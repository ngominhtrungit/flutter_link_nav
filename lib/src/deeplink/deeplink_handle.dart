import 'package:flutter/material.dart';

import 'deep_link_listener.dart';
import 'deep_link_processor.dart';

typedef DeepLinkCallback = void Function(BuildContext context, Uri uri);

class DeepLinkHandler {
  static final DeepLinkHandler _instance = DeepLinkHandler._internal();
  late final DeepLinkListener _listener;
  late final DeepLinkProcessor _processor;
  DeepLinkCallback? _customHandler;
  bool _isInitialized = false;

  factory DeepLinkHandler({
    DeepLinkListener? listener,
    DeepLinkProcessor? processor,
  }) {
    _instance._listener = listener ?? AppLinksListener();
    _instance._processor = processor ?? DefaultDeepLinkProcessor();
    return _instance;
  }

  DeepLinkHandler._internal();

  void init(BuildContext context, {DeepLinkCallback? customHandler}) {
    if (_isInitialized) return;
    _isInitialized = true;
    _customHandler = customHandler;

    _listener.uriLinkStream.listen(
      (uri) {
        if (!context.mounted) return;
        _handleDeepLink(context, uri);
      },
      onError: (error) => debugPrint('Error receiving link: $error'),
      cancelOnError: false,
    );

    _listener.getInitialLink().then((uri) {
      if (!context.mounted) return;
      if (uri != null) _handleDeepLink(context, uri);
    });
  }

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
