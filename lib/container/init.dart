import 'package:get_it/get_it.dart';

import 'package:minha_saude_frontend/container/providers/auth.dart' as auth;
import 'package:minha_saude_frontend/container/providers/theme.dart' as theme;
import 'package:minha_saude_frontend/container/providers/core.dart' as core;

// The single instance of GetIt
final getIt = GetIt.instance;

/// Initialize all providers and dependencies
void initProviders() {
  // Register services
  core.setup();
  auth.setup();
  theme.setup();
}

Future<void> allReady() async {
  // Wait until getIt sets up all the async services
  await GetIt.I.allReady();
}
