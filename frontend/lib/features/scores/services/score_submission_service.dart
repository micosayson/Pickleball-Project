import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class ScoreSubmissionSummary {
  const ScoreSubmissionSummary({
    required this.id,
    required this.status,
    required this.teamOneScore,
    required this.teamTwoScore,
    required this.submittedAt,
    this.notes,
  });

  final String id;
  final String status;
  final int teamOneScore;
  final int teamTwoScore;
  final DateTime submittedAt;
  final String? notes;

  factory ScoreSubmissionSummary.fromJson(Map<String, dynamic> json) {
    return ScoreSubmissionSummary(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      teamOneScore: (json['team_one_score'] as num?)?.toInt() ?? 0,
      teamTwoScore: (json['team_two_score'] as num?)?.toInt() ?? 0,
      submittedAt:
          DateTime.tryParse(json['submitted_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      notes: json['notes']?.toString(),
    );
  }
}

class ScoreSubmissionService {
  const ScoreSubmissionService();

  Future<List<ScoreSubmissionSummary>> listRecent({int limit = 3}) async {
    final response = await ApiClient.instance.get<List<dynamic>>(
      ApiEndpoints.scoreSubmissions,
      queryParameters: {'limit': limit},
    );
    final data = response.data ?? [];
    return data
        .whereType<Map>()
        .map(
          (item) =>
              ScoreSubmissionSummary.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
  }
}
