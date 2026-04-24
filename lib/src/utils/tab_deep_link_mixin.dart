import 'package:flutter/material.dart';
import '../deeplink/deeplink_handle.dart';
import 'navigation_extension.dart';

/// A mixin to simplify deep link handling for tab-based screens.
///
/// Implement this in the [State] of your tab-based screen.
mixin TabDeepLinkMixin<T extends StatefulWidget> on State<T> {
  /// The current selected tab index.
  int get currentTabIndex;

  /// Callback to update the selected tab index.
  void onTabChanged(int index);

  /// Map a route token (usually from the `tab` query parameter) to a tab index.
  int mapRouteToTabIndex(String? tabRoute);

  @override
  void initState() {
    super.initState();
    // Automatically initialize deep link handling for this tab screen
    DeepLinkHandler().init(
      context,
      customHandler: (ctx, uri) => ctx.handleNavigationOnTab(
        uri,
        config: TabNavigationConfig(
          getTabIndex: mapRouteToTabIndex,
          currentTabIndex: currentTabIndex,
          updateTabIndex: onTabChanged,
        ),
      ),
    );
  }
}
