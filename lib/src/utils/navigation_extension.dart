import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_link_nav/flutter_link_nav.dart';

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
  /// Returns [bool] indicating if the navigation was handled as a tab switch
  Future<bool> handleNavigationOnTab(
    Uri uri, {
    TabNavigationConfig? config,
  }) async {
    final currentRoute = ModalRoute.of(this)?.settings.name;

    // Use the unified parseUri from uri_ext.dart
    final parseResult = uri.parseUri();
    final path = parseResult.deeplink;

    if (path == null || path.isEmpty) {
      debugPrint('Invalid URI format or empty path: $uri');
      return false;
    }

    debugPrint('Current route: $currentRoute, Target path: $path');

    if (config != null) {
      // Get tab-based routes from the global AppRoutes instance
      final appRoutesInstance = AppRoutes.instance;
      if (appRoutesInstance == null) {
        debugPrint(
            'AppRoutes instance not found. Make sure to call registerRoutes() first.');
        return false;
      }

      final isTabBasedRoute =
          appRoutesInstance.tabBasedRoutes?.contains(path) ?? false;
      final isCurrentTabBasedRoute =
          appRoutesInstance.tabBasedRoutes?.contains(currentRoute) ?? false;

      // if contains list of tab-based routes => change index IndexBottomNav
      if (isTabBasedRoute && isCurrentTabBasedRoute && path == currentRoute) {
        if (uri.queryParameters.containsKey('tab')) {
          final tabRoute = uri.queryParameters['tab'];

          // NEW: Check guards for the tab route
          if (tabRoute != null && tabRoute.isNotEmpty) {
            final tabConfig = RouteRegistry.getRouteConfig(tabRoute);
            debugPrint('Checking guards for tab route: $tabRoute, found config: ${tabConfig != null}');
            if (tabConfig?.guards != null && tabConfig!.guards!.isNotEmpty) {
              debugPrint('Found ${tabConfig.guards!.length} guards for tab: $tabRoute');
              final request = DeepLinkRequest(
                uri: uri,
                path: tabRoute,
                queryParameters: uri.queryParameters,
              );

              for (final guard in tabConfig.guards!) {
                debugPrint('Executing guard: ${guard.runtimeType}');
                final result = await guard.canNavigate(this, request);
                debugPrint('Guard result: ${result.allowed}');
                if (!result.allowed) {
                  if (result.redirectRoute != null) {
                    final redirectUri = Uri(
                      path: result.redirectRoute,
                      queryParameters: result.redirectParams,
                    );
                    if (mounted) {
                      debugPrint('Redirecting to: ${result.redirectRoute}');
                      // Process redirect via global handler
                      DeepLinkHandler().init(
                          this); // Ensure init doesn't re-run, but trigger processor
                      // Actually, we should just call processor directly or Navigator
                      // Better: let the processor handle it by calling it again
                      await DefaultDeepLinkProcessor()
                          .processDeepLink(this, redirectUri);
                    }
                  }
                  return true; // Handled as blocked/redirected
                }
              }
            }
          }

          final newTabIndex = config.getTabIndex(tabRoute);
          debugPrint(
              'Updating tab to index: $newTabIndex for route: $tabRoute in tab-based screen: $path');

          if (newTabIndex != config.currentTabIndex) {
            config.updateTabIndex(newTabIndex);
          }
          return true;
        }

        // if no query parameters and same tab-based route => reset to index 0
        debugPrint(
            'Resetting tab index to 0 for $path because it is current tab-based route without params');
        if (config.currentTabIndex != 0) {
          config.updateTabIndex(0);
        }
        return true;
      }
    }

    // if has query parameters => always push
    if (uri.queryParameters.isNotEmpty) {
      debugPrint(
          'Has query parameters, navigating to $path with params: ${uri.queryParameters}');
      Navigator.pushNamed(this, path, arguments: uri.queryParameters);
      return false;
    }

    // if same route and not query params => do nothing
    if (currentRoute == path) {
      debugPrint('Skip push route $path because it is current route');
      return false;
    }

    // Another case
    debugPrint('Navigating to different route: $path');
    Navigator.pushNamed(this, path);
    return false;
  }
}
