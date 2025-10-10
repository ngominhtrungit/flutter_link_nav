import 'package:flutter/material.dart';
import 'route_registry.dart';

abstract class AppRoutes {
  // Global instance to store the current AppRoutes implementation
  static AppRoutes? _instance;

  // Getter to access the global instance
  static AppRoutes? get instance => _instance;

  // Method to set the global instance
  static void setInstance(AppRoutes appRoutes) {
    _instance = appRoutes;
  }

  ///
  /// This place contains all the routes used in the application.
  ///
  Map<String, RouteConfig> get routes;

  ///
  /// This set contains routes that are based on tab navigation.
  /// example: main screen contains 3 tabs screen: home, search, profile
  ///
  /// mapping with each tab screen <=> tab route
  /// Case 1: example.vn://main?tab=search → Navigate to search tab
  /// Case 2: example.vn://main?tab=profile → Navigate to profile tab
  /// Case 3: example.vn://main → Reset to index 0
  ///
  Set<String>? get tabBasedRoutes;

  bool isTabBasedRoute(String? route) {
    return route != null &&
        tabBasedRoutes != null &&
        (tabBasedRoutes?.contains(route) ?? false);
  }

  void registerRoutes() {
    // Set this instance as the global instance when registering routes
    AppRoutes.setInstance(this);

    routes.forEach((routeName, config) {
      RouteRegistry.registerRoute(
        routeName,
        RouteConfig(
          widgetRegister: config.widgetRegister,
          actionRegister: config.actionRegister,
        ),
      );
    });
  }

  ///
  /// Execute an action for a specific route without navigation.
  /// Use this for action-only routes instead of Navigator.pushNamed.
  ///
  static Future<void>? executeRouteAction(
    String routeName, {
    dynamic arguments,
  }) async {
    final routeConfig = RouteRegistry.getRouteConfig(routeName);
    if (routeConfig?.actionRegister != null) {
      return routeConfig!.actionRegister!.call(arguments);
    }
    debugPrint('Route "$routeName" has no actionRegister.');
    return;
  }

  ///
  /// The route generator callback used when the app is navigated to a named route.
  /// Only handles routes with widgetRegister. For action-only routes, use deep links instead.
  ///
  /// or using
  ///
  /// AppRoutes.executeRouteAction('routeName', arguments: {...});
  ///
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final routeConfig = RouteRegistry.getRouteConfig(settings.name!);

    if (routeConfig == null) {
      return null;
    }

    if (routeConfig.widgetRegister == null) {
      debugPrint(
          'Route "${settings.name}" has no widgetRegister. Use deep links for action-only routes.');
      return null;
    }

    routeConfig.actionRegister?.call(settings.arguments);

    final widgetDetected = routeConfig.widgetRegister!.call(settings.arguments);

    if (widgetDetected != null) {
      return MaterialPageRoute(
        builder: (_) => widgetDetected,
        settings: settings,
      );
    }
    return null;
  }
}
