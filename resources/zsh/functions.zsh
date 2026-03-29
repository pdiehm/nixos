#!/usr/bin/env zsh

function await() {
  local PRE="$(date "+%s%3N")"
  eval "$*"

  local STATUS="$?"
  local NOW="$(date "+%s%3N")"
  local TIME="$((NOW - PRE))"

  if [ "$TIME" -lt 1000 ]; then
    TIME="${TIME}ms"
  elif [ "$TIME" -lt 60000 ]; then
    TIME="$((TIME / 1000))s"
  elif [ "$TIME" -lt 3600000 ]; then
    TIME="$((TIME / 60000))m $((TIME / 1000 % 60))s"
  else
    TIME="$((TIME / 3600000))h $((TIME / 60000 % 60))m $((TIME / 1000 % 60))s"
  fi

  ntfy "Command '$*' finished in $TIME with exit code $STATUS"
  return "$STATUS"
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
  trap "printf '\e[?25h\e[?1049l'" EXIT
  trap "exit 0" INT

  printf '\e[?25l\e[?1049h'

  while true; do
    printf "\e[H\e[2mWatching: %s\e[m\n\n" "$*"
    script -q -c "zsh -ic $(printf "%q" "$*")" /dev/null | sed $'s/^/\e[K/'
    printf "\e[J"

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
