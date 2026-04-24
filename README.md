# flutter_link_nav

<div align="center">

> Seamlessly combine Flutter Navigator with Deep Links (Android) & Universal Links (iOS, macOS).

[![Pub.dev](https://img.shields.io/pub/v/flutter_link_nav.svg?style=flat-square&logo=dart&logoColor=white)](https://pub.dev/packages/flutter_link_nav)
[![GitHub stars](https://img.shields.io/github/stars/ngominhtrungit/flutter_link_nav?style=flat-square&logo=github)](https://github.com/ngominhtrungit/flutter_link_nav)
[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-ngominhtrungit-FFDD00?style=flat-square&logo=buy-me-a-coffee&logoColor=000000)](https://buymeacoffee.com/ngominhtrungit)


</div>

## Table of Contents
1. Overview
2. Features
3. Quick Start
4. Platform Setup
   - Android
   - iOS & macOS
5. Registering Routes
6. Case 1: Single Screen Navigation
7. Case 2: Tab Navigation (Multiple Tabs)
8. Test Deep Links (Commands)
9. Run Examples Locally
10. Changelog & License

---
## 1. Overview
`flutter_link_nav` helps you:
- Register routes once and reuse them for both Navigator and deep links.
- Use deep links to open screens or execute actions (dialogs, sheets, etc.).
- Support multi-tab screens by mapping tabs via the `tab` query parameter.

## 2. Features
- Global route registry (UI + action).
- Initial link + link stream handling.
- **Guard / Middleware**: Intercept navigation for Auth or logging.
- **Typed Query Parsing**: Safe parameter extraction.
- **Tab Navigation Mixin**: Simplified tab state synchronization.
- **Error & Unknown Route Handling**: Global callbacks for failed links.
- Null-safe & Flutter 3 compatible.

## 3. Quick Start
```dart
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
      initialRoute: ExampleAppRoutes.mainScreen,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
```
Call deep link handler inside the first screen you want to receive links:
```dart
@override
void initState() {
  super.initState();
  DeepLinkHandler().init(context); // or pass customHandler
}
```

## 4. Platform Setup
### Android (`AndroidManifest.xml`):
```xml
<intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="example.vn" />
</intent-filter>
```
### iOS & macOS (`Info.plist`):
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array><string>example.vn</string></array>
  </dict>
</array>
<key>NSUserActivityTypes</key>
<array><string>NSUserActivityTypeBrowsingWeb</string></array>
```

## 5. Registering Routes
```dart
class ExampleAppRoutes extends AppRoutes {
  static const String mainScreen = MainScreen.routeName;
  static const String detailScreen = DetailScreen.routeName;
  static const String tabScreen = TabScreen.routeName; // tab root

  @override
  Map<String, RouteConfig> get routes => {
    mainScreen: RouteConfig(widgetRegister: (query) => const MainScreen()),
    detailScreen: RouteConfig(widgetRegister: (query) => const DetailScreen()),
    'sheet': RouteConfig(actionRegister: (query) async {
      await showDialog(
        context: globalNavigatorKey.currentContext!,
        builder: (_) => AlertDialog(
          title: const Text('Deep Link Detected'),
          content: Text(query['label'] ?? ''),
          actions: [TextButton(onPressed: () => Navigator.of(globalNavigatorKey.currentContext!).pop(), child: const Text('OK'))],
        ),
      );
    }),
    tabScreen: RouteConfig(widgetRegister: (query) => const TabScreen()),
  };
}
```

## 6. Case 1: Single Screen Navigation
Minimal screen implementation:
```dart
class MainScreen extends StatefulWidget {
  static const String routeName = 'main_screen';
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}
class _MainScreenState extends State<MainScreen> {
  @override
  void initState() { super.initState(); DeepLinkHandler().init(context); }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Main')),
    body: Center(
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, ExampleAppRoutes.detailScreen),
        child: const Text('Go Detail'),
      ),
    ),
  );
}
class DetailScreen extends StatelessWidget {
  static const String routeName = 'detail_screen';
  const DetailScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Detail')));
}
```

## 7. Case 2: Tab Navigation (Multiple Tabs)
Entry point for tab-based example chooses `TabScreen` as initial route.
```dart
void main() { ExampleAppRoutes().registerRoutes(); runApp(const MyApp()); }
class MyApp extends StatelessWidget { /* same as Quick Start but initialRoute = tabScreen */ }
```
Tab screen with deep link aware tab switching:
```dart
class TabScreen extends StatefulWidget {
  static const String routeName = 'main'; // root for tab deep links
  const TabScreen({super.key, this.route});
  final String? route;
  @override State<TabScreen> createState() => _TabScreenState();
}
class _TabScreenState extends State<TabScreen> {
  int _selectedIndex = 0;
  final pages = [const HomePage(), const SearchPage(), const ProfilePage()];
  int mapTab(String? route) => switch (route) { 'search' => 1, 'profile' => 2, _ => 0 };
  @override
  void initState() {
    super.initState();
    _selectedIndex = mapTab(widget.route);
    DeepLinkHandler().init(
      context,
      customHandler: (ctx, uri) => ctx.handleNavigationOnTab(
        uri,
        config: TabNavigationConfig(
          getTabIndex: mapTab,
          currentTabIndex: _selectedIndex,
          updateTabIndex: (i) => setState(() => _selectedIndex = i),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(index: _selectedIndex, children: pages),
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (i) => setState(() => _selectedIndex = i),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    ),
  );
}
```
Required Input Parameters (must provide all):
- `getTabIndex(String? tabRoute) -> int` : Map route token to index.
- `currentTabIndex` : Current selected tab index.
- `updateTabIndex(int)` : Perform UI tab change.
  Examples:
- `example.vn://main?tab=search` → Switch to Search.
- `example.vn://main?tab=profile` → Switch to Profile.
- `example.vn://main` → Reset/stay Home.

### 7.1 Using TabDeepLinkMixin (Recommended)
Simplify tab logic by using the mixin:
```dart
class _TabScreenState extends State<TabScreen> with TabDeepLinkMixin {
  int _selectedIndex = 0;
  
  @override
  int get currentTabIndex => _selectedIndex;

  @override
  void onTabChanged(int index) => setState(() => _selectedIndex = index);

  @override
  int mapRouteToTabIndex(String? tabRoute) => switch (tabRoute) {
    'search' => 1,
    'profile' => 2,
    _ => 0
  };
  
  @override
  Widget build(BuildContext context) => Scaffold(...);
}
```

## 8. Deep Link Guards
Guards allow you to check conditions (like authentication) before navigating.

1. Implement `DeepLinkGuard`:
```dart
class AuthGuard extends DeepLinkGuard {
  @override
  FutureOr<GuardResult> canNavigate(BuildContext context, DeepLinkRequest request) {
    if (isLoggedIn) return const GuardResult.allow();
    return const GuardResult.redirect('login');
  }
}
```

2. Register in `RouteConfig`:
```dart
'profile': RouteConfig(
  widgetRegister: (query) => const ProfileScreen(),
  guards: [AuthGuard()],
),
```

## 9. Typed Query Parsing
Safely extract parameters from the query map:
```dart
'detail': RouteConfig(widgetRegister: (query) {
  final id = query.getInt('id'); // Safe int parse
  final showInfo = query.getBool('showInfo'); // Safe bool parse
  return DetailScreen(id: id);
}),
```
Available methods: `getInt`, `getDouble`, `getBool`, `getEnum`, `getList`.

## 10. Fallback & Error Handling
Catch unknown routes or errors in `DeepLinkHandler.init`:
```dart
DeepLinkHandler().init(
  context,
  onUnknownRoute: (uri) => Navigator.pushNamed(context, 'not_found'),
  onError: (error, stack) => print('Deep link error: $error'),
);
```

## 11. Test Deep Links (Commands)
Android:
```bash
adb shell am start -W -a android.intent.action.VIEW -d "example.vn://detail_screen" com.example.example
adb shell am start -W -a android.intent.action.VIEW -d "example.vn://main?tab=search" com.example.example
```
iOS Simulator:
```bash
xcrun simctl openurl DEVICE_ID "example.vn://detail_screen"
xcrun simctl openurl DEVICE_ID "example.vn://main?tab=profile"
```
macOS:
```bash
open "example.vn://detail_screen"
open "example.vn://main?tab=search"
```
Replace `DEVICE_ID` via `flutter devices` or `xcrun simctl list`.

## 9. Run Examples Locally
Case 1 (Single Screen):
```bash
flutter run -t example/lib/case_normal/main.dart -d android
flutter run -t example/lib/case_normal/main.dart -d ios
flutter run -t example/lib/case_normal/main.dart -d macos
```
Case 2 (Tabs):
```bash
flutter run -t example/lib/case_multiple_tab_screen/tab_screen.dart -d android
flutter run -t example/lib/case_multiple_tab_screen/tab_screen.dart -d ios
flutter run -t example/lib/case_multiple_tab_screen/tab_screen.dart -d macos
```

## 10. Changelog & License
- See `CHANGELOG.md` for version history.
- Licensed under the terms in `LICENSE`.

---
### Tips
- Use `AppRoutes.executeRouteAction('sheet', arguments: {...});` for non-navigation actions.
- Avoid pushing the same route without params; handler already skips.
- For debugging: add `debugPrint(uri.toString());` in custom handler.

### Next Ideas (Contributions Welcome)
- Add web platform support.
- Add guard/middleware before navigation.
- Provide a built-in tab mapping helper.

Enjoy building with deep links 🚀

---

<div align="center">

### 🤝 Contributing

Contributions, issues, and feature requests are welcome!  
Feel free to check the [issues page](https://github.com/ngominhtrungit/flutter_link_nav/issues).

### Show your support

If you find this project useful and it helps you save time, please consider supporting it. Your support keeps me motivated to maintain and improve this package!

<a href="https://www.buymeacoffee.com/ngominhtrungit" target="_blank" rel="noopener noreferrer">
  <img
    src="https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20coffee&emoji=&slug=ngominhtrungit&button_colour=FFDD00&font_colour=000000&font_family=Inter&outline_colour=000000&coffee_colour=000000"
    alt="Buy Me a Coffee"
    style="color: #000000;"
  />
</a>


<br />

Developed with ❤️ by **[Trung Ngo](https://github.com/ngominhtrungit)**

[![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/ngominhtrungit)
[![Pub.dev](https://img.shields.io/pub/v/flutter_link_nav.svg?style=for-the-badge&logo=dart&logoColor=white)](https://pub.dev/packages/flutter_link_nav)

</div>