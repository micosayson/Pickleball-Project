import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/styles/design_tokens.dart';
import '../widgets/figma_mapped_page.dart';

class ProfileHistoryPage extends StatelessWidget {
  const ProfileHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FigmaMappedPage(
      title: 'Profile & History',
      eyebrow: 'Identity, account context',
      description:
          'Review player history, ratings, receipts, payment methods, and account settings.',
      icon: Icons.person_pin_circle_rounded,
      selectedTabIndex: 4,
      showBottomNav: true,
      children: const [ProfileHistoryContent()],
    );
  }
}

class ProfileHistoryContent extends StatelessWidget {
  const ProfileHistoryContent({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ApiClient.instance.get(ApiEndpoints.usersMe),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return mappedLoadingState('Loading profile');
        }
        if (snapshot.hasError) {
          return mappedErrorState(snapshot.error);
        }

        final data = snapshot.data?.data as Map<String, dynamic>? ?? {};
        final fullName = data['full_name']?.toString().trim().isNotEmpty == true
            ? data['full_name'].toString()
            : 'Player profile';
        final email = data['email']?.toString() ?? '';
        final role = data['platform_role']?.toString() ?? 'player';
        final status = data['status']?.toString() ?? 'active';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProfileHero(
              fullName: fullName,
              email: email,
              role: role,
              status: status,
            ),
            const SizedBox(height: 24),
            _SectionLabel('Performance stats'),
            const SizedBox(height: 12),
            const _StatsGrid(),
            const SizedBox(height: 24),
            _SectionRowTitle(
              title: 'Quick access history',
              actionLabel: 'See all',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            const _QuickHistoryCard(),
            const SizedBox(height: 24),
            _PaymentSettingsCard(),
            const SizedBox(height: 24),
            _SectionLabel('Sessions & receipts'),
            const SizedBox(height: 12),
            const _SessionsCard(),
            const SizedBox(height: 24),
            _SectionLabel('Account & settings'),
            const SizedBox(height: 12),
            const _AccountActionsCard(),
            const SizedBox(height: 12),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: () {},
                child: const Text('Sign out'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.fullName,
    required this.email,
    required this.role,
    required this.status,
  });

  final String fullName;
  final String email;
  final String role;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F3DF),
                shape: BoxShape.circle,
                border: Border.all(color: DesignColors.line),
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 60,
                color: DesignColors.ink,
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: DesignColors.courtGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.16),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  size: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          fullName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: DesignColors.ink,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          email.isEmpty ? 'Verified player profile' : email,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: DesignColors.muted,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: DesignColors.line),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              _HeroInfoRow(label: 'Member type', value: role),
              const SizedBox(height: 10),
              _HeroInfoRow(label: 'Account status', value: status),
              const SizedBox(height: 10),
              _HeroActionRow(
                label: 'Profile history',
                value: 'Open verified player record',
                trailing: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: DesignColors.courtGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroInfoRow extends StatelessWidget {
  const _HeroInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: DesignColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: DesignColors.ink,
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _HeroActionRow extends StatelessWidget {
  const _HeroActionRow({
    required this.label,
    required this.value,
    required this.trailing,
  });

  final String label;
  final String value;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: DesignColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: DesignColors.courtGreen,
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 8),
        trailing,
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: DesignColors.muted,
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.9,
      ),
    );
  }
}

