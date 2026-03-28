# Score Counter (Placar)

This document specifies the requirements and design for the Score Counter feature in the Tennis Tournament Manager.

## Overview
A full-screen, immersive interface for counting tennis scores in real-time. It can be used as a standalone tool or integrated with a specific match from a tournament.

## User Stories

### General User
- **Bottom Menu Entry**: Access the score counter from a new bottom menu item.
- **Standalone Mode**: Use the counter without being tied to a specific game.
- **Match Integration**: Start counting from a match screen; auto-fills rules (advantage, sets, etc.) and player names.
- **Full-Screen Immersion**: The counter covers the entire screen for better visibility on the court.

### Scorekeeping Logic
- **Side-by-Side Scoring**: Left side for one player/pair, right side for the other.
- **Tap to Score**: Tap the right side to increase right player's score; left side for left player.
- **Official Tennis Rules**: 
  - Points: 0, 15, 30, 40, Game.
  - Deuce/Advantage: Support for "Advantage" or "No-Ad" (Golden Point) based on settings.
  - Sets and Games: Tracks current set, games within the set, and tiebreaks (7 or 10 points).
- **Undo Logic**: Revert the last point in case of a miss-click.
- **Time Tracking**: Display elapsed match time.

### Match Conclusion
- **Winner Declaration**: Automatically detect and show the winner when the match ends.
- **Result Sharing**: Option to copy match results (e.g., "6-4, 3-6, 10-8") to clipboard for sharing or manual entry.

---

## Technical Specifications

### Navigation & Entry Points
- **Bottom Navigation**: A new tab labeled "Placar" (Score) will be added to the main bottom navigation bar.
- **Quick Action**: A "Start Counter" button will be added to the `MatchDetailScreen` to launch the counter pre-filled with the match data.

### Data Integration
When tied to a `Match` document, the counter should:
1. **Load Rules**: Fetch `matchRules` from the parent `Tournament`.
2. **Setup Players**: Use names and IDs from the `Match` participants.
3. **Persist Results**: At the end of the match, provide a way to save the final score directly to the `Match` document in Firestore.

### UI/UX Design
- **High Contrast**: Large numbers for visibility under sunlight.
- **Vibrant Player Indicators**: Use player colors/avatars.
- **Gestures**: 
  - **Tap**: Increase score.
  - **Long Press**: Open menu for "Undo", "Reset", or "Edit Players".
- **Timer**: A prominent match timer at the top.
- **Fullscreen**: Use `SystemChrome` to hide the status and navigation bars for a truly immersive experience.

### State Management
Using **Riverpod** for the score state:
- `ScoreState`: { pointsA, pointsB, gamesA, gamesB, setsA, setsB, isTiebreak, server, matchTime }.
- `ScoreController`: Logic for incrementing, decrementing, and applying rules.

---

## Official Rules Logic (Reference)
- **Standard**: 0 -> 15 -> 30 -> 40 -> Game.
- **Deuce**: If 40-40, next point is Advantage (Ad-In/Ad-Out) unless No-Ad is active.
- **Tiebreak**: At 6-6 (or 4-4 in some formats), a tiebreak to 7 points (win by 2) is played.
- **Match Tiebreak**: Final set replaced by a tiebreak to 10 points (win by 2).
