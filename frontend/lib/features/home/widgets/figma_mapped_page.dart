import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/styles/design_tokens.dart';

class FigmaMappedPage extends StatelessWidget {
  const FigmaMappedPage({
    super.key,
    required this.title,
    required this.eyebrow,
    required this.description,
    required this.icon,
    required this.children,
    this.trailing,
    this.selectedTabIndex,
    this.showBottomNav = false,
  });

  final String title;
  final String eyebrow;
  final String description;
  final IconData icon;
  final List<Widget> children;
  final Widget? trailing;
  final int? selectedTabIndex;
  final bool showBottomNav;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignColors.chalk,
      bottomNavigationBar: showBottomNav && selectedTabIndex != null
          ? _FigmaBottomNav(selectedIndex: selectedTabIndex!)
          : null,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            return ListView(
              padding: EdgeInsets.fromLTRB(
                isWide ? 40 : 18,
                12,
                isWide ? 40 : 18,
                showBottomNav ? 96 : 28,
              ),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isWide ? 900 : 430),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _MobileTopBar(),
                        const SizedBox(height: 18),
                        _MappedHero(
                          eyebrow: eyebrow,
                          title: title,
                          description: description,
                          icon: icon,
                        ),
                        const SizedBox(height: 16),
                        ...children,
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MobileTopBar extends StatelessWidget {
  const _MobileTopBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE8ECD4),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: DesignColors.line),
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 20,
              color: DesignColors.ink,
            ),
          ),
          const Expanded(
            child: Text(
              'RallyHub',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: DesignColors.courtGreen,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.notifications);
              },
              icon: const Icon(Icons.notifications_none_rounded),
              color: DesignColors.ink,
              tooltip: 'Notifications',
            ),
          ),
        ],
      ),
    );
  }
}

class _FigmaBottomNav extends StatelessWidget {
  const _FigmaBottomNav({required this.selectedIndex});

  final int selectedIndex;

  static const _routes = [
    AppRoutes.play,
    AppRoutes.courts,
    AppRoutes.matches,
    AppRoutes.sessions,
    AppRoutes.profileHistory,
  ];

  static const _icons = [
    Icons.sports_tennis_rounded,
    Icons.location_on_rounded,
    Icons.sports_score_rounded,
    Icons.calendar_month_rounded,
    Icons.person_rounded,
  ];

  static const _labels = ['Play', 'Courts', 'Matches', 'Sessions', 'Profile'];

  @override
  Widget build(BuildContext context) {
    return Center(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFF4),
            border: Border(top: BorderSide(color: DesignColors.line)),
          ),
          child: SafeArea(
            minimum: const EdgeInsets.fromLTRB(2, 0, 2, 0),
            child: NavigationBar(
              height: 56,
              elevation: 0,
              backgroundColor: const Color(0xFFFFFFF4),
              indicatorColor: DesignColors.freshGreen,
              labelBehavior:
                  NavigationDestinationLabelBehavior.alwaysShow,
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) {
                if (index == selectedIndex) return;
                Navigator.of(context).pushReplacementNamed(_routes[index]);
              },
              destinations: List.generate(
                5,
                (index) => NavigationDestination(
                  icon: Icon(_icons[index], size: 18),
                  selectedIcon: Icon(_icons[index], size: 18),
                  label: _labels[index],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MappedHero extends StatelessWidget {
  const _MappedHero({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String eyebrow;
  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DesignColors.courtGreen,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 8,
            bottom: 8,
            child: Container(width: 3, color: DesignColors.freshGreen),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.76),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.84),
                        fontSize: 14.5,
                        height: 1.42,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MappedPanel extends StatelessWidget {
  const MappedPanel({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DesignColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: DesignColors.courtGreen, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: DesignColors.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: const TextStyle(
                color: DesignColors.muted,
                fontSize: 13.5,
                height: 1.36,
              ),
            ),
          ],
          if (children.isNotEmpty) ...[const SizedBox(height: 14), ...children],
        ],
      ),
    );
  }
}

class MappedStatTile extends StatelessWidget {
  const MappedStatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.accent = DesignColors.courtGreen,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DesignColors.chalk,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DesignColors.line),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: DesignColors.ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: DesignColors.muted,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MappedInfoRow extends StatelessWidget {
  const MappedInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: DesignColors.courtGreen, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: DesignColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? 'Not provided' : value,
                  style: const TextStyle(
                    color: DesignColors.ink,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    height: 1.32,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MappedStateCard extends StatelessWidget {
  const MappedStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.detail,
    this.action,
    this.color = DesignColors.courtGreen,
  });

  final IconData icon;
  final String title;
  final String detail;
  final Widget? action;
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
          if (action != null) ...[const SizedBox(height: 14), action!],
        ],
      ),
    );
  }
}

class MappedStatusPill extends StatelessWidget {
  const MappedStatusPill({
    super.key,
    required this.label,
    this.color = DesignColors.freshGreen,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final foreground = color == DesignColors.freshGreen
        ? DesignColors.ink
        : color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

Widget mappedLoadingState(String label) {
  return MappedStateCard(
    icon: Icons.hourglass_top_rounded,
    title: label,
    detail: 'Loading the latest player data from the backend.',
  );
}

Widget mappedErrorState(Object? error, {String? fallback}) {
  final deferred = mappedIsDeferred(error);
  return MappedStateCard(
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
