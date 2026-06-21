part of '../home_placeholder_page.dart';

class _SessionDetailsPage extends StatelessWidget {
  const _SessionDetailsPage({
    required this.court,
    required this.event,
    required this.onBack,
    required this.onJoinLobby,
  });

  final CourtSummary court;
  final EventSummary event;
  final VoidCallback onBack;
  final VoidCallback onJoinLobby;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PageHeader(
          title: 'Session Details',
          detail: '${court.name} - ${_eventTypeLabel(event.eventType)}',
          icon: Icons.fact_check_rounded,
          onBack: onBack,
        ),
        const SizedBox(height: 16),
        _SessionDetailsCard(
          court: court,
          event: event,
          onJoinLobby: onJoinLobby,
        ),
      ],
    );
  }
}
