# UI/UX Design & Navigation

## Navigation Strategy
We will use a **Shell-based Navigation** (likely using `go_router` in Flutter) to keep the Bottom Navigation Bar persistent across main sections.

### Bottom Navigation Tabs
1.  **Home**: Dashboard with active tournaments, news feed, and quick actions.
2.  **Tournaments**: List of all tournaments (Upcoming, Active, Past).
3.  **My Schedule**: Personal calendar of matches and availability settings.
4.  **Profile**: Player stats, bio, and settings.

## Screen Flow

### 1. Onboarding & Auth
-   **Splash Screen**: Animated logo.
-   **Login/Register**: Email/Password or Social Auth.
-   **Onboarding**: Quick profile setup (Name, Level, "Playing Since").

### 2. Home Tab
-   **Hero Section**: "Next Match" countdown (if active) or "Join a Tournament" CTA.
-   **News Feed**: Updates from tournaments.
-   **Quick Actions**: "Check In", "Enter Score".

### 3. Tournaments Tab
-   **List View**: Filterable list (Open, In Progress).
-   **Tournament Detail (Stack Push)**:
    -   Info & Rules.
    -   **Category Selection**: Choose division (e.g., "Men's A").
    -   **Bracket View**: Interactive tree diagram for selected category.
    -   **Standings**: Group stage tables.
    -   **Register Button**: If open.

### 4. My Schedule Tab
-   **Calendar View**: Visual representation of match days.
-   **Availability Manager**: Tap to toggle "Busy/Available" slots.
-   **Match Detail**: Opponent info, court location, "Cheer" button.

### 5. Profile Tab
-   **Header**: Avatar, Name, Title (e.g., "Weekend Warrior").
-   **Stats**: Win/Loss record, Rank.
-   **Edit Profile**: Update bio, preferred partner.

## Visual Identity (Premium Aesthetic)
-   **Theme**: Dark Mode default.
-   **Palette**:
    -   Background: Deep Charcoal / Black (`#121212`).
    -   Primary: Tennis Ball Neon (`#CCFF00`) or Electric Blue (`#2979FF`).
    -   Surface: Glassmorphism cards (semi-transparent with blur).
-   **Typography**: Modern Sans-Serif (e.g., `Outfit` or `Inter`).
-   **Interactions**: Smooth transitions, hero animations on cards.

## Mocks & Prototyping
**Recommendation**: We should create high-fidelity mocks for the **Home** and **Bracket** screens to validate the complex UI elements before coding.

### Concept Art
![Home Screen Concept](/Users/hugomatsumoto/.gemini/antigravity/brain/1ef0a050-f866-4813-a4c5-03711157efe5/home_screen_concept_1763906925134.png)
