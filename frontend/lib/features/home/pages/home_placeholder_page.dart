import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../auth/pages/login_page.dart';
import '../../auth/services/auth_service.dart';
import '../../courts/services/court_service.dart';
import '../../events/services/event_service.dart';

const _courtGreen = Color(0xFF315C3A);
const _freshGreen = Color(0xFF78A85A);
const _clay = Color(0xFFD37A46);
const _ink = Color(0xFF17221B);
const _muted = Color(0xFF6A7A70);
const _chalk = Color(0xFFF7FAF5);
const _line = Color(0xFFE1E9DE);

class HomePlaceholderPage extends StatefulWidget {
  const HomePlaceholderPage({super.key});

  @override
  State<HomePlaceholderPage> createState() => _HomePlaceholderPageState();
}

class _HomePlaceholderPageState extends State<HomePlaceholderPage> {
  late final Future<List<CourtSummary>> _courtsFuture;
  CourtSummary? _selectedCourt;
  Future<List<EventSummary>>? _courtEventsFuture;
  EventSummary? _activeSession;
  EventRegistrationSummary? _activeRegistration;
  String _lastResult = 'Backend checks have not run yet.';
  bool _isLoading = false;
  bool _matchFinished = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _courtsFuture = const CourtService().listCourts();
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
                activeSession: _activeSession,
                activeRegistration: _activeRegistration,
                matchFinished: _matchFinished,
                joinLobby: _joinLobby,
                onMatchFinished: _markMatchFinished,
                onOpenCourts: () => setState(() => _selectedIndex = 1),
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
      final registration = await const EventService().joinLobby(event.id);
      if (mounted) {
        setState(() {
          _activeSession = event;
          _activeRegistration = registration;
          _matchFinished = false;
        });
      }
      return registration;
    }, 'Join lobby');
  }

  void _markMatchFinished() {
    setState(() {
      _matchFinished = true;
      _lastResult = 'Match #102 marked finished. Waiting for verification.';
    });
  }

  Future<void> _selectCourt(CourtSummary court) {
    return _runRequest(() async {
      final selection = await const CourtMembershipService().joinCourt(
        court.id,
      );
      if (mounted) {
        setState(() {
          _selectedCourt = court;
          _courtEventsFuture = const EventService().listEvents(
            limit: 12,
            courtId: court.id,
          );
          _activeSession = null;
          _activeRegistration = null;
          _matchFinished = false;
          _selectedIndex = 0;
        });
      }
      return selection;
    }, 'Court selected');
  }
}

class _PlayTab extends StatelessWidget {
  const _PlayTab({
    required this.fullName,
    required this.selectedCourt,
    required this.courtEventsFuture,
    required this.activeSession,
    required this.activeRegistration,
    required this.matchFinished,
    required this.joinLobby,
    required this.onMatchFinished,
    required this.onOpenCourts,
  });

  final String fullName;
  final CourtSummary? selectedCourt;
  final Future<List<EventSummary>>? courtEventsFuture;
  final EventSummary? activeSession;
  final EventRegistrationSummary? activeRegistration;
  final bool matchFinished;
  final Future<void> Function(EventSummary) joinLobby;
  final VoidCallback onMatchFinished;
  final VoidCallback onOpenCourts;

  @override
  Widget build(BuildContext context) {
    return _MainColumn(
      fullName: fullName,
      selectedCourt: selectedCourt,
      courtEventsFuture: courtEventsFuture,
      activeSession: activeSession,
      activeRegistration: activeRegistration,
      matchFinished: matchFinished,
      joinLobby: joinLobby,
      onMatchFinished: onMatchFinished,
      onOpenCourts: onOpenCourts,
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

class _MainColumn extends StatelessWidget {
  const _MainColumn({
    required this.fullName,
    required this.selectedCourt,
    required this.courtEventsFuture,
    required this.activeSession,
    required this.activeRegistration,
    required this.matchFinished,
    required this.joinLobby,
    required this.onMatchFinished,
    required this.onOpenCourts,
  });

  final String fullName;
  final CourtSummary? selectedCourt;
  final Future<List<EventSummary>>? courtEventsFuture;
  final EventSummary? activeSession;
  final EventRegistrationSummary? activeRegistration;
  final bool matchFinished;
  final Future<void> Function(EventSummary) joinLobby;
  final VoidCallback onMatchFinished;
  final VoidCallback onOpenCourts;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeroPanel(fullName: fullName),
        const SizedBox(height: 16),
        if (selectedCourt == null || courtEventsFuture == null)
          _SelectCourtFirstPanel(onOpenCourts: onOpenCourts)
        else if (activeSession == null)
          _EventDiscoveryPanel(
            court: selectedCourt!,
            eventsFuture: courtEventsFuture!,
            onJoinLobby: joinLobby,
          )
        else
          _CheckedInSessionPanel(
            court: selectedCourt!,
            session: activeSession!,
            registration: activeRegistration,
            matchFinished: matchFinished,
            onMatchFinished: onMatchFinished,
          ),
      ],
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.fullName});

