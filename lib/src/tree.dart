/*
 * fluro
 * Created by Yakka
 * https://theyakka.com
 * 
 * Copyright (c) 2019 Yakka, LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:fluro/src/common.dart';
import 'package:flutter/widgets.dart';

/// A [RouteTreeNote] type
enum RouteTreeNodeType {
  component,
  parameter,
}

/// A matched [AppRoute]
class AppRouteMatch {
  AppRouteMatch(this.route);

  AppRoute route;
  Map<String, List<String>> parameters = <String, List<String>>{};
}

/// A matched [RouteTreeNode]
class RouteTreeNodeMatch {
  RouteTreeNodeMatch(this.node);

  RouteTreeNode node;

  var parameters = <String, List<String>>{};

  RouteTreeNodeMatch.fromMatch(RouteTreeNodeMatch? match, this.node) {
    parameters = <String, List<String>>{};
    if (match != null) {
      parameters.addAll(match.parameters);
    }
  }
}

/// A node on [RouteTree]
class RouteTreeNode {
  RouteTreeNode(this.part, this.type);

  String part;
  RouteTreeNodeType? type;

  RouteTreeNode? parent;

  var routes = <AppRoute>[];
  var nodes = <RouteTreeNode>[];

  bool isParameter() {
    return type == RouteTreeNodeType.parameter;
  }
}

/// A [RouteTree]
class RouteTree {
  final List<RouteTreeNode> _nodes = <RouteTreeNode>[];
  bool _hasDefaultRoute = false;

  /// Add a route to the route tree
  void addRoute(AppRoute route) {
    String path = route.route;
    // is root/default route, just add it
    if (path == Navigator.defaultRouteName) {
      if (_hasDefaultRoute) {
        // throw an error because the internal consistency of the router
        // could be affected
        throw ("Default route was already defined");
      }

      var node = RouteTreeNode(path, RouteTreeNodeType.component);
      node.routes = [route];
      _nodes.add(node);
      _hasDefaultRoute = true;
      return;
    }

    if (path.startsWith("/")) {
      path = path.substring(1);
    }

    final pathComponents = path.split('/');

    RouteTreeNode? parent;

    for (int i = 0; i < pathComponents.length; i++) {
      String? component = pathComponents[i];
      RouteTreeNode? node = _nodeForComponent(component, parent);

      if (node == null) {
        RouteTreeNodeType type = _typeForComponent(component);
        node = RouteTreeNode(component, type);
        node.parent = parent;

        if (parent == null) {
          _nodes.add(node);
        } else {
          parent.nodes.add(node);
        }
      }

      if (i == pathComponents.length - 1) {
        node.routes.add(route);
      }

      parent = node;
    }
  }

  AppRouteMatch? matchRoute(String path) {
    var usePath = path;

    if (usePath.startsWith("/")) {
      usePath = path.substring(1);
    }

    var components = usePath.split("/");

    if (path == Navigator.defaultRouteName) {
      components = ["/"];
    }

    var nodeMatches = <RouteTreeNode, RouteTreeNodeMatch>{};
    var nodesToCheck = _nodes;

    for (final checkComponent in components) {
      final currentMatches = <RouteTreeNode, RouteTreeNodeMatch>{};
      final nextNodes = <RouteTreeNode>[];

      var pathPart = checkComponent;
      Map<String, List<String>>? queryMap;

      if (checkComponent.contains("?")) {
        var splitParam = checkComponent.split("?");
        pathPart = splitParam[0];
        queryMap = parseQueryString(splitParam[1]);
      }

      for (final node in nodesToCheck) {
        final isMatch = (node.part == pathPart || node.isParameter());

        if (isMatch) {
          RouteTreeNodeMatch? parentMatch = nodeMatches[node.parent];
          final match = RouteTreeNodeMatch.fromMatch(parentMatch, node);
          if (node.isParameter()) {
            final paramKey = node.part.substring(1);
            match.parameters[paramKey] = [pathPart];
          }
          if (queryMap != null) {
            match.parameters.addAll(queryMap);
          }
          currentMatches[node] = match;
          nextNodes.addAll(node.nodes);
        }
      }

      nodeMatches = currentMatches;
      nodesToCheck = nextNodes;

      if (currentMatches.values.length == 0) {
        return null;
      }
    }

    final matches = nodeMatches.values.toList();

    if (matches.isNotEmpty) {
      final match = matches.first;
      final nodeToUse = match.node;
      final routes = nodeToUse.routes;

      if (routes.isNotEmpty) {
        final routeMatch = AppRouteMatch(routes[0]);
        routeMatch.parameters = match.parameters;
        return routeMatch;
      }
    }

    return null;
  }

  void printTree() {
    _printSubTree();
  }

  void _printSubTree({RouteTreeNode? parent, int level = 0}) {
    final nodes = parent != null ? parent.nodes : _nodes;

    for (final node in nodes) {
      var indent = "";

      for (var i = 0; i < level; i++) {
        indent += "    ";
      }

      print("$indent${node.part}: total routes=${node.routes.length}");

      if (node.nodes.isNotEmpty) {
        _printSubTree(parent: node, level: level + 1);
      }
    }
  }

  RouteTreeNode? _nodeForComponent(String component, RouteTreeNode? parent) {
    var nodes = _nodes;

    if (parent != null) {
      // search parent for sub-node matches
      nodes = parent.nodes;
    }

    for (final node in nodes) {
      if (node.part == component) {
        return node;
      }
    }

    return null;
  }

  RouteTreeNodeType _typeForComponent(String component) {
    var type = RouteTreeNodeType.component;

    if (_isParameterComponent(component)) {
      type = RouteTreeNodeType.parameter;
    }

    return type;
  }

  /// Is the path component a parameter
  bool _isParameterComponent(String component) {
    return component.startsWith(":");
  }

  Map<String, List<String>> parseQueryString(String query) {
    final search = RegExp('([^&=]+)=?([^&]*)');
    final params = Map<String, List<String>>();

    if (query.startsWith('?')) query = query.substring(1);

    decode(String s) => Uri.decodeComponent(s.replaceAll('+', ' '));

    for (Match match in search.allMatches(query)) {
      final key = decode(match.group(1)!);
      final value = decode(match.group(2)!);

      if (params.containsKey(key)) {
        params[key]!.add(value);
      } else {
        params[key] = [value];
      }
    }

    return params;
  }
}
