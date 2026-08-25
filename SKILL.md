---
name: codex-sites-convex
description: Build, extend, validate, and publish a ChatGPT Sites application whose durable database and backend functions run on Convex. Use when a user invokes $codex-sites-convex, selects this skill from the skill picker, asks for a ChatGPT Site backed by Convex, or asks to add Convex data, realtime queries, mutations, authentication, files, schedules, or actions to an existing ChatGPT Sites project.
---

# ChatGPT Sites + Convex

Build the complete application, validate both halves, and publish it unless the user explicitly requests local-only work.

## Choose the workflow

- **Default: durable shared Site.** When the user asks to publish, deploy, share, ship, or provide a URL without explicitly requesting a temporary preview, use Convex Cloud production and complete the Sites lifecycle through a confirmed live `.chatgpt.site` URL.
- **Existing Site update.** When the user asks to update, republish, or publish the latest version, preserve the existing Sites `project_id`, current access policy, and canonical `current_live_url`. Reuse the confirmed production Convex URL. Deploy Convex again only when backend code, schema, components, schedules, actions, or backend environment requirements changed; obtain fresh production consent immediately before that deployment. Always rebuild, scan, save, deploy, poll, call `get_site`, and run live QA for the new Sites version.
- **Local-only development.** Use accountless Agent Mode only when the user explicitly wants localhost development without publishing. It creates no shareable URL.
- **Temporary preview.** Use an isolated, expiring Convex Cloud dev deployment only when the user explicitly requests a temporary preview. Label it non-production and report its expiration.

Do not stop a publication workflow after local validation, cloud linking, Site registration, an access change, or environment configuration. Continue through the saved Sites version, deployment, nonempty `get_site.current_live_url`, and live QA unless a real authorization or platform blocker prevents progress.

## Non-negotiable architecture

- Keep the frontend, frontend build, published URL, and sharing in ChatGPT Sites.
- Keep all durable application data and backend execution in Convex.
- Connect browser components through the public Convex React client and generated `api` types.
- Treat the Convex MCP server as a development tool, never as the visitor runtime.
- Never expose deploy keys, admin credentials, or third-party secrets to browser code.
- Do not add a second application database, mock persistence, or placeholder records.

## Load only the references needed

