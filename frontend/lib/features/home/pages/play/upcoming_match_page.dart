part of '../home_placeholder_page.dart';

class _UpcomingMatchPage extends StatelessWidget {
  const _UpcomingMatchPage({
    required this.court,
    required this.match,
    required this.onBack,
    required this.onGoToCourt,
    required this.onLeaveCourt,
  });

  final CourtSummary court;
  final PlayMatchSummary match;
  final VoidCallback onBack;
  final Future<void> Function() onGoToCourt;
  final Future<void> Function() onLeaveCourt;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PageHeader(
          title: 'Up Next',
          detail: 'Doubles match assignment',
          icon: Icons.sports_score_rounded,
          onBack: onBack,
        ),
        const SizedBox(height: 16),
        _UpcomingMatchCard(
          court: court,
          match: match,
          onGoToCourt: onGoToCourt,
        ),
        const SizedBox(height: 16),
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
