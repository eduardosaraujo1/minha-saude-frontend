import 'package:multiple_result/multiple_result.dart';

import 'models/profile_api_model.dart';

abstract class ProfileApiClient {
  /// Obtém o perfil do usuário.
  ///
  /// Retorna um [Result] contendo o [ProfileApiModel] em caso de sucesso ou [Exception] em caso de erro.
  Future<Result<ProfileApiModel, Exception>> getProfile();

  /// Atualiza o nome do usuário no perfil.
  ///
  /// Parâmetros:
  /// - [name]: O novo nome a ser atualizado.
  ///
  /// Retorna um [Result] contendo void em caso de sucesso ou [Exception] em caso de erro.
  Future<Result<void, Exception>> updateName(String name);

  /// Atualiza a data de nascimento do usuário no perfil.
  ///
  /// Parâmetros:
  /// - [birthDate]: A nova data de nascimento a ser atualizada.
  ///
  /// Retorna um [Result] contendo void em caso de sucesso ou [Exception] em caso de erro.
  Future<Result<void, Exception>> updateBirthdate(DateTime birthDate);

  /// Atualiza o número de telefone do usuário no perfil.
  /// Este método envia um código SMS para verificação.
  ///
  /// Parâmetros:
  /// - [phone]: O novo número de telefone a ser atualizado.
  ///
  /// Retorna um [Result] contendo void em caso de sucesso ou [Exception] em caso de erro.
  Future<Result<void, Exception>> updatePhone(String phone);

  /// Verifica o código SMS enviado para o telefone do usuário.
  ///
  /// Parâmetros:
  /// - [code]: O código de verificação recebido via SMS.
  ///
  /// Retorna um [Result] contendo void em caso de sucesso ou [Exception] em caso de erro.
  Future<Result<void, Exception>> verifyPhoneCode(String code);

  /// Solicita o envio de um código de verificação via SMS para o telefone informado.
  ///
  /// Parâmetros:
  /// - [phone]: O número de telefone que receberá o código de verificação.
  ///
  /// Retorna um [Result] contendo void em caso de sucesso ou [Exception] em caso de erro.

  Future<Result<void, Exception>> requestPhoneVerificationCode(String phone);

  /// Vincula uma conta do Google ao perfil do usuário.
  ///
  /// Parâmetros:
  /// - [tokenOauth]: O token OAuth da conta Google a ser vinculada.
  ///
  /// Retorna um [Result] contendo void em caso de sucesso ou [Exception] em caso de erro.
  Future<Result<void, Exception>> linkGoogleAccount(String tokenOauth);

  /// Agenda a exclusão permanente da conta do usuário.
  ///
  /// Retorna um [Result] contendo void em caso de sucesso ou [Exception] em caso de erro.
  Future<Result<void, Exception>> deleteAccount();
}
