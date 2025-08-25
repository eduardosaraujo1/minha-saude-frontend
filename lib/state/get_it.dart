import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/config/routes/go_router.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  getIt.registerLazySingleton<GoRouter>(() {
    return makeRouter();
  });
}
