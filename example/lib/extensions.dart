import 'package:example/models/route_match.dart';

export 'models/fluro_alias.dart' show FluroListFluroAliasX;
export 'models/fluro_guard.dart' show FluroListFluroGuardX;
export 'models/fluro_route.dart' show ListFluroRouteX;
export 'models/resolved_path.dart' show FluroListResolvedPathX;

extension FluroListStringX on List<String> {
  /// Assuming this list is a bunch of routing paths, find the right match.
  RouteMatch route(String path) {
    for (var route in this) {
      final result = route.route(path);

      if (result.matches) {
        return result;
      }
    }

    /// None found
    return RouteMatch.notFound(
      path: path,
    );
  }
}

extension FluroStringX on String {
  /// Removes whitespace, multiple backslashes, and leading/trailing backslashes.
  String sanitizePath() {
    return this

        /// remove all whitespace
        .replaceAll(RegExp(r'\s'), '')

        /// remove multiple backslashes
        .replaceAll(RegExp(r'\/{2,}'), '/')

        /// remove leading and trailing backslashes
        .replaceAll(RegExp(r'^\/+|\/+$'), '');
  }

  /// Match a path to a route
  ///
  /// ie `/foo/:wildcard => /foo/bar` matches with `{'wildcard': 'bar}` params
  RouteMatch route(String path) {
    final trimmedPath = path.sanitizePath();
    final pathUri = Uri.parse(trimmedPath);
    final pathSegments = ['/', ...pathUri.pathSegments];
    final routeUri = Uri.parse(this);
    final routeSegments = ['/', ...routeUri.pathSegments];

    final matches = <bool>[];
    final params = <String, String>{};

    for (var i = 0; i < routeSegments.length; i++) {
      final routeSegment = routeSegments[i];
      final lastRouteSegment = i == routeSegments.length - 1;

      /// Greedy wildcard
      if (routeSegment == '*') {
        matches.add(true);
        break;
      }

      /// Checks against path
      else {
        final outOfPathBounds = i > pathSegments.length - 1;
        final pathIsLonger = pathSegments.length > routeSegments.length;

        /// Out of path bounds
        if (outOfPathBounds) {
          matches.add(false);
          break;
        }

        /// In bounds
        else {
          final pathSegment = pathSegments[i];

          /// At the end of route segments
          if (lastRouteSegment && pathIsLonger) {
            matches.add(false);
            break;
          }

          /// Exact segment match
          else if (pathSegment == routeSegment) {
            matches.add(true);
            continue;
          }

          /// Segment wildcard
          else if (routeSegment.startsWith(':')) {
            final key = routeSegment.replaceFirst(':', '');
            matches.add(true);
            params[key] = pathSegment;
            continue;
          }

          /// No segment match
          else {
            matches.add(false);
            break;
          }
        }
      }
    }

    return RouteMatch(
      matches: matches.every((e) => e == true),
      pathParameters: params,
      path: path,
      route: this,
    );
  }
}
