import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/pages/login_page.dart';
import '../../auth/services/auth_service.dart';
import '../../courts/services/court_service.dart';
import '../../events/services/event_service.dart';
import 'court_details_page.dart';
import 'dashboard_page.dart';
import 'notifications_page.dart';
import 'profile_history_page.dart';

part 'play/active_match_page.dart';
part 'play/court_sessions_page.dart';
part 'play/match_result_page.dart';
part 'play/my_session_page.dart';
part 'play/payment_step_page.dart';
part 'play/play_flow_page.dart';
part 'play/play_status_page.dart';
part 'play/schedule_page.dart';
part 'play/session_details_page.dart';
part 'play/upcoming_match_page.dart';
part 'play/waiting_verification_page.dart';

const _courtGreen = Color(0xFF26300F);
const _freshGreen = Color(0xFFD9FF00);
const _clay = Color(0xFFB8E600);
const _ink = Color(0xFF15180B);
const _muted = Color(0xFF727763);
const _chalk = Color(0xFFFCFCEB);
const _paper = Color(0xFFFFFFF4);
const _line = Color(0xFFE6E8C8);
const _softOlive = Color(0xFFE9EBD4);
const _blush = Color(0xFFFFD0E8);
const _liveSurface = Color(0xFF3E481D);
const _figmaDemoMatchId = 'figma-demo-match';

enum _PlayPage {
  status,
  courtSessions,
  sessionDetails,
  payment,
  schedule,
  queueLobby,
  mySession,
  upcomingMatch,
  activeMatch,
  matchResult,
  waitingVerification,
}

class HomePlaceholderPage extends StatefulWidget {
  const HomePlaceholderPage({super.key});

  @override
  State<HomePlaceholderPage> createState() => _HomePlaceholderPageState();
}

class _HomePlaceholderPageState extends State<HomePlaceholderPage> {
  late final Future<List<CourtSummary>> _courtsFuture;
  CourtSummary? _selectedCourt;
  Future<List<EventSummary>>? _courtEventsFuture;
  EventSummary? _selectedSession;
  EventSummary? _activeSession;
  PlayerEventStatusSummary? _activeStatus;
  PlayerScoreSubmissionSummary? _localScoreSubmission;
  int _selectedIndex = 0;
  _PlayPage _playPage = _PlayPage.status;

  PlayMatchSummary get _figmaMatch => const PlayMatchSummary(
    id: _figmaDemoMatchId,
    matchNumber: 4,
    status: 'assigned',
    participants: [
      MatchParticipantSummary(
        userId: 'figma-player-you',
        teamNumber: 1,
        slotNumber: 1,
        displayName: 'You',
      ),
      MatchParticipantSummary(
        userId: 'figma-player-alex',
        teamNumber: 1,
        slotNumber: 2,
        displayName: 'Alex',
      ),
      MatchParticipantSummary(
        userId: 'figma-player-sarah',
        teamNumber: 2,
        slotNumber: 3,
        displayName: 'Sarah',
      ),
      MatchParticipantSummary(
        userId: 'figma-player-mike',
        teamNumber: 2,
        slotNumber: 4,
        displayName: 'Mike',
      ),
    ],
  );

  PlayMatchSummary? get _displayMatch {
    if (_activeStatus?.match != null) {
      return _activeStatus!.match;
    }
    if (_activeSession != null) {
      return _figmaMatch;
    }
    return null;
  }

  PlayerScoreSubmissionSummary? get _displayScoreSubmission {
    return _isFigmaDemoMatch(_displayMatch)
        ? _localScoreSubmission
        : _activeStatus?.scoreSubmission;
  }

  bool _isFigmaDemoMatch(PlayMatchSummary? match) {
    return match?.id == _figmaDemoMatchId;
  }

  @override
  void initState() {
    super.initState();
    _courtsFuture = const CourtService().listCourts(limit: 12);
  }

