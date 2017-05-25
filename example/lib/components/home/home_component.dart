/*
 * fluro
 * A Posse Production
 * http://goposse.com
 * Copyright (c) 2017 Posse Productions LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../config/application.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

class HomeComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var menuWidgets = <Widget>[
      new Padding(
        padding: new EdgeInsets.only(bottom: 25.0),
        child: new Image(image: new AssetImage("assets/images/logo_fluro.png"), width: 200.0),
      ),
      menuButton(context, "Native Animation", "native"),
      menuButton(context, "Preset (In from Left)", "preset-from-left"),
      menuButton(context, "Preset (Fade In)", "preset-fade"),
      menuButton(context, "Custom Transition", "custom"),
      menuButton(context, "Function Call", "function-call"),
      new Padding(
        padding: new EdgeInsets.only(top: 65.0, left: 60.0, right: 60.0),
        child: new Center(
          child: new ConstrainedBox(
            constraints: new BoxConstraints.tightFor(height: 50.0),
            child: new FlatButton(
              onPressed: () {

              },
              child: new Text(
                "Try going to fluro://deeplink?path=/message&text=fluro%20rocks%21%21",
                textAlign: TextAlign.center,
                style: new TextStyle(
                  fontSize: 10.0,
                  color: const Color(0xFFFFFFFF),
                ),
              ),
            ),
          ),
        ),
      ),
    ];

    return new Material(
      color: const Color(0xFF00D6F7),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: menuWidgets,
      ),
    );
  }

  // helpers
  Widget menuButton(BuildContext context, String title, String key) {
    return new Padding(
      padding: new EdgeInsets.all(4.0),
      child: new ConstrainedBox(
        constraints: new BoxConstraints(minHeight: 32.0),
        child: new FlatButton(
          child: new Text(
            title,
            style: new TextStyle(
              color: const Color(0xFF004F8F),
            ),
          ),
          onPressed: () {
            tappedMenuButton(context, key);
          },
        ),
      ),
    );
  }

  // actions
  void tappedMenuButton(BuildContext context, String key) {
    String message = "";
    String hexCode = "#FFFFFF";
    TransitionType transitionType = TransitionType.native;
    if (key != "custom" && key != "function-call") {
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
      Application.router.navigateTo(context, "/demo?message=$message&color_hex=$hexCode", transition: transitionType);
    } else if (key == "custom") {
      hexCode = "#DFF700";
      message = "This screen should have appeared with a crazy custom transition";
      var transition =
          (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
        return new ScaleTransition(
          scale: animation,
          child: new RotationTransition(
            turns: animation,
            child: child,
          ),
        );
      };
      Application.router.navigateTo(
        context,
        "/demo?message=$message&color_hex=$hexCode",
        transition: TransitionType.custom,
        transitionBuilder: transition,
        transitionDuration: const Duration(milliseconds: 600),
      );
    } else {
      message = "You tapped the function button!";
      Application.router.navigateTo(context, "/demo/func?message=$message");
    }
  }
}
