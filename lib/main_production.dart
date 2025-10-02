import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:minha_saude_frontend/config/dependencies/production_dependencies.dart';

import 'config/flavor_settings.dart';
import 'main_common.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.ALL;

  FlavorSettings.setup(
    flavor: Flavor.development,
    apiBaseUrl: null, // set if needed
    googleClientId: null,
    googleServerClientId: null,
  );

  final dependencies = [ProductionDependencies()];

  mainCommon(dependencies);
}
