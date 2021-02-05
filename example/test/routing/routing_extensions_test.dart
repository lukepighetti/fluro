import 'package:example/extensions.dart';
import 'package:example/models/fluro_alias.dart';
import 'package:example/models/fluro_guard.dart';
import 'package:example/models/route_match.dart';
import 'package:flutter_test/flutter_test.dart';

import '../stub_build_context.dart';

void main() {
  group('FluroStringX', () {
    test('sanitizePath', () {
      /// Removes single backslash
      expect('/'.sanitizePath(), equals(''));

      /// Remove bounded backslash
      expect('/test'.sanitizePath(), equals('test'));
      expect('/test/'.sanitizePath(), equals('test'));
      expect('test/'.sanitizePath(), equals('test'));
      expect('test'.sanitizePath(), equals('test'));

      /// Do not remove middle bashslashes
      expect('test/test'.sanitizePath(), equals('test/test'));
      expect('/test/test/'.sanitizePath(), equals('test/test'));

      /// Remove consecutive backslashes
      expect('////test////'.sanitizePath(), equals('test'));
      expect('/////test////test/////'.sanitizePath(), equals('test/test'));

      /// Remove whitespace
      expect(' /te  st  '.sanitizePath(), equals('test'));
    });

    group('route', () {
      test('Route matching', () {
        /// Basic routes
        expect('/'.route('/').matches, isTrue);
        expect('/foo'.route('/foo').matches, isTrue);
        expect('/foo/bar'.route('/foo/bar').matches, isTrue);

        /// Extra/missing slashes
        expect('/foo'.route('foo').matches, isTrue);
        expect('/foo'.route('foo/').matches, isTrue);
        expect('/foo'.route('/foo').matches, isTrue);
        expect('/foo'.route('/foo/').matches, isTrue);

        /// Segment wildcards
        expect('/foo/:wildcard'.route('/foo/bar').matches, isTrue);
        expect('/foo/:wildcard/baz'.route('/foo/bar/baz').matches, isTrue);

        /// Greedy wildcards
        expect('*'.route('/').matches, isTrue);
        expect('/*'.route('/').matches, isTrue);
        expect('/foo/*'.route('/foo/bar').matches, isTrue);
        expect('/foo/*'.route('/foo/bar/baz').matches, isTrue);
        expect('/foo/*'.route('/foo/bar/baz/biff').matches, isTrue);

        /// Uneven paths
        expect('/'.route('/foo').matches, isFalse);
        expect('/foo'.route('/').matches, isFalse);
        expect('/foo'.route('/foo/bar').matches, isFalse);
        expect('/foo/bar'.route('/foo/bar/baz').matches, isFalse);
        expect('/foo/:wildcard'.route('/foo/bar/baz').matches, isFalse);
        expect(
            '/foo/:wildcard/baz'.route('/foo/bar/baz/bing').matches, isFalse);

        /// Double wildcards
        expect('/foo/:a/baz/:c'.route('/foo/bar/baz/biff').matches, isTrue);
      });

      test('Wildcard params', () {
        var params = '/foo/:wildcard'.route('/foo/bar').pathParameters;
        expect(params['wildcard'], equals('bar'));

        params = '/foo/:wildcard/baz'.route('/foo/bar/baz').pathParameters;
        expect(params['wildcard'], equals('bar'));

        params = '/foo/:a/baz/:c'.route('/foo/bar/baz/biff').pathParameters;
        expect(params['a'], equals('bar'));
        expect(params['c'], equals('biff'));
      });

      test('Query params', () {
        RouteMatch result;

        /// One query parameter
        result = '/foo'.route('/foo?bar=yo');

        /// Multiple query parameter
        result = '/foo'.route('/foo?bar=yo&baz=sup');
        expect(result.queryParameters['bar'], equals('yo'));
        expect(result.queryParameters['baz'], equals('sup'));

        /// Wildcard with query parameters
        result = '/foo/:wildcard'.route('/foo/baz?bar=yo');
        expect(result.queryParameters['bar'], equals('yo'));
        expect(result.pathParameters['wildcard'], equals('baz'));
      });
    });
  });

  group('FluroListStringX', () {
    group('route', () {
      test('found', () {
        final routes = [
          "/",
          "/foo",
          "/foo/:bar",
          "/foo/:wildcard/*",
          "*",
        ];

        /// `/`
        var result = routes.route('/');
        expect(result.matches, isTrue);
        expect(result.route, equals('/'));

        /// `/foo`
        result = routes.route('/foo');
        expect(result.matches, isTrue);
        expect(result.route, equals('/foo'));

        /// `/foo/:bar` path parameters
        result = routes.route('/foo/test');
        expect(result.matches, isTrue);
        expect(result.route, equals('/foo/:bar'));
        expect(result.pathParameters['bar'], equals('test'));

        /// `/foo/:wildcard/*` path parameters
        result = routes.route('/foo/test/literally/any/path');
        expect(result.matches, isTrue);
        expect(result.route, equals('/foo/:wildcard/*'));
        expect(result.pathParameters['wildcard'], equals('test'));

        /// `*`
        result = routes.route('/not/found/anywhere');
        expect(result.matches, isTrue);
        expect(result.route, equals('*'));

        /// `/foo/baz/sup?test=42&thing=43` combined parameters
        result = routes.route('/foo/baz/sup?test=42&thing=43');
        expect(result.matches, isTrue);
        expect(result.route, equals('/foo/:wildcard/*'));
        expect(result.parameters['wildcard'], equals('baz'));
        expect(result.parameters['test'], equals('42'));
        expect(result.parameters['thing'], equals('43'));

        /// `/foo?test=42,43,44,45` list in query parameters
        result = routes.route('/foo?test=42,43,44,45');
        expect(result.matches, isTrue);
        expect(result.route, equals('/foo'));
        var test = result.parameters['test'] ?? '';
        expect(test, equals('42,43,44,45'));
        expect(test.split(','), containsAllInOrder(['42', '43', '44', '45']));

        /// `/foo/42,43,44,45` list in path parameters
        result = routes.route('/foo/42,43,44,45');
        expect(result.matches, isTrue);
        expect(result.route, equals('/foo/:bar'));
        var bar = result.parameters['bar'] ?? '';
        expect(bar, equals('42,43,44,45'));
        expect(bar.split(','), containsAllInOrder(['42', '43', '44', '45']));
      });

      test('not found', () {
        final routes = [
          "/",
        ];

        /// `/`
        var result = routes.route('/');
        expect(result.matches, isTrue);

        /// `/foo`
        result = routes.route('/foo');
        expect(result.matches, isFalse);
      });
    });
  });

  group('FluroListFluroAliasX', () {
    test('route', () {
      final context = StubBuildContext();

      final aliases = [
        FluroAlias('/alias', (context, params) {
          return '/alias/redirect';
        }),
        FluroAlias('/alias/:uid', (context, params) {
          /// Params are automatically passed through
          return '/alias/:uid/redirect';
        }),
      ];

      /// `/alias` => `/alias/redirect` via `/alias`
      var result = aliases.route(context, '/alias');
      expect(result.matches, isTrue);
      expect(result.route, equals('/alias/redirect'));

      /// `/alias/:uid` => `/alias/:uid/redirect`via `/alias/user_id`
      result = aliases.route(context, '/alias/user_id');
      expect(result.matches, isTrue);
      expect(result.route, equals('/alias/:uid/redirect'));
      expect(result.parameters, containsPair('uid', 'user_id'));

      /// `/alias/:uid` => `/alias/:uid/redirect` via `/alias/user_id?foo=42&bar=43`
      result = aliases.route(context, '/alias/user_id?foo=42&bar=43');
      expect(result.matches, isTrue);
      expect(result.route, equals('/alias/:uid/redirect'));
      expect(result.parameters, containsPair('uid', 'user_id'));
      expect(result.parameters, containsPair('foo', '42'));
      expect(result.parameters, containsPair('bar', '43'));

      /// None found
      result = aliases.route(context, '/');
      expect(result.matches, isFalse);
    });
  });

  group('FluroListFluroGuardX', () {
    test('route', () {
      final context = StubBuildContext();

      bool isAuthenticated = false;
      bool hasOnboarded = false;

      /// Auth guard
      final authGuard = FluroGuard((context, params) {
        if (isAuthenticated == false) return '/login';
      });

      /// Onboarding guard
      final onboardingGuard = FluroGuard((context, params) {
        if (hasOnboarded == false) return '/onboarding';
      });

      /// Parameter guard
      final parameterGuard = FluroGuard((context, params) {
        if (params['uid'] == 'me') return '/uid-is-me';
      });

      final guards = [authGuard, onboardingGuard, parameterGuard];

      /// Hasn't authenticated or onboarded
      isAuthenticated = false;
      hasOnboarded = false;
      var result = guards.resolve(context, {});
      expect(result, equals('/login'));

      /// Has authenticated, hasn't onboarded
      isAuthenticated = true;
      hasOnboarded = false;
      result = guards.resolve(context, {});
      expect(result, equals('/onboarding'));

      /// Has authenticated and onboarded
      isAuthenticated = true;
      hasOnboarded = true;
      result = guards.resolve(context, {});
      expect(result, isNull);

      /// Params
      isAuthenticated = true;
      hasOnboarded = true;
      result = guards.resolve(context, {'uid': 'me'});
      expect(result, equals('/uid-is-me'));
    });
  });
}
