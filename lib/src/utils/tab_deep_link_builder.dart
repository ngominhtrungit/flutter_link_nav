import 'package:flutter/material.dart';
import 'tab_deep_link_mixin.dart';

/// A builder function that provides the current tab index and a callback to update it.
typedef TabBuilder = Widget Function(
  BuildContext context,
  int currentIndex,
  ValueChanged<int> onTabChanged,
);

/// A wrapper widget that simplifies the usage of [TabDeepLinkMixin].
///
/// Use this when you don't want to create a [StatefulWidget] and manage
/// the current tab index manually. It handles the state and deep link integration
/// automatically.
///
/// If your use case is more complex (e.g., requires a custom [TabController],
/// calling APIs on tab change, etc.), consider using [TabDeepLinkMixin] directly
/// on your own [StatefulWidget].
class TabDeepLinkBuilder extends StatefulWidget {
  /// The initial route token to determine the starting tab.
  final String? initialRoute;

  /// A map that associates a route token with a tab index.
  /// For example: `{'search': 1, 'profile': 2}`.
  final Map<String, int>? routeToIndexMap;

  /// The default index to fall back to if the route is not found in [routeToIndexMap].
  final int defaultIndex;

  /// The builder function that creates the UI based on the current tab index.
  final TabBuilder builder;

  const TabDeepLinkBuilder({
    super.key,
    this.initialRoute,
    this.routeToIndexMap,
    this.defaultIndex = 0,
    required this.builder,
  });

  @override
  State<TabDeepLinkBuilder> createState() => _TabDeepLinkBuilderState();
}

class _TabDeepLinkBuilderState extends State<TabDeepLinkBuilder> with TabDeepLinkMixin {
  late int _currentIndex;

  @override
  void initState() {
    _currentIndex = mapRouteToTabIndex(widget.initialRoute);
    super.initState();
  }

  @override
  int get currentTabIndex => _currentIndex;

  @override
  int mapRouteToTabIndex(String? tabRoute) {
    if (widget.routeToIndexMap != null && tabRoute != null) {
      return widget.routeToIndexMap![tabRoute] ?? widget.defaultIndex;
    }
    return widget.defaultIndex;
  }

  @override
  void onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _currentIndex, onTabChanged);
  }
}
