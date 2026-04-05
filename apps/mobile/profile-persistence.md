# Profile Persistence (Firestore) — Implementation Notes

## Branch
`feat/profile-persistence` (but building on `feat/onboarding-flow` since it depends on that work)

## Task Summary
Wire the profile tab to display real Firestore data from the `userProfileProvider` (created in the onboarding task). Replace hardcoded values with live data. Add a Workout Split tile. Display-only — no editing.

---

## Files to Modify

| Action | File | Notes |
|--------|------|-------|
| Modify | `lib/features/profile/profile_tab.dart` | Wire to `userProfileProvider`, display real data, add workout split tile |
| Reuse  | `lib/providers/user_profile_provider.dart` | Already created in onboarding task — no new provider file needed |
| Reuse  | `lib/models/user_profile.dart` | Already has `workoutSplit` field from onboarding task |

---

## What Already Exists (from Onboarding Task)

- `userProfileProvider` — `StreamProvider<UserProfile?>` that listens to `users/{uid}` in Firestore
- `userProfileServiceProvider` — `Provider<UserProfileService>` with `createProfile()` and `updateProfile()`
- `UserProfile` model — has `fitnessLevel`, `goals`, `workoutSplit`, `preferredFacilities`
- Profile creation happens during onboarding — no auto-creation at sign-in needed

---

## Profile Tab Changes

### Current state (hardcoded):
- Fitness Level → always shows "Beginner"
- Goals → always shows "Tap to set fitness goals"
- Preferred Facilities → always shows "CoRec"
- No workout split tile

### Target state (Firestore-driven, display only):
- Watch `userProfileProvider` for real-time data
- Handle loading state (show shimmer or progress indicator)
- Handle null profile (shouldn't happen if onboarding works, but show fallback)
- **Fitness Level** → display `profile.fitnessLevel` (capitalize first letter)
- **Goals** → display `profile.goals.join(', ')` with human-readable labels, or "No goals set" if empty
- **Workout Split** → NEW tile, display human-readable split name, or "Not set" if null
- **Preferred Facilities** → display `profile.preferredFacilities.join(', ')` or "None set"
- All tiles remain tappable (for future editing) but TODOs stay

### Display label mappings:

**Fitness Level:**
- `beginner` → "Beginner"
- `intermediate` → "Intermediate"
- `advanced` → "Advanced"
- `athlete` → "Athlete"

**Goals (stored as snake_case keys):**
- `lose_weight` → "Lose Weight"
- `build_muscle` → "Build Muscle"
- `improve_endurance` → "Improve Endurance"
- `stay_active` → "Stay Active"
- `improve_flexibility` → "Improve Flexibility"

**Workout Split:**
- `ppl` → "Push / Pull / Legs"
- `upper_lower` → "Upper / Lower"
- `full_body` → "Full Body"
- `bro_split` → "Bro Split"
- `null` → "Not set"

---

## Key Decisions

1. **No new provider file** — reuse `user_profile_provider.dart` from onboarding task
2. **Display only** — no edit dialogs/sheets, just show Firestore data
3. **Show workout split** — new ListTile between Goals and Preferred Facilities
4. **No auto-creation** — onboarding handles profile creation; if profile is null, show fallback UI
5. **Profile header** — continue using Firebase Auth user for name/email/photo (since those come from Google Sign-In, not Firestore)

---

## Implementation Progress

- [x] **Profile tab wired to Firestore** — watches `userProfileProvider`, uses `.when()` for loading/error/data states
- [x] **Label maps** — `_fitnessLevelLabels`, `_goalLabels`, `_splitLabels` convert snake_case keys to human-readable display strings
- [x] **Workout Split tile added** — new ListTile with `Icons.calendar_view_week`, between Goals and Preferred Facilities
- [x] **Null/empty handling** — "Not set" for missing fitness level or workout split, "No goals set" for empty goals, "None set" for empty facilities
- [x] **Compile check** — `flutter analyze` passes with 0 new issues
- [x] **No new files created** — reused `user_profile_provider.dart` from onboarding task

---

## Notes

- The profile header (avatar, name, email) still reads from `FirebaseAuth.currentUser`, not Firestore. This is intentional — those values come from Google Sign-In and stay in sync automatically.
- The TODO comments on each ListTile's `onTap` are preserved for future editing features.
- Goals are displayed as a comma-separated string with human-readable labels (e.g., "Build Muscle, Lose Weight") in priority order (matching the order set during onboarding).
