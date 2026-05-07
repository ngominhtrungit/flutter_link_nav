# Migration Guide: Core Update (v3.2.0)

Version 3.2.0 introduces several enhancements to `flutter_link_nav` for better safety, security, and developer experience. This guide helps you migrate your existing code to the new APIs.

## 1. Guard System
If you want to intercept navigation (e.g., for authentication), you can now add guards to your `RouteConfig`.

**Old:**
```dart
'profile': RouteConfig(widgetRegister: (query) => ProfileScreen()),
```

**New:**
```dart
'profile': RouteConfig(
  widgetRegister: (query) => ProfileScreen(),
  guards: [AuthGuard()], // New field
),
```

## 2. Tab Navigation Mixin
The `TabDeepLinkMixin` simplifies tab switching logic.

**Old (Manual):**
```dart
class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    DeepLinkHandler().init(
      context,
      customHandler: (ctx, uri) => ctx.handleNavigationOnTab(
        uri,
        config: TabNavigationConfig(...),
      ),
    );
  }
}
```

**New (Mixin):**
```dart
class _MainScreenState extends State<MainScreen> with TabDeepLinkMixin {
  @override
  int get currentTabIndex => _selectedIndex;

  @override
  void onTabChanged(int index) => setState(() => _selectedIndex = index);

  @override
  int mapRouteToTabIndex(String? tabRoute) => switch(tabRoute) {
    'search' => 1,
    'profile' => 2,
    _ => 0
  };
  
  // initState is handled by the mixin!
}
```

## 3. Typed Query Parsing
Instead of manual string parsing, use the new extensions on `Map<String, String>`.

**Old:**
```dart
final id = int.tryParse(query['id'] ?? '');
```

**New:**
```dart
final id = query.getInt('id');
final isNew = query.getBool('is_new');
final tags = query.getList('tags');
```

## 4. Error Handling
You can now catch errors and unknown routes globally.

```dart
DeepLinkHandler().init(
  context,
  onUnknownRoute: (uri) {
    // Handle 404
  },
  onError: (error, stack) {
    // Log error
  },
);
```

## 5. Safe Parameter Parsing
`RouteHandler` parameters are now `Object?`. Use `.toParams` to safely convert them.

**Old:**
```dart
widgetRegister: (query) {
  final id = query['id']; // Assumes query is Map
}
```

**New:**
```dart
widgetRegister: (query) {
  final id = query.toParams['id']; // Safe and works with any Object type
}
```
