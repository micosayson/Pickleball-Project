# Figma to Repo Mapping

This document maps the Figma player frames to the Flutter routes and screens in the repo.

## Figma Prototype Test Note

The shared prototype was tested from:

`https://www.figma.com/proto/vwTqKf6e1pt2sMOciKOJUM/Untitled?node-id=0-1&t=eH18zXW3uqOUj3uR-1`

The prototype opens into the session/payment/check-in branch rather than the earlier full register/discover branch. Hotspot testing showed that most main content cards advance the happy path, while the bottom nav labels are mostly static in the prototype.

## Player Flow Order

1. `Session Details` (`33-590`)
2. `Complete Payment` (`33-755`)
3. `Schedule / Your Schedule` (`33-2350`)
4. `Session Details / Queue Lobby` (`33-1220`)
5. `Active Session / In Queue` (`33-929`)
6. `Up Next` (`33-1070`)
7. `Live Match` (`33-1155`)
8. `Verification in Progress` (`33-875`)
9. `Victory` (`33-2034`)
10. `Return to Queue` back to `Active Session / In Queue`

The app keeps the earlier auth, court discovery, court details, and session list pages because they are required for the real backend-backed flow before a player reaches the tested prototype branch.

## App Routes

Named routes live in `frontend/lib/core/navigation/app_routes.dart`.

- `/onboarding` -> `OnboardingPage`
- `/login` -> `LoginPage`
- `/register` -> `RegisterPage`
- `/home` -> `HomePlaceholderPage`
- `/player/play` -> `HomePlaceholderPage`
- `/player/courts` -> `HomePlaceholderPage`
- `/player/sessions` -> `HomePlaceholderPage`
- `/player/discover-courts` -> `HomePlaceholderPage` compatibility alias
- `/player/dashboard` -> `DashboardPage`
- `/player/matches` -> `MatchesListPage`
- `/player/notifications` -> `NotificationsPage`
- `/player/profile-history` -> `ProfileHistoryPage`
- `/player/book-private-court` -> `BookingsPage`
- `/player/payment` -> `PaymentFlowPage`

## Shell Navigation

The signed-in shell now follows the tested Figma bottom nav:

- `Play`: starts the core player route and contains the live open-play flow.
- `Courts`: court discovery and court details entry.
- `Matches`: embeds the matches frame content.
- `Sessions`: schedule/session summary content.
- `Profile`: embeds the player profile and history frame content.

Notifications are opened from the top `RallyHub` header bell, matching the prototype's header treatment.

## Flow Mapping

- `Play` / `Discover Courts` -> `HomePlaceholderPage` / `_DiscoverOrFlowTab`
- `Courts` -> `HomePlaceholderPage` / `_DiscoverCourtsTab`
- `Court Details View Page` -> `CourtDetailsPage`
- `Session Details` -> `frontend/lib/features/home/pages/play/session_details_page.dart`
- `Complete Payment` -> `frontend/lib/features/home/pages/play/payment_step_page.dart`
- `Schedule / Your Schedule` -> `frontend/lib/features/home/pages/play/schedule_page.dart`
- `Active Session / In Queue` -> `frontend/lib/features/home/pages/play/my_session_page.dart`
- `Up Next` -> `frontend/lib/features/home/pages/play/upcoming_match_page.dart`
- `Live Match` -> `frontend/lib/features/home/pages/play/active_match_page.dart`
- `Match Result / score entry` -> `frontend/lib/features/home/pages/play/match_result_page.dart`
- `Verification in Progress` -> `frontend/lib/features/home/pages/play/waiting_verification_page.dart`
- `Victory` -> verified state inside `waiting_verification_page.dart`

## Deferred Frames

- `Book Private Court Flow` and `Select Timeslot (with Nav)` -> `BookingsPage`
- `Payment Flow` compatibility route -> `PaymentFlowPage`

Private court booking/payment frames remain visible as unavailable states until booking and payment backend work is implemented. The player open-play path now includes the Figma `Complete Payment` and `Your Schedule` screens as functional routing steps before the live check-in API call.
