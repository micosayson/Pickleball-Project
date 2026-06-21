part of '../home_placeholder_page.dart';

class _SessionDetailsPage extends StatelessWidget {
  const _SessionDetailsPage({
    required this.court,
    required this.event,
    required this.onBack,
    required this.onJoinLobby,
    required this.actionLabel,
    required this.actionIcon,
    this.showQueueLobby = false,
  });

  final CourtSummary court;
  final EventSummary event;
  final VoidCallback onBack;
  final VoidCallback onJoinLobby;
  final String actionLabel;
  final IconData actionIcon;
  final bool showQueueLobby;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PageHeader(
          title: 'Session Details',
          detail: '',
          icon: Icons.share_rounded,
          onBack: onBack,
        ),
        _SessionDetailsCard(
          court: court,
          event: event,
          onJoinLobby: onJoinLobby,
          actionLabel: actionLabel,
          actionIcon: actionIcon,
          showQueueLobby: showQueueLobby,
        ),
      ],
    );
  }
}
