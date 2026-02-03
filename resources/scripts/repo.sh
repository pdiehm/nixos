#!/usr/bin/env bash

set -e
cd ~/Repos

if [ "$#" = 0 ]; then
  echo "Usage: repo <command> [args...]"
  exit 1
elif [ "$1" = "help" ]; then
  echo "Usage: repo <command> [args...]"
  echo
  echo "Commands:"
  echo "  help                   Show this help"
  echo "  clone <url> [name]     Clone a repo"
  echo "  edit <name> [path]     Open editor in a repo"
  echo "  exec <name> <cmd...>   Execute a command in a repo"
  echo "  list                   List all repos"
  echo "  remove <name>          Remove a repo"
  echo "  shell <name> [path]    Open shell in a repo"
  echo "  status [name]          Show status of one or all repos"
  echo "  update [name]          Update one or all repos"
elif [ "$1" = "clone" ]; then
  if [ "$#" = 2 ]; then
    git clone "$2"
  elif [ "$#" = 3 ]; then
    git clone "$2" "$3"
  else
    echo "Usage: repo clone <url> [name]"
    exit 1
  fi
elif [ "$1" = "edit" ]; then
  if [ "$#" -lt 2 ]; then
    echo "Usage: repo edit <name> [path]"
    exit 1
  fi

  if [ ! -d "$2" ]; then
    echo "Repo '$2' not found. Do you want to clone gh:/$2.git?"
    echo
    read -r -n 1 -p "[y/N] " RES
    echo

    test "$RES" = "y" || exit 1
    git clone "gh:/$2.git"
  fi

  cd "$2"
  if [ "$#" = 3 ]; then
    if [ -d "$3" ]; then
      cd "$3"
      exec "$EDITOR" .
    elif [ -f "$3" ]; then
      cd "$(dirname "$3")"
      exec "$EDITOR" "$(basename "$3")"
    else
      echo "Path '$3' not found."
      exit 1
    fi
  else
    exec "$EDITOR" .
  fi
elif [ "$1" = "exec" ]; then
  if [ "$#" -lt 3 ]; then
    echo "Usage: repo exec <name> <cmd...>"
    exit 1
  fi

  if [ ! -d "$2" ]; then
    echo "Repo '$2' not found."
    exit 1
  fi

  cd "$2"
  exec "${@:3}"
elif [ "$1" = "list" ]; then
  for REPO in *; do
    test -d "$REPO" || continue
    cd "$REPO"

    URL="$(git remote get-url origin 2>/dev/null || echo "local")"
    HEAD="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"

    if [ "$HEAD" = "HEAD" ]; then
      if git rev-parse HEAD &>/dev/null; then
        echo -e "\e[1;34m$REPO \e[0;33m$(git rev-parse --short HEAD) \e[90m$URL"
      else
        echo -e "\e[1;34m$REPO \e[0;31mEMPTY \e[90m$URL"
      fi
    else
      CHANGES=""
      if [ -n "$(git status --porcelain)" ]; then
        CHANGES="\e[36m*"
      else
        while read -r BRANCH; do
          if ! git rev-parse "$BRANCH@{upstream}" &>/dev/null || [ -n "$(git rev-list "$BRANCH@{upstream}..$BRANCH")" ]; then
            CHANGES="\e[36m+"
            break
          fi
        done < <(git branch --format "%(refname:short)")
      fi

      echo -e "\e[1;34m$REPO \e[0;32m$HEAD$CHANGES \e[90m$URL"
    fi

    cd ..
  done | column --table --table-columns $'\e[4mRepo,Head,Remote\e[m'
elif [ "$1" = "remove" ]; then
  if [ "$#" -lt 2 ]; then
    echo "Usage: repo remove <name>"
    exit 1
  fi

  if [ ! -d "$2" ]; then
    echo "Repo '$2' not found."
    exit 1
  fi

  cd "$2"
  CHANGES=""
  test -n "$(git status --porcelain)" && CHANGES+="  - Uncommitted changes\n"
  test -n "$(git stash list)" && CHANGES+="  - Stashed changes\n"

  while read -r BRANCH; do
    if git rev-parse "$BRANCH@{upstream}" &>/dev/null; then
      test -n "$(git rev-list "$BRANCH@{upstream}..$BRANCH")" && CHANGES+="  - Unpushed commits ($BRANCH)\n"
    else
      CHANGES+="  - Local branch ($BRANCH)\n"
    fi
  done < <(git branch --format "%(refname:short)")

  if [ -n "$CHANGES" ]; then
    echo "The repository has been changed:"
    echo -e "$CHANGES"
    echo "Are you sure you want to remove the repo?"
    echo
    read -r -n 1 -p "[y/N] " RES
    echo

    test "$RES" = "y" || exit 1
  fi

  cd ..
  rm -rf "$2"
