part of '../home_placeholder_page.dart';

class _UpcomingMatchPage extends StatelessWidget {
  const _UpcomingMatchPage({
    required this.court,
    required this.onBack,
    required this.onGoToCourt,
    required this.onLeaveCourt,
  });

  final CourtSummary court;
  final VoidCallback onBack;
  final VoidCallback onGoToCourt;
  final VoidCallback onLeaveCourt;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PageHeader(
          title: 'Upcoming match',
          detail:
              'This page gets full focus so the player can quickly see the court, teams, and next action.',
          icon: Icons.sports_score_rounded,
          onBack: onBack,
        ),
        const SizedBox(height: 16),
        _UpcomingMatchCard(court: court, onGoToCourt: onGoToCourt),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onLeaveCourt,
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Leave court'),
            style: _dangerOutlineButtonStyle(),
          ),
        ),
      ],
    );
  }
}
