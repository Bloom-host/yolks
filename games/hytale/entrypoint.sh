#!/bin/bash
set -e

cd /home/container

# Populate machine-id (for Hardware UUID lookups)
MID="/home/container/machine-id"
if [ ! -s "$MID" ]; then
  hostname | tr -d '-' | tr -d '\n' > "$MID"
  echo >> "$MID"
fi

# Hand off to the standard yolks Java entrypoint logic (STARTUP parsing + exec)
exec /java.sh
