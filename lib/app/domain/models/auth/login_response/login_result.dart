import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../data/services/api/deprecating/auth/models/login_response/login_api_response.dart';

part 'login_result.freezed.dart';
part 'login_result.g.dart';

@freezed
sealed class LoginResult with _$LoginResult {
  const factory LoginResult.successful({required String sessionToken}) =
      SuccessfulLoginResult;

  const factory LoginResult.needsRegistration({required String registerToken}) =
      NeedsRegistrationLoginResult;

  /// Create polymorphic LoginResult from an APIResponse
  /// Throws Exception if the ApiResponse is in an invalid state (says user isRegistered but did not provide valid sessionToken)
  factory LoginResult.fromApi(LoginApiResponse response) {
    if (response.isRegistered) {
      if (response.sessionToken != null && response.sessionToken!.isNotEmpty) {
        return LoginResult.successful(sessionToken: response.sessionToken!);
      }
    } else {
      if (response.registerToken != null &&
          response.registerToken!.isNotEmpty) {
        return LoginResult.needsRegistration(
          registerToken: response.registerToken!,
        );
      }
    }
    throw Exception("LoginApiResponse returned an invalid response object");
  }

  factory LoginResult.fromJson(Map<String, dynamic> json) =>
      _$LoginResultFromJson(json);
}
