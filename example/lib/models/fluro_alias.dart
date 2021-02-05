import 'package:flutter/widgets.dart' show BuildContext;

import '../extensions.dart';
import 'resolved_path_match.dart';
import 'route_match.dart';

/// Used to alias one route to another.
///
/// ie `/timeline => /timeline/latest`
typedef FluroAliasBuilder = String Function(
    BuildContext context, Map<String, String> params);

class FluroAlias {
  /// Used to alias one route to another.
  ///
  /// ie `/timeline => /timeline/latest`
  FluroAlias(this.path, this.builder);

  /// The path to alias.
  ///
  /// ie `/timeline` in `/timeline => /timeline/latest`
  final String path;

  /// The destination path builder.
  ///
  /// ie `/timeline/latest` in `/timeline => /timeline/latest`
  final FluroAliasBuilder builder;
}

extension FluroListFluroAliasX on List<FluroAlias> {
  /// Assuming this list is a bunch of routing paths, find the right match.
  RouteMatch route(BuildContext context, String path) {
    for (var e in this) {
      final routeMatch = e.path.route(path);

      if (routeMatch.matches) {
        final aliasRoute = e.builder(context, routeMatch.parameters);

        return RouteMatch(
          matches: true,
          path: path,
          route: aliasRoute,
          pathParameters: routeMatch.pathParameters,
        );
      }
    }

    /// None found
    return ResolvedPathMatch.notFound(
      path: path,
    );
  }
}
