#!/usr/bin/env bash
set -u

repo_dir="$(cd "$(dirname "$0")/.." && pwd)"
runtime_check="$repo_dir/scripts/check-runtime.sh"
temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/codex-sites-runtime.XXXXXX")"
trap 'rm -rf "$temp_dir"' EXIT

make_fake_runtime() {
  local bin_dir="$1"
  local version="$2"
  mkdir -p "$bin_dir"
  printf '#!/usr/bin/env bash\nif [[ "${1:-}" == "--version" ]]; then echo "%s"; exit 0; fi\nexit 0\n' "$version" > "$bin_dir/node"
  printf '#!/usr/bin/env bash\n[[ -n "${NPM_MARKER:-}" ]] && : > "$NPM_MARKER"\necho "11.0.0"\n' > "$bin_dir/npm"
  printf '#!/usr/bin/env bash\necho "11.0.0"\n' > "$bin_dir/npx"
  printf '#!/usr/bin/env bash\n[[ -n "${PNPM_MARKER:-}" ]] && : > "$PNPM_MARKER"\necho "10.0.0"\n' > "$bin_dir/pnpm"
  chmod +x "$bin_dir/node" "$bin_dir/npm" "$bin_dir/npx" "$bin_dir/pnpm"
}

project_dir="$temp_dir/project"
mkdir -p "$project_dir"
printf '24\n' > "$project_dir/.nvmrc"
printf '24\n' > "$project_dir/.node-version"

make_fake_runtime "$temp_dir/node24" "v24.19.0"
node24_marker="$temp_dir/node24-npm-ran"
supported_output="$(HOME="$temp_dir/home" NPM_MARKER="$node24_marker" PATH="$temp_dir/node24:/usr/bin:/bin" "$runtime_check" "$project_dir" 2>&1)"
supported_status=$?
if [[ "$supported_status" -ne 0 ]] || ! grep -Fq "RUNTIME READY" <<<"$supported_output"; then
  echo "FAILED: Node 24 should pass the runtime gate"
  printf '%s\n' "$supported_output"
  exit 1
fi
if [[ ! -f "$node24_marker" ]]; then
  echo "FAILED: npm should run only after Node 24 passes"
  exit 1
fi

pnpm_project="$temp_dir/pnpm-project"
mkdir -p "$pnpm_project"
printf 'lockfileVersion: 9\n' > "$pnpm_project/pnpm-lock.yaml"
pnpm_marker="$temp_dir/pnpm-ran"
pnpm_npm_marker="$temp_dir/pnpm-project-npm-ran"
pnpm_output="$(HOME="$temp_dir/home" NPM_MARKER="$pnpm_npm_marker" PNPM_MARKER="$pnpm_marker" PATH="$temp_dir/node24:/usr/bin:/bin" "$runtime_check" "$pnpm_project" 2>&1)"
if [[ ! -f "$pnpm_marker" ]] || [[ -e "$pnpm_npm_marker" ]] || ! grep -Fq "PACKAGE MANAGER: pnpm" <<<"$pnpm_output"; then
  echo "FAILED: an existing pnpm project must preserve pnpm without invoking npm"
  printf '%s\n' "$pnpm_output"
  exit 1
fi

make_fake_runtime "$temp_dir/node20/node@20/bin" "v20.20.1"
node20_marker="$temp_dir/node20-npm-ran"
set +e
unsupported_output="$(HOME="$temp_dir/home" NPM_MARKER="$node20_marker" PATH="$temp_dir/node20/node@20/bin:/usr/bin:/bin" "$runtime_check" "$project_dir" 2>&1)"
unsupported_status=$?
set -e
if [[ "$unsupported_status" -ne 1 ]]; then
  echo "FAILED: Node 20 should be rejected with status 1"
  printf '%s\n' "$unsupported_output"
  exit 1
fi
if [[ -e "$node20_marker" ]]; then
  echo "FAILED: Node 20 must fail before npm runs"
  exit 1
fi

required_patterns=(
  "requires Node.js 22.13.0 or newer"
  "npm install installs project packages"
  "STALE SELECTED PATH"
  "brew install node@24"
  "nvm install 24"
  "VERIFY IN A FRESH LOGIN SHELL"
)
for pattern in "${required_patterns[@]}"; do
  if ! grep -Fq "$pattern" <<<"$unsupported_output"; then
    echo "FAILED: missing Node 20 guidance: $pattern"
    printf '%s\n' "$unsupported_output"
    exit 1
  fi
done

make_fake_runtime "$temp_dir/node2212" "v22.12.0"
if HOME="$temp_dir/home" PATH="$temp_dir/node2212:/usr/bin:/bin" "$runtime_check" "$project_dir" >/dev/null 2>&1; then
  echo "FAILED: Node 22.12 must be rejected"
  exit 1
fi

make_fake_runtime "$temp_dir/node2213" "v22.13.0"
if ! HOME="$temp_dir/home" PATH="$temp_dir/node2213:/usr/bin:/bin" "$runtime_check" "$project_dir" >/dev/null 2>&1; then
  echo "FAILED: Node 22.13 must pass"
  exit 1
fi

echo "PASSED: supported Node versions pass, Node 20/22.12 fail before npm, and pnpm is preserved"
