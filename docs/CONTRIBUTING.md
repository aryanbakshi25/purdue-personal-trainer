# Contributing Guide

## Getting Started

1. Follow the [Developer Setup Guide](./DEV-SETUP.md) to get the app running locally.
2. Pick a task from the [Task Board](./TASKS.md).
3. Create a branch, build the feature, and open a PR.

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
- **Feature branches**: Create from `dev`, merge back into `dev`.

### Creating Your Branch

```bash
git checkout dev
git pull origin dev
git checkout -b feat/your-task-name
```

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

- [ ] Unit tests pass (`flutter test`)
- [ ] Tested on emulator with Firebase emulators running
- [ ] Screenshots attached (if UI change)

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

## Development Workflow

### 1. Start the emulators

```bash
pnpm emulators
```

### 2. Run the app

```bash
cd apps/mobile
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:5001/scab-purdue/us-central1/api
```

### 3. Sign in

Use **"Sign in with Emulator"** on the login screen for local development.

### 4. Make your changes

Edit the relevant files. Flutter hot-reload (`r` in terminal) applies most Dart changes instantly. Press `R` for a full restart if state gets stale.

### 5. Test

```bash
# Flutter tests
cd apps/mobile && flutter test

# Node.js tests (if you changed functions or shared schemas)
pnpm test
```

### 6. Open a PR

```bash
git add .
git commit -m "feat: your change description"
git push -u origin feat/your-task-name
```

Then open a PR on GitHub targeting the `dev` branch.

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

## Project Structure Quick Reference

```
apps/mobile/lib/
├── app/              App root widget
├── features/         Feature modules
│   ├── auth/         Login screen
│   ├── today/        Today tab (plan + facility usage)
│   ├── schedule/     Schedule CRUD
│   ├── chat/         AI chat assistant
│   └── profile/      User profile
├── models/           Dart data models
├── providers/        Riverpod providers (state management)
├── services/         API client
└── shared/           Theme, routing, shared widgets

functions/src/
├── routes/           Express route handlers
├── middleware/        Auth middleware
├── services/         Gemini, plan generator, facility scraper
└── index.ts          Entry point
```
