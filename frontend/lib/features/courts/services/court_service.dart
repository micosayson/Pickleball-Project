import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class CourtSummary {
  const CourtSummary({
    required this.id,
    required this.name,
    required this.slug,
    required this.status,
    this.address,
    this.contactInfo,
  });

  final String id;
  final String name;
  final String slug;
  final String status;
  final String? address;
  final String? contactInfo;

  factory CourtSummary.fromJson(Map<String, dynamic> json) {
    return CourtSummary(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Court',
      slug: json['slug']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      address: json['address']?.toString(),
      contactInfo: json['contact_info']?.toString(),
    );
  }
}

class CourtService {
  const CourtService();

  Future<List<CourtSummary>> listCourts({int limit = 6}) async {
    final response = await ApiClient.instance.get<List<dynamic>>(
      ApiEndpoints.courts,
      queryParameters: {'limit': limit, 'status': 'active'},
    );
    final data = response.data ?? [];
    return data
        .whereType<Map>()
        .map((item) => CourtSummary.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }
}

class CourtMembershipSummary {
  const CourtMembershipSummary({
    required this.id,
    required this.courtId,
    required this.status,
  });

  final String id;
  final String courtId;
  final String status;

  factory CourtMembershipSummary.fromJson(Map<String, dynamic> json) {
    return CourtMembershipSummary(
      id: json['id']?.toString() ?? '',
      courtId: json['court_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
    );
  }
}

class CourtMembershipService {
  const CourtMembershipService();

  Future<CourtMembershipSummary> joinCourt(String courtId) async {
    final response = await ApiClient.instance.post<Map<String, dynamic>>(
      ApiEndpoints.courtMembership(courtId),
    );
    return CourtMembershipSummary.fromJson(response.data ?? {});
  }

  Future<List<CourtMembershipSummary>> listMyMemberships() async {
    final response = await ApiClient.instance.get<List<dynamic>>(
      '${ApiEndpoints.courtMemberships}/me',
    );
    final data = response.data ?? [];
    return data
        .whereType<Map>()
        .map(
          (item) =>
              CourtMembershipSummary.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
  }
}
