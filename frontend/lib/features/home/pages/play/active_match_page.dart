part of '../home_placeholder_page.dart';

class _ActiveMatchPage extends StatelessWidget {
  const _ActiveMatchPage({
    required this.court,
    required this.prototypeMatch,
    required this.onShowMatchResult,
    required this.onLeaveCourt,
  });

  final CourtSummary court;
  final _PrototypeMatch prototypeMatch;
  final VoidCallback onShowMatchResult;
  final VoidCallback onLeaveCourt;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PageHeader(
          title: 'Active match',
          detail:
              'The player has reached the court. Keep this page quiet while the match is in progress.',
          icon: Icons.sports_tennis_rounded,
        ),
        const SizedBox(height: 16),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(
                icon: Icons.play_circle_fill_rounded,
                title: 'Match in progress',
              ),
              const SizedBox(height: 14),
              _StatusActionCard(
                icon: Icons.location_on_rounded,
                title: 'Match ${prototypeMatch.matchNumber}',
                detail: '${court.name} - ${prototypeMatch.homeTeam.name} vs ${prototypeMatch.awayTeam.name}',
                actionLabel: 'View result',
                onPressed: onShowMatchResult,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onLeaveCourt,
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text('Leave court'),
                  style: _dangerOutlineButtonStyle(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
