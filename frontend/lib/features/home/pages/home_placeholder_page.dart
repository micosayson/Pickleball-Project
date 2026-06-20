import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../auth/pages/login_page.dart';
import '../../auth/services/auth_service.dart';
import '../../courts/services/court_service.dart';
import '../../events/services/event_service.dart';
import 'dashboard_page.dart';
import 'bookings_page.dart';
import 'notifications_page.dart';
import 'matches_list_page.dart';
import 'court_details_page.dart';
import 'profile_history_page.dart';

part 'play/active_match_page.dart';
part 'play/court_sessions_page.dart';
part 'play/match_result_page.dart';
part 'play/my_session_page.dart';
part 'play/play_flow_page.dart';
part 'play/play_status_page.dart';
part 'play/session_details_page.dart';
part 'play/upcoming_match_page.dart';
part 'play/waiting_verification_page.dart';

const _courtGreen = Color(0xFF315C3A);
const _freshGreen = Color(0xFF78A85A);
const _clay = Color(0xFFD37A46);
const _ink = Color(0xFF17221B);
const _muted = Color(0xFF6A7A70);
const _chalk = Color(0xFFF7FAF5);
const _line = Color(0xFFE1E9DE);

enum _PlayPage {
  status,
  courtSessions,
  sessionDetails,
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
  late final _PrototypeMatch _prototypeMatch;
  CourtSummary? _selectedCourt;
  Future<List<EventSummary>>? _courtEventsFuture;
  EventSummary? _selectedSession;
  EventSummary? _activeSession;
  EventRegistrationSummary? _activeRegistration;
  String _lastResult = 'Backend checks have not run yet.';
  bool _isLoading = false;
  bool _matchFinished = false;
  int _selectedIndex = 0;
  _PlayPage _playPage = _PlayPage.status;

  @override
  void initState() {
    super.initState();
    final courts = _PrototypeData.courts();
    _prototypeMatch = _PrototypeData.match();
    _courtsFuture = Future.value(courts);
  }

