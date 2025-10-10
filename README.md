# flutter_link_nav

> Seamlessly combine Flutter Navigator with Deep Links (Android) & Universal Links (iOS, macOS).

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
- Custom deep link handler injection.
- Tab navigation state sync via deep link events.
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

## 8. Test Deep Links (Commands)
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
