# Accounts, access, and ownership

Read the current official sources before choosing a workflow:

- https://docs.convex.dev/cli/agent-mode
- https://docs.convex.dev/cli/local-deployments
- https://docs.convex.dev/production/overview
- https://docs.convex.dev/production/project-configuration
- https://docs.convex.dev/cli/deploy-key-types
- https://docs.convex.dev/llms.txt

## Contents

- Account and ownership matrix
- Safe credential detection
- Accountless-to-production handoff
- Sites access and application authentication
- Public-data warning
- App and documentation copy
- Published handoff
- Validation cases

## Account and ownership matrix

| Context | Where the backend or gate runs | Owner or manager | Required login or key | Can power a published Site? | Visitor behavior and data |
| --- | --- | --- | --- | --- | --- |
| Accountless local Agent Mode | Developer's machine; state in `.convex/` | Person or agent controlling that machine | No Convex login or deploy key | No; it is not a publicly reachable production backend | Local testers only; local backend must keep running |
| Signed-in developer cloud development | Developer's personal cloud dev deployment | Convex team/project and signed-in developer | Saved Convex CLI user credentials | No; use the project's production deployment for publishing | Development data is separate from production |
| Isolated cloud agent development | Deployment-scoped Convex Cloud dev deployment | Convex team/project that issued the scoped key | Dev-deployment-scoped `CONVEX_DEPLOY_KEY` | Yes, for a clearly labeled temporary shared preview; not for production | Preview data is isolated to that deployment but may be shared among visitors |
| Convex Cloud production | Publicly reachable production deployment | Convex team/project or holder of its production-scoped key | Convex account/project or production-scoped deploy key | Yes | Data isolation depends on application authentication and backend authorization |
| ChatGPT Sites visitor access | ChatGPT Sites gate in front of the frontend | Site owner or workspace administrators | Public access or authorized ChatGPT account | Controls who opens the frontend and does not deploy Convex | Visitors never need Convex accounts |
| Product-level authentication | Application and protected Convex functions | Application owner | Product-specific visitor identity | Independent of Sites access | Determines whether records are shared or isolated per authenticated user |

Accountless local Agent Mode runs a backend on the developer's machine. It needs neither a Convex login nor a deploy key, cannot serve a published ChatGPT Site, and must keep `npx convex dev` running during local development. A live Site needs a publicly reachable Convex Cloud URL. Use an expiring isolated cloud dev deployment only for a clearly labeled temporary shared preview, and use the confirmed production deployment for production. Developers need access to the owning Convex team or project or an appropriately scoped key. A Convex Pro plan is not required merely to publish. Visitors never need Convex accounts.

## Detect credentials without exposing them

Before choosing a workflow, classify the environment without printing secret values:

1. Determine whether `CONVEX_DEPLOYMENT` is present and whether its reference selects local, dev, preview, or production.
2. Determine whether `CONVEX_DEPLOY_KEY` is present. Never print or partially reveal it.
3. Check only whether Convex CLI user configuration exists. Never read or print its contents.
4. Classify the frontend's `NEXT_PUBLIC_CONVEX_URL` as missing, localhost/`127.0.0.1`, or `convex.cloud`. Avoid printing unrelated environment variables.
5. Resolve the selected team, project, and deployment using safe CLI metadata or explicit user confirmation before any production write.

Never print credentials, deploy keys, admin keys, tokens, or Convex user-configuration contents. Never claim no Convex account was used merely because no login prompt appeared; saved CLI credentials may have been reused.

Classify a deployment key by its documented scope. A dev-scoped key is not production authorization. Do not infer production access from the mere presence of a key.

## Move accountless development to production

When a user with an accountless local backend asks to publish:

1. Explain that the current local backend cannot serve the published Site.
2. Tell the user they must sign in to or create a Convex account, or provide a production-scoped deployment key owned by their team.
3. Follow the latest official Convex instructions to link or select the intended project.
4. Confirm the intended Convex team, project, and production deployment before deploying.
5. Announce the exact production team, project, deployment, known URL, and expected changes; obtain fresh target-specific consent immediately before deployment.
6. Deploy the backend to production.
7. Capture the exact production Convex URL.
8. Configure Sites `NEXT_PUBLIC_CONVEX_URL` as non-secret public configuration only after that URL is known.
9. Rebuild Sites cleanly and scan the browser bundle.
10. Push the exact validated source commit, save and deploy the Sites version, and require `get_site.current_live_url`.
11. Verify reads, writes, and realtime updates through the published Sites URL.

Do not publish a bundle containing `127.0.0.1`, `localhost`, a local deployment URL, or an unintended development deployment.

## Publish a temporary shared preview

Use this only when the user explicitly requests a temporary preview backed by Convex Cloud Agent Mode:

