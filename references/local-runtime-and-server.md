# Local runtime and server

Use this runbook before installing dependencies, starting Sites/Vinext, or diagnosing localhost.

## Runtime order

1. The shell selects the `node` executable through `PATH`, Homebrew, nvm, fnm, Volta, or another version manager.
2. The project declares its supported runtime in `.nvmrc`, `.node-version`, and `package.json#engines.node`.
3. The package manager installs project dependencies.

`npm install` changes `node_modules`; it cannot install or switch the Node.js executable selected by the current terminal.

The current official Sites starter requires Node.js 22.13.0 or newer. Use Node.js 24 LTS for new projects. Before `npm install`, `npx`, a project script, or another Node-based project command, run the skill gate from the target project root:

```bash
~/.codex/skills/codex-sites-convex/scripts/check-runtime.sh .
```

For a project-local skill installation, run:

```bash
./.agents/skills/codex-sites-convex/scripts/check-runtime.sh .
```

The gate's first and only executable check before accepting the runtime is `node --version`. It exits before invoking npm or npx when Node is unsupported.

## Fix a stale terminal

First inspect the selection:

```bash
which -a node
node --version
```

For Homebrew on Apple silicon:

```bash
brew install node@24
export PATH="$(brew --prefix node@24)/bin:$PATH"
```

Replace an older explicit `node@20` path in the active shell startup file instead of stacking conflicting entries. Edit a startup file only with the user's approval.

For nvm:

```bash
nvm install 24
nvm use 24
nvm alias default 24
```

Do not install a second version manager when the machine already has a working one. After changing runtime selection, verify that it survives a new login shell:

```bash
/bin/zsh -lic 'command -v node; node --version; command -v npm; npm --version'
```

Only after this reports Node 22.13.0 or newer should dependency installation run.

## New-project runtime files

Create these files for every new Sites project:

```text
.nvmrc: 24
.node-version: 24
package.json engines.node: >=22.13.0
```

Copy `assets/check-node-version.mjs` from this skill to the app as `scripts/check-node-version.mjs`. Add `predev`, `prebuild`, and `prestart` scripts that run it. If one of those scripts already exists, prepend the check and retain the existing command. Preserve a stricter compatible engine requirement.

Example shape for a new npm project:

```json
{
  "engines": {
    "node": ">=22.13.0"
  },
  "scripts": {
    "check:node": "node scripts/check-node-version.mjs",
    "predev": "npm run check:node",
    "prebuild": "npm run check:node",
    "prestart": "npm run check:node"
  }
}
```

Merge these keys into the existing `package.json`; do not replace other scripts, dependencies, metadata, or the lockfile. For an existing pnpm, Yarn, or Bun project, keep its package manager and command style. Do not create a second lockfile.

## Start one Sites server

Provision Convex and pass `scripts/check-backend-ready.sh` before starting Sites. Then:

1. Resolve the expected port from the existing dev script or configuration. The stock Vinext starter expects port `3000`.
2. Inspect only that port with `lsof -nP -iTCP:PORT -sTCP:LISTEN`; do not scan other ports.
3. Reuse one healthy server owned by the same project. Stop only a duplicate started by the current task. Never stop an unrelated process when ownership is unclear.
4. For a new project, set or merge Vite `server.strictPort: true` so a port conflict fails instead of selecting a fallback. Preserve an existing project's deliberate port and configuration.
5. Start the project's existing dev command once in a retained terminal or managed session.
6. If the output announces a fallback port, stop that task-owned server, resolve the expected-port conflict, and restart once. Never hand off the fallback URL.
7. Wait up to 60 seconds for the first worker compilation and capture the exact Local URL printed by the server.
8. Verify that exact URL and expected port:

```bash
~/.codex/skills/codex-sites-convex/scripts/check-local-url.sh http://localhost:3000/ 3000
```

Use the actual printed URL and resolved port in place of the example. The script sends an HTTP GET and fails if the URL uses a different port.

For local-only work, leave one interactive `npx convex dev` process and the healthy Sites process running through handoff unless the user asks to stop them. If the execution surface cannot retain processes, say so and give the exact command the user must keep running.

Localhost is available only on that computer and only while the development server remains running. A successful build does not keep the local URL alive and does not create a shareable Site.
