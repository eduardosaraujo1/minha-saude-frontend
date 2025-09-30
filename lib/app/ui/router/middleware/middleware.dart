import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

typedef NextFunction = Future<String?> Function();

abstract class Middleware {
  Future<String?> handle(
    BuildContext context,
    GoRouterState state,
    NextFunction next,
  );
}
