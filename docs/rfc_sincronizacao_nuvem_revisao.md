# Revisão da RFC — Passagem de caixa pela nuvem

> **Status:** Aprovada pelo autor — Fases 0–3 (fix pack, schema v9, Worker e
> Fase A) implementadas em 04/10/2026. Ver `sincronizacao_nuvem.md`.
> A Fase B (junção automática) aguarda o critério da seção 5.3: 4+ semanas de
> revezamento real contando divergências.
> **RFC revisada:** `docs/rfc_sincronizacao_nuvem.md` (04/10/2026)
> **Revisor:** Claude Code (revisão no nível staff, com verificação do código)
> **Data:** 04/10/2026

---

## 1. Parecer geral (TL;DR)

**A direção está certa.** Opção D (R2 + Worker + snapshots versionados com escrita condicional) é a escolha correta para este problema, escala e restrições. O transporte está bem desenhado. O problema está na outra metade: **o motor de junção está subestimado e duas premissas sobre o código atual estão erradas**, o que quebraria a junção linha a linha como descrita.

**Nota geral: 7/10.** Aprovada com mudanças obrigatórias (seção 5).

As três mudanças mais importantes:

1. **Fatiar a entrega.** O caso dominante é o revezamento linear (Marcone → Diogo → Marcone), que é *fast-forward*: não precisa de junção nenhuma. Entregue primeiro o backup versionado com detecção de divergência (Fase A), e só depois o merge automático (Fase B). ~80% do valor sai com ~30% do esforço e do risco.
2. **Junção por agregado + versão lógica, não LWW por relógio.** A edição de venda regenera os UUIDs das linhas a cada edição (ver 4.2), então LWW linha a linha duplica e orfana linhas. A unidade de merge precisa ser o agregado (venda + linhas + alocações como bloco *replace-set*), decidido por um contador de versão por linha (`rowVersion`) com desempate por `deviceId` — relógio de parede só para exibição.
3. **E1 (movimentações de estoque) + tombstones em TODOS os caminhos de DELETE.** Hoje há DELETE físico em `deleteSale`, `deleteEventCascade`, nos endpoints do host Wi-Fi e no `updateCombo`. Sem converter todos, linhas apagadas "ressuscitam" na junção.

---

## 2. Pontuação por dimensão

| Dimensão | Nota | Comentário |
|---|---|---|
| Definição do problema e contexto | 9/10 | Claro, com exemplo real e anti-escopo explícito. Exemplar. |
| Levantamento do estado do código | 7/10 | Honesto, mas duas premissas falham na verificação (4.1, 4.2) |
| Alternativas consideradas | 8/10 | Boa cobertura; faltou a alternativa "oplog por dispositivo" (5.8) |
| Arquitetura e transporte (R2/Worker/CAS) | 8/10 | Sólida. VACUUM INTO + gzip + sha256 + escrita condicional é o desenho certo |
| Modelo de dados e junção | 5/10 | LWW por relógio + merge linha a linha não sobrevive ao código real |
| Interação com o sync Wi-Fi existente | 3/10 | Não abordada — e é onde mora o maior risco de perda de dados (4.5) |
| Segurança | 7/10 | Worker como gatekeeper é correto; modelo de ameaça bem calibrado |
| Plano e testes | 6/10 | Fases boas, mas monolíticas; cenários de teste bons porém incompletos (seção 7) |
| **Geral** | **7/10** | Direção aprovada; merge e integração precisam de redesenho |

---

## 3. O que a RFC acerta (prós)

- **Recorte do problema.** Separar "revezamento entre dias" (este RFC) de "concorrência no mesmo evento" (Wi-Fi já resolve) é a decisão de escopo mais importante do documento, e está certa.
- **Descartar backend completo.** Para centenas de vendas/evento e um time de voluntários, Supabase/Firebase adiciona login, regras de acesso e um segundo modelo de dados para manter. R2 + Worker é proporcional ao problema.
- **Worker como gatekeeper.** Não embutir chave S3 no APK e aplicar a regra `N → N+1` no servidor é o ponto de segurança/integridade certo. Escrita condicional via ETag no R2 (binding `put(..., { onlyIf })`) funciona para o CAS do manifest.
- **`VACUUM INTO`** para gerar a cópia: resolve WAL/consistência no *upload* (mas não no *restore* — ver 4.7).
- **Cópia de segurança antes de qualquer substituição ou junção** (N3/N5): não-negociável e está lá.
- **Reconhecer que contadores de estoque não se somam** e propor E1/E2 em vez de fingir que o problema não existe.
- **Perguntas explícitas ao revisor** com as dúvidas reais — incluindo a do relógio lógico, que é exatamente onde o desenho precisa mudar.

