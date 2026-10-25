import 'package:maleva/features/planning/data/js_values.dart';

/// Fleet F4: a truck's regular drivers, read as `GET /api/planning/regular-drivers` answers (the web's
/// `utils/regularDrivers.ts`): the driver Driver Master assigns to the truck, the last RTI driver (60 days) and the
/// one on most of its RTIs (90 days). A suggestion for the driver picker only.
class RegularDriver {
  const RegularDriver({
    required this.truckRefId,
    this.assignedDriverRefId = 0,
    this.lastRtiDriverRefId = 0,
    this.mostUsedDriverRefId = 0,
    this.mostUsedRtis = 0,
  });

  factory RegularDriver.fromJava(Map<String, dynamic> m) => RegularDriver(
        truckRefId: Js.intOr0(m['truckRefId']),
        assignedDriverRefId: Js.intOr0(m['assignedDriverRefId']),
        lastRtiDriverRefId: Js.intOr0(m['lastRtiDriverRefId']),
        mostUsedDriverRefId: Js.intOr0(m['mostUsedDriverRefId']),
        mostUsedRtis: Js.intOr0(m['mostUsedRtis']),
      );

  final int truckRefId;
  final int assignedDriverRefId;
  final int lastRtiDriverRefId;
  final int mostUsedDriverRefId;
  final int mostUsedRtis;

  /// driver id → why it is on top ("assigned · last RTI · 63 RTIs"), the web's `regularNotesFor`.
  Map<int, String> get notes {
    final why = <int, List<String>>{};
    void add(int id, String reason) {
      if (id > 0) (why[id] ??= []).add(reason);
    }

    add(assignedDriverRefId, 'assigned');
    add(lastRtiDriverRefId, 'last RTI');
    add(mostUsedDriverRefId, mostUsedRtis > 0 ? '$mostUsedRtis RTIs' : 'most used');
    return {for (final e in why.entries) e.key: e.value.join(' · ')};
  }

  /// [items] with this truck's regular drivers first (most reasons first), the rest in their order (`withRegularFirst`).
  static List<T> regularFirst<T>(List<T> items, int Function(T) idOf, Map<int, String> notes) {
    if (notes.isEmpty) return items;
    int weight(T d) => (notes[idOf(d)] ?? '').split(' · ').where((p) => p.isNotEmpty).length;
    final top = items.where((d) => notes.containsKey(idOf(d))).toList()..sort((a, b) => weight(b).compareTo(weight(a)));
    return [...top, ...items.where((d) => !notes.containsKey(idOf(d)))];
  }
}
