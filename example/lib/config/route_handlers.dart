/*
 * router
 * A Posse Production
 * http://goposse.com
 * Copyright (c) 2017 Posse Productions LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */
import 'package:flutter/painting.dart';
import 'package:router/fluro.dart';
import 'package:router_example/helpers/color_helpers.dart';
import 'package:router_example/screens/test_screen_01.dart';

RouteHandler showDemoHandler = (Map<String, String> params) {
  String message = params["message"];
  String colorHex = params["color_hex"];
  Color color = new Color(0xFFFFFFFF);
  if (colorHex != null && colorHex.length > 0) {
    color = new Color(ColorHelpers.fromHexString(colorHex));
  }
  return new TestScreen01(message: message, color: color);
};