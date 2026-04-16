# Onboarding Flow — Implementation Notes

## Branch
`feat/onboarding-flow`

## Task Summary
Build a 3-step onboarding screen using PageView. On completion, write UserProfile to Firestore and route to home. Block first-time users (no UserProfile doc) via GoRouter redirect.

---

## Files to Create / Modify

| Action | File |
|--------|------|
| Create | `lib/features/onboarding/onboarding_screen.dart` |
| Create | `lib/providers/user_profile_provider.dart` |
| Modify | `lib/models/user_profile.dart` |
| Modify | `lib/shared/routing/router.dart` |

---

## Data Model Changes — UserProfile

Add two fields to `lib/models/user_profile.dart`:

```dart
final String? workoutSplit;   // 'ppl' | 'upper_lower' | 'full_body' | 'bro_split'
// goals: List<String> already exists — store in PRIORITY ORDER (index 0 = rank 1)
```

- `workoutSplit` is nullable (null before onboarding completes)
- `goals` list is reused but now has semantic ordering (priority by index)
- Update `fromJson`, `toJson`, and constructor accordingly

### Why string for workoutSplit (not enum):
The user said "easiest to pull for production and future customization." A plain string stored in Firestore is easiest to query/filter without needing client-side enum mapping. In the future, a Cloud Function can branch on this value directly.

---

## Firestore Schema

```
users/{uid}                         ← UserProfile document
  ├── uid: string
  ├── displayName: string
  ├── email: string
  ├── photoUrl: string?
  ├── fitnessLevel: string           (beginner | intermediate | advanced | athlete)
  ├── goals: string[]                (ordered by priority, index 0 = rank 1)
  ├── workoutSplit: string?          (ppl | upper_lower | full_body | bro_split)
  ├── preferredFacilities: string[]
  ├── createdAt: string
  └── updatedAt: string
  ├── scheduleBlocks/{blockId}
  └── plans/{dateId}
```

---

## Step Definitions

### Step 1 — Welcome + Fitness Level
- Heading: "Welcome to Purdue Personal Trainer"
- Subtext: brief app description
- Fitness level: **single-select** using tappable cards
- Options: `beginner`, `intermediate`, `advanced`, `athlete`
- Display labels: "Beginner", "Intermediate", "Advanced", "Athlete"
- Next button disabled until a level is selected

### Step 2 — Goal Selection (multi-select + ranked)
- Heading: "What are your fitness goals?"
- Subtext: "Tap to select. Your first tap is your top priority."
- Goals list:
  - `lose_weight` → "Lose Weight"
  - `build_muscle` → "Build Muscle"
  - `improve_endurance` → "Improve Endurance"
  - `stay_active` → "Stay Active"
  - `improve_flexibility` → "Improve Flexibility"
- UX: **Numbered tap order** — tapping assigns rank badge (1, 2, 3...). Tapping again deselects and re-adjusts ranks.
- Stored as: `['lose_weight', 'build_muscle', ...]` (priority order, index = rank - 1)
- Next button disabled until at least 1 goal is selected

### Step 3 — Workout Split
- Heading: "How do you like to train?"
- Subtext: brief description of what a split is
- Options (single-select cards):
  - `ppl` → "Push / Pull / Legs"
  - `upper_lower` → "Upper / Lower"
  - `full_body` → "Full Body"
  - `bro_split` → "Bro Split"
- Each card should have a short description (e.g., "PPL: Chest/shoulders/triceps, back/biceps, legs")
- Finish button disabled until a split is selected

---

## Onboarding Screen Architecture

```dart
// onboarding_screen.dart
class OnboardingScreen extends ConsumerStatefulWidget { ... }
class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController;
  int _currentPage = 0;

  // Local state held until final submission
  String? _fitnessLevel;
  List<String> _rankedGoals = [];   // ordered by tap sequence
  String? _workoutSplit;

  void _nextPage() { ... }
  void _previousPage() { ... }
  Future<void> _submit() { ... }    // writes to Firestore, then routes to /home
}
```

- Use `PageView` with `NeverScrollableScrollPhysics` (disable swipe — only nav buttons move pages)
- Show a progress indicator (e.g., 3 dots or "Step X of 3") at the top
- Back button on steps 2 and 3 (not on step 1)
- All state is local until final submit on step 3

---

## UserProfile Provider

Create `lib/providers/user_profile_provider.dart`:

```dart
// Stream of the current user's profile doc
final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((snap) => snap.exists ? UserProfile.fromJson(snap.data()!) : null);
});

// Service for Firestore writes
final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  return UserProfileService();
});

class UserProfileService {
  Future<void> createProfile(UserProfile profile) { ... }
  Future<void> updateProfile(String uid, Map<String, dynamic> fields) { ... }
}
```

