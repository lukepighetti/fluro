/*
 * fluro
 * A Posse Production
 * http://goposse.com
 * Copyright (c) 2018 Posse Productions LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */
part of fluro;

abstract class Routable {
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {}
  void didAppear(
    bool wasPushed,
    Route<dynamic> route,
    Route<dynamic> previousRoute,
  ) {}
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {}
}

typedef String ScreenNameExtractor(RouteSettings settings);

String defaultNameExtractor(RouteSettings settings) => settings.name;

class RoutableObserver extends RouteObserver<PageRoute<dynamic>> {
  final ScreenNameExtractor nameExtractor = defaultNameExtractor;

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      final routeWidget = route.buildPage(
          route.navigator.context, route.animation, route.secondaryAnimation);
      if (routeWidget is Routable) {
        Routable w = (routeWidget as Routable);
        w.didPush(route, previousRoute);
        w.didAppear(true, route, previousRoute);
      }
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPop(route, previousRoute);
    if (route is PageRoute) {
      final leavingWidget = route.buildPage(
          route.navigator.context, route.animation, route.secondaryAnimation);
      if (leavingWidget is Routable) {
        Routable w = (leavingWidget as Routable);
        w.didPop(route, previousRoute);
      }
    }
    if (previousRoute is PageRoute) {
      final returningWidget = previousRoute.buildPage(
          previousRoute.navigator.context,
          previousRoute.animation,
          previousRoute.secondaryAnimation);
      if (returningWidget is Routable) {
        Routable w = (returningWidget as Routable);
        w.didAppear(false, route, previousRoute);
      }
    }
  }

  @override
  void didReplace({Route newRoute, Route oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (oldRoute is PageRoute) {
      final leavingWidget = oldRoute.buildPage(oldRoute.navigator.context,
          oldRoute.animation, oldRoute.secondaryAnimation);
      if (leavingWidget is Routable) {
        Routable w = (leavingWidget as Routable);
        w.didPop(oldRoute, newRoute);
      }
    }
    if (newRoute is PageRoute) {
      final returningWidget = newRoute.buildPage(newRoute.navigator.context,
          newRoute.animation, newRoute.secondaryAnimation);
      if (returningWidget is Routable) {
        Routable w = (returningWidget as Routable);
        w.didAppear(false, newRoute, oldRoute);
      }
    }
  }
}
