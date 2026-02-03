#!/usr/bin/env bash

if [ "$#" = 0 ]; then
  ls "${DIR}"
elif [ ! -f "${DIR}/$1" ]; then
  echo "Cannot make $1"
  exit 1
elif [ -f "${2:-$1}" ]; then
  echo "${2:-$1} already exists"
  exit 1
else
  sed "s/@YEAR@/$(date "+%Y")/" <"${DIR}/$1" >"${2:-$1}"
fi
