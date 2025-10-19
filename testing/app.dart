import 'package:flutter/material.dart';

import 'mocks/mock_go_router.dart';

Widget testApp(Scaffold child, {MockGoRouter? mockGoRouter}) {
  return MaterialApp(
    home: mockGoRouter == null
        ? child
        : MockGoRouterProvider(goRouter: mockGoRouter, child: child),
  );
}
