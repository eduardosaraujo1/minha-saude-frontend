import 'package:minha_saude_frontend/app/data/profile/models/user.dart';
import 'package:multiple_result/multiple_result.dart';

class ProfileRepository {
  // Mock: hardcode user for now
  User? _cachedUser = User(
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
      return Result.success(_cachedUser!);
    }
  }

  // UPDATE
  Future<Result<void, Exception>> updateNome(String newName) async {
    try {
      _cachedUser = _cachedUser?.copyWith(name: newName);
      return Result.success(null);
    } catch (e) {
      return Result.error(Exception("Failed to update name: $e"));
    }
  }

  Future<Result<void, Exception>> updateEmail(String newEmail) async {
    try {
      _cachedUser = _cachedUser?.copyWith(email: newEmail);
      return Result.success(null);
    } catch (e) {
      return Result.error(Exception("Failed to update email: $e"));
    }
  }

  Future<Result<void, Exception>> updateTelefone(String newTelefone) async {
    try {
      _cachedUser = _cachedUser?.copyWith(telefone: newTelefone);
      return Result.success(null);
    } catch (e) {
      return Result.error(Exception("Failed to update telefone: $e"));
    }
  }

  Future<Result<void, Exception>> updateBirthDate(String newBirthDate) async {
    try {
      _cachedUser = _cachedUser?.copyWith(birthDate: newBirthDate);
      return Result.success(null);
    } catch (e) {
      return Result.error(Exception("Failed to update birth date: $e"));
    }
  }

  // DELETE
}
