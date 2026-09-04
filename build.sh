#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NUGET="$SCRIPT_DIR/Utils/nuget.exe"
EXPAND="$SCRIPT_DIR/Utils/expand.exe"

checkNugetVersion=0
publish=0
for arg in "$@"; do
  case "$arg" in
    -FetchVersionFromNuget) checkNugetVersion=1 ;;
    -Publish) publish=1 ;;
  esac
done

http_fetch() { # url -> stdout
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL --retry 3 "$1"
  else
    wget -qO- "$1"
  fi
}

http_download() { # url dest
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL --retry 3 -o "$2" "$1"
  else
    wget -q -O "$2" "$1"
  fi
}

# Returns 0 if $1 >= $2
version_ge() {
  awk -v a="$1" -v b="$2" 'BEGIN {
    na = split(a, A, ".");
    nb = split(b, B, ".");
    n = (na > nb) ? na : nb;
    for (i = 1; i <= n; i++) {
      x = (i <= na) ? A[i] + 0 : 0;
      y = (i <= nb) ? B[i] + 0 : 0;
      if (x > y) exit 0;
      if (x < y) exit 1;
    }
    exit 0
  }'
}

shopt -s nullglob
cabs=("$SCRIPT_DIR"/*.cab)
downloadManually=0
webViewVersion="1.0"

# Download .cab files manually if no one in build directory
if [ "${#cabs[@]}" -eq 0 ]; then
  echo "WebView2 .cab files not found, trying to download it automatically"
  downloadPage="$(http_fetch "https://developer.microsoft.com/en-us/microsoft-edge/webview2/#download-section")"
  cabUrls="$(printf '%s' "$downloadPage" | grep -oE '"http[^"]*Runtime\.[0-9.]+\.[^"]*\.cab"' || true)"
  if [ -z "$cabUrls" ]; then
    echo "No WebView2 .cab files found on the download page" >&2
    exit 1
  fi

  # First we need get all versions from page and find latest
  while IFS= read -r url; do
    [ -n "$url" ] || continue
    v="$(printf '%s' "$url" | sed -E 's/.*Runtime\.([0-9]+(\.[0-9]+)+).*/\1/')"
    [ -n "$v" ] || continue
    webViewVersion="$(printf '%s\n%s\n' "$webViewVersion" "$v" | sort -V | tail -n 1)"
  done <<< "$cabUrls"
  echo "Select version: $webViewVersion"

  while IFS= read -r url; do
    [ -n "$url" ] || continue
    url="${url#\"}"
    url="${url%\"}"
    url="$(printf '%s' "$url" | sed 's/\\u002F/\//g')"
    case "$url" in
      *"$webViewVersion"*) ;;
      *) continue ;;
    esac
    fileName="${url##*/}"
    echo "Package: $fileName"
    if [ "$checkNugetVersion" -eq 1 ]; then
      echo "Checking nuget version"
      arch="$(printf '%s' "$fileName" | awk -F. '{print $(NF-1)}' | tr '[:lower:]' '[:upper:]')"
      packageName="WebView2.Runtime.$arch"
      nugetOutput="$("$NUGET" list "$packageName" || true)"
      nugetVersion="$(printf '%s\n' "$nugetOutput" | grep -F "$packageName" | tail -n 1 | awk '{print $2}' || true)"
      echo "Nuget version: $nugetVersion"
      if [ -n "$nugetVersion" ] && version_ge "$nugetVersion" "$webViewVersion"; then
        echo "Nuget version >= microsoft website version, skipping"
        continue
      fi
    fi
    echo "Downloading: $fileName"
    http_download "$url" "$SCRIPT_DIR/$fileName"
  done <<< "$cabUrls"
  downloadManually=1
fi

shopt -s nullglob
cabs=("$SCRIPT_DIR"/*.cab)

buildLangFiles=1
for cab in "${cabs[@]}"; do
  fileName="${cab##*/}"
  arch="$(printf '%s' "$fileName" | awk -F. '{print $(NF-1)}' | tr '[:lower:]' '[:upper:]')"

  output_path="$SCRIPT_DIR/WebView2.Runtime.$arch"
  output_folder="WebView2.Runtime.$arch"
  wv_dir="$output_path/contentFiles/any/any"

  # Remove exists directory
  rm -rf "$output_path"
  mkdir -p "$wv_dir"

  # Unpack cab
  "$EXPAND" -F:* "$cab" "$wv_dir"

  # Now we need rename folder in content directory
  inner="$(find "$wv_dir" -mindepth 1 -maxdepth 1 -type d -print -quit)"
  if [ -n "$inner" ] && [ "$inner" != "$wv_dir/WebView2" ]; then
    mv "$inner" "$wv_dir/WebView2"
  fi
  wv_dir="$wv_dir/WebView2"

  # Parse version from manifest
  version_file="$(find "$output_path/contentFiles" -name '*.manifest' -type f -print -quit)"
  webViewVersion="$(basename "$version_file" .manifest)"

  if [ "$buildLangFiles" -eq 1 ]; then
    locales_output_path="$SCRIPT_DIR/WebView2.Runtime.Locales"
    locales_output_folder="WebView2.Runtime.Locales"

    # Remove exists directory
    rm -rf "$locales_output_path"
    mkdir -p "$locales_output_path/contentFiles/any/any/WebView2"

    cp -r "$wv_dir/Locales" "$locales_output_path/contentFiles/any/any/WebView2/"

    # Copy nuspec and replace vars
    sed "s/%VERSION%/$webViewVersion/g" "$SCRIPT_DIR/Template.Locales.nuspec" > "$locales_output_path/$locales_output_folder.nuspec"
    # Copy license file
    cp "$SCRIPT_DIR/LICENSE.txt" "$locales_output_path/LICENSE.txt"
    # Copy readme
    cp "$SCRIPT_DIR/README.md" "$locales_output_path/README"

    # Compile nupkg
    "$NUGET" pack "$locales_output_path/$locales_output_folder.nuspec" -OutputDirectory "$SCRIPT_DIR"

    rm -rf "$locales_output_path"
    buildLangFiles=0
  fi

  # Cleanup some useless files to save space
  # Copilot - useless AI
  # DirectX files exists in windows for ages
  for uf in copilot dxcompiler d3dcompiler; do
    find "$wv_dir" -mindepth 1 -depth -iname "*$uf*" -exec rm -rf {} \;
  done

  # Delete all locales except english
  find "$wv_dir/Locales" -mindepth 1 -depth ! -name 'en-US.*' -exec rm -rf {} \;

  # Copy nuspec and replace vars
  sed -e "s/%NAME%/$output_folder/g" -e "s/%VERSION%/$webViewVersion/g" "$SCRIPT_DIR/Template.nuspec" > "$output_path/$output_folder.nuspec"
  # Copy license file
  cp "$SCRIPT_DIR/LICENSE.txt" "$output_path/LICENSE.txt"
  # Copy readme
  cp "$SCRIPT_DIR/README.md" "$output_path/README"

  # Compile nupkg
  "$NUGET" pack "$output_path/$output_folder.nuspec" -OutputDirectory "$SCRIPT_DIR"

  rm -rf "$output_path"
done

# Remove downloaded files
if [ "$downloadManually" -eq 1 ]; then
  rm -f "${cabs[@]}"
fi

nupkgs=("$SCRIPT_DIR"/*"$webViewVersion".nupkg)
if [ "${#nupkgs[@]}" -gt 0 ]; then
  printf '%s\n' "${nupkgs[@]}"
fi

if [ "$publish" -eq 1 ]; then
  powershell.exe -File "$SCRIPT_DIR/publish.ps1"
fi
