import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'fluro_provider.dart';

class FluroView extends StatefulWidget {
  /// A router view that acts as an outlet for nested routes.
  ///
  /// Naively expects an ancestor [FluroProvider].
  const FluroView({Key? key, this.name = ''}) : super(key: key);

  /// The name of this view, used optionally to scope nested routes.
  final String name;

  @override
  FluroViewState createState() => FluroViewState();
}

class FluroViewState extends State<FluroView> with FluroViewDescendents {
  @visibleForTesting
  var hasInitialized = false;

  @override
  void didChangeDependencies() {
    /// Initialize only once.
    if (hasInitialized == false) {
      _handleInitializeNotification();
      hasInitialized = true;
    }

    super.didChangeDependencies();
  }

  @visibleForTesting
  var pages = <Page>[];

  /// Update the pages that this view is displaying.
  void updatePages(List<Page> pages) {
    if (listEquals(this.pages, pages) == false) {
      setState(() {
        this.pages = pages;
      });
    }
  }

  /// Inform our ancestor that this view has been attached to the tree.
  void _handleInitializeNotification() {
    final bubble = FluroViewNotification(
      name: widget.name,
      state: this,
      descendents: descendents,
    );

    bubble.dispatch(context);
  }

  /// Wrap a notification from a descendent with information about this [FluroView] and bubble it
  /// to the next ancestor.
  ///
  /// Eventually this will bubble all the way up to [FluroProvider] building a complete [FluroView]
  /// trie as the notifications propogate.
  bool _handleDescendentNotification(FluroViewNotification notification) {
    safelyAddDescendent(notification.state);

    /// Wrap this notification in a new one with our context added.
    final bubble = FluroViewNotification(
      name: widget.name,
      state: this,
      descendents: descendents,
    );

    /// Dispatch the wrapped notification so it bubbles up.
    bubble.dispatch(context);

    /// Stop the base notification from bubbling up.
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<FluroViewNotification>(
      onNotification: _handleDescendentNotification,
      child: Navigator(
        pages: [EmptyPage(), ...pages],
        onPopPage: (Route<dynamic> route, dynamic result) {
          route.didPop(result);
          return true;
        },
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('hasInitialized', hasInitialized));
    properties
        .add(IterableProperty<FluroViewState>('descendents', descendents));
    properties.add(IterableProperty<Page>('pages', pages));
  }
}

class FluroViewNotification extends Notification {
  /// A notification dispatched by a [FluroView] to inform it's ancestor [FluroView] or [FluroProvider]
  /// of it's status, name, and descendents.
  ///
  /// Used to build a routing tree as [FluroView]s are added/removed from the widget tree.
  FluroViewNotification({
    required this.name,
    required this.state,
    required this.descendents,
  });

  /// The name of this particular [FluroView]
  final String name;

  /// The link to this particular [FluroView]
  final FluroViewState state;

  /// The other [FluroView] below this one.
  final Set<FluroViewState> descendents;
}

/// A completely empty page.
class EmptyPage extends MaterialPage {
  EmptyPage()
      : super(
          child: SizedBox.shrink(),
        );
}

mixin FluroViewDescendents {
  @visibleForTesting
  final descendents = <FluroViewState>{};

  /// Remove all descendents that are not mounted.
  ///
  /// Have all mounted descendents prune their descendents.
  void pruneDescendents() {
    descendents.removeWhere((e) => e.mounted == false);

    for (var e in descendents) {
      e.pruneDescendents();
    }
  }

  /// Add the descendent if it's not already in [descendents]
  void safelyAddDescendent(FluroViewState value) {
    if (descendents.contains(value) == false) descendents.add(value);
  }
}