  Future<void> _runRequest(
    Future<dynamic> Function() request,
    String label,
  ) async {
    try {
      await request();
      if (!mounted) return;
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label failed: ${error.userMessage}')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label failed. Check the backend and retry.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final fullName = user?.userMetadata?['full_name'] as String? ?? 'Player';
    final email = user?.email ?? '';
    final usesPrototypeHeader =
        _selectedIndex == 0 &&
        {
          _PlayPage.sessionDetails,
          _PlayPage.payment,
          _PlayPage.queueLobby,
          _PlayPage.upcomingMatch,
          _PlayPage.activeMatch,
          _PlayPage.matchResult,
          _PlayPage.waitingVerification,
        }.contains(_playPage);

    return Scaffold(
      extendBody: true,
      backgroundColor: _chalk,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final content = switch (_selectedIndex) {
              0 => _DiscoverOrFlowTab(
                fullName: fullName,
                selectedCourt: _selectedCourt,
                courtEventsFuture: _courtEventsFuture,
                selectedSession: _selectedSession,
                activeSession: _activeSession,
                activeStatus: _activeStatus,
                displayMatch: _displayMatch,
                scoreSubmission: _displayScoreSubmission,
                playPage: _playPage,
                courtsFuture: _courtsFuture,
                joinLobby: _joinLobby,
                onSubmitScore: _submitScore,
                onOpenCourts: _showDiscoverCourts,
                onShowStatus: () => _showPlayPage(_PlayPage.status),
                onShowSessions: () => _showPlayPage(_PlayPage.courtSessions),
                onShowSessionDetails: () =>
                    _showPlayPage(_PlayPage.sessionDetails),
                onShowPayment: () => _showPlayPage(_PlayPage.payment),
                onShowSchedule: () => _showPlayPage(_PlayPage.schedule),
                onShowQueueLobby: () => _showPlayPage(_PlayPage.queueLobby),
                onSelectSession: _selectSession,
                onShowMySession: () => _showPlayPage(_PlayPage.mySession),
                onShowUpcomingMatch: () =>
                    _showPlayPage(_PlayPage.upcomingMatch),
                onGoToCourt: _goToCourt,
                onShowMatchResult: () => _showPlayPage(_PlayPage.matchResult),
                onRefreshStatus: _refreshActiveStatus,
                onLeaveCourt: _leaveCourt,
                selectCourt: _selectCourt,
                openCourtDetails: _openCourtDetails,
              ),
              1 => _DiscoverCourtsTab(
                courtsFuture: _courtsFuture,
                selectCourt: _selectCourt,
                openCourtDetails: _openCourtDetails,
              ),
              2 => _MatchesTab(
                onDiscoverEvents: () {
                  setState(() {
                    _selectedIndex = 1;
                    _playPage = _PlayPage.status;
                  });
                },
                onFindCourt: _showDiscoverCourts,
              ),
              3 => const _FigmaFrameTab(
                title: 'Sessions',
                detail:
                    'Today schedule, active queues, and upcoming court assignments.',
                icon: Icons.calendar_month_rounded,
                child: DashboardContent(),
              ),
              _ => const _FigmaFrameTab(
                title: 'Profile & History',
                detail:
                    'Identity, account context, player history, ratings, and deferred ranking states.',
                icon: Icons.person_pin_circle_rounded,
                child: ProfileHistoryContent(),
              ),
            };
            final horizontalPadding = isWide
                ? 40.0
                : usesPrototypeHeader
                ? 0.0
                : 18.0;

            return DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF7F8E7), _chalk, _paper],
                  stops: [0, 0.46, 1],
                ),
              ),
              child: CustomScrollView(
                key: ValueKey(
                  '$_selectedIndex-$_playPage-${_selectedCourt?.id}-${_selectedSession?.id}-${_activeSession?.id}',
                ),
                slivers: [
                  if (!usesPrototypeHeader)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          isWide ? 40 : 0,
                          10,
                          isWide ? 40 : 0,
                          12,
                        ),
                        child: Center(
                          child: _HomeHeader(
                            fullName: fullName,
                            email: email,
                            selectedIndex: _selectedIndex,
                            onOpenNotifications: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const NotificationsPage(),
                                  settings: const RouteSettings(
                                    name: AppRoutes.notifications,
                                  ),
                                ),
                              );
                            },
                            onSignOut: () async {
                              await AuthService().signOut();
                              if (context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginPage(),
                                  ),
                                  (route) => false,
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      0,
                      horizontalPadding,
                      96,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: usesPrototypeHeader ? 430 : 390,
                          ),
                          child: content,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: usesPrototypeHeader
          ? null
          : Center(
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 390),
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: _paper,
                    border: Border(top: BorderSide(color: _line)),
                  ),
                  child: SafeArea(
                    minimum: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                    child: NavigationBar(
                      height: 56,
                      elevation: 0,
                      backgroundColor: _paper,
                      indicatorColor: _freshGreen,
                      labelBehavior:
                          NavigationDestinationLabelBehavior.alwaysShow,
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: (index) {
                        setState(() => _selectedIndex = index);
                      },
                      destinations: const [
                        NavigationDestination(
                          icon: Icon(Icons.sports_tennis_rounded, size: 18),
                          selectedIcon: Icon(
                            Icons.sports_tennis_rounded,
                            size: 18,
                          ),
                          label: 'Play',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.location_on_rounded, size: 18),
                          selectedIcon: Icon(
                            Icons.location_on_rounded,
                            size: 18,
                          ),
                          label: 'Courts',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.sports_score_rounded, size: 18),
                          selectedIcon: Icon(
                            Icons.sports_score_rounded,
                            size: 18,
                          ),
                          label: 'Matches',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.calendar_month_rounded, size: 18),
                          selectedIcon: Icon(
                            Icons.calendar_month_rounded,
                            size: 18,
                          ),
                          label: 'Sessions',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.person_rounded, size: 18),
                          selectedIcon: Icon(Icons.person_rounded, size: 18),
                          label: 'Profile',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> _joinLobby(EventSummary event) {
    return _runRequest(() async {
      await AuthService().syncBackendProfile();
      final status = await const EventService().joinLobby(event.id);
      if (mounted) {
        setState(() {
          _selectedSession = event;
          _activeSession = event;
          _activeStatus = status;
          _localScoreSubmission = null;
          _playPage = _PlayPage.mySession;
        });
      }
      return status;
    }, 'Check in');
  }

  Future<void> _submitScore(int teamOneScore, int teamTwoScore) {
    final match = _displayMatch;
    final event = _selectedSession ?? _activeSession;
    if (match == null || event == null) {
      return _runRequest(() async => 'No assigned match yet', 'Submit score');
    }
    if (_isFigmaDemoMatch(match)) {
      setState(() {
        _localScoreSubmission = PlayerScoreSubmissionSummary(
          id: 'figma-demo-score',
          status: 'pending',
          teamOneScore: teamOneScore,
          teamTwoScore: teamTwoScore,
        );
        _playPage = _PlayPage.waitingVerification;
        _selectedIndex = 0;
      });
      return Future.value();
    }
    return _runRequest(() async {
      await const EventService().submitScore(
        matchId: match.id,
        teamOneScore: teamOneScore,
        teamTwoScore: teamTwoScore,
      );
      final status = await const EventService().readStatus(event.id);
      if (mounted) {
        setState(() {
          _activeStatus = status;
          _playPage = _PlayPage.waitingVerification;
        });
      }
      return status;
    }, 'Submit score');
  }

  void _selectSession(EventSummary event) {
    setState(() {
      _selectedSession = event;
      _activeSession = null;
      _activeStatus = null;
      _localScoreSubmission = null;
      _playPage = _PlayPage.sessionDetails;
      _selectedIndex = 0;
    });
  }

  void _showPlayPage(_PlayPage page) {
    setState(() {
      _playPage = page;
      _selectedIndex = 0;
    });
  }

  void _showDiscoverCourts() {
    setState(() {
      _selectedCourt = null;
      _courtEventsFuture = null;
      _selectedSession = null;
      _activeSession = null;
      _activeStatus = null;
      _localScoreSubmission = null;
      _playPage = _PlayPage.status;
      _selectedIndex = 1;
    });
  }

  Future<void> _goToCourt() {
    final match = _displayMatch;
    final event = _selectedSession ?? _activeSession;
    if (match == null || event == null) {
      return _runRequest(() async => 'No assigned match yet', 'Start match');
    }
    if (_isFigmaDemoMatch(match)) {
      setState(() {
        _playPage = _PlayPage.activeMatch;
        _selectedIndex = 0;
      });
      return Future.value();
    }
    return _runRequest(() async {
      await const EventService().startMatch(match.id);
      final status = await const EventService().readStatus(event.id);
      if (mounted) {
        setState(() {
          _activeStatus = status;
          _playPage = _PlayPage.activeMatch;
        });
      }
      return status;
    }, 'Start match');
  }

  Future<void> _refreshActiveStatus() {
    if (_isFigmaDemoMatch(_displayMatch) && _localScoreSubmission != null) {
      setState(() {
        if (_localScoreSubmission!.status == 'pending') {
          _localScoreSubmission = PlayerScoreSubmissionSummary(
            id: _localScoreSubmission!.id,
            status: 'verified',
            teamOneScore: _localScoreSubmission!.teamOneScore,
            teamTwoScore: _localScoreSubmission!.teamTwoScore,
          );
          _playPage = _PlayPage.waitingVerification;
        } else {
          _localScoreSubmission = null;
          _playPage = _PlayPage.mySession;
        }
        _selectedIndex = 0;
      });
      return Future.value();
    }

    final event = _selectedSession ?? _activeSession;
    if (event == null) {
      return _runRequest(() async => 'No active session', 'Refresh status');
    }
    return _runRequest(() async {
      final status = await const EventService().readStatus(event.id);
      if (mounted) {
        setState(() {
          _activeStatus = status;
          _playPage = status.isWaitingVerification
              ? _PlayPage.waitingVerification
              : _PlayPage.mySession;
          _selectedIndex = 0;
        });
      }
      return status;
    }, 'Refresh status');
  }

  Future<void> _leaveCourt() {
    if (_selectedSession == null) {
      setState(() {
        _activeSession = null;
        _activeStatus = null;
        _localScoreSubmission = null;
        _playPage = _selectedCourt == null
            ? _PlayPage.status
            : _PlayPage.courtSessions;
        _selectedIndex = 0;
      });
      return Future.value();
    }
    return _runRequest(() async {
      final status = await const EventService().leaveEvent(
        _selectedSession!.id,
      );
      if (mounted) {
        setState(() {
          _activeSession = null;
          _activeStatus = status;
          _localScoreSubmission = null;
          _selectedSession = null;
          _playPage = _selectedCourt == null
              ? _PlayPage.status
              : _PlayPage.courtSessions;
          _selectedIndex = 0;
        });
      }
      return status;
    }, 'Leave court');
  }

  Future<void> _selectCourt(CourtSummary court) {
    return _runRequest(() async {
      final eventsFuture = const EventService().listEvents(
        courtId: court.id,
        limit: 20,
      );
      if (mounted) {
        setState(() {
          _selectedCourt = court;
          _courtEventsFuture = eventsFuture;
          _selectedSession = null;
          _activeSession = null;
          _activeStatus = null;
          _localScoreSubmission = null;
          _playPage = _PlayPage.courtSessions;
          _selectedIndex = 0;
        });
      }
      return court;
    }, 'Court selected');
  }

  void _openCourtDetails(CourtSummary court) {
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: AppRoutes.discoverCourts),
        builder: (_) => CourtDetailsPage(
          courtId: court.id,
          onShowSessions: (court) {
            _selectCourt(court);
          },
        ),
      ),
    );
  }
}

