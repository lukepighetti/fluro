import 'package:flutter/widgets.dart' show BuildContext;

class FluroGuard {
  /// Used to optionally redirect to another path.
  ///
  /// If `null`, the redirect will coalesce to the original destination.
  FluroGuard(this.builder);

  /// See [FluroGuardBuilder]
  final FluroGuardBuilder builder;
}

/// Used to optionally redirect to another path.
///
/// If `null`, the redirect will coalesce to the original destination.
typedef FluroGuardBuilder = String? Function(
    BuildContext context, Map<String, String> params);

/// A stub authentication guard that allows every path to proceed.
///
/// In other words, a guard that never fails.
///
/// Intended only for development purposes.
final FluroGuardBuilder allowAllAuthenticationGuard = (context, params) => null;

extension FluroListFluroGuardX on List<FluroGuard> {
  /// Resolve a list of guards into a RouteMatch
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