class _SectionRowTitle extends StatelessWidget {
  const _SectionRowTitle({
    required this.title,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: DesignColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                actionLabel,
                style: const TextStyle(
                  color: DesignColors.courtGreen,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: DesignColors.courtGreen,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.28,
      children: const [
        _StatCard(
          icon: Icons.sports_score_rounded,
          label: 'Matches played',
          value: '142',
        ),
        _StatCard(icon: Icons.percent_rounded, label: 'Win rate', value: '68%'),
        _StatCard(
          icon: Icons.timeline_rounded,
          label: 'Rating trend',
          value: 'Steady',
          body:
              'Your verified activity is trending upward over recent sessions.',
        ),
        _StatCard(
          icon: Icons.emoji_events_rounded,
          label: 'Rank level',
          value: 'Live',
          body:
              'Ranking will update as verification and scoring continue to stabilize.',
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.body,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DesignColors.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: DesignColors.courtGreen, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: DesignColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: DesignColors.ink,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          if (body != null) ...[
            const SizedBox(height: 8),
            Text(
              body!,
              style: const TextStyle(
                color: DesignColors.muted,
                fontSize: 12.5,
                height: 1.36,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickHistoryCard extends StatelessWidget {
  const _QuickHistoryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DesignColors.line),
      ),
      child: Column(
        children: const [
          _HistoryRow(
            icon: Icons.calendar_month_rounded,
            title: 'Sunset Park Court',
            subtitle: 'Open play - verified result',
            value: '32 pts',
          ),
          SizedBox(height: 12),
          _HistoryRow(
            icon: Icons.lock_clock_rounded,
            title: 'Private rental',
            subtitle: 'Checked in on time',
            value: 'Paid',
          ),
          SizedBox(height: 12),
          _HistoryRow(
            icon: Icons.arrow_forward_rounded,
            title: 'View complete history',
            subtitle: 'Open all sessions and receipts',
            value: '',
            trailingOnly: true,
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    this.trailingOnly = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final bool trailingOnly;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF4F6E6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: DesignColors.courtGreen, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: DesignColors.ink,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: DesignColors.muted,
                  fontSize: 12.5,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        if (!trailingOnly)
          Text(
            value,
            style: const TextStyle(
              color: DesignColors.courtGreen,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          )
        else
          const Icon(
            Icons.arrow_forward_rounded,
            size: 16,
            color: DesignColors.courtGreen,
          ),
      ],
    );
  }
}

class _PaymentSettingsCard extends StatelessWidget {
  const _PaymentSettingsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DesignColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.credit_card_rounded, color: DesignColors.courtGreen, size: 18),
              SizedBox(width: 10),
              Text(
                'Payments & billing',
                style: TextStyle(
                  color: DesignColors.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'This app will route into Stripe or bank payment providers rather than a wallet top-up flow.',
            style: TextStyle(
              color: DesignColors.muted,
              fontSize: 13.5,
              height: 1.36,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: const Text('Open payment setup'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionsCard extends StatelessWidget {
  const _SessionsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DesignColors.line),
      ),
      child: Column(
        children: const [
          _SessionRow(
            icon: Icons.sports_tennis_rounded,
            title: 'Sunset Park Court - Open play',
            subtitle: 'Today, 2:00 PM',
            trailing: 'Queued',
          ),
          SizedBox(height: 12),
          _SessionRow(
            icon: Icons.receipt_long_rounded,
            title: 'Receipt #2024-138',
            subtitle: 'Private rental - completed',
            trailing: 'Paid',
          ),
          SizedBox(height: 12),
          _SessionRow(
            icon: Icons.description_rounded,
            title: 'Past sessions',
            subtitle: 'Open the full history view',
            trailing: 'View',
          ),
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF4F6E6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: DesignColors.courtGreen, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: DesignColors.ink,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: DesignColors.muted,
                  fontSize: 12.5,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        Text(
          trailing,
          style: const TextStyle(
            color: DesignColors.courtGreen,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _AccountActionsCard extends StatelessWidget {
  const _AccountActionsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DesignColors.line),
      ),
      child: Column(
        children: const [
          _AccountActionRow(
            icon: Icons.person_outline_rounded,
            title: 'Edit profile',
          ),
          Divider(height: 1, color: DesignColors.line),
          _AccountActionRow(
            icon: Icons.payment_rounded,
            title: 'Payment methods',
          ),
          Divider(height: 1, color: DesignColors.line),
          _AccountActionRow(
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
          ),
          Divider(height: 1, color: DesignColors.line),
          _AccountActionRow(
            icon: Icons.shield_outlined,
            title: 'Privacy settings',
          ),
        ],
      ),
    );
  }
}

class _AccountActionRow extends StatelessWidget {
  const _AccountActionRow({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 57,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: DesignColors.courtGreen, size: 16),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: DesignColors.ink,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: DesignColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}

Widget mappedLoadingState(String label) {
  return _StateCard(
    icon: Icons.hourglass_top_rounded,
    title: label,
    detail: 'Loading the latest player data from the backend.',
  );
}

Widget mappedErrorState(Object? error, {String? fallback}) {
  final deferred = mappedIsDeferred(error);
  return _StateCard(
    icon: deferred ? Icons.lock_clock_rounded : Icons.cloud_off_rounded,
    title: deferred ? 'Not available yet' : 'Could not load this screen',
    detail: deferred
        ? mappedErrorMessage(error)
        : fallback ?? mappedErrorMessage(error),
    color: deferred ? DesignColors.clay : DesignColors.courtGreen,
  );
}

String mappedErrorMessage(Object? error) {
  if (error is ApiException) {
    if (error.statusCode == 501) {
      return error.message.isEmpty
          ? 'This flow is planned for a later backend phase.'
          : error.message;
    }
    if (error.statusCode == 401 || error.statusCode == 422) {
      return 'Sign in to view this player screen.';
    }
    return error.userMessage;
  }
  return 'Check the backend connection and try again.';
}

bool mappedIsDeferred(Object? error) {
  return error is ApiException && error.statusCode == 501;
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.icon,
    required this.title,
    required this.detail,
    this.color = DesignColors.courtGreen,
  });

  final IconData icon;
  final String title;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DesignColors.line),
      ),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: DesignColors.ink,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            detail,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: DesignColors.muted,
              fontSize: 13.5,
              height: 1.38,
            ),
          ),
        ],
      ),
    );
  }
}
