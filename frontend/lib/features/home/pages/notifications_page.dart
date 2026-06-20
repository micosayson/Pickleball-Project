import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: FutureBuilder(
        future: ApiClient.instance.get(ApiEndpoints.notifications),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          final list = snapshot.data?.data as List<dynamic>? ?? [];
          if (list.isEmpty) return const Center(child: Text('No notifications'));
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final n = list[i] as Map<String, dynamic>;
              return ListTile(
                title: Text(n['title'] ?? ''),
                subtitle: Text(n['body'] ?? ''),
                trailing: n['read'] == true ? const Icon(Icons.done) : null,
              );
            },
          );
        },
      ),
    );
  }
}
