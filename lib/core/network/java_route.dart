import 'package:maleva/core/config/app_config.dart';

/// Which .NET app controllers a Java bridge (`/api/mobile/app`) serves: none.
///
/// The owner's rule (2026-10-02): the app calls the shared Java APIs the web
/// uses, and no new .NET-shaped bridge endpoints are made. The last one, stock,
/// moved to the shared `/api/stock-ins` (`StockInApi`). [moved] stays empty;
/// [isJava] tells the HTTP helpers which URLs carry the Java session token.
///
/// The Java backend answers each moved controller at
/// `/api/mobile/app/<Controller>/<Action>` with exactly the .NET contract
/// (backend change `add-mobile-app-api`), so a call only changes host and
/// token: [resolve] rewrites the URL, and the shared HTTP helpers send Java
/// URLs through [JavaApiClient] (session token, refresh on 401).
///
/// Moving a controller (or one action) is one entry in [moved]; removing it
/// sends it back to .NET.
class JavaRoute {
  JavaRoute._();

  static const String appApi = '${AppConfig.javaBaseUrl}/api/mobile/app';

  /// What has moved, spelled as the Java backend maps it: a whole controller
  /// (`FuelEntryApp`) or one action (`CustomerApp/GetCustomer`) when only some
  /// of a controller's actions have moved.
  static const Set<String> moved = {};

  static final Map<String, String> _byLowerName = {
    for (final name in moved) name.toLowerCase(): name,
  };

  static final RegExp _legacyPath = RegExp(r'^/+api/([^/?]+)/([^/?]*)(.*)$');

  /// [url] on the Java host when it calls a moved controller or action on the
  /// .NET host; otherwise [url] unchanged. Names may be spelled in any case
  /// (.NET matched them case-insensitively).
  static String resolve(String url) {
    if (!url.startsWith(AppConfig.baseUrl)) return url;
    final match = _legacyPath.firstMatch(url.substring(AppConfig.baseUrl.length));
    if (match == null) return url;
    final controller = match.group(1)!;
    final action = match.group(2)!;
    final whole = _byLowerName[controller.toLowerCase()];
    final single = _byLowerName['$controller/$action'.toLowerCase()];
    final target = whole != null ? '$whole/$action' : single;
    if (target == null) return url;
    return '$appApi/$target${match.group(3)}';
  }

  /// True for a URL on the Java host (it must carry the Java session token).
  static bool isJava(String url) => url.startsWith(AppConfig.javaBaseUrl);
}
