import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_link_nav/flutter_link_nav.dart';

void main() {
  group('QueryParametersX Tests', () {
    test('getInt returns parsed int or null', () {
      final params = {'id': '123', 'invalid': 'abc', 'missing': ''};
      expect(params.getInt('id'), 123);
      expect(params.getInt('invalid'), null);
      expect(params.getInt('missing'), null);
      expect(params.getInt('not_exists'), null);
    });

    test('getBool returns correct boolean', () {
      final params = {
        'b1': 'true',
        'b2': '1',
        'b3': 'false',
        'b4': '0',
        'b5': 'random'
      };
      expect(params.getBool('b1'), true);
      expect(params.getBool('b2'), true);
      expect(params.getBool('b3'), false);
      expect(params.getBool('b4'), false);
      expect(params.getBool('b5'), false);
      expect(params.getBool('b5', defaultValue: true), true);
    });

    test('getList returns split list', () {
      final params = {'tags': 'flutter,dart,deeplink', 'empty': '', 'one': 'tag'};
      expect(params.getList('tags'), ['flutter', 'dart', 'deeplink']);
      expect(params.getList('empty'), []);
      expect(params.getList('one'), ['tag']);
      expect(params.getList('not_exists'), []);
    });

    test('getEnum returns correct enum', () {
      final params = {'status': 'active', 'invalid': 'unknown'};
      expect(params.getEnum('status', _Status.values), _Status.active);
      expect(params.getEnum('invalid', _Status.values), null);
      expect(params.getEnum('not_exists', _Status.values), null);
    });
  });
}

enum _Status { active, inactive }
