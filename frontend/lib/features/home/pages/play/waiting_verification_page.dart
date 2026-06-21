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
    final isVerified = scoreSubmission?.status == 'verified';
    return Column(
      children: [
        _PageHeader(
          title: isVerified ? 'Victory' : 'Verification in Progress',
          detail: isVerified
              ? 'Verified result - return to queue when ready.'
              : 'Staff is reviewing the official result.',
          icon: isVerified
              ? Icons.emoji_events_rounded
              : Icons.hourglass_top_rounded,
        ),
        const SizedBox(height: 16),
        _VerificationPanel(
          court: court,
          match: match,
          scoreSubmission: scoreSubmission,
          onRefreshStatus: onRefreshStatus,
        ),
      ],
    );
  }
}
