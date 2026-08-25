# Sites settings and environment

Use the current official sources:

- https://learn.chatgpt.com/docs/sites?surface=app
- https://chatgpt.com/sites
- https://docs.convex.dev/client/react/deployment-urls
- https://docs.convex.dev/production/environment-variables
- https://docs.convex.dev/production/project-configuration
- https://docs.convex.dev/cli/agent-mode
- https://docs.convex.dev/llms.txt

## Contents

- Find and manage a published Site
- Site settings
- Sites-to-Convex data flow
- Three environment layers
- Environment-variable reference
- Hosting manifest
- Change-specific runbooks
- Published handoff

## Find and manage a published Site

### ChatGPT desktop app

1. Open ChatGPT.
2. Open Sites.
3. Find and select the Site.
4. Open Settings to manage it.
5. Open Analytics to review unique visitors and page views.

### ChatGPT on the web

1. Open https://chatgpt.com/sites.
2. Find the Site.
3. Select More actions.
4. Select Settings or Analytics.

Sites does not have a standalone Codex CLI or IDE management screen. Codex can edit and test the local project, but hosted Site management happens through ChatGPT on the web or in the desktop app. A Site remains in the Sites list after the original Codex task or ChatGPT conversation ends.

Every published handoff must include:

> To manage this Site later, open Sites in ChatGPT or visit https://chatgpt.com/sites, select the Site, then open Settings.

## Understand Site settings

- **Name:** the Site's display name.
- **URL or domain:** its hosted `chatgpt.site` address.
- **Custom domain:** a domain or subdomain the user already owns.
- **Sharing:** who can open the Site.
- **Environment variables:** configuration used by the hosted frontend or Sites worker.
- **Analytics:** unique visitors and page views.
- **Delete Site:** permanent deletion that cannot be undone.

Available settings can vary by plan, region, workspace policy, and the current Sites beta. Sharing controls who can visit; it does not grant permission to edit the Site or manage its Convex backend.

## Understand the Sites-to-Convex data flow

```text
Visitor browser
→ ChatGPT Sites frontend
→ NEXT_PUBLIC_CONVEX_URL
→ Convex Cloud deployment
→ Convex queries, mutations, actions, and data
```

- ChatGPT Sites hosts the frontend.
- Convex hosts the database and backend functions.
- `NEXT_PUBLIC_CONVEX_URL` tells `ConvexReactClient` which deployment to connect to.
- The Convex deployment URL is public configuration, not a password. Knowing it does not grant dashboard or deployment access.
- Generated Convex API types tell the frontend which functions it can call.
- Convex validators, authentication, and authorization still protect backend operations.
- Site visitors never need Convex accounts.
- A public Site without product authentication may expose shared application data to every visitor.
- Accountless Agent Mode may configure `.env.local`, but it does not create hosted Sites environment variables.

## Keep the three environment layers separate

| Layer | Location | Purpose | Rules |
| --- | --- | --- | --- |
| Local frontend | `.env.local` | Local development settings, local or development Convex URL, and frontend configuration | Keep it out of Git. Keep `.env.example` aligned by variable name without real secrets. A localhost Convex URL cannot power a published Site. |
| Hosted ChatGPT Sites | Sites → Site → Settings → Environment variables | Configuration available to the hosted frontend or Sites worker | Do not store hosted values in `.openai/hosting.json`. Redeploy an approved saved version after changes. Rebuild first when browser JavaScript embeds the value. Browser public prefixes are visible to visitors. Mark only true server side values as Secret. |
| Convex deployment | Convex dashboard deployment settings or Convex CLI environment commands | Secrets and configuration read by Convex functions | Convex functions do not read frontend `.env.local`. Development and production values are separate. Third-party keys used by actions belong here. Set production values on production. |

A Secret switch cannot make a browser-public variable safe. Never copy a Convex backend secret into `NEXT_PUBLIC_*`, `VITE_*`, or another browser-public variable.

For production, set hosted `NEXT_PUBLIC_CONVEX_URL` only after the exact production deployment URL is known. Treat it as non-secret public configuration. Linking Convex Cloud or setting Sites access does not populate this value automatically.

## Environment-variable reference