---

## 4. Riscos e lacunas (contras), com evidência no código

### 4.1 ❌ Premissa falsa: "UUID texto em todas as tabelas"
`product_combo_items` **não tem id próprio** — a PK é composta `{comboProductId, childProductId}` (`lib/data/database.dart:61-68`), e `updateCombo` (`database.dart:1271`) apaga e reinsere as linhas. Junção linha a linha por UUID não se aplica a essa tabela.
**Correção:** tratar o combo como **agregado** (produto-combo + seus itens viajam juntos, decididos pela versão do produto), ou dar id sintético à tabela. A primeira é mais coerente com 5.5.

### 4.2 ❌ Premissa frágil: linhas de venda estáveis
`updateSaleWithLines` (`database.dart:936-1089`) faz DELETE físico das linhas e **insere linhas novas com UUIDs novos** a cada edição. Consequência para o merge linha a linha: se A edita a venda X, o celular B tem as linhas antigas (UUIDs que não existem mais em A) e A tem linhas novas (UUIDs que B desconhece). Um merge por UUID **duplicaria as linhas** (antigas + novas) na mesma venda.
A RFC até diz "venda e linhas como bloco" (6.7 item 3), mas descreve o algoritmo geral como linha a linha. **O bloco não pode ser um caso especial: tem de ser a regra.** O merge de venda é *replace-set*: vence a venda com maior versão, e o conjunto de linhas do perdedor é **apagado**, não mesclado.

### 4.3 ⚠️ DELETEs físicos em mais lugares do que a RFC mapeia
A exclusão lógica (6.3) só funciona se **todos** os caminhos de DELETE virarem tombstone:
- `deleteSale` (`database.dart:1509-1547`) — chamado pela UI e pelo endpoint `delete-sale` do host (`lib/providers/sync_provider.dart:645`)
- `deleteEventCascade` (`database.dart:1443-1486`) — apaga o evento inteiro fisicamente
- endpoints `delete-product` / `delete-denom` do host Wi-Fi
- `updateCombo` e `updateSaleWithLines` (internos ao agregado — podem continuar físicos **se** o merge for por agregado)

Sem isso, o cenário é: A apaga a venda, B ainda a tem com `updatedAt` antigo → a junção **ressuscita a venda apagada**. O tombstone de evento também precisa de política definida (apagar evento em A × vender nesse evento em B).

### 4.4 ⚠️ LWW por relógio de parede
Tudo hoje é `DateTime.now().millisecondsSinceEpoch` do aparelho. Para o revezamento semanal, minutos de deriva toleram-se; mas o caso que decide conflito é justamente "os dois editaram a mesma coisa", onde um relógio errado (fuso trocado, hora manual) silenciosamente escolhe o perdedor errado — e a RFC admite que o perdedor "se perde".
**Correção (responde a pergunta 4 da RFC):** `rowVersion INTEGER` por linha — na escrita local, `rowVersion = max(rowVersion local, rowVersion visto no remoto) + 1`; desempate por `deviceId`. É um relógio de Lamport por linha: ~10 linhas de código, zero dependência de relógio. `updatedAtMs` continua existindo, mas **só para humanos** (exibição, resumo da junção).

### 4.5 🔴 A interação com o sync Wi-Fi não foi analisada — e é o maior risco
O sync local (`sync_provider.dart` + `AppDatabase.syncEventData`, `database.dart:1299-1377`) **apaga tudo do evento no cliente e reinsere** com `insertOrReplace` a cada refresh. Três colisões diretas com a nuvem:

1. **Perda de dados já existente hoje:** se o cliente Wi-Fi fica desconectado, a venda é gravada localmente (`new_sale_screen.dart:549-586`) — e o próximo `syncEventData` **apaga essa venda em silêncio**. A nuvem não causa esse bug, mas vai conviver com ele e pode fotografar o estado errado. Corrigir **antes** da Fase A.
2. **Clobbering das colunas de sync:** o apaga-e-reinsere do `syncEventData` vai sobrescrever `rowVersion`/`updatedBy`/`deletedAtMs` com o que vier do host. O snapshot do host precisa transportar essas colunas, senão a junção da nuvem perde a base de comparação.
3. **Dirty flag em clientes:** `cloud.dirty` via `db.tableUpdates()` dispara em cada refresh Wi-Fi. Num evento com 3 celulares, os 3 ficam dirty e os 3 tentam subir snapshot → divergência artificial e churn de versões. **Política: em modo cliente, upload para nuvem desabilitado; só o host (ou modo standalone) sobe.**

