# SkillSwap System Overview and Technical Decisions

## 1. Project Summary

SkillSwap is a Flutter and Firebase mobile app that helps students exchange skills. Users can create profiles, add skills they offer and want, discover matching students, send swap requests, chat, complete swaps, and leave reviews.

The main idea is that students can learn from each other instead of always paying money for tutoring.

Example:

- Student A teaches Physics and wants Maths.
- Student B teaches Maths and wants Physics.
- SkillSwap helps them find each other and exchange skills.

## 2. Main Features

- Authentication.
- Profile setup.
- Add offered/wanted skills.
- Discover/search.
- Match score.
- Swap requests.
- My Swaps tabs.
- Chat.
- Reviews.
- Loading/error/empty states.
- No internet handling.

## 3. Technology Stack

### Frontend

- Flutter.
- Dart.

### Backend

- Firebase Authentication.
- Cloud Firestore.

### Optional/Demo

- Firebase Console for data inspection.
- No custom server.

## 4. Why Flutter?

We used Flutter because:

- It uses one codebase.
- It is fast for UI development.
- It has a widget-based structure.
- It has good Firebase support.
- It is good for a mobile app final project demo.

## 5. Why Firebase?

We used Firebase because:

- It is easy to set up.
- Authentication is included.
- Firestore stores app data online.
- We do not need to build a custom backend server.
- It is suitable for a student final project.

## 6. Folder Structure

Actual project structure:

```text
lib/
  main.dart
  app.dart
  firebase_options.dart

  core/
    constants/
      app_constants.dart
    theme/
      app_colors.dart
      app_text_styles.dart
      app_theme.dart
    utils/
      app_error_handler.dart
      app_validators.dart
      date_formatter.dart
    widgets/
      app_button.dart
      app_card.dart
      app_error_view.dart
      app_loading_screen.dart
      app_snackbar.dart
      app_text_field.dart
      empty_state_view.dart
      skill_chip.dart
      status_badge.dart

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
    app_routes.dart
    app_router.dart

docs/
  presentation guide files
```

### Folder Explanation

- `core`: shared constants, theme, utilities, and reusable widgets.
- `data`: models, Firebase services, and Firestore repositories.
- `features`: app pages grouped by feature.
- `routing`: route names, route arguments, and route builder.
- `demo`: demo seed data and mock fallback data.
- `docs`: presentation and explanation documents.

## 7. System Flow

### App Start Flow

```text
App opens
-> SkillSwap loading screen
-> Firebase initializes
-> AuthGate checks user
-> Login / Profile Setup / Home
```

### User Flow

```text
Signup
-> Profile Setup
-> Add Skills
-> Discover
-> Request Swap
-> Accept
-> Chat
-> Complete
-> Review
```

## 8. Firebase Authentication Design

The app uses email/password authentication.

Important ideas:

- Firebase creates a unique `uid` for each user.
- The app checks the current user during startup.
- Users can logout.
- Users can request password reset emails.
- AuthGate decides which screen to show.

Important files:

- `lib/data/services/auth_service.dart`
- `lib/features/auth/widgets/auth_gate.dart`
- `lib/features/auth/pages/login_page.dart`
- `lib/features/auth/pages/signup_page.dart`

## 9. Firestore Database Design

### users

Purpose:

- Stores student profile data.

Important fields:

- `uid`
- `fullName`
- `email`
- `university`
- `department`
- `year`
- `bio`
- `campus`
- `photoUrl`
- `rating`
- `completedSwaps`
- `profileCompleted`
- `createdAt`

### skills

Purpose:

- Stores offered and wanted skills.

Important fields:

- `ownerId`
- `ownerName`
- `ownerPhotoUrl`
- `university`
- `title`
- `category`
- `level`
- `description`
- `type`
- `exchangeFor`
- `isActive`
- `createdAt`

### swapRequests

Purpose:

- Stores requests between two students.

Important fields:

- `fromUserId`
- `fromUserName`
- `toUserId`
- `toUserName`
- `offeredSkillId`
- `offeredSkillTitle`
- `wantedSkillId`
- `wantedSkillTitle`
- `message`
- `status`
- `suggestedTime`
- `mode`
- `createdAt`
- `updatedAt`

### conversations

Purpose:

- Stores chat conversation information.

Important fields:

- `participants`
- `participantNames`
- `lastMessage`
- `lastMessageAt`
- `relatedRequestId`
- `lastSenderId`
- `unreadBy`

