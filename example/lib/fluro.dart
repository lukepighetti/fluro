import 'package:example/routing/fluro_route.dart';
import 'package:example/routing/routing_extensions.dart';
import 'package:flutter/material.dart';

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
    with ChangeNotifier, PopNavigatorRouterDelegateMixin, FluroRouterMixin {
  FluroRouterDelegate({required this.children});

  bool _handlePopPage(Route<dynamic> route, dynamic result) {
    debugPrint('handlePopPage route: $route, result: $result');

    return false;
  }

  Route<dynamic>? _handleGenerateRoute(RouteSettings? settings) {
    ///
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onPopPage: _handlePopPage,
      onGenerateRoute: _handleGenerateRoute,
    );
  }

  @override
  Future<bool> popRoute() {
    // TODO: implement popRoute
    throw UnimplementedError();
  }

  @override
  Future<void> setNewRoutePath(FluroConfiguration configuration) {
    // TODO: implement setNewRoutePath
    throw UnimplementedError();
  }

  @override
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  final List<FluroRoute> children;
}

class FluroConfiguration {}

mixin FluroRouterMixin {
  /// A list of routes
  List<FluroRoute> get children;

  /// Without `late` keyword this would fail. Works nice in this context.
  @visibleForTesting
  late final List<String> resolvedPaths = children.resolvePaths();
}
