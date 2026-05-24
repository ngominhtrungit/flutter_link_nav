import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_link_nav/flutter_link_nav.dart';
import 'package:flutter_link_nav/src/deeplink/deep_link_listener.dart';

// A mock listener to avoid MethodChannel calls during widget tests.
class MockDeepLinkListener implements DeepLinkListener {
  final StreamController<Uri> _uriController = StreamController<Uri>.broadcast();

  @override
  Future<Uri?> getInitialLink() async => null;

  @override
  void init(BuildContext context) {}

  @override
  Stream<Uri> get uriLinkStream => _uriController.stream;

  void emitUri(Uri uri) {
    _uriController.add(uri);
  }
}

void main() {
  setUp(() {
    // Initialize DeepLinkHandler with a mock listener so it doesn't crash
    // when TabDeepLinkMixin calls DeepLinkHandler().init(...)
    DeepLinkHandler(listener: MockDeepLinkListener());
  });

  group('TabDeepLinkBuilder Widget Tests', () {
    testWidgets('renders correctly and defaults to defaultIndex', (WidgetTester tester) async {
      int builtIndex = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TabDeepLinkBuilder(
              routeToIndexMap: const {
                'home': 0,
                'search': 1,
                'profile': 2,
              },
              builder: (context, currentIndex, onTabChanged) {
                builtIndex = currentIndex;
                return Text('Current Index: $currentIndex');
              },
            ),
          ),
        ),
      );

      expect(builtIndex, 0);
      expect(find.text('Current Index: 0'), findsOneWidget);
    });

    testWidgets('uses initialRoute to set initial index', (WidgetTester tester) async {
      int builtIndex = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TabDeepLinkBuilder(
              initialRoute: 'search',
              routeToIndexMap: const {
                'home': 0,
                'search': 1,
                'profile': 2,
              },
              builder: (context, currentIndex, onTabChanged) {
                builtIndex = currentIndex;
                return Text('Current Index: $currentIndex');
              },
            ),
          ),
        ),
      );

      expect(builtIndex, 1);
      expect(find.text('Current Index: 1'), findsOneWidget);
    });

    testWidgets('falls back to defaultIndex when initialRoute is unknown', (WidgetTester tester) async {
      int builtIndex = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TabDeepLinkBuilder(
              initialRoute: 'unknown',
              defaultIndex: 2,
              routeToIndexMap: const {
                'home': 0,
                'search': 1,
              },
              builder: (context, currentIndex, onTabChanged) {
                builtIndex = currentIndex;
                return Text('Current Index: $currentIndex');
              },
            ),
          ),
        ),
      );

      expect(builtIndex, 2);
      expect(find.text('Current Index: 2'), findsOneWidget);
    });

    testWidgets('calls onTabChanged updates index and rebuilds UI', (WidgetTester tester) async {
      int builtIndex = -1;
      late ValueChanged<int> changeTab;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TabDeepLinkBuilder(
              routeToIndexMap: const {
                'home': 0,
                'search': 1,
              },
              builder: (context, currentIndex, onTabChanged) {
                builtIndex = currentIndex;
                changeTab = onTabChanged;
                return Text('Current Index: $currentIndex');
              },
            ),
          ),
        ),
      );

      expect(builtIndex, 0);
      expect(find.text('Current Index: 0'), findsOneWidget);

      // Programmatically change tab
      changeTab(1);
      await tester.pumpAndSettle();

      expect(builtIndex, 1);
      expect(find.text('Current Index: 1'), findsOneWidget);
    });
  });
}