Messages are stored in:

```text
conversations/{conversationId}/messages
```

### reviews

Purpose:

- Stores session reviews.

Important fields:

- `sessionId`
- `reviewerId`
- `revieweeId`
- `rating`
- `tags`
- `comment`
- `createdAt`

## 10. Matching Decision

Match score was added to help users find better swap partners.

It prioritizes:

- People who teach what the user wants.
- People who want what the user can teach.

Scoring:

- `+50` wanted skill match.
- `+30` exchange skill match.
- `+10` category match.
- `+5` same university/campus.
- `+5` good rating.

Maximum score is 100.

## 11. Swap Request Decision

Swap requests connect two users.

Each request has a status:

- `pending`
- `accepted`
- `declined`
- `completed`

Tab behavior:

- Pending requests appear in Requests.
- Accepted requests appear in Upcoming.
- Completed requests appear in Completed.

## 12. Duplicate Prevention Decisions

### Duplicate Swap Prevention

The app prevents creating the same active request multiple times.

If a request already exists with status `pending` or `accepted`, the app shows:

> “You already have an active request with this student.”

### Duplicate Chat Prevention

The app keeps one chat per pair of users.

The conversation id is deterministic:

```text
smallerUid_largerUid
```

This means the same two users always open the same chat.

## 13. Error Handling Decisions

The app handles errors in a user-friendly way.

- Firebase errors are converted into friendly messages.
- Loading states prevent duplicate submissions.
- No internet errors show a clear retry message.
- Empty states explain what the user should do next.

Examples:

- Wrong password -> “Incorrect email or password. Please check your details and try again.”
- No internet -> “No internet connection. Please check your connection and try again.”
- No skills -> user should add skills.
- No swaps -> user should find a swap partner.

Important file:

- `lib/core/utils/app_error_handler.dart`

## 14. Security Measures

Security concepts:

- Firebase Auth ensures only signed-in users access app data.
- User documents are tied to UID.
- Users should only edit their own profile.
- Users should only modify their own skills.
- Swap requests should only be visible to participants.
- Conversations should only be visible to participants.
- Reviews are created by the reviewer.

Recommended Firestore rule idea:

- Signed-in users can read user profiles.
- Users can update only `users/{uid}` where `uid` equals their Firebase uid.
- Users can create/update/delete only skills where `ownerId` is their uid.
- Users can read swap requests only when they are `fromUserId` or `toUserId`.
- Users can read conversations only when their uid is in `participants`.
- Users can read/write messages only inside conversations where they are participants.
- Users can create reviews only as `reviewerId`.

## 15. Demo Plan

Final demo flow:

1. Login as User A.
2. Show profile and skills.
3. Open Discover.
4. Find User B skill.
5. Send swap request.
6. Login as User B.
7. Accept request.
8. Send chat message.
9. Mark complete.
10. Leave review.

## 16. Team Responsibility Summary

Student 1:

- Project idea, problem, UI/UX, user flow.

Student 2:

- Flutter frontend, folder structure, reusable widgets, navigation, UI states.

Student 3:

- Firebase Auth, user profile, AuthGate, login/signup, error handling.

Student 4:

- Firestore skills, match score, swap requests, chat, reviews.

## 17. Challenges

Realistic challenges we faced:

- Organizing code.
- Connecting UI with Firebase.
- Preventing duplicate requests.
- Making match score logical.
- Handling no internet and errors.
- Testing with two users.
- Keeping the app beginner-friendly while still connected to Firebase.

## 18. Future Improvements

Possible improvements:

- Push notifications.
- Google sign-in.
- Profile image upload.
- Admin dashboard.
- Advanced search.
- Better recommendation algorithm.
- Scheduling calendar.
- Report/moderation system.

## 19. How To Run The Project

Commands:

```bash
flutter pub get
flutter analyze
flutter run -d chrome
```

Firebase setup:

- Firebase project must be configured.
- `lib/firebase_options.dart` should exist.
- Email/password auth should be enabled.
- Firestore database should be created.

## 20. Presentation Checklist

Before presentation:

- Prepare two demo accounts.
- Add skills for both accounts.
- Test Discover.
- Test swap request.
- Test chat.
- Test review.
- Keep Firebase Console open.
- Keep app running before presentation.
- Make sure internet is working.
- Practice switching between two users.

## Final Note

This document explains the overall system and the major technical decisions made in the SkillSwap project.
