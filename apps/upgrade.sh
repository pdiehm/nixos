#!/usr/bin/env bash

set -e
echo "build(deps): automatic upgrade" >MSG

echo "::group::Flake"
nix flake update

CHANGES="$(git diff flake.lock)"
git add flake.lock

test -n "$CHANGES" && {
  echo -e "\nFlake changes:"
  grep '"repo":' <<<"$CHANGES" | cut -d '"' -f 4 | sort -u | sed "s/^/  - /"
} >>MSG
echo "::endgroup::"

echo "::group::Dynhostmgr"
pushd overlay/dynhostmgr
cargo upgrade --incompatible
popd

CHANGES="$(git diff overlay/dynhostmgr/Cargo.toml)"
git add overlay/dynhostmgr

test -n "$CHANGES" && {
  echo -e "\nDynhostmgr changes:"
  grep ^+ <<<"$CHANGES" | tail -n +2 | cut -d = -f 1 | sort -u | sed "s/^+/  - /"
} >>MSG
echo "::endgroup::"

echo "::group::Waybar UPS plugin"
pushd overlay/waybar-ups
cargo upgrade --incompatible
popd

CHANGES="$(git diff overlay/waybar-ups/Cargo.toml)"
git add overlay/waybar-ups

test -n "$CHANGES" && {
  echo -e "\nWaybar UPS plugin changes:"
  grep ^+ <<<"$CHANGES" | tail -n +2 | cut -d = -f 1 | sort -u | sed "s/^+/  - /"
} >>MSG
echo "::endgroup::"

echo "::group::Prettier"
pushd overlay/prettier
TMP="$(mktemp)"

jq '.dependencies |= with_entries(.value = "*")' package.json >"$TMP"
cp "$TMP" package.json
npm upgrade --save

if [ -n "$(git status --porcelain package.json)" ]; then
  jq '.version = (now | strftime("%Y-%m-%d"))' package.json >"$TMP"
  cp "$TMP" package.json
  npm upgrade
fi

rm "$TMP"
popd

CHANGES="$(git diff overlay/prettier/package.json)"
git add overlay/prettier

test -n "$CHANGES" && {
  echo -e "\nPrettier changes:"
  grep ^+ <<<"$CHANGES" | tail -n +3 | cut -d '"' -f 2 | sort -u | sed "s/^/  - /"
} >>MSG
echo "::endgroup::"

echo "::group::Vim spellfiles"
TMP="$(mktemp -d)"
pushd "$TMP"
curl -fsSLO https://cgit.freedesktop.org/libreoffice/dictionaries/plain/de/de_DE_frami.aff
curl -fsSLO https://cgit.freedesktop.org/libreoffice/dictionaries/plain/de/de_DE_frami.dic
curl -fsSLO https://cgit.freedesktop.org/libreoffice/dictionaries/plain/en/en_US.aff
curl -fsSLO https://cgit.freedesktop.org/libreoffice/dictionaries/plain/en/en_US.dic
popd

pushd resources/vim
nvim -c "silent mkspell! de $TMP/de_DE_frami" -c q
nvim -c "silent mkspell! en $TMP/en_US" -c q
popd

rm -rf "$TMP"
CHANGES="$(git status --porcelain resources/vim)"
git add resources/vim

test -n "$CHANGES" && {
  echo -e "\nVim spellfile changes:"
  sort -u <<<"$CHANGES" | sed -E "s|^.*/(.+)$|  - \1|"
} >>MSG
echo "::endgroup::"

echo "::group::Firefox extensions"
TMP="$(mktemp -d)"
echo "[" >"$TMP/extensions.json"

FIRST=1
while read -r EXT; do
  ((FIRST)) || echo "," >>"$TMP/extensions.json"
  FIRST=0

  NAME="$(jq -r .name <<<"$EXT")"
  echo "  - $NAME"

  curl -fsSI "https://addons.mozilla.org/firefox/downloads/latest/$NAME/latest.xpi" >"$TMP/$NAME.txt"
  SOURCE="$(sed -En "s/^location: (\S+)\s*$/\1/p" "$TMP/$NAME.txt")"

  if [ -z "$SOURCE" ]; then
    echo "    -> Failed, no location returned"
    echo "::warning::No location returned for Firefox extension $NAME"
    SOURCE="$(jq -r .source <<<"$EXT")"
  fi

  curl -fsSL -o "$TMP/$NAME.xpi" "$SOURCE"
  ID="$(unzip -cq "$TMP/$NAME.xpi" manifest.json | jq -r "(.browser_specific_settings // .applications).gecko.id")"

  echo -n "  { \"name\": \"$NAME\", \"id\": \"$ID\", \"source\": \"$SOURCE\" }" >>"$TMP/extensions.json"
done < <(jq -c ".[]" resources/extensions/firefox.json)

echo -e "\n]" >>"$TMP/extensions.json"
mv "$TMP/extensions.json" resources/extensions/firefox.json
rm -rf "$TMP"

CHANGES="$(git diff resources/extensions/firefox.json)"
git add resources/extensions/firefox.json

test -n "$CHANGES" && {
  echo -e "\nFirefox extension changes:"
  grep ^+ <<<"$CHANGES" | tail -n +2 | cut -d '"' -f 4 | sort -u | sed "s/^/  - /"
} >>MSG
echo "::endgroup::"

echo "::group::Thunderbird extensions"
TMP="$(mktemp -d)"
echo "[" >"$TMP/extensions.json"

FIRST=1
while read -r EXT; do
  ((FIRST)) || echo "," >>"$TMP/extensions.json"
  FIRST=0

  NAME="$(jq -r .name <<<"$EXT")"
  echo "  - $NAME"

  curl -fsSI "https://addons.thunderbird.net/thunderbird/downloads/latest/$NAME/latest.xpi" >"$TMP/$NAME.txt"
  SOURCE="$(sed -En "s/^location: (\S+)\s*$/\1/p" "$TMP/$NAME.txt")"

  if [ -z "$SOURCE" ]; then
    echo "    -> Failed, no location returned"
    echo "::warning::No location returned for Thunderbird extension $NAME"
    SOURCE="$(jq -r .source <<<"$EXT")"
  fi

  curl -fsSL -o "$TMP/$NAME.xpi" "$SOURCE"
  ID="$(unzip -cq "$TMP/$NAME.xpi" manifest.json | jq -r "(.browser_specific_settings // .applications).gecko.id")"

  echo -n "  { \"name\": \"$NAME\", \"id\": \"$ID\", \"source\": \"$SOURCE\" }" >>"$TMP/extensions.json"
done < <(jq -c ".[]" resources/extensions/thunderbird.json)

echo -e "\n]" >>"$TMP/extensions.json"
mv "$TMP/extensions.json" resources/extensions/thunderbird.json
rm -rf "$TMP"

CHANGES="$(git diff resources/extensions/thunderbird.json)"
git add resources/extensions/thunderbird.json

test -n "$CHANGES" && {
  echo -e "\nThunderbird extension changes:"
  grep ^+ <<<"$CHANGES" | tail -n +2 | cut -d '"' -f 4 | sort -u | sed "s/^/  - /"
} >>MSG
echo "::endgroup::"
