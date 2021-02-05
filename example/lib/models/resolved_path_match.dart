import 'package:example/models/fluro_guard.dart';
import 'package:example/models/resolved_path.dart';
import 'package:example/models/route_match.dart';

import 'fluro_route.dart';

class ResolvedPathMatch implements ResolvedPath, RouteMatch {
  /// A data class that contains the sum of [ResolvedPath] and [RouteMatch],
  /// where the [route] property is taken from [ResolvedPath]
  ResolvedPathMatch(this.resolvedPath, this.routeMatch);

  /// The path match to use when there is no result.
  ResolvedPathMatch.notFound({required String path})
      : resolvedPath = ResolvedPath('', {}),
        routeMatch = RouteMatch.notFound(path: path);

  /// The underlying [ResolvedPath]
  final ResolvedPath resolvedPath;

  /// The underlying [RouteMatch]
  final RouteMatch routeMatch;

  @override
  bool get matches => routeMatch.matches;

  @override
  Map<String, String> get parameters => routeMatch.parameters;

  @override
  String get path => routeMatch.path;

  @override
  Map<String, String> get pathParameters => routeMatch.pathParameters;

  @override
  Map<String, String> get queryParameters => routeMatch.queryParameters;

  @override
  String get route => resolvedPath.route;

  @override
  Map<int, FluroRoute> get routerMap => resolvedPath.routerMap;

  @override
  List<FluroGuard> get guards => resolvedPath.guards;
}
