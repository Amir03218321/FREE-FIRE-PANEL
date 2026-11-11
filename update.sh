#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

OWNER="Amir03218321"
REPO="FREE-FIRE-PANEL"
BRANCH="main"
FILE="danish-army-manager.sh"
DEST="${PREFIX:-/data/data/com.termux/files/usr}/bin/danish-army-manager"
URL="https://raw.githubusercontent.com/$OWNER/$REPO/$BRANCH/$FILE"
TMP="$(mktemp)"
BACKUP="$DEST.backup"
trap 'rm -f "$TMP"' EXIT

if [[ "$OWNER" == "YOUR_GITHUB_USERNAME" ]]; then
  echo "Edit update.sh and set OWNER to your GitHub username first."
  exit 1
fi
command -v curl >/dev/null 2>&1 || { echo "Run: pkg install curl -y"; exit 1; }
[[ -f "$DEST" ]] || { echo "Not installed. Run install.sh first."; exit 1; }

echo "Checking for update..."
curl -fL --retry 2 "$URL" -o "$TMP"
[[ -s "$TMP" ]] && bash -n "$TMP" || { echo "Update download/syntax check failed; current version unchanged."; exit 1; }

cp -p "$DEST" "$BACKUP"
if install -m 700 "$TMP" "$DEST"; then
  rm -f "$BACKUP"
  echo "DANISH ARMY updated successfully."
else
  mv "$BACKUP" "$DEST"
  echo "Update failed; previous version restored."
  exit 1
fi
