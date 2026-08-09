#!/usr/bin/env bash
set -u

repo_dir="$(cd "$(dirname "$0")/.." && pwd)"
url_check="$repo_dir/scripts/check-local-url.sh"
temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/codex-sites-local-url.XXXXXX")"
trap 'rm -rf "$temp_dir"' EXIT

printf '#!/usr/bin/env bash\nprintf "%%s\\n" "${!#}" > "$CURL_MARKER"\n' > "$temp_dir/curl"
chmod +x "$temp_dir/curl"

marker="$temp_dir/curl-ran"
output="$(CURL_MARKER="$marker" PATH="$temp_dir:/usr/bin:/bin" "$url_check" "http://localhost:3000/health" 3000 2>&1)"
if [[ ! -f "$marker" ]] || ! grep -Fq "PASSED" <<<"$output"; then
  echo "FAILED: expected localhost URL should be checked over HTTP"
  printf '%s\n' "$output"
  exit 1
fi

rm "$marker"
set +e
output="$(CURL_MARKER="$marker" PATH="$temp_dir:/usr/bin:/bin" "$url_check" "http://localhost:3001/" 3000 2>&1)"
status=$?
set -e
if [[ "$status" -ne 1 ]] || [[ -e "$marker" ]] || ! grep -Fq "Do not accept a fallback port" <<<"$output"; then
  echo "FAILED: fallback port should fail before the HTTP request"
  printf '%s\n' "$output"
  exit 1
fi

echo "PASSED: exact localhost URL is checked and fallback ports are rejected"
