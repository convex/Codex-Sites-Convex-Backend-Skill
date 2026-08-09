# Convex helpers and ESLint

Use this reference before adding `convex-helpers` or changing project lint configuration.

## Selection order

1. Inspect the current project for an existing solution.
2. Use a documented built-in Convex primitive when it is sufficient.
3. Use an official Convex Component when it owns state or a lifecycle that the app should not rebuild.
4. Use `convex-helpers` for a matched code-level utility that removes repeated application code.
5. Add no package when the requested behavior remains clearer in local code.

`convex-helpers` is not a Convex Component. Do not expect it to appear in the Component catalog and do not install it during generic project setup.

## Good helper candidates

Check the current package documentation for utilities such as:

- custom query, mutation, and action wrappers;
- relationship and validator helpers;
- anonymous session identifiers;
- pagination, stream, query-cache, and React query helpers;
- CORS and HTTP router helpers;
- small retry, migration, rate-limit, or trigger utilities when an official Component is not the better owner.

Install only after naming the selected utility and the repeated code or correctness risk it removes. Import only the documented path needed by the app.

## Guardrails

- A session identifier is not authentication or authorization.
- A custom function wrapper centralizes checks but does not prove every resource access is authorized.
- Prefer indexed Convex queries. Do not use a JavaScript filter helper to hide an unbounded scan.
- Do not replace a working official Component with a helper without a user-visible benefit and migration plan.
- Prefer the current official Rate Limiter or Migrations Component when the requested behavior needs its managed state and lifecycle.
- Read the current repository or package documentation before using an API; helper exports can change.
- Run Convex code generation, type checks, tests, and lint after adding a helper.

Record one of these before implementation:

- `Convex helper selected: <utility>; reason: <matched need>; source: <current URL>`
- `No Convex helper selected: <brief reason>; using: <built-in docs or Component skill URL>`

## Official Convex ESLint rules

The official `@convex-dev/eslint-plugin` catches common Convex function problems, including old registered-function syntax, missing argument validators, implicit table IDs, inefficient query filtering, and top-of-hour cron schedules.

Before configuring it:

1. Inspect `package.json`, the lint script, and all ESLint configuration files.
2. Fetch the current setup instructions at `https://docs.convex.dev/eslint`.
3. Preserve the project's flat or legacy configuration format.
4. Preserve unrelated plugins, ignores, file patterns, and rules.
5. Ensure the recommended Convex rules apply to the actual Convex source directory.
6. Ensure the project's lint command includes that directory.

For a new project, configure the official plugin as part of the initial quality setup. If the starter has no ESLint configuration, add a minimal compatible setup unless the user excluded lint tooling or project constraints make that unsafe.

For an existing project:

- extend a compatible ESLint setup instead of replacing it;
- do not silently migrate legacy configuration formats;
- if no ESLint setup exists, recommend the plugin and report lint as not configured rather than failing an otherwise valid project;
- if the plugin dependency exists but its recommended rules are not referenced, report the setup as partial and fix it when lint configuration is in scope.

Run the existing lint command after changes. Treat Convex lint errors as implementation failures. Do not suppress a recommended rule merely to make validation green; fix the code or document a narrow project-specific exception.

Sources:

- https://github.com/get-convex/convex-helpers
- https://www.npmjs.com/package/convex-helpers
- https://docs.convex.dev/eslint
- https://www.convex.dev/components/get-convex.md
