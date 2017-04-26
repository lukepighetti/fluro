part of router;

class Router {
  /// The tree structure that stores the defined routes
  RouteTree _routeTree = new RouteTree();

  /// Generic handler for when a route has not been defined
  AppRoute notFoundRoute;

  /// Creates a custom [Route] definition
  void defineRoute(String routePath, {@required RouteCreator creator}) {
    _routeTree.addRoute(new AppRoute(routePath, creator));
  }

  /// Creates a [PageRoute] definition for the passed [RouteHandler]. You can optionally provide a custom
  /// transition builder for the route.
  void defineRouteHandler(String routePath, {@required RouteHandler handler, RouteTransitionsBuilder transitionsBuilder,
      Duration duration = const Duration(milliseconds: 250)})
  {
    RouteCreator creator = (RouteSettings routeSettings, Map<String, String> params) {
      return new PageRouteBuilder(settings: routeSettings, transitionDuration: duration,
          transitionsBuilder:  transitionsBuilder,
          pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
            return handler(params);
          });
    };
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

  Route<Null> matchRoute(String path, {RouteSettings routeSettings = null}) {
    RouteSettings settingsToUse = routeSettings;
    if (routeSettings == null) {
      settingsToUse = new RouteSettings(name: path);
    }
    AppRouteMatch match = _routeTree.matchRoute(path);
    AppRoute route = match?.route ?? notFoundRoute;
    if (route == null) {
      return null;
    }
    Map<String, String> parameters = match?.parameters ?? <String, String>{};
    return route.routeCreator(settingsToUse, parameters);
  }

  /// used by the [MaterialApp.onGenerateRoute] function as callback to
  /// create a route that is able to be consumed.
  Route<Null> generator(RouteSettings routeSettings) {
    return matchRoute(routeSettings.name, routeSettings: routeSettings);
  }

  /// Prints the route tree so you can analyze it.
  void printTree() {
    _routeTree.printTree();
  }
}
