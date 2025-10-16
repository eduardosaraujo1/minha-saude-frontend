class UnreachableServerException implements Exception {
  UnreachableServerException(this.message);

  final String message;

  @override
  String toString() => 'BadResponseException: $message';
}
