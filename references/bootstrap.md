# Bootstrap paths

## Where commands run

Open the app folder in Codex and start a task there. Paste the skill prompt into the task; Codex can run the setup commands in its integrated terminal. A user does not need to copy each command manually. If manual execution is requested, open the integrated terminal at the project root, the folder containing `package.json`, and run one command at a time. Explain approval requests before asking a new user to accept them.

Codex guide: https://learn.chatgpt.com/docs/integrated-terminal

Before either bootstrap path, read [local-runtime-and-server.md](local-runtime-and-server.md) and run `scripts/check-runtime.sh` from the target project root. Do not run `npm install`, `npx`, or a project script until Node.js 22.13.0 or newer is selected. Node.js 24 LTS is recommended. Repeating `npm install` cannot repair an older Node executable selected by the shell.

## New empty workspace

1. Run the runtime gate and initialize the Sites starter with the installed Sites workflow.
2. Pin Node 24 in `.nvmrc` and `.node-version`, require `>=22.13.0` in `package.json`, copy the project-owned Node check, and wire it through `predev`, `prebuild`, and `prestart` without replacing existing scripts.
3. Set or merge Vite `server.strictPort: true`, but preserve an existing project's deliberate port configuration.
4. Do not start the Sites server yet.
5. Install `convex` in the same package using the established package manager.
6. Have Codex run the matching `convex dev --once` command in its terminal to provision an accountless local backend.
7. Run the matching `convex ai-files status` command, then install only when the managed files are missing or stale.
8. Verify `.env.local` contains a nonempty `NEXT_PUBLIC_CONVEX_URL` and generated API types exist.
9. Add a guarded `ConvexProvider` that renders a helpful setup state instead of throwing when the URL is absent.
10. Start exactly one Sites server after backend readiness passes, then prove its exact printed URL and expected port with `scripts/check-local-url.sh`.
11. Keep the Convex watcher and Sites server running for the interactive preview.
12. Build the vertical connection test before product features.

If Sites was already running when Convex created or changed `.env.local`, stop it and restart exactly once. Do not accept a fallback port.

For local-only handoff, do not stop a healthy server merely because validation finished. Localhost disappears when that process exits. If Codex cannot preserve the process, tell the user exactly which command must remain running.

## Existing Sites project

Preserve `.openai/hosting.json`, the package manager, lockfile, Vite/vinext structure, worker entrypoint, dependencies, existing scripts, and unrelated changes. Run the runtime gate before installing anything. Preserve compatible existing runtime pins and prepend the project-owned runtime guard to existing pre-scripts instead of replacing them. Add only the Convex dependency, `convex/`, generated client types, provider, requested runtime hardening, and product code.

Do not treat the manifest alone as a registered Site. A valid nonempty `project_id` means the local folder has registration metadata; confirm that registration with `get_site`. When publication is requested, register the Site exactly once after the local build passes and before Convex production setup can pause the workflow.

## Existing Convex project

Preserve `convex/`, the deployment configuration, schema, generated types, and auth. Add the Sites frontend in the existing project root only when it does not conflict with the current package structure. If it would overwrite an existing application, stop and explain the collision.

## Convex Codex support

Use https://www.convex.dev/agent-setup.md as the current setup source.

### Install one global integration

Prefer the full Convex plugin for Codex. Inspect before changing it:

```bash
codex plugin marketplace list --json
codex plugin list --json
```

If the Convex marketplace is absent, add it. If present, upgrade it using its exact listed name. Then install or update the plugin:

```bash
codex plugin marketplace add get-convex/convex-codex-plugin
codex plugin add convex@convex-codex-plugin
```

Verify with both list commands and confirm the `convex` plugin comes from `convex-codex-plugin`. Restart Codex when it is not available in the current session. Do not install separate Convex skills or MCP when the full plugin succeeds.

Use standalone skills plus MCP only when the plugin path is unavailable. Preserve unrelated user configuration and do not enable production access.

### Install managed project guidance

Treat a folder as an existing Convex project only when its project-level `package.json` includes `convex` and the same root contains either `convex/` or `convex.json`. In a monorepo, stop when ownership is ambiguous.

Record existing changes, then inspect managed AI files:

```bash
git status --short
npx convex ai-files status
```

When status reports missing or stale files, run:

```bash
npx convex ai-files install
```

Let the CLI manage `AGENTS.md`, `CLAUDE.md`, `convex.json`, generated guidance, and project skills. Do not hand-edit managed sections. Verify afterward:

```bash
npx convex ai-files status
git status --short
git diff -- convex.json convex/_generated/ai AGENTS.md CLAUDE.md
```

Read `convex/_generated/ai/guidelines.md` completely before later Convex code work. During integration setup alone, do not initialize Convex, run a development server, log in, deploy, change application code or schema, modify environment variables, or access production data.

Source: https://docs.convex.dev/ai/using-codex

Agent mode: https://docs.convex.dev/cli/agent-mode
