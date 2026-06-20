import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookings')),
      body: FutureBuilder(
        future: ApiClient.instance.get(ApiEndpoints.bookings),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          final list = snapshot.data?.data as List<dynamic>? ?? [];
          if (list.isEmpty) return const Center(child: Text('No bookings yet'));
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final b = list[i] as Map<String, dynamic>;
              return ListTile(
                title: Text(b['court_id'] ?? 'Court'),
                subtitle: Text('${b['start_at']} → ${b['end_at']}'),
                trailing: Text(b['status'] ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}
