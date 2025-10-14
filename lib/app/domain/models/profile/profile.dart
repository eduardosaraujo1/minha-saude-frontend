import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';

@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    required String id,
    required String email,
    required String cpf,
    required String nome,
    required String telefone,
    required DateTime dataNascimento,
    required AuthMethod metodoAutenticacao,
  }) = _Profile;
}

enum AuthMethod { google, email }