  Future<void> _runRequest(
    Future<dynamic> Function() request,
    String label,
  ) async {
    setState(() {
      _isLoading = true;
      _lastResult = 'Running $label...';
    });

    try {
      final response = await request();
      if (!mounted) return;
      final result = response is Response ? response.data : response;
      setState(() {
        _lastResult = '$label succeeded: $result';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _lastResult = '$label failed: $error';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final fullName = user?.userMetadata?['full_name'] as String? ?? 'Player';
    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: _chalk,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final content = switch (_selectedIndex) {
              0 => _PlayTab(
                fullName: fullName,
                selectedCourt: _selectedCourt,
                courtEventsFuture: _courtEventsFuture,
                selectedSession: _selectedSession,
                activeSession: _activeSession,
                activeRegistration: _activeRegistration,
                prototypeMatch: _prototypeMatch,
                matchFinished: _matchFinished,
                playPage: _playPage,
                joinLobby: _joinLobby,
                onMatchFinished: _markMatchFinished,
                onOpenCourts: () => setState(() => _selectedIndex = 1),
                onShowStatus: () => _showPlayPage(_PlayPage.status),
                onShowSessions: () => _showPlayPage(_PlayPage.courtSessions),
                onSelectSession: _selectSession,
                onShowMySession: () => _showPlayPage(_PlayPage.mySession),
                onShowUpcomingMatch: () =>
                    _showPlayPage(_PlayPage.upcomingMatch),
                onGoToCourt: () => _showPlayPage(_PlayPage.activeMatch),
                onShowMatchResult: () => _showPlayPage(_PlayPage.matchResult),
                onReturnToQueue: _returnToQueue,
                onLeaveCourt: _leaveCourt,
              ),
              1 => _CourtsTab(
                courtsFuture: _courtsFuture,
                selectCourt: _selectCourt,
              ),
              2 => _ProfileTab(fullName: fullName, email: email, user: user),
              _ => _SettingsTab(
                isWide: isWide,
                isLoading: _isLoading,
                lastResult: _lastResult,
                fullName: fullName,
                user: user,
                runRequest: _runRequest,
              ),
            };

            return CustomScrollView(
              key: ValueKey(
                '$_selectedIndex-$_playPage-${_selectedCourt?.id}-${_selectedSession?.id}-${_activeSession?.id}',
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isWide ? 40 : 20,
                      18,
                      isWide ? 40 : 20,
                      18,
                    ),
                    child: _HomeHeader(
                      fullName: fullName,
                      email: email,
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
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    isWide ? 40 : 20,
                    0,
                    isWide ? 40 : 20,
                    28,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1120),
                      child: content,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.sports_tennis_rounded),
            label: 'Play',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_on_rounded),
            label: 'Courts',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Future<void> _joinLobby(EventSummary event) {
    return _runRequest(() async {
      final registration = _PrototypeData.joinLobby(event.id);
      if (mounted) {
        setState(() {
          _selectedSession = event;
          _activeSession = event;
          _activeRegistration = registration;
          _matchFinished = false;
          _playPage = _PlayPage.mySession;
        });
      }
      return registration;
    }, 'Join lobby');
  }

  void _markMatchFinished() {
    setState(() {
      _matchFinished = true;
      _lastResult =
          '${_prototypeMatch.matchNumber} marked finished. Waiting for verification.';
      _playPage = _PlayPage.waitingVerification;
    });
  }

  void _selectSession(EventSummary event) {
    setState(() {
      _selectedSession = event;
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

  void _returnToQueue() {
    setState(() {
      _matchFinished = false;
      _lastResult =
          '${_prototypeMatch.matchNumber} verified. Player returned to queue.';
      _playPage = _PlayPage.mySession;
      _selectedIndex = 0;
    });
  }

  void _leaveCourt() {
    setState(() {
      _activeSession = null;
      _activeRegistration = null;
      _matchFinished = false;
      _selectedSession = null;
      _playPage = _selectedCourt == null
          ? _PlayPage.status
          : _PlayPage.courtSessions;
      _selectedIndex = 0;
      _lastResult = 'Left court. Mock queue state cleared.';
    });
  }

  Future<void> _selectCourt(CourtSummary court) {
    return _runRequest(() async {
      if (mounted) {
        setState(() {
          _selectedCourt = court;
          _courtEventsFuture = Future.value(_PrototypeData.eventsForCourt(court.id));
          _selectedSession = null;
          _activeSession = null;
          _activeRegistration = null;
          _matchFinished = false;
          _playPage = _PlayPage.courtSessions;
          _selectedIndex = 0;
          _lastResult = 'Selected ${court.name}. Mock sessions loaded.';
        });
      }
      return court;
    }, 'Court selected');
  }
}

class _PlayTab extends StatelessWidget {
  const _PlayTab({
    required this.fullName,
    required this.selectedCourt,
    required this.courtEventsFuture,
    required this.selectedSession,
    required this.activeSession,
    required this.activeRegistration,
    required this.prototypeMatch,
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
  final _PrototypeMatch prototypeMatch;
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
    return _PlayFlowPage(
      fullName: fullName,
      selectedCourt: selectedCourt,
      courtEventsFuture: courtEventsFuture,
      selectedSession: selectedSession,
      activeSession: activeSession,
      activeRegistration: activeRegistration,
      prototypeMatch: prototypeMatch,
      matchFinished: matchFinished,
      playPage: playPage,
      joinLobby: joinLobby,
      onMatchFinished: onMatchFinished,
      onOpenCourts: onOpenCourts,
      onShowStatus: onShowStatus,
      onShowSessions: onShowSessions,
      onSelectSession: onSelectSession,
      onShowMySession: onShowMySession,
      onShowUpcomingMatch: onShowUpcomingMatch,
      onGoToCourt: onGoToCourt,
      onShowMatchResult: onShowMatchResult,
      onReturnToQueue: onReturnToQueue,
      onLeaveCourt: onLeaveCourt,
    );
  }
}

class _CourtsTab extends StatelessWidget {
  const _CourtsTab({required this.courtsFuture, required this.selectCourt});

  final Future<List<CourtSummary>> courtsFuture;
  final Future<void> Function(CourtSummary) selectCourt;

  @override
  Widget build(BuildContext context) {
    return _CourtDiscoveryPanel(
      courtsFuture: courtsFuture,
      onSelectCourt: selectCourt,
      maxItems: 12,
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({
    required this.fullName,
    required this.email,
    required this.user,
  });

  final String fullName;
  final String email;
  final User? user;

  @override
  Widget build(BuildContext context) {
    final role = user?.userMetadata?['platform_role']?.toString() ?? 'player';
    final createdAt = user?.createdAt;

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(icon: Icons.person_rounded, title: 'Profile'),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: _courtGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    fullName.isEmpty ? 'P' : fullName.characters.first,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email.isEmpty ? 'Signed in player' : email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ProfileRow(
            icon: Icons.badge_rounded,
            label: 'Role',
            value: role.toUpperCase(),
          ),
          _ProfileRow(
            icon: Icons.calendar_month_rounded,
            label: 'Account created',
            value: createdAt ?? 'Available after sync',
          ),
          _ProfileRow(
            icon: Icons.speed_rounded,
            label: 'Rating',
            value: 'Connect ratings screen',
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonal(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DashboardPage())),
                child: const Text('Dashboard'),
              ),
              FilledButton.tonal(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BookingsPage())),
                child: const Text('Bookings'),
              ),
              FilledButton.tonal(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsPage())),
                child: const Text('Notifications'),
              ),
              FilledButton.tonal(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MatchesListPage())),
                child: const Text('Matches'),
              ),
              FilledButton.tonal(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileHistoryPage())),
                child: const Text('Profile / History'),
              ),
              FilledButton.tonal(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CourtDetailsPage(courtId: 'skyline-courts'))),
                child: const Text('Court details'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: _courtGreen, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: _muted, fontSize: 13.5),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _ink,
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab({
    required this.isWide,
    required this.isLoading,
    required this.lastResult,
    required this.fullName,
    required this.user,
    required this.runRequest,
  });

