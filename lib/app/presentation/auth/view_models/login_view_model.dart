import 'package:flutter/foundation.dart';
import 'package:minha_saude_frontend/app/data/auth/repositories/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository authRepository;

  LoginStatus _status = LoginStatus.initial;
  String? _errorMessage;
  bool _isLoading = false;

  LoginViewModel(this.authRepository);

  LoginStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    _status = LoginStatus.initial;
    notifyListeners();

    try {
      // Use the new googleLogin method
      final result = await authRepository.googleLogin();

      if (result.isError()) {
        _status = LoginStatus.error;
        _errorMessage =
            result.tryGetError()?.toString() ?? "Ocorreu um erro desconhecido.";
      } else {
        final signInResult = result.getOrThrow();

        // After successful login, check registration status
        final isRegistered = authRepository.isRegistered;

        if (!isRegistered) {
          _status = LoginStatus.needsRegistration;
        } else if (signInResult.sessionToken != null) {
          _status = LoginStatus.authenticated;
        } else {
          _status = LoginStatus.error;
          _errorMessage = "Ocorreu um erro desconhecido.";
        }
      }
    } catch (e) {
      _status = LoginStatus.error;
      _errorMessage = "Ocorreu um erro desconhecido.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// ...existing code...

enum LoginStatus { initial, authenticated, needsRegistration, error }
