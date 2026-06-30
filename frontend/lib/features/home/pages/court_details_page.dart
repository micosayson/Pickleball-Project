import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../courts/services/court_service.dart';
import '../widgets/figma_mapped_page.dart';
import 'bookings_page.dart';

class CourtDetailsPage extends StatelessWidget {
  const CourtDetailsPage({
    super.key,
    required this.courtId,
    this.onShowSessions,
  });

  final String courtId;
  final void Function(CourtSummary court)? onShowSessions;

  @override
  Widget build(BuildContext context) {
    return FigmaMappedPage(
      title: 'Court details',
      eyebrow: 'Court profile',
      description:
          'Inspect the selected court before joining a live session or checking booking availability.',
      icon: Icons.stadium_rounded,
      selectedTabIndex: 1,
      showBottomNav: true,
      children: [
        FutureBuilder(
          future: ApiClient.instance.get(ApiEndpoints.court(courtId)),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return mappedLoadingState('Loading court');
            }
            if (snapshot.hasError) {
              return mappedErrorState(snapshot.error);
            }

            final data = snapshot.data?.data as Map<String, dynamic>? ?? {};
            final court = CourtSummary.fromJson(data);
            return Column(
              children: [
                MappedPanel(
                  icon: Icons.sports_tennis_rounded,
                  title: court.name,
                  subtitle:
                      'This is the Court Details View Page in the Figma flow. Continue to sessions for live open play.',
                  children: [
                    MappedInfoRow(
                      icon: Icons.location_on_rounded,
                      label: 'Address',
                      value: court.address ?? '',
                    ),
                    MappedInfoRow(
                      icon: Icons.public_rounded,
                      label: 'Status',
                      value: court.status,
                    ),
                    MappedInfoRow(
                      icon: Icons.contact_phone_rounded,
                      label: 'Contact',
                      value: court.contactInfo ?? '',
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton.icon(
                        onPressed: onShowSessions == null
                            ? null
                            : () {
                                Navigator.of(context).pop();
                                onShowSessions!(court);
                              },
                        icon: const Icon(Icons.event_available_rounded),
                        label: const Text('View sessions'),
                      ),
                    ),
                  ],
                ),
                MappedPanel(
                  icon: Icons.calendar_month_rounded,
                  title: 'Private court booking',
                  subtitle:
                      'The Figma booking flow is represented, but checkout and reservation persistence are not enabled yet.',
                  children: [
                    const MappedInfoRow(
                      icon: Icons.lock_clock_rounded,
                      label: 'Availability',
                      value:
                          'Booking and payment are planned for the next backend phase.',
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const BookingsPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.event_busy_rounded),
                        label: const Text('View booking status'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
