import 'package:example/fluro.dart';
import 'package:example/models/fluro_alias.dart';
import 'package:example/models/fluro_guard.dart';
import 'package:example/models/fluro_route.dart';
import 'package:example/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'stub_build_context.dart';

void main() {
  /// Redirects to `/login` if we're not authenticated
  final authenticationGuard = FluroGuard((context, params) {
    if (context.isAuthenticated == false) return '/login';
  });

  /// The router to exercise in this test suite
  final router = _TestRouter(
    fallbackPage: (context, params) => _stubPage('fallback page'),
    aliases: [
      FluroAlias(
        '/user/random',
        (context, params) => '/user/${context.randomUid}/profile',
      ),
      FluroAlias(
        '/user/:uid',
        (context, params) => '/user/${params['uid']}/profile',
      ),
      FluroAlias(
        '/timeline',
        (context, params) => '/timeline/latest',
      ),
      FluroAlias(
        '/onboarding',
        (context, params) => '/onboarding/welcome',
      ),
    ],
    routes: [
      FluroRoute(
        '/user/:uid',
        page: (_, params) => _stubPage('/user/${params['uid']}'),
        children: [
          FluroRoute(
            '/profile',
            page: (_, params) => _stubPage('/profile'),
          ),
          FluroRoute(
            '/photos',
            page: (_, params) => _stubPage('/photos'),
          ),
          FluroRoute(
            '/likes',
            page: (_, params) => _stubPage('/likes'),
          ),
        ],
      ),
      FluroRoute(
        '/timeline',
        guards: [authenticationGuard],
        page: (context, params) => _stubPage('/timeline'),
        children: [
          FluroRoute(
            '/new',
            page: (context, params) => _stubPage('/new'),
          ),
          FluroRoute(
            '/hot',
            page: (context, params) => _stubPage('/hot'),
          ),
          FluroRoute(
            '/nearby',
            page: (context, params) => _stubPage('/nearby'),
          ),
        ],
      ),
      FluroRoute(
        '/login',
        page: (context, params) => _stubPage('/login'),
      ),
      FluroRoute(
        '/onboarding',
        page: (context, params) => _stubPage('/onboarding'),
        children: [
          FluroRoute(
            '/welcome',
            page: (context, params) => _stubPage('/welcome'),
          ),
          FluroRoute(
            '/location',
            guards: [
              FluroGuard((context, params) {
                if (context.locationPermissionIsGranted)
                  return '/onboarding/camera';
              }),
            ],
            page: (context, params) => _stubPage('/location'),
          ),
          FluroRoute(
            '/camera',
            guards: [
              FluroGuard((context, params) {
                if (context.cameraPermissionIsGranted)
                  return '/onboarding/complete';
              }),
            ],
            page: (context, params) => _stubPage('/camera'),
          ),
          FluroRoute(
            '/complete',
            page: (context, params) => _stubPage('/complete'),
          ),
        ],
      ),
      FluroRoute(
        '*',
        page: (context, params) => _stubPage('Route not found'),
      ),
    ],
  );

  group('FluroRouterMixin', () {
    test('Resolve flattened paths', () {
      final resolvedPaths = router.routes.resolvePaths();
      final flattenedPaths = resolvedPaths.map((e) => e.route);

      /// Quick check all paths
      final expected = [
        '/user/:uid/profile',
        '/user/:uid/photos',
        '/user/:uid/likes',
        '/timeline/new',
        '/timeline/hot',
        '/timeline/nearby',
        '/login',
        '/onboarding/welcome',
        '/onboarding/location',
        '/onboarding/camera',
        '/onboarding/complete',
        '/*',
      ];

      expect(flattenedPaths, containsAllInOrder(expected));
      expect(flattenedPaths.length, equals(expected.length));

      /// Quick check that we didn't make any easy mistakes
      expect(flattenedPaths, isNot(contains('/user')));
      expect(flattenedPaths, isNot(contains('/timeline')));
    });

    test('routerMap', () {
      final resolvedPaths = router.routes.resolvePaths();

      /// 1 deep `/`
      var path = resolvedPaths.firstWhere((e) => e.route == '/login');
      expect(path.routerMap.length, equals(1));
      expect(path.routerMap[0]!.path, equals('/login'));

      /// 2 deep `/timeline/new`
      path = resolvedPaths.firstWhere((e) => e.route == '/timeline/new');
      expect(path.routerMap.length, equals(2));
      expect(path.routerMap[0]!.path, equals('/timeline'));
      expect(path.routerMap[1]!.path, equals('/new'));

      /// 2 deep `/user/:uid/profile` with wildcard
      path = resolvedPaths.firstWhere((e) => e.route == '/user/:uid/profile');
      expect(path.routerMap.length, equals(2));
      expect(path.routerMap[0]!.path, equals('/user/:uid'));
      expect(path.routerMap[1]!.path, equals('/profile'));

      /// 1 deep `*`
      path = resolvedPaths.firstWhere((e) => e.route == '/*');
      expect(path.routerMap.length, equals(1));
      expect(path.routerMap[0]!.path, equals('*'));
    });

    group('ResolvedPath', () {
      test('guards', () {
        final context = StubBuildContext();

        final resolvedPaths = router.routes.resolvePaths();

        /// 2 deep `/timeline/new` with a guard on `/timeline`
        var path = resolvedPaths.firstWhere((e) => e.route == '/timeline/new');
        expect(path.guards.length, equals(1));

        StubBuildContextX.stubAuthenticated = false;
        expect(context.isAuthenticated, isFalse);
        expect(path.guards.resolve(context, {}), equals('/login'));

        StubBuildContextX.stubAuthenticated = true;
        expect(context.isAuthenticated, isTrue);
        expect(path.guards.resolve(context, {}), isNull);
      });
    });

    test('route resolved paths', () {
      final resolvedPaths = router.routes.resolvePaths();

      /// 1 deep `/`
      var match = resolvedPaths.route('/login');
      expect(match.routerMap.length, equals(1));
      expect(match.routerMap[0]!.path, equals('/login'));

      /// 2 deep `/timeline/new`
      match = resolvedPaths.route('/timeline/new');
      expect(match.routerMap.length, equals(2));
      expect(match.routerMap[0]!.path, equals('/timeline'));
      expect(match.routerMap[1]!.path, equals('/new'));

      /// 2 deep `/user/:uid/profile` with wildcard
      match = resolvedPaths.route('/user/user_id/profile');
      expect(match.routerMap.length, equals(2));
      expect(match.routerMap[0]!.path, equals('/user/:uid'));
      expect(match.routerMap[1]!.path, equals('/profile'));
      expect(match.parameters['uid'], equals('user_id'));

      /// 1 deep `*` with query parameters
      match = resolvedPaths.route('no/match/for/this/route?foo=42&bar=43');
      expect(match.routerMap.length, equals(1));
      expect(match.routerMap[0]!.path, equals('*'));
      expect(match.parameters['foo'], equals('42'));
      expect(match.parameters['bar'], equals('43'));
    });

    test('Routing through aliases, routes, guards', () {
      final context = StubBuildContext();

      /// `/login` 1 deep, no aliases, no guards, no wildcards
      var match = router.route(context, '/login');
      expect(match.matches, isTrue);
      expect(match.parameters, isEmpty);
      expect(match.path, equals('/login'));

      /// `/timeline/new` 2 deep, no aliases, 1 guards, no wildcards
      StubBuildContextX.stubAuthenticated = true;
      expect(context.isAuthenticated, isTrue);
      match = router.route(context, '/timeline/new');
      expect(match.route, equals('/timeline/new'));
      expect(match.matches, isTrue);

      StubBuildContextX.stubAuthenticated = false;
      expect(context.isAuthenticated, isFalse);
      match = router.route(context, '/timeline/new');
      expect(match.route, equals('/login'));
      expect(match.matches, isTrue);
    });
  });
}

class _TestRouter with FluroRouterMixin {
  /// A minimal implementation of [FluroRouterMixin] for test purposes.
  _TestRouter({
    required this.fallbackPage,
    required this.routes,
    required this.aliases,
  });

  @override
  final List<FluroRoute> routes;

  @override
  final List<FluroAlias> aliases;

  @override
  final FluroPageBuilder fallbackPage;
}

/// A stub page that does nothing.
MaterialPage _stubPage([String message = '']) {
  return MaterialPage(
    child: Scaffold(
      body: Center(
        child: Text(message),
      ),
    ),
  );
}
