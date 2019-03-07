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
      String result})
      : this.message = message,
        this.color = color,
        this.result = result;

  final String message;
  final Color color;
  final String result;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(
            image: AssetImage("assets/images/acc_boom.png"),
            color: ColorHelpers.blackOrWhiteContrastColor(color),
            width: 260,
          ),
          Padding(
            padding: EdgeInsets.only(left: 50, right: 50, top: 15),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ColorHelpers.blackOrWhiteContrastColor(color),
                height: 2,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 15),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: 42),
              child: FlatButton(
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
                child: Text(
                  "OK",
                  style: TextStyle(
                    fontSize: 18,
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
