# Task Board — Sprint 1

Pick a task, assign yourself by adding your name to the **Owner** column, and create a branch. Each task is self-contained and designed for someone learning Flutter.

**Before you start:** Complete the [Developer Setup Guide](./DEV-SETUP.md) and make sure you can run the app and sign in with the emulator.

## How to Claim a Task

1. Open a PR that edits this file — put your name in the Owner column.
2. Create your branch: `git checkout -b feat/<branch-name>` (off `dev`).
3. When done, open a PR targeting `dev`. See [CONTRIBUTING.md](./CONTRIBUTING.md).

---

## Flutter Tasks (Frontend)

### Task 1: Category Icon Mapper Utility
| Field | Details |
|-------|---------|
| **Branch** | `feat/category-icon-mapper` |
| **Difficulty** | Easy |
| **Owner** | _unclaimed_ |
| **Files** | Create `lib/shared/utils/category_icons.dart`, update `lib/features/schedule/schedule_tab.dart` |

**What to do:** There's inline icon-mapping logic in `schedule_tab.dart` (the `_categoryIcon` method). Extract it into a shared utility function `IconData iconForCategory(String category)` that maps categories (`class`, `club`, `study`, `workout`, `work`, `meal`, `other`) to Material Icons. Import and use it everywhere schedule categories appear.

**What you'll learn:** Dart functions, Material icons, imports, code organization.

---

### Task 2: Schedule Form Validation
| Field | Details |
|-------|---------|
| **Branch** | `feat/schedule-form-validation` |
| **Difficulty** | Easy |
| **Owner** | _unclaimed_ |
| **Files** | `lib/features/schedule/schedule_edit_screen.dart` |

**What to do:** Add validation to the schedule edit form: end time must be after start time (show a `SnackBar` error if not), and title cannot be empty (already partially done). Also prevent saving if the time range is invalid.

**What you'll learn:** Form validation, `TimeOfDay` comparison, `ScaffoldMessenger`/`SnackBar`.

---

### Task 3: Profile Persistence (Firestore)
| Field | Details |
|-------|---------|
| **Branch** | `feat/profile-persistence` |
| **Difficulty** | Medium |
| **Owner** | _unclaimed_ |
| **Files** | `lib/features/profile/profile_tab.dart`, create `lib/providers/profile_provider.dart`, `lib/models/user_profile.dart` |

