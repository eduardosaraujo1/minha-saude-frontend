import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RouterFactory {
  static RouterConfig<Object> create() {
    return GoRouter(
      initialLocation: '/documents',
      routes: <RouteBase>[
        GoRoute(
          name:
              'documents', // use notation 'resource.action', i.e. 'documents.edit'
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
