import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/styles/design_tokens.dart';
import '../widgets/figma_mapped_page.dart';

class ProfileHistoryPage extends StatelessWidget {
  const ProfileHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FigmaMappedPage(
      title: 'Profile & History',
      eyebrow: 'Player record',
      description:
          'Keep identity, membership context, and verified match history in one player-first view.',
      icon: Icons.person_pin_circle_rounded,
      children: const [ProfileHistoryContent()],
    );
  }
}

class ProfileHistoryContent extends StatelessWidget {
  const ProfileHistoryContent({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ApiClient.instance.get(ApiEndpoints.usersMe),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return mappedLoadingState('Loading profile');
        }
        if (snapshot.hasError) {
          return mappedErrorState(snapshot.error);
        }

        final data = snapshot.data?.data as Map<String, dynamic>? ?? {};
        final name = data['full_name']?.toString().trim().isNotEmpty == true
            ? data['full_name'].toString()
            : data['email']?.toString() ?? 'Player';
        final email = data['email']?.toString() ?? '';
        return Column(
          children: [
            MappedPanel(
              icon: Icons.badge_rounded,
              title: name,
              subtitle: email.isEmpty ? 'Signed-in player' : email,
              children: [
                MappedInfoRow(
                  icon: Icons.verified_user_rounded,
                  label: 'Account status',
                  value: data['status']?.toString() ?? 'active',
                ),
                MappedInfoRow(
                  icon: Icons.admin_panel_settings_rounded,
                  label: 'Role',
                  value: data['platform_role']?.toString() ?? 'player',
                ),
              ],
            ),
            const MappedPanel(
              icon: Icons.timeline_rounded,
              title: 'Match history',
              subtitle:
                  'Verified results will populate this timeline after score verification is stable.',
              children: [
                MappedInfoRow(
                  icon: Icons.lock_clock_rounded,
                  label: 'Deferred calculation',
                  value:
                      'Rating and ranking recalculation is intentionally held until verified match results are reliable.',
                ),
              ],
            ),
            const MappedPanel(
              icon: Icons.speed_rounded,
              title: 'Player rating',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: MappedStatTile(
                        label: 'Current rating',
                        value: 'Pending',
                        icon: Icons.trending_up_rounded,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: MappedStatTile(
                        label: 'Verified matches',
                        value: 'Live soon',
                        icon: Icons.fact_check_rounded,
                        accent: DesignColors.clay,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
