/// Typed exception thrown by [ApiClient] when an HTTP error occurs.
/// Catch this in your service or UI layer instead of raw DioException.
class ApiException implements Exception {
  final int? statusCode;
  final String message;

  const ApiException({required this.message, this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';

  /// Human-readable message safe to show in the UI.
  String get userMessage {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'You are not authorised. Please log in again.';
      case 403:
        return 'You do not have permission to do that.';
      case 404:
        return 'The requested resource was not found.';
      case 409:
        return 'A conflict occurred. The resource may already exist.';
      case 422:
        return 'Invalid data submitted.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return message.isNotEmpty ? message : 'Something went wrong.';
    }
  }
}
