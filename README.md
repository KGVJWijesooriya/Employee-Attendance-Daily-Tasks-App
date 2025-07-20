# Employee Attendance & Daily Tasks App

## Portfolio

Visit my portfolio: [https://jayasanka.com/](https://jayasanka.com/)

## Objective

A Flutter app for employees to log attendance (Check In/Out) and manage daily tasks. Supports both Web and APK builds.

## Features & Interactions

### Attendance Log

- **Name Entry:** Enter your name once; persists across sessions.
- **Check-In/Check-Out:** Record timestamps in device local time.
- **Today’s Record:** Displays date, day name, check-in/out times, time spent, and attendance status.
- **Attendance Status:**
  - Present: Both Check-In and Check-Out exist
  - Incomplete: Only Check-In or Check-Out exists
  - Absent: No record for the day
  - On Leave: User can mark any day as On Leave in history
- **History View:** Shows all previous records, including incomplete and On Leave days.
- **Edge Case:** Previous day’s incomplete record remains visible in history.

### Daily Tasks

- **Empty List on First Launch:** No tasks initially.
- **Add Task:** Fill in Name, Due Date (date picker), Priority (Low/Medium/High), and Status (Not Started/In Progress/Done).
- **Update Status:** Change any task’s status; persists after restart.
- **Persistence:** All tasks and fields survive app restarts and hot-reloads.

### Data Persistence

- Uses `shared_preferences` for all local storage (name, attendance, tasks).

### Error Simulation (Debug)

- Hidden feature: Long-press the AppBar title on either screen to simulate a save/load error. App displays a clear error message.

### UI Expectations

- Two main screens via bottom navigation: Attendance ↔ Tasks
- Standard Flutter widgets: Scaffold, AppBar, ListView, ElevatedButton, TextField, DatePicker, DropdownButton
- Loading indicators while saving/loading
- Clear error messages (e.g., “Failed to save, please try again”)
- Usability focused; no custom theming or animations

## How to Run

1. **Install dependencies:**
   ```
   flutter pub get
   ```
2. **Run on Web:**
   ```
   flutter run -d chrome
   ```
3. **Run on Android (Device/Emulator):**
   ```
   flutter run -d android
   ```
4. **Build APK:**
   ```
   flutter build apk --release
   # Output: build/app/outputs/flutter-apk/app-release.apk
   # Rename to AttendanceTasks_YourName_YYYYMMDD.apk as required
   ```

## Design Choices

## Assumptions & Bonus Features

- Attendance and tasks are stored locally; no cloud sync.
- User can edit their name at any time from the Attendance screen.
- Bonus: "On Leave" status can be set for any day in history.
- Error simulation works on both screens via long-press AppBar title.

## Time Taken

- Total development time: 04 hours.

- **Persistence:** Chose `shared_preferences` for simplicity and reliability.
- **Error Handling:** All save/load operations are wrapped in try/catch; errors are shown in the UI.
- **Error Simulation:** Debug feature lets testers verify error UI easily.
- **UI:** Used only standard widgets for clarity and maintainability.
- **Status Logic:** Attendance status is computed exactly as required, including edge cases and bonus On Leave feature.

## Testing

- See requirements for step-by-step test scenarios. All flows (attendance, tasks, edge cases, error simulation) are supported and persist as expected.

---
