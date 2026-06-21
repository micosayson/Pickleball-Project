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
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR SCHEDULE',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Today, Oct 24',
                      style: TextStyle(
                        color: _ink,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: _softOlive,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: _ink,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const _DateStrip(),
          const SizedBox(height: 48),
          _ScheduleTimeline(court: court, event: event, onCheckIn: onCheckIn),
        ],
      ),
    );
  }
}

class _DateStrip extends StatelessWidget {
  const _DateStrip();

  @override
  Widget build(BuildContext context) {
    const days = [
      ('TUE', '22'),
      ('WED', '23'),
      ('THU', '24'),
      ('FRI', '25'),
      ('SAT', '26'),
    ];
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (context, index) => const SizedBox(width: 18),
        itemBuilder: (context, index) {
          final selected = index == 2;
          return Container(
            width: 58,
            decoration: BoxDecoration(
              color: selected ? _freshGreen : _softOlive,
              shape: BoxShape.circle,
              border: selected
                  ? Border.all(color: _courtGreen, width: 2)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  days[index].$1,
                  style: TextStyle(
                    color: selected ? _courtGreen : _muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  days[index].$2,
                  style: TextStyle(
                    color: selected ? _ink : _muted,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ScheduleTimeline extends StatelessWidget {
  const _ScheduleTimeline({
    required this.court,
    required this.event,
    required this.onCheckIn,
  });

  final CourtSummary court;
  final EventSummary event;
  final VoidCallback onCheckIn;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: const [
            _TimelineDot(active: false),
            _TimelineLine(height: 150),
            _TimelineDot(active: true),
            _TimelineLine(height: 190),
          ],
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            children: [
              const _ScheduleEventCard(
                time: '10:00 AM - 11:30 AM',
                title: 'Private Court\nRental',
                location: 'Court 4 - Downtown Rally Park',
                status: 'Confirmed',
              ),
              const SizedBox(height: 40),
              _ScheduleEventCard(
                time: _formatTimeRange(event.startAt, event.endAt),
                title: event.name,
                location: '${court.name} - ${court.address ?? 'Athletic Club'}',
                status: 'Joined',
                highlighted: true,
                action: FilledButton(
                  onPressed: onCheckIn,
                  style: _primaryButtonStyle(),
                  child: const Text('Check-in'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineDot extends StatelessWidget {
  const _TimelineDot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: active ? _freshGreen : _muted,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _TimelineLine extends StatelessWidget {
  const _TimelineLine({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(width: 2, height: height, color: _softOlive);
  }
}

class _ScheduleEventCard extends StatelessWidget {
  const _ScheduleEventCard({
    required this.time,
    required this.title,
    required this.location,
    required this.status,
    this.highlighted = false,
    this.action,
  });

  final String time;
  final String title;
  final String location;
  final String status;
  final bool highlighted;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.all(18),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  time,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _ScheduleStatusChip(label: status, joined: highlighted),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: highlighted ? _ink : _muted,
              fontSize: highlighted ? 26 : 21,
              height: 1.14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: _muted, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  location,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 16,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
          if (action != null) ...[
            const SizedBox(height: 18),
            SizedBox(width: double.infinity, child: action!),
          ],
        ],
      ),
    );
  }
}

class _ScheduleStatusChip extends StatelessWidget {
  const _ScheduleStatusChip({required this.label, required this.joined});

  final String label;
  final bool joined;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: joined ? _freshGreen : _softOlive,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            color: joined ? _courtGreen : const Color(0xFF67C8AE),
            size: 8,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: _muted,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
