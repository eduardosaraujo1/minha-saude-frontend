import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/config/routes/go_router.dart';
import 'package:minha_saude_frontend/features/auth/provider.dart' as auth;

final getIt = GetIt.I;

void _registerCoreServices() {
  getIt.registerLazySingleton<GoRouter>(() {
    return makeRouter();
  });
}

void configureDependencies() {
  // Serviços padrão
  _registerCoreServices();

  // Expandir dependências
  auth.init();
}