elif [ "$1" = "shell" ]; then
  if [ "$#" -lt 2 ]; then
    echo "Usage: repo shell <name> [path]"
    exit 1
  fi

  if [ ! -d "$2" ]; then
    echo "Repo '$2' not found."
    exit 1
  fi

  cd "$2"
  if [ "$#" = 3 ]; then
    if [ ! -d "$3" ]; then
      echo "Directory '$3' not found."
      exit 1
    fi

    cd "$3"
  fi

  exec "$SHELL"
elif [ "$1" = "status" ]; then
  function status() {
    cd "$1"
    git fetch

    HEAD="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
    if [ "$HEAD" = "HEAD" ]; then
      HEAD="\e[33m$(git rev-parse --short HEAD)"
    else
      HEAD="\e[32m$HEAD"
    fi

    echo -e "\e[1mRepo: \e[34m$1 \e[m($HEAD\e[m, \e[90m$(git remote get-url origin 2>/dev/null || echo "local")\e[m)"
    echo

    if [ -n "$(git status --porcelain)" ]; then
      echo -e "\e[1mChanges:\e[m"
      git status --short
      echo
    fi

    git branch --format "%(refname:short)" | while read -r BRANCH; do
      COMMIT="$(git show --oneline --no-patch "$BRANCH" | sed -E 's/^(\w+) (.+)$/\\e[33m\1 \\e[m\2/')"

      if git rev-parse "$BRANCH@{upstream}" &>/dev/null; then
        AHEAD="$(git rev-list --count "$BRANCH@{upstream}..$BRANCH")"
        BEHIND="$(git rev-list --count "$BRANCH..$BRANCH@{upstream}")"

        echo -e "\e[32m$BRANCH\x09\e[m\u2193\e[36m$BEHIND \e[m\u2191\e[36m$AHEAD\x09$COMMIT"
      else
        echo -e "\e[32m$BRANCH\x09\e[36mlocal\x09$COMMIT"
      fi
    done | column --table --separator $'\x09' --table-columns $'\e[4mBranch,Changes,Commit\e[m'

    cd ..
  }

  if [ "$#" = 1 ]; then
    FIRST=1
    for REPO in *; do
      test -d "$REPO" || continue

      ((FIRST)) || echo -e "\n"
      FIRST=0

      status "$REPO"
    done
  elif [ "$#" = 2 ]; then
    if [ ! -d "$2" ]; then
      echo "Repo '$2' not found."
      exit 1
    fi

    status "$2"
  else
    echo "Usage: repo status [name]"
    exit 1
  fi
elif [ "$1" = "update" ]; then
  function conflict() {
    clear
    git status
    echo -n "Press enter to open editor..."
    read -r

    "$EDITOR" .
  }

  function update() {
    cd "$1"
    git fetch

    STASHED=0
    if [ -n "$(git status --porcelain)" ]; then
      STASHED=1
      git stash push --include-untracked
    fi

    HEAD="$(git rev-parse --abbrev-ref HEAD)"
    test "$HEAD" = "HEAD" && HEAD="$(git rev-parse HEAD)"

    git branch --format "%(refname:short)" | while read -r BRANCH; do
      git checkout "$BRANCH"
      git rev-parse "@{u}" &>/dev/null || continue

      if [ -n "$(git status --porcelain)" ]; then
        git stash push --include-untracked
        git pull || conflict
        git stash pop || conflict
      else
        git pull || conflict
      fi
    done

    git checkout "$HEAD"

    if ((STASHED)); then
      git stash pop || conflict
    fi

    cd ..
  }

  if [ "$#" = 1 ]; then
    for REPO in *; do
      test -d "$REPO" || continue
      git -C "$REPO" rev-parse HEAD &>/dev/null || continue

      update "$REPO"
    done
  elif [ "$#" = 2 ]; then
    if [ ! -d "$2" ]; then
      echo "Repo '$2' not found."
      exit 1
    fi

    update "$2"
  else
    echo "Usage: repo update [name]"
    exit 1
  fi
else
  echo "Unknown command: $1"
  exit 1
fi
