part of '../home_placeholder_page.dart';

class _CourtSessionsPage extends StatelessWidget {
  const _CourtSessionsPage({
    required this.court,
    required this.eventsFuture,
    required this.onBack,
    required this.onChangeCourt,
    required this.onSelectSession,
  });

  final CourtSummary court;
  final Future<List<EventSummary>> eventsFuture;
  final VoidCallback onBack;
  final VoidCallback onChangeCourt;
  final void Function(EventSummary) onSelectSession;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PageHeader(
          title: 'Court sessions',
          detail:
              '${court.name} is selected. Pick one session to review before checking in.',
          icon: Icons.event_available_rounded,
          onBack: onBack,
          trailing: TextButton.icon(
            onPressed: onChangeCourt,
            icon: const Icon(Icons.swap_horiz_rounded, size: 18),
            label: const Text('Change'),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(
                icon: Icons.format_list_bulleted_rounded,
                title: 'Available sessions',
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose one session first. The next page handles the lobby check-in.',
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
                        _SessionListTile(
                          event: event,
                          onSelect: () => onSelectSession(event),
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

class _SessionListTile extends StatelessWidget {
  const _SessionListTile({required this.event, required this.onSelect});

  final EventSummary event;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          const _CourtSurfaceIcon(icon: Icons.event_rounded),
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
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _SignalChip(
                      icon: Icons.schedule_rounded,
                      label: _formatTimeRange(event.startAt, event.endAt),
                    ),
                    _SignalChip(
                      icon: Icons.sports_tennis_rounded,
                      label: _eventTypeLabel(event.eventType),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton.filledTonal(
            onPressed: onSelect,
            tooltip: 'View session',
            icon: const Icon(Icons.arrow_forward_rounded),
          ),
        ],
      ),
    );
  }
}
