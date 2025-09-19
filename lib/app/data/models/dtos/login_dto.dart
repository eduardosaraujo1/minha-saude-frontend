class LoginDto {
  final bool isRegistered;
  final String? sessionToken;
  final String? registerToken;
  final DateTime? expiresAt;

  LoginDto({
    required this.isRegistered,
    this.sessionToken,
    this.registerToken,
    this.expiresAt,
  });

  factory LoginDto.fromJson(Map<String, dynamic> json) {
    return LoginDto(
      isRegistered: json['is_registered'] as bool,
      sessionToken: json['session_token'] as String?,
      registerToken: json['register_token'] as String?,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_registered': isRegistered,
      'session_token': sessionToken,
      'register_token': registerToken,
      'expires_at': expiresAt?.toIso8601String(),
    };
  }
}
