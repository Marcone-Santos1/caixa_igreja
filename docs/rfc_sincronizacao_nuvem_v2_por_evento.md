# RFC v2 — Nuvem por evento, com configuração de um toque

> **Status:** Aprovada (Worker simplificado + por-evento substitui
> banco-inteiro) e implementada em 05/10/2026. Ver `sincronizacao_nuvem.md`.
> **Motivação:** feedback do Marcone (05/10/2026) sobre a Fase A entregue:
> (1) o fluxo do Worker da Cloudflare pareceu pesado; (2) a tela de
> configuração ficou confusa; (3) a sincronização deveria ser **por evento**.
> **Substitui:** o transporte "banco inteiro" da Fase A
> (`sincronizacao_nuvem.md`). O schema v9, o fix pack e toda a
> infraestrutura de versão/tombstone/movimentações **permanecem** — são a
> fundação disto.

---

## 1. Diagnóstico do incômodo

| Incômodo | Causa raiz | O que muda |
|---|---|---|
| "Worker confuso" | O deploy aparecia como tarefa do usuário, e cada igreja exigia `wrangler secret put` (registro manual no servidor) | Deploy vira tarefa **única do desenvolvedor**; o endpoint vai **embutido no app**; a igreja se registra **sozinha no primeiro envio** (sem tocar na Cloudflare nunca mais) |
| "Config confusa" (4 campos) | Endpoint + código + segredo + nome digitados em cada celular | **1 toque** no primeiro celular ("Ativar backup") e **1 QR** nos demais — mesmo gesto do pareamento Wi-Fi que os usuários já conhecem |
| "Quero por evento" | Fase A versiona o banco inteiro: divergência em qualquer lugar trava tudo, e não dá para trazer só "a quermesse de domingo" | Cada evento vira uma **cadeia de versões própria** na nuvem |

**Correção de registro:** a revisão D2 (pergunta 5) recomendou "banco
inteiro" alegando catálogo compartilhado entre eventos. **Estava errado**:
desde o schema v3, produtos, fichas, combos, sessões e vendas pertencem a um
evento (`eventId` em tudo). O banco já é um conjunto de ilhas por evento —
sincronizar por evento é o recorte natural, não um caso especial.

---

## 2. Proposta

### 2.1 Unidade de sincronização: o **agregado do evento**

Um snapshot por evento = JSON gzip com as linhas do evento, **incluindo
tombstones** (diferente do snapshot Wi-Fi, que filtra):

```
{ "formatVersion": 1, "schemaVersion": 9,
  "event": {...}, "denoms": [...], "products": [...], "comboItems": [...],
  "cashSessions": [...], "sales": [...], "saleLines": [...],
  "changeAllocations": [...], "stockMovements": [...] }
```

- Reusa a serialização Drift (`toJson`/`fromJson`) já usada no sync Wi-Fi.
- `stockMovements`: as movimentações dos itens do evento.
- `cashSessions` entram (hoje ficam fora do snapshot Wi-Fi).
- Aplicação local = substituição do agregado sob `runWithSyncBypass`
  (mesma mecânica do `syncEventData`, estendida).
- Tamanho típico: dezenas de KB gzip — menor e mais rápido que o banco.

### 2.2 Nuvem: uma cadeia de versões **por evento**

```
{igreja}/
  auth.json                      ← hash do segredo (criado no 1º uso)
  events/
    {eventId}/
      manifest.json              ← versão atual DESTE evento
      snapshots/v000007.json.gz
```

- Regra `N → N+1` com CAS continua igual, só que **por evento**: divergência
  na quermesse não impede o almoço comunitário de sincronizar.
- `GET /v1/events` lista os eventos na nuvem (título, data, versão, quem
  enviou) — é o que permite "baixar um evento" num celular novo.
- Estado local por evento: `lastSyncedVersion` + *fingerprint* de alteração
  (soma de `rowVersion` + contagem de linhas do agregado — monotônico graças
  ao v9). `dirty` = fingerprint atual ≠ fingerprint do último envio. Nada de
  marcar dirty "no escuro": é derivado dos dados.

### 2.3 Registro automático da igreja (fim do `CHURCH_SECRETS`)

- O app **gera** código + segredo aleatórios ao ativar.
- O primeiro request grava `auth.json` com o hash do segredo
  (escrita condicional "só se não existir") — a igreja "reivindica" o seu
  espaço. Requests seguintes exigem o mesmo segredo.
