#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
DEST="${PREFIX:-/data/data/com.termux/files/usr}/bin/danish-army-manager"

if [[ ! -f "$DEST" ]]; then
  echo "DANISH ARMY TMP MANAGER is not installed."
  exit 0
fi

read -r -p "Type YES to remove the manager: " answer
if [[ "$answer" == "YES" ]]; then
  rm -f "$DEST"
  echo "Manager removed."
  echo "This does not delete files previously placed in /data/local/tmp."
else
  echo "Uninstall cancelled."
fi
