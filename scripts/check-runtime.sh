#!/usr/bin/env bash
set -u

project_dir="${1:-.}"
minimum_major=22
minimum_minor=13

if [[ ! -d "$project_dir" ]]; then
  echo "ERROR: project directory does not exist: $project_dir"
  exit 2
fi

if ! command -v node >/dev/null 2>&1; then
  echo "RUNTIME NOT READY: Node.js is not available in this shell."
  echo "Install or select Node.js 24 before npm install or any project Node command."
  echo "Homebrew: brew install node@24"
  echo "nvm: nvm install 24 && nvm use 24 && nvm alias default 24"
  exit 1
fi

node_path="$(command -v node)"
node_link="$(readlink "$node_path" 2>/dev/null || true)"
node_version="$("$node_path" --version 2>/dev/null || true)"
version_without_v="${node_version#v}"
IFS='.' read -r node_major node_minor node_patch <<<"$version_without_v"
node_major="${node_major:-0}"
node_minor="${node_minor:-0}"
node_patch="${node_patch%%[^0-9]*}"
node_patch="${node_patch:-0}"

echo "NODE EXECUTABLE: $node_path"
[[ -n "$node_link" ]] && echo "NODE SYMLINK TARGET: $node_link"
echo "NODE VERSION: $node_version"

supported=0
if [[ "$node_major" =~ ^[0-9]+$ && "$node_minor" =~ ^[0-9]+$ ]]; then
  if (( node_major > minimum_major || (node_major == minimum_major && node_minor >= minimum_minor) )); then
    supported=1
  fi
fi

report_stale_shell_paths() {
  local stale_pin_found=0
  local shell_file
  local matches
  local -a shell_files=()

  if [[ "$node_path $node_link" =~ node@(18|20|21)|Cellar/node@(18|20|21)|/v(18|20|21)(\.|/) ]]; then
    echo "STALE SELECTED PATH: the current Node executable resolves to an unsupported Node release."
    stale_pin_found=1
  fi

  [[ -n "${HOME:-}" ]] && shell_files+=("$HOME/.zshrc" "$HOME/.zprofile" "$HOME/.bashrc" "$HOME/.bash_profile")
  [[ -n "${ZDOTDIR:-}" ]] && shell_files+=("$ZDOTDIR/.zshrc" "$ZDOTDIR/.zprofile")

  for shell_file in "${shell_files[@]}"; do
    [[ -f "$shell_file" ]] || continue
    if command -v rg >/dev/null 2>&1; then
      matches="$(rg -n -o '(node@(18|20|21)|nvm[[:space:]]+use[[:space:]]+(18|20|21)|NODE_VERSION[=:][[:space:]]*(18|20|21))' "$shell_file" 2>/dev/null || true)"
    else
      matches="$(grep -Eno '(node@(18|20|21)|nvm[[:space:]]+use[[:space:]]+(18|20|21)|NODE_VERSION[=:][[:space:]]*(18|20|21))' "$shell_file" 2>/dev/null || true)"
    fi
    if [[ -n "$matches" ]]; then
      echo "STALE SHELL PIN: $shell_file"
      printf '%s\n' "$matches"
      stale_pin_found=1
    fi
  done

  if [[ "$stale_pin_found" -eq 0 ]]; then
    echo "SHELL NOTE: no common Node 18/20/21 pin was found; inspect 'which -a node' and the active version manager."
  fi
}

if [[ "$supported" -ne 1 ]]; then
  echo "RUNTIME NOT READY: the current Sites starter requires Node.js 22.13.0 or newer; Node.js 24 LTS is recommended."
  echo "IMPORTANT: npm install installs project packages. It cannot install or switch the Node.js runtime selected by this shell."
  report_stale_shell_paths
  echo "HOMEBREW FIX: brew install node@24"
  echo 'HOMEBREW PATH: export PATH="$(brew --prefix node@24)/bin:$PATH"'
  echo "NVM FIX: nvm install 24 && nvm use 24 && nvm alias default 24"
  echo "VERIFY IN A FRESH LOGIN SHELL: /bin/zsh -lic 'command -v node; node --version; command -v npm; npm --version'"
  exit 1
fi

package_manager="npm"
if [[ -f "$project_dir/bun.lock" || -f "$project_dir/bun.lockb" ]]; then
  package_manager="bun"
elif [[ -f "$project_dir/pnpm-lock.yaml" ]]; then
  package_manager="pnpm"
elif [[ -f "$project_dir/yarn.lock" ]]; then
  package_manager="yarn"
elif [[ -f "$project_dir/package-lock.json" ]]; then
  package_manager="npm"
elif [[ -f "$project_dir/package.json" ]]; then
  declared_manager="$("$node_path" -e '
    const fs = require("node:fs");
    try {
      const pkg = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
      process.stdout.write(String(pkg.packageManager ?? "").split("@")[0]);
    } catch {
      process.exit(1);
    }
  ' "$project_dir/package.json" 2>/dev/null || true)"
  case "$declared_manager" in
    bun|pnpm|yarn|npm) package_manager="$declared_manager" ;;
  esac
fi

required_commands=("$package_manager")
[[ "$package_manager" == "npm" ]] && required_commands+=(npx)
for command_name in "${required_commands[@]}"; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "RUNTIME NOT READY: the established $package_manager project needs $command_name, but it is missing."
    exit 1
  fi
  command_version="$("$command_name" --version 2>/dev/null)"
  if [[ "$?" -ne 0 || -z "$command_version" ]]; then
    echo "RUNTIME NOT READY: $command_name exists but cannot run with the selected Node.js executable."
    exit 1
  fi
  echo "$(printf '%s' "$command_name" | tr '[:lower:]' '[:upper:]') EXECUTABLE: $(command -v "$command_name")"
  echo "$(printf '%s' "$command_name" | tr '[:lower:]' '[:upper:]') VERSION: $command_version"
done
echo "PACKAGE MANAGER: $package_manager"

if (( node_major == 22 )); then
  echo "RUNTIME READY: Node.js $node_version meets the minimum; Node.js 24 LTS is recommended for Sites/Vinext."
else
  echo "RUNTIME READY: Node.js $node_version is supported."
fi

if [[ -f "$project_dir/.nvmrc" ]]; then
  echo "PROJECT PIN: .nvmrc=$(tr -d '[:space:]' < "$project_dir/.nvmrc")"
else
  echo "PROJECT PIN WARNING: .nvmrc is missing; new Sites projects should pin Node 24."
fi

if [[ -f "$project_dir/.node-version" ]]; then
  echo "PROJECT PIN: .node-version=$(tr -d '[:space:]' < "$project_dir/.node-version")"
else
  echo "PROJECT PIN WARNING: .node-version is missing; new Sites projects should pin Node 24."
fi

if [[ -f "$project_dir/package.json" ]]; then
  engine="$("$node_path" -e '
    const fs = require("node:fs");
    try {
      const pkg = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
      process.stdout.write(String(pkg.engines?.node ?? ""));
    } catch {
      process.exit(1);
    }
  ' "$project_dir/package.json" 2>/dev/null || true)"
  if [[ -n "$engine" ]]; then
    echo "PROJECT ENGINE: package.json requires node $engine"
  else
    echo "PROJECT PIN WARNING: package.json engines.node is missing."
  fi
fi