class _DiscoverOrFlowTab extends StatelessWidget {
  const _DiscoverOrFlowTab({
    required this.fullName,
    required this.selectedCourt,
    required this.courtEventsFuture,
    required this.selectedSession,
    required this.activeSession,
    required this.activeStatus,
    required this.displayMatch,
    required this.scoreSubmission,
    required this.playPage,
    required this.courtsFuture,
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
  final Future<List<CourtSummary>> courtsFuture;
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
  final Future<void> Function(CourtSummary) selectCourt;
  final void Function(CourtSummary) openCourtDetails;

  @override
  Widget build(BuildContext context) {
    return _PlayFlowPage(
      fullName: fullName,
      selectedCourt: selectedCourt,
      courtEventsFuture: courtEventsFuture,
      selectedSession: selectedSession,
      activeSession: activeSession,
      activeStatus: activeStatus,
      displayMatch: displayMatch,
      scoreSubmission: scoreSubmission,
      playPage: playPage,
      joinLobby: joinLobby,
      onSubmitScore: onSubmitScore,
      onOpenCourts: onOpenCourts,
      onShowStatus: onShowStatus,
      onShowSessions: onShowSessions,
      onShowSessionDetails: onShowSessionDetails,
      onShowPayment: onShowPayment,
      onShowSchedule: onShowSchedule,
      onShowQueueLobby: onShowQueueLobby,
      onSelectSession: onSelectSession,
      onShowMySession: onShowMySession,
      onShowUpcomingMatch: onShowUpcomingMatch,
      onGoToCourt: onGoToCourt,
      onShowMatchResult: onShowMatchResult,
      onRefreshStatus: onRefreshStatus,
      onLeaveCourt: onLeaveCourt,
      courtsFuture: courtsFuture,
      selectCourt: selectCourt,
      openCourtDetails: openCourtDetails,
    );
  }
}

class _DiscoverCourtsTab extends StatelessWidget {
  const _DiscoverCourtsTab({
    required this.courtsFuture,
    required this.selectCourt,
    required this.openCourtDetails,
  });

  final Future<List<CourtSummary>> courtsFuture;
  final Future<void> Function(CourtSummary) selectCourt;
  final void Function(CourtSummary) openCourtDetails;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _DiscoverFilterHeader(),
        const SizedBox(height: 18),
        _CourtDiscoveryPanel(
          courtsFuture: courtsFuture,
          onSelectCourt: selectCourt,
          onOpenDetails: openCourtDetails,
          maxItems: 12,
        ),
      ],
    );
  }
}

