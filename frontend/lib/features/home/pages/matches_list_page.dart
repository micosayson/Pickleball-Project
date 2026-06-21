import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/styles/design_tokens.dart';
import '../widgets/figma_mapped_page.dart';

class MatchesListPage extends StatelessWidget {
  const MatchesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FigmaMappedPage(
      title: 'Matches',
      eyebrow: 'Player history',
      description:
          'Review assigned, active, and verified matches from the live queue flow.',
      icon: Icons.sports_score_rounded,
      children: const [MatchesListContent()],
    );
  }
}

class MatchesListContent extends StatelessWidget {
  const MatchesListContent({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ApiClient.instance.get(ApiEndpoints.matches),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return mappedLoadingState('Loading matches');
        }
        if (snapshot.hasError) {
          return mappedErrorState(snapshot.error);
        }

        final list = snapshot.data?.data as List<dynamic>? ?? [];
        if (list.isEmpty) {
          return const MappedStateCard(
            icon: Icons.sports_tennis_rounded,
            title: 'No matches yet',
            detail:
                'Checked-in players will see assigned and completed matches here once play begins.',
          );
        }

        return MappedPanel(
          icon: Icons.format_list_bulleted_rounded,
          title: 'Match log',
          children: [
            for (final item in list)
              _MatchRow(data: Map<String, dynamic>.from(item as Map)),
          ],
        );
      },
    );
  }
}

class _MatchRow extends StatelessWidget {
  const _MatchRow({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final number = data['match_number']?.toString() ?? '-';
    final status = data['status']?.toString() ?? 'created';
    final winner = data['winner_team_number']?.toString();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DesignColors.chalk,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DesignColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: DesignColors.courtGreen,
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
                    color: DesignColors.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  winner == null
                      ? 'Status: ${_format(status)}'
                      : 'Team $winner verified winner',
                  style: const TextStyle(
                    color: DesignColors.muted,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          MappedStatusPill(label: _format(status)),
        ],
      ),
    );
  }

  static String _format(String value) {
    return value.replaceAll('_', ' ');
  }
}
