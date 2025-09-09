import 'package:get_it/get_it.dart';

import 'package:minha_saude_frontend/container/providers/auth.dart' as auth;
import 'package:minha_saude_frontend/container/providers/core.dart' as core;

/// Initialize all providers and dependencies
void initProviders() {
  // Register services
  core.setup();
  auth.setup();
}

Future<void> allReady() async {
  // Wait until getIt sets up all the async services
  await GetIt.I.allReady();
}
