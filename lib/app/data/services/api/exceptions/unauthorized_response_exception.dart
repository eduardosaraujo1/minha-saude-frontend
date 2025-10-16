class UnauthorizedResponseException implements Exception {
  UnauthorizedResponseException(this.message);

  final String message;

  @override
  String toString() => 'UnauthorizedResponseException: $message';
}
