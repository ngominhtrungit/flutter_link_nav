import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_link_nav/flutter_link_nav.dart';
import 'dart:async';

class MockGuard extends DeepLinkGuard {
  final bool allowed;
  final String? redirectRoute;

  MockGuard({required this.allowed, this.redirectRoute});

  @override
  Future<GuardResult> canNavigate(
      BuildContext context, DeepLinkRequest request) async {
    if (allowed) return const GuardResult.allow();
    return GuardResult.redirect(redirectRoute ?? 'blocked');
  }
}

class TestAppRoutes extends AppRoutes {
  @override
  Map<String, RouteConfig> get routes => {
        'main': const RouteConfig(widgetRegister: _emptyWidget),
        'tab1': RouteConfig(
          widgetRegister: _emptyWidget,
          guards: [MockGuard(allowed: true)],
        ),
        'tab_blocked': RouteConfig(
          widgetRegister: _emptyWidget,
          guards: [MockGuard(allowed: false, redirectRoute: 'login')],
        ),
        'login': const RouteConfig(actionRegister: _emptyAction),
      };

  @override
  Set<String>? get tabBasedRoutes => {'main'};

  static Widget _emptyWidget(_) => const SizedBox.shrink();
  static void _emptyAction(_) {}
}

void main() {
  setUp(() {
    TestAppRoutes().registerRoutes();
  });

  group('DeepLinkObjectX Tests', () {
    test('toParams converts Map<String, String> correctly', () {
      final Map<String, String> data = {'id': '1', 'name': 'test'};
      expect(data.toParams, data);
    });

    test('toParams converts Map<dynamic, dynamic> to Map<String, String>', () {
      final Map<dynamic, dynamic> data = {1: 100, 'key': true};
      final result = data.toParams;
      expect(result['1'], '100');
      expect(result['key'], 'true');
      expect(result, isA<Map<String, String>>());
    });

    test('toParams returns empty map for non-map objects', () {
      expect('string'.toParams, <String, String>{});
      expect(123.toParams, <String, String>{});
      expect(null.toParams, <String, String>{});
    });
  });

  group('RouteAction Async Tests', () {
    test('RouteAction can be asynchronous', () async {
      bool called = false;
      final RouteAction action = (params) async {
        await Future.delayed(const Duration(milliseconds: 10));
        called = true;
      };

      final result = action({});
      expect(result, isA<Future<void>>());
      await result;
      expect(called, true);
    });

    test('RouteAction can be synchronous', () {
      bool called = false;
      final RouteAction action = (params) {
        called = true;
      };

      final result = action({});
      expect(result, isNot(isA<Future<void>>()));
      expect(called, true);
    });
  });

  group('DeepLinkHandler Tests', () {
    testWidgets('DeepLinkHandler can be re-initialized with new context',
        (tester) async {
      final handler = DeepLinkHandler();

      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (context) {
          handler.init(context);
          return const Text('Home');
        }),
      ));

      expect(find.text('Home'), findsOneWidget);

      // Re-init with new context (e.g. after navigation)
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (context) {
          handler.init(context);
          return const Text('New Context');
        }),
      ));

      expect(find.text('New Context'), findsOneWidget);
    });
  });

  group('NavigationExtension Tab Guard Tests', () {
    testWidgets('handleNavigationOnTab executes guards and allows navigation',
        (tester) async {
      bool tabUpdated = false;
      int? updatedIndex;

      await tester.pumpWidget(MaterialApp(
        // Set current route name to 'main'
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Builder(builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  final result = await context.handleNavigationOnTab(
                    Uri.parse('app://scheme/main?tab=tab1'),
                    config: TabNavigationConfig(
                      getTabIndex: (r) => r == 'tab1' ? 1 : 0,
                      currentTabIndex: 0,
                      updateTabIndex: (idx) {
                        tabUpdated = true;
                        updatedIndex = idx;
                      },
                    ),
                  );
                  expect(result, true);
                },
                child: const Text('Go'),
              );
            }),
          ),
          settings: const RouteSettings(name: 'main'),
        ),
      ));

      // Trigger the route generation
      await tester.pump(); 

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(tabUpdated, true);
      expect(updatedIndex, 1);
    });

    testWidgets('handleNavigationOnTab executes guards and blocks navigation',
        (tester) async {
      bool tabUpdated = false;
      bool redirectTriggered = false;

      // Register redirect route action to verify it was called
      RouteRegistry.registerRoute(
        'login',
        RouteConfig(
          actionRegister: (_) {
            redirectTriggered = true;
          },
        ),
      );

      await tester.pumpWidget(MaterialApp(
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Builder(builder: (context) {
              DeepLinkHandler().init(context);
              return ElevatedButton(
                onPressed: () async {
                  await context.handleNavigationOnTab(
                    Uri.parse('app://scheme/main?tab=tab_blocked'),
                    config: TabNavigationConfig(
                      getTabIndex: (r) => r == 'tab_blocked' ? 1 : 0,
                      currentTabIndex: 0,
                      updateTabIndex: (idx) {
                        tabUpdated = true;
                      },
                    ),
                  );
                },
                child: const Text('Go'),
              );
            }),
          ),
          settings: const RouteSettings(name: 'main'),
        ),
      ));

      await tester.pump();
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(tabUpdated, false,
          reason: 'Tab should not be updated if guard blocks');
      expect(redirectTriggered, true, reason: 'Redirect should be triggered');
    });
  });

  group('TabDeepLinkMixin Tests', () {
    testWidgets('TabDeepLinkMixin initializes DeepLinkHandler', (tester) async {
      int tabIndex = 0;

      await tester.pumpWidget(MaterialApp(
        home: _TestTabWidget(
          onTabChanged: (idx) => tabIndex = idx,
        ),
      ));

      expect(find.text('Tab Content'), findsOneWidget);
    });
  });
}

class _TestTabWidget extends StatefulWidget {
  final ValueChanged<int> onTabChanged;
  const _TestTabWidget({required this.onTabChanged});

  @override
  State<_TestTabWidget> createState() => _TestTabWidgetState();
}

class _TestTabWidgetState extends State<_TestTabWidget> with TabDeepLinkMixin {
  int _index = 0;

  @override
  int get currentTabIndex => _index;

  @override
  void onTabChanged(int index) {
    setState(() => _index = index);
    widget.onTabChanged(index);
  }

  @override
  int mapRouteToTabIndex(String? tabRoute) => tabRoute == 'target' ? 1 : 0;

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Text('Tab Content'));
}
