#!/usr/bin/env bash

TOKEN="$(<"@token@")"

if [ "$#" = 1 ]; then
  curl -fsSL -H "Authorization: Bearer $TOKEN" -d "$1" https://ntfy.pdiehm.dev/default
elif [ "$#" = 2 ]; then
  curl -fsSL -H "Authorization: Bearer $TOKEN" -d "$2" "https://ntfy.pdiehm.dev/@machine@-$1"
else
  echo "Usage: ntfy [channel] <message>"
  exit 1
fi
