import 'package:minha_saude_frontend/app/data/services/api/fakes/fake_server_persistent_storage.dart';
import 'package:multiple_result/multiple_result.dart';

import 'models/login_response/login_api_response.dart';
import 'models/register_response/register_response.dart';
import 'auth_api_client.dart';

class FakeAuthApiClient implements AuthApiClient {
  FakeAuthApiClient({required this.fakePersistentStorage});

  final FakeServerPersistentStorage fakePersistentStorage;

  @override
  Future<Result<LoginApiResponse, Exception>> authLoginGoogle(
    String tokenOauth,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (await fakePersistentStorage.getRegistered()) {
      return Result.success(
        LoginApiResponse(
          isRegistered: true,
          sessionToken: 'fake_session_token',
          registerToken: null,
        ),
      );
    } else {
      return Result.success(
        LoginApiResponse(
          isRegistered: false,
          sessionToken: null,
          registerToken: 'fake_register_token',
        ),
      );
    }
  }

  @override
  Future<Result<RegisterResponse, Exception>> authRegister({
    required String nome,
    required String cpf,
    required DateTime dataNascimento,
    required String telefone,
    required String registerToken,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));

    // Create a new user with the registration data
    final newUser = FakeRegisterModel(
      id: 'fake_user_id_${DateTime.now().millisecondsSinceEpoch}',
      email:
          'eduardosaraujo100@gmail.com', // In a real scenario, this would come from the token
      cpf: cpf,
      nome: nome,
      telefone: telefone,
      dataNascimento: dataNascimento,
      metodoAutenticacao: InternalAuthMethod
          .email, // Default to email, could be determined from token
    );

    await fakePersistentStorage.setUser(newUser);

    return Result.success(
      RegisterResponse(status: 'success', sessionToken: 'fake_session_token'),
    );
  }

  @override
  Future<Result<void, Exception>> authLogout() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return Result.success(null);
  }

  @override
  Future<Result<String, Exception>> authSendEmail(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    return Result.success("success");
  }

  @override
  Future<Result<LoginApiResponse, Exception>> authLoginEmail(
    String email,
    String code,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (await fakePersistentStorage.getRegistered()) {
      return Result.success(
        LoginApiResponse(
          isRegistered: true,
          sessionToken: 'fake_session_token',
          registerToken: null,
        ),
      );
    } else {
      return Result.success(
        LoginApiResponse(
          isRegistered: false,
          registerToken: 'fake_register_token',
        ),
      );
    }
  }
}
