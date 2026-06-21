part of '../home_placeholder_page.dart';

class _PlayFlowPage extends StatelessWidget {
  const _PlayFlowPage({
    required this.fullName,
    required this.selectedCourt,
    required this.courtEventsFuture,
    required this.selectedSession,
    required this.activeSession,
    required this.activeStatus,
    required this.displayMatch,
    required this.scoreSubmission,
    required this.playPage,
    required this.joinLobby,
    required this.onSubmitScore,
    required this.onOpenCourts,
    required this.onShowStatus,
    required this.onShowSessions,
    required this.onShowSessionDetails,
    required this.onShowPayment,
    required this.onShowSchedule,
    required this.onShowQueueLobby,
    required this.onSelectSession,
    required this.onShowMySession,
    required this.onShowUpcomingMatch,
    required this.onGoToCourt,
    required this.onShowMatchResult,
    required this.onRefreshStatus,
    required this.onLeaveCourt,
    required this.courtsFuture,
    required this.selectCourt,
    required this.openCourtDetails,
  });

  final String fullName;
  final CourtSummary? selectedCourt;
  final Future<List<EventSummary>>? courtEventsFuture;
  final EventSummary? selectedSession;
  final EventSummary? activeSession;
  final PlayerEventStatusSummary? activeStatus;
  final PlayMatchSummary? displayMatch;
  final PlayerScoreSubmissionSummary? scoreSubmission;
  final _PlayPage playPage;
  final Future<void> Function(EventSummary) joinLobby;
  final Future<void> Function(int teamOneScore, int teamTwoScore) onSubmitScore;
  final VoidCallback onOpenCourts;
  final VoidCallback onShowStatus;
  final VoidCallback onShowSessions;
  final VoidCallback onShowSessionDetails;
  final VoidCallback onShowPayment;
  final VoidCallback onShowSchedule;
  final VoidCallback onShowQueueLobby;
  final void Function(EventSummary) onSelectSession;
  final VoidCallback onShowMySession;
  final VoidCallback onShowUpcomingMatch;
  final Future<void> Function() onGoToCourt;
  final VoidCallback onShowMatchResult;
  final Future<void> Function() onRefreshStatus;
  final Future<void> Function() onLeaveCourt;
  final Future<List<CourtSummary>> courtsFuture;
  final Future<void> Function(CourtSummary) selectCourt;
  final void Function(CourtSummary) openCourtDetails;

  @override
  Widget build(BuildContext context) {
    final match = displayMatch ?? activeStatus?.match;
    final isWaitingVerification =
        activeStatus?.isWaitingVerification == true ||
        playPage == _PlayPage.waitingVerification;

    if (playPage == _PlayPage.courtSessions &&
        selectedCourt != null &&
        courtEventsFuture != null) {
      return _CourtSessionsPage(
        court: selectedCourt!,
        eventsFuture: courtEventsFuture!,
        onBack: onShowStatus,
        onChangeCourt: onOpenCourts,
        onSelectSession: onSelectSession,
      );
    }

    if (playPage == _PlayPage.sessionDetails &&
        selectedCourt != null &&
        selectedSession != null) {
      return _SessionDetailsPage(
        court: selectedCourt!,
        event: selectedSession!,
        onBack: onShowSessions,
        onJoinLobby: onShowPayment,
        actionLabel: 'Pay PHP 500 Now',
        actionIcon: Icons.payments_rounded,
      );
    }

    if (playPage == _PlayPage.payment &&
        selectedCourt != null &&
        selectedSession != null) {
      return _PaymentStepPage(
        court: selectedCourt!,
        event: selectedSession!,
        onBack: onShowSessionDetails,
        onConfirmPayment: onShowSchedule,
      );
    }

    if (playPage == _PlayPage.schedule &&
        selectedCourt != null &&
        selectedSession != null) {
      return _SchedulePage(
        court: selectedCourt!,
        event: selectedSession!,
        onCheckIn: onShowQueueLobby,
      );
    }

    if (playPage == _PlayPage.queueLobby &&
        selectedCourt != null &&
        selectedSession != null) {
      return _SessionDetailsPage(
        court: selectedCourt!,
        event: selectedSession!,
        onBack: onShowSchedule,
        onJoinLobby: () => joinLobby(selectedSession!),
        actionLabel: 'Check In Now',
        actionIcon: Icons.login_rounded,
        showQueueLobby: true,
      );
    }

    if (playPage == _PlayPage.mySession &&
        selectedCourt != null &&
        activeSession != null) {
      return _MySessionPage(
        court: selectedCourt!,
        session: activeSession!,
        status: activeStatus,
        onShowUpcomingMatch: match == null ? null : onShowUpcomingMatch,
        onLeaveCourt: onLeaveCourt,
      );
    }

    if (playPage == _PlayPage.upcomingMatch &&
        selectedCourt != null &&
        match != null) {
      return _UpcomingMatchPage(
        court: selectedCourt!,
        match: match,
        onBack: onShowStatus,
        onGoToCourt: onGoToCourt,
        onLeaveCourt: onLeaveCourt,
      );
    }

    if (playPage == _PlayPage.activeMatch &&
        selectedCourt != null &&
        match != null) {
      return _ActiveMatchPage(
        court: selectedCourt!,
        match: match,
        onShowMatchResult: onShowMatchResult,
        onLeaveCourt: onLeaveCourt,
      );
    }

    if (playPage == _PlayPage.matchResult &&
        selectedCourt != null &&
        match != null) {
      return _MatchResultPage(
        court: selectedCourt!,
        match: match,
        onSubmitScore: onSubmitScore,
      );
    }

    if (playPage == _PlayPage.waitingVerification &&
        selectedCourt != null &&
        match != null) {
      return _WaitingVerificationPage(
        court: selectedCourt!,
        match: match,
        scoreSubmission: scoreSubmission ?? activeStatus?.scoreSubmission,
        onRefreshStatus: onRefreshStatus,
      );
    }

    return _PlayStatusPage(
      fullName: fullName,
      selectedCourt: selectedCourt,
      activeSession: activeSession,
      isWaitingVerification: isWaitingVerification,
      hasMatch: match != null,
      onOpenCourts: onOpenCourts,
      onShowSessions: onShowSessions,
      onShowMySession: isWaitingVerification
          ? () {
              onRefreshStatus();
            }
          : onShowMySession,
      courtsFuture: courtsFuture,
      selectCourt: selectCourt,
      openCourtDetails: openCourtDetails,
    );
  }
}