### 4.6 ⚠️ Estoque: E1 é a única opção séria, e precisa cobrir ajuste manual
O estoque hoje é read-modify-write em Dart (`_abateProductStock` `database.dart:676-694`, `_revertProductStock` :696-711), sem trilha. Pontos que a RFC não cobre:
- **Ajustes manuais hoje sobrescrevem `stockQty` com valor absoluto** (edição de produto/ficha e endpoints do host, `sync_provider.dart:470-538`). No E1, o ajuste manual vira `stock_movement(delta, reason: 'ajuste')` calculado como `novoValor − saldoAtual`; no E2 ("recalcular das vendas") os ajustes manuais ficam sem registro — por isso **E2 é insuficiente, não só "mais simples"**.
- Combos não guardam estoque (calculado dos filhos, `database.dart:422-463`) — as movimentações devem ser geradas nos **filhos**, como o desconto já faz.
- `stockQty` vira cache derivado: recalculado após junção e após restore.

### 4.7 ⚠️ Restore atual não serve de base sem conserto
`database_backup.dart:47-75` sobrescreve o arquivo do banco **sem remover os `-wal`/`-shm`** e sem validar schema. Se houver um WAL órfão da base antiga, o SQLite pode aplicá-lo sobre a base nova (corrupção). O fluxo 6.8 da RFC herda isso. **Correção:** no restore, fechar o banco, apagar `arquivo-wal`/`arquivo-shm`, copiar, validar `PRAGMA user_version`/`schemaVersion` antes de religar.

### 4.8 ⚠️ Bugs existentes que a junção vai amplificar (fix pack prévio)
- `updateSaleWithLines` **perde as `sale_change_dot_allocations`** (apaga e não recria) — hoje é um bug localizado; com merge, vira divergência de estoque de fichas entre celulares.
- `openCashSession` grava o operador de abertura em `closedBy` (`database.dart:760`) — trivial, mas mexe em `cash_sessions` na mesma migração.
- `cash_sessions` **não entra no snapshot do sync Wi-Fi** — ok para a nuvem (cada celular abre a sua), mas confirma que "sessão fechada vence a aberta" (6.7 item 5) precisa ser por `rowVersion`, não por `updatedAtMs`.

### 4.9 ⚠️ Esforço subestimado na migração v9
`updatedAt`/`rowVersion` precisam ser atualizados em **todo call site de escrita** — e o Drift não tem hook automático por linha. Há ~21 usos de `DateTime.now` e dezenas de `update/insert` espalhados. **Tática:** centralizar a escrita num helper (`touch(companion)` que injeta `rowVersion`, `updatedAtMs`, `updatedByDevice`) e proibir `into(...).insert`/`update(...)` direto fora do helper via revisão/lint. Sem isso, uma escrita esquecida = linha que nunca vence merge.

---

## 5. Proposta refinada — "Opção D2"

Mantém o transporte da Opção D (R2 + Worker + manifest + CAS). Muda o modelo de dados, a unidade de junção e o faseamento.

### 5.1 Princípios
1. **Fast-forward é o caso comum; junção é exceção.** O desenho otimiza o revezamento linear e trata divergência como evento raro, visível e auditado.
2. **A unidade de junção é o agregado, não a linha.** Venda (+ linhas + alocações) e combo (+ itens) viajam e vencem como bloco.
3. **Ordem lógica, não relógio.** `rowVersion` (Lamport por linha) decide; `deviceId` desempata; relógio de parede só informa humanos.
4. **Tudo que o merge lê precisa sobreviver ao sync Wi-Fi.** As colunas de sync transitam também no snapshot local host→cliente.

### 5.2 Schema v9 (substitui o 6.3 da RFC)
Em todas as tabelas:

| Coluna | Tipo | Uso |
|---|---|---|
| `rowVersion` | `INTEGER NOT NULL DEFAULT 0` | Decide o merge (Lamport: `max(local, remoto)+1` a cada escrita) |
| `updatedByDevice` | `TEXT` | Desempate e auditoria |
| `updatedAtMs` | `INTEGER NOT NULL` | **Só exibição** (aviso "Diogo · 14:58", resumo da junção) |
| `deletedAtMs` | `INTEGER NULL` | Tombstone (exclusão lógica) |

