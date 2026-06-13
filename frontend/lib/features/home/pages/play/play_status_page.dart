part of '../home_placeholder_page.dart';

class _PlayStatusPage extends StatelessWidget {
  const _PlayStatusPage({
    required this.fullName,
    required this.selectedCourt,
    required this.activeSession,
    required this.matchFinished,
    required this.onOpenCourts,
    required this.onShowSessions,
    required this.onShowMySession,
  });

  final String fullName;
  final CourtSummary? selectedCourt;
  final EventSummary? activeSession;
  final bool matchFinished;
  final VoidCallback onOpenCourts;
  final VoidCallback onShowSessions;
  final VoidCallback onShowMySession;

  @override
  Widget build(BuildContext context) {
    final title = activeSession == null
        ? 'Ready for the next rally, $fullName?'
        : matchFinished
        ? 'Your match is waiting for verification'
        : 'You are checked in and queued';
    final detail = activeSession == null
        ? 'Choose a court, review its sessions, then check in when you arrive.'
        : matchFinished
        ? 'After the queue master verifies the result, you return to the queue.'
        : 'Stay in My session until the next match assignment is ready.';

    return Column(
      children: [
        _HeroPanel(title: title, detail: detail),
        const SizedBox(height: 16),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(
                icon: activeSession == null
                    ? Icons.route_rounded
                    : Icons.fact_check_rounded,
                title: 'Play status',
              ),
              const SizedBox(height: 14),
              _StatusActionCard(
                icon: selectedCourt == null
                    ? Icons.location_on_rounded
                    : activeSession == null
                    ? Icons.event_available_rounded
                    : Icons.notifications_active_rounded,
                title: selectedCourt == null
                    ? 'No court selected'
                    : activeSession == null
                    ? selectedCourt!.name
                    : activeSession!.name,
                detail: selectedCourt == null
                    ? 'Pick a court to see its live sessions.'
                    : activeSession == null
                    ? 'Review available sessions for this court.'
                    : 'Open your current session and queue status.',
                actionLabel: selectedCourt == null
                    ? 'Choose court'
                    : activeSession == null
                    ? 'View sessions'
                    : matchFinished
                    ? 'Return to queue'
                    : 'View my session',
                onPressed: selectedCourt == null
                    ? onOpenCourts
                    : activeSession == null
                    ? onShowSessions
                    : onShowMySession,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
