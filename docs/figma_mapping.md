# Figma → Repo Mapping

This document maps Figma frames (from the provided file) to the existing repo screens/components.

Source Figma frames observed:
- REGISTER (OPEN PLAY COMPETITIVE FLOW)
- Matches
- Session Details
- Active Match (Staff Verified)
- Upcoming Match
- My Session
- Verification in Progress
- Payment Flow
- Select Timeslot (with Nav)
- Notifications (with Nav)
- Player Profile & History
- Dashboard
- Discover Courts
- Book Private Court Flow
- Court Details View Page

Mapping to repo files (initial):
- Login / Register / Onboarding: `frontend/lib/features/auth/pages/*`
- Play flow pages: `frontend/lib/features/home/pages/play/*`
  - `Session Details` → `session_details_page.dart`
  - `My Session` → `my_session_page.dart`
  - `Upcoming Match` → `upcoming_match_page.dart`
  - `Active Match` → `active_match_page.dart`
  - `Match Result` → `match_result_page.dart`
  - `Verification in Progress` → `waiting_verification_page.dart`
- Courts discovery and details: `frontend/lib/features/home/pages/home_placeholder_page.dart` (`_CourtDiscoveryPanel`) and `court_details_page.dart` (scaffolded)
- Book Private Court: (scaffolded endpoints `backend/.../bookings.py` and `frontend/lib/features/home/pages/bookings_page.dart`)
- Payment Flow: (backend `payments.py` scaffolded; frontend page TBD)
- Dashboard: `frontend/lib/features/home/pages/dashboard_page.dart` (scaffolded)
- Notifications: `frontend/lib/features/home/pages/notifications_page.dart` (scaffolded)
- Matches list: `frontend/lib/features/home/pages/matches_list_page.dart` (scaffolded)
- Player Profile & History: `frontend/lib/features/home/pages/profile_history_page.dart` (scaffolded)

Next steps:
1. Centralize design tokens in `frontend/lib/core/styles/design_tokens.dart`.
2. Update auth and onboarding UI to match Figma (typography, spacing, button styles).
3. Implement Book Private Court end-to-end.
