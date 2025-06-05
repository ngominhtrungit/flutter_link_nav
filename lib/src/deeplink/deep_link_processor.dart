// deep_link_processor.dart
import 'package:flutter/material.dart';

abstract class DeepLinkProcessor {
  void processDeepLink(BuildContext context, Uri uri);
}

class DefaultDeepLinkProcessor implements DeepLinkProcessor {
  @override
  void processDeepLink(BuildContext context, Uri uri) {
    try {
      final routeName = uri.toString().split('://')[1];
      if (routeName.isNotEmpty) {
        Navigator.pushNamed(
          context,
          routeName,
          arguments: uri.queryParameters,
        );
      }
    } catch (e) {
      debugPrint('Error handling deep link: $e');
    }
  }
}