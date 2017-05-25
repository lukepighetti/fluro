/*
 * fluro
 * A Posse Production
 * http://goposse.com
 * Copyright (c) 2017 Posse Productions LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */
import '../../config/application.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluro/fluro.dart';
import '../home/home_component.dart';
import 'package:router_example/config/routes.dart';

class AppComponent extends StatefulWidget {

  static const platform = const MethodChannel('channel:com.goposse.routersample/deeplink');

  @override
  State createState() {
    configureDeepLinker();
    return new AppComponentState();
  }

  void configureDeepLinker() {
    platform.setMethodCallHandler((MethodCall call) async {
      if (call.method == "linkReceived") {
        String path = call.arguments;
        if (path != null) {
          print("got path: $path");
        }
      }
    });
  }
}

class AppComponentState extends State<AppComponent> {

  AppComponentState() {
    Router router = new Router();
    Routes.configureRoutes(router);
    Application.router = router;
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new HomeComponent(),
    );
  }
}

