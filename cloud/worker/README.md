# Worker de sincronização — Cantina Padroeira (por evento, com compartilhamento)

Worker Cloudflare + bucket R2 com snapshots versionados **por evento** e
**controle de acesso por celular** (RFC v3
`docs/rfc_sincronizacao_nuvem_v3_compartilhamento.md`). Custo esperado:
**zero**.

## Deploy — tarefa do DESENVOLVEDOR, uma única vez

```bash
cd cloud/worker
npx wrangler login
npx wrangler r2 bucket create cantina-padroeira-sync
npx wrangler deploy
```

Embuta a URL no build do app:

```bash
flutter build apk --release \
  --dart-define=CLOUD_SYNC_ENDPOINT=https://cantina-padroeira-sync.<conta>.workers.dev
```

Não há segredos nem cadastro de igrejas no servidor.

## Modelo de acesso (v3)

- **Cada celular tem credencial própria.** O 1º celular ("Ativar" no app)
  registra a igreja e vira **administrador**; os demais entram por
  **convite de uso único** (QR, 48h), trocado por um token do aparelho
  (`/v1/join`). Só o hash do token fica no bucket.
- **Todo evento nasce privado**: `sharedWith` vazio, acesso só do dono
  (backup automático). Compartilhar = o dono/admin ampliar a lista
  (`PUT /v1/events/:id/acl`).
- **Revogação real:** admin revoga um celular (`PUT /v1/devices/:id`) e o
  acesso morre no servidor, na hora.
- Versões por evento continuam estritamente `N → N+1` (CAS por ETag), com
  sha256 conferido e retenção de 10 snapshots + 1/semana por 6 meses.

## Rotas

| Rota | Quem | O quê |
|---|---|---|
| `GET /v1/health` | público | diagnóstico |
| `POST /v1/register` | 1º celular | cria a igreja; retorna token (admin) |
| `POST /v1/invites` | admin | gera convite de uso único |
| `POST /v1/join` | convidado | troca convite por token |
| `GET /v1/devices` | membros | lista celulares |
| `PUT /v1/devices/:id` | admin | revogar/restaurar/promover |
| `GET /v1/events` | membros | só eventos acessíveis ao celular |
| `GET /v1/events/:id/manifest` · `/snapshot/:v` | dono/lista/admin | leitura |
| `PUT /v1/events/:id/snapshot?expected=N` | dono/lista/admin | nova versão |
| `PUT /v1/events/:id/acl` | dono/admin | lista "quem recebe" |

Auth: headers `x-church-code`, `x-device-id`, `x-device-token`.
IDs de evento: `[A-Za-z0-9-]`, 4–64 caracteres (o app usa UUID v7).

## Teste rápido

```bash
URL=https://cantina-padroeira-sync.<conta>.workers.dev
curl $URL/v1/health
curl -s -X POST -H 'x-church-code: minhaigreja1' -H 'x-device-id: meu-dev-1' \
  -H 'content-type: application/json' -d '{"deviceName":"Teste"}' \
  $URL/v1/register
# => {"ok":true,"deviceToken":"…","role":"admin"} (uma vez; depois 409)
```
