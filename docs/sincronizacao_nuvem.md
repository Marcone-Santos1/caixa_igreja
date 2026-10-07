# Sincronização pela nuvem (por evento) — como funciona

> Implementa a RFC v2 `rfc_sincronizacao_nuvem_v2_por_evento.md` (transporte
> por evento) + RFC v3 `rfc_sincronizacao_nuvem_v3_compartilhamento.md`
> (compartilhamento controlado), sobre o schema v9 da revisão
> `rfc_sincronizacao_nuvem_revisao.md`.
> Resolve a passagem de caixa entre celulares em dias diferentes.

## 0. Modelo de acesso (RFC v3)

- **Cada celular tem credencial própria.** O 1º celular "Ativa" e vira
  **administrador**; os demais entram por **convite** (QR de uso único,
  48h), que o servidor troca por uma credencial do aparelho. Administradores
  convidam, revogam celulares (efeito imediato, no servidor) e podem
  promover outro administrador — faça isso cedo, para o caso de o celular
  principal quebrar.
- **Todo evento sobe automaticamente como backup PRIVADO** (acesso só do
  dono). Nada é compartilhado por padrão.
- **Compartilhar = ampliar a lista.** No painel do evento (☁️), a seção
  "Quem recebe" liga/desliga cada celular da igreja. Só quem está na lista
  vê, baixa e envia versões do evento. Dono do evento e administradores
  gerenciam a lista.
- **Desligar um celular de um evento** o faz parar de receber novas versões
  na hora; o que ele já baixou permanece no aparelho dele (não existe
  apagamento remoto — dito com todas as letras).

---

## 1. Visão geral

**Cada evento é sincronizado separadamente.** Um snapshot de evento é um
JSON compactado com tudo do evento (produtos, fichas, combos, sessões,
vendas, linhas, trocos e movimentações de estoque — incluindo exclusões
lógicas), versionado numa cadeia própria `N → N+1` na nuvem (R2 da
Cloudflare, atrás de um Worker que guarda as credenciais).

```
Celular A (semana 1)                    Celular B (semana 2)
  vende, fecha o caixa                     abre o app
  └─ envia "Quermesse" v7 ──► nuvem ─────► vê "Quermesse" na lista e baixa
                                           vende, fecha o caixa
  abre o app ◄───────────── nuvem ◄─────── envia "Quermesse" v8
  └─ recebe a v8 (fast-forward automático)
```

Divergência num evento não trava os outros. Com novidades dos dois lados, o
app **pergunta** — nada é sobrescrito em silêncio, e as versões anteriores
ficam no histórico do evento.

A junção automática de bases divergentes (Fase B da RFC) continua **não**
construída: observar 4+ semanas de uso real antes de decidir.

## 2. Configuração (onboarding + QR)

Na **primeira abertura** o app pergunta como começar: **Cadastrar minha
igreja** (nome da igreja + nome do aparelho → este celular vira o
administrador e recebe o **código de recuperação**, mostrado uma única vez
— guarde!), **Entrar com convite** (QR/colar) ou **Usar sem nuvem por
enquanto** (ativa depois em Ajustes). O código de recuperação devolve o
posto de administrador num aparelho novo se o principal quebrar; é de uso
único e pode ser regenerado em Avançado.

### 2b. Deploy do servidor (desenvolvedor)

O deploy do Worker é tarefa **única do desenvolvedor**
(`cloud/worker/README.md`); a URL vai embutida no build
(`--dart-define=CLOUD_SYNC_ENDPOINT=...`). Não há cadastro de igrejas no
servidor: o app gera código + segredo e o primeiro envio registra a igreja
sozinho.

- **Primeiro celular:** Ajustes → Backup na nuvem → **"Ativar backup na
  nuvem"**. Pronto.
- **Demais celulares:** **"Conectar com QR"** e escanear o QR exibido em
  "Parear outro celular" (ou colar o código como texto). Mesmo gesto do
  pareamento Wi-Fi.

## 3. Gatilhos (automáticos, por evento)

| Gatilho | Comportamento |
|---|---|
| Fechar sessão de caixa | Envia o evento imediatamente |
| ~20 s após a última escrita | Envia os eventos alterados (debounce) |
| **A cada 60 s com o app aberto** | Verifica a nuvem e aplica fast-forwards (é o que faz o outro celular receber sem reabrir o app) |
| Abrir / retomar o app | Verifica tudo; aplica fast-forwards; envia pendências |
| Sair do app (pausar) | Tenta enviar pendências; o polling para (bateria) |
| ☁️ no hub → "Enviar agora" | Envia o evento na hora |

