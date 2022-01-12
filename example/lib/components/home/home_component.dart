/*
 * fluro
 * Created by Yakka
 * https://theyakka.com
 * 
 * Copyright (c) 2019 Yakka, LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */
import 'dart:async';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/application.dart';

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
          opacity: (_deepLinkOpacity - 1.0).abs(),
          duration: Duration(milliseconds: 400),
          child: Center(
            child: Text(
              "Copied to clipboard!",
              style: TextStyle(
                fontSize: 14.0,
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
            child: TextButton(
              onPressed: () {
                if (_deepLinkOpacity == 1.0) {
                  Timer(Duration(milliseconds: 2000), () {
                    setState(() {
                      _deepLinkOpacity = 1.0;
                    });
                  });
                  setState(() {
                    _deepLinkOpacity = 0.0;
                  });
                  final clipboardData = ClipboardData(text: _deepLinkURL);
                  Clipboard.setData(clipboardData);
                }
              },
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Click here to copy a deep link url to the clipboard",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.0,
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
      menuButton(context, 'assets/images/ic_transform_native_hz.png',
          "Native Animation", "native"),
      menuButton(context, 'assets/images/ic_transform_fade_in_hz.png',
          "Preset (Fade In)", "preset-fade"),
      menuButton(context, 'assets/images/ic_transform_global_hz.png',
          "Preset (Global transition)", "fixed-trans"),
      menuButton(context, 'assets/images/ic_transform_custom_hz.png',
          "Custom Transition", "custom"),
      menuButton(context, 'assets/images/ic_result_hz.png', "Navigator Result",
          "pop-result"),
      menuButton(context, 'assets/images/ic_function_hz.png', "Function Call",
          "function-call"),
    ];

    final size = MediaQuery.of(context).size;
    final childRatio = (size.width / size.height) * 2.5;

    return Material(
      color: const Color(0xFF00D6F7),
      child: SafeArea(
        top: true,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 25, bottom: 35, left: 25),
              child: Image(
                image: AssetImage("assets/images/logo_fluro.png"),
                width: 100.0,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: GridView.count(
                  childAspectRatio: childRatio,
                  crossAxisCount: 2,
                  mainAxisSpacing: 5,
                  children: menuWidgets,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // helpers
  Widget menuButton(
      BuildContext context, String assetSrc, String title, String key) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Container(
        height: 42.0,
        child: TextButton(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  height: 36,
                  child: Image.asset(
                    assetSrc,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xAA001133),
                ),
              )
            ],
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
    String? result;
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
