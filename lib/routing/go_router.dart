import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Routes {
  static const String documents = 'documents';
  static const String login = 'login';
  static const String tos = 'tos';
  static const String profile = 'profile';
  // Add more routes as needed
}

class RouterFactory {
  static RouterConfig<Object> create() {
    return GoRouter(
      initialLocation: Routes.documents,
      routes: <RouteBase>[
        GoRoute(
          name: 'documents',
          path: '/documents',
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(title: Text('Documents')),
              body: Center(child: Text('Documents Page')),
            );
          },
        ),
      ],
    );
  }
}
