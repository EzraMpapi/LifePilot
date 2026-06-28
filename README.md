# LifePilot — Iteration 1

This is the **first working iteration** of LifePilot, scoped down
deliberately from the full product brief to something that's actually
real and runnable: **Flutter Web, local storage only (no Firebase
yet)**, with a complete authentication shell and one fully-working
feature (Expense Management) built end-to-end through every
architectural layer.

## What's actually real here, and what isn't

Being upfront about this matters more than it might seem, because the
original brief asked for ~15 major modules across 6 platforms with no
placeholders anywhere — that's a multi-month, multi-engineer effort.
This iteration is honest about being a starting slice, not a shortcut
pretending to be the whole thing:

**Fully real and working:**
- Project structure (Clean Architecture / repository pattern / Riverpod DI)
- Local-only "auth" (a profile name + optional PIN, stored in Hive — no real account/password system yet)
- Dashboard shell with real navigation and real layout
- **Expense Management — completely real**, end to end: add/edit/delete,
  the 11 specified categories, search, category filtering, a real
  pie chart (fl_chart) computed from real stored data, income/expense/balance
  summary cards, local persistence via Hive
- Light and dark Material 3 themes with a deliberately custom palette/typeface
- Responsive navigation (rail on wide screens, bottom bar on narrow ones)
- Unit tests for the expense domain logic and the Hive repository

**Explicitly placeholder, labeled as such in the UI** (not faked):
Weather, today's schedule, reminders, goal progress, quick notes,
recent locations, AI suggestions, calendar preview — the dashboard
shows these as "Coming soon" cards rather than displaying invented
numbers. A fake weather reading would be actively misleading on a
screen whose whole point is to be a trustworthy daily overview.

**Not started at all yet:** Diary, Timeline, GPS location tracking,
Weekly Timetable, Reminders, Alarms, Goals, Habit Tracker, Calendar,
Notes, AI Assistant, Reports, Push notifications, global Search,
real biometric/PIN security enforcement, Settings, Firebase/Firestore,
and every platform other than Web.

## Why this scope, and how the rest gets built

Each remaining module follows the exact same pattern Expenses
demonstrates: a domain entity + repository *interface*, a Hive-backed
implementation of that interface, Riverpod providers, then the UI.
That pattern is the actual deliverable of this iteration — it's the
template every subsequent module reuses, so each new feature is a
similarly-scoped, independently testable addition rather than a
restart.

## A note on verification

I (Claude) cannot run, compile, or test Flutter code in the environment
this was written in — there's no Flutter SDK, no Dart compiler, no
device or browser to launch a build in. Everything here was written
carefully and cross-checked by hand (relative imports verified to
resolve to real files, every package import checked against
`pubspec.yaml`, brace/paren balance checked programmatically, current
package APIs checked against up-to-date documentation rather than
assumed from memory), and a couple of real mistakes were caught and
fixed *during* that process — including a `go_router`/Riverpod wiring
bug that would have silently broken navigation after sign-in, and a
`DropdownButtonFormField` API call that would have failed to compile
on the SDK version this project targets. That said, this has never
actually been run. Please treat first-run results as the real test,
and tell me exactly what error you see if `flutter pub get` or
`flutter run` surfaces one — that's the fastest way for me to fix it.

## Setup

You'll need the Flutter SDK installed (3.22+ recommended; this project's
`pubspec.yaml` declares a `3.3.0` floor). Check with:

```bash
flutter --version
```

Then, from this project's root:

```bash
flutter pub get
flutter run -d chrome
```

`-d chrome` targets Flutter Web specifically. If you have other
devices/simulators configured, `flutter devices` lists every target
Flutter can currently see.

### Running tests

```bash
flutter test
```

This runs both the pure-logic tests (`expense_entry_test.dart`,
`expense_summary_test.dart`) and the real-Hive-backed repository test
(`hive_expense_repository_test.dart`), which uses a temp directory
rather than mocking Hive.

## Project structure

```
lib/
├── main.dart                  # Entry point — initializes Hive, runs the app
├── lifepilot_app.dart          # Root widget — theme + router wiring
├── core/
│   ├── theme/                  # AppColors, AppTypography, AppTheme (light/dark)
│   ├── router/                 # go_router setup + auth-based redirect
│   ├── storage/                # Hive box initialization
│   ├── utils/                  # Formatters (currency, dates)
│   └── widgets/                # AppShell (responsive nav scaffold)
└── features/
    ├── auth/
    │   ├── domain/              # AppUser entity, AuthRepository interface
    │   ├── data/                # LocalAuthRepository (Hive-backed)
    │   └── presentation/        # AuthController (Riverpod), SignInScreen
    ├── dashboard/
    │   └── presentation/        # DashboardScreen + its widgets
    └── expenses/                # The full reference vertical slice
        ├── domain/              # ExpenseEntry, ExpenseCategory, ExpenseRepository interface
        ├── data/                # HiveExpenseRepository
        └── presentation/        # Providers, ExpensesScreen, form/list/chart widgets
test/
└── features/expenses/          # Unit tests for the one complete feature
```

## The Firebase-swap seam, explained

Every feature's domain layer defines a repository *interface*
(`AuthRepository`, `ExpenseRepository`) that the rest of the app
depends on — never the concrete Hive implementation directly. When
Firebase gets added:

1. Create `lib/features/expenses/data/firestore_expense_repository.dart`
   implementing `ExpenseRepository` exactly as `HiveExpenseRepository` does.
2. Change one line — `expenseRepositoryProvider`'s body — from
   `HiveExpenseRepository()` to `FirestoreExpenseRepository()`.
3. Nothing in `presentation/` or any UI file changes at all.

The same pattern applies to `AuthRepository` for swapping in real
Firebase Auth (email/Google/Apple/phone) later.

## Design notes

The visual direction is deliberately *not* generic Material blue — see
`lib/core/theme/app_colors.dart`'s doc comment for the reasoning. The
palette is an ink/slate + warm amber pairing (a "well-kept personal
planner," not a corporate SaaS dashboard), typeset in Fraunces (display)
+ Inter (body) rather than default Roboto. The dashboard's date header
is this iteration's signature element — it's meant to read like the
top of a page in a paper planner.

## Known rough edges in this iteration

- The "auth" is not real authentication — no password, no server, just
  a local display name. This is clearly disclosed in the sign-in
  screen's UI copy, not hidden.
- `ExpenseRepository.watchAll()`'s Hive-backed stream re-reads and
  re-sorts the *entire* box on every change. Fine at the data volumes
  a personal expense tracker actually has; would need revisiting if
  this pattern were reused somewhere with thousands of frequently-
  updated records.
- No currency/locale selection yet (hardcoded to a generic format in
  `Formatters`) — flagged clearly in that file as the seam to extend
  once Settings exists.
