import 'package:example/case_multiple_tab_screen/tab_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_link_nav/flutter_link_nav.dart';

import 'case_normal/detail_screen.dart';
import 'case_normal/main.dart';
import 'case_normal/main_screen.dart';

class ExampleAppRoutes extends AppRoutes {
  static const String mainScreen = MainScreen.routeName;
  static const String detailScreen = DetailScreen.routeName;

  static const String tabScreen = TabScreen.routeName;
  static const String another = AnotherScreen.routeName;

  @override
  Map<String, RouteConfig> get routes => {
    mainScreen: RouteConfig(
      widgetRegister: (queryParams) => const MainScreen(),
    ),
    '$mainScreen/$detailScreen': RouteConfig(
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
    tabScreen: RouteConfig(
      widgetRegister: (queryParams) =>
          TabScreen(route: queryParams != null ? queryParams['tab'] : null),
    ),
    another: RouteConfig(
      widgetRegister: (queryParams) => const AnotherScreen(),
    ),
  };

  @override
  Set<String>? get tabBasedRoutes => {tabScreen};
}
