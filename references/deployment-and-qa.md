# Deployment and QA

Lifecycle order: local Sites project → registered Site → Convex production backend → production Convex URL → Sites production build → saved Sites version → Sites deployment → live URL and access verification.

Apply the account matrix, credential-detection rules, public-data warning, and accountless-to-production handoff in [accounts-access-and-ownership.md](accounts-access-and-ownership.md).

Apply the hosted management, environment-layer, and update rules in [sites-settings-and-environment.md](sites-settings-and-environment.md).

## Contents

- Copy-paste local, temporary-preview, and production prompts
- Convex local, cloud preview, and production deployments
- Sites lifecycle and early registration
- Sites publishing and access choice
- New and existing Site deployment
- Access changes and private login
- Production QA and response templates

## Before deployment

- Confirm no unrelated user changes will be overwritten.
- Run `scripts/check-runtime.sh` before package installation, npx, or project scripts. Require Node.js 22.13.0 or newer and recommend Node.js 24 LTS.
- Run Convex code generation and backend validation.
- Run the frontend production build, lint, and type check when defined.
- Confirm the browser uses only a public Convex deployment URL.
- Confirm `.env.local` contains a nonempty `NEXT_PUBLIC_CONVEX_URL` before starting Sites.
- Confirm third-party secrets exist only in Convex environment variables.

## Copy-paste prompts

Use the first prompt by default for any request to publish, deploy, share, ship, or return a live URL. Use the second only for localhost development with no shareable URL. Use the third only for an explicitly temporary, expiring shared preview.

Open the app folder in Codex, start a task, and paste one complete prompt into the task. Codex runs the commands in its integrated terminal. Users who want to run commands themselves should open the terminal at the project root, the folder containing `package.json`. See https://learn.chatgpt.com/docs/integrated-terminal.

### Default: Build and publish a durable shared Site

```text
$codex-sites-convex Build, validate, and publish this app as a durable shared
ChatGPT Site backed by Convex production.

Build and validate locally first, including a Convex query, mutation, and
realtime update. Register or reuse the ChatGPT Site, inspect its current access
and publication state, and explain whether visitors share data. Get explicit
authorization before changing access to public; preserve an already-public
policy without asking for the same change again.

Link or select the correct Convex Cloud project. Announce the exact production
team, project, deployment, URL, and expected changes. Get my fresh target-specific
confirmation immediately before deploying Convex production. Deploy Convex and
capture its exact production convex.cloud URL.

Only then set NEXT_PUBLIC_CONVEX_URL in Sites as non-secret public configuration
and rebuild. Fail if the browser bundle contains localhost, the development URL,
a deployment key, or a backend secret, or lacks the exact production URL.

Push the exact validated source commit, save one Sites version from that commit,
deploy it, and poll to success or failure. Require the deployment URL and a
matching nonempty get_site.current_live_url. Open the Site and verify live HTTPS,
Convex reads, writes, and realtime updates. Return the copyable live URL first.
Do not stop at an intermediate state unless authorization or the platform blocks.
```

### Local-only development

```text
$codex-sites-convex Set up this app for accountless local development with
ChatGPT Sites and Convex. If this folder is not already a ChatGPT Sites project,
initialize Sites in this same folder and preserve its normal project structure.
Run the skill's runtime gate before npm, npx, or project scripts. Require Node
22.13.0 or newer and recommend Node 24 LTS. For a new project, add the Node 24
pins and project-owned pre-command checks. Explain that npm install cannot
install or switch the terminal's Node runtime. Preserve existing scripts,
dependencies, package manager, lockfile, and unrelated changes.

Install with the established package manager and run the matching Convex dev
--once command. Confirm .env.local has NEXT_PUBLIC_CONVEX_URL and that the
generated Convex API exists before starting the frontend. Keep one Convex
watcher and one Sites development server running. Reject a fallback port and
verify the exact printed localhost URL with an HTTP request. Then verify a
query, mutation, and realtime update locally. Give me the verified localhost
URL and explain it works only while the development server remains running. Do
not require a Convex login, create a second frontend or database, publish the
Site, or claim the local backend can power a .chatgpt.site URL. Accountless mode
does not create hosted Sites environment variables.
```

