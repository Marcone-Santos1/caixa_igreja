#!/usr/bin/env bash
# Publica uma atualização do app na nuvem (atualizador embutido).
#
# Uso:  ./cloud/publish_app.sh ["notas da versão"]
#
# Builda o APK release (assinado com o keystore de android/key.properties),
# sobe para o R2 em `_app/` e atualiza o manifest `_app/latest.json`.
# Os celulares com o app aberto veem o banner "Atualização disponível".
set -euo pipefail

cd "$(dirname "$0")/.."

ENDPOINT="${CLOUD_SYNC_ENDPOINT:-https://cantina-padroeira-sync.marconedev.workers.dev}"
BUCKET="cantina-padroeira-sync"
NOTES="${1:-}"

VERSION_LINE=$(grep '^version:' pubspec.yaml | awk '{print $2}')
VERSION_NAME="${VERSION_LINE%%+*}"
VERSION_CODE="${VERSION_LINE##*+}"

echo "==> Build do APK $VERSION_NAME ($VERSION_CODE) com endpoint $ENDPOINT"
flutter build apk --release --dart-define=CLOUD_SYNC_ENDPOINT="$ENDPOINT"

APK="build/app/outputs/flutter-apk/app-release.apk"
SHA256=$(shasum -a 256 "$APK" | awk '{print $1}')
SIZE=$(stat -f %z "$APK")

echo "==> Enviando APK (${SIZE} bytes, sha256 ${SHA256:0:12}…) para o R2"
(cd cloud/worker && npx wrangler r2 object put \
  "$BUCKET/_app/cantina-$VERSION_CODE.apk" \
  --file "../../$APK" \
  --content-type application/vnd.android.package-archive \
  --remote)

MANIFEST=$(mktemp)
cat > "$MANIFEST" <<JSON
{
  "versionCode": $VERSION_CODE,
  "versionName": "$VERSION_NAME",
  "sha256": "$SHA256",
  "sizeBytes": $SIZE,
  "notes": "$NOTES",
  "uploadedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
JSON
(cd cloud/worker && npx wrangler r2 object put \
  "$BUCKET/_app/latest.json" \
  --file "$MANIFEST" \
  --content-type application/json \
  --remote)
rm -f "$MANIFEST"

echo "==> Publicado: $VERSION_NAME ($VERSION_CODE). Os apps avisam na próxima abertura."
