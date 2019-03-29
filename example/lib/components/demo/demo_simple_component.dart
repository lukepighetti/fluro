/*
 * fluro
 * Created by Yakka
 * https://theyakka.com
 *
 * Copyright (c) 2018 Yakka, LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */
import '../../helpers/color_helpers.dart';
import 'package:flutter/material.dart';

class DemoSimpleComponent extends StatelessWidget {
  DemoSimpleComponent(
      {String message = "Testing",
      Color color = const Color(0xFFFFFFFF),
      String result,
      this.include})
      : this.message = message,
        this.color = color,
        this.result = result;

  final String message;
  final Color color;
  final String result;
  final Widget include;

  @override
  Widget build(BuildContext context) {
    return new Material(
      color: color,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          new Image(
            image: new AssetImage("assets/images/acc_boom.png"),
            color: ColorHelpers.blackOrWhiteContrastColor(color),
            width: 260.0,
          ),
          new Padding(
            padding: new EdgeInsets.only(left: 50.0, right: 50.0, top: 15.0),
            child: include != null
                ? include
                : new Text(
                    message,
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                      color: ColorHelpers.blackOrWhiteContrastColor(color),
                      height: 2.0,
                    ),
                  ),
          ),
          new Padding(
            padding: new EdgeInsets.only(top: 15.0),
            child: new ConstrainedBox(
              constraints: new BoxConstraints(minHeight: 42.0),
              child: new FlatButton(
                highlightColor:
                    ColorHelpers.blackOrWhiteContrastColor(color).withAlpha(17),
                splashColor:
                    ColorHelpers.blackOrWhiteContrastColor(color).withAlpha(34),
                onPressed: () {
                  if (result == null) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pop(context, result);
                  }
                },
                child: new Text(
                  "OK",
                  style: new TextStyle(
                    fontSize: 18.0,
                    color: ColorHelpers.blackOrWhiteContrastColor(color),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
