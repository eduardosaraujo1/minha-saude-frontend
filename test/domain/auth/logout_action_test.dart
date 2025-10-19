import 'package:minha_saude_frontend/app/data/repositories/auth/auth_repository.dart';
import 'package:minha_saude_frontend/app/data/repositories/document/document_repository.dart';
import 'package:minha_saude_frontend/app/data/repositories/profile/profile_repository.dart';
import 'package:minha_saude_frontend/app/data/repositories/session/session_repository.dart';
import 'package:minha_saude_frontend/app/domain/actions/auth/logout_action.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:test/test.dart';

import '../../../testing/mocks/repositories/mock_auth_repository.dart';
import '../../../testing/mocks/repositories/mock_document_repository.dart';
import '../../../testing/mocks/repositories/mock_profile_repository.dart';
import '../../../testing/mocks/repositories/mock_session_repository.dart';

void main() {
  late AuthRepository authRepository;
  late DocumentRepository documentRepository;
  late SessionRepository sessionRepository;
  late ProfileRepository profileRepository;
  late LogoutAction logoutAction;

  setUp(() {
    authRepository = MockAuthRepository();
    documentRepository = MockDocumentRepository();
    sessionRepository = MockSessionRepository();
    profileRepository = MockProfileRepository();
    logoutAction = LogoutAction(
      documentRepository: documentRepository,
      authRepository: authRepository,
      sessionRepository: sessionRepository,
      profileRepository: profileRepository,
    );
  });

  test(
    "when logout is called successfully then it should call logout on auth, clear auth token and reset cache",
    () async {
      // Hook AuthRepository.logout to complete successfully
      when(() => authRepository.logout()).thenAnswer((_) async {});
      when(() => profileRepository.clearCache()).thenAnswer((_) async {});

      // Hook SessionRepository.clearAuthToken to return Success
      when(
        () => sessionRepository.clearAuthToken(),
      ).thenAnswer((_) async => const Result.success(null));

      // Hook DocumentRepository.resetCache to complete successfully
      when(() => documentRepository.clearCache()).thenAnswer((_) async {});

      // Execute action
      final result = await logoutAction.execute();

      // Assert result is Success
      expect(result.isSuccess(), true);

      // Assert all repository methods were called in correct order
      verify(() => authRepository.logout()).called(1);
      verify(() => sessionRepository.clearAuthToken()).called(1);
      verify(() => documentRepository.clearCache()).called(1);
    },
  );

  test(
    "when authRepository.logout throws exception then it should return Error",
    () async {
      // Hook AuthRepository.logout to throw exception
      when(() => authRepository.logout()).thenThrow(Exception("Network error"));

      // Hook other methods to detect if they're called
      when(
        () => sessionRepository.clearAuthToken(),
      ).thenAnswer((_) async => const Result.success(null));
      when(() => documentRepository.clearCache()).thenAnswer((_) async {});

      // Execute action
      final result = await logoutAction.execute();

      // Assert result is Error
      expect(result.isError(), true);
      expect(
        result.tryGetError()!.toString(),
        contains('Ocorreu um erro desconhecido ao tentar fazer logout'),
      );

      // Assert authRepository.logout was called
      verify(() => authRepository.logout()).called(1);

      // Assert other methods were not called due to exception
      verifyNever(() => sessionRepository.clearAuthToken());
      verifyNever(() => documentRepository.clearCache());
    },
  );

  test(
    "when sessionRepository.clearAuthToken throws exception then it should return Error",
    () async {
      // Hook AuthRepository.logout to complete successfully
      when(() => authRepository.logout()).thenAnswer((_) async {});

      // Hook SessionRepository.clearAuthToken to throw exception
      when(
        () => sessionRepository.clearAuthToken(),
      ).thenThrow(Exception("Storage error"));

      // Hook DocumentRepository to detect if it's called
      when(() => documentRepository.clearCache()).thenAnswer((_) async {});

      // Execute action
      final result = await logoutAction.execute();

      // Assert result is Error
      expect(result.isError(), true);
      expect(
        result.tryGetError()!.toString(),
        contains('Ocorreu um erro desconhecido ao tentar fazer logout'),
      );

      // Assert methods were called in order until exception
      verify(() => authRepository.logout()).called(1);
      verify(() => sessionRepository.clearAuthToken()).called(1);

      // Assert resetCache was not called due to exception
      verifyNever(() => documentRepository.clearCache());
    },
  );

  test(
    "when documentRepository.resetCache throws exception then it should return Error",
    () async {
      // Hook AuthRepository.logout to complete successfully
      when(() => authRepository.logout()).thenAnswer((_) async {});

      // Hook SessionRepository.clearAuthToken to return Success
      when(
        () => sessionRepository.clearAuthToken(),
      ).thenAnswer((_) async => const Result.success(null));

      // Hook DocumentRepository.resetCache to throw exception
      when(
        () => documentRepository.clearCache(),
      ).thenThrow(Exception("Database error"));

      // Execute action
      final result = await logoutAction.execute();

      // Assert result is Error
      expect(result.isError(), true);
      expect(
        result.tryGetError()!.toString(),
        contains('Ocorreu um erro desconhecido ao tentar fazer logout'),
      );

      // Assert all methods were called
      verify(() => authRepository.logout()).called(1);
      verify(() => sessionRepository.clearAuthToken()).called(1);
      verify(() => documentRepository.clearCache()).called(1);
    },
  );
}
