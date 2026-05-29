# Student 3 Presentation Guide: Firebase Authentication and User Profiles

## My Main Responsibility

> “I worked on Firebase Authentication, user signup/login, profile setup, AuthGate logic, user data storage, and error handling.”

Student 3 should focus on explaining how users enter the app and how their profile data is stored.

## Why We Used Firebase

Firebase is used as the backend. It allows the app to use authentication and database services without building a custom server.

For this part, we used:

- Firebase Authentication.
- Cloud Firestore for user profiles.

Firebase is useful for a student final project because it is fast to set up, works well with Flutter, and lets us focus on app features.

## Authentication Features

The app supports:

- Sign up with email and password.
- Login with email and password.
- Logout.
- Forgot password.
- Current user checking.

Important file:

- `lib/data/services/auth_service.dart`

`AuthService` contains methods for:

- `signUpWithEmail`
- `signInWithEmail`
- `signOut`
- `sendPasswordResetEmail`
- `authStateChanges`
- `currentUser`

## AuthGate and Startup Flow

Important file:

- `lib/features/auth/widgets/auth_gate.dart`

When the app starts:

1. Show SkillSwap loading screen.
2. Check if Firebase user is logged in.
3. If not logged in, show Login.
4. If logged in but `profileCompleted` is false, show Profile Setup.
5. If logged in and `profileCompleted` is true, show Home/Main App.
6. If there is no internet or an error, show a clear error message or retry option.

This makes sure users go to the correct screen automatically.

## User Profile Collection

User profiles are stored in Firestore:

```text
users/{uid}
```

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

Important files:

- `lib/data/models/app_user.dart`
- `lib/data/repositories/user_repository.dart`

## Why UID Is Important

Firebase gives each account a unique `uid`.

The app uses this `uid` to connect:

- User profile.
- Skills.
- Swap requests.
- Conversations.
- Reviews.

This helps the app know which data belongs to which user.

## Profile Completed Logic

New users first have:

```text
profileCompleted: false
```

After they fill the profile setup form, it becomes:

```text
profileCompleted: true
```

This is important because the app uses it to decide where to send the user.

Example:

- New user -> Profile Setup.
- Completed user -> Home.

## Error Handling

Important file:

- `lib/core/utils/app_error_handler.dart`

The app converts Firebase errors into friendly messages.

Examples:

- Wrong password -> “Incorrect email or password. Please check your details and try again.”
- Invalid email -> “Please enter a valid email address.”
- No internet -> “No internet connection. Please check your connection and try again.”
- Permission error -> “You do not have permission to access this data. Please sign in again.”

## Why User-Friendly Errors Matter

Friendly errors are important because:

- Users understand what happened.
- The app does not look broken.
- The demo becomes easier to test.
- The teacher can see that we handled real app situations.

## Screens I Should Show

- Login.
- Signup.
- Forgot Password.
- Profile Setup.
- My Profile.
- Firebase Console Authentication users list.
- Firestore `users` collection.

## Demo Steps

1. Create a new account.
2. Show the account in Firebase Authentication.
3. Show `users/{uid}` document in Firestore.
4. Complete profile setup.
5. Show `profileCompleted` changes to `true`.
6. Logout.
7. Login again.
8. Show that the app opens the main app instead of Profile Setup.

## What I Should Prepare

- Prepare Firebase Console before presentation.
- Enable Email/Password authentication in Firebase.
- Have one test email ready.
- Know where to find the Authentication users list.
- Know where to find the Firestore `users` collection.
- Practice explaining `uid` and `profileCompleted`.

## Files/Code I Should Explain

Recommended files:

- `lib/data/services/auth_service.dart`
- `lib/data/repositories/user_repository.dart`
- `lib/data/models/app_user.dart`
- `lib/features/auth/pages/login_page.dart`
- `lib/features/auth/pages/signup_page.dart`
- `lib/features/auth/pages/forgot_password_page.dart`
- `lib/features/profile_setup/pages/profile_setup_page.dart`
- `lib/features/auth/widgets/auth_gate.dart`
- `lib/core/utils/app_error_handler.dart`

## Suggested Speaking Script

“My part focused on Firebase Authentication and user profiles. Firebase Authentication handles signup, login, logout, password reset, and checking the current user. After signup, we create a user profile document in Firestore using the Firebase uid. The uid is important because it connects the user to their profile, skills, swap requests, chat, and reviews. We also use an AuthGate. When the app starts, it checks whether the user is logged in and whether their profile is complete. Based on that, the app shows Login, Profile Setup, or the main app.”

## Possible Teacher Questions

### 1. Why did you use Firebase Authentication?

It gives us secure email/password login without building our own authentication server.

### 2. What is a UID?

A UID is a unique id Firebase gives to each user account. We use it to connect data to the correct user.

### 3. Where is user profile data stored?

User profiles are stored in the Firestore `users` collection.

### 4. What happens when a new user signs up?

Firebase creates the auth account, then the app creates a `users/{uid}` document with profileCompleted set to false.

### 5. What happens if there is no internet?

The app shows a clear no-internet message and retry option.

### 6. How do you protect user data?

Each user profile is connected to the Firebase uid. Firestore security rules should allow users to edit only their own profile.

## Short Summary

Student 3 should focus on explaining how users enter the system and how their profile data is stored.
