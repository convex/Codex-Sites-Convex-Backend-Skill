# Runtime and localhost hardening

Created: 2026-08-09T07:08:37Z

## Problem

The skill checked that `node`, `npm`, and `npx` existed but did not prove that the selected Node executable could run the Sites/Vinext toolchain. A stale shell could complete `npm install` under Node 20 and fail later during `npm run dev`. A localhost URL could also be handed off after its server stopped or after Vite moved to a fallback port.

## Confirmed constraints

- The installed official Sites starter declares `package.json#engines.node` as `>=22.13.0`.
- Node.js 24 is an LTS release, while Node.js 20 is end-of-life as of this update.
- `npm install` installs project packages but cannot change the terminal's selected Node executable.
- The stock Vinext development server expects port `3000`; existing projects may intentionally configure another port.

## Required workflow

1. Run a runtime-only gate before package installation or project Node commands.
2. Stop before npm or npx when Node is older than 22.13.0.
3. For a new project, pin Node 24 and add project-owned pre-command checks.
4. Preserve existing project structure, scripts, package manager, dependencies, lockfile, and unrelated changes.
5. Provision Convex and pass backend readiness before Sites starts.
6. Resolve one expected Sites port, inspect only that port, and run one frontend server.
7. Reject fallback ports and verify the exact printed localhost URL with an HTTP GET.
8. Keep the frontend and Convex processes alive for local-only handoff and explain that localhost ends with the server process.

## Files

- `assets/check-node-version.mjs`
- `scripts/check-runtime.sh`
- `scripts/check-local-url.sh`
- `scripts/preflight.sh`
- `scripts/verify-project.sh`
- `tests/test-node-runtime.sh`
- `tests/test-node-version.mjs`
- `tests/test-local-url.sh`
- `references/local-runtime-and-server.md`
- `references/bootstrap.md`
- `references/agent-mode.md`
- `SKILL.md`
- `README.md`
- `task.md`
- `changelog.md`
- `files.md`

## Acceptance checks

- Node 24 and Node 22.13 pass the runtime gate.
- Node 20 and Node 22.12 fail before npm executes.
- An existing pnpm project keeps pnpm and does not invoke npm.
- The project-owned version helper accepts and rejects the same boundaries.
- An exact expected localhost URL reaches the HTTP check; a fallback port fails before curl runs.
- Every shell script passes `bash -n`.
- The runtime regression suite, existing publication-state regression, official skill validator, and `git diff --check` pass.

## Decision log

- Keep Node.js 22.13.0 as the hard minimum because it matches the current official Sites starter.
- Pin new projects to Node.js 24 because it is LTS and supported by the starter.
- Add both project declarations and executable guards: declarations communicate the requirement, while guards stop stale terminals clearly.
- Set `server.strictPort: true` for new projects and preserve deliberate existing port configuration.
