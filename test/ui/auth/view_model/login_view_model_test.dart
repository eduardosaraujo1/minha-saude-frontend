import 'package:flutter_test/flutter_test.dart';
import 'package:minha_saude_frontend/app/domain/actions/auth/process_login_result_action.dart';
import 'package:minha_saude_frontend/app/domain/models/auth/login_response/login_result.dart';
import 'package:minha_saude_frontend/app/ui/auth/view_models/login_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';

import '../../../../testing/mocks/repositories/mock_auth_repository.dart';

class MockProcessLoginResult extends Mock implements ProcessLoginResultAction {}

void main() {
  // UNIT
  // Has correct state after google login command
  // INTEGRATION
  // Calls repository method on view model command google login call

  late MockProcessLoginResult mockProcessLoginResult;
  late MockAuthRepository mockAuthRepository;
  late LoginViewModel viewModel;
  const SuccessfulLoginResult mockSuccessResponse = SuccessfulLoginResult(
    sessionToken: "mock_session_token",
  );
  const NeedsRegistrationLoginResult mockRegistrationResponse =
      NeedsRegistrationLoginResult(registerToken: "mock_register_token");

  setUp(() {
    mockProcessLoginResult = MockProcessLoginResult();
    mockAuthRepository = MockAuthRepository();

    // Arrange: It successfully gets Google server token
    when(
      () => mockAuthRepository.getGoogleServerToken(),
    ).thenAnswer((_) async => const Success("valid-google-server-token-123"));

    // Arrange: It successfully logs in with Google
    when(
      () => mockAuthRepository.loginWithGoogle(any()),
    ).thenAnswer((_) async => const Success(mockSuccessResponse));

    // Arrange: it successfully stores token
    when(
      () => mockProcessLoginResult.execute(any()),
    ).thenAnswer((_) async => const Success(null));

    viewModel = LoginViewModel(
      authRepository: mockAuthRepository,
      processLoginAction: mockProcessLoginResult,
    );
  });

  group("User is already registered", () {
    test("has correct state after google login command", () async {
      viewModel.loginWithGoogle.execute();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(viewModel.loginWithGoogle.value, isNotNull);
      expect(viewModel.loginWithGoogle.value!.isSuccess(), isTrue);
      expect(
        viewModel.loginWithGoogle.value!.tryGetSuccess(),
        mockSuccessResponse,
      );
    });
  });

  group("User needs registration", () {
    setUp(() {
      // Arrange: It needs registration in server
      when(
        () => mockAuthRepository.loginWithGoogle(any()),
      ).thenAnswer((_) async => const Success(mockRegistrationResponse));
    });

    test("has correct state after google login command", () async {
      viewModel.loginWithGoogle.execute();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(viewModel.loginWithGoogle.value, isNotNull);
      expect(viewModel.loginWithGoogle.value!.isSuccess(), isTrue);
      expect(
        viewModel.loginWithGoogle.value!.tryGetSuccess(),
        mockRegistrationResponse,
      );
    });
  });

  group("Error Handling", () {
    test("handles errors when getting Google server token fails", () async {
      // Arrange
      when(
        () => mockAuthRepository.getGoogleServerToken(),
      ).thenAnswer((_) async => Error(Exception("Failed to get token")));

      // Act
      viewModel.loginWithGoogle.execute();
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(viewModel.loginWithGoogle.value, isNotNull);
      expect(viewModel.loginWithGoogle.value!.isError(), isTrue);
    });

    test("handles errors when login with Google fails", () async {
      // Arrange
      when(
        () => mockAuthRepository.loginWithGoogle(any()),
      ).thenAnswer((_) async => Error(Exception("Login failed")));

      // Act
      viewModel.loginWithGoogle.execute();
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(viewModel.loginWithGoogle.value, isNotNull);
      expect(viewModel.loginWithGoogle.value!.isError(), isTrue);
    });
    test("handles errors when token storage fails", () async {
      // Arrange
      when(
        () => mockProcessLoginResult.execute(any()),
      ).thenAnswer((_) async => Error(Exception("Token storage failed")));

      // Act
      viewModel.loginWithGoogle.execute();
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(viewModel.loginWithGoogle.value, isNotNull);
      expect(viewModel.loginWithGoogle.value!.isError(), isTrue);
    });
  });
}
