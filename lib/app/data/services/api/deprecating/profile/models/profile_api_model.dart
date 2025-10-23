import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_api_model.freezed.dart';
part 'profile_api_model.g.dart';

@freezed
abstract class ProfileApiModel with _$ProfileApiModel {
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ProfileApiModel({
    required String id,
    required String nome,
    required String cpf,
    required String email,
    required String telefone,
    required DateTime dataNascimento,
    required String metodoAutenticacao,
  }) = _ProfileApiModel;

  factory ProfileApiModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileApiModelFromJson(json);
}
