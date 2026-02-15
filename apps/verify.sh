#!/usr/bin/env bash

FAILED=0
echo "# Verify" >>"$GITHUB_STEP_SUMMARY"

echo "::group::Systems"
echo "## Systems" >>"$GITHUB_STEP_SUMMARY"
rm -f /nix/var/nix/gcroots/ci/*

while read -r MACHINE; do
  if nix build --show-trace -o "/nix/var/nix/gcroots/ci/$MACHINE" ".#nixosConfigurations.$MACHINE.config.system.build.toplevel" |& sed "s/^evaluation warning: /::warning::/"; then
    echo "- :white_check_mark: $MACHINE" >>"$GITHUB_STEP_SUMMARY"
  else
    echo "- :x: $MACHINE" >>"$GITHUB_STEP_SUMMARY"
    FAILED=1
  fi
done < <(jq -r "keys[]" machines.json)
echo "::endgroup::"

# HACK: https://github.com/oppiliappan/statix/issues/139
echo "::group::Lint nix"
echo "## Nix files" >>"$GITHUB_STEP_SUMMARY"
nix build --accept-flake-config -o /nix/var/nix/gcroots/ci/statix github:oppiliappan/statix

while read -r FILE; do
  echo "Checking $FILE"
  DIAGNOSTICS="$(nil diagnostics "$FILE" 2>&1 && /nix/var/nix/gcroots/ci/statix/bin/statix check "$FILE" 2>&1 || true)"

  if [ -z "$DIAGNOSTICS" ]; then
    echo "- :white_check_mark: $FILE" >>"$GITHUB_STEP_SUMMARY"
  else
    {
      echo "- :x: $FILE"
      echo '  ```'
      ansi2txt <<<"$DIAGNOSTICS" | sed -E "s/^/  /"
      echo '  ```'
    } >>"$GITHUB_STEP_SUMMARY"

    FAILED=1
  fi
done < <(find . -path ./resources -prune -o -name "*.nix" -print)
echo "::endgroup::"

echo "::group::Lint shell"
echo "## Shell files" >>"$GITHUB_STEP_SUMMARY"

while read -r FILE; do
  echo "Checking $FILE"
  DIAGNOSTICS="$(shellcheck "$FILE" 2>&1 || true)"

  if [ -z "$DIAGNOSTICS" ]; then
    echo "- :white_check_mark: $FILE" >>"$GITHUB_STEP_SUMMARY"
  else
    {
      echo "- :x: $FILE"
      echo '  ```'
      sed -E "s/^/  /" <<<"$DIAGNOSTICS"
      echo '  ```'
    } >>"$GITHUB_STEP_SUMMARY"

    FAILED=1
  fi
done < <(find . -name "*.sh")
echo "::endgroup::"

test "$FAILED" = 0
