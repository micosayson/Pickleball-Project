part of '../home_placeholder_page.dart';

class _MatchResultPage extends StatelessWidget {
  const _MatchResultPage({
    required this.court,
    required this.matchFinished,
    required this.onMatchFinished,
  });

  final CourtSummary court;
  final bool matchFinished;
  final VoidCallback onMatchFinished;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _PageHeader(
          title: 'Match result',
          detail:
              'Confirm that the game is done. The queue master handles verification before the player returns to queue.',
          icon: Icons.task_alt_rounded,
        ),
        const SizedBox(height: 16),
        _MatchResultCard(
          court: court,
          matchFinished: matchFinished,
          onMatchFinished: onMatchFinished,
        ),
      ],
    );
  }
}
