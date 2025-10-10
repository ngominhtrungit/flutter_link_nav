import 'package:flutter/material.dart';
import '../route/app_routes.dart';

/// Configuration class for tab navigation handling
class TabNavigationConfig {
  final int Function(String?) getTabIndex;
  final int currentTabIndex;
  final void Function(int) updateTabIndex;

  const TabNavigationConfig({
    required this.getTabIndex,
    required this.currentTabIndex,
    required this.updateTabIndex,
  });
}

extension NavigationExtension on BuildContext {
  /// Handles navigation for tab-based screens with deep link support
  ///
  /// This extension method provides navigation logic for tab-based screens:
  /// - Updates tab index based on query parameters
  /// - Resets to index 0 when no query parameters are provided
  /// - Handles regular navigation for non-tab routes
  ///
  /// Parameters:
  /// - [uri]: The deep link URI to process
  /// - [config]: Tab navigation configuration (optional for tab-based navigation)
  void handleNavigationOnTab(
    Uri uri, {
    TabNavigationConfig? config,
  }) {
    final currentRoute = ModalRoute.of(this)?.settings.name;

    // Parse path correctly from URI scheme like example.vn://main_screen
    String path;
    if (uri.scheme.isNotEmpty && uri.host.isNotEmpty) {
      // For URIs like example.vn://main_screen
      path = uri.host;
    } else if (uri.path.isNotEmpty) {
      // For URIs like /main_screen
      path = uri.path.replaceFirst('/', '');
    } else {
      debugPrint('Invalid URI format: $uri');
      return;
    }

    debugPrint('Current route: $currentRoute, Target path: $path');

    if (config != null) {
      // Get tab-based routes from the global AppRoutes instance
      final appRoutesInstance = AppRoutes.instance;
      if (appRoutesInstance == null) {
        debugPrint(
            'AppRoutes instance not found. Make sure to call registerRoutes() first.');
        return;
      }

      final isTabBasedRoute =
          appRoutesInstance.tabBasedRoutes?.contains(path) ?? false;
      final isCurrentTabBasedRoute =
          appRoutesInstance.tabBasedRoutes?.contains(currentRoute) ?? false;

      // if contains list of tab-based routes => change index IndexBottomNav
      if (isTabBasedRoute && isCurrentTabBasedRoute && path == currentRoute) {
        if (uri.queryParameters.containsKey('tab')) {
          final tabRoute = uri.queryParameters['tab'];
          final newTabIndex = config.getTabIndex(tabRoute);
          debugPrint(
              'Updating tab to index: $newTabIndex for route: $tabRoute in tab-based screen: $path');

          if (newTabIndex != config.currentTabIndex) {
            config.updateTabIndex(newTabIndex);
          }
          return;
        }

        // if no query parameters and same tab-based route => reset to index 0
        debugPrint(
            'Resetting tab index to 0 for $path because it is current tab-based route without params');
        if (config.currentTabIndex != 0) {
          config.updateTabIndex(0);
        }
        return;
      }
    }

    // if has query parameters => always push
    if (uri.queryParameters.isNotEmpty) {
      debugPrint(
          'Has query parameters, navigating to $path with params: ${uri.queryParameters}');
      Navigator.pushNamed(this, path, arguments: uri.queryParameters);
      return;
    }

    // if same route and not query params => do nothing
    if (currentRoute == path) {
      debugPrint('Skip push route $path because it is current route');
      return;
    }

    // Another case
    debugPrint('Navigating to different route: $path');
    Navigator.pushNamed(this, path);
  }
}
