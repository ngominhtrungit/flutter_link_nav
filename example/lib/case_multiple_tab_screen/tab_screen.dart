import 'package:flutter/material.dart';
import 'package:flutter_link_nav/flutter_link_nav.dart';
import '../app_routes.dart';
import '../case_normal/main.dart';

void main() {
  ExampleAppRoutes().registerRoutes();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: globalNavigatorKey,
      initialRoute: ExampleAppRoutes.tabScreen,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}

/// Example of Simple Case using [TabDeepLinkBuilder]
class TabScreen extends StatelessWidget {
  static const String routeName = 'main';

  final String? route;

  const TabScreen({super.key, this.route});

  @override
  Widget build(BuildContext context) {
    return TabDeepLinkBuilder(
      initialRoute: route,
      routeToIndexMap: const {
        SearchPage.routeName: 1,
        ProfileScreen.routeName: 2,
      },
      builder: (context, currentIndex, onTabChanged) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Simple Tab Screen'),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, AdvancedTabScreen.routeName);
                },
                icon: const Icon(Icons.settings),
                tooltip: 'Go to Advanced Case',
              )
            ],
          ),
          body: IndexedStack(
            index: currentIndex,
            children: const [
              Center(child: Text('home page')),
              SearchPage(),
              ProfileScreen(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTabChanged,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        );
      },
    );
  }
}

/// Example of Advanced Case using [TabDeepLinkMixin]
class AdvancedTabScreen extends StatefulWidget {
  static const String routeName = 'main_advanced';

  const AdvancedTabScreen({super.key, this.route});

  final String? route;

  @override
  State<AdvancedTabScreen> createState() => _AdvancedTabScreenState();
}

class _AdvancedTabScreenState extends State<AdvancedTabScreen> with TabDeepLinkMixin {
  int _selectedIndexBottomNav = 0;
  List<BottomNavItemData>? _bottomNavItems;

  final List<Widget> _pages = [
    const Center(child: Text('home page')),
    const SearchPage(),
    const ProfileScreen(),
  ];

  @override
  int get currentTabIndex => _selectedIndexBottomNav;

  @override
  void onTabChanged(int index) {
    setState(() {
      _selectedIndexBottomNav = index;
    });
  }

  @override
  int mapRouteToTabIndex(String? tabRoute) {
    const routeMap = {SearchPage.routeName: 1, ProfileScreen.routeName: 2};
    return routeMap[tabRoute] ?? 0;
  }

  @override
  void initState() {
    _selectedIndexBottomNav = mapRouteToTabIndex(widget.route);
    super.initState();

    _bottomNavItems = <BottomNavItemData>[
      BottomNavItemData(icon: Icons.book_outlined, label: 'Home'),
      BottomNavItemData(
        icon: Icons.chat_bubble_outline,
        label: 'Search',
        hasNotification: true,
      ),
      BottomNavItemData(icon: Icons.person_outline, label: 'Profile'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advanced Tab Screen')),
      body: IndexedStack(index: _selectedIndexBottomNav, children: _pages),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndexBottomNav,
      onTap: (int index) {
        setState(() {
          _selectedIndexBottomNav = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(fontSize: 12.0),
      unselectedLabelStyle: const TextStyle(fontSize: 11.0),
      items:
          _bottomNavItems?.map<BottomNavigationBarItem>((
            BottomNavItemData item,
          ) {
            return BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Icon(item.icon),
                  if (item.hasNotification)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: const SizedBox.shrink(),
                      ),
                    ),
                ],
              ),
              label: item.label,
            );
          }).toList() ??
          [],
    );
  }
}

class BottomNavItemData {
  final IconData icon;
  final String label;
  final bool hasNotification;

  BottomNavItemData({
    required this.icon,
    required this.label,
    this.hasNotification = false,
  });
}

class SearchPage extends StatelessWidget {
  static const String routeName = 'search';

  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class ProfileScreen extends StatelessWidget {
  static const String routeName = 'profile';

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Profile screen'));
  }
}

class AnotherScreen extends StatelessWidget {
  static const String routeName = 'another';
  const AnotherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Another Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'This is another screen.',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, ExampleAppRoutes.detailScreen);
              },
              child: const Text('Go to Detail Screen'),
            ),
            ElevatedButton(
              onPressed: () {
                AppRoutes.executeRouteAction(
                  'sheet',
                  arguments: {'label': 'Action executed from button'},
                );
                // Navigator.pushNamed(context, 'sheet', arguments:{'label': 'Action executed from button'}  );
              },
              child: const Text('Show Sheet (Action)'),
            ),
          ],
        ),
      ),
    );
  }
}
