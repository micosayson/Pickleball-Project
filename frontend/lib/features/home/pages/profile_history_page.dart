import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class ProfileHistoryPage extends StatelessWidget {
  const ProfileHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & History')),
      body: FutureBuilder(
        future: ApiClient.instance.get(ApiEndpoints.usersMe),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          final data = snapshot.data?.data as Map<String, dynamic>? ?? {};
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Name: ${data['full_name'] ?? data['email'] ?? ''}'),
              const SizedBox(height: 8),
              Text('Email: ${data['email'] ?? ''}'),
            ]),
          );
        },
      ),
    );
  }
}
