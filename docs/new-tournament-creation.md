# New Tournament Creation — Multi-Step Flow

> **PRD & Design Spec** — Transforms the tournament creation form into a focused, step-by-step flow with progress tracking and bidirectional navigation.

---

## Why This Flow Works

| Problem | Solution |
|---|---|
| 15+ fields on a single screen overwhelm the user | Split into 4 focused steps, one "theme" at a time |
| Complex mode options cause confusion | Interactive cards with expandable descriptions replace a bare dropdown |
| Users abandon after getting lost mid-form | Progress indicator + local state cache allow resuming at any point |
| Hard to use on mobile at a tennis court | Fixed footer navigation + large touch targets for one-hand use |

---

## Tournament Type Visual Identity

Canonical icon and color for each mode — always use these; never hardcode per-widget.
Source of truth: [`lib/core/theme/tournament_type_theme.dart`](../lib/core/theme/tournament_type_theme.dart)

| Type | `tournamentType` | Icon | Color | Hex | Rationale |
|---|---|---|---|---|---|
| Mata-Mata | `mataMata` | `Icons.emoji_events` | 🔴 Red 600 | `#E53935` | Intensity — lose once, you're out |
| Open Tennis | `openTennis` | `Icons.groups` | 🔵 Blue 600 | `#1E88E5` | Structure — organised group stage |
| Americano | `americano` | `Icons.shuffle` | 🟠 Amber 700 | `#FF8F00` | Energy — rotation and cross-group mixing |

### Usage in Dart

```dart
final t = TournamentTypeTheme.of(tournament.tournamentType);

Icon(t.icon, color: t.color)

Container(
  decoration: BoxDecoration(
    color: t.background,   // color @ 12% opacity — for card/chip backgrounds
    border: Border.all(color: t.border),  // color @ 35% opacity — for outlines
  ),
)
```

---

## Step Architecture Overview

```
Step 1          Step 2          Step 3          Step 4
Visão     →    Logística  →    Regras     →    Revisão
Identity        Where/When      Match Rules     Final Review
& Mode
```

---

## Step 1 — Visão (Identity & Mode)

**Goal:** Establish the tournament's identity and format before anything else.

### Fields

- **Tournament Name** — text input with a trophy icon; required
- **Mode Selector** — vertical list of three selectable cards:

| Card | Label | Icon | Color | Short Description |
|---|---|---|---|---|
| `mataMata` | Mata-Mata | `emoji_events` | 🔴 Red | Perdeu uma vez, está fora |
| `openTennis` | Fase de Grupos | `groups` | 🔵 Blue | Todos jogam entre si no grupo; melhores avançam |
| `americano` | Americano | `shuffle` | 🟠 Amber | Grupos cruzados + decisivo + chave eliminatória |

> Tapping a card expands a description box with full mode explanation.

### Validation
- "Avançar" remains disabled until **both** a name is entered and a mode is selected.

---

## Step 2 — Logística (Where & When)

**Goal:** Define when, where, and how many courts are available.

### Fields

- **Location** — search bar for club/city; shows a static map preview on selection
- **Date Range** — single "Selecionar Período" button → calendar modal → displays start/end as read-only chips side by side
- **Court Capacity** — numeric stepper (− / +) for available courts
- **Playing Days** — row of 7 toggle chips (S T Q Q S S D)
- **Default Start Time** — time picker for the standard match start time

---

## Step 3 — Regras (Match Mechanics)

**Goal:** Define scoring and conduct rules with sensible presets to minimize friction.

### Rule Presets

A horizontal button group auto-populates the sections below:

| Preset | Description |
|---|---|
| **Rápido** | Short matches; ideal for large draws or time-constrained events |
| **Padrão** | Standard club-level rules |
| **Completo** | Full ATP-style rules with warm-up, rest times, and conduct rules |

> A preset is selected by default so users can proceed without customizing.

### Customizable Sections (collapsible accordions)

1. **Pontuação** — sets, games per set, tie-break rules
2. **Tempo** — warm-up time, rest between sets
3. **Quadra & Conduta** — surface type, ball brand
4. **W.O. & Ausência** — wait time before a forfeit is declared

---

## Step 4 — Revisão (Final Review)

**Goal:** Let the user review everything before committing.

### Layout

- **Summary cards** — scrollable list showing the choices from Steps 1–3 (Identity, Logistics, Rules); each card has an **Edit** shortcut that jumps back to that step
- **Additional Info** — large text area for prizes, contact info, sponsor mentions
- **Primary CTA** — full-width "Criar Torneio" button

---

## Navigation & Progress

### Progress Stepper

A horizontal stepper sits at the top of the screen throughout the flow.

```
●━━━━━●━━━━━●━━━━━●
1      2      3      4
```

| Circle State | Appearance | Behavior |
|---|---|---|
| Completed | Green + checkmark | Tappable — jumps back to that step immediately |
| Current | Green + pulse ring | Non-tappable |
| Pending | Grey | Non-tappable |

### Footer Navigation

Fixed at the bottom of every step:

| Position | Button | Notes |
|---|---|---|
| Left | **Voltar** | Text or outlined style; hidden on Step 1 |
| Right | **Avançar** | Solid green + chevron `›` icon; changes to **Criar Torneio** on Step 4 |

---

## State Management

### Local Cache (Draft Persistence)

Use a `TournamentDraftProvider` (or equivalent Riverpod notifier) to persist form data locally after each step is completed. If the user closes the app mid-flow, reopening the creation screen should offer to **resume the draft** or **start over**.

**Cache scope:** Steps 1–3 data is cached as soon as the user advances. Step 4 (submission) clears the draft on success.

### Back Navigation Behaviour

- Tapping **Voltar** or a completed stepper circle navigates back without losing entered data.
- Advancing again from an earlier step preserves data entered in later steps unless the user explicitly changes a field that invalidates it (e.g., changing the tournament mode resets Step 3 rules to the default preset).
