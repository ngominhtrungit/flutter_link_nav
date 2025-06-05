import 'package:flutter/material.dart';
import 'route_registry.dart';

abstract class AppRoutes {
  Map<String, RouteConfig> get routes;

  void registerRoutes() {
    routes.forEach((routeName, config) {
      RouteRegistry.register(
        routeName,
        (queryParams, fromSource) => config.builder(queryParams, fromSource),
      );
    });
  }

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final routeHandler = RouteRegistry.getHandler(
      settings.name!,
      queryParams: settings.arguments,
      fromSource: '',
    );

    if (routeHandler != null) {
      return MaterialPageRoute(
        builder: (_) => routeHandler,
        settings: settings,
      );
    }
    return null;
  }
}

class RouteConfig {
  final Widget Function(dynamic queryParams, String? fromSource) builder;

  const RouteConfig({
    required this.builder,
  });
}