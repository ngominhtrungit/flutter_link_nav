import 'package:flutter/material.dart';
import 'route_registry.dart';

abstract class AppRoutes {
  ///
  /// This place contains all the routes used in the application.
  ///
  Map<String, RouteConfig> get routes;

  void registerRoutes() {
    routes.forEach((routeName, config) {
      RouteRegistry.register(
        routeName,
        (queryParams, fromSource) =>
            config.widgetRegister(queryParams, fromSource),
      );
    });
  }

  ///
  /// The route generator callback used when the app is navigated to a named route.
  ///
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final widgetDetected = RouteRegistry.getWidget(
      settings.name!,
      queryParams: settings.arguments,
      fromSource: '',
    );

    if (widgetDetected != null) {
      return MaterialPageRoute(
        builder: (_) => widgetDetected,
        settings: settings,
      );
    }
    return null;
  }
}

class RouteConfig {
  ///
  /// [widgetRegister] function it mainly callback queryParams and fromSource for once [Widget]
  ///
  final Widget Function(dynamic queryParams, String? fromSource) widgetRegister;

  const RouteConfig({
    required this.widgetRegister,
  });
}
