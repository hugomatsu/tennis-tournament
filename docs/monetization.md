# Monetization Strategy & Implementation Plan

This document outlines the strategy to transition from an admin-only tournament creation model to a user-centric, subscription-based model.

## 1. Description of Change

### Current State
- **Admin-Centric:** Only users with specific administrative privileges (or a single global admin) can create and manage tournaments.
- **Tournament Ownership:** Tournaments are effectively "system-owned" or owned by the creator but without explicit ownership metadata exposed or utilized for permissions.
- **Access Control:** No limits on creation for admins; regular users cannot create tournaments.

### Future State (Proposed)
- **User-Centric:** Any user can create tournaments, subject to their subscription status.
- **Subscription Model:**
  - **Free Users:** Can create up to **2** (configurable) tournaments for testing/personal use.
  - **Premium Users (Subscribers):** Can create an **unlimited** number of tournaments.
- **Tournament Ownership:** The user who creates a tournament is the **Owner**.
- **Shared Administration:** The Owner can add other users as **Admins** to their specific tournament.

## 2. Technical Implementation

### Data Model Changes

#### `Tournament` Collection
We need to add ownership and administration fields to the `Tournament` document.

```dart
class Tournament {
  // ... existing fields
  final String ownerId;        // [NEW] ID of the user who created it (The "Owner")
  final List<String> adminIds; // [NEW] IDs of users granted admin rights
}
```

#### `User` Collection / Subscription Logic
We need to track or verify the user's subscription status.

**Option A: Firestore User Document**
Add fields to the `users` collection:
- `isPremium` (bool): controlled by purchase logic.
- `subscriptionStatus` (String): e.g., 'active', 'expired', 'none'.

**Option B: Dynamic Count (for limits)**
To enforce the 2-tournament limit for free users:
- **Query:** `tournaments.where('ownerId', isEqualTo: currentUser.uid).count()`
- **Logic:** If count >= 2 and `!isPremium`, block creation.

### Creation Workflow

1.  **User navigates to "Create Tournament" screen.**
2.  **App checks permissions:**
    -   Fetch current user's subscription status (`isPremium`).
    -   If `!isPremium`, query Firestore for number of tournaments owned by this user.
    -   If count >= `MAX_FREE_TOURNAMENTS` (2), show upsell screen/dialog.
    -   Else, allow access to form.
3.  **User submits form:**
    -   Create `Tournament` object with `ownerId = currentUser.uid`.
    -   Add `currentUser.uid` to `adminIds` (optional, or implicit owner rights).
    -   Save to Firestore.

### Administration Workflow

1.  **Tournament Details Screen:**
    -   Show "Edit" / "Manage" buttons only if `currentUser.uid == ownerId` OR `adminIds.contains(currentUser.uid)`.
2.  **Adding Admins:**
    -   New feature in "Tournament Settings": "Manage Admins".
    -   Owner can search for users and add them to the `adminIds` list.

## 3. Immediate Next Steps

1.  **Update Domain Models:**
    -   Modify `Tournament` class in `lib/features/tournaments/domain/tournament.dart`.
    -   Generate `freezed` files.
2.  **Repository Update:**
    -   Update `createTournament` in `FirestoreTournamentRepository` to save `ownerId` and `adminIds`.
    -   Implement permission checks in `updateTournament` etc.
3.  **UI/Logic Implementation:**
    -   Modify `CreateTournamentScreen` to check limits.
    -   Add "Manage Admins" UI.

## 4. Configurable Variables

- `MAX_FREE_TOURNAMENTS`: 2