### Temporary preview with Cloud Agent Mode

```text
$codex-sites-convex Publish this app as a temporary shared preview using Convex
Cloud Agent Mode and ChatGPT Sites.

Confirm the intended Convex team and project. Reuse an existing isolated cloud
development deployment only after verifying its scope and expiration, or create
an expiring dev deployment for this app. Use only deployment-scoped access and
never expose its deploy key in browser code.

Configure the cloud dev deployment's required environment variables without
printing secret values, then push the Convex functions with npx convex dev
--once. Rebuild ChatGPT Sites with that deployment's public convex.cloud URL and
confirm the bundle contains no deploy key, backend secret, localhost URL, or
unintended deployment URL.

Confirm the exact Sites access mode and get my authorization before making it
public or expanding access. Save and deploy the Sites version, require a
matching nonempty get_site.current_live_url, then verify reads, writes, and
realtime updates through the live Sites URL.

Label the result as a temporary shared preview, not production. Report the
Convex deployment expiration, Sites access mode, visitor sign-in requirements,
whether visitors share data, what stops working after expiration, and the exact
steps required to promote the app to production.
```

## Distinguish the four Sites states

| State | What proves it | What it does not prove |
| --- | --- | --- |
| Local Sites project | The editable Sites project files exist in the folder | Registration, a saved version, or a live URL |
| Registered Site | `.openai/hosting.json` has a valid nonempty `project_id`, and `get_site` confirms the hosted record | A version was saved or deployed |
| Saved Sites version | The current build was uploaded and saved through the Sites hosting workflow | The version is live |
| Published Site | Deployment succeeded and `get_site.current_live_url` is nonempty and matches the deployment URL | Nothing further about application correctness; complete production QA separately |

Do not infer registration from `.openai/hosting.json` alone. Do not infer publication from registration, a saved version, deployment initiation, or a deployment URL that `get_site.current_live_url` does not confirm.

### Recover a registered, public, but unpublished Site

The combination below is not a partial publication; it is an unpublished Site that still needs the complete production path:

- valid `project_id` and confirmed registration;
- `access_level: public`;
- `latest_version_number: 0`;
- `current_live_url: null`;
- no Sites environment variables;
- frontend still targeting accountless local Convex.

Preserve the already-public access policy and do not request the same access change again. Continue by linking the intended Convex Cloud project, announcing the exact production target, obtaining fresh consent immediately before production deployment, deploying Convex, setting the exact production URL as non-secret Sites configuration, rebuilding and scanning the bundle, pushing the exact validated source commit, saving and deploying a Sites version, polling to success, requiring `get_site.current_live_url`, and completing live QA.

Use `scripts/check-publication-state.sh tests/fixtures/registered-public-unpublished.json` for the regression fixture. Exit status `1` is expected because the fixture is unpublished; the output must list the full recovery path.

### Register early for publication work

When the user requests publication:

1. Complete the local build and local validation first.
2. Run `scripts/verify-project.sh --publish`. If it reports a missing `project_id`, call `create_site` exactly once with the Sites hosting workflow.
3. Persist the returned `project_id` in `.openai/hosting.json`.
4. Call `get_site` and confirm the hosted record.
5. Check `list_sites` or the Sites UI separately for sidebar visibility.
6. If the record exists but is not listed yet, preserve the `project_id`, do not call `create_site` again, report `Registered Site; sidebar indexing pending`, and ask the user to refresh or reopen Sites.
7. Report `Registered Site` as the current lifecycle state, then continue with Convex production setup.

Registration is intentionally early so the Site has a stable hosted identity even if Convex production setup later pauses for account, team, project, environment, or authorization input. Do not save a placeholder version or claim a publication at this checkpoint.

## Convex development and production

### Local or development backend

Use this while building and testing. It is not the backend for the published Site.

