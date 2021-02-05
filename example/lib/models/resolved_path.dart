import 'package:example/models/fluro_guard.dart';

import '../extensions.dart';
import 'fluro_route.dart';
import 'resolved_path_match.dart';

class ResolvedPath {
  /// A path that has been resolved to a flattened path and a mapping
  /// of router tree depth to route. This is used to walk the router tree
  /// so we can place the correct route.
  ResolvedPath(this.route, this.routerMap);

  /// The path flattened completely.
  ///
  /// Ie `/ => /foo => /bar` is `/foo/bar`
  final String route;

  /// Mapping router depth to route
  final Map<int, FluroRoute> routerMap;

  /// A flattened list of guards for this resolved path
  late final List<FluroGuard> guards =
      routerMap.values.fold([], (e, i) => [...e, ...i.guards]);

  @override
  String toString() => 'ResolvedPath($route)';
}

extension FluroListResolvedPathX on List<ResolvedPath> {
  /// Assuming this list is a bunch of routing paths, find the right match.
  ResolvedPathMatch route(String path) {
    for (var resolvedPath in this) {
      final result = resolvedPath.route.route(path);

      if (result.matches) {
        return ResolvedPathMatch(resolvedPath, result);
      }
    }

    /// None found
    return ResolvedPathMatch.notFound(
      path: path,
    );
  }
}
