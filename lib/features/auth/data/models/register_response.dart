import 'package:minha_saude_frontend/shared/models/user.dart';

class RegisterResponse {
  final RegisterStatus status;
  final User? user;
  const RegisterResponse(this.status, this.user);
}

enum RegisterStatus { success, failure }
