part of '../home_placeholder_page.dart';

class _WaitingVerificationPage extends StatelessWidget {
  const _WaitingVerificationPage({
    required this.court,
    required this.onReturnToQueue,
  });

  final CourtSummary court;
  final VoidCallback onReturnToQueue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PageHeader(
          title: 'Waiting for verification',
          detail:
              'Match #102 is marked finished. The queue master verifies the result before returning the player to the queue.',
          icon: Icons.hourglass_top_rounded,
        ),
        const SizedBox(height: 16),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(
                icon: Icons.verified_rounded,
                title: 'Queue master review',
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F6FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFD8E5FF)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.pending_actions_rounded,
                      color: _courtGreen,
                      size: 34,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Result is under review',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'After verification at ${court.name}, the queue list adjusts and the player is available for the next match.',
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
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onReturnToQueue,
                  icon: const Icon(Icons.replay_rounded, size: 18),
                  label: const Text('Return to queue'),
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
