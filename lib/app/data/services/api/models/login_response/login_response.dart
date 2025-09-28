import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_response.freezed.dart';
part 'login_response.g.dart';

@freezed
abstract class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    /// Indicates if user has completed registration
    required bool isRegistered,

    /// Session token for authenticated users (only when isRegistered = true)
    required String? sessionToken,

    /// Register token for users who need to complete registration (only when isRegistered = false)
    required String? registerToken,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}
