import 'package:flutter/material.dart';

import 'deep_link_listener.dart';
import 'deep_link_processor.dart';

typedef DeepLinkCallback = void Function(BuildContext context, Uri uri);

class DeepLinkHandler {
  static final DeepLinkHandler _instance = DeepLinkHandler._internal();
  late final DeepLinkListener _listener;
  late final DeepLinkProcessor _processor;
  DeepLinkCallback? _customHandler;
  void Function(Uri uri)? _onUnknownRoute;
  void Function(Object error, StackTrace stackTrace)? _onError;
  bool _isInitialized = false;

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

  void init(
    BuildContext context, {
    DeepLinkCallback? customHandler,
    void Function(Uri uri)? onUnknownRoute,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    if (_isInitialized) return;
    _isInitialized = true;
    _customHandler = customHandler;
    _onUnknownRoute = onUnknownRoute;
    _onError = onError;

    _listener.uriLinkStream.listen(
      (uri) {
        if (!context.mounted) return;
        _handleDeepLink(context, uri);
      },
      onError: (error, stack) {
        debugPrint('Error receiving link: $error');
        _onError?.call(error, stack);
      },
      cancelOnError: false,
    );

    _listener.getInitialLink().then((uri) {
      if (!context.mounted) return;
      if (uri != null) _handleDeepLink(context, uri);
    }).catchError((error, stack) {
      _onError?.call(error, stack);
    });
  }

  /// Exposed for internal use by processors
  void triggerUnknownRoute(Uri uri) => _onUnknownRoute?.call(uri);
  void triggerError(Object error, StackTrace stack) => _onError?.call(error, stack);

  void _handleDeepLink(BuildContext context, Uri uri) {
    try {
      if (_customHandler != null) {
        _customHandler!(context, uri);
        return;
      }
      _processor.processDeepLink(context, uri);
    } catch (e, stackTrace) {
      debugPrint('Error processing deep link: $e\n$stackTrace');
    }
  }
}
