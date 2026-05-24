import 'dart:async';
import 'package:flutter/material.dart';
import '../deeplink/deep_link_guard.dart';

typedef RouteHandler<T> = T Function(Object? queryParams);

typedef RouteWidget = RouteHandler<Widget?>;
typedef RouteAction = RouteHandler<FutureOr<void>>;

class RouteConfig {
  final RouteWidget? widgetRegister;
  final RouteAction? actionRegister;
  final List<DeepLinkGuard>? guards;

  const RouteConfig({
    this.widgetRegister,
    this.actionRegister,
    this.guards,
  });
}

class RouteMatch {
  final RouteConfig config;
  final String matchedRouteName;
  final Map<String, String> pathParams;

  RouteMatch(this.config, this.matchedRouteName, this.pathParams);
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

  /// Match a path against registered routes, supporting path parameters like /user/:id
  static RouteMatch? matchRoute(String path) {
    // 1. Check for exact match first
    if (_routes.containsKey(path)) {
      return RouteMatch(_routes[path]!, path, {});
    }

    // 2. Iterate through routes to find pattern match
    final pathSegments = path.split('/').where((s) => s.isNotEmpty).toList();

    for (final entry in _routes.entries) {
      final routePattern = entry.key;
      final routeSegments = routePattern.split('/').where((s) => s.isNotEmpty).toList();

      if (pathSegments.length == routeSegments.length) {
        bool isMatch = true;
        final Map<String, String> extractedParams = {};

        for (int i = 0; i < routeSegments.length; i++) {
          final rSeg = routeSegments[i];
          final pSeg = pathSegments[i];

          if (rSeg.startsWith(':')) {
            final paramName = rSeg.substring(1);
            extractedParams[paramName] = pSeg;
          } else if (rSeg != pSeg) {
            isMatch = false;
            break;
          }
        }

        if (isMatch) {
          return RouteMatch(entry.value, routePattern, extractedParams);
        }
      }
    }

    return null;
  }

  ///
  /// Get route configuration for a specific route (exact match only)
  ///
  static RouteConfig? getRouteConfig(String route) {
    return _routes[route];
  }
}
