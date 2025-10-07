import 'package:minha_saude_frontend/app/data/repositories/auth/auth_repository.dart';
import 'package:minha_saude_frontend/app/data/repositories/session/session_repository.dart';
import 'package:minha_saude_frontend/app/domain/actions/auth/register_action.dart';
import 'package:minha_saude_frontend/app/domain/models/auth/user_register_model/user_register_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:test/test.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSessionRepository extends Mock implements SessionRepository {}

void main() {
  late AuthRepository authRepository;
  late SessionRepository sessionRepository;
  late RegisterAction registerAction;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(
      UserRegisterModel(
        registerToken: '',
        nome: '',
        cpf: '',
        telefone: '',
        dataNascimento: DateTime(1990),
      ),
    );
  });

  setUp(() {
    authRepository = MockAuthRepository();
    sessionRepository = MockSessionRepository();
    registerAction = RegisterAction(
      sessionRepository: sessionRepository,
      authRepository: authRepository,
    );
  });

  test(
    "when registration succeeds then it should clear register token, store session token and return Success",
    () async {
      // Hook SessionRepository.getRegisterToken to return a valid token
      when(
        () => sessionRepository.getRegisterToken(),
      ).thenReturn("test-register-token-123");

      // Hook AuthRepository.register to return Success with session token
      when(
        () => authRepository.register(any()),
      ).thenAnswer((_) async => const Result.success("test-session-token-456"));

      // Hook SessionRepository.clearRegisterToken to detect it was called
      when(() => sessionRepository.clearRegisterToken()).thenAnswer((_) {});

      // Hook SessionRepository.setAuthToken to return Success
      when(
        () => sessionRepository.setAuthToken(any()),
      ).thenAnswer((_) async => const Result.success(null));

      // Execute action
      final result = await registerAction.execute(
        nome: "John Doe",
        cpf: "12345678900",
        dataNascimento: DateTime(1990, 1, 15),
        telefone: "11999999999",
      );

      // Assert result is Success
      expect(result.isSuccess(), true);

      // Assert SessionRepository.getRegisterToken was called
      verify(() => sessionRepository.getRegisterToken()).called(1);

      // Assert AuthRepository.register was called with correct parameters
      final captured = verify(
        () => authRepository.register(captureAny()),
      ).captured;
      expect(captured.length, 1);
      final registerModel = captured.first as UserRegisterModel;
      expect(registerModel.nome, "John Doe");
      expect(registerModel.cpf, "12345678900");
      expect(registerModel.dataNascimento, DateTime(1990, 1, 15));
      expect(registerModel.telefone, "11999999999");
      expect(registerModel.registerToken, "test-register-token-123");

      // Assert SessionRepository.clearRegisterToken was called
      verify(() => sessionRepository.clearRegisterToken()).called(1);

      // Assert SessionRepository.setAuthToken was called with session token
      verify(
        () => sessionRepository.setAuthToken("test-session-token-456"),
      ).called(1);
    },
  );

  test(
    "when register token is null then it should return Error without calling register",
    () async {
      // Hook SessionRepository.getRegisterToken to return null
      when(() => sessionRepository.getRegisterToken()).thenReturn(null);

      // Hook AuthRepository.register to detect if it's called
      when(
        () => authRepository.register(any()),
      ).thenAnswer((_) async => const Result.success("test-session-token"));

      // Execute action
      final result = await registerAction.execute(
        nome: "John Doe",
        cpf: "12345678900",
        dataNascimento: DateTime(1990, 1, 15),
        telefone: "11999999999",
      );

      // Assert result is Error
      expect(result.isError(), true);
      expect(
        result.tryGetError()!.toString(),
        contains('Login expirado. Faça login novamente para continuar'),
      );

      // Assert SessionRepository.getRegisterToken was called
      verify(() => sessionRepository.getRegisterToken()).called(1);

      // Assert AuthRepository.register was never called
      verifyNever(() => authRepository.register(any()));
    },
  );

  test(
    "when AuthRepository.register returns Error then it should return Error without storing tokens",
    () async {
      // Hook SessionRepository.getRegisterToken to return a valid token
      when(
        () => sessionRepository.getRegisterToken(),
      ).thenReturn("test-register-token-123");

      // Hook AuthRepository.register to return Error
      final testError = Exception("Registration failed on server");
      when(
        () => authRepository.register(any()),
      ).thenAnswer((_) async => Result.error(testError));

      // Hook SessionRepository methods to detect if they're called
      when(() => sessionRepository.clearRegisterToken()).thenAnswer((_) {});
      when(
        () => sessionRepository.setAuthToken(any()),
      ).thenAnswer((_) async => const Result.success(null));

      // Execute action
      final result = await registerAction.execute(
        nome: "John Doe",
        cpf: "12345678900",
        dataNascimento: DateTime(1990, 1, 15),
        telefone: "11999999999",
      );

      // Assert result is Error
      expect(result.isError(), true);
      expect(
        result.tryGetError()!.toString(),
        contains('Ocorreu um erro desconhecido durante o processo de registro'),
      );

      // Assert SessionRepository.getRegisterToken was called
      verify(() => sessionRepository.getRegisterToken()).called(1);

      // Assert AuthRepository.register was called
      verify(() => authRepository.register(any())).called(1);

      // Assert token clearing methods were never called
      verifyNever(() => sessionRepository.clearRegisterToken());
      verifyNever(() => sessionRepository.setAuthToken(any()));
    },
  );

  test(
    "when setAuthToken throws exception then it should return Error",
    () async {
      // Hook SessionRepository.getRegisterToken to return a valid token
      when(
        () => sessionRepository.getRegisterToken(),
      ).thenReturn("test-register-token-123");

      // Hook AuthRepository.register to return Success with session token
      when(
        () => authRepository.register(any()),
      ).thenAnswer((_) async => const Result.success("test-session-token-456"));

      // Hook SessionRepository.clearRegisterToken
      when(() => sessionRepository.clearRegisterToken()).thenAnswer((_) {});

      // Hook SessionRepository.setAuthToken to throw exception
      when(
        () => sessionRepository.setAuthToken(any()),
      ).thenThrow(Exception("Storage error"));

      // Execute action
      final result = await registerAction.execute(
        nome: "John Doe",
        cpf: "12345678900",
        dataNascimento: DateTime(1990, 1, 15),
        telefone: "11999999999",
      );

      // Assert result is Error
      expect(result.isError(), true);
      expect(
        result.tryGetError()!.toString(),
        contains('Ocorreu um erro desconhecido durante o processo de registro'),
      );

      // Assert methods were called in order until exception
      verify(() => sessionRepository.getRegisterToken()).called(1);
      verify(() => authRepository.register(any())).called(1);
      verify(() => sessionRepository.clearRegisterToken()).called(1);
      verify(() => sessionRepository.setAuthToken(any())).called(1);
    },
  );

  test(
    "when clearRegisterToken throws exception then it should return Error",
    () async {
      // Hook SessionRepository.getRegisterToken to return a valid token
      when(
        () => sessionRepository.getRegisterToken(),
      ).thenReturn("test-register-token-123");

      // Hook AuthRepository.register to return Success with session token
      when(
        () => authRepository.register(any()),
      ).thenAnswer((_) async => const Result.success("test-session-token-456"));

      // Hook SessionRepository.clearRegisterToken to throw exception
      when(
        () => sessionRepository.clearRegisterToken(),
      ).thenThrow(Exception("Clear token failed"));

      // Hook SessionRepository.setAuthToken to detect if it's called
      when(
        () => sessionRepository.setAuthToken(any()),
      ).thenAnswer((_) async => const Result.success(null));

      // Execute action
      final result = await registerAction.execute(
        nome: "John Doe",
        cpf: "12345678900",
        dataNascimento: DateTime(1990, 1, 15),
        telefone: "11999999999",
      );

      // Assert result is Error
      expect(result.isError(), true);
      expect(
        result.tryGetError()!.toString(),
        contains('Ocorreu um erro desconhecido durante o processo de registro'),
      );

      // Assert methods were called in order until exception
      verify(() => sessionRepository.getRegisterToken()).called(1);
      verify(() => authRepository.register(any())).called(1);
      verify(() => sessionRepository.clearRegisterToken()).called(1);

      // Assert setAuthToken was never called due to exception
      verifyNever(() => sessionRepository.setAuthToken(any()));
    },
  );

  test(
    "when AuthRepository.register throws exception then it should return Error",
    () async {
      // Hook SessionRepository.getRegisterToken to return a valid token
      when(
        () => sessionRepository.getRegisterToken(),
      ).thenReturn("test-register-token-123");

      // Hook AuthRepository.register to throw exception
      when(
        () => authRepository.register(any()),
      ).thenThrow(Exception("Network error"));

      // Hook SessionRepository methods to detect if they're called
      when(() => sessionRepository.clearRegisterToken()).thenAnswer((_) {});
      when(
        () => sessionRepository.setAuthToken(any()),
      ).thenAnswer((_) async => const Result.success(null));

      // Execute action
      final result = await registerAction.execute(
        nome: "John Doe",
        cpf: "12345678900",
        dataNascimento: DateTime(1990, 1, 15),
        telefone: "11999999999",
      );

      // Assert result is Error
      expect(result.isError(), true);
      expect(
        result.tryGetError()!.toString(),
        contains('Ocorreu um erro desconhecido durante o processo de registro'),
      );

      // Assert SessionRepository.getRegisterToken was called
      verify(() => sessionRepository.getRegisterToken()).called(1);

      // Assert AuthRepository.register was called
      verify(() => authRepository.register(any())).called(1);

      // Assert token management methods were never called
      verifyNever(() => sessionRepository.clearRegisterToken());
      verifyNever(() => sessionRepository.setAuthToken(any()));
    },
  );
}
