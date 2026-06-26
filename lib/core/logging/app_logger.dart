import 'dart:collection';

/// One entry in the log timeline — either a screen visit or an error.
class LogEntry {
  final DateTime time;
  final String type;     // "SCREEN" | "ERROR" | "ACTION"
  final String message;
  final String? detail;  // stack trace / extra info, kept short

  LogEntry({
    required this.type,
    required this.message,
    this.detail,
  }) : time = DateTime.now();

  String get formattedTime =>
      "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}";

  @override
  String toString() {
    final base = "[$formattedTime] $type: $message";
    return detail == null || detail!.isEmpty ? base : "$base\n   ↳ $detail";
  }

  Map<String, dynamic> toJson() => {
    "time": time.toIso8601String(),
    "type": type,
    "message": message,
    "detail": detail,
  };
}

/// App-wide logger. Keeps the last [_maxEntries] events in memory only —
/// nothing is written to disk, nothing slows the app down.
/// Call AppLogger.instance.logScreen(...) / logError(...) / logAction(...)
/// from anywhere in the app.
class AppLogger {
  AppLogger._internal();
  static final AppLogger instance = AppLogger._internal();

  static const int _maxEntries = 150;

  final Queue<LogEntry> _entries = Queue<LogEntry>();

  void _add(LogEntry entry) {
    _entries.addLast(entry);
    while (_entries.length > _maxEntries) {
      _entries.removeFirst();
    }
  }

  /// Call this whenever a new screen is opened.
  /// Wired automatically via AppNavigatorObserver — you usually don't
  /// need to call this by hand.
  void logScreen(String screenName) {
    _add(LogEntry(type: "SCREEN", message: screenName));
  }

  /// Call this for caught exceptions, API failures, etc.
  /// [context] is optional — e.g. "SalesOrder Submit", "Login API".
  void logError(Object error, [StackTrace? stack, String? context]) {
    final msg = context == null ? error.toString() : "$context → $error";
    _add(LogEntry(
      type: "ERROR",
      message: msg,
      detail: stack == null ? null : _trimStack(stack.toString()),
    ));
  }

  /// Optional — call this for important manual actions
  /// (e.g. "Tapped Submit on SalesOrder", "Logout pressed").
  void logAction(String label) {
    _add(LogEntry(type: "ACTION", message: label));
  }

  String _trimStack(String stack) {
    final lines = stack.split('\n');
    return lines.take(8).join('\n'); // keep stack trace short
  }

  /// All current log entries, oldest first.
  List<LogEntry> get entries => _entries.toList();

  /// Human-readable text block — what gets shown in preview / sent to server.
  String exportAsText() => _entries.map((e) => e.toString()).join('\n\n');

  /// Structured JSON — easier for the server to store & query later.
  List<Map<String, dynamic>> exportAsJson() =>
      _entries.map((e) => e.toJson()).toList();

  void clear() => _entries.clear();
}
