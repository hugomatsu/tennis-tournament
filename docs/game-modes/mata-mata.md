# Mata-Mata (Single Elimination)

**`tournamentType: 'mataMata'`**

---

## Overview

Classic knockout bracket. A player loses one match and is eliminated. The bracket advances until a single champion remains.

Supports an optional **Repescagem** (losers bracket) flag that gives eliminated players a second chance, without changing the tournament type.

---

## How it works

1. Players are randomly seeded into a bracket sized to the next power of 2 (e.g. 8 players → 8-slot bracket, 6 players → 8-slot bracket with 2 byes).
2. Byes are resolved automatically — the player with the bye advances as if they won.
3. After each match the winner progresses to the next round; the loser is out (or enters the repescagem bracket if enabled).
4. Rounds are labeled numerically (`1`, `2`, `3`, …). The final match produces the champion.

---

## Bracket generation

- Players are shuffled before seeding (unless `shuffle: false` is passed).
- Match times are assigned from the tournament's `scheduleRules`. If no rules exist, slots are generated starting the next day at 09:00, respecting the location's court count and existing matches to avoid conflicts.
- Each match stores a `nextMatchId` pointer so the bracket view can draw the progression tree.

---

## Configuration

No group-stage settings apply. The relevant tournament fields are:

| Field | Type | Description |
|---|---|---|
| `format` | `String` | `'singles'` or `'doubles'` |
| `scheduleRules` | `List<DailySchedule>` | Date, start/end time, court count entries |
| `matchRules` | `Map<String, dynamic>` | Scoring, time, conduct, and walkover settings (see `match-rules.md`) |
| `repescagem` | `bool` | `false` (default). When `true`, activates the losers bracket — see below |
| `repescagemDepth` | `int` | `1` (default). How many main-bracket rounds feed losers into the repescagem. `1` = round-1 losers only; `2` = rounds 1 and 2; etc. |

---

## Repescagem (Losers Bracket)

> **Status: not yet implemented — documented for future development.**
> Planned flag: `matchRules['repescagem'] = true`

### What it is

A parallel bracket that gives eliminated players a second (and final) chance. Used in Brazilian club tennis to guarantee every player at least 2 matches and to crown both a main champion and a consolation champion.

### Variants

#### Consolation (Repescagem Simples) — recommended starting point

Only losers from **Round 1** of the main bracket enter the consolation draw. They form their own independent single-elimination bracket played in parallel.

```
Main Bracket              Consolation Bracket
─────────────             ───────────────────
R1: A vs B → A            B enters consolation
R1: C vs D → C            D enters consolation
R1: E vs F → E            F enters consolation
R1: G vs H → G            H enters consolation
                              ↓
R2: A vs C → …            Consolation R1: B vs D → …
R2: E vs G → …            Consolation R1: F vs H → …
                              ↓
…                         Consolation Final → Consolation Champion
Final → Champion
```

**Result:** every player is guaranteed at least 2 matches. Two independent titles are awarded.

`repescagemDepth: 1` (default when repescagem is enabled)

---

#### Double Elimination (Repescagem Completa)

Players are eliminated only after **two losses**. Losers from any round of the main (winners) bracket drop into the losers bracket for a second chance. The losers bracket has its own rounds that run in parallel.

```
Winners Bracket (WB)       Losers Bracket (LB)
────────────────────       ───────────────────
WB R1 losers  ──────────►  LB R1
WB R2 losers  ──────────►  LB R2  ◄── LB R1 winners
WB R3 losers  ──────────►  LB R3  ◄── LB R2 winners
…
WB Final                   LB Final
     │                          │
     └──────── Grand Final ─────┘
                   │
         if WB winner wins → Champion
         if LB winner wins → Bracket Reset (one more match)
```

**Result:** the champion has zero or one loss; the runner-up has exactly one loss.

`repescagemDepth` is ignored in this variant — use `repescagemType: 'doubleElimination'` (see configuration below).

---

### Recommended configuration fields (future)

These fields do not exist in the data model yet. Add them to `matchRules` when implementing:

| Field | Type | Default | Description |
|---|---|---|---|
| `repescagem` | `bool` | `false` | Enable losers bracket |
| `repescagemType` | `String` | `'consolation'` | `'consolation'` or `'doubleElimination'` |
| `repescagemDepth` | `int` | `1` | Rounds that feed into consolation (consolation type only) |
| `repescagemTitle` | `String` | `'Consolação'` | Display name for the consolation bracket |

### Implementation notes

- **Consolation** is simpler to implement first: after Round 1 of the main bracket is fully generated, collect all Round 1 losers and run `SingleEliminationService.generateBracket` on them with a `parentBracket: 'consolation'` tag.
- **Double Elimination** requires tracking bracket origin per match (`winnersBracket` / `losersBracket`) and the grand-final reset logic. Significantly more complex to schedule and display.
- The bracket view (`BracketView`) would need a tab or toggle to switch between the main and consolation brackets, similar to how `openTennis` and `americano` show a `GroupStandingsView` + bracket.
- Match `category` or a new `bracketTag` field could be used to separate main-bracket matches from consolation matches in queries.

---

## Service

`SingleEliminationService` (`lib/features/tournaments/application/single_elimination_service.dart`)