- Always read [references/architecture.md](references/architecture.md).
- Before dependency installation, Sites/Vinext startup, or localhost troubleshooting, read [references/local-runtime-and-server.md](references/local-runtime-and-server.md).
- Before selecting a Convex environment or explaining accounts, access, ownership, or authentication, read [references/accounts-access-and-ownership.md](references/accounts-access-and-ownership.md).
- Before publishing or changing a published Site, hosted environment variable, connected Convex deployment, or sharing setting, read [references/sites-settings-and-environment.md](references/sites-settings-and-environment.md).
- Before configuring the Convex plugin, MCP, skills, or managed AI files, read the current official [Convex agent setup guide](https://www.convex.dev/agent-setup.md) and [references/bootstrap.md](references/bootstrap.md).
- Before provisioning any development backend, read [references/agent-mode.md](references/agent-mode.md).
- Before editing `convex/`, read [references/convex-rules.md](references/convex-rules.md).
- Before selecting backend packages or implementing a capability, read [references/components.md](references/components.md).
- Before adding `convex-helpers` or changing ESLint configuration, read [references/helpers-and-eslint.md](references/helpers-and-eslint.md).
- Before completing the frontend, read [references/built-with-footer.md](references/built-with-footer.md).
- Before publishing, read [references/deployment-and-qa.md](references/deployment-and-qa.md).
- For authentication, file storage, scheduled jobs, search, migrations, or external APIs, use the official links routed by [references/convex-doc-map.md](references/convex-doc-map.md).

If the installed `sites:sites-building`, `sites:sites-hosting`, `convex:convex-expert`, or `convex:convex-reviewer` skills are available, read and follow the relevant skill before acting. This skill sets the cross-product architecture; those skills own their product-specific implementation details.

## Workflow

### 1. Inspect before changing anything

Run `scripts/check-runtime.sh` from the target project root before `npm install`, `npx`, a project script, or another Node-based project command. Its initial `node --version` probe must be the first executable runtime check. Require Node.js 22.13.0 or newer and recommend Node.js 24 LTS. If it fails, stop before npm or npx, explain that `npm install` cannot install or switch Node, and follow [references/local-runtime-and-server.md](references/local-runtime-and-server.md). After repairing the existing runtime selection within authorization, verify `command -v node`, `node --version`, `command -v npm`, and `npm --version` in a fresh login shell. Then run `scripts/preflight.sh` and inspect `AGENTS.md`, `.openai/hosting.json`, `package.json`, the lockfile, `app/`, `convex/`, and `.env.example` when present. Preserve the existing package manager, dependencies, scripts, lockfile, working structure, and unrelated uncommitted changes.

Report these Sites states separately; never use one as proof of another:

1. **Local Sites project:** the editable project files exist in the current folder. A hosting manifest may exist without a registration.
2. **Registered Site:** `.openai/hosting.json` contains a valid nonempty `project_id`, and `get_site` confirms the hosted record. Sidebar visibility is checked separately and may lag.
3. **Saved Sites version:** the current build was uploaded and saved as a version. Registration alone does not create or deploy a version.
4. **Published Site:** a saved version deployed successfully and `get_site.current_live_url` is nonempty. A deployment URL or successful save alone is not sufficient.

For a new Codex user, explain that they paste the `$codex-sites-convex` prompt into a Codex task opened on their app folder. Treat the task box as an instruction composer, not direct shell input. When command tools are available, run routine setup, validation, and build commands directly instead of making the user copy them. If the user prefers manual execution, tell them to select the terminal icon in the upper right corner or press `Ctrl` plus the backtick key, confirm it is using the same project root, show commands in order, and distinguish commands that exit from development servers that must remain running. If the current surface cannot access project files or run commands, direct the user to the Codex desktop app, Codex CLI, or another command capable Codex environment. Ask the user only for required approval, authentication, account or project selection, secure secret entry, a user interface action, or a real platform blocker. Do not assume they know what “project root,” “terminal,” or a command approval means.

Classify `CONVEX_DEPLOYMENT`, the presence and scope of `CONVEX_DEPLOY_KEY`, saved Convex CLI user configuration, and the public Convex URL without printing credentials or configuration contents. No login prompt does not prove accountless mode; saved CLI credentials may already be active.

Classify the task:

- **Empty/projectless directory:** initialize ChatGPT Sites first, then add Convex to that same project.
- **Existing local Sites project:** preserve its structure, report whether it is registered, and add or extend Convex.
- **Existing Convex project without Sites:** preserve `convex/` and initialize the ChatGPT Sites frontend around it; do not scaffold another product app.
- **Both already present:** make only the requested product changes.

Confirm an existing Convex project only when the same project root has both a `convex` dependency in `package.json` and either `convex/` or `convex.json`. In a monorepo, use the nearest unambiguous matching root. Do not install managed Convex AI files when project ownership is missing or ambiguous.

### 2. Prepare or preserve the Sites frontend

For a new project, use the installed Sites building workflow to initialize the local project files, but do not start or open the Sites server yet. This cross-product ordering overrides the usual Sites-only preview order: provision Convex and pass the backend-readiness gate first. Create `.nvmrc` and `.node-version` with `24`, set `package.json#engines.node` to `>=22.13.0`, copy `assets/check-node-version.mjs` to the app as `scripts/check-node-version.mjs`, and add `predev`, `prebuild`, and `prestart` scripts that run the check. Merge with existing scripts and preserve any stricter compatible starter requirement. Set or merge Vite `server.strictPort: true` so the new project fails on an occupied expected port. Treat `.openai/hosting.json` as a local hosting manifest, not proof of registration; only a valid nonempty `project_id` identifies a registered Site. Do not replace the project's vinext/Vite/Cloudflare Worker structure.

For an existing project, install dependencies only when absent. Preserve compatible runtime pins, pre-scripts, its package manager, and its deliberate port configuration. Do not create a second lockfile or replace existing pre-scripts when adding a runtime check. Inspect the actual starter before choosing its public environment-variable convention.

### 3. Add Convex to the same project

Use the current Convex workflow rather than hand-writing setup. Prefer the callable Convex start/runbook tools when available. Otherwise:

```bash
npm install convex
npx convex dev
npx convex ai-files status
```

These commands show the new npm-project path. For an existing pnpm, Yarn, or Bun project, use that package manager's install and executable commands; never create `package-lock.json` beside another lockfile.

For a confirmed Convex project, run `npx convex ai-files install` only when status reports missing or stale files. Let the CLI manage `AGENTS.md`, `CLAUDE.md`, `convex.json`, generated guidance, and project skills; never reproduce or edit managed sections by hand. Read `convex/_generated/ai/guidelines.md` completely before editing `convex/` when it exists.

For accountless local agent development, use the supported non-interactive flow:

```bash
npm install
npx convex dev --once
```

Do not require login and do not set the legacy `CONVEX_AGENT_MODE=anonymous` flag. In a non-interactive shell with no configured deployment or deploy key, Convex automatically provisions a local backend.

Accountless Agent Mode is local-only. It may write the local frontend URL to `.env.local`, but it does not create a hosted Sites environment variable and cannot power a published Site. Linking the folder to Convex Cloud provides managed development and production deployments; it does not by itself publish Sites.

After provisioning, run `scripts/check-backend-ready.sh`. Do not start the Sites server or open a browser until `.env.local` contains a nonempty `NEXT_PUBLIC_CONVEX_URL` and the generated Convex API exists.

For an interactive preview, keep `npx convex dev` running alongside Sites after the initial provisioning succeeds. Do not overwrite existing environment files. Keep `.env.local` ignored and `.env.example` limited to public names without values.

Treat Convex development and production as separate targets:

- **Development:** use `npx convex dev --once` to provision/push once, then keep `npx convex dev` running for an interactive preview. The frontend uses the development URL written to `.env.local`.
- **Temporary shared preview:** only when explicitly requested, select or create an isolated, expiring Convex Cloud dev deployment with a deployment-scoped key, push with `npx convex dev --once`, and publish Sites against its public URL. Label it non-production and report its expiration.
- **Production:** after development validation, use `npx convex deploy`. Capture the production deployment URL and rebuild Sites with that URL; never publish a bundle connected to the development deployment.

### 4. Complete the official capability check

Before implementing any product capability:

1. Fetch the current official component catalog from `https://www.convex.dev/components/get-convex.md`.
2. Fetch or search the current Convex documentation index at `https://docs.convex.dev/llms.txt`.
3. Match the requested capability against both sources.
4. If an official component clearly fits, fetch and read that component's linked `SKILL.md` completely before writing code.
5. Inspect the current project for an already-installed solution before adding a package.
6. Use the component only when it materially reduces custom infrastructure; otherwise use the documented built-in Convex primitive.
7. If no Component is selected and the capability needs a common code-level utility, check the current `convex-helpers` repository and package documentation. Install it only for a named matched utility; it is not a Component or default dependency.
8. Record the selected Component or helper, or the reason neither was selected, in the task update.

Never select or install a Convex static-hosting component. ChatGPT Sites owns the frontend build, published URL, and sharing.

Use `scripts/check-components.sh <keywords>` for a quick catalog search. Treat its output as discovery only; read the matched component skill and official documentation before implementation.

### 5. Configure development assistance

Follow https://www.convex.dev/agent-setup.md. Prefer the full official Convex plugin for Codex because it includes skills and MCP. Inspect and verify the marketplace and installed plugin before changing anything. When the plugin succeeds, do not install separate Convex skills or add a duplicate MCP server.

Run applicable setup commands directly. Ask the user only when approval, authentication, a user-interface action, or a restart is required. Preserve unrelated settings and repository changes.

When the full plugin is unavailable, use the fallback integration. Add this entry to `~/.codex/config.toml` without replacing unrelated configuration, then restart Codex:

```toml
[mcp_servers.convex]
command = "npx"
args = ["-y", "convex@latest", "mcp", "start"]
```

Verify the selected integration with plugin listing, AI-file status, and MCP health where available; install success alone is insufficient. Report setup as partial with the exact remaining action when verification fails or a restart is pending. Continue implementing without MCP when normal CLI access is sufficient. Do not enable broad production access by default.

### 6. Start exactly one Sites server

Start Sites only after the backend-readiness gate passes. Resolve the expected port from the existing dev command or configuration; the stock Vinext starter expects `3000`. Inspect retained sessions and only that intended port:

- Reuse a healthy Sites server for this project when one already exists.
- Stop duplicate Sites servers started by this task before continuing.
- Never accept a fallback port as success; it usually means another server is still running.
- Never stop an unrelated user process. If ownership is unclear, report the port conflict and ask.
- Start the existing project dev command once in a retained session. If it announces a fallback port, stop only that task-owned process, resolve the expected-port conflict, and restart once on the expected port.

If Sites was started before Convex wrote `.env.local`, stop it and restart it exactly once after `NEXT_PUBLIC_CONVEX_URL` exists. Environment variables are captured when the client bundle starts; a running server will not reliably pick up a newly created public URL.

When `.env.local`, dependencies, and hosting configuration change together, allow those changes to settle and perform one clean restart. Treat JSON parse errors, overlapping Vite restarts, fallback ports, multiple-renderer warnings, and worker errors appearing in that window as one cascading server-state failure until the clean restart proves otherwise.

Capture the exact Local URL printed by the healthy server. Allow up to 60 seconds for the first worker compilation, then run `scripts/check-local-url.sh EXACT_LOCAL_URL EXPECTED_PORT`. Do not substitute a guessed URL or accept a successful response from another port. For local-only work, keep one healthy Sites server and one interactive Convex server running through handoff unless the user asks to stop them. If the execution surface cannot preserve long-running processes, state that limitation and give the exact command the user must keep running. Explain that localhost works only on that computer and only while the development server remains alive. Never describe localhost as published or shareable.

### 7. Prove the deployed connection early

Before building a large data-driven product, create the smallest vertical slice:

1. One validated table.
2. One query returning a small bounded result.
3. One idempotent mutation.
4. One Sites component wrapped by `ConvexProvider`.
5. One UI control that writes and visibly receives the reactive update.

Validate locally, then publish this slice when publishing is authorized. Confirm the published origin can make HTTPS and WebSocket connections to Convex. If Content Security Policy, CORS, WebSocket, or mixed-content restrictions block it, stop and report the exact evidence. Do not disguise the failure with local-only success.

### 8. Build the requested product

Propose schema changes before implementing them. Then build the smallest coherent product:

- Use `schema.ts`, validators, and explicit indexes.
- Use generated `api.module.functionName` references.
- Use `useQuery` for reactive reads and `useMutation` for writes.
- Include loading, empty, error, success, and disabled states.
- Put secret-dependent or third-party calls in Convex actions.
- Add authentication only when required; enforce authorization in every protected Convex function.
- Use Convex file storage, schedules, search, or an approved official component only when the requested feature needs it.
- Keep UI data real and backed by Convex; do not ship placeholders.
- Never throw during React render when `NEXT_PUBLIC_CONVEX_URL` is missing. Render a clear configuration/setup state and construct `ConvexReactClient` only after a valid URL exists.
- Keep developer account and deployment setup out of normal visitor UI. If a public Site lacks product authentication and per-user authorization, warn that visitors share Convex data before requesting authorization to publish publicly.

Add the removable “Built with ChatGPT Sites + Convex” footer from [references/built-with-footer.md](references/built-with-footer.md) unless the user explicitly asks to omit or remove it. Use the bundled light and dark logo assets, follow the Site's resolved theme, use the Phosphor GitHub logo for the repository link, link each brand to its official site, and preserve the removal comment in source code.

### 9. Validate in proportion to risk

Run the project scripts that exist, plus the applicable checks:

```bash
npx convex dev --once
npx convex codegen
npm run build
```

Run lint and a separate type check when defined. Use `scripts/verify-project.sh` for local structural checks, or `scripts/verify-project.sh --publish` when publication was requested. Review changed Convex functions for validators, authentication, public/internal visibility, indexes, pagination, bounded reads, and mutation conflicts.

Run `scripts/check-runtime.sh` again before final Node-based checks. For local preview work, verify the exact expected URL returns HTTP success while the server remains running. When the shell runtime changed, perform the final runtime verification in a new login shell so the fix survives the next terminal session.

For a new project, configure the official `@convex-dev/eslint-plugin` recommended rules and ensure lint checks the actual Convex directory. For an existing project, preserve its ESLint format and extend a compatible configuration; do not replace unrelated rules or silently migrate configuration formats. If the existing project has no ESLint setup, recommend the plugin and report lint as not configured rather than failing solely for its absence. Follow [references/helpers-and-eslint.md](references/helpers-and-eslint.md) and the current official ESLint documentation.

Fix failures and rerun the failing check. Do not declare completion from a local UI preview alone.

### 10. Register the Site early when publication is requested

After the local production build passes, inspect `.openai/hosting.json`. If publication was requested and no valid `project_id` exists, call `create_site` exactly once through the Sites hosting workflow and persist the returned `project_id`. Call `get_site` to confirm the registration before starting or resuming Convex production setup. Check `list_sites` or the Sites UI separately for sidebar visibility.

This checkpoint registers the Site only. Do not claim that a Sites version was saved or that the Site was published. If `get_site` succeeds but the Site is not listed yet, preserve the existing `project_id`, do not call `create_site` again, report `Registered Site; sidebar indexing pending`, and ask the user to refresh or reopen Sites. Report `Registered Site` as the last completed lifecycle state and name the next required Convex action.

If a hydration warning mentions attributes injected by Grammarly or another browser extension, verify once in a clean Chrome profile or with extensions disabled. Do not change application code when the warning disappears and the server-rendered markup otherwise matches.

### 11. Publish and hand off

Read and follow [references/deployment-and-qa.md](references/deployment-and-qa.md) completely.

Deployment order: Convex backend → production Convex URL → Sites production build → Sites publish → URL and access verification.

The complete durable-publication lifecycle is:

1. Build and validate locally, including a Convex query, mutation, and realtime update.
2. Register the Site once or reuse its valid `project_id`, then call `get_site`.
3. Inspect `access_level`, `latest_version_number`, `current_live_url`, Sites environment-variable names, and the frontend's current Convex URL without displaying credentials.
4. Explain whether visitors share Convex data. If public access is requested and the Site is not public, obtain explicit authorization before changing access. If it is already public, preserve that policy and do not request the same access change again.
5. Link or select the intended Convex Cloud project. Announce the exact production team, project, deployment, and known public URL, plus what the deployment will change.
6. Immediately before `npx convex deploy`, obtain fresh, target-specific production authorization even when Sites access is already public.
7. Deploy Convex production and capture the exact production `convex.cloud` URL.
8. Only after that URL is known, set Sites `NEXT_PUBLIC_CONVEX_URL` as non-secret public configuration. Never put a deploy key, admin key, or backend secret in Sites public environment variables.
9. Rebuild the frontend with the production URL. Run `scripts/check-production-bundle.sh BUILD_DIR PRODUCTION_URL DEVELOPMENT_URL`; fail if the bundle contains localhost, the development URL, a deployment key marker, or lacks the exact production URL.
10. Commit the exact validated source, push that commit, package the selected commit, and call `save_site_version` once for that build.
11. Deploy the saved version and poll `get_deployment_status` until success or failure.
12. On success require a non-null deployment `url`, call `get_site`, and require `current_live_url` to be nonempty and match the deployment URL.
13. Open the canonical live URL and verify HTTPS plus Convex read, write, and realtime behavior through the published Site.
14. Return the copyable clickable Sites URL as the first item in the final answer.

For an existing frontend-only update, do not redeploy an unchanged Convex backend. Confirm the current production deployment and exact URL, then continue with the clean production build, bundle scan, exact source commit, Sites version save, deployment, canonical URL check, and live QA. If any Convex backend behavior or configuration changed, use the full production deployment and fresh-consent steps above.

Before publishing, resolve whether the Site should be public or require sign-in. Default to private when the user has not requested public access. Explain the resolved access mode and obtain explicit authorization before changing to public or changing any access list. Public access is an access policy, not a deployment, and never proves that the Site is published.

An accountless local backend cannot power a published Site. Before production deployment, confirm the intended Convex team, project, production deployment, and authorized account or production-scoped key. Obtain fresh consent immediately before every production deployment. Reject any production bundle containing localhost, `127.0.0.1`, a local URL, an unintended development deployment, or a deployment credential.

Treat this recovery state as **registered and public but unpublished**: valid `project_id`, `access_level: public`, `latest_version_number: 0`, `current_live_url: null`, no Sites environment variables, and a frontend still targeting accountless local Convex. Preserve public access, but complete cloud linking, fresh production authorization, production deployment, Sites public configuration, clean rebuild and scan, exact-commit save and deploy, live URL confirmation, and production QA. Use `scripts/check-publication-state.sh` with a normalized state file when diagnosing this case.

For an explicitly requested temporary shared preview, follow the Cloud Agent Mode path in [references/agent-mode.md](references/agent-mode.md) and [references/deployment-and-qa.md](references/deployment-and-qa.md). Confirm the team and project; reuse only a suitable isolated cloud dev deployment or create one with an explicit expiration; use only deployment-scoped access; configure its environment; push with `npx convex dev --once`; and build Sites with its public `convex.cloud` URL. Confirm Sites access before publishing. Never expose the deploy key, call the backend production, or imply that preview data automatically transfers to production.

Call `save_site_version` once for the production build, then deploy that saved version. Poll the Sites deployment to success or failure and retain its exact returned `url`, but report the Site as published only after `get_site.current_live_url` is nonempty and matches that URL. Open the confirmed live URL in Codex and make its clickable link the first item in the final answer. For an existing Site, read `project_id` from `.openai/hosting.json`, call `get_site`, and treat `current_live_url` as canonical; never reconstruct a URL from a slug.

If work stops at any point, report the last completed state using the four state names above and the single next required action. Never upgrade the wording from local, registered, or saved to published without a confirmed `get_site.current_live_url`.

Every published handoff must explain how to reopen the Site in ChatGPT Sites and manage it through Settings. Hosted Site management is not available through a standalone Codex CLI or IDE screen.

Every successful first-publication and update handoff must include this exact instruction:

> For future updates, ask Codex: `$codex-sites-convex Build, validate, and publish the latest version to ChatGPT Sites.`

Every temporary-preview handoff must begin with the live Sites URL and label `Temporary shared preview`. Report the exact Convex deployment expiration, Sites access mode, visitor sign-in requirements, whether data is shared or isolated, what fails after expiration, and the steps required to promote to production.

Do not enable production MCP writes, generate a sign-in bypass token, make a Site public, or add users or groups unless the user explicitly authorizes that action.

## Completion contract

Finish only when:

- the requested workflow uses Convex-backed data end to end;
- the selected Node.js executable is 22.13.0 or newer, new projects pin Node 24 and guard `dev`, `build`, and `start`, and any runtime repair survives a fresh login shell;
- the selected agent mode matches the environment and account requirements;
- backend readiness passed before the Sites server or browser started;
- the official component catalog and current Convex documentation were checked before capability implementation;
- any `convex-helpers` utility was selected for a named need rather than installed speculatively;
- the official Convex ESLint rules pass when configured, or the handoff clearly reports that an existing project has no lint setup;
- backend generation/checks and the frontend build pass;
- local-only handoff proves the exact expected localhost URL responds, rejects fallback ports, and leaves the required Sites and Convex development processes running, or states why the execution surface cannot preserve them;
- no browser bundle contains a secret;
- the removable built-with footer is present unless the user explicitly opted out;
- the footer remains legible in the Site's explicit light and dark modes;
- the published connection was tested when publishing was requested;
- the handoff states Sites access, visitor sign-in, Convex backend ownership, Convex deployment type, shared versus per-user data, and future developer requirements without exposing credentials;
- a temporary shared preview is labeled non-production and reports its exact backend expiration, failure behavior, data-sharing model, and production-promotion steps;
- the final response starts with the published Sites URL and includes the required access and future-update handoff, or clearly states the exact remaining blocker;
- the future-update handoff includes the literal `$codex-sites-convex` invocation so a new user reliably activates this skill;
- every incomplete handoff names the last completed Sites state and the next required action.
