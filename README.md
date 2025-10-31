
# mytravaly_flutter_task

Flutter 3.24 (Ladybug) sample task for MyTravaly — BLoC architecture with Google Sign-In (frontend-only mock), hotel list and search + pagination.

## How to run

1. Ensure Flutter 3.24 SDK installed.
2. Open the project directory:
   ```bash
   cd mytravaly_flutter_task
   ```
3. Get dependencies:
   ```bash
   flutter pub get
   ```
4. If you want full platform folders generated, run (optional):
   ```bash
   flutter create .
   ```
   This will populate `android/` and `ios/` with platform code if they are missing.
5. Run on an emulator or device:
   ```bash
   flutter run
   ```

Notes:
- Google Sign-In is a frontend-only mock button for the assignment. No Firebase configuration included.
- The `lib/` folder contains the full app implementation (BLoC, routing, UI, API service placeholders).
