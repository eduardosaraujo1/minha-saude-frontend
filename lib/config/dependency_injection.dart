import 'package:get_it/get_it.dart';
import 'package:minha_saude_frontend/data/services/google_auth_client.dart';
import 'package:minha_saude_frontend/data/services/session.dart';
import 'package:minha_saude_frontend/ui/auth/view_model/login_view_model.dart';

final getIt = GetIt.instance;

void setupDI() {
  getIt.registerLazySingleton<GoogleAuthClient>(() => GoogleAuthClient());
  getIt.registerFactory<LoginViewModel>(
    () => LoginViewModel(getIt<GoogleAuthClient>()),
  );
  getIt.registerLazySingleton<Session>(() => Session());
}
