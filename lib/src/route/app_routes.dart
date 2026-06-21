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
  /// A smarter alternative to [ModalRoute.withName] that supports Path Parameters.
  /// Use this with [Navigator.popUntil] to correctly match routes with dynamic segments.
  /// 
  static RoutePredicate withName(String routeName) {
    return (Route<dynamic> route) {
      final currentName = route.settings.name;
      if (currentName == null) return false;
      
      // 1. Exact match (same as ModalRoute.withName)
      if (currentName == routeName) return true;
      
      // 2. Smart match for Path Parameters
      final match = RouteRegistry.matchRoute(currentName);
      return match?.matchedRouteName == routeName;
    };
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
          guards: config.guards,
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
    final routeMatch = RouteRegistry.matchRoute(routeName);
    if (routeMatch?.config.actionRegister != null) {
      dynamic finalArguments = arguments;
      if (routeMatch!.pathParams.isNotEmpty) {
        if (finalArguments is Map) {
          finalArguments = <dynamic, dynamic>{
            ...finalArguments,
            ...routeMatch.pathParams,
          };
        } else if (finalArguments == null) {
          finalArguments = routeMatch.pathParams;
        }
      }
      return routeMatch.config.actionRegister!.call(finalArguments);
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
    if (settings.name == null) return null;
    
    final routeMatch = RouteRegistry.matchRoute(settings.name!);

    if (routeMatch == null) {
      return null;
    }

    final routeConfig = routeMatch.config;

    if (routeConfig.widgetRegister == null) {
      debugPrint(
          'Route "${settings.name}" has no widgetRegister. Use deep links for action-only routes.');
      return null;
    }

    dynamic finalArguments = settings.arguments;
    if (routeMatch.pathParams.isNotEmpty) {
      if (finalArguments is Map) {
        finalArguments = <dynamic, dynamic>{
          ...finalArguments,
          ...routeMatch.pathParams,
        };
      } else if (finalArguments == null) {
        finalArguments = routeMatch.pathParams;
      }
    }

    routeConfig.actionRegister?.call(finalArguments);

    final widgetDetected = routeConfig.widgetRegister!.call(finalArguments);

    if (widgetDetected != null) {
      return MaterialPageRoute(
        builder: (_) => widgetDetected,
        settings: settings,
      );
    }
    return null;
  }
}