Mais:
- `product_combo_items`: continua sem id próprio, mas passa a ser **parte do agregado do produto-combo** (merge pela versão do produto pai). Alternativa: id sintético — só se o agregado se provar insuficiente.
- Nova tabela `stock_movements(id UUID, itemType, itemId, delta, reason, saleId?, atMs, deviceId, rowVersion)` — **E1**, incluindo ajustes manuais como movimento com `reason`.
- `stockQty` vira cache derivado: recalculado após junção, restore e no fechamento de sessão (checagem de consistência barata).
- Converter para tombstone: `deleteSale`, `deleteEventCascade` (tombstone no evento + filhos), `delete-product`, `delete-denom`. Consultas da UI filtram `deletedAtMs IS NULL`.
- Helper central de escrita (4.9) na mesma fase, antes de qualquer código de nuvem.

### 5.3 Fase A — Backup versionado com fast-forward (entrega valor sozinha)
Cobre N1, N2, N3, N5 e N6 — todo o revezamento linear — **sem motor de junção**:

- **Upload:** gatilhos da RFC (6.5) + `VACUUM INTO` + gzip + sha256 + `PUT ?expected=N`. Igual à RFC. Política extra: **em modo cliente Wi-Fi, upload desabilitado** (4.5.3); debounce mínimo de ~3 min entre uploads.
- **Download:** `GET manifest` ao abrir; se `remote.version > lastSynced` e **não-dirty** → aplica direto (com backup local + aviso "Atualizado da versão do Diogo (hoje 14:58) — Desfazer"), respondendo a pergunta 6 da RFC: **automático com undo**, não diálogo.
- **Divergência (dirty + remoto mais novo):** **bloqueia e orienta**, não junta: backup automático dos dois lados + tela mostrando os dois resumos ("Local: 12 vendas novas · Nuvem: 45 vendas do Diogo") + opções: *manter local e sobrescrever a nuvem* / *baixar nuvem e arquivar local* / *exportar os dois*. Nada é perdido (N5 cobre), nada é sobrescrito em silêncio (espírito do N4).
- **Critério de saída da Fase A:** rodar 4+ semanas de revezamento real. **Medir quantas divergências reais acontecem.** Se forem ~zero (esperado, dado que o Wi-Fi cobre a concorrência do mesmo dia), a Fase B encolhe ou é adiada — a junção automática pode ser YAGNI.

### 5.4 Fase B — Junção automática por agregados (substitui o 6.7 da RFC)
Só se a Fase A mostrar divergências recorrentes. Com `ATTACH DATABASE`, em transação:

1. Backup pré-merge (igual RFC).
2. **Catálogo** (`events`, `products`, `event_dot_denominations`): LWW por linha via `rowVersion` (desempate `deviceId`); tombstone vence linha mais antiga. Combo = agregado (produto + itens).
3. **Vendas:** agregado *replace-set* — para cada `sale.id`, vence a venda de maior `rowVersion`; as linhas e alocações do perdedor são **removidas**, as do vencedor copiadas integralmente. Vendas que só existem de um lado: união.
4. **Sessões:** união por id; fechada vence aberta via `rowVersion`.
5. **Estoque:** união de `stock_movements` por UUID (append-only, sem conflito possível) → recálculo de `stockQty`.
6. Resumo humano + upload do resultado como `v{N+1}` (CAS; 409 → repete).

Repare no ganho: dos 8 tipos de linha, **só o catálogo usa LWW** (3 tabelas de baixa frequência de edição). Vendas são replace-set por agregado e movimentos são união pura. A superfície de conflito real encolhe para "dois celulares editaram o mesmo produto/venda", que é raro e auditável.

### 5.5 Worker e segurança (confirma o 6.9 da RFC, com ajustes)
- Endpoints e CAS como na RFC. No R2, usar `put(key, body, { onlyIf: { etagMatches } })` no manifest.
- Autenticação "código da igreja + segredo" via header, sobre HTTPS: **adequada ao modelo de ameaça** (dados de cantina, risco = integridade, não confidencialidade). Não gastar esforço com per-device tokens agora.
- Multi-tenant por prefixo `{codigoIgreja}/` com o segredo validado por igreja.
- Se o CAS por ETag se provar chato, um **Durable Object** (disponível no plano gratuito com storage SQLite) serializa `N → N+1` trivialmente — alternativa, não requisito.
- Retenção (pergunta 7): últimas 20 versões + 1 por semana por 6 meses. Custa centavos de nada no R2 e cobre "descobrimos o erro semanas depois".

### 5.6 Fix pack prévio (antes da Fase A)
1. Venda offline do cliente Wi-Fi apagada pelo `syncEventData` (perda de dados real, hoje).
2. `updateSaleWithLines` recriar as alocações de troco.
3. `openedBy` gravado em `closedBy`.
4. Restore: apagar `-wal`/`-shm` + validar schema (4.7).

### 5.7 Plano revisado

