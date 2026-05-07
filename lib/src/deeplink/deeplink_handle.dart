import 'dart:async';
import 'package:flutter/material.dart';

import 'deep_link_listener.dart';
import 'deep_link_processor.dart';

typedef DeepLinkCallback = FutureOr<void> Function(BuildContext context, Uri uri);

class DeepLinkHandler {
  static final DeepLinkHandler _instance = DeepLinkHandler._internal();
  late final DeepLinkListener _listener;
  late final DeepLinkProcessor _processor;
  DeepLinkCallback? _customHandler;
  void Function(Uri uri)? _onUnknownRoute;
  void Function(Object error, StackTrace stackTrace)? _onError;
  bool _isInitialized = false;
  BuildContext? _currentContext;

  factory DeepLinkHandler({
    DeepLinkListener? listener,
    DeepLinkProcessor? processor,
  }) {
    if (!_instance._isInitializedFields) {
      _instance._listener = listener ?? AppLinksListener();
      _instance._processor = processor ?? DefaultDeepLinkProcessor();
      _instance._isInitializedFields = true;
    }
    return _instance;
  }

  bool _isInitializedFields = false;

  DeepLinkHandler._internal();

  /// Initialize or update the deep link handler.
  /// Can be called multiple times to update the [context] and [customHandler].
  void init(
    BuildContext context, {
    DeepLinkCallback? customHandler,
    void Function(Uri uri)? onUnknownRoute,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    // Always update context and handlers to the latest one
    _currentContext = context;
    _customHandler = customHandler;
    if (onUnknownRoute != null) _onUnknownRoute = onUnknownRoute;
    if (onError != null) _onError = onError;

    if (_isInitialized) return;
    _isInitialized = true;

    _listener.uriLinkStream.listen(
      (uri) {
        final ctx = _currentContext;
        if (ctx == null || !ctx.mounted) return;
        _handleDeepLink(ctx, uri);
      },
      onError: (error, stack) {
        debugPrint('Error receiving link: $error');
        _onError?.call(error, stack);
      },
      cancelOnError: false,
    );

    _listener.getInitialLink().then((uri) {
      final ctx = _currentContext;
      if (ctx == null || !ctx.mounted) return;
      if (uri != null) _handleDeepLink(ctx, uri);
    }).catchError((error, stack) {
      _onError?.call(error, stack);
    });
  }

  /// Exposed for internal use by processors
  void triggerUnknownRoute(Uri uri) => _onUnknownRoute?.call(uri);
  void triggerError(Object error, StackTrace stack) =>
      _onError?.call(error, stack);

  Future<void> _handleDeepLink(BuildContext context, Uri uri) async {
    try {
      if (_customHandler != null) {
        await _customHandler!(context, uri);
        return;
      }
      await _processor.processDeepLink(context, uri);
    } catch (e, stackTrace) {
      debugPrint('Error processing deep link: $e\n$stackTrace');
      triggerError(e, stackTrace);
    }
  }
}
