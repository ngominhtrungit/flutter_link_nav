# flutter_link_nav

Combining Navigator with Deep Links (Android) and Universal Links (iOS) in Flutter

## How to config
### First, example config with schema `example.vn`:
### Android
1. Add the following to your `AndroidManifest.xml` file:

```            
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />

        <data android:scheme="example.vn" />
    </intent-filter>
```
### iOS
1. Add the following to your `Info.plist` file:

```
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>example.vn</string>
            </array>
        </dict>
    </array>
    <key>NSUserActivityTypes</key>
    <array>
        <string>NSUserActivityTypeBrowsingWeb</string>
    </array>
```

## How to use
1. First example have 2 screens: `MainScreen` and `DetailScreen`.
   - In `MainScreen`, because I want every navigate to `another screen` after start from `MainScreen` to be handled by deep link, I will call `DeepLinkHandler().init(context)` in `initState()`.
```
class MainScreen extends StatefulWidget {
  static const String routeName = "main_screen";
  ...
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
     /// option 1: use the default deep link handler
    DeepLinkHandler().init(context);
    /// option 2: use a custom deep link handler
    // DeepLinkHandler().init(context, customHandler: (context, uri) {
    //   // Custom deep link handling logic can be added here
    //   debugPrint('MainScreen Custom deep link handler: $uri');
    // });
  }
  ...
}

class DetailScreen extends StatelessWidget {
  static const String routeName = "detail_screen";
  ...
}
```
2. Then, create implementation of `AppRoutes`:

```
import 'package:flutter_link_nav/flutter_link_nav.dart';

class ExampleAppRoutes extends AppRoutes {
  static const String mainScreen = MainScreen.routeName;
  static const String detailScreen = DetailScreen.routeName;

  @override
  Map<String, RouteConfig> get routes => {
        mainScreen: RouteConfig(
          builder: (queryParams, fromSource) => const MainScreen(),
        ),
        detailScreen: RouteConfig(
          builder: (queryParams, fromSource) => const DetailScreen(),
        ),
      };
}
```
3. Finally, setup in `main.dart`:

```
import 'package:flutter/material.dart';
import 'package:flutter_link_nav/flutter_link_nav.dart';

import 'app_routes.dart';

void main() {
  ExampleAppRoutes().registerRoutes();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      initialRoute: ExampleAppRoutes.mainScreen,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
```

## How to test
1. Navigate into app:
```
Navigator.pushNamed(context, [screen_name]);

example:
Navigator.pushNamed(context, ExampleAppRoutes.detailScreen);
```

2. For Android, you can use the `adb` command to test deep links:
```
adb shell am start -W -a android.intent.action.VIEW -d [deeplink] [package_name]

# Example command to test deep link
adb shell am start -W -a android.intent.action.VIEW -d "example.vn/detail_screen" com.example.example

# With query params
adb shell am start -W -a android.intent.action.VIEW -d "example.vn/detail_screen?param1=value1&param2=value2" com.example.example
```

3. For iOS, you can use the `xcrun` command to test universal links:
```
xcrun simctl openurl [device_id] [universal link]

# Example command to test universal link
xcrun simctl openurl 55331C47-EDBD-439A-B098-34A9382F3A83 "example.vn://detail_screen"

# With query params
xcrun simctl openurl 3ACB75D6-C7A4-4BDD-A6E4-AE17C8773949 example.vn://detail_screen?param1=value1&param2=value2
```