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
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight:
            MediaQuery.sizeOf(context).height -
            MediaQuery.paddingOf(context).top,
      ),
      color: _liveSurface,
      child: _LiveMatchPanel(
        court: court,
        match: match,
        onFinishMatch: onShowMatchResult,
        onLeaveCourt: onLeaveCourt,
      ),
    );
  }
}
