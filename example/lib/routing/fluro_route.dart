import 'package:flutter/widgets.dart' show Page;

class FluroRoute {
  /// A route with a path, optional name, page to display, and optional children.
  FluroRoute(
    this.path, {
    this.name = '',
    required this.page,
    this.children = const [],
  });

  /// The path for this route, ie `/` or `/user/:user_id/photo/:photo_id`
  final String path;

  /// A unique name for this route, ie `UserPhotoRoute`
  final String name;

  /// The page to display
  final Page page;

  /// A sublist of routes
  final List<FluroRoute> children;
}
