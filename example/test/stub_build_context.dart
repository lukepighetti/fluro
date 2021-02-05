import 'package:flutter/widgets.dart';

extension StubBuildContextX on BuildContext {
  /// It's not really random, but it illustrates the point that you can
  /// get some data from a service and use it to populate a random UID.
  String get randomUid => 'some_random_uid';

  /// Stub value for if our location permission is granted.
  bool get locationPermissionIsGranted => stubLocationPermissionIsGranted;
  static var stubLocationPermissionIsGranted = true;

  /// Stub value for if our camera permission is granted.
  bool get cameraPermissionIsGranted => stubCameraPermissionIsGranted;
  static var stubCameraPermissionIsGranted = true;

  /// Stub value for if the current user is authenticated.
  bool get isAuthenticated => stubAuthenticated;
  static var stubAuthenticated = true;
}

/// Used to create a stub context.
class StubBuildContext extends Element {
  StubBuildContext() : super(_NullWidget());

  // static _NullElement instance = _NullElement();

  @override
  bool get debugDoingBuild => throw UnimplementedError();

  @override
  void performRebuild() {}
}

class _NullWidget extends Widget {
  @override
  Element createElement() => throw UnimplementedError();
}
