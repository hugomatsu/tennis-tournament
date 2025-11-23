# Backend Architecture & Data Model

## Database: Cloud Firestore (NoSQL)

### 1. Collections & Schema

#### `users`
Stores user profiles and global settings.
```json
{
  "uid": "string (Auth ID)",
  "email": "string",
  "displayName": "string",
  "photoURL": "string",
  "role": "string ('admin' | 'player')",
  "profile": {
    "category": "string (e.g., 'A', 'B')",
    "playingSince": "timestamp",
    "bio": "string",
    "title": "string",
    "birthDate": "timestamp",
    "preferredPartnerId": "string (uid)"
  },
  "stats": {
    "wins": "number",
    "losses": "number",
    "rank": "number"
  },
  "createdAt": "timestamp"
}
```

#### `tournaments`
Stores high-level event metadata.
```json
{
  "id": "string",
  "name": "string",
  "status": "string ('open' | 'active' | 'completed')",
  "dates": {
    "start": "timestamp",
    "end": "timestamp",
    "registrationDeadline": "timestamp"
  },
  "courts": ["string (courtId)"] 
}
```

#### `categories`
Represents a specific division within a tournament (e.g., "Men's A", "Mixed Doubles").
```json
{
  "id": "string",
  "tournamentId": "string",
  "name": "string",
  "type": "string ('singles' | 'doubles')",
  "rules": {
    "scoringType": "string",
    "sets": "number",
    "format": "string ('round_robin' | 'elimination')"
  },
  "participants": ["string (uid) or {uid, partnerUid}"]
}
```

#### `matches`
Stores individual match details linked to a category.
```json
{
  "id": "string",
  "tournamentId": "string",
  "categoryId": "string",
  "round": "number",
  "status": "string ('scheduled' | 'in_progress' | 'completed')",
  "players": [
    { "uid": "string", "team": 1 },
    { "uid": "string", "team": 2 }
  ],
  "schedule": {
    "startTime": "timestamp",
    "endTime": "timestamp",
    "courtId": "string"
  },
  "result": {
    "winnerTeam": "number",
    "score": "string (e.g., '6-4, 6-2')"
  }
}
```

#### `availability`
Stores player availability constraints for the scheduling algorithm.
```json
{
  "id": "string (auto-id)",
  "userId": "string",
  "tournamentId": "string (optional, if specific)",
  "unavailableRanges": [
    { "start": "timestamp", "end": "timestamp" }
  ]
}
```

#### `courts`
Stores physical locations and their specific availability.
```json
{
  "id": "string",
  "name": "string",
  "location": "geopoint",
  "type": "string ('clay' | 'hard')",
  "ownerId": "string (optional, for private courts)",
  "availableSlots": [
    { "dayOfWeek": "number", "startHour": "number", "endHour": "number" }
  ]
}
```

---

## API & Cloud Functions

While simple CRUD operations (e.g., updating profile) will happen directly from the Flutter client using Firestore SDK, complex logic will be handled by **Cloud Functions**.

### 1. Scheduling Engine
*   **Function**: `generateSchedule`
*   **Trigger**: HTTPS Callable (Admin only)
*   **Input**: `tournamentId`, `startDate`, `endDate`
*   **Logic**:
    1.  Fetch all registered players and their `availability`.
    2.  Fetch available `courts`.
    3.  Run Constraint Satisfaction Algorithm to assign matches.
    4.  Batch write `matches` documents with status `scheduled`.

### 2. Match Management
*   **Function**: `submitMatchResult`
*   **Trigger**: HTTPS Callable
*   **Input**: `matchId`, `score`, `winnerTeam`
*   **Logic**:
    1.  Validate user permissions (Admin or assigned Scorekeeper).
    2.  Update `matches/{matchId}`.
    3.  Trigger `onMatchCompleted` to advance bracket or update standings.

### 3. Notifications
*   **Function**: `onMatchScheduled`
*   **Trigger**: Firestore `onCreate` / `onUpdate` of `matches`
*   **Logic**:
    1.  Check if `status` changed to `scheduled`.
    2.  Send FCM (Firebase Cloud Messaging) notification to participants.

### 4. User Management
*   **Function**: `addGhostPlayer`
*   **Trigger**: HTTPS Callable (Admin only)
*   **Input**: `name`, `category`
*   **Logic**: Creates a user document without Auth credentials for manual management.

## Security Rules Strategy
*   **Users**: Read public profile (Auth required); Write own profile only.
*   **Tournaments**: Public Read; Admin Write.
*   **Matches**: Public Read; Admin/Delegate Write.
*   **Availability**: Read (Admin/Self); Write (Self).
