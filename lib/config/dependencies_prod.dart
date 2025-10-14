import 'package:get_it/get_it.dart';

import '../app/ui/core/theme_provider.dart';

final _getIt = GetIt.instance;

Future<void> setup({
  bool mockGoogle = false,
  bool mockApiClient = false,
  bool mockScanner = false,
  bool mockSecureStorage = false,
}) async {
  // Core
  _getIt.registerSingleton<ThemeController>(ThemeController());

  // TODO: Implement production dependencies
  throw UnimplementedError();
}