1. Run `scripts/check-runtime.sh` before package installation or project Node commands. Stop before npm or npx when Node is unsupported.
2. Install dependencies with the established package manager.
3. Run `npx convex dev --once`, or the package-manager equivalent, to configure a development backend, push functions once, generate API types, and write the development deployment URL to `.env.local`.
4. Verify the frontend's public Convex URL variable is present. For this Sites starter it is normally `NEXT_PUBLIC_CONVEX_URL`; follow the actual starter convention if different.
5. During an interactive preview, keep the Convex watcher running beside exactly one Sites development server on the expected port.
6. Run `scripts/check-local-url.sh EXACT_LOCAL_URL EXPECTED_PORT`, then verify development reads, writes, and realtime updates.
7. Keep both processes alive for local-only handoff and explain that localhost ends when the Sites process stops.

Accountless agent development may use a local backend without a Convex account. A cloud development deployment requires a Convex project and suitably scoped credentials.

### Temporary cloud preview backend

Use this only for an explicitly requested temporary shared preview:

1. Confirm the intended Convex team and project before selecting or creating a deployment.
2. Inspect an existing isolated cloud dev deployment's owner, reference, key scope, and expiration without displaying credentials. Reuse it only when all four match the preview.
3. Otherwise create a named dev deployment with `npx convex deployment create --type dev --select <team>:<project>:<dev-reference> --expiration <value>`.
4. Create or reuse a deploy key scoped only to that dev deployment. Save it to an ignored environment file; never print it or expose it through a browser-public prefix.
5. Set required cloud dev environment variables after deployment selection and before pushing functions. Use project defaults only when they should apply to every new cloud deployment.
6. Run `npx convex dev --once`, capture the public `convex.cloud` URL, and build Sites with that URL.
7. Scan the production Sites bundle for deploy keys, backend secrets, localhost references, and unintended deployment URLs.
8. Confirm Sites access, save and deploy the version, require `get_site.current_live_url`, and complete live read/write/realtime QA.

Report the exact expiration returned by Convex or confirmed in deployment settings; never estimate it. The Site may remain reachable after the dev deployment expires, but backend reads, writes, scheduled functions, and realtime updates will stop. Do not call the preview production.

### Production backend

Use this only after development checks pass:

1. Confirm the developer is authenticated to the intended Convex project, or that a production-scoped `CONVEX_DEPLOY_KEY` is configured for the deployment workflow.
2. Configure production-only backend environment variables in Convex. Local `.env.local` values are not automatically backend environment variables. Use the dashboard or `npx convex env set --prod NAME`, without exposing secret values in logs or browser variables.
3. Announce the exact team, project, production deployment, known URL, and expected changes. Obtain fresh target-specific consent immediately before deployment, even if Sites is already public.
4. Run `npx convex deploy`. This deploys to the project's production deployment when the local project is configured through `CONVEX_DEPLOYMENT`; when `CONVEX_DEPLOY_KEY` is set, it deploys to the deployment scoped by that key.
5. Capture the exact production Convex URL returned by the deployment workflow or deployment settings.
6. Only now configure Sites `NEXT_PUBLIC_CONVEX_URL` with that production URL as non-secret public configuration.
7. Run a clean frontend production build. Run `scripts/check-production-bundle.sh BUILD_DIR PRODUCTION_URL DEVELOPMENT_URL` and fail unless the exact production URL is present and localhost, the development URL, and credential markers are absent.

Never use `npx convex dev` as the production deployment step, and never publish a Sites bundle connected to a development backend.

The only exception to the development-backend publishing rule is an explicitly requested, expiring temporary shared preview that follows the safeguards above and is labeled as non-production in every handoff.

## Choose who can open the ChatGPT Site

Resolve and explain the access choice before calling a Sites deployment or access-update tool:

- **No sign-in for visitors:** use `public`. Anyone with the URL can open the Site. Public publishing is an external side effect and requires explicit user authorization.
- **Sign-in required for all workspace members:** use `workspace_all`. Visitors sign in with an active ChatGPT/OpenAI account in that workspace.
- **Sign-in required for selected people or groups:** use `custom`. Visitors sign in with the explicitly allowed ChatGPT/OpenAI account. Adding an email grants access but sends no invitation email.
- **Owner/admin access only:** use `admins_only`.

