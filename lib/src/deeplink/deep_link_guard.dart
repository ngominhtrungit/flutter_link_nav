import 'dart:async';
import 'package:flutter/material.dart';
import 'deep_link_request.dart';

/// Result of a [DeepLinkGuard.canNavigate] check
class GuardResult {
  /// Whether the navigation is allowed
  final bool allowed;

  /// Optional route to redirect to if [allowed] is false
  final String? redirectRoute;

  /// Optional parameters for the redirect route
  final Map<String, String>? redirectParams;

  const GuardResult._({
    required this.allowed,
    this.redirectRoute,
    this.redirectParams,
  });

  /// Allow the navigation to proceed
  const GuardResult.allow()
      : allowed = true,
        redirectRoute = null,
        redirectParams = null;

  /// Block the navigation without redirection
  const GuardResult.block()
      : allowed = false,
        redirectRoute = null,
        redirectParams = null;

  /// Redirect the navigation to a different route
  const GuardResult.redirect(
    String route, {
    Map<String, String>? params,
  })  : allowed = false,
        redirectRoute = route,
        redirectParams = params;
}

/// A guard that can intercept and potentially block or redirect deep link navigation
abstract class DeepLinkGuard {
  /// Determines if the navigation to the given [request] is allowed
  FutureOr<GuardResult> canNavigate(
    BuildContext context,
    DeepLinkRequest request,
  );
}
