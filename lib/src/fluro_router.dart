/*
 * fluro
 * Created by Yakka
 * https://theyakka.com
 * 
 * Copyright (c) 2019 Yakka, LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'dart:async';

import 'package:fluro/fluro.dart';
import 'package:fluro/src/common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// {@template fluro_router}
/// Attach [FluroRouter] to [MaterialApp] by connnecting [FluroRouter.generator] to [MaterialApp.onGenerateRoute].
///
/// Define routes with [FluroRouter.define], optionally specifying transition types and connecting string path params to
/// your screen widget's constructor.
///
/// Push new route paths with [FluroRouter.appRouter.navigateTo] or continue to use [Navigator.of(context).push] if you prefer.
/// {@endtemplate}
class FluroRouter {
  /// The static / singleton instance of [FluroRouter]
  ///
  /// {@macro fluro_router}
  static final appRouter = FluroRouter();

  /// The tree structure that stores the defined routes
  final RouteTree _routeTree = RouteTree();

  /// Generic handler for when a route has not been defined
  Handler notFoundHandler;

  /// Creates a [PageRoute] definition for the passed [RouteHandler]. You can optionally provide a default transition type.
  void define(String routePath,
      {@required Handler handler,
      TransitionType transitionType,
      Duration transitionDuration = const Duration(milliseconds: 250),
      RouteTransitionsBuilder transitionBuilder}) {
    _routeTree.addRoute(
      AppRoute(routePath, handler,
          transitionType: transitionType,
          transitionDuration: transitionDuration,
          transitionBuilder: transitionBuilder),
    );
  }

  /// Finds a defined [AppRoute] for the path value. If no [AppRoute] definition was found
  /// then function will return null.
  AppRouteMatch match(String path) {
    return _routeTree.matchRoute(path);
  }

  /// Similar to [Navigator.pop]
  void pop<T>(BuildContext context, [T result]) =>
      Navigator.of(context).pop(result);

  /// Similar to [Navigator.push] but with a few extra features.
  Future navigateTo(BuildContext context, String path,
      {bool replace = false,
      bool clearStack = false,
      bool maintainState = true,
      bool rootNavigator = false,
      bool nullOk = false,
      TransitionType transition,
      Duration transitionDuration,
      RouteTransitionsBuilder transitionBuilder,
      RouteSettings routeSettings}) {
    RouteMatch routeMatch = matchRoute(context, path,
        transitionType: transition,
        transitionsBuilder: transitionBuilder,
        transitionDuration: transitionDuration,
        maintainState: maintainState,
        routeSettings: routeSettings);
    Route<dynamic> route = routeMatch.route;
    Completer completer = Completer();
    Future future = completer.future;
    if (routeMatch.matchType == RouteMatchType.nonVisual) {
      completer.complete("Non visual route type.");
    } else {
      if (route == null && notFoundHandler != null) {
        route = _notFoundRoute(context, path, maintainState: maintainState);
      }
      if (route != null) {
        final navigator =
            Navigator.of(context, rootNavigator: rootNavigator, nullOk: nullOk);
        if (clearStack) {
          future = navigator.pushAndRemoveUntil(route, (check) => false);
        } else {
          future = replace
              ? navigator.pushReplacement(route)
              : navigator.push(route);
        }
        completer.complete();
      } else {
        String error = "No registered route was found to handle '$path'.";
        print(error);
        completer.completeError(RouteNotFoundException(error, path));
      }
    }

    return future;
  }

  Route<Null> _notFoundRoute(BuildContext context, String path,
      {bool maintainState}) {
    RouteCreator<Null> creator =
        (RouteSettings routeSettings, Map<String, List<String>> parameters) {
      return MaterialPageRoute<Null>(
          settings: routeSettings,
          maintainState: maintainState,
          builder: (BuildContext context) {
            return notFoundHandler.handlerFunc(context, parameters);
          });
    };
    return creator(RouteSettings(name: path), null);
  }

  /// Attempt to match a route to the provided [path].
  RouteMatch matchRoute(BuildContext buildContext, String path,
      {RouteSettings routeSettings,
      TransitionType transitionType,
      Duration transitionDuration,
      RouteTransitionsBuilder transitionsBuilder,
      bool maintainState = true}) {
    RouteSettings settingsToUse = routeSettings;
    if (routeSettings == null) {
      settingsToUse = RouteSettings(name: path);
    }
    if (settingsToUse.name == null) {
      settingsToUse = settingsToUse.copyWith(name: path);
    }
    AppRouteMatch match = _routeTree.matchRoute(path);
    AppRoute route = match?.route;

    if (route?.transitionDuration != null) {
      transitionDuration = route?.transitionDuration;
    }

    Handler handler = (route != null ? route?.handler : notFoundHandler);
    var transition = transitionType;
    if (transitionType == null) {
      transition =
          route != null ? route?.transitionType : TransitionType.native;
    }
    if (route == null && notFoundHandler == null) {
      return RouteMatch(
          matchType: RouteMatchType.noMatch,
          errorMessage: "No matching route was found");
    }
    Map<String, List<String>> parameters =
        match?.parameters ?? <String, List<String>>{};
    if (handler.type == HandlerType.function) {
      handler.handlerFunc(buildContext, parameters);
      return RouteMatch(matchType: RouteMatchType.nonVisual);
    }

    RouteCreator creator =
        (RouteSettings routeSettings, Map<String, List<String>> parameters) {
      bool isNativeTransition = (transition == TransitionType.native ||
          transition == TransitionType.nativeModal);
      if (isNativeTransition) {
        return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            fullscreenDialog: transition == TransitionType.nativeModal,
            maintainState: maintainState,
            builder: (BuildContext context) {
              return handler.handlerFunc(context, parameters);
            });
      } else if (transition == TransitionType.material ||
          transition == TransitionType.materialFullScreenDialog) {
        return MaterialPageRoute<dynamic>(
            settings: routeSettings,
            fullscreenDialog:
                transition == TransitionType.materialFullScreenDialog,
            maintainState: maintainState,
            builder: (BuildContext context) {
              return handler.handlerFunc(context, parameters);
            });
      } else if (transition == TransitionType.cupertino ||
          transition == TransitionType.cupertinoFullScreenDialog) {
        return CupertinoPageRoute<dynamic>(
            settings: routeSettings,
            fullscreenDialog:
                transition == TransitionType.cupertinoFullScreenDialog,
            maintainState: maintainState,
            builder: (BuildContext context) {
              return handler.handlerFunc(context, parameters);
            });
      } else {
        var routeTransitionsBuilder;

        if (transition == TransitionType.custom) {
          routeTransitionsBuilder =
              transitionsBuilder ?? route?.transitionBuilder;
        } else {
          routeTransitionsBuilder = _standardTransitionsBuilder(transition);
        }

        return PageRouteBuilder<dynamic>(
          settings: routeSettings,
          maintainState: maintainState,
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return handler.handlerFunc(context, parameters);
          },
          transitionDuration: transition == TransitionType.none
              ? Duration.zero
              : transitionDuration ?? route?.transitionDuration,
          reverseTransitionDuration: transition == TransitionType.none
              ? Duration.zero
              : transitionDuration ?? route?.transitionDuration,
          transitionsBuilder: transition == TransitionType.none
              ? (_, __, ___, child) => child
              : routeTransitionsBuilder,
        );
      }
    };
    return RouteMatch(
      matchType: RouteMatchType.visual,
      route: creator(settingsToUse, parameters),
    );
  }

  RouteTransitionsBuilder _standardTransitionsBuilder(
      TransitionType transitionType) {
    return (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation, Widget child) {
      if (transitionType == TransitionType.fadeIn) {
        return FadeTransition(opacity: animation, child: child);
      } else {
        const Offset topLeft = const Offset(0.0, 0.0);
        const Offset topRight = const Offset(1.0, 0.0);
        const Offset bottomLeft = const Offset(0.0, 1.0);

        Offset startOffset = bottomLeft;
        Offset endOffset = topLeft;
        if (transitionType == TransitionType.inFromLeft) {
          startOffset = const Offset(-1.0, 0.0);
          endOffset = topLeft;
        } else if (transitionType == TransitionType.inFromRight) {
          startOffset = topRight;
          endOffset = topLeft;
        } else if (transitionType == TransitionType.inFromBottom) {
          startOffset = bottomLeft;
          endOffset = topLeft;
        } else if (transitionType == TransitionType.inFromTop) {
          startOffset = Offset(0.0, -1.0);
          endOffset = topLeft;
        }

        return SlideTransition(
          position: Tween<Offset>(
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
  Route<dynamic> generator(RouteSettings routeSettings) {
    RouteMatch match =
        matchRoute(null, routeSettings.name, routeSettings: routeSettings);
    return match.route;
  }

  /// Prints the route tree so you can analyze it.
  void printTree() {
    _routeTree.printTree();
  }
}
