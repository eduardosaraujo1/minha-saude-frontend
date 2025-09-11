// TODO: Add expired_at field
class RegisterResponse {
  final RegisterStatus status;

  const RegisterResponse(this.status);
}

enum RegisterStatus { success, failure }