**What to do:** When a user signs in, create a `UserProfile` document in Firestore at `users/{uid}` (if it doesn't already exist). Add a `StreamProvider` that listens to `users/{uid}` and displays the profile data. The `UserProfile` model already exists in `lib/models/user_profile.dart`.

**What you'll learn:** Firestore reads/writes, Riverpod `StreamProvider`, data models.

---

### Task 4: Fitness Level & Goals Selector
| Field | Details |
|-------|---------|
| **Branch** | `feat/fitness-goals-selector` |
| **Difficulty** | Medium |
| **Owner** | Aaditya Panjabi |
| **Files** | `lib/features/profile/profile_tab.dart` |

**What to do:** Add a bottom sheet in the Profile tab that lets users select their fitness level (beginner / intermediate / advanced) and goals (lose fat / build muscle / maintain / recomp) using `ChoiceChip` widgets. Save selections to the `UserProfile` document in Firestore. Coordinate with Task 3 owner since this depends on profile persistence.

**What you'll learn:** Bottom sheets, `ChoiceChip` widgets, Firestore updates.

---

### Task 5: Wire "Generate Plan" Button
| Field | Details |
|-------|---------|
| **Branch** | `feat/wire-generate-plan` |
| **Difficulty** | Medium |
| **Owner** | _unclaimed_ |
| **Files** | `lib/features/today/today_tab.dart`, create `lib/providers/plan_provider.dart` |

**What to do:** The Today tab has a "Generate Plan" button that doesn't do anything. Wire it to call `POST /api/plan/generate` via the existing `ApiClient`. Display the returned plan items in a `ListView`. The `DailyPlan` and `PlanItem` models already exist in `lib/models/daily_plan.dart`. Also load today's plan from Firestore on tab open if one already exists.

**What you'll learn:** HTTP requests, async state management, `FutureProvider`, list rendering.

---

### Task 6: Facility Usage UI Polish
| Field | Details |
|-------|---------|
| **Branch** | `feat/facility-usage-polish` |
| **Difficulty** | Easy–Medium |
| **Owner** | _unclaimed_ |
| **Files** | `lib/features/today/today_tab.dart` |

**What to do:** The facility usage data is displayed but needs polish. Add a `LinearProgressIndicator` showing `currentCount / maxCapacity` as a percentage bar (green < 50%, yellow 50–80%, red > 80%). Show "Updated X min ago" relative timestamps instead of raw data. Add a manual refresh button.

**What you'll learn:** Custom widgets, conditional styling, `intl` package for date formatting.

---

### Task 7: Onboarding Flow
| Field | Details |
|-------|---------|
| **Branch** | `feat/onboarding-flow` |
| **Difficulty** | Hard |
| **Owner** | _unclaimed_ |
| **Files** | Create `lib/features/onboarding/onboarding_screen.dart`, update `lib/shared/routing/router.dart` |

**What to do:** Build a 3-step onboarding screen using `PageView`: (1) Welcome + fitness level, (2) Goal selection, (3) Workout split preference (PPL / Upper-Lower / Full Body / Bro Split). On completion, save to Firestore and route to home. Add a GoRouter redirect so first-time users (no `UserProfile` doc) go to onboarding. This is a bigger task — consider pairing up.

**What you'll learn:** `PageView`, multi-step forms, GoRouter redirects, Firestore writes.

---

### Task 8: Dark Mode Toggle
| Field | Details |
|-------|---------|
| **Branch** | `feat/dark-mode` |
| **Difficulty** | Easy–Medium |
| **Owner** | _unclaimed_ |
| **Files** | `lib/shared/theme/theme.dart`, `lib/features/profile/profile_tab.dart`, `lib/app/app.dart` |

**What to do:** Create a `darkTheme` in the existing Purdue theme file (dark background with gold accents). Add a toggle switch in the Profile tab that switches between light/dark/system. Store the preference using `SharedPreferences` and wire it into `MaterialApp.router`'s `themeMode`. You'll need to add the `shared_preferences` package.

**What you'll learn:** Theming, `SharedPreferences`, `StateProvider`, Material 3 color schemes.

---

### Task 9: Chat UI Improvements
| Field | Details |
|-------|---------|
| **Branch** | `feat/chat-ui-improvements` |
| **Difficulty** | Medium |
| **Owner** | _unclaimed_ |
| **Files** | `lib/features/chat/chat_tab.dart` |

**What to do:** Improve the chat tab: (1) Add styled message bubbles with different colors for user vs assistant, (2) Add a typing indicator (animated dots) while waiting for the AI response, (3) Auto-scroll to the bottom on new messages, (4) Add a disclaimer footer text: "Gemini can make mistakes. Verify important info."

**What you'll learn:** `ListView`, `ScrollController`, `AnimationController`, custom widget design.

---

## TypeScript Task (Backend)

### Task 10: ICS Import Endpoint
| Field | Details |
|-------|---------|
| **Branch** | `feat/ics-import` |
| **Difficulty** | Medium |
| **Owner** | _unclaimed_ |
| **Files** | `functions/src/routes/schedule.ts`, `packages/shared/src/schemas.ts` |

**What to do:** Implement the `POST /api/schedule/import-ics` endpoint that currently returns 501. Use the `ical.js` npm package to parse an ICS string, extract `VEVENT` entries, map them to `ScheduleBlock` objects (title from `SUMMARY`, day from `DTSTART`, times from `DTSTART`/`DTEND`), validate with Zod, and batch-write to Firestore under `users/{uid}/scheduleBlocks/`. Write unit tests. This is a **TypeScript/Node.js** task — no Flutter needed.

**What you'll learn:** Express route handlers, ICS parsing, Zod validation, Firestore batch writes.

---

## Task Dependencies

```
Task 3 (Profile Persistence) ──► Task 4 (Fitness Goals) ──► Task 7 (Onboarding)
                                                              │
Task 5 (Generate Plan) ◄────────────────────────────────────────┘ (uses profile data)

All other tasks are independent and can be done in parallel.
```

**Recommended pairing:**
- Tasks 3 & 4 should coordinate (same Firestore document).
- Task 7 builds on Tasks 3 & 4 — start it after those are merged.
- All other tasks can run in parallel with no conflicts.

## Status Legend

| Status | Meaning |
|--------|---------|
| _unclaimed_ | Available — claim it! |
| **In Progress** (Name) | Someone is working on it |
| **In Review** (Name) | PR is open, awaiting review |
| **Done** | Merged into `dev` |
