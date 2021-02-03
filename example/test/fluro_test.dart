import 'package:example/fluro.dart';
import 'package:example/routing/fluro_route.dart';
import 'package:example/routing/routing_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// The router to exercise in this test suite
  final router = _TestRouter(
    children: [
      FluroRoute('/', page: _stubPage()),
      FluroRoute('/user/:uid', page: _stubPage(), children: [
        FluroRoute('/photo/:photo_id', page: _stubPage()),
        FluroRoute('/favorites', page: _stubPage(), children: [
          FluroRoute('/all', page: _stubPage()),
        ]),
        FluroRoute('/bar', page: _stubPage()),
      ]),
      FluroRoute('*', page: _stubPage()),
    ],
  );

  group('FluroRouterMixin', () {
    test('Nested route parsing', () {
      final resolvedPaths = router.children.resolvePaths();

      final expected = [
        '/',
        '/user/:uid',
        '/user/:uid/photo/:photo_id',
        '/user/:uid/favorites',
        '/user/:uid/favorites/all',
        '/user/:uid/bar',
        '/*',
      ];

      expect(resolvedPaths, containsAllInOrder(expected));
    });
  });
}

class _TestRouter with FluroRouterMixin {
  /// A minimal implementation of [FluroRouterMixin] for test purposes.
  _TestRouter({required this.children});

  @override
  final List<FluroRoute> children;
}

/// A stub page that does nothing.
MaterialPage _stubPage() {
  return MaterialPage(
    child: SizedBox.shrink(),
  );
}
