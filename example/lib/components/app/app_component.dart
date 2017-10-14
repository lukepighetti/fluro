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
import '../../config/routes.dart';

class AppComponent extends StatefulWidget {

  @override
  State createState() {
    return new AppComponentState();
  }
}

class AppComponentState extends State<AppComponent> {

  static MethodChannel platform = const MethodChannel('channel:com.goposse.routersample/deeplink');

  AppComponentState() {
    Router router = new Router();
    Routes.configureRoutes(router);
    Application.router = router;
    configureDeepLinker();
    print("Configured channel receiver in flutter ..");
  }


  void configureDeepLinker() {
    platform.setMethodCallHandler((MethodCall call) async {
      if (call.method == "linkReceived") {
        Map<String, dynamic> passedObjs = call.arguments;
        if (passedObjs != null) {
          var path = passedObjs["path"];
          Application.router.navigateTo(context, path);
        }
      }
    });
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

