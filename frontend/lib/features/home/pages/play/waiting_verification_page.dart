part of '../home_placeholder_page.dart';

class _WaitingVerificationPage extends StatelessWidget {
  const _WaitingVerificationPage({
    required this.court,
    required this.match,
    required this.scoreSubmission,
    required this.onRefreshStatus,
  });

  final CourtSummary court;
  final PlayMatchSummary match;
  final PlayerScoreSubmissionSummary? scoreSubmission;
  final Future<void> Function() onRefreshStatus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: _VerificationPanel(
        court: court,
        match: match,
        scoreSubmission: scoreSubmission,
        onRefreshStatus: onRefreshStatus,
      ),
    );
  }
}
