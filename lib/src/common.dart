/*
 * router
 * A Posse Production
 * http://goposse.com
 * Copyright (c) 2017 Posse Productions LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */
part of router;

///
typedef Route<Null> RouteCreator(RouteSettings route, Map<String, String> parameters);

///
typedef Widget RouteHandler(Map<String, String> parameters);

///
class AppRoute {
  String route;
  RouteHandler handler;
  AppRoute(this.route, this.handler);
}