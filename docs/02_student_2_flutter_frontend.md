# Student 2 Presentation Guide: Flutter Frontend and UI Structure

## My Main Responsibility

> “I worked on the Flutter frontend implementation, page structure, reusable widgets, navigation, app theme, loading screens, and responsive UI behavior.”

Student 2 should focus on explaining how the Flutter app is organized and how the screens are built.

## What Flutter Does In Our Project

Flutter is used to build the mobile user interface with one codebase. Flutter uses widgets to build screens.

In SkillSwap:

- Every page is a Flutter widget.
- Reusable UI parts are separated into common components.
- The same code can run on Chrome for demo and can also run as a mobile app.
- The UI connects to Firebase through services and repositories.

## Folder Structure

The current project structure is organized like this:

```text
lib/
  main.dart
  app.dart

  core/
    constants/
    theme/
    utils/
    widgets/

  data/
    models/
    services/
    repositories/

  demo/

  features/
    auth/
    profile_setup/
    home/
    discover/
    swaps/
    messages/
    profile/
    reviews/

  routing/
```

## What Each Folder Means

- `core/theme`: app colors, text styles, and global app theme.
- `core/widgets`: reusable UI widgets used on many screens.
- `core/utils`: helper functions like validators, error handling, and date formatting.
- `data/models`: Dart model classes for Firestore data.
- `data/services`: low-level Firebase services, such as authentication.
- `data/repositories`: database operations for each Firestore collection.
- `features`: app pages grouped by feature.
- `routing`: route names and navigation logic.
- `demo`: demo seed data and mock fallback data.

## Reusable Widgets To Explain

Reusable widgets help the app stay consistent.

Important reusable widgets:

- `AppButton`
- `AppTextField`
- `AppLoadingScreen`
- `AppErrorView`
- `EmptyStateView`
- `SkillChip`
- `StatusBadge`
- `SkillCard`
- `AppCard`

Files:

- `lib/core/widgets/app_button.dart`
- `lib/core/widgets/app_text_field.dart`
- `lib/core/widgets/app_loading_screen.dart`
- `lib/core/widgets/app_error_view.dart`
- `lib/core/widgets/empty_state_view.dart`
- `lib/core/widgets/skill_chip.dart`
- `lib/core/widgets/status_badge.dart`
- `lib/features/discover/widgets/skill_card.dart`

## Why Reusable Widgets Are Important

Reusable widgets are important because they:

- Reduce duplicate code.
- Make the UI consistent.
- Make it easier to update the design.
- Make the project easier for team members to understand.
- Keep page files cleaner.

## Theme System

The app theme is global.

Important files:

- `lib/core/theme/app_colors.dart`
- `lib/core/theme/app_text_styles.dart`
- `lib/core/theme/app_theme.dart`

Colors are stored globally instead of writing random color values in many pages. This keeps the app consistent.

Example:

- Primary green is used for main actions.
- Gold is used as an accent.
- Warm background is used across the app.
- Cards use white backgrounds.

## Navigation

The app uses named routes and bottom navigation.

Important files:

- `lib/routing/app_routes.dart`
- `lib/routing/app_router.dart`
- `lib/features/home/widgets/bottom_navigation_shell.dart`

Main bottom navigation pages:

- Home
- Discover
- Swaps
- Messages
- Profile

Example navigation flow:

```text
Discover -> Skill Details -> Request Swap
```

Auth flow:

```text
App starts -> Loading screen -> AuthGate -> Login / Profile Setup / Home
```

## Loading, Error, and Empty States

The app avoids blank screens.

- `AppLoadingScreen` appears when Firebase or profile data is loading.
- `AppErrorView` shows clear messages when something goes wrong.
- `EmptyStateView` can explain what the user should do next.
- Buttons show loading states while saving or submitting.

This makes the app easier to demo and easier for users to understand.

## How The Frontend Connects To Firebase

Pages do not directly write complex Firestore logic. Instead:

- Pages show UI.
- Pages call repositories or services.
- Repositories talk to Firestore.
- Models convert Firestore data into Dart objects.

Example:

- `DiscoverPage` uses `SkillRepository`.
- `MySwapsPage` uses `SwapRepository`.
- `ChatPage` uses `ChatRepository`.

## Screens I Should Show

- Login screen loading behavior.
- Bottom navigation.
- Discover page.
- Add Skill page.
- My Swaps tabs.
- Empty state screen if possible.

## What I Should Prepare

- Open the project in the code editor.
- Be ready to show the `lib/` folder structure.
- Practice explaining reusable widgets.
- Practice explaining navigation using `app_routes.dart` and `app_router.dart`.
- Make sure the app is already running before the presentation.
- Prepare to show one page file, such as `discover_page.dart`.

## Files/Code I Should Explain

Recommended files:

- `lib/main.dart`
- `lib/app.dart`
- `lib/core/theme/app_colors.dart`
- `lib/core/theme/app_theme.dart`
- `lib/core/widgets/app_button.dart`
- `lib/core/widgets/app_loading_screen.dart`
- `lib/routing/app_routes.dart`
- `lib/routing/app_router.dart`
- `lib/features/discover/pages/discover_page.dart`
- `lib/features/home/widgets/bottom_navigation_shell.dart`

## Suggested Speaking Script

“I worked on the Flutter frontend structure. Flutter lets us build the UI using widgets. In our app, the code is organized by responsibility. Shared styles and widgets are inside the core folder, Firebase models and repositories are inside data, and each screen is grouped inside features. We also centralized routing so it is easy to understand how users move between screens. Reusable widgets like AppButton, AppCard, AppLoadingScreen, and SkillCard help us keep the interface consistent and avoid repeated code.”

## Possible Teacher Questions

### 1. Why did you use Flutter?

Flutter lets us build a mobile app with one codebase. It is fast for UI development and works well with Firebase.

### 2. How is the UI organized?

The UI is organized by features. For example, Discover pages are in `features/discover`, chat pages are in `features/messages`, and profile pages are in `features/profile`.

### 3. What are reusable widgets?

Reusable widgets are common UI components used in many places, such as buttons, cards, loading screens, and chips.

### 4. How do you avoid duplicate code?

We put common UI parts in `core/widgets`, common colors in `core/theme`, and common validation or error helpers in `core/utils`.

### 5. How does navigation work?

The app uses named routes. Route names are in `app_routes.dart`, and route page creation is in `app_router.dart`.

### 6. What happens when data is loading?

The app shows a loading screen or loading indicator instead of showing a blank screen.

## Short Summary

Student 2 should focus on explaining how the Flutter frontend is organized and how the user interface works.
