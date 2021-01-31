import 'package:flutter/material.dart';

extension FluroBuildContextX on BuildContext {
  /// Convenience method to retreive [RouteSettings] via
  /// `ModalRoute.of(context).settings`
  RouteSettings? get settings => ModalRoute.of(this)?.settings;

  /// Helper to get [RouteSettings.arguments] via
  /// `ModalRoute.of(context).settings.arguments`
  Object? get arguments => ModalRoute.of(this)?.settings.arguments;
}
