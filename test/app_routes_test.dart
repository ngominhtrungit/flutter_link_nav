import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_link_nav/flutter_link_nav.dart';

// Mocks a basic route for testing predicates
class MockRoute<T> extends Route<T> {
  MockRoute(String? name) : super(settings: RouteSettings(name: name));
}

void main() {
  group('AppRoutes.withName predicate Tests', () {
    setUp(() {
      // Setup some routes in the registry for testing smart match
      RouteRegistry.registerRoute('detail', const RouteConfig());
      RouteRegistry.registerRoute('detail/:id', const RouteConfig());
      RouteRegistry.registerRoute('course/:courseId/lesson/:lessonId', const RouteConfig());
    });

    test('exact match returns true', () {
      final predicate = AppRoutes.withName('main_screen');
      final route = MockRoute('main_screen');
      
      expect(predicate(route), isTrue);
    });

    test('null route name returns false', () {
      final predicate = AppRoutes.withName('main_screen');
      final route = MockRoute(null);
      
      expect(predicate(route), isFalse);
    });

    test('mismatched route returns false', () {
      final predicate = AppRoutes.withName('main_screen');
      final route = MockRoute('other_screen');
      
      expect(predicate(route), isFalse);
    });

    test('smart match returns true for path parameters pattern', () {
      // The user wants to pop to the route definition 'detail/:id'
      final predicate = AppRoutes.withName('detail/:id');
      
      // The current stack route has the actual URL 'detail/999'
      final route = MockRoute('detail/999');
      
      expect(predicate(route), isTrue);
    });

    test('smart match returns false when pattern does not match', () {
      // The user wants to pop to 'detail/:id'
      final predicate = AppRoutes.withName('detail/:id');
      
      // The current stack route has 'detail/999/extra' which doesn't match the pattern exactly
      final route = MockRoute('detail/999/extra');
      
      expect(predicate(route), isFalse);
    });

    test('complex path parameter matches correctly', () {
      final predicate = AppRoutes.withName('course/:courseId/lesson/:lessonId');
      final route = MockRoute('course/flutter/lesson/1');
      
      expect(predicate(route), isTrue);
    });
  });
}
