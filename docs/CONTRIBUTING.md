# Contributing Guide

## Branching Strategy

```
main                 ← production-ready, protected
  └── dev            ← integration branch for PRs
       ├── feat/schedule-crud
       ├── fix/auth-redirect
       └── chore/update-deps
```

- **main**: Protected. Deploys to production. Merge only via PR from `dev`.
- **dev**: Integration branch. All feature branches merge here.
- **Feature branches**: Named `feat/<short-description>`, `fix/<short-description>`, or `chore/<short-description>`.

### Branch Naming

| Prefix | Use |
|--------|-----|
| `feat/` | New feature |
| `fix/` | Bug fix |
| `chore/` | Tooling, deps, CI, docs |
| `refactor/` | Code restructuring (no behavior change) |

## Pull Request Rules

1. **One logical change per PR.** Don't bundle unrelated changes.
2. **Title format:** `feat: add schedule block CRUD` or `fix: auth redirect on logout`.
3. **Description must include:**
   - What changed and why
   - Screenshots for UI changes
   - Test plan (how you verified it works)
4. **Require at least 1 approval** before merging.
5. **CI must pass** (lint, typecheck, tests).
6. **Squash merge** into dev to keep history clean.

### PR Template

```markdown
## What

Brief description of the change.

## Why

Context/motivation.

## How

Implementation approach.

## Test Plan

- [ ] Unit tests pass
- [ ] Tested on emulators
- [ ] Tested on physical device (if UI change)

## Screenshots (if applicable)
```

## Code Style

### Dart (Flutter)

- Follow the rules in `analysis_options.yaml` (strict mode).
- Use `const` constructors wherever possible.
- Prefer single quotes for strings.
- Use Riverpod providers for state; avoid `setState` except in local widget state.
- Name files with `snake_case`.
- Name classes with `PascalCase`.
- Always declare return types on functions.

### TypeScript (Functions)

- Follow ESLint + Prettier config in `functions/`.
- Use `double quotes` (Prettier default for this project).
- Validate all inputs with Zod schemas from `@ppt/shared`.
- Always handle errors; never swallow exceptions silently.
- Use `async/await` over raw Promises.

### General

- No `console.log` in Flutter (use `debugPrint` or `logger`).
- No secrets in code. Ever. Use Secret Manager or environment variables.
- No `// TODO` without a linked issue number: `// TODO(#42): implement ICS parser`.

## Review Expectations

- **Reviewers:** Focus on correctness, security, and maintainability.
- **Authors:** Respond to all comments. Resolve conversations when addressed.
- **Turnaround:** Review within 24 hours during active sprints.
- **Be kind.** We're all learning.

## Testing

### Functions

```bash
pnpm --filter @ppt/functions run test
```

Write unit tests for:
- Service functions (plan generator, scraper logic)
- Request validation
- Auth middleware (with mocked tokens)

### Flutter

```bash
cd apps/mobile && flutter test
```

Write tests for:
- Model serialization (JSON round-trip)
- Provider logic (with mocked dependencies)
- Widget tests for critical UI flows

### Running Everything

```bash
# From repo root
pnpm test                    # Node.js tests
pnpm flutter:test            # Flutter tests
```

## Good First Issues

If you're new to the project, look for issues labeled `good-first-issue`. Here are some starter tasks:

1. **Add a "category" icon mapper** – Create a utility that maps schedule block categories to Material icons (partially exists in `schedule_tab.dart`; extract to a shared utility).

2. **Add form validation to schedule edit** – Ensure end time is after start time. Show an error if they overlap.

3. **Display today's plan items** – Replace the placeholder in `today_tab.dart` with actual plan items loaded from Firestore.

4. **Add a loading skeleton** – Replace `CircularProgressIndicator` with shimmer/skeleton loading in the Today tab.

5. **Implement fitness level selector** – Add a bottom sheet or dialog in the Profile tab to select beginner/intermediate/advanced.

6. **Add unit tests for Zod schemas** – Expand test coverage in `packages/shared/src/schemas.test.ts` with edge cases.

7. **Add dark mode toggle** – Add a switch in the Profile tab that overrides system theme.

8. **Format facility usage timestamps** – Show "Updated 3 min ago" instead of raw ISO strings.

## Setting Up Your Dev Environment

See [SETUP.md](./SETUP.md) for detailed instructions.
