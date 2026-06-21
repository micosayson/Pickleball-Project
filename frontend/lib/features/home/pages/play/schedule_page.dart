part of '../home_placeholder_page.dart';

class _SchedulePage extends StatelessWidget {
  const _SchedulePage({
    required this.court,
    required this.event,
    required this.onCheckIn,
  });

  final CourtSummary court;
  final EventSummary event;
  final VoidCallback onCheckIn;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _ScreenTitle(title: 'Your Schedule', subtitle: 'Today'),
        const SizedBox(height: 4),
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final selected = index == 2;
              return Container(
                width: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? _freshGreen : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: selected ? _freshGreen : _line),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      ['Tue', 'Wed', 'Thu', 'Fri', 'Sat'][index],
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${22 + index}',
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemCount: 5,
          ),
        ),
        const SizedBox(height: 16),
        _ScheduleCard(
          icon: Icons.lock_clock_rounded,
          title: 'Private Court Rental',
          detail: '${court.name} - Confirmed',
          status: 'Confirmed',
        ),
        const SizedBox(height: 12),
        _ScheduleCard(
          icon: Icons.sports_tennis_rounded,
          title: event.name,
          detail:
              '${_formatTimeRange(event.startAt, event.endAt)} - ${court.name}',
          status: 'Joined',
          action: FilledButton.icon(
            onPressed: onCheckIn,
            icon: const Icon(Icons.login_rounded, size: 18),
            label: const Text('Check-in'),
            style: _primaryButtonStyle(),
          ),
        ),
        const SizedBox(height: 12),
        const _ScheduleCard(
          icon: Icons.groups_rounded,
          title: 'Open Play',
          detail: 'Community queue available after check-in.',
          status: 'Open',
        ),
      ],
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.icon,
    required this.title,
    required this.detail,
    required this.status,
    this.action,
  });

  final IconData icon;
  final String title;
  final String detail;
  final String status;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CourtSurfaceIcon(icon: icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detail,
                      style: const TextStyle(color: _muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              _SignalChip(icon: Icons.check_rounded, label: status),
            ],
          ),
          if (action != null) ...[
            const SizedBox(height: 14),
            SizedBox(width: double.infinity, child: action!),
          ],
        ],
      ),
    );
  }
}
