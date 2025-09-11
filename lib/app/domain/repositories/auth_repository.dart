import 'package:minha_saude_frontend/app/data/auth/models/login_response.dart';
import 'package:minha_saude_frontend/app/data/auth/models/register_response.dart';
import 'package:minha_saude_frontend/app/data/auth/models/user.dart';
import 'package:multiple_result/multiple_result.dart';

/// Interface for authentication repository
/// Organized by CRUD operations:
/// - Create: login operations
/// - Read: get token, check login status
/// - Update: refresh token operations (future)
/// - Delete: logout operations
abstract class AuthRepository {
  // =============================================================================
  // CREATE OPERATIONS (Login/Authentication)
  // =============================================================================

  /// Login with Google OAuth and obtain session token
  /// Returns LoginResponse with session token and registration status
  Future<Result<LoginResponse, Exception>> loginWithGoogle();

  /// Register a new user with provided data
  /// Note: Registration doesn't automatically log the user in
  Future<Result<RegisterResponse, Exception>> registerWithGoogle(User userData);

  // =============================================================================
  // READ OPERATIONS (Token retrieval and status checks)
  // =============================================================================

  /// Get the current session token from local storage
  /// Returns null if no token is stored
  Future<Result<String?, Exception>> getLocalToken();

  /// Get the cached session token synchronously
  /// Returns null if no token is cached or not yet loaded
  String? getCachedToken();

  /// Check if user is currently logged in (has valid session)
  /// This is a fast synchronous check using cached token
  bool isLoggedIn();

  /// Check if user is logged in with async verification
  /// Useful for initial app startup when cache might not be loaded
  Future<bool> isLoggedInAsync();

  // =============================================================================
  // UPDATE OPERATIONS (Token refresh - future implementation)
  // =============================================================================

  // Future methods for token refresh when backend supports it:
  // Future<Result<String, Exception>> refreshToken();

  // =============================================================================
  // DELETE OPERATIONS (Logout/Session cleanup)
  // =============================================================================

  /// Logout user - clears local session and notifies server
  /// Always succeeds locally even if server logout fails
  Future<Result<void, Exception>> logout();

  /// Clear only local session data (without server notification)
  /// Useful for emergency logout or when server is unreachable
  Future<Result<void, Exception>> clearLocalSession();
}
