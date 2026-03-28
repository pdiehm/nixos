#!/usr/bin/env zsh

setopt PROMPT_SUBST

export PROMPT='%F{4}%~%f$(_prompt_git) %F{%(?.5.1)}$(_prompt_char)%f '
export RPROMPT='$(_prompt_host)'

function _prompt_char() {
  if expr "$TTY" : /dev/tty > /dev/null; then
    echo -n ">"
  else
    echo -en "\u276F"
  fi
}

function _prompt_git() {
  git rev-parse HEAD &> /dev/null || return

  local BRANCH="$(git rev-parse --abbrev-ref HEAD)"
  if [ "$BRANCH" = "HEAD" ]; then
    echo -n " %F{3}$(git rev-parse --short HEAD)%f"
  else
    echo -n " %F{8}$BRANCH%f"
  fi

  local STATUS="$(timeout 0.1 git status --porcelain)"
  local CHANGED="$(grep -Ec "^.(\w|\?)" <<< "$STATUS")"
  local STAGED="$(grep -Ec "^\w." <<< "$STATUS")"

  if [ "$CHANGED" -gt 0 ] && [ "$STAGED" -gt 0 ]; then
    echo -n "%F{6}\u203D%f"
  elif [ "$CHANGED" -gt 0 ]; then
    echo -n "%F{6}?%f"
  elif [ "$STAGED" -gt 0 ]; then
    echo -n "%F{6}!%f"
  fi

  test -n "$(git stash list)" && echo -n " %F{6}\u2026%f"

  if [ -n "$(git remote show)" ] && [ "$BRANCH" != "HEAD" ]; then
    if git rev-parse "@{u}" &> /dev/null; then
      local AHEAD="$(git rev-list --count "@{u}..")"
      local BEHIND="$(git rev-list --count "..@{u}")"

      if [ "$AHEAD" -gt 0 ] && [ "$BEHIND" -gt 0 ]; then
        echo -n " %F{6}\u296F%f"
      elif [ "$AHEAD" -gt 0 ]; then
        echo -n " %F{6}\u2191%f"
      elif [ "$BEHIND" -gt 0 ]; then
        echo -n " %F{6}\u2193%f"
      fi
    else
      echo -n " %F{6}\u21A5%f"
    fi
  fi

  local GIT_DIR="$(git rev-parse --git-dir)"
  if [ -f "$GIT_DIR/MERGE_HEAD" ]; then
    echo -n " %F{1}(merge)%f"
  elif [ -f "$GIT_DIR/REVERT_HEAD" ]; then
    echo -n " %F{1}(revert)%f"
  elif [ -f "$GIT_DIR/BISECT_LOG" ]; then
    echo -n " %F{1}(bisect)%f"
  elif [ -f "$GIT_DIR/rebase-merge/interactive" ]; then
    local STEP="$(< "$GIT_DIR/rebase-merge/msgnum")"
    local TOTAL="$(< "$GIT_DIR/rebase-merge/end")"
    echo -n " %F{1}(rebase)%f %F{6}$STEP%F{8}/%F{6}$TOTAL%f"
  fi
}

function _prompt_host() {
  test -n "$SSH_TTY" && echo -n " %F{14}%n@%M%f"
}
