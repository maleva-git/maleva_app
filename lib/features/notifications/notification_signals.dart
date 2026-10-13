import 'dart:async';

/// "Something about the bell may have changed": a push arrived, a notice was read, or vessel jobs were
/// updated or dismissed. The bell, the dashboard banner and an open notifications page reload at once.
class NotificationSignals {
  NotificationSignals._();

  static final StreamController<void> _refresh = StreamController<void>.broadcast();

  static Stream<void> get refresh => _refresh.stream;

  static void changed() => _refresh.add(null);
}