1. Confirm the intended Convex team and project.
2. Reuse a named isolated cloud dev deployment only after confirming its owner, scope, and expiration, or create an expiring dev deployment.
3. Use only a deployment-scoped dev key. Never display it or place it in browser code.
4. Configure the cloud dev deployment's required environment variables and push functions with `npx convex dev --once`.
5. Build and publish Sites with the dev deployment's public `convex.cloud` URL after confirming Sites access.
6. Verify live reads, writes, and realtime updates.
7. Report the exact expiration, Sites access mode, visitor sign-in, shared-versus-isolated data behavior, and production promotion steps.

The Sites frontend and its URL do not automatically expire with Convex. Warn that backend reads, writes, schedules, and realtime updates stop when the dev deployment expires. Preview data remains separate and is not automatically promoted or copied to production.

## Separate Sites access from application authentication

Changing a Site from `custom` to `public` changes only the ChatGPT Sites visitor gate. It does not deploy Convex, move Convex data, change the Convex plan, or create Convex visitor accounts. It requires explicit user authorization.

If `get_site` already reports `public`, preserve that setting and do not request the same access-policy change again. Continue the publication lifecycle. Fresh target-specific authorization is still required immediately before every Convex production deployment.

| Sites mode | Who can open the frontend? |
| --- | --- |
| `public` | Anyone with the URL, without ChatGPT sign-in |
| `custom` | Explicitly allowed ChatGPT/OpenAI users and groups |
| `workspace_all` | Active members of the ChatGPT/OpenAI workspace |
| `admins_only` | Site owner or administrators |

Application authentication is separate. It identifies visitors inside the app, while authorization in Convex functions decides which records each identity can read or change. A private Sites gate does not replace backend authorization, and a public Sites gate does not automatically make data per-user.

## Warn before exposing shared data

Before making a Site public, inspect whether the app has product authentication and per-user authorization in its Convex functions.

If it does not, tell the user exactly:

> This Site will be public and all visitors will use the same Convex data. Anyone who can open the Site may be able to read or change shared records.

Obtain explicit authorization after this warning and before changing access. If the app has product authentication, report whether data is actually isolated per authenticated user based on backend authorization checks; do not assume it from the presence of a sign-in screen.

## Keep visitor UI visitor-focused

- Do not put developer account, project-linking, or deploy-key setup in normal visitor-facing UI.
- A developer setup screen is appropriate only when the public Convex URL is missing or invalid. It must render a safe configuration state, not throw during React rendering.
- Visitor-facing copy may say: “No Convex account is required to use this app.”
- For a public app without product authentication, add a concise shared-data notice when relevant.
- Do not generate a README in each built app unless the user asks for one.

## Required published handoff

Every published handoff must report:

1. Exact clickable ChatGPT Sites URL.
2. Sites access mode.
3. Whether visitors must sign in with ChatGPT/OpenAI.
4. That visitors do not need Convex accounts.
5. Convex deployment type (`temporary cloud dev preview` or `production`), without credentials or secret identifiers.
6. Who owns or can manage the Convex backend.
7. Whether app data is shared or isolated by authenticated user.
8. What a new developer must configure before future backend deployments.
9. The required future-update prompt from the deployment guide.

## Validation cases

Use these scenarios to validate future changes to the skill:

| Case | Backend and owner | Publishing | Required credential | Visitor sign-in | Data model |
| --- | --- | --- | --- | --- | --- |
| Fresh machine, no account, local-only | Local machine; controlled by local developer/agent | Not requested; local only | None | Local tester only | Shared local data unless app auth exists |
| Fresh machine, no account, asks to publish | Starts local; production must move to a confirmed Convex Cloud project | Block until account/project or production key is provided | Convex login/project or production-scoped key | Determined by Sites mode | Report shared vs per-user after auth audit |
| Machine with saved Convex credentials | Selected personal cloud dev or local deployment; owned by its Convex team/project | Possible after confirming team/project/prod | Existing saved user credential, confirmed safely | Determined by Sites mode | Production data policy must be verified |
| Cloud agent with dev-scoped key | Isolated, expiring Convex Cloud dev deployment | May publish a temporary shared preview; cannot publish production with that key | Deployment-scoped dev key | Determined by Sites mode | Preview data may be shared unless app auth and backend authorization isolate it |
| CI with production-scoped key | Convex Cloud production; owned by issuing team/project | Yes | Production-scoped deploy key | Determined by Sites mode | Shared or per-user based on backend auth |
| Private Site with public Convex URL | Convex Cloud production; team-managed | Yes | Backend production authorization plus Sites publish access | Yes according to `custom`, `workspace_all`, or `admins_only` | Shared or per-user based on app auth, not Sites privacy |
| Public Site without product auth | Convex Cloud production; team-managed | Yes, after explicit warning and authorization | Production authorization | No ChatGPT sign-in | Shared data; warn before publishing |
| Public Site with per-user app auth | Convex Cloud production; team-managed | Yes, after explicit public authorization | Production authorization | No Sites sign-in; app sign-in may be required | Isolated only if Convex authorization enforces ownership |

For each test, the agent must identify where the backend runs, who owns it, whether publishing is possible, the required login or key, whether visitors sign in, and whether visitor data is shared.
