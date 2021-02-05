import 'package:flutter/widgets.dart' show BuildContext;

/// {@macro FluroGuard}
class FluroGuard {
  /// {@template FluroGuard}
  /// Used to guard a [FluroRoute] from access.
  ///
  /// If a string is provided by [builder] redirect to another path.
  /// If `null`, the redirect will coalesce to the original destination.
  /// {@endtemplate}
  FluroGuard(this.builder);

  /// {@macro FluroGuardBuilder}
  final FluroGuardBuilder builder;
}

/// {@template FluroGuardBuilder}
/// Used to optionally redirect to another path.
///
/// If `null`, the redirect will coalesce to the original destination.
/// {@endtemplate}
typedef FluroGuardBuilder = String? Function(
    BuildContext context, Map<String, String> params);

extension FluroListFluroGuardX on List<FluroGuard> {
  /// Resolve a list of guards into an optional [String].
  ///
  /// `null` if no redirect should occur.
  String? resolve(BuildContext context, Map<String, String> parameters) {
    for (var e in this) {
      final resolvedGuard = e.builder(context, parameters);
      if (resolvedGuard != null) {
        return resolvedGuard;
      }
    }

    /// None found
    return null;
  }
}
