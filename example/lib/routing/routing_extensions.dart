import 'package:example/routing/route_match.dart';

import 'fluro_route.dart';

extension ListFluroRouteX on List<FluroRoute> {
  /// Resolve a list of [FluroRoute] into a list of [String] routes.
  List<String> resolvePaths() {
    /// The list of resolved paths
    final paths = <String>[];

    void _visit(List<FluroRoute> routes, String parentPath) {
      for (var e in routes) {
        final trimmedPath = e.path.sanitizePath();
        final path = '$parentPath/$trimmedPath';
        paths.add(path);
        _visit(e.children, path);
      }
    }

    _visit(this, '');

    return paths;
  }
}

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
    return RouteMatch(
      matches: false,
      pathParameters: {},
      path: path,
      route: '',
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
