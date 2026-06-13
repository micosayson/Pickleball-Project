part of '../home_placeholder_page.dart';

class _PlayFlowPage extends StatelessWidget {
  const _PlayFlowPage({
    required this.fullName,
    required this.selectedCourt,
    required this.courtEventsFuture,
    required this.selectedSession,
    required this.activeSession,
    required this.activeRegistration,
    required this.matchFinished,
    required this.playPage,
    required this.joinLobby,
    required this.onMatchFinished,
    required this.onOpenCourts,
    required this.onShowStatus,
    required this.onShowSessions,
    required this.onSelectSession,
    required this.onShowMySession,
    required this.onShowUpcomingMatch,
    required this.onGoToCourt,
    required this.onShowMatchResult,
    required this.onReturnToQueue,
    required this.onLeaveCourt,
  });

  final String fullName;
  final CourtSummary? selectedCourt;
  final Future<List<EventSummary>>? courtEventsFuture;
  final EventSummary? selectedSession;
  final EventSummary? activeSession;
  final EventRegistrationSummary? activeRegistration;
  final bool matchFinished;
  final _PlayPage playPage;
  final Future<void> Function(EventSummary) joinLobby;
  final VoidCallback onMatchFinished;
  final VoidCallback onOpenCourts;
  final VoidCallback onShowStatus;
  final VoidCallback onShowSessions;
  final void Function(EventSummary) onSelectSession;
  final VoidCallback onShowMySession;
  final VoidCallback onShowUpcomingMatch;
  final VoidCallback onGoToCourt;
  final VoidCallback onShowMatchResult;
  final VoidCallback onReturnToQueue;
  final VoidCallback onLeaveCourt;

  @override
  Widget build(BuildContext context) {
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
        onJoinLobby: () => joinLobby(selectedSession!),
      );
    }

    if (playPage == _PlayPage.mySession &&
        selectedCourt != null &&
        activeSession != null) {
      return _MySessionPage(
        court: selectedCourt!,
        session: activeSession!,
        registration: activeRegistration,
        onShowUpcomingMatch: onShowUpcomingMatch,
        onLeaveCourt: onLeaveCourt,
      );
    }

    if (playPage == _PlayPage.upcomingMatch && selectedCourt != null) {
      return _UpcomingMatchPage(
        court: selectedCourt!,
        onBack: onShowStatus,
        onGoToCourt: onGoToCourt,
        onLeaveCourt: onLeaveCourt,
      );
    }

    if (playPage == _PlayPage.activeMatch && selectedCourt != null) {
      return _ActiveMatchPage(
        court: selectedCourt!,
        onShowMatchResult: onShowMatchResult,
        onLeaveCourt: onLeaveCourt,
      );
    }

    if (playPage == _PlayPage.matchResult && selectedCourt != null) {
      return _MatchResultPage(
        court: selectedCourt!,
        matchFinished: matchFinished,
        onMatchFinished: onMatchFinished,
      );
    }

    if (playPage == _PlayPage.waitingVerification && selectedCourt != null) {
      return _WaitingVerificationPage(
        court: selectedCourt!,
        onReturnToQueue: onReturnToQueue,
      );
    }

    return _PlayStatusPage(
      fullName: fullName,
      selectedCourt: selectedCourt,
      activeSession: activeSession,
      matchFinished: matchFinished,
      onOpenCourts: onOpenCourts,
      onShowSessions: onShowSessions,
      onShowMySession: matchFinished ? onReturnToQueue : onShowMySession,
    );
  }
}
