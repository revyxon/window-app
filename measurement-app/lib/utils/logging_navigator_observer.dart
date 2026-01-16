import 'package:flutter/material.dart';
import '../services/log_service.dart';

class LoggingNavigatorObserver extends RouteObserver<PageRoute<dynamic>> {
  final LogService _logService = LogService();

  void _logScreenView(PageRoute<dynamic> route) {
    var screenName = route.settings.name;

    // If name is null (e.g. anonymous route), try to use the widget type
    if (screenName == null) {
      // This is a bit of a hack but better than "null"
      // In a real pro app, we'd ensure all routes are named.
      // logic: route.builder might give a clue, but usually we just prefer named routes.
    }

    if (screenName != null) {
      _logService.logScreenView(screenName);
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      _logScreenView(route);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute && route is PageRoute) {
      _logScreenView(previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is PageRoute) {
      _logScreenView(newRoute);
    }
  }
}
