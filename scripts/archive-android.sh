#!/usr/bin/env bash
set -euo pipefail

readonly HOME_PAGE='https://weixin.qq.com/'
readonly WORK_DIR='.archive'
readonly SOURCE_PAGE="$WORK_DIR/weixin.html"

cleanup() { rm -rf "$WORK_DIR"; }
trap cleanup EXIT

mkdir -p "$WORK_DIR"
curl --fail --location --retry 3 --silent --show-error "$HOME_PAGE" -o "$SOURCE_PAGE"

# The official page embeds all currently supported Android APK URLs in its
# Nuxt payload. Keep every distinct APK so users can choose their ABI.
mapfile -t urls < <(rg -o 'https://[^" ]*/weixin[0-9]+android[^" ]*\.apk' "$SOURCE_PAGE" | awk '!seen[$0]++')
if [ "${#urls[@]}" -eq 0 ]; then
  echo 'No Android APK URL found on the official download page.' >&2
  exit 1
fi

primary_url=$(printf '%s\n' "${urls[@]}" | rg '_arm64\.apk$' | head -n 1 || true)
if [ -z "$primary_url" ]; then primary_url="${urls[0]}"; fi
primary_name=${primary_url##*/}
if [[ "$primary_name" =~ weixin([0-9]{4})android ]]; then
  digits=${BASH_REMATCH[1]}
  version="${digits:0:1}.${digits:1:1}.${digits:2:2}"
else
  echo "Could not derive version from $primary_name" >&2
  exit 1
fi

assets=()
notes="$WORK_DIR/release-notes.txt"
signature_input="$WORK_DIR/signature.txt"
printf 'Version: %s\nUpdateTime: %s (UTC)\n\nOfficial download sources:\n' "$version" "$(date -u '+%Y-%m-%d %H:%M:%S')" > "$notes"

for url in "${urls[@]}"; do
  filename=${url##*/}
  path="$WORK_DIR/$filename"
  curl --fail --location --retry 3 --silent --show-error "$url" -o "$path"
  hash=$(sha256sum "$path" | awk '{print $1}')
  printf '%s  %s\n' "$hash" "$filename" | tee -a "$signature_input" > "$path.sha256"
  assets+=("$path" "$path.sha256")
  printf -- '- %s\n  %s\n' "$filename" "$url" >> "$notes"
done

signature=$(sha256sum "$signature_input" | awk '{print $1}')
printf '\nPackageSignature: %s\n' "$signature" >> "$notes"
latest_signature=$(gh release view --json body --jq '.body' 2>/dev/null | sed -n 's/^PackageSignature: //p' | head -n 1 || true)
if [ -n "$latest_signature" ] && [ "$signature" = "$latest_signature" ]; then
  echo 'Official Android packages are unchanged.'
  exit 0
fi

tag="v$version"
if gh release view "$tag" >/dev/null 2>&1; then tag="${tag}_$(date -u '+%Y%m%d')"; fi
gh release create "$tag" "${assets[@]}" --title "WeChat Android $tag" --notes-file "$notes"