If the user has not requested public access, publish privately with the existing access policy. Do not silently choose `public`. Sites sign-in controls access to the frontend; application authentication controls what a signed-in visitor can do inside the product. Neither requires the visitor to own a Convex account.

Example intent mapping:

- “Publish this so anyone with the link can use it without logging in” → explain `public`, request/confirm authorization, then publish or update access as public.
- “Publish this only for my workspace” → use `workspace_all`.
- “Share this only with alex@example.com” → inspect existing `custom` access, explain the full resulting allowlist, obtain authorization, then pass the complete existing-plus-desired allowlist to `update_site_access`.
- “Publish it privately” with no audience specified → preserve the current private policy or use the private deployment path; report who can access it.

## Publish a new version

1. Confirm the local build passed and the early registration checkpoint produced a valid `project_id` confirmed by `get_site`.
2. Call `get_site`; inspect access, version, live URL, and environment-variable names. Explain whether visitors share data. Preserve an already-public policy; otherwise obtain authorization before changing access to public.
3. Confirm and announce the exact Convex production target, then obtain fresh consent immediately before deploying its functions and schema.
4. Obtain the exact production Convex URL. A Convex cloud project/account is required for developers managing or publishing this backend.
5. Configure Sites `NEXT_PUBLIC_CONVEX_URL` as non-secret public configuration only after the production URL is known.
6. Stop stale development bundles and rebuild cleanly. Run the production-bundle check and reject localhost, the development deployment URL, credential markers, or a missing production URL.
7. Commit the exact validated source, push that commit, and package that selected commit using the Sites hosting workflow.
8. Call `save_site_version` once for that exact build and source commit. Retain its version identifier and report `Saved Sites version`, not `Published Site`.
9. Deploy the saved version with the Sites hosting workflow and retain the deployment identifier.
10. Poll `get_deployment_status` until it returns `succeeded` or `failed`. Do not treat an intermediate state as completion.
11. On success, require a non-null deployment `url` and retain that exact value. Never guess, derive, or reconstruct a URL from a slug.
12. Call `get_site` with the registered `project_id`. Require a nonempty `current_live_url`, confirm that it matches the successful deployment `url`, and inspect the current access configuration.
13. Only now report `Published Site`, open the confirmed `current_live_url` in Codex, and complete live HTTPS, read, write, and realtime QA.
14. Return the clickable Sites URL as the first item in the final answer.

When publication was requested, do not stop after local validation, Convex linking, Site registration, an access change, or environment-variable creation. Continue until the live URL and live QA gates pass unless authorization or a platform failure blocks the workflow.

If deployment fails or work pauses, report the last completed state and one next required action. Examples:

- `Last completed state: Local Sites project. Next action: register the Site and persist its project_id.`
- `Last completed state: Registered Site. Next action: connect and authorize the intended Convex production deployment.`
- `Last completed state: Saved Sites version. Next action: deploy that version and wait for a successful status.`
- `Last completed state: Sites deployment succeeded, publication unconfirmed. Next action: call get_site and require a nonempty current_live_url.`

Do not present an older URL as the new deployment and do not use the word “published” until `get_site.current_live_url` confirms it.

## Discover an already-published Site

1. Read `project_id` from `.openai/hosting.json`.
2. Call `get_site` with that project identifier.
3. Use `current_live_url` as the canonical ChatGPT Sites URL.

If `current_live_url` is empty, report that the Site is registered but not confirmed published. Never guess, derive, or reconstruct the URL from the project slug.

## Update an existing published Site

