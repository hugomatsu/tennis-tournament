# Grupos + Chave Rankeada (Seeded Playoff)

## Overview

Three-phase format designed to maximize fairness across the whole tournament:

1. **Group stage** — round-robin within each group, every player gets guaranteed matches.
2. **Cross-group ranking** — all qualifiers are ranked by a unified index across groups, rewarding consistent performance.
3. **Seeded single-elimination bracket** — the best-ranked players receive byes and favorable positioning; top seeds don't face each other until the later rounds.

The key differentiator from a standard groups + playoff format is the **seeded bracket placement**: instead of randomly drawing qualified players, they are placed according to their overall ranking, giving the best performers a structural advantage in the knockout stage.

---

## Phase 1 — Group Stage

### Group composition

Players are divided into groups of roughly equal size. Because the total number of players rarely divides evenly, groups may differ by one player.

| Variation | Description |
|---|---|
| **Equal groups** | All groups have the same number of players (e.g. 5 groups × 3 players = 15 players) |
| **One larger group** | One group has N+1 players to absorb the remainder (e.g. 4 groups × 3 + 1 group × 4 = 16 players) |
| **Multiple larger groups** | The remainder is spread across several groups (e.g. 17 players → 2 groups of 4, 3 groups of 3) |

### Round-robin within each group

Every player faces every other player in their group exactly once. Number of matches per player = group size − 1.

### Equalization rule (for unequal groups)

When groups have different sizes, players in larger groups play more matches — which inflates their stats. To keep the cross-group ranking fair, each player in an oversized group has their **best single result discarded** before computing their ranking index.

This ensures everyone's index is calculated from the same number of matches (= smallest group size − 1).

> Example: Groups of 3 → each player plays 2 matches. One group of 4 → each player plays 3 matches. The group-of-4 players have their best match result removed, so the index is based on 2 matches for everyone.

**Variation — no equalization:** some formats skip this rule and accept that larger-group players have a slight statistical advantage. Use this when all groups are the same size (no equalization needed) or when the organizer deliberately wants to reward playing in a harder group.

### Standings per group

Results within each group are tracked independently. Tiebreaker order:

1. **Points** — configurable per win (common values: 2 or 3)
2. **Wins**
3. **Set differential** — sets won minus sets lost across all counted matches
4. **Game differential** — games won minus games lost across all counted matches
5. **Head-to-head** — direct result between tied players (if applicable)

---

## Phase 2 — Cross-Group Ranking

After the group stage, all qualified players (top N from each group) are merged into a single ranked list using the same tiebreaker order above, but now applied across groups. This produces a global seed number (1 = best overall) used for bracket placement.

**Variation — group winner priority:** some formats ensure group winners are always seeded above runners-up from other groups, regardless of raw stats. This rewards winning the group over being the second-best in a weak group.

---

## Phase 3 — Seeded Bracket

### Bracket size

The bracket is sized to the next power of 2 above the number of qualifiers (8, 16, 32, …). Empty slots are filled with byes.

| Qualifiers | Bracket size | Byes |
|---|---|---|
| 10 | 16 | 6 |
| 12 | 16 | 4 |
| 6 | 8 | 2 |
| 8 | 8 | 0 |

### Seeded placement

Seeds are placed into the bracket so that:
- The **#1 seed** and **#2 seed** are on opposite halves — they can only meet in the final.
- The **#3 and #4 seeds** are placed in the two quarter-bracket slots that don't contain #1 or #2.
- Lower seeds fill in around them.
- **Byes are assigned to the highest seeds first**, so the best players don't face each other early and have lighter opening rounds.

> Example with 10 players (16-bracket, 6 byes):
> - Seed #1 — bye in Round of 16, bye in Quarterfinal → enters at Semifinal
> - Seeds #2, #3, #4 — bye in Round of 16 → enter at Quarterfinal
> - Seeds #5–#10 — play in Round of 16; winners face #2, #3, #4 in QF

**Variation — how many byes the top seed receives:**

| Format | #1 seed enters at |
|---|---|
| Aggressive top-seeding | Semifinal (2 byes) |
| Standard | Quarterfinal (1 bye) |
| No top-seeding advantage | Round of 16 (0 byes, same as everyone) |

### Bracket progression

Standard single elimination from that point: win to advance, lose and you're out. Each round is labeled (Round of 16 / Oitavas, Quarterfinal / Quartas, Semifinal, Final).

---

## Configuration Summary

| Parameter | Description | Common values |
|---|---|---|
| Total players | Total enrolled | Any |
| Groups | Number of groups | 4–8 |
| Players per group | Target size per group | 3, 4, 5 |
| Equalization | Discard best result in larger groups | On / Off |
| Points per win | Points awarded in group stage | 2 or 3 |
| Qualifiers per group | How many advance | 1 or 2 |
| Bracket size | Power of 2 ≥ total qualifiers | Auto |
| Top-seed byes | How many rounds the #1 seed skips | 0, 1, or 2 |
| Tiebreaker order | Order of criteria for ranking ties | Points → Wins → Set diff → Game diff → H2H |

---

## Example Configurations

### Compact (small club, ~15 players)
- 5 groups × 3 players
- Top 2 qualify → 10 players
- 16-bracket, 6 byes
- #1 seed enters Semifinal, #2–#4 enter Quarterfinal

### Balanced (medium event, ~24 players)
- 6 groups × 4 players
- Top 2 qualify → 12 players
- 16-bracket, 4 byes
- #1–#4 seeds enter Quarterfinal (1 bye each)

### Large field (~32 players)
- 8 groups × 4 players
- Top 2 qualify → 16 players
- 16-bracket, no byes — fully seeded draw

### Conservative (no bye advantage)
- Any group configuration
- Top N qualify
- All qualifiers play from Round of 16; bracket is seeded but no one gets a bye
