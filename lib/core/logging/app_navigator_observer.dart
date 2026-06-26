import 'package:flutter/material.dart';
import 'app_logger.dart';

/// Attach this to MaterialApp's `navigatorObservers: [AppNavigatorObserver()]`.
/// Every time a screen is pushed or popped, it's recorded automatically —
/// no need to add logging code to every page.
class AppNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    AppLogger.instance.logScreen(_nameOf(route));
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      AppLogger.instance.logScreen("← back to ${_nameOf(previousRoute)}");
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      AppLogger.instance.logScreen(_nameOf(newRoute));
    }
  }

  String _nameOf(Route route) {
    // Named routes use settings.name; PageRouteBuilder/MaterialPageRoute
    // without a name falls back to the widget's runtimeType, which is
    // still readable, e.g. "SaleOrderView".
    if (route.settings.name != null && route.settings.name!.isNotEmpty) {
      return route.settings.name!;
    }
    final routeStr = route.toString();
    // Try to pull a readable widget name out of the route description.
    final match = RegExp(r'builder.*?=>\s*([A-Za-z0-9_]+)').firstMatch(routeStr);
    return match?.group(1) ?? route.runtimeType.toString();
  }
}
