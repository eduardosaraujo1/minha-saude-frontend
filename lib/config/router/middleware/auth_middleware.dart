import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/app/data/repositories/auth/auth_repository.dart';
import 'package:minha_saude_frontend/config/di/service_locator.dart';
import 'package:minha_saude_frontend/config/router/middleware/middleware.dart';

class AuthMiddleware implements Middleware {
  const AuthMiddleware(this._authRoutes);

  final List<String> _authRoutes;

  @override
  Future<String?> handle(
    BuildContext context,
    GoRouterState state,
    NextFunction next,
  ) async {
    final authRepository = ServiceLocator.I<AuthRepository>();

    // Check authentication state
    final hasSessionToken = await authRepository.hasToken();
    final hasRegisterToken =
        authRepository.getRegisterToken().tryGetSuccess() != null;
    final isOnAuthRoute = _authRoutes.contains(state.fullPath);

    // Early return: User is not authenticated and trying to access protected route
    if (!hasSessionToken && !isOnAuthRoute) {
      // User has a valid registration token, redirect to register
      if (hasRegisterToken) {
        return '/register';
      }
      // No valid tokens, redirect to login
      return '/login';
    }

    // Early return: User is authenticated and trying to access auth route
    if (hasSessionToken && isOnAuthRoute) {
      return '/';
    }

    // No authentication-related redirection needed, continue to next middleware
    return next();
  }
}
