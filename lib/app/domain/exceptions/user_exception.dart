/// Custom exception class for user-facing error messages
class UserException implements Exception {
  final String message;

  const UserException(this.message);

  @override
  String toString() => message;
}
