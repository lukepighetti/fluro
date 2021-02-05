import 'package:example/models/fluro_guard.dart';
import 'package:example/models/resolved_path.dart';
import 'package:flutter/widgets.dart' show BuildContext, Page;

import '../extensions.dart';

/// Used to build a page from context and params.
typedef FluroPageBuilder = Page Function(
    BuildContext context, Map<String, String> params);

class FluroRoute {
  /// A route with a path, page to display, and optional children.
  FluroRoute(
    this.path, {
    required this.page,
    this.guards = const [],
    this.children = const [],
  });

  /// The path for this route.
  ///
  /// ie `/` or `/user/:user_id/photo/:photo_id`
  final String path;

  /// The page to display
  final FluroPageBuilder page;

  /// A list of guards to resolve when trying to navigate to this route.
  final List<FluroGuard> guards;

  /// A sublist of routes
  final List<FluroRoute> children;

  @override
  String toString() {
    return 'FluroRoute($path)';
  }
}

extension ListFluroRouteX on List<FluroRoute> {
  /// Resolve a list of [FluroRoute] into a list of [String] routes.
  List<ResolvedPath> resolvePaths() {
    final paths = <ResolvedPath>[];

    void _visit(FluroRoute route, String parentPath, int depth,
        Map<int, FluroRoute> parentRouterMap) {
      final path = '$parentPath/${route.path}'.sanitizePath();
      final routerMap = {...parentRouterMap, depth: route};

      if (route.children.isEmpty) {
        paths.add(ResolvedPath("/$path", routerMap));
      } else {
        for (var e in route.children) {
          _visit(e, path, depth + 1, routerMap);
        }
      }
    }

    for (var e in this) {
      _visit(e, '', 0, {});
    }

    return paths;
  }
}
