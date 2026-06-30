import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/styles/design_tokens.dart';
import '../widgets/figma_mapped_page.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FigmaMappedPage(
      title: 'Notifications',
      eyebrow: 'With Nav frame',
      description:
          'A player inbox for match-ready alerts, score verification updates, and court announcements.',
      icon: Icons.notifications_active_rounded,
      selectedTabIndex: 4,
      children: const [NotificationsContent()],
    );
  }
}

class NotificationsContent extends StatelessWidget {
  const NotificationsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ApiClient.instance.get(ApiEndpoints.notifications),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return mappedLoadingState('Checking notifications');
        }
        if (snapshot.hasError) {
          return mappedErrorState(snapshot.error);
        }

        final list = snapshot.data?.data as List<dynamic>? ?? [];
        if (list.isEmpty) {
          return const MappedStateCard(
            icon: Icons.notifications_none_rounded,
            title: 'No notifications yet',
            detail:
                'Match assignment and verification alerts will appear here once notification delivery is enabled.',
          );
        }

        return MappedPanel(
          icon: Icons.inbox_rounded,
          title: 'Inbox',
          children: [
            for (final item in list)
              _NotificationRow(data: Map<String, dynamic>.from(item as Map)),
          ],
        );
      },
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final read = data['read'] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: read ? Colors.white : DesignColors.chalk,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DesignColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            read ? Icons.mark_email_read_rounded : Icons.markunread_rounded,
            color: read ? DesignColors.muted : DesignColors.courtGreen,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title']?.toString() ?? 'Notification',
                  style: const TextStyle(
                    color: DesignColors.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data['body']?.toString() ?? '',
                  style: const TextStyle(
                    color: DesignColors.muted,
                    fontSize: 13.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          MappedStatusPill(
            label: read ? 'Read' : 'New',
            color: read ? DesignColors.muted : DesignColors.freshGreen,
          ),
        ],
      ),
    );
  }
}
