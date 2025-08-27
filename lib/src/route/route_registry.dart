import 'package:flutter/material.dart';

typedef RouteWidget = Widget? Function(dynamic queryParams, String? fromSource);

class RouteRegistry {
  static final Map<String, RouteWidget> _handlers = {};

  ///
  /// This [register] function is supported to register a route handler for a specific route.
  ///
  /// example:
  ///
  /// 'home': (queryParams, fromSource) => HomeScreen()
  ///
  /// 'profile': (queryParams, fromSource) => ProfileScreen(userId: queryParams['id'])
  ///
  static void register(String route, RouteWidget handler) {
    _handlers[route] = handler;
  }

  ///
  /// This [getWidget] function is supported to [get] the widget for a specific [route].
  ///
  /// example:
  ///
  /// RouteRegistry.getWidget('home') => return [HomeScreen] had registered before
  ///
  static Widget? getWidget(
    String route, {
    dynamic queryParams,
    String? fromSource,
  }) {
    return _handlers[route]?.call(queryParams, fromSource);
  }
}
