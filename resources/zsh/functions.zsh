#!/usr/bin/env zsh

function await() {
  "$@"
  ntfy "Command '$*' finished with exit code $?"
}

function ed() {
  if [ "$#" = 0 ]; then
    "$EDITOR"
  elif [ -d "$1" ]; then
    pushd "$1"
    "$EDITOR" .
    popd
  else
    local DIR="$(dirname "$1")"
    mkdir -p "$DIR"

    pushd "$DIR"
    "$EDITOR" "$(basename "$1")"
    popd
  fi
}

function mkcd() {
  mkdir -p "$1"
  cd "$1"
}

function watch() (
  trap "tput cnorm; tput rmcup" EXIT
  trap "exit 0" INT

  tput smcup
  tput civis

  while clear; do
    echo -e "\e[90mWatching: $*\e[m\n"
    eval "$*"

    sleep 1
  done
)

if [ "$NIXOS_MACHINE_TYPE" = "desktop" ]; then
  function mktex() {
    latexmk -pdf -cd -outdir="$PWD/build" "$1"
  }
elif [ "$NIXOS_MACHINE_TYPE" = "server" ]; then
  function service() {
    if [ "$#" = 0 ]; then
      docker compose ls
    else
      docker compose --file "/home/pascal/docker/$NIXOS_MACHINE_NAME/$1/compose.yaml" "${@:2}"
    fi
  }
fi
