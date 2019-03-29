/*
 * fluro
 * Created by Yakka
 * https://theyakka.com
 *
 * Copyright (c) 2018 Yakka, LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import './route_handlers.dart';

class Routes {
  static String root = "/";
  static String demoSimple = "/demo";
  static String demoSimpleFixedTrans = "/demo/fixedtrans";
  static String demoFunc = "/demo/func";
  static String deepLink = "/message";

  static void configureRoutes(Router router) {
    router.notFoundHandler = new Handler(handlerFunc: (BuildContext context,
        Map<String, List<String>> params, Object arguments) {
      print("ROUTE WAS NOT FOUND !!!");
    });
    router.define(root, handler: rootHandler);
    router.define(demoSimple, handler: demoRouteHandler);
    router.define(demoSimpleFixedTrans,
        handler: demoRouteHandler, transitionType: TransitionType.inFromLeft);
    router.define(demoFunc, handler: demoFunctionHandler);
    router.define(deepLink, handler: deepLinkHandler);
  }
}
