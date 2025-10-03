import '../../../data/repositories/auth/auth_repository.dart';
import '../action.dart';

class LoginWithEmail implements Action {
  const LoginWithEmail(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<void> execute() async {
    // TODO: implement execute
    throw UnimplementedError();
  }
}
