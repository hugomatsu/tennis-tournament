# Open Tennis (Round-Robin Groups + Playoff)

**`tournamentType: 'openTennis'`**

## Overview

Two-phase format: a group stage where everyone plays multiple matches, followed by a single-elimination playoff for the top performers. Designed to give players more court time and a fair ranking before the knockout stage.

## Phases

### Phase 1 — Group Stage

Players are divided into groups. Within each group they play a full round-robin (every player faces every other player once). Points are accumulated; standings are tracked per group.

**Group distribution**

- `tournament.groupCount` sets the maximum players per group (default: 4).
- The app computes how many groups are needed so each group has at most `groupCount` players. Players are distributed as evenly as possible (some groups may have ±1 player).
- Groups are labeled A, B, C, …

**Standings**

Each match result updates the group standings in Firestore (`/tournaments/{id}/standings`):

| Outcome | Effect |
|---|---|
| Win | +`pointsPerWin` points, +1 win, +1 played |
| Loss | +1 loss, +1 played |

Standings are sorted by points descending.

### Phase 2 — Playoff Bracket

After all group matches are completed, the top `advanceCount` players from each group advance to a single-elimination playoff.

**Seeding options** (controlled by `matchRules.scoringMode`):

| `scoringMode` | Behaviour |
|---|---|
| `'flat'` (default) | 1st-seeds face 2nd-seeds from opposite groups (cross-seeding) |
| `'variable'` | Players from the same group face each other in the first playoff round |

The playoff bracket follows the same single-elimination rules as Mata-Mata.

---

## Match Format Options

Configured via `matchRules.matchFormat`:

### Round-Robin (`'roundRobin'`)

Default. Each player plays only against others in their own group.

### Cross-Group (`'crossGroup'`)

Each player plays the full intra-group round-robin **plus** extra matches against players from other groups. Points from cross-group matches count toward the player's own group standings.

- `matchRules.matchesPerPlayer` — number of extra cross-group matches each player gets (default: 5, configurable in the tournament creation UI).

---

## Configuration

| Field | Description |
|---|---|
| `groupCount` | Max players per group (controls how many groups are created) |
| `pointsPerWin` | Points awarded to the winner of each group-stage match (default: 3) |
| `advanceCount` | How many players from each group advance to the playoff (default: 1) |
| `matchRules.matchFormat` | `'roundRobin'` or `'crossGroup'` |
| `matchRules.scoringMode` | `'flat'` (cross-seeded playoff) or `'variable'` (same-group playoff) |
| `matchRules.matchesPerPlayer` | Extra cross-group matches per player (only for `crossGroup` format) |

---

## Service

`OpenTennisService` (`lib/features/tournaments/application/open_tennis_service.dart`)

Key methods:

| Method | Purpose |
|---|---|
| `generateGroupMatches` | Creates round-robin matches for each group |
| `generateCrossGroupMatches` | Creates intra-group + cross-group matches |
| `updateStandingsAfterMatch` | Updates wins/losses/points in Firestore after a match result |
| `isGroupStageComplete` | Returns `true` when all group/cross matches are finished |
| `generatePlayoffBracket` | Reads standings, selects qualified players, and generates the playoff |
