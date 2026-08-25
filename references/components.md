# Official Convex component selection

## Mandatory discovery sequence

Before implementing a backend capability:

1. Fetch `https://www.convex.dev/components/get-convex.md` for the current official catalog.
2. Search `https://docs.convex.dev/llms.txt` for the equivalent built-in Convex feature and implementation guidance.
3. Inspect `package.json`, `convex.config.ts`, and existing component registrations.
4. Compare the official component with the built-in approach.
5. When selecting a component, fetch the catalog's linked `SKILL.md` and read it completely before installing or editing code.
6. Follow that component skill for package installation, registration, schema, API usage, environment variables, and validation.
7. If no Component is selected and a common code-level utility may fit, follow [helpers-and-eslint.md](helpers-and-eslint.md) before adding `convex-helpers`.
8. Run the relevant build and Convex checks after installation.

Do not copy a catalog version into implementation instructions. Use the package/version shown by the live catalog at execution time.

## Selection rules

- Prefer an official component when it directly matches a requested capability and avoids substantial custom reliability or scaling work.
- Prefer built-in Convex primitives for small, straightforward behavior that does not justify another dependency.
- Do not install components speculatively.
- Do not replace a working project integration without a user-visible benefit and migration plan.
- Do not select any Convex static hosting component. The frontend remains on ChatGPT Sites.

## Current capability families

The official catalog currently covers capabilities such as:

- AI agents, persistent text streaming, and RAG;
- Better Auth and WorkOS AuthKit;
- action caching and rate limiting;
- presence and collaborative editor sync;
- aggregates, geospatial queries, migrations, and scalable counters;
- retries, batch work, runtime crons, workflows, and work pools;
- feature flags and backend integrations;
- push notifications, email, and SMS;
- payments and subscriptions;
- external object storage.

This list is only a discovery aid. Always refresh the live catalog because components, versions, and skill links change.

## Required implementation note

Before code changes, state one of:

- `Official component selected: <name>; component skill read: <url>`
- `No official component selected: <brief reason>; using: <official Convex docs URL>`

Sources:

- https://www.convex.dev/components/get-convex.md
- https://docs.convex.dev/components/overview
- https://docs.convex.dev/components/using
- https://docs.convex.dev/llms.txt
