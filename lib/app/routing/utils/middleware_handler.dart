import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../middleware/middleware.dart';

class MiddlewareHandler {
  const MiddlewareHandler(this._middlewares);

  final List<Middleware> _middlewares;

  Future<String?> run(BuildContext context, GoRouterState state) async {
    return _runMiddleware(context, state, 0);
  }

  Future<String?> _runMiddleware(
    BuildContext context,
    GoRouterState state,
    int index,
  ) async {
    // If we've processed all middleware, return null (no redirection)
    if (index >= _middlewares.length) {
      return null;
    }

    final middleware = _middlewares[index];

    // Create the next function that calls the next middleware in the chain
    Future<String?> next() async {
      return _runMiddleware(context, state, index + 1);
    }

    // Execute the current middleware
    return middleware.handle(context, state, next);
  }
}