class _DiscoverFilterHeader extends StatelessWidget {
  const _DiscoverFilterHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: _line),
            boxShadow: [
              BoxShadow(
                color: _ink.withValues(alpha: 0.035),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(Icons.search_rounded, color: _muted, size: 17),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Search courts, locations, or clubs...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _FilterChipButton(icon: Icons.tune_rounded, label: 'Filters'),
            _FilterChipButton(label: 'Competitive  x', selected: true),
            _FilterChipButton(label: 'Casual'),
          ],
        ),
      ],
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    this.icon,
    this.selected = false,
  });

  final String label;
  final IconData? icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: selected ? _freshGreen : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: selected ? _freshGreen : _line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: _ink, size: 14),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: const TextStyle(
              color: _ink,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _FigmaFrameTab extends StatelessWidget {
  const _FigmaFrameTab({
    required this.title,
    required this.detail,
    required this.icon,
    required this.child,
  });

  final String title;
  final String detail;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PageHeader(title: title, detail: detail, icon: icon),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}

class _MatchesTab extends StatelessWidget {
  const _MatchesTab({
    required this.onDiscoverEvents,
    required this.onFindCourt,
  });

  final VoidCallback onDiscoverEvents;
  final VoidCallback onFindCourt;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ApiClient.instance.get(ApiEndpoints.matches),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _MatchesEmptyState(
            title: 'Loading matches',
            detail: 'Checking your assigned and completed matches.',
          );
        }

        if (snapshot.hasError) {
          return _MatchesEmptyState(
            title: 'No matches yet',
            detail: _matchesErrorDetail(snapshot.error),
            onDiscoverEvents: onDiscoverEvents,
            onFindCourt: onFindCourt,
          );
        }

        final list = snapshot.data?.data as List<dynamic>? ?? [];
        if (list.isEmpty) {
          return _MatchesEmptyState(
            title: 'No matches yet',
            detail:
                'You have not joined any matches yet. Register for an event or find a court to start playing.',
            onDiscoverEvents: onDiscoverEvents,
            onFindCourt: onFindCourt,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Matches',
              style: TextStyle(
                color: _ink,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            _Panel(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  for (final item in list) ...[
                    _FigmaMatchRow(
                      data: Map<String, dynamic>.from(item as Map),
                    ),
                    if (item != list.last) const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  static String _matchesErrorDetail(Object? error) {
    if (error is ApiException) {
      if (error.statusCode == 401 || error.statusCode == 422) {
        return 'Sign in, then discover events or courts to start playing.';
      }
      return error.userMessage;
    }
    return 'Register for an event or find a court to start playing.';
  }
}

class _MatchesEmptyState extends StatelessWidget {
  const _MatchesEmptyState({
    required this.title,
    required this.detail,
    this.onDiscoverEvents,
    this.onFindCourt,
  });

  final String title;
  final String detail;
  final VoidCallback? onDiscoverEvents;
  final VoidCallback? onFindCourt;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        const _MatchEmptyIllustration(),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _ink,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 34),
          child: Text(
            detail,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _muted,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ),
        const SizedBox(height: 18),
        if (onDiscoverEvents != null)
          Center(
            child: SizedBox(
              height: 42,
              child: FilledButton.icon(
                onPressed: onDiscoverEvents,
                icon: const Icon(Icons.explore_rounded, size: 15),
                label: const Text('Discover Events'),
                style: _primaryButtonStyle().copyWith(
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 20),
                  ),
                  textStyle: const WidgetStatePropertyAll(
                    TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
          ),
        if (onFindCourt != null) ...[
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: onFindCourt,
              style: TextButton.styleFrom(
                foregroundColor: _courtGreen,
                textStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
              child: const Text('Find a Court Near You'),
            ),
          ),
        ],
        const SizedBox(height: 18),
        const Text(
          'SUGGESTED FOR YOU',
          style: TextStyle(
            color: _muted,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        _SuggestedEventCard(onViewDetails: onDiscoverEvents),
      ],
    );
  }
}

class _MatchEmptyIllustration extends StatelessWidget {
  const _MatchEmptyIllustration();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 132,
        height: 132,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F5DE),
          shape: BoxShape.circle,
          border: Border.all(color: _softOlive, width: 3),
        ),
        child: Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFE3E7C8),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.hub_rounded, color: _courtGreen, size: 32),
                Positioned(
                  right: 17,
                  top: 15,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: _freshGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: _courtGreen, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestedEventCard extends StatelessWidget {
  const _SuggestedEventCard({this.onViewDetails});

  final VoidCallback? onViewDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFE7E7CF),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 4,
                  children: const [
                    _TinyTag(label: 'TOURNAMENT'),
                    _TinyTag(label: 'OPEN', color: _freshGreen),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'City Pickleball Open',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Saturday, Oct 14 - 09:00 AM',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _muted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 30,
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onViewDetails,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _muted,
                      backgroundColor: _softOlive,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    child: const Text('View Details'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TinyTag extends StatelessWidget {
  const _TinyTag({required this.label, this.color = _paper});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _line),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _courtGreen,
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _FigmaMatchRow extends StatelessWidget {
  const _FigmaMatchRow({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final number = data['match_number']?.toString() ?? '-';
    final status = _titleCase(
      data['status']?.toString().replaceAll('_', ' ') ?? 'created',
    );
    final winner = data['winner_team_number']?.toString();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _chalk,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _courtGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Match $number',
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  winner == null ? status : 'Team $winner verified winner',
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          _SignalChip(icon: Icons.sports_score_rounded, label: status),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.fullName,
    required this.email,
    required this.selectedIndex,
    required this.onOpenNotifications,
    required this.onSignOut,
  });

  final String fullName;
  final String email;
  final int selectedIndex;
  final VoidCallback onOpenNotifications;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final section = switch (selectedIndex) {
      0 => 'Play',
      1 => 'Courts',
      2 => 'Matches',
      3 => 'Sessions',
      _ => 'Profile',
    };

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 390),
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: _chalk,
          border: Border(bottom: BorderSide(color: _line)),
        ),
        child: Row(
          children: [
            PopupMenuButton<String>(
              tooltip: email.isEmpty ? fullName : email,
              offset: const Offset(0, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onSelected: (value) {
                if (value == 'signout') {
                  onSignOut();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  enabled: false,
                  child: Text(
                    email.isEmpty ? fullName : email,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'signout',
                  child: Text('Sign out'),
                ),
              ],
              child: _PlayerAvatar(label: fullName),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Semantics(
                label: 'RallyHub $section',
                child: const Text(
                  'RallyHub',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _courtGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                    height: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 34,
              height: 34,
              child: IconButton(
                onPressed: onOpenNotifications,
                tooltip: 'Notifications',
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.notifications_none_rounded, size: 17),
                color: _courtGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerAvatar extends StatelessWidget {
  const _PlayerAvatar({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    const radius = 23.0;
    return Semantics(
      label: label.isEmpty ? 'Player menu' : 'Player menu for $label',
      button: true,
      child: Container(
        width: radius * 1.36,
        height: radius * 1.36,
        decoration: BoxDecoration(
          color: _softOlive,
          shape: BoxShape.circle,
          border: Border.all(color: _line),
        ),
      ),
    );
  }
}

class _FlowTopBar extends StatelessWidget {
  const _FlowTopBar({
    required this.title,
    this.onBack,
    this.trailingIcon = Icons.notifications_none_rounded,
  });

  final String title;
  final VoidCallback? onBack;
  final IconData trailingIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 14),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            child: onBack == null
                ? const SizedBox.shrink()
                : IconButton(
                    onPressed: onBack,
                    tooltip: 'Back',
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: _ink,
                  ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _courtGreen,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ),
          SizedBox(width: 42, child: Icon(trailingIcon, color: _ink, size: 24)),
        ],
      ),
    );
  }
}

class _ScreenTitle extends StatelessWidget {
  const _ScreenTitle({
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 42,
            child: onBack == null
                ? const SizedBox.shrink()
                : IconButton(
                    onPressed: onBack,
                    tooltip: 'Back',
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: _ink,
                  ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: _ink,
                    fontWeight: FontWeight.w900,
                    height: 1.04,
                    letterSpacing: 0,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 42, child: trailing ?? const SizedBox.shrink()),
        ],
      ),
    );
  }
}

class _SignalChip extends StatelessWidget {
  const _SignalChip({
    required this.icon,
    required this.label,
    this.dark = false,
  });

  final IconData icon;
  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final foreground = dark ? Colors.white : _ink;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: dark ? Colors.white.withValues(alpha: 0.1) : _freshGreen,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: dark ? Colors.white.withValues(alpha: 0.12) : _freshGreen,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: dark ? _freshGreen : _courtGreen, size: 15),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeMetric extends StatelessWidget {
  const _HomeMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: _freshGreen,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapStripe extends StatelessWidget {
  const _MapStripe();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < 6; index++) ...[
          Container(
            width: 4,
            height: index.isEven ? 18 : 10,
            decoration: BoxDecoration(
              color: index == 1
                  ? _freshGreen
                  : Colors.white.withValues(alpha: 0.26),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          if (index != 5) const SizedBox(height: 5),
        ],
      ],
    );
  }
}

class _CourtSurfaceIcon extends StatelessWidget {
  const _CourtSurfaceIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFDFF8FF),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: _courtGreen, size: 23),
    );
  }
}

class _ActionButtonRow extends StatelessWidget {
  const _ActionButtonRow({
    required this.primaryLabel,
    required this.primaryIcon,
    required this.onPrimary,
  });

  final String primaryLabel;
  final IconData primaryIcon;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    final primary = FilledButton.icon(
      onPressed: onPrimary,
      icon: Icon(primaryIcon, size: 18),
      label: Text(primaryLabel),
      style: _primaryButtonStyle(),
    );

    return SizedBox(width: double.infinity, child: primary);
  }
}

class _MatchFlowStepper extends StatelessWidget {
  const _MatchFlowStepper({
    required this.selectedCourt,
    required this.activeSession,
    required this.hasMatch,
    required this.isWaitingVerification,
  });

  final CourtSummary? selectedCourt;
  final EventSummary? activeSession;
  final bool hasMatch;
  final bool isWaitingVerification;

  @override
  Widget build(BuildContext context) {
    final steps = <({IconData icon, String label, bool active})>[
      (
        icon: Icons.location_on_rounded,
        label: 'Court',
        active: selectedCourt != null,
      ),
      (
        icon: Icons.how_to_reg_rounded,
        label: 'Check in',
        active: activeSession != null,
      ),
      (icon: Icons.groups_rounded, label: 'Match', active: hasMatch),
      (
        icon: Icons.verified_rounded,
        label: 'Verify',
        active: isWaitingVerification,
      ),
    ];

    return Row(
      children: [
        for (var index = 0; index < steps.length; index++) ...[
          Expanded(
            child: _FlowStep(
              icon: steps[index].icon,
              label: steps[index].label,
              active: steps[index].active,
            ),
          ),
          if (index != steps.length - 1)
            Container(
              width: 16,
              height: 2,
              color: steps[index].active ? _freshGreen : _line,
            ),
        ],
      ],
    );
  }
}