1. Read `project_id` from `.openai/hosting.json`, call `get_site`, and preserve the existing Site and access policy unless the user explicitly authorizes a change.
2. Inspect the source diff and configuration to classify the update.
3. If Convex backend code, schema, components, schedules, actions, or backend environment requirements changed, announce the exact production target and obtain fresh consent immediately before deploying Convex.
4. If the update is frontend-only, do not redeploy an unchanged backend. Confirm and reuse the exact current production Convex URL.
5. Rebuild and scan the Sites bundle, push the exact validated source commit, save one version from it, deploy that version, poll to completion, and require a matching nonempty `get_site.current_live_url`.
6. Open the live URL and test HTTPS plus the affected query, mutation, and realtime behavior.

Use this reliable short prompt:

```text
$codex-sites-convex Build, validate, and publish the latest version to ChatGPT Sites.
```

## Explain access accurately

- `public`: anyone with the URL can visit without signing in.
- `workspace_all`: active workspace members sign in with their ChatGPT/OpenAI workspace account.
- `custom`: only explicitly allowed users and groups can sign in.
- `admins_only`: only the owner or administrators can visit.

Visitors never need a Convex account. A Convex account is needed only by developers managing or deploying the backend. Product-level authentication may still require visitors to sign in to the application, independently of Sites access and Convex developer access.

## Hand off a private Site

- Tell the visitor to open the Sites URL.
- Tell them to sign in with the ChatGPT/OpenAI account that was granted access.
- Explain that signing in to the Convex dashboard does not grant access to the Site.
- If access fails, call `get_site` and inspect the current access policy instead of guessing.
- Never generate a sign-in bypass token unless the user explicitly requests one.

## Change Site access only with authorization

Access changes are external side effects:

- Never make a Site public automatically.
- Never add users or groups without explicit authorization.
- Before changing access, explain the access level resolved from `get_site` and the proposed change.
- Use `update_site_access` only after the user authorizes the change.
- When preserving custom users, pass the complete existing and desired email allowlist; do not pass only the newly added address.
- Explain that adding an email grants access but does not send an invitation email.

## Published QA

Use Chrome for the final deployed check. Verify:

- initial query and loading state;
- mutation success, duplicate submission behavior, and errors;
- reactive update without refresh;
- authentication and authorization when present;
- responsive layout, keyboard controls, and touch targets;
- empty, offline, and backend-error states;
- browser console and network panel for CSP, CORS, WebSocket, and mixed-content failures.

## Development-server recovery

- Run only one Sites server for the project and require the intended port.
- Reject fallback ports and verify the exact printed local URL with `scripts/check-local-url.sh` before opening the browser or handing it off.
- If `.env.local`, dependencies, or hosting configuration change after startup, let the writes settle and restart exactly once.
- Treat JSON parsing, worker startup, multiple-renderer, and fallback-port errors immediately after those changes as cascading restart failures first.
- Keep `npx convex dev` running during an interactive local preview.
- Treat Grammarly-injected hydration attributes as extension noise after reproducing cleanly with extensions disabled.

Sharing or widening access is an external side effect. Ask before changing the audience unless the user explicitly requested sharing.

## Post-deployment checklist

- [ ] `get_deployment_status` is `succeeded`.
- [ ] The successful deployment `url` is non-null.
- [ ] `get_site.current_live_url` matches the successful deployment URL.
- [ ] The handoff does not call the Site published unless `get_site.current_live_url` is nonempty.
- [ ] The current access mode is reported accurately.
- [ ] An already-public policy was preserved without repeating the access-change request.
- [ ] Fresh target-specific authorization was obtained immediately before Convex production deployment.
- [ ] The finished bundle contains the exact production URL and no localhost, development URL, or deployment credential marker.
- [ ] The saved Sites version came from the exact validated, pushed source commit.
- [ ] Private login requirements are explained when applicable.
- [ ] The user is told that visitors do not need Convex accounts.
- [ ] The handoff names the selected Convex deployment type and who can manage it without exposing credentials.
- [ ] The handoff states whether app data is shared or isolated by authenticated user.
- [ ] A new developer is told what account, project selection, or scoped key is required before a future backend deployment.
- [ ] Reads, writes, and realtime updates work through the selected publicly reachable Convex deployment.
- [ ] The final response begins with the clickable Sites URL and includes the future-update instruction.
- [ ] The final response explains how to reopen the Site in ChatGPT Sites and manage it through Settings.
- [ ] A stopped workflow reports the last completed state and the next required action.

