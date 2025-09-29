import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_api_response.freezed.dart';
part 'login_api_response.g.dart';

@freezed
abstract class LoginApiResponse with _$LoginApiResponse {
  const factory LoginApiResponse({
    /// Indicates if user has completed registration
    required bool isRegistered,

    /// Session token for authenticated users (only when isRegistered = true)
    required String? sessionToken,

    /// Register token for users who need to complete registration (only when isRegistered = false)
    required String? registerToken,
  }) = _LoginApiResponse;

  factory LoginApiResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginApiResponseFromJson(json);
}
