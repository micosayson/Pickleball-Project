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
    this.checkedInAt,
  });

  final String id;
  final String eventId;
  final String status;
  final DateTime? checkedInAt;

  factory EventRegistrationSummary.fromJson(Map<String, dynamic> json) {
    return EventRegistrationSummary(
      id: json['id']?.toString() ?? '',
      eventId: json['event_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'registered',
      checkedInAt: DateTime.tryParse(json['checked_in_at']?.toString() ?? ''),
    );
  }

  @override
  String toString() {
    final checkedIn = checkedInAt?.toLocal().toIso8601String();
    return checkedIn == null
        ? '{event_id: $eventId, status: $status}'
        : '{event_id: $eventId, status: $status, checked_in_at: $checkedIn}';
  }
}

class EventQueueEntrySummary {
  const EventQueueEntrySummary({
    required this.id,
    required this.status,
    this.queuePosition,
    this.assignedMatchId,
  });

  final String id;
  final String status;
  final int? queuePosition;
  final String? assignedMatchId;

  factory EventQueueEntrySummary.fromJson(Map<String, dynamic> json) {
    return EventQueueEntrySummary(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'queued',
      queuePosition: (json['queue_position'] as num?)?.toInt(),
      assignedMatchId: json['assigned_match_id']?.toString(),
    );
  }
}

class MatchParticipantSummary {
  const MatchParticipantSummary({
    required this.userId,
    required this.teamNumber,
    required this.slotNumber,
    required this.displayName,
  });

  final String userId;
  final int teamNumber;
  final int? slotNumber;
  final String displayName;

  factory MatchParticipantSummary.fromJson(Map<String, dynamic> json) {
    return MatchParticipantSummary(
      userId: json['user_id']?.toString() ?? '',
      teamNumber: (json['team_number'] as num?)?.toInt() ?? 1,
      slotNumber: (json['slot_number'] as num?)?.toInt(),
      displayName: json['display_name']?.toString() ?? 'Player',
    );
  }
}

class PlayMatchSummary {
  const PlayMatchSummary({
    required this.id,
    required this.matchNumber,
    required this.status,
    required this.participants,
    this.winnerTeamNumber,
  });

  final String id;
  final int matchNumber;
  final String status;
  final int? winnerTeamNumber;
  final List<MatchParticipantSummary> participants;

  List<MatchParticipantSummary> get teamOne =>
      participants.where((p) => p.teamNumber == 1).toList(growable: false);

  List<MatchParticipantSummary> get teamTwo =>
      participants.where((p) => p.teamNumber == 2).toList(growable: false);

  String get matchLabel => '#$matchNumber';

  factory PlayMatchSummary.fromJson(Map<String, dynamic> json) {
    final rawParticipants = json['participants'] as List<dynamic>? ?? [];
    return PlayMatchSummary(
      id: json['id']?.toString() ?? '',
      matchNumber: (json['match_number'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'assigned',
      winnerTeamNumber: (json['winner_team_number'] as num?)?.toInt(),
      participants: rawParticipants
          .whereType<Map>()
          .map(
            (item) => MatchParticipantSummary.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(growable: false),
    );
  }
}

class PlayerScoreSubmissionSummary {
  const PlayerScoreSubmissionSummary({
    required this.id,
    required this.status,
    required this.teamOneScore,
    required this.teamTwoScore,
  });

  final String id;
  final String status;
  final int teamOneScore;
  final int teamTwoScore;

  factory PlayerScoreSubmissionSummary.fromJson(Map<String, dynamic> json) {
    return PlayerScoreSubmissionSummary(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      teamOneScore: (json['team_one_score'] as num?)?.toInt() ?? 0,
      teamTwoScore: (json['team_two_score'] as num?)?.toInt() ?? 0,
    );
  }
}

class PlayerEventStatusSummary {
  const PlayerEventStatusSummary({
    required this.phase,
    this.registration,
    this.queueEntry,
    this.match,
    this.scoreSubmission,
  });

  final String phase;
  final EventRegistrationSummary? registration;
  final EventQueueEntrySummary? queueEntry;
  final PlayMatchSummary? match;
  final PlayerScoreSubmissionSummary? scoreSubmission;

  bool get hasMatch => match != null;
  bool get isWaitingVerification =>
      phase == 'score_pending' || phase == 'pending_verification';

  factory PlayerEventStatusSummary.fromJson(Map<String, dynamic> json) {
    final registration = json['registration'];
    final queueEntry = json['queue_entry'];
    final match = json['match'];
    final score = json['score_submission'];
    return PlayerEventStatusSummary(
      phase: json['phase']?.toString() ?? 'no_registration',
      registration: registration is Map
          ? EventRegistrationSummary.fromJson(
              Map<String, dynamic>.from(registration),
            )
          : null,
      queueEntry: queueEntry is Map
          ? EventQueueEntrySummary.fromJson(
              Map<String, dynamic>.from(queueEntry),
            )
          : null,
      match: match is Map
          ? PlayMatchSummary.fromJson(Map<String, dynamic>.from(match))
          : null,
      scoreSubmission: score is Map
          ? PlayerScoreSubmissionSummary.fromJson(
              Map<String, dynamic>.from(score),
            )
          : null,
    );
  }
}

class EventService {
  const EventService();

  Future<List<EventSummary>> listEvents({
    int limit = 3,
    String? courtId,
  }) async {
    final queryParameters = <String, dynamic>{'limit': limit};
    if (courtId != null) {
      queryParameters['court_id'] = courtId;
    }
    final response = await ApiClient.instance.get<List<dynamic>>(
      ApiEndpoints.events,
      queryParameters: queryParameters,
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

  Future<PlayerEventStatusSummary> joinLobby(String eventId) async {
    final response = await ApiClient.instance.post<Map<String, dynamic>>(
      ApiEndpoints.eventCheckIn(eventId),
    );
    return PlayerEventStatusSummary.fromJson(response.data ?? {});
  }

  Future<PlayerEventStatusSummary> readStatus(String eventId) async {
    final response = await ApiClient.instance.get<Map<String, dynamic>>(
      ApiEndpoints.eventStatus(eventId),
    );
    return PlayerEventStatusSummary.fromJson(response.data ?? {});
  }

  Future<PlayerEventStatusSummary> leaveEvent(String eventId) async {
    final response = await ApiClient.instance.post<Map<String, dynamic>>(
      ApiEndpoints.eventLeave(eventId),
    );
    return PlayerEventStatusSummary.fromJson(response.data ?? {});
  }

  Future<void> startMatch(String matchId) async {
    await ApiClient.instance.post<Map<String, dynamic>>(
      ApiEndpoints.matchStart(matchId),
    );
  }

  Future<PlayerScoreSubmissionSummary> submitScore({
    required String matchId,
    required int teamOneScore,
    required int teamTwoScore,
  }) async {
    final response = await ApiClient.instance.post<Map<String, dynamic>>(
      ApiEndpoints.scoreSubmissions,
      data: {
        'match_id': matchId,
        'team_one_score': teamOneScore,
        'team_two_score': teamTwoScore,
      },
    );
    return PlayerScoreSubmissionSummary.fromJson(response.data ?? {});
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
