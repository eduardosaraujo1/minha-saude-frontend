import 'package:minha_saude_frontend/shared/utils/environment_reader.dart';

class GoogleAuthConfig {
  const GoogleAuthConfig();

  String get clientId => String.fromEnvironment('CLIENT_ID');
  String get serverClientId => String.fromEnvironment('SERVER_CLIENT_ID');
}
