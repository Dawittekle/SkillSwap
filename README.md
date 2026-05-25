# SkillSwap

SkillSwap is a clean Flutter demo app for peer-to-peer student skill exchange.

This first checkpoint contains the Flutter project scaffold, design system, reusable UI primitives, bottom navigation shell, simple named routes, and mock data. Firebase is not connected yet.

## Run

Open a new terminal so `~/.bashrc` loads the local Flutter SDK path:

```bash
flutter run
```

The SDK was installed locally at:

```bash
/home/dawit/tools/flutter
```

If the current terminal has not reloaded yet, use:

```bash
export PATH="$PATH:/home/dawit/tools/flutter/bin"
flutter run
```

## Verify

```bash
flutter analyze
flutter test
flutter doctor -v
```

Progress notes live in [doc/progress.md](doc/progress.md).
