import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: FutureBuilder(
        future: ApiClient.instance.get(ApiEndpoints.dashboard),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final data = snapshot.data?.data ?? {};
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Courts: ${data['courts'] ?? '-'}'),
                Text('Active sessions: ${data['active_sessions'] ?? '-'}'),
                Text('Queued players: ${data['queued_players'] ?? '-'}'),
                Text('Upcoming matches: ${data['upcoming_matches'] ?? '-'}'),
                Text('Bookings: ${data['bookings'] ?? '-'}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