  final String fullName;

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
            'Ready for the next rally, $fullName?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Select a court, join its lobby, and wait for your upcoming match.',
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

class _SelectCourtFirstPanel extends StatelessWidget {
  const _SelectCourtFirstPanel({required this.onOpenCourts});

  final VoidCallback onOpenCourts;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.location_on_rounded,
            title: 'Court lobby',
          ),
          const SizedBox(height: 12),
          const Text(
            'Select a court before joining a session lobby.',
            style: TextStyle(color: _muted, fontSize: 13.5, height: 1.35),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: onOpenCourts,
              icon: const Icon(Icons.map_rounded, size: 18),
              label: const Text('Choose court'),
              style: FilledButton.styleFrom(
                backgroundColor: _ink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventDiscoveryPanel extends StatelessWidget {
  const _EventDiscoveryPanel({
    required this.court,
    required this.eventsFuture,
    required this.onJoinLobby,
  });

  final CourtSummary court;
  final Future<List<EventSummary>> eventsFuture;
  final Future<void> Function(EventSummary) onJoinLobby;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(
                icon: Icons.event_available_rounded,
                title: '${court.name} sessions',
              ),
              const SizedBox(height: 6),
              const Text(
                'Join a session when you are ready to check in and enter the automatic match queue.',
                style: TextStyle(color: _muted, fontSize: 13.5, height: 1.35),
              ),
              const SizedBox(height: 14),
              FutureBuilder<List<EventSummary>>(
                future: eventsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _InlineLoadingState();
                  }
                  if (snapshot.hasError) {
                    return _CourtMessageState(
                      icon: Icons.cloud_off_rounded,
                      title: 'Events are unavailable',
                      detail: 'Check the backend connection and try again.',
                      color: _clay,
                    );
                  }

                  final events = snapshot.data ?? [];
                  if (events.isEmpty) {
                    return const _CourtMessageState(
                      icon: Icons.event_busy_rounded,
                      title: 'No sessions for this court',
                      detail: 'Court sessions will appear here when available.',
                      color: _courtGreen,
                    );
                  }

                  return Column(
                    children: [
                      for (final event in events) ...[
                        _SessionDetailsCard(
                          court: court,
                          event: event,
                          onJoinLobby: () => onJoinLobby(event),
                        ),
                        if (event != events.last) const SizedBox(height: 12),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
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

class _CheckedInSessionPanel extends StatelessWidget {
  const _CheckedInSessionPanel({
    required this.court,
    required this.session,
    required this.registration,
    required this.matchFinished,
    required this.onMatchFinished,
  });

  final CourtSummary court;
  final EventSummary session;
  final EventRegistrationSummary? registration;
  final bool matchFinished;
  final VoidCallback onMatchFinished;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MySessionCard(
          court: court,
          session: session,
          registration: registration,
        ),
        const SizedBox(height: 16),
        _UpcomingMatchCard(court: court),
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

class _MySessionCard extends StatelessWidget {
  const _MySessionCard({
    required this.court,
    required this.session,
    required this.registration,
  });

  final CourtSummary court;
  final EventSummary session;
  final EventRegistrationSummary? registration;

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
                  'You will be notified when your match at ${court.name} is ready.',
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
  const _UpcomingMatchCard({required this.court});

  final CourtSummary court;

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
            '${court.name} - Match #102',
            style: const TextStyle(color: _muted, fontSize: 12.5),
          ),
          const SizedBox(height: 16),
          const _TeamCard(
            name: 'Team A',
            color: Color(0xFF3B82F6),
            tint: Color(0xFFF1F6FF),
            border: Color(0xFFD8E5FF),
            players: [
              _MatchPlayer(name: 'Mico Santos', rating: '3.20'),
              _MatchPlayer(name: 'John Reyes', rating: '3.15'),
            ],
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
          const _TeamCard(
            name: 'Team B',
            color: Color(0xFFE43F5A),
            tint: Color(0xFFFFF1F4),
            border: Color(0xFFF9D7DF),
            players: [
              _MatchPlayer(name: 'Anna Garcia', rating: '3.25'),
              _MatchPlayer(name: 'Kyle Wong', rating: '3.10'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: _freshGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
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
    required this.matchFinished,
    required this.onMatchFinished,
  });

  final CourtSummary court;
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
          const Text(
            'Match #102',
            style: TextStyle(
              color: _ink,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            court.name,
            style: const TextStyle(color: _muted, fontSize: 12.5),
          ),
          const Divider(height: 28, color: _line),
          const Center(
            child: Text(
              'Team A',
              style: TextStyle(
                color: _ink,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(child: _ScoreBox(score: '11')),
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
              'Team B',
              style: TextStyle(
                color: _ink,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(child: _ScoreBox(score: '7')),
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
            const Center(
              child: Text(
                'Waiting for queue master verification',
                style: TextStyle(
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
