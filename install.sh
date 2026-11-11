#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# Replace this with the GitHub account that owns DANISH-ARMY-ROOT-SUITE.
OWNER="Amir03218321"
REPO="FREE-FIRE-PANEL"
BRANCH="main"
FILE="danish-army-manager.sh"
DEST="${PREFIX:-/data/data/com.termux/files/usr}/bin/danish-army-manager"
URL="https://raw.githubusercontent.com/$OWNER/$REPO/$BRANCH/$FILE"
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

if [[ "$OWNER" == "YOUR_GITHUB_USERNAME" ]]; then
  echo "Edit install.sh and set OWNER to your GitHub username first."
  exit 1
fi
command -v curl >/dev/null 2>&1 || { echo "Run: pkg install curl -y"; exit 1; }

echo "Downloading DANISH ARMY TMP MANAGER..."
curl -fL --retry 2 "$URL" -o "$TMP"
[[ -s "$TMP" ]] && bash -n "$TMP" || { echo "Download or syntax check failed."; exit 1; }
mkdir -p "$(dirname "$DEST")"
install -m 700 "$TMP" "$DEST"
echo "Installed successfully."
echo "Run: danish-army-manager"
echo "The manager's file operations require root authorization."
