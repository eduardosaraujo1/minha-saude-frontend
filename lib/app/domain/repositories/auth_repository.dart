import 'package:minha_saude_frontend/app/data/auth/models/login_response.dart';
import 'package:minha_saude_frontend/app/data/auth/models/register_response.dart';
import 'package:minha_saude_frontend/app/data/auth/models/user.dart';
import 'package:multiple_result/multiple_result.dart';

/// Interface for authentication repository
/// New architecture organized by CRUD operations:
/// - Create: googleLogin, googleRegister
/// - Read: getToken, isRegistered
/// - Delete: signOut
abstract class IAuthRepository {
  // =============================================================================
  // CREATE OPERATIONS (Login/Authentication)
  // =============================================================================

  /// Login with Google OAuth and obtain session token
  /// Automatically stores token in SecureStorage and updates cache
  Future<Result<LoginResponse, Exception>> googleLogin();

  /// Register a new user
  /// Automatically updates registration status in cache
  Future<Result<RegisterResponse, Exception>> register(User userData);

  // =============================================================================
  // READ OPERATIONS (Token retrieval and status checks)
  // =============================================================================

  /// Get the current session token from cache
  /// Fast synchronous access to token
  String? get authToken;

  /// Check if user is registered
  /// Used by router to decide between login, register, or home screen
  /// Available in cache and remote, but not in storage
  bool get isRegistered;

  // =============================================================================
  // DELETE OPERATIONS (Logout/Session cleanup)
  // =============================================================================

  /// Sign out user - clears cache, storage and notifies server
  /// Always succeeds locally even if server logout fails
  Future<Result<void, Exception>> signOut();
}
