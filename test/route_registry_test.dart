import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_link_nav/src/route/route_registry.dart';

void main() {
  group('RouteRegistry matchRoute Tests', () {
    setUp(() {
      // Clear routes before each test using reflection or by just registering over them.
      // Since _routes is private and static, we'll just register the ones we need for tests
      // and rely on specific route names.
      RouteRegistry.registerRoute('home', const RouteConfig());
      RouteRegistry.registerRoute('user/:id', const RouteConfig());
      RouteRegistry.registerRoute('course/:courseId/lesson/:lessonId', const RouteConfig());
      RouteRegistry.registerRoute('profile', const RouteConfig());
    });

    test('exact match returns correct route without params', () {
      final match = RouteRegistry.matchRoute('home');
      expect(match, isNotNull);
      expect(match!.matchedRouteName, 'home');
      expect(match.pathParams, isEmpty);
    });

    test('match with one path parameter', () {
      final match = RouteRegistry.matchRoute('user/123');
      expect(match, isNotNull);
      expect(match!.matchedRouteName, 'user/:id');
      expect(match.pathParams, {'id': '123'});
    });

    test('match with multiple path parameters', () {
      final match = RouteRegistry.matchRoute('course/flutter101/lesson/5');
      expect(match, isNotNull);
      expect(match!.matchedRouteName, 'course/:courseId/lesson/:lessonId');
      expect(match.pathParams, {'courseId': 'flutter101', 'lessonId': '5'});
    });

    test('fails to match when path is too long or short', () {
      final match1 = RouteRegistry.matchRoute('user'); // Too short
      expect(match1, isNull);

      final match2 = RouteRegistry.matchRoute('user/123/extra'); // Too long
      expect(match2, isNull);
    });

    test('fails to match unknown static segments', () {
      final match = RouteRegistry.matchRoute('course/flutter101/invalid/5');
      expect(match, isNull);
    });
    
    test('matchRoute with leading or trailing slashes (should be handled by caller/UriParser usually, but test exact match behavior)', () {
      // RouteRegistry splits by '/' and ignores empty segments thanks to .where((s) => s.isNotEmpty)
      final match1 = RouteRegistry.matchRoute('/user/123/');
      expect(match1, isNotNull);
      expect(match1!.pathParams, {'id': '123'});
      
      final match2 = RouteRegistry.matchRoute('//course/abc///lesson/2');
      expect(match2, isNotNull);
      expect(match2!.pathParams, {'courseId': 'abc', 'lessonId': '2'});
    });
  });
}
