import 'package:flutter/material.dart';
import 'package:flutter_link_nav/flutter_link_nav.dart';
import 'app_routes.dart';

final globalNavigatorKey = GlobalObjectKey<NavigatorState>('nav');
void main() {
  ExampleAppRoutes().registerRoutes();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: globalNavigatorKey,
      initialRoute: ExampleAppRoutes.mainScreen,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