---

## Router Changes

### New route:
```dart
GoRoute(
  path: '/onboarding',
  name: 'onboarding',
  builder: (context, state) => const OnboardingScreen(),
),
```

### Updated redirect logic:
The redirect needs to handle 3 states:
1. **Not logged in** → `/login`
2. **Logged in, no UserProfile doc** → `/onboarding`
3. **Logged in, has UserProfile** → allow (or redirect away from `/login` / `/onboarding`)

**Critical gotcha**: GoRouter's `redirect` runs synchronously, but checking Firestore is async. Solve this by:
- Watching `userProfileProvider` (a StreamProvider) in the router provider
- The router provider already watches `authStateProvider` — add `userProfileProvider` alongside it
- While `userProfileProvider` is loading (`AsyncLoading`), return `null` (no redirect) to avoid flickering
- Only redirect to `/onboarding` when the value is `AsyncData(null)` (stream resolved but doc is null)

```dart
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final profileState = ref.watch(userProfileProvider);

  return GoRouter(
    refreshListenable: ...,  // need to trigger refresh when either stream changes
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isOnLogin = state.matchedLocation == '/login';
      final isOnOnboarding = state.matchedLocation == '/onboarding';

      if (!isLoggedIn && !isOnLogin) return '/login';
      if (isLoggedIn && isOnLogin) return '/onboarding'; // always check profile first

      if (isLoggedIn && !isOnLogin) {
        // Still loading profile — don't redirect yet
        if (profileState is AsyncLoading) return null;

        final hasProfile = profileState.valueOrNull != null;
        if (!hasProfile && !isOnOnboarding) return '/onboarding';
        if (hasProfile && isOnOnboarding) return '/home';
      }

      return null;
    },
    ...
  );
});
```

**Note on refreshListenable**: GoRouter needs a `Listenable` to know when to re-run `redirect`. Since we're using Riverpod, the cleanest approach is to use a `RouterNotifier` pattern — a `ChangeNotifier` that watches the Riverpod providers and calls `notifyListeners()` when they change. See go_router + riverpod redirect pattern.

---

## On Completion (Submit)

When user taps "Finish" on step 3:
1. Show loading indicator
2. Get current Firebase Auth user
3. Write to `users/{uid}`:
   ```dart
   UserProfile(
     uid: user.uid,
     displayName: user.displayName ?? user.email ?? 'Purdue Student',
     email: user.email!,
     photoUrl: user.photoURL,
     fitnessLevel: _fitnessLevel!,
     goals: _rankedGoals,
     workoutSplit: _workoutSplit,
     preferredFacilities: [],
     createdAt: DateTime.now().toIso8601String(),
     updatedAt: DateTime.now().toIso8601String(),
   )
   ```
4. `userProfileProvider` stream fires → router redirect picks it up → navigates to `/home` automatically
   - Do NOT manually call `context.go('/home')` — let the router redirect handle it to avoid race conditions

---

## Key Things to Watch Out For

1. **Router refresh**: GoRouter won't re-run `redirect` unless told to. Need `RouterNotifier` with `ref.listen` on both `authStateProvider` and `userProfileProvider`.

2. **Swipe disabled on PageView**: Use `NeverScrollableScrollPhysics` — steps have required fields, user must interact before advancing.

3. **Goal deselection re-ranking**: When a user taps a selected goal to deselect, ranks of remaining goals must compress (no gaps). E.g., if rank-2 goal is deselected, the old rank-3 becomes rank-2.

4. **Null safety on submit**: All three fields (`_fitnessLevel`, `_rankedGoals`, `_workoutSplit`) are validated before the Finish button is enabled, so force-unwrapping is safe at submit time.

5. **Firestore write timestamp**: Use `DateTime.now().toIso8601String()` for consistency with the existing model (createdAt/updatedAt are strings, not Timestamps).

6. **UserProfile.fromJson null-safety**: `workoutSplit` is nullable — `json['workoutSplit'] as String?` (no default).

