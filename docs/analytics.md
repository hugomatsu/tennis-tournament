# Analytics & Crashlytics Tracking Plan

This project uses Firebase Analytics and Firebase Crashlytics to monitor overall app health and user behaviors.

## Crashlytics
Firebase Crashlytics is configured to automatically track:
- Unhandled Flutter errors (caught via `FlutterError.onError`).
- Unhandled asynchronous errors (caught via `PlatformDispatcher.instance.onError`).

## Screen Views
Automatic screen view tracking is enabled via the `FirebaseAnalyticsObserver` registered within `GoRouter` in `lib/app.dart`. 
Every time a user navigates to a new route, a `screen_view` event is logged in Firebase Analytics. The `name` property of each `GoRoute` is used as the screen name (e.g., `TournamentsScreen`, `ProfileScreen`) to ensure clean and readable analytics reports instead of raw path strings.

## Analytics Events

We track standard and custom events to understand how users interact with the app. The following events are implemented using the `AnalyticsService`.

### Authentication & User Lifecycle
- `login`: Triggered when a user successfully logs in.
    - **Params**: `method` (String: email, google, apple)
- `sign_up`: Triggered when a new user registers.
    - **Params**: `method` (String: email, google, apple)
- `logout`: Triggered when a user logs out.

### Tournament Discovery & Engagement
- `view_tournament_list`: Triggered when a user views the list of tournaments.
- `view_tournament_detail`: Triggered when a user opens a specific tournament.
    - **Params**: `tournament_name` (String), `tournament_type` (String: openTennis, elimination)
- `share_tournament`: Triggered when a user clicks the "share" button for a tournament.
    - **Params**: `tournament_name` (String)
- `join_tournament_request`: Triggered when a user requests to join a tournament.
    - **Params**: `tournament_name` (String), `category_name` (String)
- `share_bracket`: Triggered when a user shares a tournament bracket (match nodes).
    - **Params**: `tournament_name` (String)

### Match Interactions
- `view_match_detail`: Triggered when a user opens a specific match details page.
- `follow_match`: Triggered when a user "stars" or follows a match.
- `share_match`: Triggered when a user shares a match status.
    - **Params**: `match_id` (String), `tournament_name` (String)
- `submit_match_score`: Triggered when an admin/scorekeeper inputs a match result.
    - **Params**: `match_id` (String), `tournament_name` (String)

### Admin / Core Actions
- `create_tournament`: Triggered when an admin successfully creates a new tournament.
    - **Params**: `tournament_type` (String)
- `generate_bracket`: Triggered when an admin generates the match schedule bracket for a tournament.
    - **Params**: `generation_method` (String: manual, automatic)

### Monetization & Profile
- `view_premium_offer`: Triggered when a user accesses the Premium Subscription page.
- `purchase_premium`: Triggered when a user subscribes to the premium plan (simulated).
- `update_profile`: Triggered when a user saves updates to their profile.
