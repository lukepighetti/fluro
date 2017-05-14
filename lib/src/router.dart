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
  inFromLeft,
  inFromRight,
  inFromBottom,
  fadeIn,
  custom, // if using custom then you must also provide a transition
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
  void navigateTo(BuildContext context, String path, {TransitionType transition = TransitionType.native,
    Duration transitionDuration = const Duration(milliseconds: 250),
    RouteTransitionsBuilder transitionBuilder})
  {
    Route<Null> route = matchRoute(path, transitionType: transition,
        transitionsBuilder: transitionBuilder, transitionDuration: transitionDuration);
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
  Route<Null> matchRoute(String path, {RouteSettings routeSettings = null,
    TransitionType transitionType, Duration transitionDuration = const Duration(milliseconds: 250),
    RouteTransitionsBuilder transitionsBuilder})
  {
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
      bool isNativeTransition = (transitionType == TransitionType.native || transitionType == TransitionType.nativeModal);
      if (isNativeTransition) {
        return new MaterialPageRoute<Null>(settings: routeSettings, fullscreenDialog: transitionType == TransitionType.nativeModal,
            builder: (BuildContext context) {
              return handler(params);
            });
      } else {
        var routeTransitionsBuilder;
        if (transitionType == TransitionType.custom) {
          routeTransitionsBuilder = transitionsBuilder;
        } else {
          routeTransitionsBuilder = _standardTransitionsBuilder(transitionType);
        }
        return new PageRouteBuilder<Null>(settings: routeSettings,
          pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
            return handler(params);
          },
          transitionDuration: transitionDuration,
          transitionsBuilder: routeTransitionsBuilder,
        );
      }
    };
    return creator(settingsToUse, parameters);
  }

  RouteTransitionsBuilder _standardTransitionsBuilder(TransitionType transitionType) {
    return (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
      if (transitionType == TransitionType.fadeIn) {
        return new FadeTransition(opacity: animation, child: child);
      } else {
        FractionalOffset startOffset = FractionalOffset.bottomLeft;
        FractionalOffset endOffset = FractionalOffset.topLeft;
        if (transitionType == TransitionType.inFromLeft) {
          startOffset = new FractionalOffset(-1.0, 0.0);
          endOffset = FractionalOffset.topLeft;
        } else if (transitionType == TransitionType.inFromRight) {
          startOffset = FractionalOffset.topRight;
          endOffset = FractionalOffset.topLeft;
        }

        return new SlideTransition(
          position: new FractionalOffsetTween(
            begin: startOffset,
            end: endOffset,
          ).animate(animation),
          child: child,
        );
      }
    };
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
