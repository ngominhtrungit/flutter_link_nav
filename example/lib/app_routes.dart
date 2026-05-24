import 'package:example/case_multiple_tab_screen/tab_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_link_nav/flutter_link_nav.dart';

import 'case_normal/detail_screen.dart';
import 'case_normal/main.dart';
import 'case_normal/main_screen.dart';

class SimpleAuthGuard extends DeepLinkGuard {
  @override
  GuardResult canNavigate(BuildContext context, DeepLinkRequest request) {
    final isLoggedIn = request.queryParameters.getBool(
      'login',
      defaultValue: false,
    );
    if (isLoggedIn) {
      debugPrint('User is logged in');
      return const GuardResult.allow();
    }
    debugPrint('User is not logged in - Blocking access');
    return const GuardResult.redirect(
      'warning',
      params: {'msg': 'Access Denied: Please login to view this content!'},
    );
  }
}

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
    detailScreen: RouteConfig(
      widgetRegister: (query) {
        final id = query.toParams.getInt('id') ?? 0;
        return DetailScreen(id: id);
      },
    ),
    'user/:id': RouteConfig(
      widgetRegister: (query) {
        final id = query.toParams.getInt('id') ?? 0;
        return DetailScreen(id: id);
      },
    ),
    'warning': RouteConfig(
      actionRegister: (query) {
        final message = query.toParams['msg'] ?? 'Access denied';
        ScaffoldMessenger.of(globalNavigatorKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    ),
    'sheet': RouteConfig(
      actionRegister: (query) async {
        await showDialog(
          context: globalNavigatorKey.currentContext!,
          builder: (context) => AlertDialog(
            title: const Text('Deep Link Detected'),
            content: Text(query.toParams['label'] ?? 'No label'),
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
          TabScreen(route: queryParams.toParams['tab']),
    ),
    AdvancedTabScreen.routeName: RouteConfig(
      widgetRegister: (queryParams) =>
          AdvancedTabScreen(route: queryParams.toParams['tab']),
    ),
    another: RouteConfig(
      widgetRegister: (queryParams) => const AnotherScreen(),
      guards: [SimpleAuthGuard()],
    ),
  };

  @override
  Set<String>? get tabBasedRoutes => {tabScreen, AdvancedTabScreen.routeName};
}
