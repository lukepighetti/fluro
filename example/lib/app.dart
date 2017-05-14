/*
 * router
 * A Posse Production
 * http://goposse.com
 * Copyright (c) 2017 Posse Productions LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:router/fluro.dart';
import 'package:router_example/config/application.dart';
import 'package:router_example/config/route_handlers.dart';
import 'package:router_example/screens/home_screen.dart';

class App extends StatelessWidget {

  static const platform = const MethodChannel('channel:com.goposse.routerdemo/deeplink');

  App() {
    Router router = new Router();
    router.define("/demo", handler: showDemoHandler);
    Application.router = router;
    configureDeepLinker();
  }
  
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new HomeScreen(),
    );
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

