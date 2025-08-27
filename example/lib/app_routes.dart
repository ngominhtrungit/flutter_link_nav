import 'package:flutter/material.dart';
import 'package:flutter_link_nav/flutter_link_nav.dart';

import 'detail_screen.dart';
import 'main.dart';
import 'main_screen.dart';

class ExampleAppRoutes extends AppRoutes {
  static const String mainScreen = MainScreen.routeName;
  static const String detailScreen = DetailScreen.routeName;

  @override
  Map<String, RouteConfig> get routes => {
    mainScreen: RouteConfig(
      widgetRegister: (queryParams) => const MainScreen(),
    ),
    detailScreen: RouteConfig(
      widgetRegister: (queryParams) => const DetailScreen(),
    ),
    'sheet': RouteConfig(
      actionRegister: (query) async {
        await showDialog(
          context: globalNavigatorKey.currentContext!,
          builder: (context) => AlertDialog(
            title: const Text('Deep Link Detected'),
            content: Text(query['label'] ?? ''),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    ),
  };
}
