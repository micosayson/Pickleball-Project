part of '../home_placeholder_page.dart';

class _MySessionPage extends StatelessWidget {
  const _MySessionPage({
    required this.court,
    required this.session,
    required this.registration,
    required this.prototypeMatch,
    required this.onShowUpcomingMatch,
    required this.onLeaveCourt,
  });

  final CourtSummary court;
  final EventSummary session;
  final EventRegistrationSummary? registration;
  final _PrototypeMatch prototypeMatch;
  final VoidCallback onShowUpcomingMatch;
  final VoidCallback onLeaveCourt;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PageHeader(
          title: 'My session',
          detail:
              'You are checked in. Stay here for queue status and your next match assignment.',
          icon: Icons.notifications_active_rounded,
        ),
        const SizedBox(height: 16),
        _MySessionCard(
          court: court,
          session: session,
          registration: registration,
          prototypeMatch: prototypeMatch,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onLeaveCourt,
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Leave court'),
                style: _dangerOutlineButtonStyle(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: onShowUpcomingMatch,
                icon: const Icon(Icons.sports_score_rounded, size: 18),
                label: const Text('View match'),
                style: _primaryButtonStyle(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
