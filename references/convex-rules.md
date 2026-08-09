# Convex implementation rules

Apply these rules before editing any file in `convex/`.

- Use object-form queries, mutations, and actions with `args` and `returns` validators.
- Use `v.null()` for functions that return no value.
- Use public functions only for browser-callable APIs; use internal functions for server-only composition.
- Authenticate and authorize every protected function.
- Query ownership through declared indexes; avoid unbounded `.collect()` and post-query `.filter()`.
- Keep results bounded or paginated.
- Make retryable mutations idempotent with early returns.
- Patch directly when no prior read is needed.
- Use actions for external network calls and Node-specific work; actions call queries/mutations for database access.
- Use `ctx.scheduler.runAfter` or scheduled functions for deferred work.
- Store third-party secrets with Convex environment variables.
- Use generated `api` and `internal` references; never string function names.
- Run `npx convex codegen` after API changes.
- Suggest migration steps before changing fields that existing records may lack.
- Prefer a documented built-in primitive or official Component before adding a utility dependency.
- Use `convex-helpers` only for a named matched utility; sessions are not authentication, wrappers do not replace authorization, and JavaScript filters do not replace indexes.
- Configure and run the official Convex ESLint recommended rules for new projects and compatible existing ESLint setups.

Use the current `npx convex ai-files install` output and installed `convex:convex-expert` skill as the authoritative implementation layer when available.
Read [helpers-and-eslint.md](helpers-and-eslint.md) before adding `convex-helpers` or changing ESLint configuration.

Sources:

- https://docs.convex.dev/understanding/best-practices/typescript
- https://docs.convex.dev/functions/query-functions
- https://docs.convex.dev/functions/mutation-functions
- https://docs.convex.dev/functions/actions
- https://docs.convex.dev/functions/validation
- https://docs.convex.dev/database/indexes
- https://docs.convex.dev/eslint
- https://github.com/get-convex/convex-helpers
