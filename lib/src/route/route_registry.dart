import 'package:flutter/material.dart';

typedef RouteHandler<T> = T Function(dynamic queryParams);

typedef RouteWidget = RouteHandler<Widget?>;
typedef RouteAction = RouteHandler<void>;

class RouteConfig {
  final RouteWidget? widgetRegister;
  final RouteAction? actionRegister;

  const RouteConfig({this.widgetRegister, this.actionRegister});
}

class RouteRegistry {
  static final Map<String, RouteConfig> _routes = {};

  ///
  /// Register a unified route configuration with both widget and action handlers
  ///
  /// example:
  /// RouteRegistry.registerRoute('home', RouteConfig(
  ///   widgetRegister: (queryParams) => HomeScreen(),
  ///   actionRegister: (queryParams) async => print('Home accessed')
  /// ));
  ///
  static void registerRoute(String route, RouteConfig config) {
    _routes[route] = config;
  }

  ///
  /// Get route configuration for a specific route
  ///
  /// example:
  ///
  /// RouteRegistry.getRouteConfig('home') => return [HomeScreen] had registered before
  ///
  /// or show bottom sheet
  ///
  /// RouteRegistry.getRouteConfig('showBottomSheet') => return action to show bottom sheet
  ///
  static RouteConfig? getRouteConfig(String route) {
    return _routes[route];
  }
}
