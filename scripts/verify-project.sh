#!/usr/bin/env bash
set -u

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_dir="."
publishing_requested=0
failures=0

for argument in "$@"; do
  case "$argument" in
    --publish)
      publishing_requested=1
      ;;
    -h|--help)
      echo "Usage: $0 [project-directory] [--publish]"
      echo "Use --publish to require a registered Sites project_id."
      exit 0
      ;;
    --*)
      echo "ERROR: unknown option: $argument"
      exit 2
      ;;
    *)
      if [[ "$project_dir" != "." ]]; then
        echo "ERROR: provide only one project directory"
        exit 2
      fi
      project_dir="$argument"
      ;;
  esac
done

if ! "$script_dir/check-runtime.sh" "$project_dir"; then
  echo "FAILED: fix the Node.js runtime before project verification."
  exit 1
fi

check_file() {
  if [[ -e "$1" ]]; then
    echo "OK: $1"
  else
    echo "MISSING: $1"
    failures=$((failures + 1))
  fi
}

cd "$project_dir" 2>/dev/null || {
  echo "ERROR: cannot enter project directory: $project_dir"
  exit 2
}

check_file package.json
check_file .openai/hosting.json
check_file convex

if [[ -f .openai/hosting.json ]]; then
  if ! command -v node >/dev/null 2>&1; then
    echo "MISSING: node is required to validate .openai/hosting.json"
    failures=$((failures + 1))
  else
    project_id="$(node -e '
      const fs = require("node:fs");
      try {
        const hosting = JSON.parse(fs.readFileSync(".openai/hosting.json", "utf8"));
        if (typeof hosting.project_id === "string" && hosting.project_id.trim() !== "") {
          console.log(hosting.project_id.trim());
          process.exit(0);
        }
        process.exit(1);
      } catch {
        process.exit(2);
      }
    ')"
    project_id_status=$?

    if [[ "$project_id_status" -eq 0 ]]; then
      echo "OK: Sites registration metadata has a nonempty project_id; confirm the hosted record with get_site"
      echo "INFO: Sidebar visibility requires list_sites or the Sites UI; never create a duplicate after get_site succeeds"
    elif [[ "$project_id_status" -eq 2 ]]; then
      echo "INVALID: .openai/hosting.json is not valid JSON"
      failures=$((failures + 1))
    elif [[ "$publishing_requested" -eq 1 ]]; then
      echo "MISSING: valid project_id in .openai/hosting.json; register the Site before publishing"
      failures=$((failures + 1))
    else
      echo "INFO: local Sites project is not registered; project_id is required only for publishing"
    fi
  fi
fi

if [[ -f .env.local ]] && rg -q '^NEXT_PUBLIC_CONVEX_URL=.+$' .env.local; then
  echo "OK: NEXT_PUBLIC_CONVEX_URL"
else
  echo "MISSING: nonempty NEXT_PUBLIC_CONVEX_URL in .env.local"
  failures=$((failures + 1))
fi

if [[ -f package.json ]] && rg -q '"convex"[[:space:]]*:' package.json; then
  echo "OK: convex dependency"
else
  echo "MISSING: convex dependency"
  failures=$((failures + 1))
fi

eslint_config=""
for candidate in eslint.config.js eslint.config.mjs eslint.config.cjs eslint.config.ts .eslintrc .eslintrc.js .eslintrc.cjs .eslintrc.json; do
  if [[ -f "$candidate" ]]; then
    eslint_config="$candidate"
    break
  fi
done

if [[ -f package.json ]] && rg -q '"@convex-dev/eslint-plugin"[[:space:]]*:' package.json; then
  if [[ -n "$eslint_config" ]] && rg -q '(@convex-dev/eslint-plugin|plugin:@convex-dev/recommended|configs\.recommended)' "$eslint_config"; then
    echo "OK: official Convex ESLint plugin is installed and referenced by $eslint_config"
    echo "INFO: confirm the lint command covers the actual Convex source directory"
  elif [[ -n "$eslint_config" ]]; then
    echo "WARNING: @convex-dev/eslint-plugin is installed but $eslint_config does not reference its recommended rules"
  else
    echo "WARNING: @convex-dev/eslint-plugin is installed but no supported ESLint configuration file was found"
  fi
elif [[ -n "$eslint_config" ]]; then
  echo "WARNING: $eslint_config exists without @convex-dev/eslint-plugin; follow https://docs.convex.dev/eslint"
else
  echo "INFO: ESLint is not configured; add the official Convex plugin for new projects or when adopting lint"
fi

if [[ -f package.json ]] && rg -q '@convex-dev/(self-)?static-hosting' package.json; then
  echo "FAILED: Convex static hosting is excluded; ChatGPT Sites owns the frontend"
  failures=$((failures + 1))
else
  echo "OK: frontend hosting remains assigned to ChatGPT Sites"
fi

if [[ -f convex/_generated/api.d.ts || -f convex/_generated/api.js ]]; then
  echo "OK: generated Convex API"
else
  echo "MISSING: generated Convex API; run npx convex codegen"
  failures=$((failures + 1))
fi

if rg -n --hidden --glob '!node_modules/**' --glob '!.git/**' --glob '!skills/**' --glob '!.codex/**' '(CONVEX_DEPLOY_KEY|CONVEX_ADMIN_KEY)[[:space:]]*=' .; then
  echo "WARNING: possible privileged Convex credential found; inspect before publishing"
else
  echo "OK: no obvious privileged Convex credential assignment in project files"
fi

if (( failures > 0 )); then
  echo "FAILED: $failures structural check(s) need attention"
  exit 1
fi

if [[ "$publishing_requested" -eq 1 ]]; then
  echo "PASSED: structural and publishing-registration checks"
else
  echo "PASSED: structural checks"
fi
