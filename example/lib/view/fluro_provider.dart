import 'package:example/fluro.dart';
import 'package:example/models/fluro_alias.dart';
import 'package:example/models/fluro_route.dart';
import 'package:example/view/fluro_view.dart';
import 'package:flutter/material.dart';

/// Passes [routeInformationParser] and [routerDelegate] to [MaterialApp.router]
typedef FluroBuilder = Widget Function(
    BuildContext,
    FluroRouteInformationParser routeInformationParser,
    FluroRouterDelegate routerDelegate);

class FluroProvider extends StatefulWidget {
  FluroProvider({
    Key? key,
    required this.fallbackPage,
    this.aliases = const [],
    required this.routes,
    required this.builder,
  }) : super(key: key);

  /// The page to build when no other route can be found.
  final FluroPageBuilder fallbackPage;

  /// The aliases used to build supplement the router tree.
  final List<FluroAlias> aliases;

  /// The routes used to build out the router tree with pages.
  final List<FluroRoute> routes;

  /// Passes [routeInformationParser] and [routerDelegate] to [MaterialApp.router]
  late final FluroBuilder builder;

  @override
  _FluroProviderState createState() => _FluroProviderState();
}

class _FluroProviderState extends State<FluroProvider> {
  late final delegate = FluroRouterDelegate(
    routes: widget.routes,
    aliases: widget.aliases,
    fallbackPage: widget.fallbackPage,
  );

  @override
  void dispose() {
    delegate.dispose();
    super.dispose();
  }

  /// Fires whenever a descendent attaches itself to the tree or updates
  bool _handleDescendentNotification(FluroViewNotification notification) {
    delegate.safelyAddDescendent(notification.state);
    delegate.updateRouterTree();

    /// Stop the base notification from bubbling up.
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<FluroViewNotification>(
      onNotification: _handleDescendentNotification,
      child: widget.builder(
        context,
        FluroRouteInformationParser(),
        delegate,
      ),
    );
  }
}
