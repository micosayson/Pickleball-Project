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

  static const String events = '/events';
  static String event(String id) => '/events/$id';
  static String eventParticipants(String id) => '/events/$id/participants';

  static const String matches = '/matches';
  static String match(String id) => '/matches/$id';
  static String matchParticipants(String id) => '/matches/$id/participants';

  static const String ratings = '/ratings';
  static const String rankings = '/rankings';
  static const String ratingHistory = '/rating-history';

  static const String payments = '/payments';
  static const String invitations = '/invitations';
}
