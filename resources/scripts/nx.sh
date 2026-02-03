#!/usr/bin/env bash

set -e

if [ "$#" = 0 ]; then
  echo "Usage: nx <command> [args...]"
  exit 1
elif [ "$1" = "help" ]; then
  echo "Usage: nx <command> [args...]"
  echo
  echo "Commands:"
  echo "  help                 Show this help"
  echo "  diff                 List new commits"
  echo "  edit                 Open editor in repository"
  echo "  iso                  Build installer image"
  echo "  list                 List installed generations"
  echo "  repl [host]          Start repl in configuration"
  echo "  reset <gen> [mode]   Reset to previous generation"
  echo "  secrets [type]       Edit secret stores"
  echo "  sync                 Sync repository"
  echo "  test                 Test configuration"
  echo "  upgrade [mode]       Upgrade machine"
  echo "  version              Show system version"
elif [ "$1" = "diff" ]; then
  REV="$(nixos-version --configuration-revision)"

  if [ "$REV" = "<dirty>" ]; then
    echo "Error: unstable revision"
    exit 1
  fi

  git -C ~/.config/nixos pull
  git -C ~/.config/nixos log --oneline --no-decorate "$REV.."
elif [ "$1" = "edit" ]; then
  cd ~/.config/nixos
  exec "$EDITOR" .
elif [ "$1" = "iso" ]; then
  nix build ~/.config/nixos#nixosConfigurations.installer.config.system.build.isoImage
  cp result/iso/*.iso nixos.iso
  rm result
elif [ "$1" = "list" ]; then
  nixos-rebuild list-generations
elif [ "$1" = "repl" ]; then
  nixos-rebuild --impure --flake "$HOME/.config/nixos#${2:-$NIXOS_MACHINE_NAME}" repl
elif [ "$1" = "reset" ]; then
  if [ "$#" -lt 2 ]; then
    echo "Usage: nx reset <gen> [mode]"
    exit 1
  fi

  sudo "/nix/var/nix/profiles/system-$2-link/bin/switch-to-configuration" "${3:-boot}"
elif [ "$1" = "secrets" ]; then
  sudo GNUPGHOME=/etc/nixos/.gnupg sops "$HOME/.config/nixos/resources/secrets/${2:-$NIXOS_MACHINE_TYPE}/store.yaml"
elif [ "$1" = "sync" ]; then
  git -C ~/.config/nixos pull
  git -C ~/.config/nixos push
elif [ "$1" = "test" ]; then
  nixos-rebuild --sudo --impure --flake ~/.config/nixos test
elif [ "$1" = "upgrade" ]; then
  sudo --validate
  while true; do
    trap 'kill -- -"$$"' EXIT
    sleep 250
    sudo --validate
  done &

  SUDO_LOOP_PID="$!"
  trap 'kill "$SUDO_LOOP_PID"' EXIT

  git -C ~/.config/nixos pull
  nixos-rebuild --sudo --impure --flake ~/.config/nixos "${2:-boot}"
elif [ "$1" = "version" ]; then
  REV="$(nixos-version --configuration-revision)"

  uname -a
  echo "NixOS $(nixos-version)"

  if [ "$REV" = "<dirty>" ]; then
    echo "??????? unstable revision"
  else
    git -C ~/.config/nixos show --oneline --no-decorate --no-patch "$REV"
  fi
else
  echo "Unknown command: $1"
  exit 1
fi
