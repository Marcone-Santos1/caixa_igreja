# Worker de sincronização — Cantina Padroeira (por evento)

Worker Cloudflare + bucket R2 que guardam snapshots versionados **por
evento** (RFC v2 `docs/rfc_sincronizacao_nuvem_v2_por_evento.md`). Custo
esperado: **zero**.

## Deploy — tarefa do DESENVOLVEDOR, uma única vez

Os usuários do app nunca tocam na Cloudflare. Não há segredos para
configurar no servidor: cada igreja se registra sozinha no primeiro envio
(o app gera código + segredo e o Worker guarda só o hash).

```bash
cd cloud/worker
npx wrangler login
npx wrangler r2 bucket create cantina-padroeira-sync
npx wrangler deploy
```

O deploy imprime a URL (ex.: `https://cantina-padroeira-sync.<conta>.workers.dev`).
Embuta essa URL no app no build:

```bash
flutter build apk --dart-define=CLOUD_SYNC_ENDPOINT=https://cantina-padroeira-sync.<conta>.workers.dev
```

(Sem o `--dart-define`, o app pede o endereço uma única vez ao ativar o
backup — e o QR de pareamento o carrega para os demais celulares.)

## Como as igrejas entram

Nenhum cadastro no servidor. No app: **Ajustes → Backup na nuvem →
Ativar** — o app gera o código e o segredo e o primeiro envio "reivindica"
o espaço `{codigo}/` no bucket (o hash do segredo fica em
`{codigo}/auth.json`; gravação condicional, sem corrida). Os outros
celulares entram **escaneando o QR** do primeiro.

## Garantias

- Credenciais do R2 nunca saem da Cloudflare; o APK não carrega chave alguma.
- Versões por evento estritamente `N → N+1` (CAS por ETag): dois celulares
  enviando o mesmo evento ao mesmo tempo ⇒ o segundo recebe `409`, nunca
  sobrescrita silenciosa. Eventos diferentes não competem entre si.
- `sha256` conferido no servidor.
- Retenção por evento: últimos 10 snapshots + 1 por semana por 6 meses.

## Teste rápido

```bash
URL=https://cantina-padroeira-sync.<conta>.workers.dev
curl $URL/v1/health
curl -H 'x-church-code: teste123' -H 'x-church-secret: s3gr3d0' $URL/v1/events
# 1ª chamada registra a igreja "teste123"; => {"events":[]}
curl -H 'x-church-code: teste123' -H 'x-church-secret: errado' $URL/v1/events
# => 403
```
