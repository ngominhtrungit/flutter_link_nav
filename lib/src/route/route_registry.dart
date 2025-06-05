import 'package:flutter/material.dart';

typedef RouteHandler = Widget? Function(dynamic queryParams, String? fromSource);

class RouteRegistry {
  static final Map<String, RouteHandler> _handlers = {};

  static void register(String route, RouteHandler handler) {
    _handlers[route] = handler;
  }

  static Widget? getHandler(
      String route, {
        dynamic queryParams,
        String? fromSource,
      }) {
    return _handlers[route]?.call(queryParams, fromSource);
  }
}