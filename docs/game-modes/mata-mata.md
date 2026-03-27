# Mata-Mata (Single Elimination)

**`tournamentType: 'mataMata'`**

## Overview

Classic knockout bracket. A player loses one match and is eliminated. The bracket advances until a single champion remains.

## How it works

1. Players are randomly seeded into a bracket sized to the next power of 2 (e.g. 8 players → 8-slot bracket, 6 players → 8-slot bracket with 2 byes).
2. Byes are resolved automatically — the player with the bye advances as if they won.
3. After each match the winner progresses to the next round; the loser is out.
4. Rounds are labeled numerically (`1`, `2`, `3`, …). The final match produces the champion.

## Bracket generation

- Players are shuffled before seeding (unless `shuffle: false` is passed).
- Match times are assigned from the tournament's `scheduleRules`. If no rules exist, slots are generated starting the next day at 09:00, respecting the location's court count and existing matches to avoid conflicts.
- Each match stores a `nextMatchId` pointer so the bracket view can draw the progression tree.

## Configuration

No group-stage settings apply. The relevant tournament fields are:

| Field | Description |
|---|---|
| `format` | `'singles'` or `'doubles'` |
| `scheduleRules` | List of `DailySchedule` entries (date, start/end time, court count) |
| `matchRules` | Scoring, time, conduct, and walkover settings (see `match-rules.md`) |

## Service

`SingleEliminationService` (`lib/features/tournaments/application/single_elimination_service.dart`)
