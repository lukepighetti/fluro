/*
 * fluro
 * A Posse Production
 * http://goposse.com
 * Copyright (c) 2017 Posse Productions LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */
import '../helpers/color_helpers.dart';
import '../screens/test_screen_01.dart';
import 'package:flutter/painting.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

Handler demoRouteHandler = new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  String message = params["message"];
  String colorHex = params["color_hex"];
  Color color = new Color(0xFFFFFFFF);
  if (colorHex != null && colorHex.length > 0) {
    color = new Color(ColorHelpers.fromHexString(colorHex));
  }
  return new TestScreen01(message: message, color: color);
});

Handler demoFunctionHandler = new Handler(type: HandlerType.function,
    handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      String message = params["message"];
      showDialog(context: context,
        child: new AlertDialog(
          title: new Text(
            "Hey Hey!",
            style: new TextStyle(
              color: const Color(0xFF00D6F7),
              fontFamily: "Lazer84",
              fontSize: 22.0,
            ),
          ),
          content: new Text("$message"),
          actions: <Widget>[
            new Padding(
              padding: new EdgeInsets.only(bottom: 8.0, right: 8.0),
              child: new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: new Text("OK"),
              ),
            ),
          ],
        ),
      );
    });