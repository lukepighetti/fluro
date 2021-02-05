import 'package:example/models/fluro_route.dart';
import 'package:example/models/resolved_path.dart';
import 'package:example/extensions.dart';
import 'package:example/view/fluro_view.dart';
import 'package:flutter/material.dart';

import 'models/fluro_alias.dart';
import 'models/resolved_path_match.dart';

class FluroRouteInformationParser extends RouteInformationParser<String> {
  @override
  Future<String> parseRouteInformation(
      RouteInformation routeInformation) async {
    /// Print the route information when it comes in.
    ///
    /// What is [routeInformation.state]?
    debugPrint({
      'location': routeInformation.location,
      'state': routeInformation.state,
    }.toString());

    final location = routeInformation.location;

    if (location == null)
      throw StateError('routeInformation.location is null!');

    return location;
  }
}

class FluroRouterDelegate extends RouterDelegate<FluroConfiguration>
    with
        ChangeNotifier,
        PopNavigatorRouterDelegateMixin,
        FluroRouterMixin,
        FluroViewDescendents {
  FluroRouterDelegate({
    required this.routes,
    required this.aliases,
    required this.fallbackPage,
  });

  @override
  final List<FluroRoute> routes;

  @override
  final List<FluroAlias> aliases;

  @override
  final FluroPageBuilder fallbackPage;

  @visibleForTesting
  final pages = <Page>[];

  /// Update the router tree and push the resulting page chunks down to each [FluroView]
  void updateRouterTree() {
    pruneDescendents();
    linkRoutesAndViews();
    print('updateRouterTree');
  }

  /// The paths for the route
  late final routePaths = routes.resolvePaths();

  void linkRoutesAndViews() {}

  bool _handlePopPage(Route<dynamic> route, dynamic result) {
    debugPrint('handlePopPage route: $route, result: $result');

    return false;
  }

  Route<dynamic>? _handleGenerateRoute(RouteSettings? settings) {
    print('handleGenerateRoute($settings)');
  }

  @override
  void dispose() {
    pruneDescendents();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onPopPage: _handlePopPage,
      onGenerateRoute: _handleGenerateRoute,
      pages: [EmptyPage(), ...pages],
    );
  }

  @override
  Future<bool> popRoute() {
    throw UnimplementedError();
  }

  @override
  Future<void> setNewRoutePath(FluroConfiguration configuration) {
    throw UnimplementedError();
  }

  @override
  final navigatorKey = GlobalKey<NavigatorState>();
}

class FluroConfiguration {}

mixin FluroRouterMixin {
  /// The page to fallback on if you can't find one to build.
  FluroPageBuilder get fallbackPage;

  /// A list of aliases.
  List<FluroAlias> get aliases;

  /// A list of routes
  List<FluroRoute> get routes;

  /// Without `late` keyword this would fail. Works nice in this context.
  @visibleForTesting
  late final List<ResolvedPath> resolvedPaths = routes.resolvePaths();

  /// Given a path, resolve a route.
  ///
  /// Our route path goes `aliases => routes => authenticationGuard => guards => fallbackPage`
  ///
  /// We always resolve the first matching alias, route, and guard.
  ResolvedPathMatch route(BuildContext context, String path) {
    var workingPath = path;

    /// Route aliases
    final aliasMatch = aliases.route(context, workingPath);
    if (aliasMatch.matches) workingPath = aliasMatch.route;

    /// Route resolved path routes
    final resolvedPathMatch = resolvedPaths.route(workingPath);
    if (resolvedPathMatch.matches) {
      /// Resolve our route guards
      final guardRoute = resolvedPathMatch.resolvedPath.guards
          .resolve(context, resolvedPathMatch.parameters);

      /// Failed a guard
      if (guardRoute != null) {
        workingPath = guardRoute;
      }

      /// Passed all guards
      else {
        workingPath = resolvedPathMatch.route;
      }
    }

    /// Working path has now been routed through aliases, routes, and route guards.
    ///
    /// Now resolve it to a final [RouteMatch] 🤜
    final resolvedRouteMatch = resolvedPaths.route(workingPath);

    return resolvedRouteMatch;
  }
}
