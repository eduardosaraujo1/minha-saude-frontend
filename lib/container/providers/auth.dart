import 'package:google_sign_in/google_sign_in.dart';
import 'package:minha_saude_frontend/app/data/auth/repositories/auth_repository.dart';
import 'package:minha_saude_frontend/app/data/auth/sources/auth_local_data_source.dart';
import 'package:minha_saude_frontend/app/data/auth/sources/auth_remote_data_source.dart';
import 'package:minha_saude_frontend/app/data/auth/sources/google_sign_in_data_source.dart';
import 'package:minha_saude_frontend/app/data/shared/sources/api_client.dart';
import 'package:minha_saude_frontend/app/data/shared/sources/secure_storage.dart';
import 'package:minha_saude_frontend/config/google_auth_config.dart';
import 'package:minha_saude_frontend/container/get_it.dart';

void setup() {
  getIt.registerSingleton<AuthLocalDataSource>(
    AuthLocalDataSource(getIt<SecureStorage>()),
  );

  getIt.registerSingleton<ApiClient>(ApiClient());

  getIt.registerSingleton<AuthRemoteDataSource>(
    AuthRemoteDataSource(getIt<ApiClient>()),
  );

  getIt.registerSingletonAsync(() async {
    return GoogleSignInDataSource.create(
      GoogleSignIn.instance,
      GoogleAuthConfig(),
    );
  });

  getIt.registerSingletonWithDependencies<AuthRepository>(
    () => AuthRepository(
      getIt<AuthRemoteDataSource>(),
      getIt<AuthLocalDataSource>(),
      getIt<GoogleSignInDataSource>(),
    ),
    dependsOn: [GoogleSignInDataSource],
  );
}
