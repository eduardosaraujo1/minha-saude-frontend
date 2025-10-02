import 'package:get_it/get_it.dart';

import '../../app/ui/core/themes/app_theme.dart';
import 'dependencies.dart';

final _getIt = GetIt.instance;

class SharedDependencies extends Dependencies {
  @override
  Future<void> register() async {
    _getIt.registerSingleton<AppTheme>(AppTheme());
  }

  @override
  Future<void> bind() async {}
}
