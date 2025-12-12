# Backend Architecture & Data Model

## Database: Cloud Firestore (NoSQL)

### 1. Collections & Schema

#### `users`
Stores user profiles and global settings.
```json
{
  "id": "string (Auth ID)",
  "name": "string",
  "email": "string",
  "avatarUrl": "string",
  "role": "string ('admin' | 'player')",
  "title": "string (e.g., 'Pro', 'Beginner')",
  "bio": "string",
  "category": "string (Self-assessed level)",
  "playingSince": "string (MM/yyyy)",
  "wins": "number",
  "losses": "number",
  "rank": "number",
  "createdAt": "timestamp"
}
```

#### `tournaments`
Stores high-level event metadata.
```json
{
  "id": "string",
  "name": "string",
  "status": "string ('Upcoming' | 'In Progress' | 'Completed')",
  "dateRange": "string",
  "location": "string (Display name)",
  "locationId": "string (Reference to locations collection)",
  "imageUrl": "string",
  "description": "string",
  "playersCount": "number",
  "category": "string (Filter tag)"
}
```

#### `tournaments/{tournamentId}/participants`
Sub-collection storing players registered for a specific tournament.
```json
{
  "id": "string (userId_categoryId)",
  "userId": "string",
  "name": "string",
  "avatarUrl": "string",
  "categoryId": "string",
  "status": "string ('pending' | 'approved' | 'rejected')",
  "joinedAt": "timestamp"
}
```

#### `tournaments/{tournamentId}/categories`
Sub-collection defining divisions within a tournament.
```json
{
  "id": "string",
  "name": "string (e.g. Men's A)",
  "type": "string ('singles' | 'doubles')",
  "description": "string",
  "matchDurationMinutes": "number (Default 90)"
}
```

#### `matches`
Stores individual match details.
```json
{
  "id": "string",
  "tournamentId": "string",
  "categoryId": "string",
  "round": "string (e.g. '1', '2', 'Quarter-Final')",
  "matchIndex": "number (position in bracket)",
  "status": "string ('Preparing' | 'Scheduled' | 'Confirmed' | 'Started' | 'Finished' | 'Completed')",
  "time": "timestamp",
  "durationMinutes": "number",
  "court": "string",
  "locationId": "string",
  
  "player1Id": "string",
  "player1Name": "string",
  "player1AvatarUrl": "string",
  "player1Confirmed": "boolean",
  "player1Cheers": "number",
  "player1Justification": "string (optional)",
  
  "player2Id": "string (nullable)",
  "player2Name": "string (nullable)",
  "player2AvatarUrl": "string",
  "player2Confirmed": "boolean",
  "player2Cheers": "number",
  "player2Justification": "string (optional)",
  
  "winner": "string (Name of winner)",
  "score": "string (e.g., '6-4, 6-2')"
}
```

#### `locations`
Stores physical locations and their details.
```json
{
  "id": "string",
  "name": "string",
  "address": "string",
  "numberOfCourts": "number",
  "surface": "string",
  "googleMapsUrl": "string",
  "imageUrl": "string"
}
```

---

## API & Cloud Functions

Currently, most operations are performed directly from the Flutter client using the Firebase SDK with plans to migrate complex logic (like advanced scheduling algorithms or mass notifications) to Cloud Functions as the user base grows.

### Implemented Logic (Client-Side)

1.  **Bracket Generation**: 
    -   **Automatic**: Randomly shuffles approved participants and generates a single-elimination tree.
    -   **Manual**: Allows admin to reorder participants via drag-and-drop before generation.
    -   **Conflict Detection**: Checks for time/court overlaps when scheduling/rescheduling.

2.  **Match Management**:
    -   **Confirmation**: Admins can mark players as 'Present'. If both are present, status auto-updates to 'Confirmed'.
    -   **Score Entry**: Updates individual match and advances winner in bracket (manual advancement in current version).

3.  **Social**:
    -   **Cheering**: Real-time counter updates on match cards.

## Security Rules Strategy
*   **Users**: Read public profile; Write own profile only.
*   **Tournaments**: Public Read; Admin Write.
*   **Matches**: Public Read; Admin Write (Score/Schedule); Authenticated User Write (Cheering).
*   **Locations**: Public Read; Admin Write.

