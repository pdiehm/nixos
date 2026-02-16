#!/usr/bin/env zsh

function _backup() {
  if [ "$CURRENT" = 2 ]; then
    _values command clone list restore status
  elif [ "${words[2]}" = "clone" ]; then
    if [ "$CURRENT" = 3 ]; then
      _values machine "${(f)$(ls /home/pascal/.config/nixos/machines)}"
    elif [ "$CURRENT" = 4 ]; then
      _files
    elif [ "$CURRENT" = 5 ]; then
      _files
    fi
  elif [ "${words[2]}" = "list" ]; then
    if [ "$CURRENT" = 3 ]; then
      _values machine "${(f)$(ls /home/pascal/.config/nixos/machines)}"
    fi
  elif [ "${words[2]}" = "restore" ]; then
    if [ "$CURRENT" = 3 ]; then
      _files
    fi
  elif [ "${words[2]}" = "status" ]; then
    if [ "$CURRENT" = 3 ]; then
      _values machine "${(f)$(ls /home/pascal/.config/nixos/machines)}"
    fi
  fi
}

function _nx() {
  if [ "$CURRENT" = 2 ]; then
    _values command help build diff edit iso off list repl reset secrets sync test upgrade version
  elif [ "${words[2]}" = "build" ]; then
    if [ "$CURRENT" = 3 ]; then
      _values host "${(f)$(ls /home/pascal/.config/nixos/machines)}"
    fi
  elif [ "${words[2]}" = "repl" ]; then
    if [ "$CURRENT" = 3 ]; then
      _values host "${(f)$(ls /home/pascal/.config/nixos/machines)}"
    fi
  elif [ "${words[2]}" = "reset" ]; then
    if [ "$CURRENT" = 3 ]; then
      _values gen "${(f)$(nixos-rebuild list-generations --json | jq ".[].generation")}"
    elif [ "$CURRENT" = 4 ]; then
      _values mode test boot switch
    fi
  elif [ "${words[2]}" = "secrets" ]; then
    if [ "$CURRENT" = 3 ]; then
      _values type "${(f)$(ls /home/pascal/.config/nixos/resources/secrets)}"
    fi
  elif [ "${words[2]}" = "upgrade" ]; then
    if [ "$CURRENT" = 3 ]; then
      _values mode boot switch
    fi
  fi
}

compdef '_arguments ":cmd:_command_names" "*::args:_normal"' await
compdef _backup backup
compdef _files ed
compdef _files mkcd
compdef _nothing ntfy
compdef _nx nx
compdef '_arguments ":cmd:_command_names" "*::args:_normal"' watch
compdef _xh xhs

if [ "$NIXOS_MACHINE_TYPE" = "desktop" ]; then
  function _repo() {
    if [ "$CURRENT" = 2 ]; then
      _values command help clone edit exec list remove shell status update
    elif [ "${words[2]}" = "edit" ]; then
      if [ "$CURRENT" = 3 ]; then
        _values name "${(f)$(ls /home/pascal/Repos)}"
      elif [ "$CURRENT" = 4 ]; then
        _files -W "/home/pascal/Repos/${words[3]}"
      fi
    elif [ "${words[2]}" = "exec" ]; then
      if [ "$CURRENT" = 3 ]; then
        _values name "${(f)$(ls /home/pascal/Repos)}"
      else
        words=("${words[4]}" "${words[5,-1]}")
        CURRENT="$((CURRENT - 3))"
        _normal
      fi
    elif [ "${words[2]}" = "remove" ]; then
      if [ "$CURRENT" = 3 ]; then
        _values name "${(f)$(ls /home/pascal/Repos)}"
      fi
    elif [ "${words[2]}" = "shell" ]; then
      if [ "$CURRENT" = 3 ]; then
        _values name "${(f)$(ls /home/pascal/Repos)}"
      elif [ "$CURRENT" = 4 ]; then
        _files -/ -W "/home/pascal/Repos/${words[3]}"
      fi
    elif [ "${words[2]}" = "status" ]; then
      if [ "$CURRENT" = 3 ]; then
        _values name "${(f)$(ls /home/pascal/Repos)}"
      fi
    elif [ "${words[2]}" = "update" ]; then
      if [ "$CURRENT" = 3 ]; then
        _values name "${(f)$(ls /home/pascal/Repos)}"
      fi
    fi
  }

  compdef _nothing ha
  compdef '_arguments ":what:($(mk))" ":where:_files"' mk
  compdef _files mktex
  compdef _files mnt
  compdef _repo repo
  compdef _nothing wp-toggle
elif [ "$NIXOS_MACHINE_TYPE" = "server" ]; then
  function _service() {
    if [ "$CURRENT" = 2 ]; then
      _values service "${(f)$(ls /home/pascal/docker/$NIXOS_MACHINE_NAME)}"
    elif [ -f "/home/pascal/docker/$NIXOS_MACHINE_NAME/${words[2]}/compose.yaml" ]; then
      words=("docker" "compose" "--file" "/home/pascal/docker/$NIXOS_MACHINE_NAME/${words[2]}/compose.yaml" "${words[3,-1]}")
      CURRENT="$((CURRENT + 2))"
      _docker
    fi
  }

  compdef _service service
fi
