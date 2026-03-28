# In-App Tutorial System

This document describes the interactive tutorial (coach marks / guided walkthrough) for Entre Sets. The tutorial highlights key UI elements with overlays and tooltips, guiding users through the app's features step by step.

---

## Table of Contents

- [Overview](#overview)
- [Welcome Screen](#welcome-screen)
- [Skip & Replay Mechanism](#skip--replay-mechanism)
- [Analytics Events](#analytics-events)
- [Player Tutorial](#player-tutorial)
- [Tournament Admin Tutorial](#tournament-admin-tutorial)
- [Implementation Notes](#implementation-notes)

---

## Overview

The onboarding flow has two parts:

1. **Welcome Screen** — a quick, swipeable intro shown right after first login (before the main app). Highlights what the app does and lets the user choose to start the guided tutorial or skip straight into the app.
2. **Coach-Mark Tutorial** — an in-app walkthrough that overlays screens with a dimmed backdrop, spotlighting one UI element at a time with a tooltip. Users tap "Next" to advance or "Skip" to dismiss at any point.

There are **two tutorial tracks**:

| Track                | Triggered when                                                                     | Steps |
| -------------------- | ---------------------------------------------------------------------------------- | ----- |
| **Player**           | User taps "Start Tour" on the Welcome Screen (or replays later)                    | 10    |
| **Tournament Admin** | First time the user opens a tournament they own/admin (or replays later)            | 8     |

Both tracks are independent — a user who becomes an admin later will see the admin tutorial when relevant, even if they already completed the player tutorial.

---

## Welcome Screen

The Welcome Screen is the **first screen after login/registration** (replaces the direct navigation to `/tournaments`). It's a short, swipeable page-view with 3-4 slides — fast to read, no scrolling needed.

### Flow

```
Splash (video) -> Login/Register -> Welcome Screen -> Tournaments Screen
                                                   \-> Coach-mark tutorial (if user chose "Start Tour")
```

### Slides

Each slide has: an illustration/icon area (top 60%), a title, a subtitle (one line), and navigation dots at the bottom.

| # | Title                  | Subtitle                                                         | Illustration hint           |
|---|------------------------|------------------------------------------------------------------|-----------------------------|
| 1 | Welcome to Entre Sets  | Organize and join tennis tournaments with ease.                  | App logo + tennis court     |
| 2 | Find Tournaments       | Browse, filter, and register for tournaments near you.           | Tournament cards fanning    |
| 3 | Track Your Matches     | Get your schedule, confirm attendance, and follow results live.  | Calendar with match cards   |
| 4 | Ready to Play?         | _(final slide with CTA buttons)_                                 | Racket + checkmark          |

### Buttons (last slide)

| Button              | Action                                                                 |
| ------------------- | ---------------------------------------------------------------------- |
| **Start Tour**      | Navigate to `/tournaments` and auto-start the player coach-mark tutorial |
| **Skip, let me in** | Navigate to `/tournaments` directly, mark welcome as seen              |

### Rules

- Shown **only once** after first login. Controlled by `welcomeScreenSeen` flag in SharedPreferences.
- Swiping is smooth with a `PageView` and dot indicators.
- Each slide auto-advances after 4 seconds of inactivity (but pauses if user is swiping).
- Tapping anywhere advances to the next slide (except on the last slide where CTA buttons are shown).
- The entire welcome screen should take **under 15 seconds** to get through.

---

## Skip & Replay Mechanism

### Skipping

Users can skip at **two levels**:

1. **Welcome Screen** — the "Skip, let me in" button on the last slide (or a small "Skip" link visible on every slide at the top-right corner).
2. **Coach-Mark Tutorial** — a persistent "Skip" button on every tooltip step. Skipping the coach marks does NOT re-show the welcome screen.

Both actions mark the respective flags as completed and fire analytics events.

### Replay

Users can replay any tutorial they have previously completed.

**Profile > Help > Replay Tutorial**

On the Help screen (`/help`), a "Replay Tutorial" section is shown at the top, listing the available tutorials:

| Button                    | Action                                                        |
| ------------------------- | ------------------------------------------------------------- |
| **Player Tour**           | Navigates to `/tournaments` and starts the player coach-mark tutorial |
| **Tournament Admin Tour** | Navigates to the user's most recent tournament detail and starts the admin tutorial. If no tournament exists, shows a message to create one first. |
| **Welcome Screen**        | Re-shows the welcome slides (informational only, no tutorial auto-start) |

### Persistence

- `welcomeScreenSeen` — set to `true` after user completes or skips the welcome screen.
- `tutorialCompleted_player` — set to `true` after user completes or skips the player coach-mark tutorial.
- `tutorialCompleted_admin` — set to `true` after user completes or skips the admin coach-mark tutorial.
- `tutorialLastStepSeen_player` / `tutorialLastStepSeen_admin` — stores the index of the last step the user saw (for analytics correlation and potential resume).
- On first relevant screen load, check the flag. If `false`, auto-start.
- "Replay" buttons ignore the flag and force-start regardless.

---

## Analytics Events

Every tutorial interaction fires an analytics event so we can measure completion rates, identify drop-off points, and detect issues.

### Event Catalog

| Event Name                     | Fired When                                      | Parameters                                                                                     |
| ------------------------------ | ----------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| `tutorial_welcome_started`     | Welcome screen is shown                         | `source`: `first_login` / `replay`                                                             |
| `tutorial_welcome_slide_viewed`| User lands on a welcome slide                   | `slide_index`, `slide_title`                                                                   |
| `tutorial_welcome_completed`   | User reaches the last slide and taps a CTA      | `action`: `start_tour` / `skip`, `time_spent_ms`                                               |
| `tutorial_welcome_skipped`     | User taps "Skip" before the last slide          | `skipped_at_slide`: index, `time_spent_ms`                                                     |
| `tutorial_started`             | Coach-mark tutorial begins                      | `track`: `player` / `admin`, `source`: `welcome_cta` / `auto` / `replay`                      |
| `tutorial_step_viewed`         | A coach-mark step becomes visible               | `track`, `step_index`, `step_id` (e.g. `tournaments_tab`), `time_on_previous_step_ms`         |
| `tutorial_step_interaction`    | User taps "Next" on a step                      | `track`, `step_index`, `step_id`                                                               |
| `tutorial_skipped`             | User taps "Skip" during coach marks             | `track`, `skipped_at_step`: index, `skipped_at_step_id`, `total_steps`, `time_spent_ms`        |
| `tutorial_completed`           | User finishes the last coach-mark step          | `track`, `total_steps`, `time_spent_ms`                                                        |
| `tutorial_error`               | Something goes wrong (key not found, widget not mounted, navigation failure) | `track`, `step_index`, `step_id`, `error_type`, `error_message`              |
| `tutorial_replay_tapped`       | User taps a replay button on the Help screen    | `track`: `player` / `admin` / `welcome`                                                        |

### Key Metrics to Track (Dashboard)

| Metric                          | How to compute                                                                    |
| ------------------------------- | --------------------------------------------------------------------------------- |
| **Welcome completion rate**     | `tutorial_welcome_completed` / `tutorial_welcome_started`                         |
| **Tour start rate**             | `tutorial_started` (where source=`welcome_cta`) / `tutorial_welcome_completed` (where action=`start_tour`) |
| **Coach-mark completion rate**  | `tutorial_completed` / `tutorial_started` (per track)                             |
| **Drop-off step**               | Distribution of `skipped_at_step` from `tutorial_skipped` events                  |
| **Avg time per step**           | Mean of `time_on_previous_step_ms` from `tutorial_step_viewed` events             |
| **Error rate**                  | `tutorial_error` / `tutorial_step_viewed`                                         |
| **Replay rate**                 | `tutorial_replay_tapped` / unique users who completed a tutorial                  |

### Error Tracking

The `tutorial_error` event captures problems that would silently break the experience:

| `error_type`          | Description                                                       |
| --------------------- | ----------------------------------------------------------------- |
| `key_not_found`       | The `GlobalKey` for the target widget is null (widget not in tree) |
| `widget_not_mounted`  | The widget exists but its `RenderObject` is not mounted/laid out  |
| `navigation_failed`   | Cross-screen transition (e.g. step 6 -> 7) failed to navigate    |
| `timeout`             | Step waited too long for the target widget to appear (> 3s)       |
| `unknown`             | Catch-all for unexpected exceptions                               |

When a `tutorial_error` fires, the tutorial should **gracefully skip that step** and advance to the next one rather than crashing or freezing. If 3 consecutive errors occur, auto-dismiss the tutorial and fire a `tutorial_skipped` event with `skipped_at_step_id` indicating the failure point.

---

## Player Tutorial

Triggered on the **Tournaments screen** after first sign-up, then flows across screens as the user taps through.

### Step 1 — Bottom Navigation: Tournaments Tab

- **Highlight:** The "Tournaments" tab icon in the bottom navigation bar.
- **Tooltip:** "This is your home base. Browse all available tournaments, filter by status, and find your next match."
- **Position:** Above the bottom nav bar.

### Step 2 — Bottom Navigation: Schedule Tab

- **Highlight:** The "Schedule" tab icon.
- **Tooltip:** "Your personal match calendar. See all upcoming matches you're participating in or following, organized by date."
- **Position:** Above the bottom nav bar.

### Step 3 — Bottom Navigation: Profile Tab

- **Highlight:** The "Profile" tab icon.
- **Tooltip:** "Manage your profile, set your playing level, check your stats, and adjust your preferences."
- **Position:** Above the bottom nav bar.

### Step 4 — Notification Bell

- **Highlight:** The notification bell icon (top-right area).
- **Tooltip:** "Stay up to date. Match schedule changes, results, and announcements appear here. The badge shows unread count."
- **Position:** Below the icon.

### Step 5 — Tournament Search & Filters

- **Highlight:** The search bar and filter button at the top of the tournaments list.
- **Tooltip:** "Search tournaments by name or tap the filter icon to narrow by status: your tournaments, ones you're participating in, singles, doubles, or open registration."
- **Position:** Below the search bar.

### Step 6 — Tournament Card

- **Highlight:** The first tournament card in the list.
- **Tooltip:** "Each card shows the tournament name, cover image, status, number of players, and date range. Tap it to see full details."
- **Position:** Below the card.

### Step 7 — Tournament Detail: Info Tab

- **Highlight:** The "Info" tab inside the tournament detail screen.
- **Tooltip (auto-navigates into a tournament):** "The Info tab shows the tournament description, format, categories, location, and the list of participants."
- **Position:** Below the tab bar.

### Step 8 — Tournament Detail: Bracket Tab

- **Highlight:** The "Bracket" tab.
- **Tooltip:** "Once the bracket is generated, view the full match tree here. Tap any match to see details."
- **Position:** Below the tab bar.

### Step 9 — Tournament Detail: Calendar Tab

- **Highlight:** The "Calendar" tab.
- **Tooltip:** "See all scheduled matches on a calendar view. Dates with matches are marked so you can plan ahead."
- **Position:** Below the tab bar.

### Step 10 — Match Confirmation

- **Highlight:** A match card (or the confirm/decline buttons on the match detail).
- **Tooltip:** "When a match is scheduled, you'll be asked to confirm your attendance. You can confirm or decline — and if declining, provide a reason."
- **Position:** Above the buttons.

---

## Tournament Admin Tutorial

Triggered the first time a user lands on the **Tournament Detail screen** of a tournament they own or admin.

### Step 1 — Admin Actions Menu

- **Highlight:** The floating action menu button (bottom-right or top-right settings icon).
- **Tooltip:** "As a tournament admin, this menu gives you access to all management options: editing info, managing players, generating brackets, and more."
- **Position:** To the left of the button.

### Step 2 — Edit Tournament

- **Highlight:** The "Edit Tournament" option in the admin menu (expand the menu first).
- **Tooltip:** "Change the tournament name, description, cover image, location, dates, or format at any time before the tournament goes live."
- **Position:** Next to the menu item.

### Step 3 — Manage Participants

- **Highlight:** The "Manage Participants" option.
- **Tooltip:** "Review and approve player registration requests. You can also add players manually or remove approved participants. Once the tournament is in progress, the roster is locked."
- **Position:** Next to the menu item.

### Step 4 — Manage Categories

- **Highlight:** The "Manage Categories" option.
- **Tooltip:** "Set up match categories like Men's Singles, Mixed Doubles, etc. Each category has its own bracket, format, and match duration."
- **Position:** Next to the menu item.

### Step 5 — Schedule Settings

- **Highlight:** The "Schedule Settings" option.
- **Tooltip:** "Define available days, time slots, and number of courts for each date. You can also bulk-apply a schedule to multiple days at once."
- **Position:** Next to the menu item.

### Step 6 — Generate Bracket

- **Highlight:** The "Generate Bracket" option.
- **Tooltip:** "When registrations are finalized, generate the match bracket. Choose automatic (random draw) or manual (drag to reorder seeds). For Open Tennis mode, this also creates round-robin groups."
- **Position:** Next to the menu item.

### Step 7 — Manage Admins

- **Highlight:** The "Manage Admins" option.
- **Tooltip:** "Add co-administrators who can help manage the tournament. They'll have the same management capabilities as you, except deleting the tournament."
- **Position:** Next to the menu item.

### Step 8 — Share Tournament

- **Highlight:** The "Share" button.
- **Tooltip:** "Share a link to your tournament so players can find and register. The link works as a deep link — it opens directly in the app if installed."
- **Position:** Below the button.

---

## Implementation Notes

### Recommended Packages

- [`tutorial_coach_mark`](https://pub.dev/packages/tutorial_coach_mark) — coach-mark overlays with `GlobalKey` targeting, pulse animation, skip button, and finish/skip callbacks.
- [`smooth_page_indicator`](https://pub.dev/packages/smooth_page_indicator) — dot indicators for the welcome screen `PageView`.

### Architecture

```
lib/features/tutorial/
  domain/
    tutorial_step.dart          # Model: id, targetKey, title, description, position
    tutorial_track.dart         # Enum: player, admin
  data/
    tutorial_repository.dart    # Read/write completion & lastStepSeen flags (SharedPreferences)
    tutorial_steps_data.dart    # All step definitions for both tracks
  presentation/
    tutorial_controller.dart    # Riverpod controller: start, skip, complete, replay
    tutorial_overlay.dart       # Wrapper widget that triggers coach marks
    tutorial_analytics.dart     # Centralized event firing (wraps Firebase Analytics)
    welcome_screen.dart         # PageView with slides and CTA buttons
```

### GlobalKey Strategy

Each screen that participates in the tutorial should expose `GlobalKey`s for the elements being highlighted. Define them in a shared location (e.g., `tutorial_keys.dart`) so both the screen widgets and the tutorial controller can reference them.

```dart
// tutorial_keys.dart
class TutorialKeys {
  // Bottom nav
  static final tournamentsTab = GlobalKey();
  static final scheduleTab = GlobalKey();
  static final profileTab = GlobalKey();
  static final notificationBell = GlobalKey();

  // Tournaments screen
  static final searchBar = GlobalKey();
  static final filterButton = GlobalKey();
  static final firstTournamentCard = GlobalKey();

  // Tournament detail
  static final infoTab = GlobalKey();
  static final bracketTab = GlobalKey();
  static final calendarTab = GlobalKey();
  static final adminActionsMenu = GlobalKey();
  static final shareButton = GlobalKey();

  // Match
  static final confirmButton = GlobalKey();
}
```

### Cross-Screen Tutorial Flow

The player tutorial spans multiple screens (Tournaments list -> Tournament detail). Handle this by:

1. Starting the tutorial on the Tournaments screen (steps 1-6).
2. After step 6, programmatically navigate to a tournament detail screen.
3. Continue with steps 7-10 on the new screen.

Use the tutorial controller to manage this transition — listen for the step index and trigger navigation at the boundary.

### Analytics Integration

Create a `TutorialAnalytics` class that wraps Firebase Analytics and exposes typed methods for each event:

```dart
// tutorial_analytics.dart
class TutorialAnalytics {
  final FirebaseAnalytics _analytics;

  TutorialAnalytics(this._analytics);

  void welcomeStarted({required String source}) { ... }
  void welcomeSlideViewed({required int slideIndex, required String slideTitle}) { ... }
  void welcomeCompleted({required String action, required int timeSpentMs}) { ... }
  void welcomeSkipped({required int skippedAtSlide, required int timeSpentMs}) { ... }

  void tutorialStarted({required String track, required String source}) { ... }
  void stepViewed({required String track, required int stepIndex, required String stepId, int? timeOnPreviousStepMs}) { ... }
  void stepInteraction({required String track, required int stepIndex, required String stepId}) { ... }
  void tutorialSkipped({required String track, required int skippedAtStep, required String skippedAtStepId, required int totalSteps, required int timeSpentMs}) { ... }
  void tutorialCompleted({required String track, required int totalSteps, required int timeSpentMs}) { ... }
  void tutorialError({required String track, required int stepIndex, required String stepId, required String errorType, String? errorMessage}) { ... }
  void replayTapped({required String track}) { ... }
}
```

The controller should track a `Stopwatch` per step and for the entire tutorial session to populate `time_spent_ms` and `time_on_previous_step_ms`.

### Error Resilience

When a step fails to render (target key not found, widget not mounted, etc.):

1. Fire `tutorial_error` with the relevant `error_type`.
2. Skip to the next step automatically.
3. If 3 consecutive errors occur, dismiss the tutorial gracefully and fire `tutorial_skipped`.
4. Never crash or freeze the app — the tutorial is non-blocking UX.

### Localization

All tooltip and welcome screen strings should go through the localization system (`app_en.arb` / `app_pt.arb`). Suggested key pattern:

```json
"welcomeSlide1Title": "Welcome to Entre Sets",
"welcomeSlide1Subtitle": "Organize and join tennis tournaments with ease.",
"welcomeSlide4StartTour": "Start Tour",
"welcomeSlide4Skip": "Skip, let me in",

"tutorialPlayerStep1Title": "Tournaments",
"tutorialPlayerStep1Body": "This is your home base. Browse all available tournaments, filter by status, and find your next match.",
"tutorialAdminStep1Title": "Admin Menu",
"tutorialAdminStep1Body": "As a tournament admin, this menu gives you access to all management options."
```

### Navigation Flow

```
Splash (video)
  -> Login / Register
    -> Welcome Screen (first time only)
      -> "Start Tour" -> /tournaments + auto-start player coach marks
      -> "Skip, let me in" -> /tournaments (no coach marks)
    -> /tournaments (returning users, welcome already seen)

Profile screen
  -> Help screen (/help)
    -> "Replay Tutorial" section
      -> Tap "Welcome Screen" -> re-show welcome slides
      -> Tap "Player Tour" -> /tournaments + force-start player coach marks
      -> Tap "Tournament Admin Tour" -> most recent owned tournament + force-start admin coach marks
```
