# Architecture contract

## Ownership

| Concern | Owner |
| --- | --- |
| React UI, layout, browser interactions | ChatGPT Sites project |
| Frontend build, URL, access, sharing | ChatGPT Sites |
| Tables, indexes, durable records | Convex |
| Queries, mutations, actions, schedules | Convex |
| Realtime subscriptions | Convex React client |
| Backend secrets | Convex environment variables |
| Development inspection | Convex CLI and MCP |

The browser receives only the public Convex deployment URL and user-facing configuration. It imports generated types from `convex/_generated/api` and connects through `ConvexProvider`.

```text
Visitor browser
→ ChatGPT Sites frontend
→ NEXT_PUBLIC_CONVEX_URL
→ Convex Cloud deployment
→ Convex queries, mutations, actions, and data
```

See [sites-settings-and-environment.md](sites-settings-and-environment.md) for Sites management, environment layers, hosting metadata, and update runbooks.

## Sites lifecycle states

| State | Required evidence |
| --- | --- |
| Local Sites project | Editable Sites project files exist in the current folder |
| Registered Site | A valid nonempty `project_id` exists and `get_site` confirms the hosted Site record |
| Saved Sites version | The current build was uploaded and saved as a Sites version |
| Published Site | A saved version deployed successfully and `get_site.current_live_url` is nonempty |

These states are cumulative but not interchangeable. `.openai/hosting.json` without a valid `project_id` is only a local manifest. A returned deployment URL is provisional until `get_site.current_live_url` confirms the live Site.

An access policy is not a lifecycle state. `public` means anyone with the URL may visit, but it does not create a version or deployment. A registered public Site with no saved version and `current_live_url: null` is unpublished.

For publish or share intent, the default architecture path is: local validation → registered Site → confirmed Convex Cloud production target and fresh deployment consent → production Convex URL → Sites public configuration → clean scanned build → exact validated source commit → saved Sites version → Sites deployment → matching nonempty `current_live_url` → live HTTPS/read/write/realtime QA.

## Account boundaries

See [accounts-access-and-ownership.md](accounts-access-and-ownership.md) for the account matrix, safe credential detection, ownership rules, Sites access, and application authentication. The essential boundary is: Sites controls who can open the frontend; Convex application authorization controls which data an app user can read or change.

## Current integration gate

The OpenAI Academy Sites page currently says Sites cannot connect directly to live data sources. A Convex-backed Site therefore requires an early deployed proof that the published origin permits browser HTTPS and WebSocket traffic to the chosen Convex deployment.

Pass criteria:

- Query returns a record.
- Mutation writes a record.
- The subscribed query updates without a refresh.
- Chrome shows no CSP, CORS, WebSocket, or mixed-content failure.

If this fails, preserve the evidence and stop before building the full product.

## Sources

- https://openai.com/academy/chatgpt-sites/
- https://docs.convex.dev/ai/using-codex
- https://docs.convex.dev/ai/convex-mcp-server
- https://docs.convex.dev/cli/agent-mode
