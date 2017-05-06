/*
 * router
 * A Posse Production
 * http://goposse.com
 * Copyright (c) 2017 Posse Productions LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */
part of router;

enum TransitionType {
  native,
  nativeModal,
}

class Router {
  /// The tree structure that stores the defined routes
  RouteTree _routeTree = new RouteTree();

  /// Generic handler for when a route has not been defined
  RouteHandler notFoundHandler;

  /// Creates a [PageRoute] definition for the passed [RouteHandler]. You can optionally provide a custom
  /// transition builder for the route.
  void define(String routePath, {@required RouteHandler handler}) {
    _routeTree.addRoute(new AppRoute(routePath, handler));
  }

  /// Finds a defined [AppRoute] for the path value. If no [AppRoute] definition was found
  /// then function will return null.
  AppRouteMatch match(String path) {
    return _routeTree.matchRoute(path);
  }

  ///
  void navigateTo(BuildContext context, String path, {TransitionType transition = TransitionType.native}) {
    Route<Null> route;
    if (transition == TransitionType.native) {
      route = matchRoute(path);
    }
    if (route == null && notFoundHandler != null) {
      route = _notFoundRoute(context, path);
    }
    if (route != null) {
      Navigator.push(context, route);
    } else {
      print("No registered route was found to handle '$path'.");
    }
  }

  ///
  Route<Null> _notFoundRoute(BuildContext context, String path) {
    RouteCreator creator = (RouteSettings routeSettings, Map<String, String> params) {
      return new MaterialPageRoute<Null>(settings: routeSettings, builder: (BuildContext context) {
        return notFoundHandler(params);
      });
    };
    return creator(new RouteSettings(name: path), null);
  }

  ///
  Route<Null> matchRoute(String path, {RouteSettings routeSettings = null}) {
    RouteSettings settingsToUse = routeSettings;
    if (routeSettings == null) {
      settingsToUse = new RouteSettings(name: path);
    }
    AppRouteMatch match = _routeTree.matchRoute(path);
    AppRoute route = match?.route;
    if (route == null && notFoundHandler == null) {
      return null;
    }
    RouteHandler handler = (route != null ? route.handler : notFoundHandler);
    Map<String, String> parameters = match?.parameters ?? <String, String>{};
    RouteCreator creator = (RouteSettings routeSettings, Map<String, String> params) {
      return new MaterialPageRoute<Null>(settings: routeSettings, builder: (BuildContext context) {
        return handler(params);
      });
    };
    return creator(settingsToUse, parameters);
  }

  /// Route generation method. This function can be used as a way to create routes on-the-fly
  /// if any defined handler is found. It can also be used with the [MaterialApp.onGenerateRoute]
  /// property as callback to create routes that can be used with the [Navigator] class.
  Route<Null> generator(RouteSettings routeSettings) {
    return matchRoute(routeSettings.name, routeSettings: routeSettings);
  }

  /// Prints the route tree so you can analyze it.
  void printTree() {
    _routeTree.printTree();
  }
}