7. **Loading state during redirect**: The first render after login will show a brief loading state while `userProfileProvider` resolves. Handle this gracefully (e.g., full-screen loading widget in the router's `errorBuilder` or a dedicated loading route).

8. **Emulator testing**: Sign in with emulator → no UserProfile doc → should redirect to onboarding. After completing onboarding, doc is created → redirect to home. Verify this full flow.

---

## Workout Split Descriptions (for UI cards)

| Value | Label | Description |
|-------|-------|-------------|
| `ppl` | Push / Pull / Legs | Push: chest, shoulders, triceps. Pull: back, biceps. Legs: quads, hamstrings, glutes. |
| `upper_lower` | Upper / Lower | Alternate upper body and lower body days. |
| `full_body` | Full Body | Train all major muscle groups each session. |
| `bro_split` | Bro Split | One muscle group per day (chest day, arm day, etc.) |

---

## Dependencies Already Available
- `cloud_firestore: ^5.5.0` ✓
- `flutter_riverpod: ^2.6.0` ✓
- `go_router: ^14.6.0` ✓
- No new packages needed

---

## Implementation Progress

- [x] **Task 1**: Update `UserProfile` model — added `workoutSplit: String?` field, updated constructor, `fromJson`, `toJson`
- [x] **Task 2**: Create `user_profile_provider.dart` — `StreamProvider<UserProfile?>` for real-time doc watching, `UserProfileService` for create/update
- [x] **Task 3**: Build `onboarding_screen.dart` — 3-step PageView with fitness level cards, numbered-tap goal ranking, workout split selection. Submits to Firestore via `UserProfileService`.
- [x] **Task 4**: Update `router.dart` — added `/onboarding` route, `_RouterNotifier` (ChangeNotifier listening to both auth + profile providers), redirect logic: not logged in → `/login`, logged in + no profile → `/onboarding`, logged in + has profile → `/home`
- [x] **Compile check**: `flutter analyze` passes with 0 new issues (3 pre-existing warnings unrelated to onboarding)
- [x] **Task 5**: Add `WorkoutSplit` Zod enum to `packages/shared/src/schemas.ts` — `z.enum(["ppl", "upper_lower", "full_body", "bro_split"])`, added as optional field on `UserProfile` schema. Also added `"athlete"` to `FitnessLevel` enum for consistency with the onboarding UI. Exported `WorkoutSplit` and `WorkoutSplitType` from `index.ts`.
- [x] **Task 6**: Update `functions/src/services/plan-generator.ts` — `buildWorkoutItem` now checks `profile.workoutSplit`. If set, uses `getWorkoutForSplit()` which maps split + fitness level to a descriptive activity string. If not set (legacy profiles), falls back to `getFallbackWorkout()` which preserves old behavior. Also added `"athlete"` tier to intensity labels.
- [x] **Build check**: Both `packages/shared` and `functions` compile cleanly with `tsc`

---

## Considerations Discovered During Implementation

1. **Router creates a new GoRouter instance on every provider rebuild.** This is the existing pattern in the codebase. The `_RouterNotifier` + `refreshListenable` ensures redirect re-runs when streams change, but a GoRouter instance is also recreated when Riverpod invalidates the provider (since `ref.watch` is used). This is fine for correctness but slightly wasteful. Not changing it since it matches the existing pattern.

2. **Loading state gap after login.** When a user logs in, `authStateProvider` fires immediately but `userProfileProvider` takes a round-trip to Firestore. During this gap, the redirect sends the user to `/onboarding` briefly (since `isLoading` is true when first subscribed, but quickly resolves). To handle this: when profile is loading AND user just logged in, we redirect to `/onboarding` (which will then auto-redirect to `/home` once profile loads). This avoids the user seeing the home screen flash before being redirected.

3. **`uid` field in Firestore doc.** The `UserProfile.fromJson` expects a `uid` field, but Firestore doc IDs are not stored inside the doc data by default. In `user_profile_provider.dart`, we inject `'uid': snap.id` into the JSON before parsing. The `UserProfileService.createProfile` writes the full `toJson()` which includes `uid` in the doc body — slightly redundant with the doc ID but consistent with the existing model contract.

4. **Goal deselection is naturally handled.** Using `List.remove()` on `_rankedGoals` automatically compresses the list — remaining goals shift left, so rank numbers stay gapless. The `ListView` rebuilds with correct `indexOf` values.

5. **No `context.go('/home')` after submit.** The `_submit` method writes to Firestore and lets the `userProfileProvider` stream detect the new doc, which triggers `_RouterNotifier.notifyListeners()`, which triggers GoRouter's `redirect`, which sees `hasProfile = true` + `isOnOnboarding = true` and redirects to `/home`. This avoids race conditions.

6. **Firestore rules.** Verified — the existing `firestore.rules` already allows authenticated users to read/write their own `users/{userId}` doc (line 9). No changes needed.

7. **FitnessLevel enum mismatch.** The shared schema had `["beginner", "intermediate", "advanced"]` but the onboarding UI includes `"athlete"`. Fixed by adding `"athlete"` to the Zod enum. This is backwards-compatible since existing profiles won't have `"athlete"` set.

8. **Plan generator backwards compatibility.** The `buildWorkoutItem` function previously used a simple `Record<string, string>` keyed by `fitnessLevel`. Now it checks `workoutSplit` first and falls back to the old behavior if absent. Existing users without `workoutSplit` will see no change in their generated plans.
