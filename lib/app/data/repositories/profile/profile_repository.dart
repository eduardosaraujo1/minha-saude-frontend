import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/domain/models/profile/profile.dart';
import 'package:multiple_result/multiple_result.dart';

abstract class ProfileRepository extends ChangeNotifier {
  /// Obtém o perfil do usuário.
  ///
  /// Retorna um [Result] contendo o [Profile] em caso de sucesso ou [Exception] em caso de erro.
  Future<Result<Profile, Exception>> getProfile({bool forceRefresh = false});

  // UPDATE
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

  /// Agenda a exclusão permanente da conta do usuário.
  /// É recomendado que o chamador da função faça logout após chamar este método.
  ///
  /// Retorna um [Result] contendo void em caso de sucesso ou [Exception] em caso de erro.
  Future<Result<void, Exception>> deleteAccount();

  /// Solicita o envio de um código de verificação via SMS para o telefone informado.
  ///
  /// Parâmetros:
  /// - [phone]: O número de telefone que receberá o código de verificação.
  ///
  /// Retorna um [Result] contendo void em caso de sucesso ou [Exception] em caso de erro.
  Future<Result<void, Exception>> requestPhoneVerificationCode(String phone);

  /// Verifica o código SMS enviado para o telefone do usuário.
  ///
  /// Parâmetros:
  /// - [code]: O código de verificação recebido via SMS.
  ///
  /// Retorna um [Result] contendo void em caso de sucesso ou [Exception] em caso de erro.
  Future<Result<void, Exception>> verifyPhoneCode(String code);

  /// Vincula uma conta do Google ao perfil do usuário.
  ///
  /// Parâmetros:
  /// - [tokenOauth]: O token OAuth da conta Google a ser vinculada.
  ///
  /// Retorna um [Result] contendo void em caso de sucesso ou [Exception] em caso de erro.
  Future<Result<void, Exception>> linkGoogleAccount(String tokenOauth);

  /// Solicita a exportação dos dados do usuário.
  /// Dados são enviados via e-mail dentro de 24 horas.
  ///
  /// Retorna um [Result] contendo void em caso de sucesso ou [Exception] em caso de erro.
  Future<Result<void, Exception>> requestDataExport();

  Future<void> clearCache();
}
