import 'package:flutter_link_nav/flutter_link_nav.dart';

import 'detail_screen.dart';
import 'main_screen.dart';

class ExampleAppRoutes extends AppRoutes {
  static const String mainScreen = MainScreen.routeName;
  static const String detailScreen = DetailScreen.routeName;

  @override
  Map<String, RouteConfig> get routes => {
    MainScreen.routeName: RouteConfig(
      builder: (queryParams, fromSource) => const MainScreen(),
    ),
    DetailScreen.routeName: RouteConfig(
      builder: (queryParams, fromSource) => const DetailScreen(),
    ),
  };
}