  final bool isWide;
  final bool isLoading;
  final String lastResult;
  final String fullName;
  final User? user;
  final Future<void> Function(Future<dynamic> Function(), String) runRequest;

  @override
  Widget build(BuildContext context) {
    final checks = _DeveloperChecks(
      isLoading: isLoading,
      lastResult: lastResult,
      fullName: fullName,
      user: user,
      runRequest: runRequest,
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(flex: 4, child: _ReadinessCard()),
          const SizedBox(width: 20),
          Expanded(flex: 7, child: checks),
        ],
      );
    }

    return Column(
      children: [const _ReadinessCard(), const SizedBox(height: 16), checks],
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.fullName,
    required this.email,
    required this.onSignOut,
  });

  final String fullName;
  final String email;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1120),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _courtGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.sports_tennis_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plaqora',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  email.isEmpty ? fullName : email,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: onSignOut,
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
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
    return _Panel(
      color: _courtGreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (onBack != null) ...[
                IconButton.filledTonal(
                  onPressed: onBack,
                  tooltip: 'Back',
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: 10),
              ],
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const Spacer(),
              ?trailing,
            ],
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            detail,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 15,
              height: 1.45,
            ),
          ),
        ],
      ),
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
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _courtGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
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
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onPressed,
              style: _primaryButtonStyle(),
              child: Text(actionLabel),
            ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: const Text(
              'Player hub',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            detail,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 15,
              height: 1.45,
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
    this.maxItems = 3,
  });

  final Future<List<CourtSummary>> courtsFuture;
  final Future<void> Function(CourtSummary) onSelectCourt;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.location_on_rounded,
            title: 'Nearby courts',
          ),
          const SizedBox(height: 6),
          const Text(
            'Choose a court for events, match play, and ladder activity.',
            style: TextStyle(color: _muted, fontSize: 13.5, height: 1.35),
          ),
          const SizedBox(height: 14),
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
                  detail:
                      'Create an active court record to make discovery live.',
                  color: _courtGreen,
                );
              }

              final visibleCourts = courts
                  .take(maxItems)
                  .toList(growable: false);
              return Column(
                children: [
                  for (final court in visibleCourts) ...[
                    _CourtTile(
                      court: court,
                      onSelect: () => onSelectCourt(court),
                    ),
                    if (court != visibleCourts.last) const SizedBox(height: 10),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CourtTile extends StatelessWidget {
  const _CourtTile({required this.court, required this.onSelect});

  final CourtSummary court;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final address = court.address?.trim();
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _courtGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.sports_tennis_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  court.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address == null || address.isEmpty
                      ? 'Community court'
                      : address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, fontSize: 12.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton.filledTonal(
            onPressed: onSelect,
            tooltip: 'Select court',
            icon: const Icon(Icons.check_circle_rounded),
          ),
        ],
      ),
    );
  }
}

