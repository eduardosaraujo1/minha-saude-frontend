class RegisterDto {
  // {status,session_token?,expires_at}
  final RegisterStatus status;
  final String? sessionToken;
  final DateTime? expiresAt;

  RegisterDto({required this.status, this.sessionToken, this.expiresAt});

  factory RegisterDto.fromJson(Map<String, dynamic> json) {
    return RegisterDto(
      status: _stringToEnum(json['status'] as String),
      sessionToken: json['session_token'] as String?,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': _enumToString(status),
      'session_token': sessionToken,
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  static String _enumToString(RegisterStatus statusEnum) {
    return statusEnum.toString().split('.').last;
  }

  static RegisterStatus _stringToEnum(String statusString) {
    return RegisterStatus.values.firstWhere(
      (e) => e.toString().split('.').last == statusString,
      orElse: () => RegisterStatus.failure,
    );
  }
}

enum RegisterStatus { success, failure }
