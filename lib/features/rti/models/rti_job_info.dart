import 'package:maleva/features/rti/models/js_values.dart';

/// The vessel name and job quantity of an RTI job line (Java `RTIDetailsDto.vesselName` /
/// `jobQuantity`). Saved lines carry the values the server stored; a line looked up but not
/// yet saved previews them from its sale order with the server's rule (`RtiJobInfo.java`,
/// React `features/rti/utils/rtiJobInfo.ts`):
/// - job type 11 (`jobMasterRefId`): the vessel whose ETA (`eta` loading / `oeta` off-loading)
///   is nearest now, before or after; one ETA → that vessel; a tie keeps the loading vessel;
/// - other job types: the loading vessel, else the off-loading vessel;
/// - an empty name falls back to the other vessel;
/// - job quantity: `quantity / totalWeight`, empty parts left out.
abstract final class RtiJobInfo {
  static const nearestEtaJobTypeId = 11;

  /// `(vesselName, jobQuantity)` from a sale-order master (Java camelCase fields).
  static ({String vesselName, String jobQuantity}) fromSaleOrder(Map<String, dynamic>? so, {DateTime? now}) {
    if (so == null) return (vesselName: '', jobQuantity: '');
    return (
      vesselName: vesselName(
        jobTypeId: Js.fieldNumber(so, ['jobMasterRefId']).toInt(),
        loadingVessel: Js.fieldText(so, ['loadingvesselname']),
        offVessel: Js.fieldText(so, ['offvesselname']),
        loadingEta: parseEta(Js.fieldText(so, ['eta'])),
        offEta: parseEta(Js.fieldText(so, ['oeta'])),
        now: now ?? DateTime.now(),
      ),
      jobQuantity: jobQuantity(Js.fieldText(so, ['quantity']), Js.fieldText(so, ['totalWeight'])),
    );
  }

  static String vesselName({
    required int jobTypeId,
    required String loadingVessel,
    required String offVessel,
    DateTime? loadingEta,
    DateTime? offEta,
    required DateTime now,
  }) {
    final loading = loadingVessel.trim();
    final off = offVessel.trim();
    final loadingFirst = loading.isNotEmpty ? loading : off;
    final offFirst = off.isNotEmpty ? off : loading;
    if (jobTypeId != nearestEtaJobTypeId) return loadingFirst;
    if (loadingEta != null && offEta != null) {
      final loadingGap = loadingEta.difference(now).abs();
      final offGap = offEta.difference(now).abs();
      return offGap < loadingGap ? offFirst : loadingFirst;
    }
    return offEta != null ? offFirst : loadingFirst;
  }

  static String jobQuantity(String quantity, String totalWeight) => [quantity.trim(), totalWeight.trim()].where((p) => p.isNotEmpty).join(' / ');

  /// ISO or `dd/MM/yyyy[ HH:mm[:ss]]`; SQL Server's empty date (1900) and bad text are no ETA.
  static DateTime? parseEta(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return null;
    final dayFirst = RegExp(r'^(\d{2})/(\d{2})/(\d{4})(?:[ T](\d{2}):(\d{2})(?::(\d{2}))?)?$').firstMatch(t);
    if (dayFirst != null) {
      int g(int i) => int.parse(dayFirst.group(i) ?? '0');
      return DateTime(g(3), g(2), g(1), g(4), g(5), g(6));
    }
    final parsed = DateTime.tryParse(t);
    return parsed == null || parsed.year <= 1900 ? null : parsed;
  }

  /// The RTI's job-line vessels, each once, in grid order (the route activity's choices).
  static List<String> vesselOptions(Iterable<({String vesselName, String jobQuantity})> lines) {
    final seen = <String>{};
    return [
      for (final l in lines)
        if (l.vesselName.trim().isNotEmpty && seen.add(l.vesselName.trim())) l.vesselName.trim(),
    ];
  }

  /// The job quantities of the lines carrying [vessel], each once, joined with ", ".
  static String jobQuantityForVessel(Iterable<({String vesselName, String jobQuantity})> lines, String vessel) {
    final v = vessel.trim();
    if (v.isEmpty) return '';
    final seen = <String>{};
    return [
      for (final l in lines)
        if (l.vesselName.trim() == v && l.jobQuantity.trim().isNotEmpty && seen.add(l.jobQuantity.trim())) l.jobQuantity.trim(),
    ].join(', ');
  }
}
