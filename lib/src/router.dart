part of router;

class Router {
  /// The tree structure that stores the defined routes
  RouteTree _routeTree = new RouteTree();

  /// Generic handler for when a route has not been defined
  AppRoute notFoundRoute;

  /// Creates a custom [Route] definition
  void defineRoute<T extends Route<Null>>(String routePath, {@required RouteCreator creator}) {
    _routeTree.addRoute(new AppRoute(routePath, creator));
  }

  /// Creates a [MaterialPageRoute] definition
  void defineMaterialRoute(String routePath, {@required RouteHandler handler}) {
    RouteCreator creator = (RouteSettings routeSettings, Map<String, String> params) {
      return new MaterialPageRoute<Null>(settings: routeSettings, builder: (BuildContext context) {
        return handler(params);
      });
    };
    _routeTree.addRoute(new AppRoute(routePath, creator));
  }

  void addRoute(AppRoute route) {
    _routeTree.addRoute(route);
  }

  AppRoute match(String path) {
    AppRouteMatch match = _routeTree.matchRoute(path);
    return match?.route ?? notFoundRoute;
  }

  /// used by the [MaterialApp.onGenerateRoute] function as callback to
  /// create a route that is able to be consumed.
  Route<Null> generator(RouteSettings routeSettings) {
    AppRouteMatch match = _routeTree.matchRoute(routeSettings.name);
    AppRoute route = match?.route ?? notFoundRoute;
    if (route == null) {
      return null;
    }
    Map<String, String> parameters = match?.parameters ?? <String, String>{};
    return route.routeCreator(routeSettings, parameters);
  }

  /// Prints the route tree so you can analyze it.
  void printTree() {
    _routeTree.printTree();
  }
}
