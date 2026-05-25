# SkillSwap Progress

## 2026-05-25

### Setup Notes
- Created a `doc/` folder to track project progress.
- Inspected the three Stitch UI export ZIP files in `references/`.
- Treated the Stitch exports as visual reference only and did not copy generated HTML.
- Flutter was not installed on the machine at the start of the task.
- Java 17 and Android platform tools are present.
- Installed a user-local Flutter SDK at `/home/dawit/tools/flutter` because system snap installation required sudo authentication.
- Added `/home/dawit/tools/flutter/bin` to `~/.bashrc` so new interactive terminals can run `flutter` and `dart`.
- Installed Android SDK command-line tools into `/home/dawit/Android/Sdk/cmdline-tools/latest`.
- Accepted Android SDK licenses with `flutter doctor --android-licenses`.
- Installed Google's Android CLI into `~/.local/bin/android`.

### Visual Direction From References
- Warm off-white app background with white interactive cards.
- Deep teal/green for brand, navigation, and primary surfaces.
- Gold accent for highlighted actions, match badges, and selected navigation states.
- Rounded cards, pill chips, compact bottom navigation, and clear student skill cards.
- Demo should stay clean, student-focused, and easy to explain.

### First Task Scope
- Create the Flutter project structure.
- Add a reusable design system:
  - `app_colors.dart`
  - `app_theme.dart`
  - reusable buttons
  - reusable cards
  - reusable chips
  - bottom navigation shell
  - mock data files
  - simple routing
- Firebase is intentionally not connected yet.
- Full feature pages are intentionally left for later steps.

### Completed Foundation
- Generated a Flutter app scaffold for Android, iOS, web, and Linux.
- Added app theme and color tokens from the requested SkillSwap palette.
- Added reusable buttons, cards, skill chips, and status chips.
- Added a bottom navigation shell with Home, Discover, Swaps, Messages, and Profile tabs.
- Added placeholder routes for profile setup, add skill, request swap, chat, and review session.
- Added mock student, skill, and swap request data.
- Replaced the default counter test with a SkillSwap shell smoke test.

### Verification
- `flutter analyze` passed with no issues.
- `flutter test` passed.
- `flutter build apk --debug` passed and produced `build/app/outputs/flutter-apk/app-debug.apk`.
- `flutter doctor -v` shows Android toolchain, Chrome, connected devices, and network resources are ready.
- Remaining doctor issue: optional Linux desktop development packages are missing (`clang++`, `cmake`, `libgtk-3-dev`). These require sudo/apt and are not needed for Android or Chrome web runs.
