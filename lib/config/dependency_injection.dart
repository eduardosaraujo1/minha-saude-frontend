import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:minha_saude_frontend/data/services/google_auth_client.dart';
import 'package:minha_saude_frontend/data/services/google_auth_service.dart';
import 'package:minha_saude_frontend/data/services/session_service.dart';
import 'package:minha_saude_frontend/ui/auth/view_model/login_view_model.dart';

final getIt = GetIt.instance;

Future<void> setupDI() async {
  // Services
  final googleAuthService = GoogleAuthService(GoogleSignIn.instance);
  await googleAuthService.init();
  getIt.registerSingleton<GoogleAuthService>(googleAuthService);
  getIt.registerSingleton<SessionService>(SessionService());

  // ViewModels
  getIt.registerFactory<LoginViewModel>(
    () => LoginViewModel(getIt<GoogleAuthClient>()),
  );

  // Await for required .init calls
  getIt<GoogleAuthService>().init();
}
