import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:minha_saude_frontend/data/auth/repositories/auth_repository.dart';
import 'package:minha_saude_frontend/data/auth/sources/auth_remote_data_source.dart';
import 'package:minha_saude_frontend/data/auth/sources/google_auth_config.dart';
import 'package:minha_saude_frontend/data/auth/sources/google_sign_in_data_source.dart';
import 'package:minha_saude_frontend/old/features/auth/ui/view_models/login_view_model.dart';
import 'package:minha_saude_frontend/old/features/auth/ui/view_models/register_screen_view_model.dart';
import 'package:minha_saude_frontend/old/features/auth/ui/view_models/terms_conditions_view_model.dart';

void init() {
  final getIt = GetIt.I;

  // Shared services (these should be singletons)

  // Data layer
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(),
  );
  getIt.registerSingletonAsync<GoogleSignInDataSource>(
    () => GoogleSignInDataSource.create(
      GoogleSignIn.instance,
      GoogleAuthConfig(),
    ),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      getIt<AuthRemoteDataSource>(),
      getIt<GoogleSignInDataSource>(),
    ),
  );

  // ViewModels (these should be factories so they can be disposed properly)
  getIt.registerFactory<LoginViewModel>(
    () => LoginViewModel(getIt<AuthRepository>()),
  );

  getIt.registerFactory<RegisterScreenViewModel>(
    () => RegisterScreenViewModel(),
  );

  getIt.registerFactory<TermsConditionsViewModel>(
    () => TermsConditionsViewModel(),
  );
}
