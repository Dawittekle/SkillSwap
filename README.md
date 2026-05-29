# SkillSwap

SkillSwap is a Flutter demo app for student-to-student skill exchange. Students can create a profile, add skills they can teach, add skills they want to learn, discover other students, request swaps, chat, and review completed sessions.

## Main Features

- Firebase Authentication for sign up, login, logout, and password reset
- Firestore user profiles
- Offered and wanted skills
- Discover page with search, filters, sorting, and match score
- Swap request flow
- Messages and chat
- Session reviews and ratings
- Development-only Ethiopian demo data seeding

## Firebase Services Used

- Firebase Auth
- Cloud Firestore

## Important Firestore Collections

- `users`
- `skills`
- `swapRequests`
- `conversations`
- `conversations/{conversationId}/messages`
- `reviews`

## Folder Structure

```text
lib/
  main.dart                 App entry point
  app.dart                  Root MaterialApp and Firebase startup gate

  core/                     Shared constants, theme, utilities, and widgets
  data/                     Models, Firebase services, and repositories
  demo/                     Development/demo seed data and mock fallback data
  features/                 App pages grouped by feature
  routing/                  Route names, route arguments, and route builder
```

## How The Code Is Organized

- `core/theme` contains app colors, text styles, and the Material theme.
- `core/widgets` contains reusable widgets such as buttons, cards, loading views, chips, and snackbars.
- `core/utils` contains validators, date formatting, and friendly Firebase error handling.
- `data/models` contains Firestore data models and map conversion logic.
- `data/services/auth_service.dart` contains Firebase Authentication methods.
- `data/repositories` contains Firestore collection logic.
- `features` contains UI pages grouped by app area.
- `routing` keeps navigation names and route creation in one place.

## How To Run

Use the Flutter SDK installed on this machine:

```bash
export PATH="$PATH:/home/dawit/tools/flutter/bin"
flutter pub get
flutter run -d chrome
```

## How To Verify

```bash
flutter analyze
flutter test
flutter build web
```

## How To Test With Two Users

1. Create or log in to the first account.
2. Complete the profile setup.
3. Add at least one offered skill and one wanted skill.
4. Log out.
5. Create or log in to a second account.
6. Complete the second profile and add skills.
7. Use Discover to find the other student's offered skill.
8. Send a swap request.
9. Log back into the first account and accept the request.
10. Open Messages and send a chat message.
11. Mark the swap completed and submit a review.

## Demo Data

The demo seeding helper lives in:

```text
lib/demo/demo_seed_data.dart
```

It is for development/demo use only and should be removed before a real production release.
