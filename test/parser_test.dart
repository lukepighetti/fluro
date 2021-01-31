/*
 * fluro
 * Created by Yakka
 * https://theyakka.com
 * 
 * Copyright (c) 2019 Yakka, LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:fluro/fluro.dart';

void main() {
  test("FluroRouter correctly parses named parameters", () async {
    String path = "/users/1234";
    String route = "/users/:id";
    FluroRouter router = FluroRouter();
    router.define(route, handler: null);
    AppRouteMatch? match = router.match(path);
    expect(
        match?.parameters,
        equals(<String, List<String>>{
          "id": ["1234"],
        }));
  });

  test("FluroRouter correctly parses named parameters with query", () async {
    String path = "/users/1234?name=luke";
    String route = "/users/:id";
    FluroRouter router = FluroRouter();
    router.define(route, handler: null);
    AppRouteMatch? match = router.match(path);
    expect(
        match?.parameters,
        equals(<String, List<String>>{
          "id": ["1234"],
          "name": ["luke"],
        }));
  });

  test("FluroRouter correctly parses query parameters", () async {
    String path = "/users/create?name=luke&phrase=hello%20world&number=7";
    String route = "/users/create";
    FluroRouter router = FluroRouter();
    router.define(route, handler: null);
    AppRouteMatch? match = router.match(path);
    expect(
        match?.parameters,
        equals(<String, List<String>>{
          "name": ["luke"],
          "phrase": ["hello world"],
          "number": ["7"],
        }));
  });

  test("FluroRouter correctly parses array parameters", () async {
    String path =
        "/users/create?name=luke&phrase=hello%20world&number=7&number=10&number=13";
    String route = "/users/create";
    FluroRouter router = FluroRouter();
    router.define(route, handler: null);
    AppRouteMatch? match = router.match(path);
    expect(
        match?.parameters,
        equals(<String, List<String>>{
          "name": ["luke"],
          "phrase": ["hello world"],
          "number": ["7", "10", "13"],
        }));
  });
  test("FluroRouter correctly matches route and transition type", () async {
    String path = "/users/1234";
    String route = "/users/:id";
    FluroRouter router = FluroRouter();
    router.define(route,
        handler: null, transitionType: TransitionType.inFromRight);
    AppRouteMatch? match = router.match(path);
    expect(TransitionType.inFromRight, match?.route.transitionType);
  });
}
