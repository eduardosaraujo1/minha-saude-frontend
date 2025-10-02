import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:minha_saude_frontend/app/data/services/api/models/login_response/login_api_response.dart';

part 'login_response.freezed.dart';
part 'login_response.g.dart';

@freezed
abstract class LoginResponse with _$LoginResponse {
  const factory LoginResponse.successful({required String sessionToken}) =
      SuccessfulLoginResponse;

  const factory LoginResponse.needsRegistration({
    required String registerToken,
  }) = NeedsRegistrationLoginResponse;

  /// Create polymorphic LoginResponse from an APIResponse
  /// Throws Exception if the ApiResponse is in an invalid state (says user isRegistered but did not provide valid sessionToken)
  factory LoginResponse.fromApi(LoginApiResponse response) {
    if (response.isRegistered) {
      if (response.sessionToken != null && response.sessionToken!.isNotEmpty) {
        return LoginResponse.successful(sessionToken: response.sessionToken!);
      }
    } else {
      if (response.registerToken != null &&
          response.registerToken!.isNotEmpty) {
        return LoginResponse.needsRegistration(
          registerToken: response.registerToken!,
        );
      }
    }
    throw Exception("LoginApiResponse returned an invalid response object");
  }

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}
