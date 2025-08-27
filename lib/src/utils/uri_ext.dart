extension UriParser on Uri {
  ({String? deeplink, Map<String, String>? parameters}) parseUri() {
    String path = '';
    if (host.isNotEmpty) {
      path = host;
      String remainingPath = this.path;
      if (remainingPath.startsWith('/')) {
        remainingPath = remainingPath.substring(1);
      }
      if (remainingPath.isNotEmpty) {
        path = '$path/$remainingPath';
      }
    } else {
      path = this.path;
      if (path.startsWith('/')) {
        path = path.substring(1);
      }
    }

    if (path.isEmpty) {
      path = '';
    }

    Map<String, String> queryParams = queryParameters;

    return (deeplink: path, parameters: queryParams);
  }
}
