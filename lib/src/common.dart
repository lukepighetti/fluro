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