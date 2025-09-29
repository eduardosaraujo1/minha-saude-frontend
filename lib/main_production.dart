import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:minha_saude_frontend/app/ui/core/views/init_error_widget.dart';
import 'package:minha_saude_frontend/config/di/provider/service_provider.dart';
import 'package:minha_saude_frontend/config/di/service_locator.dart';

import 'main.dart';

void main() async {
  try {
    // Ensure Flutter bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Configure app logging
    Logger.root.level = Level.ALL;

    // Initialize all providers and dependencies
    ServiceLocator.I.setupProviders([ProductionServiceProvider()]);

    // Run the app
    runApp(const MyApp());
  } catch (e) {
    var log = Logger("Application Main");

    log.severe('Failed to run app: $e');
    runApp(InitErrorWidget(e));
  }
}
