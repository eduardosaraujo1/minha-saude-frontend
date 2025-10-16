import 'package:flutter_test/flutter_test.dart';
import 'package:minha_saude_frontend/app/domain/actions/auth/login_with_google.dart';
import 'package:minha_saude_frontend/app/ui/auth/view_models/login_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';

class MockLoginWithGoogle extends Mock implements LoginWithGoogle {}

void main() {
  // UNIT
  // Has correct state after google login command
  // INTEGRATION
  // Calls repository method on view model command google login call

  late LoginWithGoogle mockLoginWithGoogle;
  late LoginViewModel viewModel;

  setUp(() {
    mockLoginWithGoogle = MockLoginWithGoogle();
    viewModel = LoginViewModel(mockLoginWithGoogle);
  });

  group("Scenario: User is already registered", () {
    setUp(() {
      when(
        () => mockLoginWithGoogle.execute(),
      ).thenAnswer((_) async => Success(RedirectResponse.toHome));
    });

    test("has correct state after google login command", () async {
      viewModel.loginWithGoogle.execute();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(viewModel.loginWithGoogle.value, isNotNull);
      expect(viewModel.loginWithGoogle.value!.isSuccess(), isTrue);
      expect(
        viewModel.loginWithGoogle.value!.tryGetSuccess(),
        RedirectResponse.toHome,
      );
    });
  });

  group("Scenario: User needs registration", () {
    setUp(() {
      when(
        () => mockLoginWithGoogle.execute(),
      ).thenAnswer((_) async => Success(RedirectResponse.toRegister));
    });

    test("has correct state after google login command", () async {
      viewModel.loginWithGoogle.execute();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(viewModel.loginWithGoogle.value, isNotNull);
      expect(viewModel.loginWithGoogle.value!.isSuccess(), isTrue);
      expect(
        viewModel.loginWithGoogle.value!.tryGetSuccess(),
        RedirectResponse.toRegister,
      );
    });
  });
}
