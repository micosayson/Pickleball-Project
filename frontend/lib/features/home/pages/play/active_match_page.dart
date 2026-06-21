part of '../home_placeholder_page.dart';

class _ActiveMatchPage extends StatelessWidget {
  const _ActiveMatchPage({
    required this.court,
    required this.match,
    required this.onShowMatchResult,
    required this.onLeaveCourt,
  });

  final CourtSummary court;
  final PlayMatchSummary match;
  final VoidCallback onShowMatchResult;
  final Future<void> Function() onLeaveCourt;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _ScreenTitle(title: 'Live Match', subtitle: 'Tournament QF'),
        const SizedBox(height: 16),
        _LiveMatchPanel(
          court: court,
          match: match,
          onFinishMatch: onShowMatchResult,
          onLeaveCourt: onLeaveCourt,
        ),
      ],
    );
  }
}
