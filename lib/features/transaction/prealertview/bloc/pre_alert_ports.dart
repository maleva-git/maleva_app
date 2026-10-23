/// Which ports the Pre Alert tab offers (openspec change boarding-pre-alert-tab).
///
/// - Ports assigned to the user (EmployeePortMaster): only those, the first one
///   selected, no "All Ports" choice.
/// - None assigned: every active port of the company, as the web's picker, with
///   "All Ports" ('') selected.
class PreAlertPortChoice {
  const PreAlertPortChoice({required this.ports, required this.restricted, required this.selected});

  factory PreAlertPortChoice.of({required List<String> assigned, List<String> companyPorts = const []}) {
    final own = _clean(assigned);
    if (own.isNotEmpty) {
      return PreAlertPortChoice(ports: List.unmodifiable(own), restricted: true, selected: own.first);
    }
    return PreAlertPortChoice(ports: List.unmodifiable(_clean(companyPorts)), restricted: false, selected: '');
  }

  /// The drawer's screen: its own port search, none selected.
  static const open = PreAlertPortChoice(ports: [], restricted: false, selected: '');

  /// The ports in the dropdown.
  final List<String> ports;

  /// The user's own ports: no "All Ports" choice.
  final bool restricted;

  /// The port selected at start ('' = All Ports).
  final String selected;

  static List<String> _clean(List<String> names) {
    final out = <String>[];
    for (final p in names) {
      final name = p.trim();
      if (name.isNotEmpty && !out.contains(name)) out.add(name);
    }
    return out;
  }
}

/// The port to send with the report: in the tab the chosen port (none for All
/// Ports); on the drawer's screen only when the "Port" box is ticked, as the web does.
String? preAlertPortParam({required bool workMode, required bool checkPort, required String portName}) {
  final name = portName.trim();
  if (name.isEmpty) return null;
  return workMode || checkPort ? name : null;
}
