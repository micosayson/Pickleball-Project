/// All FastAPI backend endpoint paths.
/// Always use these constants instead of hardcoding paths in service files.
class ApiEndpoints {
  static const String authMe = '/auth/me';

  static const String users = '/users';
  static const String usersMe = '/users/me';
  static const String userSync = '/users/sync';
  static String user(String id) => '/users/$id';

  static const String courts = '/courts';
  static String court(String id) => '/courts/$id';
  static const String courtMemberships = '/court-memberships';
  static String courtMembership(String courtId) =>
      '/court-memberships/$courtId';

  static const String events = '/events';
  static String event(String id) => '/events/$id';
  static String eventParticipants(String id) => '/events/$id/participants';
  static const String eventRegistrations = '/event-registrations';
  static String eventRegistration(String eventId) =>
      '/event-registrations/$eventId';
  static String eventCheckIn(String eventId) =>
      '/event-registrations/$eventId/check-in';

  static const String matches = '/matches';
  static String match(String id) => '/matches/$id';
  static String matchParticipants(String id) => '/matches/$id/participants';

  static const String ratings = '/ratings';
  static const String rankings = '/rankings';
  static const String ratingHistory = '/rating-history';

  static const String payments = '/payments';
    static const String bookings = '/bookings';
    static String booking(String id) => '/bookings/$id';
    static const String notifications = '/notifications';
    static const String dashboard = '/dashboard';
  static const String invitations = '/invitations';
  static const String scoreSubmissions = '/score-submissions';
}
