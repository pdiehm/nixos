#!/usr/bin/env bash

test "$UID" = 0 || exec sudo "$0" "$@"

function dup() {
  PASSPHRASE="$(<"${BACKUP_PASS}")" duplicity --archive-dir /var/lib/duplicity --ssh-options "-i '${BACKUP_KEY}'" "$@"
}

if [ "$#" = 0 ]; then
  "${PRE_START}"
  dup cleanup --force "${TARGET}/${MACHINE}"
  dup remove-all-but-n-full --force 2 "${TARGET}/${MACHINE}"

  # shellcheck disable=SC2086
  dup incremental --full-if-older-than 1W / "${TARGET}/${MACHINE}" ${SPEC} --exclude "**"
  "${POST_START}"
elif [ "$1" = "help" ]; then
  echo "Usage: backup [command] [args...]"
  echo
  echo "Commands:"
  echo "  help                              Show this help"
  echo "  clone [machine [path]] <target>   Clone a backup"
  echo "  list [machine]                    List files in backup"
  echo "  restore [path] [time]             Restore a backup"
  echo "  status [machine]                  Show backup status"
elif [ "$1" = "clone" ]; then
  if [ "$#" = 2 ]; then
    dup restore "${TARGET}/${MACHINE}" "$2"
  elif [ "$#" = 3 ]; then
    dup restore "${TARGET}/$2" "$3"
  elif [ "$#" = 4 ]; then
    dup restore --path-to-restore "$3" "${TARGET}/$2" "$4"
  else
    echo "Usage: backup clone [machine [path]] <target>"
    exit 1
  fi
elif [ "$1" = "list" ]; then
  dup list-current-files "${TARGET}/${2:-${MACHINE}}"
elif [ "$1" = "restore" ]; then
  TMP="$(mktemp -d)"
  dup restore ${2:+--path-to-restore "${2#/}"} ${3:+--time "$3"} "${TARGET}/${MACHINE}" "$TMP"

  cp -arv "$TMP/." "${2:-/}"
  rm -rf "$TMP"
elif [ "$1" = "status" ]; then
  dup collection-status "${TARGET}/${2:-${MACHINE}}"
else
  echo "Unknown command: $1"
  exit 1
fi
