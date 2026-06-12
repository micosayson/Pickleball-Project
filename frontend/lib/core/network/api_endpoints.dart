/// All FastAPI backend endpoint paths.
/// Always use these constants — never hardcode paths in service files.
class ApiEndpoints {
  // ── Auth ──────────────────────────────────────────────────────────────
  static const String authMe = '/auth/me';

  // ── Users ─────────────────────────────────────────────────────────────
  static const String users = '/users';
  static String user(String id) => '/users/$id';

  // ── Courts ────────────────────────────────────────────────────────────
  static const String courts = '/courts';
  static String court(String id) => '/courts/$id';

  // ── Events ────────────────────────────────────────────────────────────
  static const String events = '/events';
  static String event(String id) => '/events/$id';
  static String eventParticipants(String id) => '/events/$id/participants';

  // ── Matches ───────────────────────────────────────────────────────────
  static const String matches = '/matches';
  static String match(String id) => '/matches/$id';
  static String matchParticipants(String id) => '/matches/$id/participants';

  // ── Ratings & Rankings ────────────────────────────────────────────────
  static const String ratings = '/ratings';
  static const String rankings = '/rankings';
  static const String ratingHistory = '/rating-history';

  // ── Payments ──────────────────────────────────────────────────────────
  static const String payments = '/payments';

  // ── Invitations ───────────────────────────────────────────────────────
  static const String invitations = '/invitations';
}
