import 'service_provider.dart';

class ProductionServiceProvider extends ServiceProvider {
  @override
  Future<void> register() async {}

  @override
  Future<void> bind() async {
    // Bind app-specific services here
  }
}
