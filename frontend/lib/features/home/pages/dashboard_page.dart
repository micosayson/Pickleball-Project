import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/styles/design_tokens.dart';
import '../widgets/figma_mapped_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FigmaMappedPage(
      title: 'Dashboard',
      eyebrow: 'Player overview',
      description:
          'Track the live player loop from court discovery through queue, match assignment, and verified results.',
      icon: Icons.dashboard_customize_rounded,
      selectedTabIndex: 3,
      showBottomNav: true,
      children: const [DashboardContent()],
    );
  }
}

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ApiClient.instance.get(ApiEndpoints.dashboard),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return mappedLoadingState('Loading dashboard');
        }
        if (snapshot.hasError) {
          return mappedErrorState(snapshot.error);
        }

        final data = snapshot.data?.data as Map<String, dynamic>? ?? {};
        return Column(
          children: [
            MappedPanel(
              icon: Icons.query_stats_rounded,
              title: 'Today at a glance',
              subtitle:
                  'Counts are read from the backend. Booking and payment metrics stay deferred until that phase is built.',
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _StatBox(
                      child: MappedStatTile(
                        label: 'Courts',
                        value: _value(data['courts']),
                        icon: Icons.location_on_rounded,
                      ),
                    ),
                    _StatBox(
                      child: MappedStatTile(
                        label: 'Active sessions',
                        value: _value(data['active_sessions']),
                        icon: Icons.event_available_rounded,
                        accent: DesignColors.freshGreen,
                      ),
                    ),
                    _StatBox(
                      child: MappedStatTile(
                        label: 'Queued players',
                        value: _value(data['queued_players']),
                        icon: Icons.queue_rounded,
                        accent: DesignColors.clay,
                      ),
                    ),
                    _StatBox(
                      child: MappedStatTile(
                        label: 'Upcoming matches',
                        value: _value(data['upcoming_matches']),
                        icon: Icons.sports_score_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const MappedPanel(
              icon: Icons.route_rounded,
              title: 'Core flow coverage',
              subtitle:
                  'These are the Figma-mapped player states currently wired to live API behavior.',
              children: [
                MappedInfoRow(
                  icon: Icons.check_circle_rounded,
                  label: 'Live',
                  value:
                      'Discover courts, court details, session details, check-in, queue status, match assignment, active match, score submit, verification pending, and return to queue.',
                ),
                MappedInfoRow(
                  icon: Icons.lock_clock_rounded,
                  label: 'Deferred',
                  value:
                      'Private booking, checkout, payment confirmation, and notification delivery are visible as unavailable screens until their backend phase.',
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static String _value(dynamic value) => value?.toString() ?? '-';
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 185, child: child);
  }
}
