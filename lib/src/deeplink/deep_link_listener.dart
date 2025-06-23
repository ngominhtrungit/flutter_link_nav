import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

abstract class DeepLinkListener {
  void init(BuildContext context);
  Future<Uri?> getInitialLink();
  Stream<Uri> get uriLinkStream;
}

class AppLinksListener implements DeepLinkListener {
  final _appLinks = AppLinks();

  @override
  Future<Uri?> getInitialLink() => _appLinks.getInitialLink();

  @override
  Stream<Uri> get uriLinkStream => _appLinks.uriLinkStream;

  @override
  void init(BuildContext context) {
    // Implementation if needed
  }
}