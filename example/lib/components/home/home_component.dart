/*
 * fluro
 * Created by Yakka
 * https://theyakka.com
 * 
 * Copyright (c) 2018 Yakka, LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */
import 'dart:async';

import '../../config/application.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeComponent extends StatefulWidget {
  @override
  State createState() => HomeComponentState();
}

class HomeComponentState extends State<HomeComponent> {
  var _deepLinkOpacity = 1.0;
  final _deepLinkURL =
      "fluro://deeplink?path=/message&mesage=fluro%20rocks%21%21";
  final _daysOfWeek = const [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  Widget deepLinkWidget(BuildContext context) {
    return Stack(
      children: <Widget>[
        // copied widget
        AnimatedOpacity(
          opacity: (_deepLinkOpacity - 1).abs(),
          duration: Duration(milliseconds: 400),
          child: Center(
            child: Text(
              "Copied to clipboard!",
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFFFFFFFF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        // button widget
        AnimatedOpacity(
          opacity: _deepLinkOpacity,
          duration: Duration(milliseconds: 250),
          child: Center(
            child: FlatButton(
              highlightColor: const Color(0x11FFFFFF),
              splashColor: const Color(0x22FFFFFF),
              onPressed: () {
                if (_deepLinkOpacity == 1) {
                  Timer(Duration(milliseconds: 2000), () {
                    setState(() {
                      _deepLinkOpacity = 1;
                    });
                  });
                  setState(() {
                    _deepLinkOpacity = 0;
                  });
                  final clipboardData = ClipboardData(text: _deepLinkURL);
                  Clipboard.setData(clipboardData);
                }
              },
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  "Click here to copy a deep link url to the clipboard",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xCCFFFFFF),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var menuWidgets = <Widget>[
      Padding(
        padding: EdgeInsets.only(bottom: 35),
        child: Image(
            image: AssetImage("assets/images/logo_fluro.png"),
            width: 200),
      ),
      menuButton(context, "Native Animation", "native"),
      menuButton(context, "Preset (Fade In)", "preset-fade"),
      menuButton(context, "Preset (Global transition)", "fixed-trans"),
      menuButton(context, "Custom Transition", "custom"),
      menuButton(context, "Navigator Result", "pop-result"),
      menuButton(context, "Function Call", "function-call"),
      Padding(
        padding: EdgeInsets.only(top: 65, left: 60, right: 60),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints.tightFor(height: 60),
            child: deepLinkWidget(context),
          ),
        ),
      ),
    ];

    return Material(
      color: const Color(0xFF00D6F7),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: menuWidgets,
      ),
    );
  }

  // helpers
  Widget menuButton(BuildContext context, String title, String key) {
    return Padding(
      padding: EdgeInsets.all(4),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 42),
        child: FlatButton(
          highlightColor: const Color(0x11FFFFFF),
          splashColor: const Color(0x22FFFFFF),
          child: Text(
            title,
            style: TextStyle(
              color: const Color(0xAA001133),
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
    String result;
    TransitionType transitionType = TransitionType.native;
    if (key != "custom" && key != "function-call" && key != "fixed-trans") {
      if (key == "native") {
        hexCode = "#F76F00";
        message =
            "This screen should have appeared using the default flutter animation for the current OS";
      } else if (key == "preset-from-left") {
        hexCode = "#5BF700";
        message =
            "This screen should have appeared with a slide in from left transition";
        transitionType = TransitionType.inFromLeft;
      } else if (key == "preset-fade") {
        hexCode = "#F700D2";
        message = "This screen should have appeared with a fade in transition";
        transitionType = TransitionType.fadeIn;
      } else if (key == "pop-result") {
        transitionType = TransitionType.native;
        hexCode = "#7d41f4";
        message =
            "When you close this screen you should see the current day of the week";
        result = "Today is ${_daysOfWeek[DateTime.now().weekday - 1]}!";
      }

      String route = "/demo?message=$message&color_hex=$hexCode";

      if (result != null) {
        route = "$route&result=$result";
      }

      Application.router
          .navigateTo(context, route, transition: transitionType)
          .then((result) {
        if (key == "pop-result") {
          Application.router.navigateTo(context, "/demo/func?message=$result");
        }
      });
    } else if (key == "custom") {
      hexCode = "#DFF700";
      message =
          "This screen should have appeared with a crazy custom transition";
      var transition = (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) {
        return ScaleTransition(
          scale: animation,
          child: RotationTransition(
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
    } else if (key == "fixed-trans") {
      Application.router.navigateTo(
          context, "/demo/fixedtrans?message=Hello!&color_hex=#f4424b");
    } else {
      message = "You tapped the function button!";
      Application.router.navigateTo(context, "/demo/func?message=$message");
    }
  }
}
