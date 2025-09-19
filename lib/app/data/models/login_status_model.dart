sealed class AuthStatus {
  get isSuccess => this is AuthSuccessStatus;
}

class AuthSuccessStatus extends AuthStatus {
  final String sessionToken;

  AuthSuccessStatus(this.sessionToken);
}

class AuthRegisterStatus extends AuthStatus {
  final String registerToken;

  AuthRegisterStatus(this.registerToken);
}
