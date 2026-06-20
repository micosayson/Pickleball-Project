import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class CourtDetailsPage extends StatelessWidget {
  final String courtId;
  const CourtDetailsPage({super.key, required this.courtId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Court details')),
      body: FutureBuilder(
        future: ApiClient.instance.get(ApiEndpoints.court(courtId)),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          final data = snapshot.data?.data as Map<String, dynamic>? ?? {};
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(data['name'] ?? 'Court'),
              const SizedBox(height: 8),
              Text(data['address'] ?? ''),
            ]),
          );
        },
      ),
    );
  }
}