class _SessionDetailsCard extends StatelessWidget {
  const _SessionDetailsCard({
    required this.court,
    required this.event,
    required this.onJoinLobby,
  });

  final CourtSummary court;
  final EventSummary event;
  final VoidCallback onJoinLobby;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SessionBanner(event: event),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              children: [
                _SessionMetaRow(
                  icon: Icons.schedule_rounded,
                  text: _formatTimeRange(event.startAt, event.endAt),
                ),
                _SessionMetaRow(
                  icon: Icons.location_on_rounded,
                  text: court.name,
                ),
                const _SessionMetaRow(
                  icon: Icons.payments_rounded,
                  text: 'Payment verified before check-in',
                ),
                _SessionMetaRow(
                  icon: Icons.sports_tennis_rounded,
                  text: _eventTypeLabel(event.eventType),
                ),
                _SessionMetaRow(
                  icon: Icons.groups_rounded,
                  text: event.capacity == null
                      ? 'Open player capacity'
                      : '${event.capacity} player capacity',
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onJoinLobby,
                    style: FilledButton.styleFrom(
                      backgroundColor: _freshGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Join lobby'),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _chalk,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _line),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Session info',
                        style: TextStyle(
                          color: _ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Check in at the court to enter the queue. The system will notify you when your match is ready.',
                        style: TextStyle(
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
          ),
        ],
      ),
    );
  }
}

class _SessionBanner extends StatelessWidget {
  const _SessionBanner({required this.event});

