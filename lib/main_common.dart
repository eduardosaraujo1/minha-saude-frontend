import 'package:flutter/material.dart';

import 'config/dependencies/shared_dependencies.dart';
import 'config/dependencies/dependencies.dart';
import 'config/bootstrap.dart';
import 'main.dart';

Future<void> mainCommon(List<Dependencies> dependencies) async {
  try {
    await registerDependencies([SharedDependencies(), ...dependencies]);

    runApp(const MyApp());
  } catch (e, stackTrace) {
    runApp(ErrorApp(e, stackTrace: stackTrace));
  }
}