"Pendente" não é uma flag frágil: é derivado dos dados — a impressão
digital do evento (soma dos `rowVersion` do schema v9) é comparada à do
último envio. Sem internet, fica pendente e sobe no próximo gatilho. O app
continua 100% funcional offline.

**Modo terminal Wi-Fi:** conectado como *cliente* da sincronização local, o
aparelho não envia para a nuvem — só o caixa central (host) ou aparelhos em
modo normal.

**Pausar um evento:** no painel do evento (☁️ no hub), o interruptor
"Sincronizar este evento" pausa a sincronização **neste aparelho** (não
envia nem baixa; os outros celulares não são afetados). Útil para testes
locais. Ao retomar, as pendências sobem no próximo ciclo — ou, se a nuvem
avançou no meio tempo, o fluxo de divergência decide.

## 4. Ao abrir o app

- **Evento com versão mais nova na nuvem e nada pendente aqui** → aplica
  automático (fast-forward). O estado anterior fica arquivado em
  `Documents/backups/` com **Desfazer** no painel do evento.
- **Novidades dos dois lados** → **divergência**: o ☁️ do evento fica em
  alerta e o painel oferece *manter o deste aparelho* (envia por cima; a
  versão da nuvem fica no histórico) ou *usar o da nuvem* (o estado local é
  arquivado antes).
- **Evento que só existe na nuvem** → aparece num banner na lista de
  eventos, com botão **Baixar** — apenas eventos **compartilhados com este
  aparelho**; dá para dispensar o aviso (X). Backups privados de outros
  celulares (visíveis ao administrador) ficam só na tela Backup na nuvem.
- **Nuvem gravada por app mais novo** (schema/formato maior) → bloqueia com
  "atualize o app", nos dois sentidos (nunca rebaixa a nuvem).

## 5. Histórico e restauração (por evento)

O manifest de cada evento guarda as últimas 15 versões (quem enviou, quando,
quantas vendas). No painel do evento dá para **restaurar** qualquer uma: o
estado atual é arquivado e a versão restaurada fica pendente — no próximo
envio ela vira a nova versão (o histórico não é reescrito). O bucket retém
os últimos 10 snapshots por evento + 1 por semana por 6 meses.

## 6. Fundação (schema v9) — inalterada

- `rowVersion` (relógio lógico por linha, mantido por triggers SQLite),
  `updatedAtMs` (exibição), `updatedByDevice`, `deletedAtMs` (tombstones)
  em todas as tabelas; exclusões são lógicas e as consultas filtram.
- Estoque como trilha de movimentações (`stock_movements`, E1); `stockQty`
  é cache derivado. O invariante `soma(movimentações) == stockQty` viaja
  junto no agregado.
- Fix pack: venda offline do terminal Wi-Fi reenviada ao host (não é mais
  perdida), troco em fichas preservado na edição, `openedBy` correto,
  restauração de backup com validação e limpeza de WAL.

## 6b. Venda fiada no sync

Os recebimentos de fiado (`fiado_payments`, schema v10) viajam no agregado
do evento (formato v2) e no snapshot Wi-Fi; são append-only e se unem por
UUID, sem conflito. Receber um fiado exige ter o evento no aparelho. Apps
com versão anterior ao 1.3.0 são bloqueados ("atualize o app") ao receber
um agregado v2.

## 7. Limitações conhecidas

- Divergência não tem junção automática (decisão da revisão D2): o usuário
  escolhe o lado; o outro fica guardado.
- O snapshot do evento substitui o evento inteiro no fast-forward — por isso
  ele só acontece quando não há nada pendente localmente.
- Produto criado offline num terminal Wi-Fi não é reenviado ao host (só as
  vendas).
- O DDL gerado pelo Drift não emite `REFERENCES` (FKs não são aplicadas pelo
  SQLite — pré-existente); a integridade é da camada de aplicação.

## 8. Teste manual sugerido (2 aparelhos/emuladores)

1. A ativa o backup (1 toque) e exibe o QR; B escaneia → conectado.
2. A cria o evento, vende, fecha o caixa → ☁️ "Em dia (v1)".
3. B abre o app → banner "1 evento na nuvem" → Baixar → evento completo.
4. B vende e fecha → v2. A abre o app → recebe v2 automático (com Desfazer).
5. A e B vendem offline → A envia (v3) → B abre: divergência no ☁️ do
   evento; "manter o deste aparelho" → v4; a v3 fica no histórico.
6. Restaurar a v3 em qualquer aparelho → pendente → envio vira v5.
7. Dois eventos diferentes alterados em aparelhos diferentes → sincronizam
   sem conflito entre si.
