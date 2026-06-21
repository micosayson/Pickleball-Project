part of '../home_placeholder_page.dart';

class _MySessionPage extends StatelessWidget {
  const _MySessionPage({
    required this.court,
    required this.session,
    required this.status,
    required this.onShowUpcomingMatch,
    required this.onLeaveCourt,
  });

  final CourtSummary court;
  final EventSummary session;
  final PlayerEventStatusSummary? status;
  final VoidCallback? onShowUpcomingMatch;
  final Future<void> Function() onLeaveCourt;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PageHeader(
          title: 'Active Session',
          detail: '${court.name} - ${_eventTypeLabel(session.eventType)}',
          icon: Icons.notifications_active_rounded,
        ),
        const SizedBox(height: 16),
        _MySessionCard(
          court: court,
          session: session,
          status: status,
          onShowUpcomingMatch: onShowUpcomingMatch,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onLeaveCourt,
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Leave session'),
            style: _dangerOutlineButtonStyle(),
          ),
        ),
      ],
    );
  }
}
