import 'package:minha_saude_frontend/app/data/repositories/auth/auth_repository.dart';
import 'package:minha_saude_frontend/app/data/repositories/session/session_repository.dart';
import 'package:minha_saude_frontend/app/domain/actions/auth/register_action.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:test/test.dart';

import '../../../testing/models/profile.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSessionRepository extends Mock implements SessionRepository {}

void main() {
  late AuthRepository authRepository;
  late SessionRepository sessionRepository;
  late RegisterAction registerAction;

  RegisterRequestModel getRequest() {
    final profile = randomProfile();
    return RegisterRequestModel(
      nome: profile.nome,
      cpf: profile.cpf,
      dataNascimento: profile.dataNascimento,
      telefone: profile.telefone,
    );
  }

  final registerRequestModel = getRequest();
  const storedRegisterToken = "valid-register-token-123";
  const serverTokenResponse = "valid-session-token-456";

  setUp(() {
    // Initialize mocks
    authRepository = MockAuthRepository();
    sessionRepository = MockSessionRepository();

    // Arrange: It has stored session token
    when(
      () => sessionRepository.getRegisterToken(),
    ).thenReturn(storedRegisterToken);

    // Arrange: It successfully registers and returns server token
    when(
      () => authRepository.register(
        nome: any(named: "nome"),
        cpf: any(named: "cpf"),
        dataNascimento: any(named: "dataNascimento"),
        telefone: any(named: "telefone"),
        registerToken: storedRegisterToken,
      ),
    ).thenAnswer((_) async => const Success(serverTokenResponse));

    // Arrange: It successfully stores session token
    when(
      () => sessionRepository.setAuthToken(any()),
    ).thenAnswer((_) async => const Result.success(null));

    registerAction = RegisterAction(
      sessionRepository: sessionRepository,
      authRepository: authRepository,
    );
  });

  /** Business Rules
   * Group: Register Submission
   * it should get submit registration to server and store token on success
   * Group: Error Handling
   * it should handle null register token by returning Error
   * it should handle empty register token by returning Error
   * it should handle registration failure by returning Error
   * it should handle token storage failure by returning Error
   */
  group("Register Submission", () {
    test(
      "it should get submit registration to server and store token on success",
      () async {
        // Act
        final result = await registerAction.execute(registerRequestModel);

        // Assert: registration succeeded
        expect(result.isSuccess(), true);

        // Assert: repository was called with correct parameters
        verify(
          () => authRepository.register(
            nome: registerRequestModel.nome,
            cpf: registerRequestModel.cpf,
            dataNascimento: registerRequestModel.dataNascimento,
            telefone: registerRequestModel.telefone,
            registerToken: storedRegisterToken,
          ),
        ).called(1);

        // Assert: token was stored
        verify(
          () => sessionRepository.setAuthToken(serverTokenResponse),
        ).called(1);
      },
    );
  });

  group("Error Handling", () {
    test("it should handle null register token by returning Error", () async {
      // Arrange
      when(() => sessionRepository.getRegisterToken()).thenReturn(null);

      // Act
      final result = await registerAction.execute(registerRequestModel);

      // Assert: result is error
      expect(result.isError(), true);

      // Assert: it avoids call to repository
      verifyNever(
        () => authRepository.register(
          nome: any(named: "nome"),
          cpf: any(named: "cpf"),
          dataNascimento: any(named: "dataNascimento"),
          telefone: any(named: "telefone"),
          registerToken: any(named: "registerToken"),
        ),
      );
      // Assert: it avoids storage
      verifyNever(() => sessionRepository.setAuthToken(any()));
    });
    test("it should handle empty register token by returning Error", () async {
      // Arrange
      when(() => sessionRepository.getRegisterToken()).thenReturn("");

      // Act
      final result = await registerAction.execute(registerRequestModel);

      // Assert: result is error
      expect(result.isError(), true);

      // Assert: it avoids call to repository
      verifyNever(
        () => authRepository.register(
          nome: any(named: "nome"),
          cpf: any(named: "cpf"),
          dataNascimento: any(named: "dataNascimento"),
          telefone: any(named: "telefone"),
          registerToken: any(named: "registerToken"),
        ),
      );

      // Assert: it avoids storage
      verifyNever(() => sessionRepository.setAuthToken(any()));
    });
    test("it should handle registration failure by returning Error", () async {
      // Arrange
      when(
        () => authRepository.register(
          nome: any(named: "nome"),
          cpf: any(named: "cpf"),
          dataNascimento: any(named: "dataNascimento"),
          telefone: any(named: "telefone"),
          registerToken: any(named: "registerToken"),
        ),
      ).thenAnswer(
        (_) async => Error(Exception("Registration failed on server")),
      );

      // Act
      final result = await registerAction.execute(registerRequestModel);

      // Assert: result is error
      expect(result.isError(), true);

      // Assert: it avoids storage
      verifyNever(() => sessionRepository.setAuthToken(any()));
    });
    test("it should handle token storage failure by returning Error", () async {
      // Arrange
      when(
        () => sessionRepository.setAuthToken(any()),
      ).thenAnswer((_) async => Error(Exception("Storage error")));

      // Act
      final result = await registerAction.execute(registerRequestModel);

      // Assert: result is error
      expect(result.isError(), true);

      // Assert: repository was at least called
      verify(
        () => authRepository.register(
          nome: any(named: "nome"),
          cpf: any(named: "cpf"),
          dataNascimento: any(named: "dataNascimento"),
          telefone: any(named: "telefone"),
          registerToken: any(named: "registerToken"),
        ),
      ).called(1);

      // Assert: storage was attempted but failed
      verify(() => sessionRepository.setAuthToken(any())).called(1);
    });
  });
}