| Fase | Entrega | Observação |
|---|---|---|
| **0. Fix pack** | 5.6 | Pré-requisito; valor imediato mesmo sem nuvem |
| **1. Schema v9** | 5.2 + helper central de escrita + sync Wi-Fi transportando as colunas novas | Maior risco do projeto; testar migração com banco real |
| **2. Worker** | `cloud/worker/` + CAS + retenção | ~100 linhas, igual RFC |
| **3. Fase A** | Upload/download/fast-forward/divergência-guiada + UI (tela nuvem + ☁️) | **Marco de valor: revezamento resolvido** |
| **4. Observar** | 4+ semanas de uso real; contar divergências | Decide o escopo da Fase B |
| **5. Fase B** | Motor de junção por agregados + testes dos cenários (seção 7) | Só se necessário |

### 5.8 Alternativa considerada e não recomendada agora: oplog por dispositivo
A forma "canônica" deste problema é cada celular anexar um **log de operações append-only** no R2 (`{igreja}/ops/{deviceId}/{seq}.jsonl`) e os demais aplicarem idempotentemente — zero conflito de escrita, histórico natural, sem merge de snapshot. É o desenho certo se um dia houver 5+ celulares assíncronos ou acompanhamento remoto em tempo quase-real. **Não agora:** exige rotear toda escrita do app por uma camada de operações (refatoração invasiva do `database.dart`), define um segundo schema (o das ops) para versionar, e o ganho sobre o D2 é pequeno no volume atual. Fica registrado como evolução natural caso a Fase B cresça.

---

## 6. Respostas às perguntas da RFC (seção 8)

1. **Opção D ou backend?** D, mas fatiada (Fase A/B). A complexidade que preocupava — a junção — é adiada e encolhida; se a Fase A mostrar que divergência real não acontece, ela nem é construída. Backend (A) continua desproporcional.
2. **E1 ou E2?** **E1.** E2 não tem onde registrar ajustes manuais (hoje sobrescritos como valor absoluto — 4.6) e exige exatamente o "registro próprio" que o transforma em E1 pela metade.
3. **Worker aceitável?** Sim, é a escolha certa. Alternativa de URLs pré-assinadas perde a regra `N → N+1` no servidor; não vale.
4. **Relógio do celular ou lógico?** **Lógico** (`rowVersion` Lamport por linha, desempate por `deviceId`). Relógio de parede só para exibição. Custo: ~10 linhas; benefício: o merge deixa de depender de NTP.
5. **Banco inteiro ou por evento?** **Banco inteiro.** O catálogo (produtos, fichas) é compartilhado entre eventos; por-evento criaria o problema "quem é dono do catálogo". Com poucos MB gzipados, não há ganho que justifique.
6. **Atualizar automático ou perguntar?** **Automático quando não-dirty**, com backup + toast "Desfazer". Perguntar sempre vira atrito e treino para ignorar o aviso.
7. **Quantas versões?** Últimas 20 + 1/semana por 6 meses (5.5).
8. **Cenários não cobertos:** ver seção 7, itens 8–14.

---

## 7. Cenários de teste (amplia a lista da RFC)

Os 7 da RFC, mais:

8. A edita a venda X (UUIDs de linha regenerados) e B tem a versão antiga → sem duplicação de linhas; vence o agregado de maior `rowVersion`.
9. A apaga a venda X, B não mexeu → tombstone propaga; venda some em B; estoque recalculado.
10. A apaga o **evento** inteiro, B registrou vendas nele → política definida (tombstone de evento vence? vendas de B arquivadas no backup?) — decidir e testar.
11. A edita o combo (itens apagados/reinseridos) e B tem a versão antiga → agregado do combo íntegro, sem itens órfãos/duplicados.
12. Cliente Wi-Fi faz refresh (`syncEventData`) → `rowVersion`/`deletedAtMs` preservados; venda offline local **não** é apagada (fix pack).
13. Celular com relógio 2h atrasado edita produto → ainda vence se a edição for logicamente posterior (`rowVersion`).
14. Upload com schemaVersion local **menor** que o remoto → bloqueado ("atualize o app") também na subida, não só na descida (evita downgrade do snapshot da nuvem).
15. Restore sobre banco com WAL pendente → sem corrupção (WAL/SHM removidos).

---

## 8. Resumo da recomendação

> **Aprovar a Opção D com o redesenho D2:** schema v9 com `rowVersion` lógico + tombstones completos + E1; junção por **agregados** (não linha a linha) quando — e se — a Fase A provar que divergência real existe; fix pack dos bugs de perda de dados **antes** de qualquer código de nuvem; e a interação com o sync Wi-Fi tratada como requisito de primeira classe, não nota de rodapé.
