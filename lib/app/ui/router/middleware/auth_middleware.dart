import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/auth/auth_repository.dart';
import '../routes.dart';
import 'middleware.dart';

class AuthMiddleware implements Middleware {
  const AuthMiddleware(this._authRoutes, this._authRepository);

  final List<String> _authRoutes;
  final AuthRepository _authRepository;

  @override
  Future<String?> handle(
    BuildContext context,
    GoRouterState state,
    NextFunction next,
  ) async {
    // Check authentication state
    final hasSessionToken = await _authRepository.hasAuthToken();
    final hasRegisterToken = _authRepository.getRegisterToken() != null;
    final isOnAuthRoute = _authRoutes.contains(state.fullPath);

    // Early return: User is not authenticated and trying to access protected route
    if (!hasSessionToken && !isOnAuthRoute) {
      // User has a valid registration token, redirect to register
      if (hasRegisterToken) {
        return Routes.register;
      }
      // No valid tokens, redirect to login
      return Routes.login;
    }

    // Early return: User is authenticated and trying to access auth route
    if (hasSessionToken && isOnAuthRoute) {
      return Routes.home;
    }

    // No authentication-related redirection needed, continue to next middleware
    return next();
  }
}
