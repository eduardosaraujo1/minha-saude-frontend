import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'main_common.dart';
import 'config/dependencies/development_dependencies.dart';
import 'config/flavor_settings.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.ALL;

  FlavorSettings.setup(
    flavor: Flavor.development,
    apiBaseUrl: null, // set if needed
    googleClientId: null,
    googleServerClientId: null,
  );

  final dependencies = [
    DevelopmentDependencies(
      mockGoogle: true,
      mockApiClient: true,
      mockScanner: true,
      mockSecureStorage: true,
    ),
  ];

  mainCommon(dependencies);
}
