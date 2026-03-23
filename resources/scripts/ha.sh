#!/usr/bin/env bash

if [ "$#" = 3 ]; then
  TOKEN="$(<"@token@")"
  curl -fsSL -H "Authorization: Bearer $TOKEN" -d "{ \"entity_id\": \"$1.$3\" }" "http://homeassistant:8123/api/services/$1/$2"
else
  echo "Usage: ha <domain> <action> <device>"
  exit 1
fi
