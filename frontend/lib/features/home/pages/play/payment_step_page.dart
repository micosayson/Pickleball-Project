part of '../home_placeholder_page.dart';

class _PaymentStepPage extends StatelessWidget {
  const _PaymentStepPage({
    required this.court,
    required this.event,
    required this.onBack,
    required this.onConfirmPayment,
  });

  final CourtSummary court;
  final EventSummary event;
  final VoidCallback onBack;
  final VoidCallback onConfirmPayment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FlowTopBar(title: 'RallyHub', onBack: onBack),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 34, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Complete Payment',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _ink,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Secure your spot for the upcoming match.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _muted,
                  fontSize: 17,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 42),
              const _SectionTitle(
                icon: Icons.person_outline_rounded,
                title: 'Contact Information',
              ),
              const SizedBox(height: 22),
              const _PaymentInputField(
                label: 'Full Name',
                value: 'Alex Rivera',
              ),
              const SizedBox(height: 16),
              const _PaymentInputField(
                label: 'Email Address',
                value: 'alex.rivera@example.com',
              ),
              const SizedBox(height: 16),
              const _PaymentInputField(
                label: 'Mobile Number',
                value: '+63 917 123 4567',
              ),
              const SizedBox(height: 44),
              const _SectionTitle(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Payment Method',
              ),
              const SizedBox(height: 22),
              const _PaymentMethodPill(
                label: 'GCash',
                detail: 'Pay via GCash app',
                mark: 'G',
                selected: true,
                color: Color(0xFF2F6BE6),
              ),
              const SizedBox(height: 16),
              const _PaymentMethodPill(
                label: 'Maya',
                detail: 'Pay via Maya wallet',
                mark: 'M',
                color: _ink,
              ),
              const SizedBox(height: 24),
              _Panel(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PaymentSummaryRow(label: event.name, value: 'PHP 500.00'),
                    const _PaymentSummaryRow(
                      label: 'Processing Fee',
                      value: 'PHP 15.00',
                    ),
                    const Divider(height: 26, color: _line),
                    const _PaymentSummaryRow(
                      label: 'Total',
                      value: 'PHP 515.00',
                      strong: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              FilledButton(
                onPressed: onConfirmPayment,
                style: _primaryButtonStyle(),
                child: const Text('Confirm Payment'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentInputField extends StatelessWidget {
  const _PaymentInputField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _line),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: _ink,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Positioned(
          left: 12,
          top: -8,
          child: Container(
            color: _chalk,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              label,
              style: const TextStyle(
                color: _muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodPill extends StatelessWidget {
  const _PaymentMethodPill({
    required this.label,
    required this.detail,
    required this.mark,
    required this.color,
    this.selected = false,
  });

  final String label;
  final String detail;
  final String mark;
  final Color color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: selected ? _freshGreen.withValues(alpha: 0.10) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: selected ? _courtGreen : _line,
          width: selected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color,
            child: Text(
              mark,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: const TextStyle(color: _muted, fontSize: 12.5),
                ),
              ],
            ),
          ),
          Icon(
            selected
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_off_rounded,
            color: _courtGreen,
            size: 24,
          ),
        ],
      ),
    );
  }
}

class _PaymentSummaryRow extends StatelessWidget {
  const _PaymentSummaryRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: strong ? _ink : _muted,
                fontSize: strong ? 16 : 14,
                fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: _ink,
              fontSize: strong ? 22 : 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
