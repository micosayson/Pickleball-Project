import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/styles/design_tokens.dart';
import '../widgets/figma_mapped_page.dart';
import 'payment_flow_page.dart';

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FigmaMappedPage(
      title: 'Book private court',
      eyebrow: 'Deferred booking flow',
      description:
          'The Figma booking and timeslot screens are represented here without creating in-memory reservations.',
      icon: Icons.calendar_month_rounded,
      selectedTabIndex: 1,
      children: [
        FutureBuilder(
          future: ApiClient.instance.get(ApiEndpoints.bookings),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return mappedLoadingState('Checking booking phase');
            }
            if (snapshot.hasError) {
              return Column(
                children: [
                  mappedErrorState(snapshot.error),
                  const SizedBox(height: 12),
                  _BookingSteps(
                    onOpenPayment: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PaymentFlowPage(),
                        ),
                      );
                    },
                  ),
                ],
              );
            }

            final list = snapshot.data?.data as List<dynamic>? ?? [];
            if (list.isEmpty) {
              return _BookingSteps(
                onOpenPayment: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PaymentFlowPage()),
                  );
                },
              );
            }

            return MappedPanel(
              icon: Icons.event_available_rounded,
              title: 'Reservations',
              children: [
                for (final item in list)
                  _BookingRow(data: Map<String, dynamic>.from(item as Map)),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _BookingSteps extends StatelessWidget {
  const _BookingSteps({required this.onOpenPayment});

  final VoidCallback onOpenPayment;

  @override
  Widget build(BuildContext context) {
    return MappedPanel(
      icon: Icons.view_timeline_rounded,
      title: 'Flow preview',
      subtitle:
          'These Figma frames are present as unavailable states until reservation rules, pricing, and checkout are implemented.',
      children: [
        const MappedInfoRow(
          icon: Icons.sports_tennis_rounded,
          label: '1. Select court',
          value: 'Players start from court details and choose private court.',
        ),
        const MappedInfoRow(
          icon: Icons.grid_view_rounded,
          label: '2. Select timeslot',
          value:
              'Timeslot inventory is deferred until the booking backend phase.',
        ),
        const MappedInfoRow(
          icon: Icons.payments_rounded,
          label: '3. Payment',
          value:
              'Checkout is blocked until payment persistence and verification are live.',
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: onOpenPayment,
            icon: const Icon(Icons.lock_clock_rounded),
            label: const Text('Open payment status'),
          ),
        ),
      ],
    );
  }
}

class _BookingRow extends StatelessWidget {
  const _BookingRow({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
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
          const Icon(Icons.event_available_rounded, color: DesignColors.clay),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${data['start_at'] ?? 'Start'} to ${data['end_at'] ?? 'End'}',
              style: const TextStyle(
                color: DesignColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          MappedStatusPill(label: data['status']?.toString() ?? 'pending'),
        ],
      ),
    );
  }
}
