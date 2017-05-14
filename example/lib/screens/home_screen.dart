/*
 * fluro
 * A Posse Production
 * http://goposse.com
 * Copyright (c) 2017 Posse Productions LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */
import 'package:flutter/material.dart';
import 'package:router/fluro.dart';
import 'package:router_example/config/application.dart';

class HomeScreen extends StatelessWidget {

  BuildContext context;

  @override
  Widget build(BuildContext context) {
    this.context = context;
    var menuWidgets = <Widget>[
      new Padding(
        padding: new EdgeInsets.only(bottom: 15.0),
        child: new Image(image: new AssetImage("assets/images/logo_fluro.png"), width: 200.0),
      ),
      menuButton("Native Animation", "native"),
      menuButton("Preset (In from Left)", "preset-from-left"),
      menuButton("Preset (Fade In)", "preset-fade"),
      menuButton("Custom", "custom"),
    ];
    return new Material(
      color: new Color(0xFF00D6F7),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: menuWidgets,
      ),
    );
  }

  // helpers
  Widget menuButton(String title, String key) {
    return new Padding(
      padding: new EdgeInsets.all(4.0),
      child: new ConstrainedBox(
        constraints: new BoxConstraints(minHeight: 42.0),
        child: new FlatButton(
          child: new Text(
            title,
            style: new TextStyle(
              color: new Color(0xFF004F8F),
            ),
          ),
          onPressed: () {
            tappedMenuButton(key);
          },
        ),
      ),
    );
  }

  // actions
  void tappedMenuButton(String key) {
    String message = "";
    String hexCode = "#FFFFFF";
    TransitionType transitionType = TransitionType.native;
    if (key != "custom") {
      if (key == "native") {
        hexCode = "#F76F00";
        message = "This screen should have appeared using the default flutter animation for the current OS";
      } else if (key == "preset-from-left") {
        hexCode = "#5BF700";
        message = "This screen should have appeared with a slide in from left transition";
        transitionType = TransitionType.inFromLeft;
      } else if (key == "preset-fade") {
        hexCode = "#F700D2";
        message = "This screen should have appeared with a fade in transition";
        transitionType = TransitionType.fadeIn;
      }
      Application.router.navigateTo(this.context, "/demo?message=$message&color_hex=$hexCode",
          transition: transitionType);
    } else {
      hexCode = "#DFF700";
      message = "This screen should have appeared with a crazy custom transition";
      var transition = (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation,
          Widget child) {
        return new ScaleTransition(
          scale: animation,
          child: new RotationTransition(
            turns: animation,
            child: child,
          ),
        );
      };
      Application.router.navigateTo(this.context, "/demo?message=$message&color_hex=$hexCode",
        transition: TransitionType.fadeIn, transitionBuilder: transition,
        transitionDuration: const Duration(milliseconds: 600),
      );
    }
  }
}