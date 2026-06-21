part of '../home_placeholder_page.dart';

class _UpcomingMatchPage extends StatelessWidget {
  const _UpcomingMatchPage({
    required this.court,
    required this.match,
    required this.onBack,
    required this.onGoToCourt,
    required this.onLeaveCourt,
  });

  final CourtSummary court;
  final PlayMatchSummary match;
  final VoidCallback onBack;
  final Future<void> Function() onGoToCourt;
  final Future<void> Function() onLeaveCourt;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FlowTopBar(
          title: 'RallyHub',
          onBack: onBack,
          trailingIcon: Icons.notifications_rounded,
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 34, 24, 0),
          child: Column(
            children: [
              Text(
                'Up Next',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _ink,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              SizedBox(height: 12),
              Text(
                "Men's Doubles Semi-Final",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _muted,
                  fontSize: 18,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 44),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _UpcomingMatchCard(
            court: court,
            match: match,
            onGoToCourt: onGoToCourt,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onLeaveCourt,
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Leave session'),
              style: _dangerOutlineButtonStyle(),
            ),
          ),
        ),
      ],
    );
  }
}
