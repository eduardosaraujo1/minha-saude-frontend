import 'package:minha_saude_frontend/config/providers/service_provider.dart';

import 'main.dart';

void main() async {
  final providers = [DevelopmentServiceProvider()];

  Application.configure().withProviders(providers).run();
}
