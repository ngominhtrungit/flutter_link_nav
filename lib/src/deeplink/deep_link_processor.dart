import 'package:flutter/material.dart';
import 'package:flutter_link_nav/src/src.dart';

///
/// This is class support process deep link
/// can be override to custom process deep link
///
abstract class DeepLinkProcessor {
  Future<void> processDeepLink(BuildContext context, Uri uri);
}

class DefaultDeepLinkProcessor implements DeepLinkProcessor {
  @override
  Future<void> processDeepLink(BuildContext context, Uri uri) async {
    try {
      final parseResult = uri.parseUri();
      final deeplink = parseResult.deeplink;
      final parameters = parseResult.parameters ?? uri.queryParameters;

      if (deeplink == null || deeplink.isEmpty) {
        DeepLinkHandler().triggerUnknownRoute(uri);
        return;
      }

      final routeMatch = RouteRegistry.matchRoute(deeplink);

      if (routeMatch == null) {
        debugPrint('No route found for deeplink: $deeplink');
        DeepLinkHandler().triggerUnknownRoute(uri);
        return;
      }

      final routeConfig = routeMatch.config;
      
      // Merge pathParams and queryParameters
      final mergedParameters = <String, String>{
        if (parameters != null) ...parameters,
        ...routeMatch.pathParams,
      };

      final request = DeepLinkRequest(
        uri: uri,
        path: routeMatch.matchedRouteName,
        queryParameters: mergedParameters,
      );

      // Check guards
      if (routeConfig.guards != null && routeConfig.guards!.isNotEmpty) {
        for (final guard in routeConfig.guards!) {
          final result = await guard.canNavigate(context, request);
          if (!result.allowed) {
            if (result.redirectRoute != null) {
              final redirectUri = Uri(
                path: result.redirectRoute,
                queryParameters: result.redirectParams,
              );
              // Recursively process redirect
              if (context.mounted) {
                await processDeepLink(context, redirectUri);
              }
            }
            return;
          }
        }
      }

      if (!context.mounted) return;

      if (routeConfig.widgetRegister != null) {
        Navigator.pushNamed(
          context,
          routeMatch.matchedRouteName,
          arguments: mergedParameters,
        );
      } else if (routeConfig.actionRegister != null) {
        await routeConfig.actionRegister!.call(mergedParameters);
      } else {
        DeepLinkHandler().triggerUnknownRoute(uri);
      }
    } catch (e, stackTrace) {
      debugPrint('Error handling deep link: $e');
      DeepLinkHandler().triggerError(e, stackTrace);
    }
  }
}
