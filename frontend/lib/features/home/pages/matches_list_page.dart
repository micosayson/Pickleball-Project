import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class MatchesListPage extends StatelessWidget {
  const MatchesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Matches')),
      body: FutureBuilder(
        future: ApiClient.instance.get(ApiEndpoints.matches),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          final list = snapshot.data?.data as List<dynamic>? ?? [];
          if (list.isEmpty) return const Center(child: Text('No matches'));
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final m = list[i] as Map<String, dynamic>;
              return ListTile(
                title: Text(m['id'] ?? 'Match'),
                subtitle: Text(m['summary'] ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}
