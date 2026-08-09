# Convex helpers and ESLint guidance

Created: 2026-08-09T05:34:22Z

## Goal

Help Codex Sites projects use current Convex utilities when they remove repeated backend code and use the official Convex ESLint rules to catch common function mistakes.

## Requirements

- Keep Codex Sites responsible for the frontend and Convex responsible for backend execution and data.
- Keep official Component discovery before implementation.
- Treat `convex-helpers` as an optional code-utility library, not a default dependency or Component.
- Prefer indexes over post-query filtering, product authentication over sessions, and explicit authorization over wrapper assumptions.
- Configure `@convex-dev/eslint-plugin` for new projects and compatible existing ESLint setups without replacing unrelated lint configuration.
- Warn rather than fail when an existing project has no ESLint setup.
- Add current official links to the skill reference, documentation map, and README.
- Validate the skill, shell scripts, helper selection wording, and ESLint detection behavior.

## Files in scope

- `SKILL.md`
- `README.md`
- `references/helpers-and-eslint.md`
- `references/convex-doc-map.md`
- `references/convex-rules.md`
- `scripts/verify-project.sh`
- `files.md`
- `changelog.md`
- `task.md`
- `agents/openai.yaml` only if its user-facing behavior is stale

## Completion evidence

- Skill validator passes.
- All shell scripts pass `bash -n`.
- Project verification distinguishes configured, partial, and absent Convex ESLint setups.
- `convex-helpers` is never installed speculatively.
- Existing architecture and publication ordering remain unchanged.
