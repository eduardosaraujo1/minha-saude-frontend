## 🧭 Context

You currently have:

```
ApiGateway → ApiClient → Repository → [Action] → ViewModel → View
```

But the **ApiClient** layer only parsed JSON and produced DTOs — a thin pass-through that didn’t justify its existence.
By moving JSON parsing and error translation into the **Repository**, you:

-   Remove one abstraction.
-   Keep type safety.
-   Localize error interpretation (since _only the domain knows what “INCORRECT_CODE” means_).
-   Keep networking concerns inside ApiGateway, not business logic.

---

## 🧩 New structure

```
ApiGateway → Repository → [Action] → ViewModel → View
```

---

## 🧱 Responsibilities (final version)

| Layer          | Responsibilities                                                                                                                                                           | Returns                                                       |
| -------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------- |
| **ApiGateway** | Perform raw HTTP requests. Handle low-level things (timeouts, auth headers, refresh token, etc.). Converts _transport-level_ errors into `Result<ApiResponse, Exception>`. | `Result<ApiResponse, Exception>`                              |
| **Repository** | Interpret the API result. If `Result` is success → decode JSON → map to domain model.<br> If it’s error or non-2xx → create domain-specific error.                         | `Result<DomainModel, DomainError>`                            |
| **[Action]**   | Optional orchestrator for multi-repository use cases or complex flows.                                                                                                     | `Result` or void                                              |
| **ViewModel**  | Holds state, triggers repository methods, exposes UI-ready data.                                                                                                           | State (e.g. `ValueNotifier<Result<LoginResult, LoginError>>`) |
| **View**       | Reacts to state. Stateless except for animations.                                                                                                                          | UI                                                            |

---

## ⚙️ Refactor plan — step-by-step explanation

Here’s the coherent explanation for the IDE (or AI) to generate/refactor code accordingly.

---

### Step 1. Change `ApiGateway` to return `Result<ApiResponse, Exception>`

**Old:**

```dart
Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body});
```

**New:**

```dart
class ApiResponse {
  final int statusCode;
  final String rawBody;
  final Map<String, dynamic>? json;

  ApiResponse(this.statusCode, this.rawBody, [this.json]);
}

Future<Result<ApiResponse, Exception>> post(
  String path, {
  Map<String, dynamic>? body,
});
```

**Responsibilities:**

-   Send HTTP request.
-   If successful, return `Result.success(ApiResponse(...))`.
-   If timeout, no internet, etc. → return `Result.failure(Exception(e))`.
-   Optionally decode the JSON inside ApiGateway if it’s trivial, otherwise let Repository do it.

---

### Step 2. Remove `ApiClient` layer

All feature-specific parsing and mapping logic moves into the repository.
Example: `AuthApiClient.login()` becomes `AuthRepository.login()`.

---

### Step 3. Rework the Repository to interpret API responses

Example for `AuthRepository`:

```dart
class AuthRepository {
  final ApiGateway _api;

  AuthRepository(this._api);

  Future<Result<LoginResult, LoginError>> login(String email, String code) async {
    final gatewayResult = await _api.post('/auth/login', body: {
      'email': email,
      'code': code,
    });

    return switch (gatewayResult) {
      // network-level errors (timeouts, connectivity)
      Failure(:final error) => Failure(LoginError.network(error)),
      Success(:final response) => _parseLoginResponse(response),
    };
  }

  Result<LoginResult, LoginError> _parseLoginResponse(ApiResponse res) {
    // Step 1: check HTTP status
    if (res.statusCode < 200 || res.statusCode >= 300) {
      // Step 2: extract machine-readable message (Laravel uses "message")
      final msg = res.json?['message'] ?? 'Unknown error';
      final code = _mapErrorCode(msg);
      return Failure(LoginError.api(code));
    }

    // Step 3: parse success JSON
    try {
      final dto = LoginResponseDto.fromJson(res.json!);
      final result = dto.toDomain();
      return Success(result);
    } catch (e) {
      return Failure(LoginError.parsing(e));
    }
  }

  LoginErrorCode _mapErrorCode(String message) {
    switch (message) {
      case 'INCORRECT_CODE':
        return LoginErrorCode.incorrectCode;
      case 'UNAUTHORIZED':
        return LoginErrorCode.unauthorized;
      default:
        return LoginErrorCode.unknown;
    }
  }
}
```

---

### Step 4. Define clear domain-level types

```dart
enum LoginErrorCode { incorrectCode, unauthorized, network, parsing, unknown }

class LoginError {
  final LoginErrorCode type;
  final Exception? cause;

  LoginError.api(this.type) : cause = null;
  LoginError.network(this.cause) : type = LoginErrorCode.network;
  LoginError.parsing(this.cause) : type = LoginErrorCode.parsing;
}
```

```dart
sealed class LoginResult {
  const LoginResult();
}

class LoggedIn extends LoginResult {
  final String sessionToken;
  const LoggedIn(this.sessionToken);
}

class RequiresRegistration extends LoginResult {
  final String registerToken;
  const RequiresRegistration(this.registerToken);
}
```

---

### Step 5. (Optional) Use small helper in ViewModel

```dart
final result = await _authRepository.login(email, code);

switch (result) {
  case Success(:final value):
    if (value is LoggedIn) goToHome();
    else if (value is RequiresRegistration) goToRegister();
    break;

  case Failure(:final error):
    if (error.type == LoginErrorCode.incorrectCode) showSnackbar('Código incorreto');
    else showSnackbar('Erro desconhecido');
}
```

---

## 🧠 Summary of design philosophy

| Principle                       | How it’s satisfied                                                                           |
| ------------------------------- | -------------------------------------------------------------------------------------------- |
| **YAGNI**                       | You removed `ApiClient`, keeping only the logic that serves a purpose.                       |
| **SRP (Single Responsibility)** | ApiGateway = transport; Repository = interpretation + domain; ViewModel = state.             |
| **Resilience to change**        | You can swap HTTP client, API format, or backend framework without touching the domain/UI.   |
| **Debuggability**               | `ApiResponse` preserves the raw body and status for logging; errors are typed and traceable. |