  final EventSummary event;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 98,
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_ink, _courtGreen],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -34,
            child: Icon(
              Icons.sports_tennis_rounded,
              color: Colors.white.withValues(alpha: 0.12),
              size: 124,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _freshGreen,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  event.status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
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

class _MySessionCard extends StatelessWidget {
  const _MySessionCard({
    required this.court,
    required this.session,
    required this.registration,
    required this.prototypeMatch,
  });

  final CourtSummary court;
  final EventSummary session;
  final EventRegistrationSummary? registration;
  final _PrototypeMatch prototypeMatch;

  @override
  Widget build(BuildContext context) {
    final status = registration?.status.replaceAll('_', ' ') ?? 'checked in';
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.fact_check_rounded,
            title: 'My session',
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F6FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD8E5FF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimeRange(session.startAt, session.endAt),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, fontSize: 12.5),
                ),
                const SizedBox(height: 5),
                Text.rich(
                  TextSpan(
                    text: 'Status: ',
                    style: const TextStyle(color: _muted, fontSize: 12.5),
                    children: [
                      TextSpan(
                        text: _titleCase(status),
                        style: const TextStyle(
                          color: _freshGreen,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _SessionMetaRow(
                  icon: Icons.confirmation_number_rounded,
                  text:
                      'Match ${prototypeMatch.matchNumber} - Queue position ${prototypeMatch.queuePosition}',
                ),
                _SessionMetaRow(
                  icon: Icons.timer_rounded,
                  text: 'Estimated wait ${prototypeMatch.estimatedWait}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: _SessionStep(
                  icon: Icons.person_add_alt_1_rounded,
                  label: 'Joined',
                  active: false,
                ),
              ),
              Expanded(
                child: _SessionStep(
                  icon: Icons.payments_rounded,
                  label: 'Paid',
                  active: false,
                ),
              ),
              Expanded(
                child: _SessionStep(
                  icon: Icons.check_rounded,
                  label: 'Checked in',
                  active: true,
                ),
              ),
              Expanded(
                child: _SessionStep(
                  icon: Icons.groups_rounded,
                  label: 'Playing',
                  active: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F6FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD8E5FF)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.notifications_active_rounded,
                  color: _freshGreen,
                  size: 34,
                ),
                const SizedBox(height: 10),
                const Text(
                  "You're in the queue",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'You will be notified when ${prototypeMatch.matchNumber} is ready at ${court.name}.',
                  textAlign: TextAlign.center,
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
          child: Icon(icon, color: active ? Colors.white : color, size: 18),
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
    required this.prototypeMatch,
    required this.onGoToCourt,
  });

  final CourtSummary court;
  final _PrototypeMatch prototypeMatch;
  final VoidCallback onGoToCourt;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.sports_score_rounded,
            title: 'Upcoming match',
          ),
          const SizedBox(height: 16),
          const Text(
            'Your match is ready',
            style: TextStyle(
              color: _ink,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${court.name} - Match ${prototypeMatch.matchNumber}',
            style: const TextStyle(color: _muted, fontSize: 12.5),
          ),
          const SizedBox(height: 16),
          _TeamCard(
            name: prototypeMatch.homeTeam.name,
            color: prototypeMatch.homeTeam.color,
            tint: prototypeMatch.homeTeam.tint,
            border: prototypeMatch.homeTeam.border,
            players: prototypeMatch.homeTeam.players,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Center(
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
          _TeamCard(
            name: prototypeMatch.awayTeam.name,
            color: prototypeMatch.awayTeam.color,
            tint: prototypeMatch.awayTeam.tint,
            border: prototypeMatch.awayTeam.border,
            players: prototypeMatch.awayTeam.players,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onGoToCourt,
              style: _primaryButtonStyle(),
              child: const Text('Go to court'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchResultCard extends StatelessWidget {
  const _MatchResultCard({
    required this.court,
    required this.prototypeMatch,
    required this.matchFinished,
    required this.onMatchFinished,
  });

  final CourtSummary court;
  final _PrototypeMatch prototypeMatch;
  final bool matchFinished;
  final VoidCallback onMatchFinished;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.task_alt_rounded,
            title: 'Match result',
          ),
          const SizedBox(height: 14),
          Text(
            'Match ${prototypeMatch.matchNumber}',
            style: TextStyle(
              color: _ink,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${court.name} - ${prototypeMatch.scoreSummary}',
            style: const TextStyle(color: _muted, fontSize: 12.5),
          ),
          const Divider(height: 28, color: _line),
          Center(
            child: Text(
              prototypeMatch.homeTeam.name,
              style: const TextStyle(
                color: _ink,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(child: _ScoreBox(score: prototypeMatch.homeScore)),
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
          Center(
            child: Text(
              prototypeMatch.awayTeam.name,
              style: const TextStyle(
                color: _ink,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(child: _ScoreBox(score: prototypeMatch.awayScore)),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: matchFinished ? null : onMatchFinished,
              style: FilledButton.styleFrom(
                backgroundColor: _freshGreen,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _freshGreen.withValues(alpha: 0.5),
                disabledForegroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Match finished'),
            ),
          ),
          if (matchFinished) ...[
            const SizedBox(height: 10),
            Center(
              child: Text(
                '${prototypeMatch.verifierName} is confirming the result',
                style: const TextStyle(
                  color: _muted,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard({
    required this.name,
    required this.color,
    required this.tint,
    required this.border,
    required this.players,
  });

  final String name;
  final Color color;
  final Color tint;
  final Color border;
  final List<_MatchPlayer> players;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              color: color,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          for (final player in players) ...[
            _PlayerLine(player: player),
            if (player != players.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _PlayerLine extends StatelessWidget {
  const _PlayerLine({required this.player});

  final _MatchPlayer player;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: _courtGreen,
          child: Text(
            player.name.characters.first,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            player.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _ink,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          player.rating,
          style: const TextStyle(
            color: _ink,
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _MatchPlayer {
  const _MatchPlayer({required this.name, required this.rating});

  final String name;
  final String rating;
}

class _ScoreBox extends StatelessWidget {
  const _ScoreBox({required this.score});

  final String score;

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
      child: Text(
        score,
        style: const TextStyle(
          color: _ink,
          fontSize: 30,
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

String _formatClock(DateTime value) {
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final minute = value.minute.toString().padLeft(2, '0');
  final suffix = value.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $suffix';
}

String _eventTypeLabel(String eventType) {
  return _titleCase(eventType.replaceAll('_', ' '));
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
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
}

ButtonStyle _dangerOutlineButtonStyle() {
  return OutlinedButton.styleFrom(
    foregroundColor: const Color(0xFFD34343),
    side: const BorderSide(color: Color(0xFFD34343)),
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

class _ReadinessCard extends StatelessWidget {
  const _ReadinessCard();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SectionTitle(
            icon: Icons.check_circle_rounded,
            title: 'Build readiness',
          ),
          SizedBox(height: 14),
          _ReadinessRow(text: 'Supabase Auth connected'),
          _ReadinessRow(text: 'FastAPI profile sync live'),
          _ReadinessRow(text: 'Events, matches, ratings, rankings routed'),
        ],
      ),
    );
  }
}

class _ReadinessRow extends StatelessWidget {
  const _ReadinessRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.done_rounded, color: _freshGreen, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: _muted, fontSize: 13.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeveloperChecks extends StatelessWidget {
  const _DeveloperChecks({
    required this.isLoading,
    required this.lastResult,
    required this.fullName,
    required this.user,
    required this.runRequest,
  });

  final bool isLoading;
  final String lastResult;
  final String fullName;
  final User? user;
  final Future<void> Function(Future<dynamic> Function(), String) runRequest;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.api_rounded,
            title: 'Live API checks',
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _CheckButton(
                label: 'Auth',
                icon: Icons.verified_user_rounded,
                isLoading: isLoading,
                onPressed: () => runRequest(
                  () => ApiClient.instance.get(ApiEndpoints.authMe),
                  'GET /auth/me',
                ),
              ),
              _CheckButton(
                label: 'Sync profile',
                icon: Icons.sync_rounded,
                isLoading: isLoading,
                onPressed: () => runRequest(
                  () => ApiClient.instance.post(
                    ApiEndpoints.userSync,
                    data: {
                      'full_name': fullName,
                      'avatar_url': user?.userMetadata?['avatar_url'],
                    },
                  ),
                  'POST /users/sync',
                ),
              ),
              _CheckButton(
                label: 'Update name',
                icon: Icons.edit_rounded,
                isLoading: isLoading,
                onPressed: () => runRequest(
                  () => ApiClient.instance.patch(
                    ApiEndpoints.usersMe,
                    data: {'full_name': '$fullName Updated'},
                  ),
                  'PATCH /users/me',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _CheckButton(
                label: 'Courts',
                icon: Icons.location_on_rounded,
                isLoading: isLoading,
                onPressed: () => runRequest(
                  () => ApiClient.instance.get(ApiEndpoints.courts),
                  'GET /courts',
                ),
              ),
              _CheckButton(
                label: 'My courts',
                icon: Icons.groups_rounded,
                isLoading: isLoading,
                onPressed: () => runRequest(
                  () => ApiClient.instance.get(
                    '${ApiEndpoints.courtMemberships}/me',
                  ),
                  'GET /court-memberships/me',
                ),
              ),
              _CheckButton(
                label: 'Events',
                icon: Icons.event_available_rounded,
                isLoading: isLoading,
                onPressed: () => runRequest(
                  () => ApiClient.instance.get(ApiEndpoints.events),
                  'GET /events',
                ),
              ),
              _CheckButton(
                label: 'My events',
                icon: Icons.event_seat_rounded,
                isLoading: isLoading,
                onPressed: () => runRequest(
                  () => ApiClient.instance.get(
                    '${ApiEndpoints.eventRegistrations}/me',
                  ),
                  'GET /event-registrations/me',
                ),
              ),
              _CheckButton(
                label: 'Matches',
                icon: Icons.sports_score_rounded,
                isLoading: isLoading,
                onPressed: () => runRequest(
                  () => ApiClient.instance.get(ApiEndpoints.matches),
                  'GET /matches',
                ),
              ),
              _CheckButton(
                label: 'Ratings',
                icon: Icons.speed_rounded,
                isLoading: isLoading,
                onPressed: () => runRequest(
                  () => ApiClient.instance.get(ApiEndpoints.ratings),
                  'GET /ratings',
                ),
              ),
              _CheckButton(
                label: 'Rankings',
                icon: Icons.leaderboard_rounded,
                isLoading: isLoading,
                onPressed: () => runRequest(
                  () => ApiClient.instance.get(ApiEndpoints.rankings),
                  'GET /rankings',
                ),
              ),
              _CheckButton(
                label: 'Scores',
                icon: Icons.scoreboard_rounded,
                isLoading: isLoading,
                onPressed: () => runRequest(
                  () => ApiClient.instance.get(ApiEndpoints.scoreSubmissions),
                  'GET /score-submissions',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _chalk,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _line),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 150),
              child: SingleChildScrollView(
                child: Text(
                  lastResult,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckButton extends StatelessWidget {
  const _CheckButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: _ink,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
  const _Panel({required this.child, this.color = Colors.white});

  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: color == Colors.white ? Border.all(color: _line) : null,
      ),
      child: child,
    );
  }
}

class _PrototypeData {
  static List<CourtSummary> courts() {
    return const [
      CourtSummary(
        id: 'court-riverview',
        name: 'Riverview Pickleball Club',
        slug: 'riverview-pickleball-club',
        status: 'active',
        address: '12 Harbor Ave, Taipei',
        contactInfo: 'Queue master: Ana',
      ),
      CourtSummary(
        id: 'court-skyline',
        name: 'Skyline Courts',
        slug: 'skyline-courts',
        status: 'active',
        address: '88 Aurora Street, Taipei',
        contactInfo: 'Queue master: Mico',
      ),
      CourtSummary(
        id: 'court-sunrise',
        name: 'Sunrise Sports Hub',
        slug: 'sunrise-sports-hub',
        status: 'active',
        address: '44 Dawn Lane, New Taipei',
        contactInfo: 'Queue master: Joey',
      ),
    ];
  }

  static List<EventSummary> eventsForCourt(String courtId) {
    switch (courtId) {
      case 'court-riverview':
        return _buildSessions(
          courtId,
          [
            ('Thursday Competitive Play', 'competitive_play', 16, 0, 90),
            ('Sunset Ladder Night', 'ladder_match', 16, 150, 90),
            ('Weekend Social Warmup', 'open_play', 20, 330, 120),
          ],
        );
      case 'court-skyline':
        return _buildSessions(
          courtId,
          [
            ('City League Rotation', 'competitive_play', 12, 45, 90),
            ('Late Court Ladder', 'ladder_match', 12, 210, 90),
            ('All Levels Open Play', 'open_play', 18, 360, 120),
          ],
        );
      case 'court-sunrise':
        return _buildSessions(
          courtId,
          [
            ('Morning Open Play', 'open_play', 18, 30, 120),
            ('Friday Mixed Doubles', 'competitive_play', 16, 180, 90),
            ('Kings Court Ladder', 'ladder_match', 10, 300, 90),
          ],
        );
      default:
        return _buildSessions(
          courtId,
          [
            ('Open Play', 'open_play', 12, 60, 120),
          ],
        );
    }
  }

  static EventRegistrationSummary joinLobby(String eventId) {
    return EventRegistrationSummary(
      id: 'registration-$eventId',
      eventId: eventId,
      status: 'checked_in',
      checkedInAt: DateTime.now().toUtc().subtract(const Duration(minutes: 6)),
    );
  }

  static _PrototypeMatch match() {
    return _PrototypeMatch(
      matchNumber: '102',
      queuePosition: '3',
      estimatedWait: '14 min',
      verifierName: 'Court Marshal Ana',
      homeScore: '11',
      awayScore: '7',
      homeTeam: _PrototypeMatchTeam(
        name: 'Team A',
        color: const Color(0xFF3B82F6),
        tint: const Color(0xFFF1F6FF),
        border: const Color(0xFFD8E5FF),
        players: const [
          _MatchPlayer(name: 'Mico Santos', rating: '3.20'),
          _MatchPlayer(name: 'John Reyes', rating: '3.15'),
        ],
      ),
      awayTeam: _PrototypeMatchTeam(
        name: 'Team B',
        color: const Color(0xFFE43F5A),
        tint: const Color(0xFFFFF1F4),
        border: const Color(0xFFF9D7DF),
        players: const [
          _MatchPlayer(name: 'Anna Garcia', rating: '3.25'),
          _MatchPlayer(name: 'Kyle Wong', rating: '3.10'),
        ],
      ),
    );
  }

  static List<EventSummary> _buildSessions(
    String courtId,
    List<(String, String, int, int, int)> specs,
  ) {
    final baseDate = DateTime.now().toUtc();
    return List<EventSummary>.unmodifiable(
      specs
          .asMap()
          .entries
          .map((entry) {
            final index = entry.key;
            final spec = entry.value;
            final startAt = baseDate.add(Duration(hours: spec.$4));
            final endAt = startAt.add(Duration(minutes: spec.$5));
            return EventSummary(
              id: '$courtId-${index + 1}',
              courtId: courtId,
              name: spec.$1,
              eventType: spec.$2,
              status: index == 0 ? 'in_progress' : 'scheduled',
              startAt: startAt,
              endAt: endAt,
              capacity: spec.$3,
            );
          })
          .toList(growable: false),
    );
  }
}

class _PrototypeMatch {
  const _PrototypeMatch({
    required this.matchNumber,
    required this.queuePosition,
    required this.estimatedWait,
    required this.verifierName,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
  });

  final String matchNumber;
  final String queuePosition;
  final String estimatedWait;
  final String verifierName;
  final _PrototypeMatchTeam homeTeam;
  final _PrototypeMatchTeam awayTeam;
  final String homeScore;
  final String awayScore;

  String get scoreSummary => '$homeScore-$awayScore';
}

class _PrototypeMatchTeam {
  const _PrototypeMatchTeam({
    required this.name,
    required this.color,
    required this.tint,
    required this.border,
    required this.players,
  });

  final String name;
  final Color color;
  final Color tint;
  final Color border;
  final List<_MatchPlayer> players;
}
