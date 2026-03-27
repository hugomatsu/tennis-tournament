# Americano

## Overview

Originally a padel format, Americano is built around one promise: **every player is guaranteed the same number of matches**, regardless of results. There are no early eliminations in the group stage — everyone plays their full quota before standings are settled.

Players are divided into groups, but instead of playing only within their group, they face opponents from other groups in each round. Points accumulate in their home group standings. After all rounds are played, the top performers from each group meet in a decider match to determine who advances to the final bracket.

---

## Why it's different from Open Tennis

| | Open Tennis | Americano |
|---|---|---|
| Group matches | Round-robin within the group | Cross-group only — never faces own group |
| Match count | Depends on group size | Fixed, guaranteed for everyone |
| Who advances | Top N go directly to bracket | Top 2 play a decider; only the winner advances |
| Bracket entry | Automatic from standings | Must win the group decider |

---

## Phases

### Phase 1 — Cross-Group Rounds

Each player plays a fixed number of matches (`guaranteedMatches`) against players randomly drawn from **other groups**. No player faces anyone from their own group during this phase.

Each win earns points that count toward the player's **home group standings**. At the end of the phase, players are ranked within their group by those accumulated points.

**Tiebreaker order (within group):**
1. Points
2. Wins
3. Set differential
4. Game differential

**Variation — opponent selection:**

| Mode | How opponents are picked each round |
|---|---|
| `random` (default) | Fully random from other groups, avoiding rematches |
| `ranked` (Mexicano style) | After round 1, top-ranked face top-ranked, bottom face bottom |

The `ranked` mode is sometimes called **Mexicano** in padel and creates more competitive late-round matches. Both modes still count points to the home group.

---

### Phase 2 — Group Decider

After all cross-group rounds are completed, the **top 2 players in each group** play one match against each other.

- **Winner** → advances to the playoff bracket
- **Loser** → eliminated

Players who finished 3rd or 4th in their group are eliminated without playing a decider. They still played their full `guaranteedMatches` quota.

**Match count per player:**

| Finish in group | Matches played |
|---|---|
| 3rd or 4th | `guaranteedMatches` (e.g. 5) |
| 2nd (lost decider) | `guaranteedMatches` + 1 |
| 1st (won decider) | `guaranteedMatches` + 1 + bracket matches |

---

### Phase 3 — Playoff Bracket

Group decider winners enter a standard single-elimination bracket (mata-mata). One player per group advances, so the bracket size equals the number of groups.

Seeding in the bracket follows the overall cross-group ranking (total points across all rounds), so the best performers face each other only in later rounds.

---

## Configuration

| Parameter | Description | Common values |
|---|---|---|
| `playersPerGroup` | Fixed group size | 4 |
| `guaranteedMatches` | Cross-group matches every player plays | 5 |
| `pointsPerWin` | Points for a win in cross-group rounds | 2 or 3 |
| `opponentSelection` | How cross-group opponents are picked | `random` or `ranked` |
| `groupDecider` | Whether top 2 play a decider or both advance | `true` (default) / `false` |

### `groupDecider: false` variation

When disabled, the top 1 (or top N) from each group advances directly to the bracket based on standings alone — no decider match. This is closer to pure Americano from padel, and is simpler to run but removes the drama of a head-to-head decider.

---

## Example

**16 players, 4 groups of 4, 5 guaranteed matches:**

```
Groups: A (p1, p2, p3, p4)  B (p5, p6, p7, p8)
        C (p9, p10, p11, p12)  D (p13, p14, p15, p16)

Phase 1 — Cross-group rounds (5 matches each)
  Round 1: p1 vs p6, p2 vs p7, p3 vs p8 ...  (all cross-group)
  Round 2: p1 vs p10, p2 vs p13 ...
  ... 5 rounds total

Group standings after 5 rounds:
  Group A: p1 (12pts) > p3 (9pts) > p2 (6pts) > p4 (3pts)
  Group B: p6 (12pts) > p5 (9pts) > ...
  ...

Phase 2 — Group Deciders
  A: p1 vs p3  →  p1 wins, advances
  B: p6 vs p5  →  p5 wins, advances
  C: p9 vs p11 →  p9 wins, advances
  D: p14 vs p13 → p14 wins, advances

Phase 3 — Bracket (4 players)
  SF: p1 vs p14 | p5 vs p9
  Final: winners
```

---

## Code identifier

`tournamentType: 'americano'`
