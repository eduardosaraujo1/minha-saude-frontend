import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/config/bootstrap/application_config.dart';
import 'package:minha_saude_frontend/config/container/service_locator.dart';
import 'package:minha_saude_frontend/config/providers/service_provider.dart';
import 'package:minha_saude_frontend/main.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    final providers = [ProductionServiceProvider()];
    final config = ApplicationConfig(
      serviceLocator: ServiceLocator.I,
      providers: providers,
    );

    await config.setup();

    runApp(const MyApp());
  } catch (e, stackTrace) {
    runApp(ErrorApp(e, stackTrace: stackTrace));
  }
}
