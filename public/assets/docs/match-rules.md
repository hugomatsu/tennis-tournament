# Match Rules Configuration

This document defines a composable match rules system for Entre Sets. Instead of writing free-text rules, tournament admins toggle/select structured options to build the ruleset. Players see a clean, formatted summary on the tournament info tab.

---

## Goal

- Admins configure rules quickly via toggles, dropdowns, and number inputs.
- The same UI is reused for creating and editing tournament rules.
- Players see the rules rendered as a formatted card on the tournament Info tab.
- Rules are stored as a structured JSON object on the tournament document.

---

## Rule Categories

### 1. Scoring Format

| Option | Type | Values | Default |
|---|---|---|---|
| **Sets to win** | Dropdown | 1, 2, 3 | 2 |
| **Games per set** | Dropdown | 4, 6, 8 | 6 |
| **Advantage (deuce)** | Toggle | On / Off | Off |
| **Tiebreak at set end** | Toggle | On / Off | On |
| **Tiebreak points** | Number | 7, 10 | 7 |
| **Final set is match tiebreak** | Toggle | On / Off | Off |
| **Match tiebreak points** | Number (shown if above is On) | 10, 15 | 10 |

**Common presets:**
- **Quick Match**: 1 set to 6, no advantage, tiebreak at 7 (fast casual format)
- **Standard Amateur**: 2 sets to 6, no advantage, tiebreak at 7, final set match tiebreak to 10
- **Full Match**: 3 sets to 6, advantage on, tiebreak at 7

### 2. Time Rules

| Option | Type | Values | Default |
|---|---|---|---|
| **Match duration limit** | Toggle + Number | Off / 60, 90, 120 min | 90 min |
| **Warm-up time** | Dropdown | 0, 3, 5 min | 5 min |
| **Rest between sets** | Dropdown | 0, 1, 2, 3 min | 2 min |
| **Changeover time** | Dropdown | 60s, 90s | 90s |

### 3. Court & Conduct

| Option | Type | Values | Default |
|---|---|---|---|
| **Self-refereeing** | Toggle | Yes / No | Yes |
| **Let serve replayed** | Toggle | Yes / No | Yes |
| **Code of conduct** | Toggle | Enforce / Relaxed | Relaxed |
| **Ball type** | Text (optional) | Free text | - |

### 4. Walkover & No-Show

| Option | Type | Values | Default |
|---|---|---|---|
| **Confirmation deadline** | Dropdown | 1h, 2h, 6h, 12h, 24h before match | 2h |
| **No-show grace period** | Dropdown | 5, 10, 15 min | 15 min |
| **No-show result** | Dropdown | Walkover (W.O.) / Reschedule | W.O. |

### 5. Open Tennis Mode (Group Stage)

These are already on the tournament model but should appear in the rules card:

| Option | Source | Display |
|---|---|---|
| **Points per win** | `tournament.pointsPerWin` | "3 points per win" |
| **Players per group** | `tournament.groupCount` | "4 players per group" |
| **Advance from group** | `tournament.advanceCount` | "Top 1 advances to playoff" |

---

## Data Model

Add a `matchRules` map to the `Tournament` model:

```dart
// On Tournament model
final Map<String, dynamic> matchRules; // default: {}
```

```json
{
  "setsToWin": 2,
  "gamesPerSet": 6,
  "advantage": false,
  "tiebreak": true,
  "tiebreakPoints": 7,
  "finalSetMatchTiebreak": true,
  "matchTiebreakPoints": 10,
  "matchDurationMinutes": 90,
  "warmupMinutes": 5,
  "restBetweenSetsMinutes": 2,
  "changeoverSeconds": 90,
  "selfRefereeing": true,
  "letServeReplayed": true,
  "codeOfConduct": "relaxed",
  "ballType": "",
  "confirmationDeadlineHours": 2,
  "noShowGraceMinutes": 15,
  "noShowResult": "walkover"
}
```

---

## Admin UI — Rules Editor

A section in Create/Edit Tournament, below the format selection.

### Layout

1. **Preset selector** — row of 3 chips: "Quick Match", "Standard Amateur", "Full Match". Tapping a preset fills in the scoring fields. Selecting "Custom" (or changing any field after picking a preset) shows the full form.

2. **Scoring section** — collapsible card with the scoring options above.

3. **Time section** — collapsible card with time-related options.

4. **Court & Conduct section** — collapsible card.

5. **Walkover section** — collapsible card.

Each section uses the Material 3 expansion tile pattern, collapsed by default after a preset is chosen.

### Interaction

- Presets auto-fill all scoring values and collapse the section.
- Changing any value after a preset was chosen switches the label to "Custom".
- Toggles use `SwitchListTile`, dropdowns use `DropdownButtonFormField`, numbers use compact `TextFormField` with `keyboardType: number`.

---

## Player UI — Rules Display

On the tournament Info tab, below the description and above the participants list.

### Layout

A `Card` with the title "Match Rules" containing:

```
Match Rules
────────────────────────────
Scoring     2 sets to 6 games · No advantage · Tiebreak to 7
            Final set: Match tiebreak to 10

Time        90 min limit · 5 min warm-up · 2 min rest between sets

Court       Self-refereeing · Let replayed

No-show     Confirm 2h before · 15 min grace · Walkover on no-show
```

Each line uses an icon + label + value format. Empty/default sections are hidden.

---

## Implementation Plan

1. **Add `matchRules` field** to `Tournament` model (Freezed, default `{}`).
2. **Create `MatchRulesEditor` widget** — reusable form for create + edit flows.
3. **Create `MatchRulesCard` widget** — read-only display for the Info tab.
4. **Add presets** as static const maps in a `match_rule_presets.dart` file.
5. **Localize** all labels — preset names, section titles, option labels, formatted summaries.
6. **Wire into Create/Edit Tournament** — add the editor as a new collapsible section.
7. **Wire into Info tab** — show the card when `matchRules` is not empty.
