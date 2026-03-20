<<<<<<< HEAD
# task_tracker_application

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
=======
# task_tracker
>>>>>>> fb2ce822cfe65de453b844d360245ccc4122e28a
>>>>>>>
# Offline-First Task Tracker

## 1. App Overview
A Flutter app to manage personal tasks that works completely offline. Tasks are stored locally using Hive and persist across app restarts. A fake sync mechanism simulates backend sync with dirty state tracking — if a task is edited after sync, it is marked as unsynced automatically.

**Main Features:**
- Add, edit, delete tasks
- Mark tasks as Pending or Completed
- Offline persistence with Hive
- Fake sync with 2 second delay
- Dirty state tracking (unsynced badge per task)
- Empty, loading, and error states handled

---

## 2. Screens Implemented

- **Task List Screen** — Shows all tasks sorted by latest update. Has a Sync button in AppBar with orange dot when unsynced changes exist. Shows summary bar with task count and unsynced warning.
- **Add/Edit Task Screen** — Form with title (required) and description (optional). Validates empty title. Same screen used for both add and edit.

---

## 3. Data Model
```
Task {
  id            → unique identifier (UUID v4)
  title         → required task name
  description   → optional details
  status        → 'pending' | 'completed'
  lastUpdatedAt → timestamp of last change (updated on every edit)
  lastSyncedAt  → timestamp of last successful sync (null if never synced)
  isDirty       → true if edited after last sync, false after sync
}
```

**Why these fields:**
- `isDirty` tracks whether a task needs to be synced again after an edit
- `lastSyncedAt` tells the user when data was last synced
- `lastUpdatedAt` is used to sort tasks — latest on top

---

## 4. Architecture
```
lib/
  models/         → TaskModel (Hive entity + generated adapter)
  services/       → HiveService (all read/write DB operations)
  providers/      → TaskProvider (business logic + state management)
  ui/
    screens/      → TaskListScreen, AddEditTaskScreen
    widgets/      → TaskTile, EmptyStateWidget
  main.dart       → App entry point, Provider + Hive setup
```

**Separation of concerns:**
- `models` — pure data, no logic
- `services` — only talks to Hive, no UI
- `providers` — all business logic, no widgets
- `ui` — only displays data, calls provider methods

---

## 5. State Management

**Used: Provider**

**Why Provider:**
- App has a single data domain (tasks) with simple CRUD + sync
- No complex async streams or multiple nested states
- `ChangeNotifier` + `Consumer` is clean and easy to read
- BLoC would be overkill for this scale
- Riverpod adds unnecessary complexity for a 2-screen app

**How UI reacts:**
- `Consumer<TaskProvider>` rebuilds only when `notifyListeners()` is called
- Loading, error, empty, and data states are all handled inside one `Consumer`

---

## 6. Local Storage

**Used: Hive**

**Why Hive:**
- Flutter-native, no native platform setup needed
- Faster than SQLite for simple key-value object storage
- Type-safe with code generation (`@HiveType`, `@HiveField`)
- Works fully offline with zero configuration

**How tasks are handled:**
- On app start → `HiveService.getAllTasks()` loads all tasks from box
- On add/edit/delete → written to Hive immediately (no delay)
- On sync → all tasks updated with `lastSyncedAt` and `isDirty = false`
- Data survives app kills because Hive writes to disk on every operation

---

## 7. Sync Logic

1. User taps the **Sync** button in AppBar
2. UI shows a loading spinner (2 second simulated network delay)
3. After delay — all tasks get:
   - `lastSyncedAt = DateTime.now()`
   - `isDirty = false`
4. Green cloud icon appears for 2 seconds then resets
5. If user edits any task after sync → `isDirty = true` automatically
6. Orange dot on Sync button and "Unsynced changes" banner appear

**Dirty state flow:**
```
Add/Edit task → isDirty = true  → orange badge shown
Press Sync   → isDirty = false → green badge shown
Edit again   → isDirty = true  → orange badge shown again
```

---

## 8. Error Handling

| Situation | Behaviour |
|---|---|
| Storage read fails | Error message shown with Retry button |
| Storage write fails | Error message shown via provider errorMessage |
| No tasks exist | Friendly empty state with "Tap + to add your first task" |
| Sync fails | Red cloud icon shown for 2 seconds, then resets to idle |
| Empty title submitted | Form validation blocks submission with inline error |

---

## 9. Known Limitations

- No real backend — sync is fully simulated with `Future.delayed`
- No task filtering, search, or sorting options
- No due dates or priority levels
- No categories or tags
- Sync does not handle partial failures (all or nothing)
- With more time: add real REST API sync, search/filter, due dates, and notifications

---

## 10. How to Run
```bash
# 1. Clone the repo
git clone https://github.com/Shailesh4056/task_tracker.git
cd task_tracker

# 2. Install dependencies
flutter pub get

# 3. Generate Hive adapters
dart run build_runner build --delete-conflicting-outputs

# 4. Run the app
flutter run
```

**Requirements:**
- Flutter SDK 3.x
- Dart SDK 3.x
- Android/iOS device or emulator

---

## 11. External References

| Package | Version | Why Used |
|---|---|---|
| [hive_flutter](https://pub.dev/packages/hive_flutter) | ^1.1.0 | Offline-first local storage |
| [provider](https://pub.dev/packages/provider) | ^6.1.2 | Lightweight state management |
| [uuid](https://pub.dev/packages/uuid) | ^4.4.2 | Generate unique task IDs |
| [intl](https://pub.dev/packages/intl) | ^0.19.0 | Format timestamps in task tiles |
| [hive_generator](https://pub.dev/packages/hive_generator) | ^2.0.1 | Auto-generate Hive type adapters |
| [build_runner](https://pub.dev/packages/build_runner) | ^2.4.13 | Run code generation |
| [flutter_screenutil](https://pub.dev/packages/flutter_screenutil) | ^5.9.3 | Responsive UI sizing |

No tutorials or templates were copied. All logic was written from scratch.
