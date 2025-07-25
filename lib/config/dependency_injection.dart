import 'package:get_it/get_it.dart';
import 'package:minha_saude_frontend/data/services/session.dart';
import '../ui/auth/view_model/login_view_model.dart';

final getIt = GetIt.instance;

void setupDI() {
  getIt.registerFactory<LoginViewModel>(() => LoginViewModel());
  getIt.registerLazySingleton<Session>(() => Session());
}