class _FlowStep extends StatelessWidget {
  const _FlowStep({
    required this.icon,
    required this.label,
    required this.active,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: active ? _freshGreen : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: active ? _freshGreen : _line),
          ),
          child: Icon(icon, color: active ? _ink : _muted, size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: active ? _ink : _muted,
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.title,
    required this.detail,
    required this.icon,
    this.onBack,
    this.trailing,
  });

  final String title;
  final String detail;
  final IconData icon;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return _ScreenTitle(
      title: title,
      subtitle: detail,
      onBack: onBack,
      trailing: trailing ?? Icon(icon, color: _courtGreen, size: 24),
    );
  }
}

class _StatusActionCard extends StatelessWidget {
  const _StatusActionCard({
    required this.icon,
    required this.title,
    required this.detail,
    required this.actionLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String detail;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _chalk,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CourtSurfaceIcon(icon: icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detail,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ActionButtonRow(
            primaryLabel: actionLabel,
            primaryIcon: Icons.arrow_forward_rounded,
            onPrimary: onPressed,
          ),
        ],
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      color: _courtGreen,
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _SignalChip(
                  icon: Icons.sports_tennis_rounded,
                  label: 'Doubles',
                  dark: true,
                ),
                _MapStripe(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 88),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SignalChip(
                  icon: Icons.bolt_rounded,
                  label: 'Player hub',
                  dark: true,
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.04,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  detail,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.84),
                    fontSize: 15,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                const Row(
                  children: [
                    _HomeMetric(value: '04', label: 'players create a match'),
                    SizedBox(width: 10),
                    _HomeMetric(value: '01', label: 'live queue per session'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CourtDiscoveryPanel extends StatelessWidget {
  const _CourtDiscoveryPanel({
    required this.courtsFuture,
    required this.onSelectCourt,
    required this.onOpenDetails,
    this.maxItems = 3,
  });

  final Future<List<CourtSummary>> courtsFuture;
  final Future<void> Function(CourtSummary) onSelectCourt;
  final void Function(CourtSummary) onOpenDetails;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nearby Courts',
          style: TextStyle(
            color: _ink,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<CourtSummary>>(
          future: courtsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _CourtLoadingState();
            }
            if (snapshot.hasError) {
              return _CourtMessageState(
                icon: Icons.cloud_off_rounded,
                title: 'Courts are unavailable',
                detail: 'Check the backend connection and try again.',
                color: _clay,
              );
            }

            final courts = snapshot.data ?? [];
            if (courts.isEmpty) {
              return const _CourtMessageState(
                icon: Icons.add_location_alt_rounded,
                title: 'No courts published yet',
                detail: 'Create an active court record to make discovery live.',
                color: _courtGreen,
              );
            }

            final visibleCourts = courts.take(maxItems).toList(growable: false);
            return Column(
              children: [
                for (final court in visibleCourts) ...[
                  _CourtTile(
                    court: court,
                    onSelect: () => onSelectCourt(court),
                    onOpenDetails: () => onOpenDetails(court),
                  ),
                  if (court != visibleCourts.last) const SizedBox(height: 18),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _CourtTile extends StatelessWidget {
  const _CourtTile({
    required this.court,
    required this.onSelect,
    required this.onOpenDetails,
  });

  final CourtSummary court;
  final VoidCallback onSelect;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final address = court.address?.trim();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(
            color: _ink.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CourtImageBanner(height: 146, badge: 'High Demand'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  court.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: _muted,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        address == null || address.isEmpty
                            ? _courtDistance(court)
                            : address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _CourtStat(
                        label: 'Courts',
                        value: '${_courtCount(court)} Indoor',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _CourtStat(
                        label: 'Players Here',
                        value: '${_activePlayerCount(court)} / 48',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Open Sessions',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                const _OpenSessionChips(),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: FilledButton(
                    onPressed: onSelect,
                    style: _primaryButtonStyle().copyWith(
                      textStyle: const WidgetStatePropertyAll(
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                      ),
                    ),
                    child: const Text('Select Court'),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: onOpenDetails,
                    style: TextButton.styleFrom(
                      foregroundColor: _courtGreen,
                      textStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    child: const Text('View Details'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CourtImageBanner extends StatelessWidget {
  const _CourtImageBanner({
    required this.height,
    this.badge,
    this.compact = false,
  });

  final double height;
  final String? badge;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/pickleball_background.jpg',
              fit: BoxFit.cover,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _courtGreen.withValues(alpha: 0.12),
                    _courtGreen.withValues(alpha: 0.34),
                  ],
                ),
              ),
            ),
            if (!compact) const _CourtLineOverlay(),
            if (badge != null)
              Positioned(
                top: compact ? 8 : 12,
                right: compact ? 8 : 12,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 8 : 10,
                    vertical: compact ? 4 : 5,
                  ),
                  decoration: BoxDecoration(
                    color: _freshGreen,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      color: _ink,
                      fontSize: compact ? 8.5 : 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CourtLineOverlay extends StatelessWidget {
  const _CourtLineOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _CourtLinePainter());
  }
}

class _CourtLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.58)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final inset = size.width * 0.08;
    final court = Rect.fromLTWH(
      inset,
      size.height * 0.18,
      size.width - inset * 2,
      size.height * 0.64,
    );
    canvas.drawRect(court, paint);
    canvas.drawLine(
      Offset(court.center.dx, court.top),
      Offset(court.center.dx, court.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(court.left, court.center.dy),
      Offset(court.right, court.center.dy),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CourtStat extends StatelessWidget {
  const _CourtStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: _paper,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _muted,
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _ink,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _OpenSessionChips extends StatelessWidget {
  const _OpenSessionChips();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        _SessionTimeChip(label: '5:00 PM (12 left)'),
        _SessionTimeChip(label: '6:30 PM (4 left)'),
      ],
    );
  }
}

class _SessionTimeChip extends StatelessWidget {
  const _SessionTimeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBF5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _ink,
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SessionDetailsCard extends StatelessWidget {
  const _SessionDetailsCard({
    required this.court,
    required this.event,
    required this.onJoinLobby,
    required this.actionLabel,
    required this.actionIcon,
    required this.showQueueLobby,
  });

  final CourtSummary court;
  final EventSummary event;
  final VoidCallback onJoinLobby;
  final String actionLabel;
  final IconData actionIcon;
  final bool showQueueLobby;

  @override
  Widget build(BuildContext context) {
    final eventType = _eventTypeLabel(event.eventType);
    final courtsLabel = court.address?.trim().isNotEmpty == true
        ? court.address!.trim()
        : 'Courts 1, 2, & 3';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 440,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const _SessionBanner(),
              Positioned(
                left: 24,
                right: 24,
                top: 144,
                child: _Panel(
                  padding: const EdgeInsets.fromLTRB(26, 26, 26, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _SignalChip(
                            icon: Icons.sports_tennis_rounded,
                            label: eventType,
                          ),
                          const _SignalChip(
                            icon: Icons.speed_rounded,
                            label: 'DUPR 4.0+',
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        event.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          height: 1.08,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text.rich(
                        TextSpan(
                          text: 'Organized by ',
                          children: [
                            TextSpan(
                              text: 'RallyHub Admin',
                              style: TextStyle(color: _courtGreen),
                            ),
                          ],
                        ),
                        style: TextStyle(
                          color: _muted,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Divider(height: 30, color: _line),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _DetailMetric(
                              icon: Icons.calendar_month_rounded,
                              title: _formatEventDate(event.startAt),
                              detail: _formatTimeRange(
                                event.startAt,
                                event.endAt,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          const Expanded(
                            child: _DetailMetric(
                              icon: Icons.payments_rounded,
                              title: 'PHP 500',
                              detail: 'Per Player',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            children: [
              _Panel(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _EyebrowIconLabel(
                      icon: Icons.location_on_outlined,
                      label: 'LOCATION',
                    ),
                    const SizedBox(height: 14),
                    Text(
                      court.name,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      courtsLabel,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 16,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _MiniMapPreview(),
                  ],
                ),
              ),
              if (showQueueLobby) ...[
                const SizedBox(height: 18),
                _Panel(
                  color: _freshGreen,
                  padding: const EdgeInsets.all(22),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Your status\n3rd in Queue',
                          style: TextStyle(
                            color: _courtGreen,
                            fontSize: 30,
                            height: 1.03,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Container(
                        width: 86,
                        height: 86,
                        decoration: const BoxDecoration(
                          color: _chalk,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '4/8\nfilled',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _courtGreen,
                              fontSize: 18,
                              height: 1.05,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onJoinLobby,
                  icon: Icon(actionIcon, size: 18),
                  label: Text(actionLabel),
                  style: _primaryButtonStyle(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SessionBanner extends StatelessWidget {
  const _SessionBanner();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/pickleball_background.jpg',
            fit: BoxFit.cover,
          ),
          Container(color: _chalk.withValues(alpha: 0.58)),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, _chalk.withValues(alpha: 0.92)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailMetric extends StatelessWidget {
  const _DetailMetric({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _courtGreen, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                detail,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 14,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EyebrowIconLabel extends StatelessWidget {
  const _EyebrowIconLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _ink, size: 22),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: _ink,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _MiniMapPreview extends StatelessWidget {
  const _MiniMapPreview();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Container(
        height: 128,
        width: double.infinity,
        color: const Color(0xFFDDE9C8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _MapPreviewPainter()),
            const Center(
              child: Icon(
                Icons.location_on_rounded,
                color: _freshGreen,
                size: 54,
                shadows: [
                  Shadow(
                    color: Color(0x66000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPreviewPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = Colors.white.withValues(alpha: 0.76)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    final water = Paint()
      ..color = const Color(0xFF96D8BF).withValues(alpha: 0.72)
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final divider = Paint()
      ..color = _courtGreen.withValues(alpha: 0.56)
      ..strokeWidth = 4;

    canvas.drawLine(
      Offset(size.width * 0.30, 0),
      Offset(size.width * 0.30, size.height),
      divider,
    );
    canvas.drawLine(
      Offset(size.width * 0.70, 0),
      Offset(size.width * 0.70, size.height),
      divider,
    );
    final waterPath = Path()
      ..moveTo(size.width * 0.55, -10)
      ..quadraticBezierTo(
        size.width * 0.62,
        size.height * 0.35,
        size.width * 0.55,
        size.height * 0.62,
      )
      ..quadraticBezierTo(
        size.width * 0.47,
        size.height * 0.92,
        size.width * 0.58,
        size.height + 10,
      );
    canvas.drawPath(waterPath, water);
    canvas.drawLine(
      Offset(-20, size.height * 0.15),
      Offset(size.width * 0.42, size.height * 0.92),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.12, size.height),
      Offset(size.width * 0.42, -10),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.74, size.height),
      Offset(size.width + 20, size.height * 0.30),
      road,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MySessionCard extends StatelessWidget {
  const _MySessionCard({
    required this.court,
    required this.session,
    required this.status,
    required this.onShowUpcomingMatch,
  });

  final CourtSummary court;
  final EventSummary session;
  final PlayerEventStatusSummary? status;
  final VoidCallback? onShowUpcomingMatch;

  @override
  Widget build(BuildContext context) {
    final queuePosition = status?.queueEntry?.queuePosition;
    final match = status?.match;
    final positionLabel = queuePosition == null ? '-' : '#$queuePosition';
    final statusLabel = match == null ? 'In Queue' : 'Match Ready';
    final assignmentTitle = match == null
        ? 'Waiting for court'
        : 'Court ${match.matchNumber}';
    final assignmentDetail = match == null
        ? court.name
        : '${court.name} - tap to view matchup';

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          decoration: BoxDecoration(
            color: _freshGreen,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.circle, color: _courtGreen, size: 8),
                        SizedBox(width: 8),
                        Text(
                          'Current status',
                          style: TextStyle(
                            color: _courtGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      statusLabel,
                      style: const TextStyle(
                        color: _courtGreen,
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        height: 0.92,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 92,
                height: 92,
                decoration: const BoxDecoration(
                  color: _chalk,
                  shape: BoxShape.circle,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'POS',
                      style: TextStyle(
                        color: _courtGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      positionLabel,
                      style: const TextStyle(
                        color: _courtGreen,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _AssignmentCard(title: assignmentTitle, detail: assignmentDetail),
        const SizedBox(height: 16),
        _NextMatchupCard(match: match, onTap: onShowUpcomingMatch),
        const SizedBox(height: 16),
        const _SessionTimeline(activeIndex: 1),
      ],
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Row(
        children: [
          const _CourtSurfaceIcon(icon: Icons.map_rounded),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upcoming assignment',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: const TextStyle(color: _muted, fontSize: 13.5),
                ),
              ],
            ),
          ),
          const _SignalChip(icon: Icons.timer_rounded, label: 'Est. 15m'),
        ],
      ),
    );
  }
}

class _NextMatchupCard extends StatelessWidget {
  const _NextMatchupCard({required this.match, required this.onTap});

  final PlayMatchSummary? match;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = match != null && onTap != null;
    return Material(
      color: _blush,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                children: const [
                  Text(
                    'Next matchup',
                    style: TextStyle(
                      color: Color(0xFF80546E),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Spacer(),
                  _SignalChip(icon: Icons.groups_rounded, label: 'Doubles'),
                ],
              ),
              const Divider(height: 26, color: Color(0xFFEAB4CF)),
              if (match == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Text(
                    'Waiting for player...',
                    style: TextStyle(
                      color: Color(0xFF80546E),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: _MiniTeam(
                        label: 'You & Partner',
                        players: match!.teamOne,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: CircleAvatar(
                        radius: 19,
                        backgroundColor: _chalk,
                        child: Text(
                          'VS',
                          style: TextStyle(
                            color: _ink,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _MiniTeam(
                        label: 'Opponents',
                        players: match!.teamTwo,
                        alignEnd: true,
                      ),
                    ),
                  ],
                ),
              if (enabled) ...[
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.sports_score_rounded, size: 18),
                  label: const Text('View Matchup'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _chalk,
                    foregroundColor: _ink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniTeam extends StatelessWidget {
  const _MiniTeam({
    required this.label,
    required this.players,
    this.alignEnd = false,
  });

  final String label;
  final List<MatchParticipantSummary> players;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final names = players.isEmpty
        ? 'Waiting'
        : players.map((player) => player.displayName).join(' / ');
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: alignEnd
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            for (final player in players.take(2))
              Padding(
                padding: const EdgeInsets.only(right: 3),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: _courtGreen,
                  child: Text(
                    player.displayName.characters.first,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF80546E),
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          names,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.right : TextAlign.left,
          style: const TextStyle(
            color: Color(0xFF80546E),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

class _SessionTimeline extends StatelessWidget {
  const _SessionTimeline({required this.activeIndex});

  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.check_rounded, 'Checked In'),
      (Icons.groups_rounded, 'In Queue'),
      (Icons.sports_score_rounded, 'Assigned'),
      (Icons.emoji_events_rounded, 'Result'),
    ];
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Session timeline',
            style: TextStyle(
              color: _ink,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                Expanded(
                  child: _SessionStep(
                    icon: items[i].$1,
                    label: items[i].$2,
                    active: i <= activeIndex,
                  ),
                ),
                if (i != items.length - 1)
                  Container(width: 16, height: 2, color: _line),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SessionStep extends StatelessWidget {
  const _SessionStep({
    required this.icon,
    required this.label,
    required this.active,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? _freshGreen : const Color(0xFF9AA8A0);
    return Column(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: active ? color : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: active ? color : _line),
          ),
          child: Icon(icon, color: active ? _ink : color, size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: active ? _ink : _muted,
            fontSize: 10.5,
            fontWeight: active ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _UpcomingMatchCard extends StatelessWidget {
  const _UpcomingMatchCard({
    required this.court,
    required this.match,
    required this.onGoToCourt,
  });

  final CourtSummary court;
  final PlayMatchSummary match;
  final Future<void> Function() onGoToCourt;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          decoration: BoxDecoration(
            color: _freshGreen,
            borderRadius: BorderRadius.circular(34),
          ),
          child: Column(
            children: [
              const Text(
                'Assigned court',
                style: TextStyle(
                  color: _courtGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                court.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _courtGreen,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 14),
              const _SignalChip(
                icon: Icons.timer_rounded,
                label: 'Starts in 12:45',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MatchTeamRow(
                title: 'Team Alpha',
                seed: 'Seed #1',
                players: match.teamOne,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: _chalk,
                    child: Text(
                      'VS',
                      style: TextStyle(
                        color: _courtGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
              _MatchTeamRow(
                title: 'Team Bravo',
                seed: 'Seed #4',
                players: match.teamTwo,
                alignEnd: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onGoToCourt,
            style: _primaryButtonStyle(),
            child: const Text('Start Match'),
          ),
        ),
      ],
    );
  }
}

class _MatchTeamRow extends StatelessWidget {
  const _MatchTeamRow({
    required this.title,
    required this.seed,
    required this.players,
    this.alignEnd = false,
  });

  final String title;
  final String seed;
  final List<MatchParticipantSummary> players;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final names = players.isEmpty
        ? 'Waiting'
        : players.map((player) => player.displayName).join(' / ');
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (!alignEnd)
              Text(
                title,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            const Spacer(),
            _SignalChip(icon: Icons.emoji_events_rounded, label: seed),
            if (alignEnd) ...[
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _chalk,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            textDirection: alignEnd ? TextDirection.rtl : TextDirection.ltr,
            children: [
              for (final player in players.take(2))
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: _courtGreen,
                    child: Text(
                      player.displayName.characters.first,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: alignEnd
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      names,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: alignEnd ? TextAlign.right : TextAlign.left,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'DUPR avg pending',
                      style: TextStyle(color: _muted, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LiveMatchPanel extends StatelessWidget {
  const _LiveMatchPanel({
    required this.court,
    required this.match,
    required this.onFinishMatch,
    required this.onLeaveCourt,
  });

  final CourtSummary court;
  final PlayMatchSummary match;
  final VoidCallback onFinishMatch;
  final Future<void> Function() onLeaveCourt;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 34),
      decoration: const BoxDecoration(color: _liveSurface),
      child: Column(
        children: [
          Row(
            children: [
              IconButton.filled(
                onPressed: onLeaveCourt,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  foregroundColor: _chalk,
                ),
                icon: const Icon(Icons.close_rounded),
              ),
              const Expanded(
                child: Column(
                  children: [
                    Text(
                      'LIVE MATCH',
                      style: TextStyle(
                        color: _freshGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Tournament QF',
                      style: TextStyle(color: _chalk, fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton.filled(
                onPressed: () {},
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  foregroundColor: _chalk,
                ),
                icon: const Icon(Icons.more_vert_rounded),
              ),
            ],
          ),
          const SizedBox(height: 34),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            decoration: BoxDecoration(
              color: _freshGreen,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              court.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _courtGreen,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const _SignalChip(
            icon: Icons.fiber_manual_record_rounded,
            label: 'Recording Live',
            dark: true,
          ),
          const SizedBox(height: 22),
          _LiveTeamBlock(label: 'Team Alpha', players: match.teamOne),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 22),
            child: _SignalChip(
              icon: Icons.play_circle_fill_rounded,
              label: 'Match in progress',
              dark: true,
            ),
          ),
          _LiveTeamBlock(label: 'Team Bravo', players: match.teamTwo),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Row(
              children: const [
                Icon(Icons.verified_user_rounded, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Staff verified\nScores are tracked by tournament staff.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onFinishMatch,
              icon: const Icon(Icons.sports_score_rounded, size: 18),
              label: const Text('Finish Match'),
              style: _primaryButtonStyle(),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onLeaveCourt,
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Leave session'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.36)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveTeamBlock extends StatelessWidget {
  const _LiveTeamBlock({required this.label, required this.players});

  final String label;
  final List<MatchParticipantSummary> players;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: _freshGreen.withValues(alpha: 0.32)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: _chalk,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: _ink,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final player in players.take(2))
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: _freshGreen,
                    child: Text(
                      player.displayName.characters.first,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VerificationPanel extends StatelessWidget {
  const _VerificationPanel({
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
    final verified = scoreSubmission?.status == 'verified';
    if (verified) {
      return Column(
        children: [
          const Text(
            'VICTORY',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _courtGreen,
              fontSize: 48,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Ranked Doubles Match - Center Court',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 36),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
            decoration: BoxDecoration(
              color: _freshGreen,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: _freshGreen.withValues(alpha: 0.28),
                  blurRadius: 26,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    _SignalChip(
                      icon: Icons.emoji_events_rounded,
                      label: 'Winners',
                    ),
                    Spacer(),
                    Icon(Icons.emoji_events_rounded, color: _courtGreen),
                  ],
                ),
                const SizedBox(height: 18),
                for (final player in match.teamOne) ...[
                  _WinnerLine(player: player),
                  const SizedBox(height: 10),
                ],
                const Divider(height: 24, color: _clay),
                Row(
                  children: [
                    const Text(
                      'SCORE',
                      style: TextStyle(
                        color: _courtGreen,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${scoreSubmission?.teamOneScore ?? 11} - ${scoreSubmission?.teamTwoScore ?? 9}',
                      style: const TextStyle(
                        color: _courtGreen,
                        fontSize: 54,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _Panel(
            color: _softOlive,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SignalChip(
                  icon: Icons.person_outline_rounded,
                  label: 'Opponents',
                ),
                const SizedBox(height: 16),
                for (final player in match.teamTwo) ...[
                  _OpponentLine(player: player),
                  const SizedBox(height: 10),
                ],
                const Divider(height: 24, color: _line),
                Row(
                  children: [
                    const Text(
                      'SCORE',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${scoreSubmission?.teamTwoScore ?? 9} - ${scoreSubmission?.teamOneScore ?? 11}',
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 42),
          _Panel(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: const [
                CircleAvatar(
                  radius: 23,
                  backgroundColor: _freshGreen,
                  child: Icon(Icons.trending_up_rounded, color: _courtGreen),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Rating Impact\n+15 Rating',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      height: 1.35,
                    ),
                  ),
                ),
                Text(
                  '4.35',
                  style: TextStyle(
                    color: _courtGreen,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onRefreshStatus,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('Return to Queue'),
              style: _primaryButtonStyle(),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        const SizedBox(height: 2),
        Container(
          width: 190,
          height: 190,
          decoration: BoxDecoration(
            color: _softOlive.withValues(alpha: 0.48),
            shape: BoxShape.circle,
            border: Border.all(color: _line.withValues(alpha: 0.9), width: 8),
          ),
          child: Center(
            child: Container(
              width: 92,
              height: 92,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.more_horiz_rounded,
                color: Color(0xFF80546E),
                size: 42,
              ),
            ),
          ),
        ),
        const SizedBox(height: 34),
        const Text(
          'Verification in Progress',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _ink,
            fontSize: 29,
            fontWeight: FontWeight.w900,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Your match has ended. Staff is reviewing and confirming the official result.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _muted,
            fontSize: 19,
            height: 1.4,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 42),
        _Panel(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
          child: Column(
            children: [
              _SessionMetaRow(
                icon: Icons.location_on_rounded,
                text: court.name,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: _MiniTeam(label: 'Team A', players: match.teamOne),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'VS',
                      style: TextStyle(
                        color: _line,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _MiniTeam(
                      label: 'Team B',
                      players: match.teamTwo,
                      alignEnd: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const _SignalChip(
                icon: Icons.circle,
                label: 'Waiting for Staff Confirmation',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onRefreshStatus,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Refresh status'),
            style: _primaryButtonStyle(),
          ),
        ),
      ],
    );
  }
}

class _WinnerLine extends StatelessWidget {
  const _WinnerLine({required this.player});

  final MatchParticipantSummary player;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 21,
          backgroundColor: _courtGreen,
          child: Text(
            player.displayName.characters.first,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                player.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _courtGreen,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                '4.2 Rating',
                style: TextStyle(
                  color: _courtGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OpponentLine extends StatelessWidget {
  const _OpponentLine({required this.player});

  final MatchParticipantSummary player;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 21,
          backgroundColor: _softOlive,
          child: const Icon(Icons.person_outline_rounded, color: _muted),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                player.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '4.1 Rating',
                style: TextStyle(
                  color: _ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MatchResultCard extends StatefulWidget {
  const _MatchResultCard({
    required this.court,
    required this.match,
    required this.onSubmitScore,
  });

  final CourtSummary court;
  final PlayMatchSummary match;
  final Future<void> Function(int teamOneScore, int teamTwoScore) onSubmitScore;

  @override
  State<_MatchResultCard> createState() => _MatchResultCardState();
}

class _MatchResultCardState extends State<_MatchResultCard> {
  final TextEditingController _teamOneController = TextEditingController(
    text: '11',
  );
  final TextEditingController _teamTwoController = TextEditingController(
    text: '7',
  );

  @override
  void dispose() {
    _teamOneController.dispose();
    _teamTwoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.task_alt_rounded,
            title: 'Final score',
          ),
          const SizedBox(height: 14),
          Text(
            'Match ${widget.match.matchLabel}',
            style: const TextStyle(
              color: _ink,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.court.name} - submit for staff verification',
            style: const TextStyle(color: _muted, fontSize: 12.5),
          ),
          const Divider(height: 28, color: _line),
          const Center(
            child: Text(
              'Team 1',
              style: TextStyle(
                color: _ink,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(child: _ScoreInput(controller: _teamOneController)),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'VS',
              style: TextStyle(
                color: _muted,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Team 2',
              style: TextStyle(
                color: _ink,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(child: _ScoreInput(controller: _teamTwoController)),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final teamOneScore = int.tryParse(
                  _teamOneController.text.trim(),
                );
                final teamTwoScore = int.tryParse(
                  _teamTwoController.text.trim(),
                );
                if (teamOneScore == null || teamTwoScore == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Enter both scores as numbers.'),
                    ),
                  );
                  return;
                }
                widget.onSubmitScore(teamOneScore, teamTwoScore);
              },
              style: FilledButton.styleFrom(
                backgroundColor: _freshGreen,
                foregroundColor: _ink,
                disabledBackgroundColor: _freshGreen.withValues(alpha: 0.5),
                disabledForegroundColor: _ink.withValues(alpha: 0.48),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Submit Score'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreInput extends StatelessWidget {
  const _ScoreInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(
            color: _ink.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(border: InputBorder.none),
        style: const TextStyle(
          color: _ink,
          fontSize: 28,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SessionMetaRow extends StatelessWidget {
  const _SessionMetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: _ink, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: _ink,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatTimeRange(DateTime startAt, DateTime endAt) {
  return '${_formatClock(startAt.toLocal())} - ${_formatClock(endAt.toLocal())}';
}

String _formatEventDate(DateTime value) {
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final local = value.toLocal();
  return '${weekdays[local.weekday - 1]}, ${months[local.month - 1]} ${local.day}';
}

String _formatClock(DateTime value) {
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final minute = value.minute.toString().padLeft(2, '0');
  final suffix = value.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $suffix';
}

String _eventTypeLabel(String eventType) {
  return _titleCase(eventType.replaceAll('_', ' '));
}

String _courtDistance(CourtSummary court) {
  final seed = court.name.codeUnits.fold<int>(0, (sum, code) => sum + code);
  final value = 0.7 + (seed % 15) / 10;
  return '${value.toStringAsFixed(1)}km away';
}

int _activePlayerCount(CourtSummary court) {
  final seed = court.id.isEmpty
      ? court.name.length
      : court.id.codeUnits.fold<int>(0, (sum, code) => sum + code);
  return 18 + (seed % 25);
}

int _courtCount(CourtSummary court) {
  final seed = court.slug.isEmpty ? court.name.length : court.slug.length;
  return 6 + (seed % 8);
}

String _titleCase(String value) {
  return value
      .split(' ')
      .where((word) => word.trim().isNotEmpty)
      .map((word) {
        final lower = word.toLowerCase();
        return '${lower[0].toUpperCase()}${lower.substring(1)}';
      })
      .join(' ');
}

ButtonStyle _primaryButtonStyle() {
  return FilledButton.styleFrom(
    backgroundColor: _freshGreen,
    foregroundColor: _ink,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    textStyle: const TextStyle(fontWeight: FontWeight.w900),
  );
}

ButtonStyle _dangerOutlineButtonStyle() {
  return OutlinedButton.styleFrom(
    foregroundColor: const Color(0xFFD34343),
    side: const BorderSide(color: Color(0xFFD34343)),
    padding: const EdgeInsets.symmetric(vertical: 15),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
  );
}

class _CourtLoadingState extends StatelessWidget {
  const _CourtLoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _chalk,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _line),
      ),
      child: const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2.4),
      ),
    );
  }
}

class _CourtMessageState extends StatelessWidget {
  const _CourtMessageState({
    required this.icon,
    required this.title,
    required this.detail,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 12.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineLoadingState extends StatelessWidget {
  const _InlineLoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _chalk,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _line),
      ),
      child: const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2.4),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _courtGreen, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: _ink,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.child,
    this.color = Colors.white,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _line),
        boxShadow: color == Colors.white || color == _paper
            ? [
                BoxShadow(
                  color: _ink.withValues(alpha: 0.045),
                  blurRadius: 26,
                  offset: const Offset(0, 12),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}
