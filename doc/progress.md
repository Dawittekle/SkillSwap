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

## 2026-05-25 Home Page

### Completed
- Rebuilt the Home tab using the Stitch reference direction:
  - SkillSwap header with profile/avatar and notifications.
  - Personalized greeting and search field.
  - Teal potential-swaps summary panel.
  - Horizontal skill category chips.
  - Best-match student cards using mock student data.
  - Upcoming session card.
  - Recent activity list.
- Added structured mock Home data in `lib/src/data/mock/mock_home.dart`.
- Kept the page mock-data only and separated data from widgets so Firestore documents can replace the mock objects later.
- Added responsive behavior with a centered max-width layout and wider grid layout on larger screens.

### Verification
- `flutter analyze` passed.
- `flutter test` passed.

## 2026-05-28 Profile Firestore Connection

### Completed
- Connected Profile Setup to Firebase Auth and Firestore user documents.
- Required setup fields before completing a profile:
  - full name
  - university
  - department
  - year
  - campus
  - bio
- Set `profileCompleted: true` only after required fields are saved.
- Connected My Profile to watch `users/{uid}` in real time.
- Added Edit Profile page for updating saved Firestore profile fields.
- Kept existing profile styling and kept skill sections on mock data.

### Verification
- `flutter analyze` passed.
- `flutter test` passed.
- `flutter build web` passed.

## 2026-05-28 Skills Firestore Connection

### Completed
- Connected skill creation and updates to the `skills` Firestore collection.
- Added Skills Setup with separate offered and wanted skill forms.
- Prevented duplicate setup skills with the same title and type for the current user.
- Added Add/Edit Skill page backed by Firestore.
- Added Manage Skills page with separate sections:
  - Skills I Teach
  - Skills I Want to Learn
- Added deactivate, reactivate, edit, and delete actions for user skills.
- Connected My Profile skill sections to current user's Firestore skills.
- Kept mock skill chips as fallback when Firestore has no skill data.
- Kept non-skill mock pages unchanged.

### Verification
- `flutter analyze` passed.
- `flutter test` passed.
- `flutter build web` passed.

## 2026-05-28 Discover Firestore Connection

### Completed
- Connected Discover to active offered skills from the `skills` Firestore collection.
- Filtered Discover results to exclude the current user's own skills.
- Kept local search and category filtering for the demo.
- Updated Skill Details to load Firestore skill data and the teacher profile from `users/{ownerId}`.
- Passed selected skill and teacher context into the Request Swap placeholder route.
- Added Public Student Profile for viewing another student's Firestore profile, offered skills, and wanted skills.
- Added an empty state explaining that Discover needs active offered skills from other students.

### Verification
- `flutter analyze` passed.
- `flutter test` passed.
- `flutter build web` passed.

## 2026-05-28 Swap Request Firestore Connection

### Completed
- Connected Request Swap to the `swapRequests` Firestore collection.
- Added a Request Sent confirmation screen after successful request creation.
- Loaded the current user's offered skills for selecting an exchange skill.
- Saved swap requests with requester, teacher, offered skill, wanted skill, message, status, suggested time, mode, and timestamps.
- Connected My Swaps to incoming and outgoing Firestore requests.
- Added tabs for pending requests, accepted upcoming swaps, and completed swaps.
- Added status badges and request actions:
  - accept incoming pending requests
  - decline incoming pending requests
  - cancel outgoing pending requests
  - complete accepted swaps
- Added loading, empty, and error states.

### Verification
- `flutter analyze` passed.
- `flutter test` passed.
- `flutter build web` passed.

## 2026-05-28 Basic Chat Firestore Connection

### Completed
- Connected conversations to the `conversations` Firestore collection.
- Connected chat messages to `conversations/{conversationId}/messages`.
- Added a Firestore-backed Messages tab showing conversations for the current user.
- Sorted conversations by `lastMessageAt` descending in the UI.
- Added a Chat page that streams messages by `createdAt` ascending.
- Added text message sending with `conversationId`, `senderId`, `text`, `createdAt`, and `readBy`.
- Updated conversation `lastMessage` and `lastMessageAt` after sending.
- Wired Message buttons from Public Student Profile, Skill Details, and swap cards to open or create conversations.
- Kept chat simple with text only.

### Verification
- `flutter analyze` passed.
- `flutter test` passed.
- `flutter build web` passed.

## 2026-05-28 Reviews Firestore Connection

### Completed
- Connected session reviews to the `reviews` Firestore collection.
- Added a Rate Session page for completed swaps.
- Saved review data with session id, reviewer id, reviewee id, rating, tags, comment, and created timestamp.
- Prevented duplicate reviews from the same reviewer for the same completed swap by using a stable review document id.
- Added review cards and average rating display to Public Student Profile.
- Added received review cards and average rating display to My Profile.
- Updated `users/{uid}.rating` after review creation when possible.