For a temporary shared preview, also confirm:

- [ ] The Convex backend is an isolated cloud dev deployment owned by the confirmed team/project.
- [ ] Its deploy key is scoped only to that deployment and is absent from browser code and the Sites bundle.
- [ ] Its exact expiration is reported without guessing.
- [ ] The handoff says `Temporary shared preview`, not production.
- [ ] The user is told what stops working when the deployment expires.
- [ ] The handoff explains whether visitors share data and how to promote the app to production.

## Promote a temporary preview to production

1. Confirm the intended Convex team, project, and production deployment.
2. Configure the required production environment variables separately; preview values do not automatically transfer.
3. Deploy the functions and schema with `npx convex deploy` using production authorization.
4. Decide explicitly whether preview data should be discarded, exported and migrated, or recreated. Never imply automatic data promotion.
5. Capture the exact production Convex URL and rebuild Sites with it.
6. Confirm the Sites bundle contains neither the preview URL nor any key or backend secret.
7. Save and deploy a new Sites version, verify `get_site.current_live_url`, and repeat production read/write/realtime QA.
8. Retire the preview deployment or let it expire only after the production handoff succeeds and the user approves any cleanup.

## Required final-response templates

Use the applicable template after all checks pass. The clickable URL must be the first item in the response.

After the opening paragraph, add: the exact Sites access mode; whether ChatGPT/OpenAI sign-in is required; Convex deployment type; backend owner or manager; whether data is shared or isolated; and what a new developer needs for the next backend deployment. Never include credentials.

### Temporary shared preview

Your temporary shared preview is live: [Open the Site](SITE_URL)

This is not production. It uses an isolated Convex Cloud dev deployment that expires at EXPIRATION. The Site access mode is ACCESS_MODE, and VISITOR_SIGN_IN. Visitors do not need Convex accounts. DATA_BEHAVIOR.

After expiration, the Sites URL may still open, but backend reads, writes, schedules, and realtime updates will stop. To promote it, configure and deploy the confirmed production Convex backend, decide how to handle preview data, rebuild Sites with the production URL, save and deploy a new version, and repeat live QA.

For future updates, ask Codex: `$codex-sites-convex Build, validate, and publish the latest version to ChatGPT Sites.`

To manage this Site later, open Sites in ChatGPT or visit https://chatgpt.com/sites, select the Site, then open Settings.

### Private Site

Your Site is live: [Open the Site](SITE_URL)

It is private. Open the link and sign in with an authorized ChatGPT/OpenAI account. Visitors do not need Convex accounts.

For future updates, ask Codex: `$codex-sites-convex Build, validate, and publish the latest version to ChatGPT Sites.`

To manage this Site later, open Sites in ChatGPT or visit https://chatgpt.com/sites, select the Site, then open Settings.

### Public Site

Your Site is live: [Open the Site](SITE_URL)

It is public, so anyone with the link can visit without signing in or creating a Convex account.

For future updates, ask Codex: `$codex-sites-convex Build, validate, and publish the latest version to ChatGPT Sites.`

To manage this Site later, open Sites in ChatGPT or visit https://chatgpt.com/sites, select the Site, then open Settings.

For `workspace_all`, `custom`, or `admins_only`, use the private template and add the precise access explanation returned by `get_site`. Every successful handoff must include this exact sentence:

For future updates, ask Codex: `$codex-sites-convex Build, validate, and publish the latest version to ChatGPT Sites.`

Sources:

- https://openai.com/academy/chatgpt-sites/
- https://docs.convex.dev/production/overview
- https://docs.convex.dev/cli/reference/dev
- https://docs.convex.dev/cli/reference/deploy
- https://docs.convex.dev/cli/reference/deployment
- https://docs.convex.dev/production/multiple-deployments
- https://docs.convex.dev/client/react/deployment-urls
- https://docs.convex.dev/ai/convex-mcp-server
- https://docs.convex.dev/cli/agent-mode
