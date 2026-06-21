part of '../home_placeholder_page.dart';

class _MatchResultPage extends StatelessWidget {
  const _MatchResultPage({
    required this.court,
    required this.match,
    required this.onSubmitScore,
  });

  final CourtSummary court;
  final PlayMatchSummary match;
  final Future<void> Function(int teamOneScore, int teamTwoScore) onSubmitScore;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _PageHeader(
          title: 'Match Result',
          detail: 'Enter the final score for staff review.',
          icon: Icons.task_alt_rounded,
        ),
        const SizedBox(height: 16),
        _MatchResultCard(
          court: court,
          match: match,
          onSubmitScore: onSubmitScore,
        ),
      ],
    );
  }
}
