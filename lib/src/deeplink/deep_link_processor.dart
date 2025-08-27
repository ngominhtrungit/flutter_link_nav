import 'package:flutter/material.dart';
import 'package:flutter_link_nav/src/src.dart';

///
/// This is class support process deep link
/// can be override to custom process deep link
///
abstract class DeepLinkProcessor {
  void processDeepLink(BuildContext context, Uri uri);
}

class DefaultDeepLinkProcessor implements DeepLinkProcessor {
  @override
  void processDeepLink(BuildContext context, Uri uri) {
    try {
      final parseResult = uri.parseUri();
      final deeplink = parseResult.deeplink;
      final parameters = parseResult.parameters;

      if (deeplink != null && deeplink.isNotEmpty) {
        final routeConfig = RouteRegistry.getRouteConfig(deeplink);

        if (routeConfig == null) {
          debugPrint('No route found for deeplink: $deeplink');
          return;
        }

        if (routeConfig.widgetRegister != null) {
          Navigator.pushNamed(
            context,
            deeplink,
            arguments: parameters ?? uri.queryParameters,
          );
        } else if (routeConfig.actionRegister != null) {
          routeConfig.actionRegister!.call(
            parameters ?? uri.queryParameters,
          );
        }
      }
    } catch (e) {
      debugPrint('Error handling deep link: $e');
    }
  }
}
