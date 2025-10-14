class BadResponseException implements Exception {
  BadResponseException(this.message);

  final String message;

  @override
  String toString() => 'BadResponseException: $message';
}