| Variable | Location | Secret? | Purpose |
| --- | --- | --- | --- |
| `NEXT_PUBLIC_CONVEX_URL` | Local frontend and hosted Sites configuration | No | Public Convex Cloud URL used by `ConvexReactClient` |
| `NEXT_PUBLIC_CONVEX_SITE_URL` | Frontend only when public HTTP Actions need it | No | Public Convex HTTP Actions URL |
| `CONVEX_DEPLOYMENT` | Local developer environment | Treat as internal configuration | Selects the local, development, preview, or project deployment |
| `CONVEX_DEPLOY_KEY` | Secure deployment environment only | Yes | Authorizes deployment operations |
| Third-party key used by a Convex action | Convex deployment environment | Yes | Allows backend functions to call another service |
| Browser-public analytics or SDK key | Hosted Sites environment | No, when designed to be public | Configures browser code |
| Server-only Site worker secret | Hosted Sites environment | Yes | Used only by server-side Sites code |

Hard rules:

- Never put `CONVEX_DEPLOY_KEY` in browser code or a `NEXT_PUBLIC_*` variable.
- Never mark `NEXT_PUBLIC_CONVEX_URL` as Secret.
- Never publish a Site pointing to localhost or `127.0.0.1`.
- Never assume a development Convex deployment is the production backend.
- Never print environment values that may contain secrets.

## Keep `.openai/hosting.json` metadata-only

`.openai/hosting.json` is the local hosting manifest. Its presence alone does not prove that a hosted Site was registered. It may contain:

- `project_id`;
- a logical D1 binding name;
- a logical R2 binding name.

It must not contain:

- `NEXT_PUBLIC_CONVEX_URL`;
- API, Convex deploy, or admin keys;
- third-party secrets;
- hosted runtime environment values.

A valid nonempty `project_id` identifies the registered Sites project. Confirm it with `get_site`; it is not a Convex project ID and does not connect the user's Convex account. Registration does not prove that a build was saved as a version or deployed. Likewise, `access_level: public` does not prove publication. A registered public Site with `latest_version_number: 0` and `current_live_url: null` remains unpublished and needs production backend configuration, a clean Sites build, a saved version, a successful deployment, and live URL verification.

The lifecycle states are:

1. Local project files.
2. Registered Site confirmed by `project_id` and `get_site`.
3. Saved Sites version confirmed by the hosting workflow.
4. Published Site confirmed only by a nonempty `get_site.current_live_url` after deployment.

Sidebar appearance is not a lifecycle state. `get_site` confirms that registration succeeded; `list_sites` or the Sites UI confirms discoverability. If the hosted record exists but the sidebar has not indexed it yet, keep the existing `project_id`, do not create a duplicate, and refresh or reopen Sites before checking again.

## Runbooks for common changes

### Change frontend code

1. Make and validate the frontend change.
2. Build with the correct production Convex URL.
3. Save a new Sites version.
4. Deploy the approved version.
5. Verify the live URL.

### Change Convex backend code

1. Confirm the intended Convex team, project, and production deployment.
2. Deploy the Convex functions and schema.
3. Confirm the production URL did not change.
4. Rebuild and redeploy Sites if frontend source, generated API use, or public configuration changed.
5. Test queries, mutations, and realtime updates through the live Site.

### Point the Site to a different Convex deployment

1. Confirm who owns the target Convex project.
2. Deploy and validate its production backend.
3. Copy its exact `convex.cloud` URL.
4. Update `NEXT_PUBLIC_CONVEX_URL` in Sites settings.
5. Update the production build environment.
6. Rebuild because `NEXT_PUBLIC_*` values may be embedded in browser JavaScript.
7. Save a new Sites version.
8. Deploy it.
9. Confirm the built frontend no longer contains the old URL.
10. Test reads, writes, and realtime subscriptions.

### Change a Sites environment variable

1. Open the Site's Settings.
2. Update the value without putting it in a prompt or committed file.
3. Determine whether it is runtime-only or bundled into client JavaScript.
4. Rebuild when the browser bundle consumes it.
5. Redeploy the approved saved version.
6. Verify the new deployment.

### Change a Convex backend secret

1. Select the correct Convex deployment.
2. Set the value in the Convex deployment environment.
3. Do not add it to Sites settings.
4. Verify the Convex function that uses it.
5. Redeploy Convex only when required by current Convex documentation.

### Change Site sharing

1. Inspect the current access mode.
2. Explain the proposed audience.
3. Warn when a public app has shared Convex data.
4. Obtain explicit authorization.
5. Change the Sites access setting.
6. Test as the intended visitor.

Changing sharing does not deploy Convex, move data, or change the Convex plan.

## Required published handoff

Along with the URL, access, ownership, authentication, and future-deployment details required by the other references, include this exact sentence:

> To manage this Site later, open Sites in ChatGPT or visit https://chatgpt.com/sites, select the Site, then open Settings.