- Ninguém roda `wrangler secret` nunca mais; adicionar uma igreja nova não
  toca no servidor.
- Modelo de ameaça inalterado: segredo forte gerado por máquina, hash no
  servidor, bucket invisível sem o Worker.

### 2.4 Configuração: 1 toque + QR

- **Primeiro celular:** botão **"Ativar backup na nuvem"** → gera a chave,
  registra na nuvem, pronto. Zero campos.
- **Demais celulares:** **"Conectar com QR"** → escaneia o QR exibido pelo
  primeiro (token `caixa://cloud/<base64>` com endpoint+código+segredo —
  mesmo padrão do token Wi-Fi). Alternativa: colar a chave como texto.
- Endpoint padrão **embutido no app** (`--dart-define` com default); campo
  visível só em "Avançado" para quem hospedar o próprio Worker.
- O deploy do Worker continua existindo, mas é **uma tarefa do
  desenvolvedor, uma única vez** — o usuário final nunca ouve falar de
  Cloudflare.

### 2.5 UI centrada no evento

- O **hub do evento** passa a ser o lugar da nuvem daquele evento: estado
  (☁️ em dia / pendente / divergência), "enviar agora", "baixar versão",
  histórico e resolução de divergência — tudo no contexto do evento.
- A lista de eventos ganha **"Eventos na nuvem"**: eventos que existem na
  nuvem e não neste celular aparecem para baixar (é assim que o caixa da
  semana seguinte começa).
- A tela em Ajustes encolhe para: ativar/parear (QR), visão geral dos
  eventos sincronizados e "Avançado".
- Gatilhos automáticos continuam os mesmos (fechar caixa, ~3 min após
  escrita, abrir/retomar app), aplicados **ao evento alterado**.

### 2.6 O que acontece com o que já foi construído

| Peça | Destino |
|---|---|
| Schema v9 (rowVersion, tombstones, movimentações, triggers) | **Mantido** — é o que torna o agregado por evento confiável |
| Fix pack (venda offline, troco, openedBy, restore seguro) | **Mantido** |
| Worker | **Reescrito** (rotas por evento + registro automático); mesmo tamanho |
| `CloudBackupService` / `CloudSyncController` | **Reescritos** para manifest/estado por evento |
| Tela de nuvem + ícone ☁️ | **Refeitos** no modelo 2.4/2.5 |
| Snapshot de banco inteiro | **Removido** da nuvem. O backup local (`VACUUM INTO` antes de aplicar/restaurar, export manual em Ajustes) continua |
| Divergência | Igual à Fase A (guiada, nada sobrescrito em silêncio), só que **por evento** |

Nada disso foi colocado em produção (o Worker nem chegou a ser publicado),
então não há migração de dados na nuvem a fazer.

---

## 3. Alternativa considerada: Google Drive da igreja (sem servidor nenhum)

Usar uma conta Google da igreja e guardar os snapshots no Drive
(`google_sign_in` + API do Drive): cada celular faz "Entrar com Google" e
pronto — nenhum Worker, nenhuma Cloudflare.

- ✅ Zero hospedagem; login que qualquer voluntário entende.
- ❌ Configurar OAuth no Google Cloud Console (client id, fingerprints
  SHA-1 por keystore, tela de consentimento) é **mais** burocrático para o
  desenvolvedor do que um `wrangler deploy`, e volta a cada troca de chave
  de assinatura.
- ❌ O Drive não tem escrita condicional decente → a regra `N → N+1` fica
  frouxa (dá para emular, mas é o tipo de gambiarra que a RFC original
  rejeitou na Opção C).
- ❌ Amarra tudo a uma conta Google compartilhada (e à 2FA dela).

**Recomendação: não.** O incômodo real era a config na ponta, e o 2.3/2.4
elimina isso mantendo o CAS forte. Fica registrado como plano B se um dia a
Cloudflare virar problema.

---

## 4. Decisões para o autor

1. **Transporte:** Worker simplificado com registro automático (recomendado)
   ou Google Drive (seção 3)?
2. **Escopo:** por-evento **substitui** o banco-inteiro na nuvem
   (recomendado — o backup local continua cobrindo o resto), ou manter os
   dois?
3. **Endpoint embutido:** qual URL fica como padrão no app (a do deploy do
   Marcone)? Defino via `--dart-define` com fallback.
