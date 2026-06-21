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
      children: [
        _PageHeader(
          title: 'Complete Payment',
          detail: 'RallyHub checkout',
          icon: Icons.payments_rounded,
          onBack: onBack,
        ),
        const SizedBox(height: 16),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(icon: Icons.person_rounded, title: 'Contact'),
              const SizedBox(height: 12),
              const _PaymentField(
                icon: Icons.badge_rounded,
                value: 'Alex Rivera',
              ),
              const SizedBox(height: 10),
              const _PaymentField(
                icon: Icons.email_rounded,
                value: 'alex.rivera@example.com',
              ),
              const SizedBox(height: 10),
              const _PaymentField(
                icon: Icons.phone_rounded,
                value: '+63 917 123 4567',
              ),
              const Divider(height: 30, color: _line),
              const Text(
                'Payment Method',
                style: TextStyle(
                  color: _ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(
                    child: _PaymentMethod(label: 'GCash', selected: true),
                  ),
                  SizedBox(width: 8),
                  Expanded(child: _PaymentMethod(label: 'Maya')),
                ],
              ),
              const SizedBox(height: 8),
              const _PaymentMethod(label: 'Credit/Debit Card'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(
                icon: Icons.receipt_long_rounded,
                title: 'Summary',
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onConfirmPayment,
                  icon: const Icon(Icons.check_circle_rounded, size: 18),
                  label: const Text('Confirm Payment'),
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

class _PaymentField extends StatelessWidget {
  const _PaymentField({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _chalk,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          Icon(icon, color: _courtGreen, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: _ink,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethod extends StatelessWidget {
  const _PaymentMethod({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(
        color: selected ? _freshGreen : _chalk,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: selected ? _freshGreen : _line),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: _courtGreen,
            size: 17,
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _ink,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
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
