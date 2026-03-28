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
-   **Login/Register**: Email/Password.
-   **Onboarding**: Quick profile setup.

### 2. Home Tab
-   **Dashboard**: Active tournaments and simple stats.
-   **Debug Tools**: Seed data, simulate matches (for development).

### 3. Tournaments Tab
-   **List View**: Filterable list (Upcoming, In Progress).
-   **Tournament Detail**:
-       **Info**: Description, Link to Google Maps location.
-       **Bracket**: Interactive tree. Admins can click to reschedule/edit matches.
-       **Matches (Calendar)**: Day-by-day view of scheduled matches.
-       **Participants**: List of players (with avatars).
-   **Bracket Generation (Admin)**: Option for "Automatic" (random) or "Manual" (drag-and-drop reordering) generation.

### 4. Matches / Calendar
-   **Match Detail**:
-       **Public**: View players, time, location, status. "Cheer" button with animation.
-       **Admin**:
-           -   **Status Control**: Update status (Scheduled -> Confirmed -> Started -> Finished).
-           -   **Confirmation**: Checkboxes to confirm player attendance (Auto-confirms match if both present).
-           -   **Reschedule**: Pick new date/time with conflict detection.
-           -   **Score Entry**: Enter final score to advance bracket.

### 5. Profile Tab
-   **View**: Avatar, Name, Title (e.g., "Pro"), Stats (Wins/Losses).
-   **Edit Profile**:
-       -   **Photo**: Select from Media Library (Gallery) or take photo.
-       -   **Title**: Select from predefined list (Beginner, Pro, etc.) or type custom.
-       -   **Playing Since**: Date picker (Month/Year).
-       -   **Bio & Category**: Text fields.

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
