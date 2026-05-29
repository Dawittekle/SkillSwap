# Student 4 Presentation Guide: Firestore Skills, Matching, Swaps, Chat, and Reviews

## My Main Responsibility

> “I worked on Firestore database features including skills, Discover data, match scoring, swap requests, chat, reviews, and duplicate request prevention.”

Student 4 should focus on the Firestore logic that makes SkillSwap work as a connected app.

## Firestore Collections To Explain

Main collections:

- `users`
- `skills`
- `swapRequests`
- `conversations`
- `reviews`

Messages are stored under:

```text
conversations/{conversationId}/messages
```

## Skills Collection

Skills are stored in:

```text
skills/{skillId}
```

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

Important files:

- `lib/data/models/skill.dart`
- `lib/data/repositories/skill_repository.dart`
- `lib/features/profile/pages/skill_form_page.dart`
- `lib/features/profile_setup/pages/skills_setup_page.dart`

## Offered vs Wanted Skills

Offered skill:

- Something the user can teach.
- Example: “Physics tutoring.”

Wanted skill:

- Something the user wants to learn.
- Example: “Maths.”

The app uses this to find useful swaps.

## Discover Page

Discover reads offered skills from Firestore.

It:

- Shows active offered skills.
- Excludes the current user’s own skills.
- Allows searching by skill, person, university, category, description, and `exchangeFor`.
- Sorts results by match score.

Important file:

- `lib/features/discover/pages/discover_page.dart`

## Match Score Logic

A good match means:

- The other user teaches something I want to learn.
- The other user wants something I can teach.

Scoring:

- `+50` if the other student teaches a skill that matches one of my wanted skills.
- `+30` if the other student wants something I can teach.
- `+10` if the category matches my wanted category.
- `+5` if same university/campus.
- `+5` if rating is 4.5 or above.
- Maximum score is 100.

Labels:

- `85-100`: Great Match
- `65-84`: Good Match
- `40-64`: Possible Match
- `1-39`: Low Match
- `0`: Not a Match

This makes Discover more useful than just showing random skills.

## Swap Request Flow

1. User finds a skill in Discover.
2. User opens Skill Details.
3. User taps Request Swap.
4. User selects what they can offer in return.
5. App creates a `swapRequests` document.
6. Receiver sees it in My Swaps.
7. Receiver accepts or declines.
8. Accepted swaps appear in Upcoming.
9. Completed swaps move to Completed.
10. User can leave review.

## Swap Requests Collection

Swap requests are stored in:

```text
swapRequests/{requestId}
```

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

Statuses:

- `pending`
- `accepted`
- `declined`
- `completed`

Important files:

- `lib/data/models/swap_request.dart`
- `lib/data/repositories/swap_repository.dart`
- `lib/features/swaps/pages/request_swap_page.dart`
- `lib/features/swaps/pages/my_swaps_page.dart`
- `lib/features/swaps/pages/session_detail_page.dart`

## Duplicate Request Prevention

The app checks if there is already an active request between the same users for the same selected skill.

If the status is `pending` or `accepted`, the app blocks creating another request.

Message shown:

> “You already have an active request with this student.”

This prevents spam and confusion.

## Chat

Chat uses:

```text
conversations
conversations/{conversationId}/messages
```

Important idea:

- The app uses one conversation per pair of users.
- The conversation id is made by sorting the two user ids.
- This means the same two users always open the same chat.
- This prevents duplicate chats.

Important files:

- `lib/data/models/conversation.dart`
- `lib/data/models/chat_message.dart`
- `lib/data/repositories/chat_repository.dart`
- `lib/features/messages/pages/messages_page.dart`
- `lib/features/messages/pages/chat_page.dart`

## Reviews

After completing a swap, a user can leave a review.

Reviews are stored in:

```text
reviews/{reviewId}
```

Reviews can be shown on:

- Public Student Profile.
- My Profile.

Important files:

- `lib/data/models/review.dart`
- `lib/data/repositories/review_repository.dart`
- `lib/features/reviews/pages/rate_session_page.dart`
- `lib/features/reviews/widgets/review_widgets.dart`

## Screens I Should Show

- Add Skill.
- Discover sorted by match score.
- Request Swap.
- My Swaps.
- Chat.
- Rate Session.
- Firebase Console collections.

## Demo Steps With Two Users

1. Login as Dawit.
2. Add offered and wanted skills.
3. Logout.
4. Login as Hana.
5. Add matching skills.
6. Discover Dawit’s skill.
7. Send swap request.
8. Logout.
9. Login as Dawit.
10. Open My Swaps.
11. Accept request.
12. Open chat and send message.
13. Complete swap.
14. Submit review.

## What I Should Prepare

- Prepare two demo users before presentation.
- Make sure both users have offered and wanted skills.
- Make sure there is at least one good match.
- Practice showing Firestore collections in Firebase Console.
- Practice explaining match score with a simple example.
- Practice sending and accepting a request.

## Files/Code I Should Explain

Recommended files:

- `lib/data/repositories/skill_repository.dart`
- `lib/data/repositories/swap_repository.dart`
- `lib/data/repositories/chat_repository.dart`
- `lib/data/repositories/review_repository.dart`
- `lib/data/models/skill.dart`
- `lib/data/models/swap_request.dart`
- `lib/data/models/conversation.dart`
- `lib/data/models/chat_message.dart`
- `lib/data/models/review.dart`
- `lib/features/discover/pages/discover_page.dart`
- `lib/features/swaps/pages/request_swap_page.dart`
- `lib/features/swaps/pages/my_swaps_page.dart`
- `lib/features/messages/pages/chat_page.dart`

## Suggested Speaking Script

“My part focused on the Firestore features. Firestore stores skills, swap requests, conversations, messages, and reviews. When a user adds a skill, it is saved in the skills collection. Discover reads skills from Firestore and calculates a match score based on what the current user wants and what they can offer. When a student sends a swap request, it is saved in the swapRequests collection. The receiver can accept, decline, or complete it. Chat uses one conversation per pair of users, so the app does not create duplicate chats. After a completed session, users can leave reviews.”

## Possible Teacher Questions

### 1. How is match score calculated?

It checks whether the other user teaches what I want and whether they want something I can teach. It also gives small points for same category, same university/campus, and high rating.

### 2. How do you prevent duplicate requests?

Before creating a request, the app checks if a pending or accepted request already exists between the same users for the same selected skill.

### 3. How do you prevent duplicate chats?

The conversation id is created by sorting the two user ids. So the same pair always opens the same conversation.

### 4. Where are messages stored?

Messages are stored inside the messages subcollection under each conversation document.

### 5. How does the other user see a request?

The My Swaps page reads incoming requests where `toUserId` is the current user id.

### 6. Why use Firestore instead of local storage?

Firestore stores data online and lets different users see shared data. Local storage would only work on one device.

## Short Summary

Student 4 should focus on explaining the main Firestore logic that makes SkillSwap work as a real connected app.
