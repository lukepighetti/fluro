/*
 * fluro
 * A Posse Production
 * http://goposse.com
 * Copyright (c) 2017 Posse Productions LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */
part of fluro;

///
enum HandlerType {
  route,
  function,
}

///
class Handler {
  Handler({this.type = HandlerType.route, this.handlerFunc});
  final HandlerType type;
  final HandlerFunc handlerFunc;
}

///
typedef Route<T> RouteCreator<T>(RouteSettings route, Map<String, dynamic> parameters);

///
typedef Widget HandlerFunc(BuildContext context, Map<String, dynamic> parameters);

///
class AppRoute {
  String route;
  dynamic handler;
  AppRoute(this.route, this.handler);
}

enum RouteMatchType {
  visual,
  nonVisual,
  noMatch,
}

///
class RouteMatch {
  RouteMatch({
    @required this.matchType = RouteMatchType.noMatch,
    this.route = null,
    this.errorMessage = "Unable to match route. Please check the logs."
  });
  final Route<dynamic> route;
  final RouteMatchType matchType;
  final String errorMessage;
}