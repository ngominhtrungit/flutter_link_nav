import 'package:flutter_link_nav/src/src.dart';

extension UriParser on Uri {
  ({String? deeplink, Map<String, String>? parameters}) parseUri() {
    String fullPath = '';

    // Get the entire path and remove leading/trailing slashes
    String normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    if (normalizedPath.endsWith('/')) {
      normalizedPath = normalizedPath.substring(0, normalizedPath.length - 1);
    }

    if (host.isNotEmpty) {
      String pathWithHost = host;
      if (normalizedPath.isNotEmpty) {
        pathWithHost = '$host/$normalizedPath';
      }

      if (RouteRegistry.matchRoute(pathWithHost) != null) {
        fullPath = pathWithHost;
      } else {
        // If host+path is not a route, treat host as a domain and only use the path
        fullPath = normalizedPath;
      }
    } else {
      fullPath = normalizedPath;
    }

    if (fullPath.isEmpty) {
      fullPath = '';
    }

    return (deeplink: fullPath, parameters: queryParameters);
  }
}
