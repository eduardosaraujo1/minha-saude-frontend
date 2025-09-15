import 'package:minha_saude_frontend/app/data/profile/models/user.dart';
import 'package:multiple_result/multiple_result.dart';

class ProfileRepository {
  // Mock: hardcode user for now
  final User? _cachedUser = User(
    name: 'Eduardo',
    email: 'eduardosaraujo100@gmail.com',
    telefone: '+55 11 95149-0211',
    cpf: '123.456.789-00',
    birthDate: '01/01/1990',
  );
  // CREATE

  // READ
  Future<Result<User, Exception>> getUserProfile() async {
    // Mock profile data, not consistent with register data without server
    if (_cachedUser == null) {
      // In the future, implement fetch logic here
      return Result.error(
        Exception("No user logged in. Did you forget to mock it?"),
      );
    } else {
      return Result.success(_cachedUser);
    }
  }

  // UPDATE

  // DELETE
}
