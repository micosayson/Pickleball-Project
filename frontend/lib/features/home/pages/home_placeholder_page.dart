import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../auth/pages/login_page.dart';
import '../../auth/services/auth_service.dart';
import '../../courts/services/court_service.dart';
import '../../events/services/event_service.dart';
import '../../scores/services/score_submission_service.dart';

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
  late final Future<List<EventSummary>> _eventsFuture;
  late final Future<List<ScoreSubmissionSummary>> _scoresFuture;
  String _lastResult = 'Backend checks have not run yet.';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _courtsFuture = const CourtService().listCourts();
    _eventsFuture = const EventService().listEvents();
    _scoresFuture = const ScoreSubmissionService().listRecent();
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
      setState(() {
        _lastResult = '$label succeeded: ${response.data}';
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
                      child: isWide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: _MainColumn(
                                    isLoading: _isLoading,
                                    lastResult: _lastResult,
                                    fullName: fullName,
                                    user: user,
                                    courtsFuture: _courtsFuture,
                                    eventsFuture: _eventsFuture,
                                    scoresFuture: _scoresFuture,
                                    joinEvent: _joinEvent,
                                    runRequest: _runRequest,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                const Expanded(flex: 4, child: _SideColumn()),
                              ],
                            )
                          : Column(
                              children: [
                                _MainColumn(
                                  isLoading: _isLoading,
                                  lastResult: _lastResult,
                                  fullName: fullName,
                                  user: user,
                                  courtsFuture: _courtsFuture,
                                  eventsFuture: _eventsFuture,
                                  scoresFuture: _scoresFuture,
                                  joinEvent: _joinEvent,
                                  runRequest: _runRequest,
                                ),
                                const SizedBox(height: 16),
                                const _SideColumn(),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _joinEvent(EventSummary event) {
    return _runRequest(
      () => const EventService().joinEvent(event.id),
      'POST /event-registrations/${event.id}',
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
    required this.isLoading,
    required this.lastResult,
    required this.fullName,
    required this.user,
    required this.courtsFuture,
    required this.eventsFuture,
    required this.scoresFuture,
    required this.joinEvent,
    required this.runRequest,
  });

  final bool isLoading;
  final String lastResult;
  final String fullName;
  final User? user;
  final Future<List<CourtSummary>> courtsFuture;
  final Future<List<EventSummary>> eventsFuture;
  final Future<List<ScoreSubmissionSummary>> scoresFuture;
  final Future<void> Function(EventSummary) joinEvent;
  final Future<void> Function(Future<dynamic> Function(), String) runRequest;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeroPanel(fullName: fullName),
        const SizedBox(height: 16),
        const _CourtDataStrip(),
        const SizedBox(height: 16),
        _CourtDiscoveryPanel(courtsFuture: courtsFuture),
        const SizedBox(height: 16),
        _EventDiscoveryPanel(
          eventsFuture: eventsFuture,
          onJoinEvent: joinEvent,
        ),
        const SizedBox(height: 16),
        _RecentScoresPanel(scoresFuture: scoresFuture),
        const SizedBox(height: 16),
        const _QuickActions(),
        const SizedBox(height: 16),
        _DeveloperChecks(
          isLoading: isLoading,
          lastResult: lastResult,
          fullName: fullName,
          user: user,
          runRequest: runRequest,
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
            'Find open play, track competitive results, and keep your profile synced with the backend.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 15,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _MetricTile(label: 'Rating', value: '3.50'),
              _MetricTile(label: 'Events', value: '0'),
              _MetricTile(label: 'Matches', value: '0'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: MediaQuery.sizeOf(context).width >= 620 ? 3 : 1,
      childAspectRatio: MediaQuery.sizeOf(context).width >= 620 ? 1.25 : 4.2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        _ActionTile(
          icon: Icons.map_rounded,
          title: 'Discover courts',
          detail: 'Find places to play nearby.',
        ),
        _ActionTile(
          icon: Icons.event_available_rounded,
          title: 'Join events',
          detail: 'Open play and competitive sessions.',
        ),
        _ActionTile(
          icon: Icons.leaderboard_rounded,
          title: 'Track ratings',
          detail: 'Match results drive rankings.',
        ),
      ],
    );
  }
}

class _CourtDiscoveryPanel extends StatelessWidget {
  const _CourtDiscoveryPanel({required this.courtsFuture});

  final Future<List<CourtSummary>> courtsFuture;

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
            'Choose a community before joining events or tracking ladder play.',
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

              final visibleCourts = courts.take(3).toList(growable: false);
              return Column(
                children: [
                  for (final court in visibleCourts) ...[
                    _CourtTile(court: court),
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
  const _CourtTile({required this.court});

  final CourtSummary court;

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
          _StatusPill(label: court.status),
        ],
      ),
    );
  }
}

class _EventDiscoveryPanel extends StatelessWidget {
  const _EventDiscoveryPanel({
    required this.eventsFuture,
    required this.onJoinEvent,
  });

