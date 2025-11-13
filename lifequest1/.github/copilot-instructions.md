# LifeQuest Platinum AI Assistant Instructions

## Project Overview

LifeQuest Platinum is a Flutter-based mobile application project targeting multiple platforms (iOS,
Android, web, desktop). The project follows standard Flutter architecture and conventions.

# LifeQuest Platinum — AI Assistant Instructions

Short, actionable guidance to help an AI coding assistant be productive in this repo.

## High-level architecture (what you'll see)

- Multi-platform Flutter app (mobile, web, desktop).
- Provider-based state layer: `lib/providers/` (e.g. `GoalsProvider`).
- Plain Dart data models in `lib/models/` (e.g. `Goal`).
- UI split into `lib/screens/` and reusable widgets in `lib/widgets/`.
- Platform-specific glue lives under `android/`, `ios/`, `web/`, `windows/`, etc.

Key files to glance at first:

- `lib/main.dart` — app entry, wires providers and themes.
- `lib/models/goal.dart` — canonical Goal data shape and JSON helpers.
- `lib/providers/goals_provider.dart` — source of truth for goals, exposes CRUD and progress
  updates.
- `lib/screens/home_screen.dart` — tabbed list UI; FAB opens the goal editor.

## Local dev / workflows (verified from repo)

- Install deps and run the app:

```powershell
cd "c:\Users\wsk\Documents\LifeQuest Platinum\lifequest1"
flutter pub get
flutter run
```

- Run tests (unit/provider tests exist in `test/`):

```powershell
flutter test
```

- VS Code launch configs are in `.vscode/launch.json` (there's a Flutter target and a test runner).
  A `flutterfire configure` entry is present in the file but Firebase isn't wired up yet.

## Project-specific conventions and patterns (concrete)

- State: use `ChangeNotifier` providers and `Provider`/`Consumer` in widgets. Example:
  `GoalsProvider` in `lib/providers`.
- Models: keep simple POJO-like classes with `toJson/fromJson` (see `Goal`).
- Navigation: use `Navigator.push(MaterialPageRoute(...))` between screens (see `HomeScreen` ->
  `GoalDetailScreen` / `GoalEditScreen`).
- UI: one screen widget per file under `lib/screens/`. Small reusable components go into
  `lib/widgets/`.
- Persistence/backends: currently none; add services in `lib/services/` and inject them from
  providers when integrating Firebase or other stores.

## Integration & external dependencies

- Flutter SDK ^3.9.2 (check `pubspec.yaml` environment).
- Provider is used for state management (dependency added to `pubspec.yaml`).
- Utilities: `uuid`, `intl` are present / available for use.
- Firebase is planned but not configured — you'll see a `flutterfire configure` hint in
  `.vscode/launch.json`.

## Small examples (copyable patterns)

- Add a goal via provider (from `GoalEditScreen`):

```dart
final provider = Provider.of<GoalsProvider>(context, listen: false);
provider.addGoal(Goal(title: 'T', description: 'D'));
```

- Update progress:

```dart
provider.updateGoalProgress(goalId, 0.5);
```

- Navigate to detail:

```dart
Navigator.of(context).push(MaterialPageRoute(builder: (_) => GoalDetailScreen(goalId: id)));
```

## Where to look next (recommended immediate work)

1. Implement persistent storage (Firebase/SQLite) under `lib/services/` and wire it into
   `GoalsProvider`.
2. Add onboarding / auth (Firebase Auth) and user-scoped data.
3. Add more tests (widget/integration) and CI (GitHub Actions) to run `flutter test`.

## Quick notes for AI assistants

- Preserve null-safety and existing public APIs when editing models/providers.
- Prefer small, focused PRs: add a screen + tests together.
- When adding platform code, follow the existing folder structure and use conditional imports.

If anything above is unclear or you want the AI assistant to make one of the recommended changes,
say which item and I'll implement it next.