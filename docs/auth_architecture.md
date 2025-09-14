# Authentication Architecture Implementation

This document explains the authentication architecture that has been implemented in your Flutter project.

## Architecture Overview

The authentication system follows a clean architecture pattern with clear separation of concerns:

### Shared Layer

-   **`Session`** (`shared/utils/session.dart`): Manages authentication state and secure token storage
-   **`Gateway`** (`shared/network/gateway.dart`): Handles all HTTP requests with automatic auth headers
-   **`Auth`** (`shared/utils/auth_helper.dart`): Laravel-style helper for global authentication access

### Auth Feature

-   **Data Layer**: Google authentication and API communication
-   **Domain Layer**: Business logic use cases (login, register, logout)
-   **Presentation Layer**: ViewModels that orchestrate the authentication flows

## Key Components

### 1. Session Management (`shared/utils/session.dart`)

```dart
// Initialize session on app startup
await Session().initialize();

// Check authentication state
if (Session().isAuthenticated) {
  print('User is logged in');
}

// Store authentication data
await Session().set(
  token: 'sanctum_token',
  user: {'id': 1, 'name': 'John', 'email': 'john@example.com'},
);

// Clear session (logout)
await Session().clear();
```

### 2. Laravel-style Auth Helper (`shared/utils/auth_helper.dart`)

```dart
// Check if user is authenticated
if (Auth.check()) {
  print('User is authenticated');
}

// Get user data
final user = Auth.user();
final userName = session().getUserName();

// Logout
await Auth.logout();
```

### 3. Gateway for API Calls (`shared/network/gateway.dart`)

```dart
final gateway = Gateway();

// Automatically includes auth headers if user is authenticated
final response = await gateway.get('/api/profile');
final response = await gateway.post('/api/data', body: {'key': 'value'});
```

## Authentication Flow

### Login Flow

1. User clicks "Sign in with Google"
2. `LoginViewModel` calls `LoginWithGoogle` use case
3. `GoogleAuthRepository` handles Google sign-in
4. `AuthRemoteDataSource` exchanges Google token for Laravel Sanctum token
5. `Session` stores the token and user data
6. App navigates to home screen

### Registration Flow

1. User signs in with Google but is not registered
2. App redirects to registration screen with Google data
3. User fills additional information (CPF, phone, etc.)
4. `RegisterWithGoogle` use case sends all data to backend
5. Backend creates user and returns Sanctum token
6. `Session` stores the token and user data

### Logout Flow

1. User triggers logout
2. `Logout` use case optionally notifies backend
3. `Session.clear()` removes all local authentication data
4. App redirects to login screen

## Usage Examples

### In a ViewModel

```dart
class ProfileViewModel extends ChangeNotifier {
  void loadProfile() {
    if (Auth.check()) {
      final userId = Auth.user()?['id'];
      // Load profile data
    }
  }
}
```

### In a Widget

```dart
class AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(Auth.check()
        ? 'Welcome, ${session().getUserName()}'
        : 'Please log in'
      ),
      actions: [
        if (Auth.check())
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await Auth.logout();
              context.go('/login');
            },
          ),
      ],
    );
  }
}
```

### In Navigation Guards

```dart
class AuthGuard {
  static bool canAccess(String route) {
    final publicRoutes = ['/login', '/register', '/terms'];

    if (publicRoutes.contains(route)) {
      return true;
    }

    return Auth.check();
  }
}
```

## Configuration

### 1. Google Sign In

Update `google_auth.dart` to include your actual Google Sign In configuration:

```dart
GoogleAuthRepository() {
  _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: 'your-server-client-id.googleusercontent.com',
  );
}
```

### 2. API Base URL

Update `gateway.dart` with your actual API URL:

```dart
static const String baseUrl = 'https://your-api-url.com/api';
```

### 3. Backend Endpoints

The system expects these endpoints on your Laravel backend:

-   `POST /auth/google/login` - Exchange Google token for Sanctum token
-   `POST /auth/google/register` - Register new user with Google + additional data
-   `POST /auth/logout` - Revoke Sanctum token
-   `GET /auth/user` - Get current user profile

## Dependency Injection

All dependencies are wired in `features/auth/provider.dart`:

```dart
void init() {
  final getIt = GetIt.I;

  // Shared services
  getIt.registerLazySingleton<Session>(() => Session());
  getIt.registerLazySingleton<Gateway>(() => Gateway());

  // Data layer
  getIt.registerLazySingleton<GoogleAuthRepository>(() => GoogleAuthRepository());
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(getIt<Gateway>()),
  );

  // Domain layer
  getIt.registerLazySingleton<LoginWithGoogle>(() => LoginWithGoogle(
    getIt<GoogleAuthRepository>(),
    getIt<AuthRemoteDataSource>(),
    getIt<Session>(),
  ));

  // ViewModels
  getIt.registerFactory<LoginViewModel>(
    () => LoginViewModel(getIt<LoginWithGoogle>()),
  );
}
```

## App Initialization

Wrap your main app with `AppInitializer` to ensure session is loaded on startup:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();

  runApp(
    AppInitializer(
      child: MyApp(),
    ),
  );
}
```

This architecture provides a clean, testable, and maintainable authentication system that can easily be extended for additional authentication methods (email/password, social providers, etc.).
