import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class EventSummary {
  const EventSummary({
    required this.id,
    required this.courtId,
    required this.name,
    required this.eventType,
    required this.status,
    required this.startAt,
    required this.endAt,
    this.capacity,
  });

  final String id;
  final String courtId;
  final String name;
  final String eventType;
  final String status;
  final DateTime startAt;
  final DateTime endAt;
  final int? capacity;

  factory EventSummary.fromJson(Map<String, dynamic> json) {
    return EventSummary(
      id: json['id']?.toString() ?? '',
      courtId: json['court_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Event',
      eventType: json['event_type']?.toString() ?? 'open_play',
      status: json['status']?.toString() ?? 'scheduled',
      startAt:
          DateTime.tryParse(json['start_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      endAt:
          DateTime.tryParse(json['end_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      capacity: (json['capacity'] as num?)?.toInt(),
    );
  }
}

class EventRegistrationSummary {
  const EventRegistrationSummary({
    required this.id,
    required this.eventId,
    required this.status,
  });

  final String id;
  final String eventId;
  final String status;

  factory EventRegistrationSummary.fromJson(Map<String, dynamic> json) {
    return EventRegistrationSummary(
      id: json['id']?.toString() ?? '',
      eventId: json['event_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'registered',
    );
  }
}

class EventService {
  const EventService();

  Future<List<EventSummary>> listEvents({int limit = 3}) async {
    final response = await ApiClient.instance.get<List<dynamic>>(
      ApiEndpoints.events,
      queryParameters: {'limit': limit},
    );
    final data = response.data ?? [];
    return data
        .whereType<Map>()
        .map((item) => EventSummary.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Future<EventRegistrationSummary> joinEvent(String eventId) async {
    final response = await ApiClient.instance.post<Map<String, dynamic>>(
      ApiEndpoints.eventRegistration(eventId),
    );
    return EventRegistrationSummary.fromJson(response.data ?? {});
  }

  Future<List<EventRegistrationSummary>> listMyRegistrations() async {
    final response = await ApiClient.instance.get<List<dynamic>>(
      '${ApiEndpoints.eventRegistrations}/me',
    );
    final data = response.data ?? [];
    return data
        .whereType<Map>()
        .map(
          (item) => EventRegistrationSummary.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList(growable: false);
  }
}
