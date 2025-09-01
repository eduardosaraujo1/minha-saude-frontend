import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:minha_saude_frontend/features/auth/domain/services/google_auth_service.dart';
import 'package:minha_saude_frontend/features/auth/domain/services/google_auth_config.dart';
import 'package:minha_saude_frontend/features/auth/ui/view_models/login_view_model.dart';
import 'package:minha_saude_frontend/features/auth/ui/view_models/register_screen_view_model.dart';
import 'package:minha_saude_frontend/features/auth/ui/view_models/terms_conditions_view_model.dart';

void init() {
  final getIt = GetIt.I;

  // Objetos da camada 'data' e 'domain' registrados aqui
  getIt.registerSingleton<GoogleAuthConfig>(GoogleAuthConfig());
  getIt.registerSingletonAsync<GoogleAuthService>(() {
    return GoogleAuthService.create(
      GoogleSignIn.instance,
      getIt<GoogleAuthConfig>(),
    );
  });

  // ViewModels registrados aqui
  getIt.registerCachedFactory<LoginViewModel>(
    () => LoginViewModel(getIt<GoogleAuthService>()),
  );
  getIt.registerCachedFactory<RegisterScreenViewModel>(
    () => RegisterScreenViewModel(),
  );
  getIt.registerCachedFactory<TermsConditionsViewModel>(
    () => TermsConditionsViewModel(),
  );
}
