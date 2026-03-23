#!/usr/bin/env bash

test "$UID" = 0 || exec sudo "$0" "$@"

function dup() {
  PASSPHRASE="$(<"@backup_pass@")" duplicity --archive-dir /var/lib/duplicity --ssh-options "-i '@backup_key@'" "$@"
}

if [ "$#" = 0 ]; then
  @pre_script@
  dup cleanup --force "@target@/@machine@"
  dup remove-all-but-n-full --force 2 "@target@/@machine@"
  dup incremental --full-if-older-than "$(date "+%Y-%m-01")" / "@target@/@machine@" @spec@ --exclude "**"
  @post_script@
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
    dup restore "@target@/@machine@" "$2"
  elif [ "$#" = 3 ]; then
    dup restore "@target@/$2" "$3"
  elif [ "$#" = 4 ]; then
    dup restore --path-to-restore "$3" "@target@/$2" "$4"
  else
    echo "Usage: backup clone [machine [path]] <target>"
    exit 1
  fi
elif [ "$1" = "list" ]; then
  dup list-current-files "@target@/${2:-@machine@}"
elif [ "$1" = "restore" ]; then
  TMP="$(mktemp -d)"
  dup restore ${2:+--path-to-restore "${2#/}"} ${3:+--time "$3"} "@target@/@machine@" "$TMP"

  cp -abv "$TMP/." "${2:-/}"
  rm -rf "$TMP"
elif [ "$1" = "status" ]; then
  dup collection-status "@target@/${2:-@machine@}"
else
  echo "Unknown command: $1"
  exit 1
fi
