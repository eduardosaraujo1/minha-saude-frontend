import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/routes/go_router.dart';
import 'package:minha_saude_frontend/old/features/auth/provider.dart' as auth;
import 'package:minha_saude_frontend/data/shared/providers/auth_provider.dart';

final getIt = GetIt.I;

void _registerCoreServices() {
  getIt.registerSingleton<FlutterSecureStorage>(FlutterSecureStorage());
  getIt.registerLazySingleton<GoRouter>(() {
    return makeRouter();
  });
  getIt.registerLazySingleton<AuthProvider>(
    () => AuthProvider(getIt<FlutterSecureStorage>()),
  );
}

void configureDependencies() {
  // Serviços padrão
  _registerCoreServices();

  // Expandir dependências
  auth.init();
}
