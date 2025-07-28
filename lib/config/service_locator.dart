import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:minha_saude_frontend/config/google_auth_config.dart';
import 'package:minha_saude_frontend/data/services/google_auth_service.dart';
import 'package:minha_saude_frontend/data/services/session_service.dart';
import 'package:minha_saude_frontend/ui/auth/view_model/login_view_model.dart';

final getIt = GetIt.instance;

/// Configures and initializes the service locator for dependency injection.
///
/// This function is responsible for setting up all service dependencies and
/// registering them in the service locator container. It must be called before
/// the application starts to ensure all required services are available.
///
/// The setup is done asynchronously to allow for any initialization that
/// requires async operations (e.g., loading configurations, establishing
/// connections).
///
/// Example:
/// ```dart
/// void main() async {
///   await setupServiceLocator();
///   runApp(MyApp());
/// }
/// ```
///
/// Throws:
///   * [Exception] if any service fails to be registered or initialized
///
Future<void> setupServiceLocator() async {
  // Services
  final googleAuthConfig = GoogleAuthConfig();
  getIt.registerSingleton<GoogleAuthConfig>(googleAuthConfig);

  final googleAuthService = GoogleAuthService(
    GoogleSignIn.instance,
    googleAuthConfig,
  );
  await googleAuthService.init();
  getIt.registerSingleton<GoogleAuthService>(googleAuthService);

  final sessionService = SessionService();
  getIt.registerSingleton<SessionService>(sessionService);

  // ViewModels
  getIt.registerFactory<LoginViewModel>(
    () => LoginViewModel(getIt<GoogleAuthService>()),
  );
}