  final Future<List<EventSummary>> eventsFuture;
  final Future<void> Function(EventSummary) onJoinEvent;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.event_available_rounded,
            title: 'Open events',
          ),
          const SizedBox(height: 6),
          const Text(
            'Join active sessions and move into match play from your event list.',
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
                  title: 'No events published yet',
                  detail: 'Published sessions will appear here.',
                  color: _courtGreen,
                );
              }

              return Column(
                children: [
                  for (final event in events) ...[
                    _EventTile(event: event, onJoin: () => onJoinEvent(event)),
                    if (event != events.last) const SizedBox(height: 10),
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

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event, required this.onJoin});

  final EventSummary event;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final start = event.startAt.toLocal();
    final timeLabel =
        '${start.month}/${start.day} ${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final typeLabel = event.eventType.replaceAll('_', ' ');
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
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _clay,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.event_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
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
                  '$timeLabel · $typeLabel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, fontSize: 12.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton.filledTonal(
            onPressed: onJoin,
            tooltip: 'Join event',
            icon: const Icon(Icons.person_add_alt_1_rounded),
          ),
        ],
      ),
    );
  }
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: _freshGreen.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _courtGreen,
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _RecentScoresPanel extends StatelessWidget {
  const _RecentScoresPanel({required this.scoresFuture});

  final Future<List<ScoreSubmissionSummary>> scoresFuture;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.scoreboard_rounded,
            title: 'Recent scores',
          ),
          const SizedBox(height: 6),
          const Text(
            'Submitted match scores appear here before ratings and rankings move.',
            style: TextStyle(color: _muted, fontSize: 13.5, height: 1.35),
          ),
          const SizedBox(height: 14),
          FutureBuilder<List<ScoreSubmissionSummary>>(
            future: scoresFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _InlineLoadingState();
              }
              if (snapshot.hasError) {
                return _CourtMessageState(
                  icon: Icons.report_problem_rounded,
                  title: 'Scores are unavailable',
                  detail: 'Check the backend connection and try again.',
                  color: _clay,
                );
              }

              final scores = snapshot.data ?? [];
              if (scores.isEmpty) {
                return const _CourtMessageState(
                  icon: Icons.scoreboard_rounded,
                  title: 'No scores submitted yet',
                  detail: 'Completed matches will show here after submission.',
                  color: _courtGreen,
                );
              }

              return Column(
                children: [
                  for (final score in scores) ...[
                    _ScoreTile(score: score),
                    if (score != scores.last) const SizedBox(height: 10),
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

class _ScoreTile extends StatelessWidget {
  const _ScoreTile({required this.score});

  final ScoreSubmissionSummary score;

  @override
  Widget build(BuildContext context) {
    final winner = score.teamOneScore == score.teamTwoScore
        ? 'Tied'
        : score.teamOneScore > score.teamTwoScore
        ? 'Team 1'
        : 'Team 2';
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
            width: 64,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _ink,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${score.teamOneScore}-${score.teamTwoScore}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
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
                  winner == 'Tied' ? 'Score submitted' : '$winner led',
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
                  score.notes?.trim().isNotEmpty == true
                      ? score.notes!.trim()
                      : 'Submitted for verification',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, fontSize: 12.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _StatusPill(label: score.status),
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

class _CourtDataStrip extends StatelessWidget {
  const _CourtDataStrip();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.query_stats_rounded,
            title: 'Court data',
          ),
          const SizedBox(height: 14),
          DecoratedBox(
            decoration: BoxDecoration(
              color: _courtGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomPaint(
              painter: const _CourtLinesPainter(),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: GridView.count(
                  crossAxisCount: MediaQuery.sizeOf(context).width >= 620
                      ? 4
                      : 2,
                  childAspectRatio: MediaQuery.sizeOf(context).width >= 620
                      ? 1.35
                      : 1.16,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    _DataStatusTile(
                      icon: Icons.event_available_rounded,
                      label: 'Events',
                      detail: 'Open play',
                    ),
                    _DataStatusTile(
                      icon: Icons.sports_score_rounded,
                      label: 'Matches',
                      detail: 'Scores',
                    ),
                    _DataStatusTile(
                      icon: Icons.speed_rounded,
                      label: 'Ratings',
                      detail: 'Player form',
                    ),
                    _DataStatusTile(
                      icon: Icons.leaderboard_rounded,
                      label: 'Rankings',
                      detail: 'Court ladder',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DataStatusTile extends StatelessWidget {
  const _DataStatusTile({
    required this.icon,
    required this.label,
    required this.detail,
  });

  final IconData icon;
  final String label;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: _courtGreen, size: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CourtLinesPainter extends CustomPainter {
  const _CourtLinesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final outer = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(8),
    );
    canvas.drawRRect(outer.deflate(14), paint);
    canvas.drawLine(
      Offset(size.width / 2, 14),
      Offset(size.width / 2, size.height - 14),
      paint,
    );
    canvas.drawLine(
      Offset(14, size.height / 2),
      Offset(size.width - 14, size.height / 2),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.25, 14),
      Offset(size.width * 0.25, size.height - 14),
      paint..color = Colors.white.withValues(alpha: 0.14),
    );
    canvas.drawLine(
      Offset(size.width * 0.75, 14),
      Offset(size.width * 0.75, size.height - 14),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _freshGreen.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _courtGreen, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 12.5,
                    height: 1.25,
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

class _SideColumn extends StatelessWidget {
  const _SideColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _NextMatchCard(),
        SizedBox(height: 16),
        _ReadinessCard(),
      ],
    );
  }
}

class _NextMatchCard extends StatelessWidget {
  const _NextMatchCard();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(icon: Icons.schedule_rounded, title: 'Next up'),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _clay.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _clay.withValues(alpha: 0.22)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thursday Competitive Play',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Ready for match setup once players are assigned.',
                  style: TextStyle(color: _muted, height: 1.35),
                ),
              ],
            ),
          ),
        ],
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
