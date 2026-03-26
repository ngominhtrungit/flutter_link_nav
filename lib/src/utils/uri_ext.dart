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
      // Check if the host is a registered route
      // If host is a route (e.g., main_screen), then path will be host + remaining path
      // If host is a domain (e.g., example.vn), and path contains the route, we might ignore the host
      
      if (RouteRegistry.getRouteConfig(host) != null) {
        fullPath = host;
        if (normalizedPath.isNotEmpty) {
          fullPath = '$fullPath/$normalizedPath';
        }
      } else {
        // If host is not a route, treat it as a domain and only use the path
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
