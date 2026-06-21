import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/styles/design_tokens.dart';
import '../widgets/figma_mapped_page.dart';

class PaymentFlowPage extends StatelessWidget {
  const PaymentFlowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FigmaMappedPage(
      title: 'Payment flow',
      eyebrow: 'Checkout unavailable',
      description:
          'Payment UI is mapped from Figma, but transaction creation and verification are deferred.',
      icon: Icons.payments_rounded,
      children: [
        FutureBuilder(
          future: ApiClient.instance.get(ApiEndpoints.payments),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return mappedLoadingState('Checking payment phase');
            }
            if (snapshot.hasError) {
              return Column(
                children: [
                  mappedErrorState(snapshot.error),
                  const SizedBox(height: 12),
                  const _PaymentPreview(),
                ],
              );
            }

            final list = snapshot.data?.data as List<dynamic>? ?? [];
            if (list.isEmpty) {
              return const _PaymentPreview();
            }

            return MappedPanel(
              icon: Icons.receipt_long_rounded,
              title: 'Payments',
              children: [
                for (final item in list)
                  _PaymentRow(data: Map<String, dynamic>.from(item as Map)),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PaymentPreview extends StatelessWidget {
  const _PaymentPreview();

  @override
  Widget build(BuildContext context) {
    return const MappedPanel(
      icon: Icons.lock_clock_rounded,
      title: 'Checkout phase',
      subtitle:
          'This screen remains read-only until payment provider integration, order persistence, and staff verification are implemented.',
      children: [
        MappedInfoRow(
          icon: Icons.price_check_rounded,
          label: 'Amount',
          value: 'Calculated after booking rules and court pricing are live.',
        ),
        MappedInfoRow(
          icon: Icons.credit_card_rounded,
          label: 'Payment method',
          value: 'Provider integration is deferred.',
        ),
        MappedInfoRow(
          icon: Icons.verified_rounded,
          label: 'Verification',
          value:
              'Confirmed payments will unlock private-court reservations in a later phase.',
        ),
      ],
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.data});

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
          const Icon(Icons.receipt_long_rounded, color: DesignColors.clay),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${data['currency'] ?? 'usd'} ${data['amount'] ?? '-'}',
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