### Verification
- `flutter analyze` passed.
- `flutter test` passed.
- `flutter build web` passed.

## 2026-05-28 Demo Data Seed Helper

### Completed
- Added a development-only Firestore seed helper for demo data.
- Added six Ethiopian student profile documents with deterministic demo ids.
- Added seven active offered skills with deterministic demo ids.
- Added a debug-only Profile button for manually running the seed.
- Seed logic skips records that already exist and does not modify the signed-in user's profile.
- Added comments marking the helper and button as removable before final submission.

### Verification
- `flutter analyze` passed.
- `flutter test` passed.
- `flutter build web` passed.

## 2026-05-29 Home Firestore Alignment

### Completed
- Replaced mock-only Home page data with signed-in Firestore profile data.
- Connected Home metrics to live swap request data:
  - active accepted swaps
  - completed sessions
  - potential matches
- Connected best matches to active offered skills from other users.
- Wired Home Request Swap buttons to pass the selected Firestore skill and teacher.
- Wired View Matches, See All, search, and filter actions to the Discover screen.
- Wired the notification bell to the Firestore-backed Messages screen.
- Added a simple Session Details screen for accepted/completed swap requests.
- Updated the Home widget test to use a Firebase-free preview mode.

### Verification
- `flutter analyze` passed.
- `flutter test` passed.
- `flutter build web` passed.

## 2026-05-29 Navigation And Notification Fixes

### Completed
- Changed Home Discover actions to switch to the existing Discover bottom-nav tab instead of pushing a standalone Discover page.
- Changed the Home notification bell to switch to the Messages tab.
- Connected Profile swap count to real completed incoming/outgoing swap requests.
- Added unread conversation tracking using the existing message `readBy` data plus conversation `unreadBy` summary.
- Added a Messages nav badge showing unread conversation count.
- Added a per-conversation unread dot in the Messages list.
- Marked conversations and messages as read when opening a chat.

### Verification
- `flutter analyze` passed.
- `flutter test` passed.
- `flutter build web` passed.

## 2026-05-29 Product Logic And UX Polish

### Completed
- Changed My Swaps primary action to "Find Swap Partner" and routed it to Discover.
- Improved Discover search to match skill fields, owner name, university, and owner department.
- Added demo-friendly Discover match score labels:
  - Great Match
  - Good Match
  - Possible Match
  - Low Match
- Prevented duplicate active swap requests for the same requester, student, and wanted skill.
- Added a friendly duplicate request message with a View action for the existing request.
- Changed chat creation to use deterministic conversation ids based on sorted user ids.
- Kept one conversation per pair of users even when opened from different entry points.
- Updated My Swaps empty messages for Requests, Upcoming, and Completed tabs.

### Verification
- `flutter analyze` passed.
- `flutter test` passed.
- `flutter build web` passed.

## 2026-05-29 Home Button And Search Handoff

### Completed
- Made Home search submit open the existing Discover tab with the typed query applied.
- Kept the bottom navigation visible when moving from Home search to Discover.
- Made Home filter/search related controls open Discover.
- Made Home category chips open Discover with the category applied as the query.
- Kept visual styling unchanged.

### Verification
- `flutter analyze` passed.
- `flutter test` passed.
- `flutter build web` passed.

## 2026-05-29 Discover Match Sorting And Skill Form Polish

### Completed
- Removed the generous base match score from Discover so unrelated skills no longer look like strong matches.
- Updated Discover match scoring to prioritize real two-way skill compatibility:
  - other student teaches what I want
  - other student wants what I can offer
  - same category, same university/campus, and high rating are small bonuses
- Changed Discover default sorting to order visible results by best match first, then newest as a tie-breaker.
- Wired the Discover Sort button to reapply best-match sorting to the filtered list.
- Kept Discover search local and made it match skill fields, people fields, department, and exchangeFor.
- Updated the Add/Edit Skill exchange field label and placeholder based on whether the skill is Offered or Wanted.

### Verification
- `flutter analyze` passed.
- `flutter test` passed.
- `flutter build web` passed.

## 2026-05-25 Discover And Skill Details

### Completed
- Rebuilt the Discover tab to match the Home page visual system:
  - Page header with supporting copy.
  - Reusable search field.
  - Horizontal category chips.
  - Skills Offered / Skills Wanted segmented control.
  - Result summary panel.
  - Responsive skill cards.
  - Empty state for unmatched searches.
- Added a reusable `SkillCard` component for skill listings.
- Added a reusable `CategoryChip` wrapper around the existing chip styling.
- Added structured mock skill metadata for detail pages:
  - duration
  - meeting format
  - outcomes
  - tags
- Added a Skill Details page with owner info, outcomes, session format, and request/message actions.
- Wired named routing for `AppRoutes.skillDetails` using a mock skill ID argument.

### Verification
- `flutter analyze` passed.
- `flutter test` passed.
