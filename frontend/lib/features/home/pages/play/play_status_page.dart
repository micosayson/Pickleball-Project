part of '../home_placeholder_page.dart';

class _PlayStatusPage extends StatelessWidget {
  const _PlayStatusPage({
    required this.fullName,
    required this.selectedCourt,
    required this.activeSession,
    required this.isWaitingVerification,
    required this.hasMatch,
    required this.onOpenCourts,
    required this.onShowSessions,
    required this.onShowMySession,
    required this.courtsFuture,
    required this.selectCourt,
    required this.openCourtDetails,
  });

  final String fullName;
  final CourtSummary? selectedCourt;
  final EventSummary? activeSession;
  final bool isWaitingVerification;
  final bool hasMatch;
  final VoidCallback onOpenCourts;
  final VoidCallback onShowSessions;
  final VoidCallback onShowMySession;
  final Future<List<CourtSummary>> courtsFuture;
  final Future<void> Function(CourtSummary) selectCourt;
  final void Function(CourtSummary) openCourtDetails;

  @override
  Widget build(BuildContext context) {
    if (selectedCourt == null && activeSession == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PlayNoCourtCard(onChooseCourt: onOpenCourts),
          const SizedBox(height: 22),
          _PlayNearbyCourts(
            courtsFuture: courtsFuture,
            onViewMap: onOpenCourts,
            onSelectCourt: selectCourt,
            onOpenDetails: openCourtDetails,
          ),
        ],
      );
    }

    final title = activeSession == null
        ? 'Ready for the next rally, $fullName?'
        : isWaitingVerification
        ? 'Your match is waiting for verification'
        : hasMatch
        ? 'Your match is ready'
        : 'You are checked in and queued';
    final detail = activeSession == null
        ? 'Choose a court, review its sessions, then check in when you arrive.'
        : isWaitingVerification
        ? 'After the queue master verifies the result, you return to the queue.'
        : hasMatch
        ? 'Open your session to view teams and head to court.'
        : 'Stay in My session until the next match assignment is ready.';

    return Column(
      children: [
        _HeroPanel(title: title, detail: detail),
        const SizedBox(height: 16),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(
                icon: activeSession == null
                    ? Icons.route_rounded
                    : Icons.fact_check_rounded,
                title: 'Play status',
              ),
              const SizedBox(height: 14),
              _MatchFlowStepper(
                selectedCourt: selectedCourt,
                activeSession: activeSession,
                hasMatch: hasMatch,
                isWaitingVerification: isWaitingVerification,
              ),
              const SizedBox(height: 16),
              _StatusActionCard(
                icon: selectedCourt == null
                    ? Icons.location_on_rounded
                    : activeSession == null
                    ? Icons.event_available_rounded
                    : Icons.notifications_active_rounded,
                title: selectedCourt == null
                    ? 'No court selected'
                    : activeSession == null
                    ? selectedCourt!.name
                    : activeSession!.name,
                detail: selectedCourt == null
                    ? 'Pick a court to see its live sessions.'
                    : activeSession == null
                    ? 'Review available sessions for this court.'
                    : 'Open your current session and queue status.',
                actionLabel: selectedCourt == null
                    ? 'Choose court'
                    : activeSession == null
                    ? 'View sessions'
                    : isWaitingVerification
                    ? 'Refresh status'
                    : 'View my session',
                onPressed: selectedCourt == null
                    ? onOpenCourts
                    : activeSession == null
                    ? onShowSessions
                    : onShowMySession,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlayNoCourtCard extends StatelessWidget {
  const _PlayNoCourtCard({required this.onChooseCourt});

  final VoidCallback onChooseCourt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 34, 24, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _line),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFFFF1F8)],
        ),
        boxShadow: [
          BoxShadow(
            color: _ink.withValues(alpha: 0.07),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFE7E7CF),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.sports_tennis_rounded,
                  color: _courtGreen,
                  size: 31,
                ),
                Transform.rotate(
                  angle: -0.72,
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _courtGreen,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'No court selected',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _ink,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You need to select a court to start matchmaking or invite players to a game.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 42,
            child: FilledButton.icon(
              onPressed: onChooseCourt,
              icon: const Icon(Icons.search_rounded, size: 15),
              label: const Text('Choose a Court'),
              style: _primaryButtonStyle().copyWith(
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 18),
                ),
                textStyle: const WidgetStatePropertyAll(
                  TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayNearbyCourts extends StatelessWidget {
  const _PlayNearbyCourts({
    required this.courtsFuture,
    required this.onViewMap,
    required this.onSelectCourt,
    required this.onOpenDetails,
  });

  final Future<List<CourtSummary>> courtsFuture;
  final VoidCallback onViewMap;
  final Future<void> Function(CourtSummary) onSelectCourt;
  final void Function(CourtSummary) onOpenDetails;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Nearby Courts',
                style: TextStyle(
                  color: _ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            TextButton(
              onPressed: onViewMap,
              style: TextButton.styleFrom(
                foregroundColor: _courtGreen,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
              child: const Text('View Map >'),
            ),
          ],
        ),
        const SizedBox(height: 10),
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
                color: _courtGreen,
              );
            }
            final courts = snapshot.data ?? [];
            if (courts.isEmpty) {
              return const _CourtMessageState(
                icon: Icons.add_location_alt_rounded,
                title: 'No courts published yet',
                detail: 'Create an active court record to make discovery live.',
                color: _courtGreen,
              );
            }
            final visible = courts.take(5).toList(growable: false);
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  for (final court in visible) ...[
                    SizedBox(
                      width: 210,
                      child: _PlayCourtCard(
                        court: court,
                        onSelect: () => onSelectCourt(court),
                        onOpenDetails: () => onOpenDetails(court),
                      ),
                    ),
                    if (court != visible.last) const SizedBox(width: 12),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _PlayCourtCard extends StatelessWidget {
  const _PlayCourtCard({
    required this.court,
    required this.onSelect,
    required this.onOpenDetails,
  });

  final CourtSummary court;
  final VoidCallback onSelect;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpenDetails,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _line),
          boxShadow: [
            BoxShadow(
              color: _ink.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CourtImageBanner(
              height: 118,
              badge: court.status.toLowerCase() == 'active'
                  ? 'Available'
                  : _titleCase(court.status),
              compact: true,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    court.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _courtDistance(court),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.groups_rounded,
                        color: _courtGreen,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${_activePlayerCount(court)} Active Players',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: IconButton(
                          onPressed: onSelect,
                          tooltip: 'Select court',
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                          ),
                          color: _courtGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
