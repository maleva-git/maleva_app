import 'package:maleva/features/planning/models/plan_line.dart';
import 'package:maleva/features/planning/models/plan_line_copy.dart';

/// Fleet F4: the TRIP of a plan row — a 1:1 port of the web's `features/Planning/utils/planTrips.ts`
/// (openspec change f4-trip-number-and-driver), so the app and the web behave the same.
///
/// Same number = same truckload of that truck ("COMBINE" = the same number). Typing a number on a row fills the
/// blank rows under it on the same truck (FILLED) until the next row the planner wrote. The backend groups
/// Create All RTI by the same numbers; a row without one still reads "1ST TRIP" in Remarks.
class PlanTrips {
  PlanTrips._();

  static const maxTrip = 20;

  static const typed = 'TYPED';
  static const filled = 'FILLED';
  static const ai = 'AI';
  static const fromRemarks = 'REMARKS';
  static const backfill = 'BACKFILL';
  static const none = 'NONE';

  static const _sources = {typed, filled, ai, fromRemarks, backfill};

  /// 1-20, or 0 for anything else (empty, 0, text).
  static int parseTrip(Object? value) {
    final n = int.tryParse('${value ?? ''}'.trim());
    return n != null && n >= 1 && n <= maxTrip ? n : 0;
  }

  static int tripOf(PlanLine row) => row.tripNo >= 1 && row.tripNo <= maxTrip ? row.tripNo : 0;

  static String sourceOf(PlanLine row) {
    final s = row.tripSource.trim().toUpperCase();
    return _sources.contains(s) ? s : '';
  }

  static final _numberThenTrip = RegExp(r'(\d+)[A-Z]{0,4}\s*TRIPS?\b');
  static final _tripThenNumber = RegExp(r'\bTRIPS?\s*(\d+)');

  /// The same reading as the backend's TripMarkers: "1ST TRIP", "2NDNTRIP", "TRIP 3", "27TH ETD(2ND TRIP)"; 0 = none.
  static int tripInRemarks(String? remarks) {
    final text = (remarks ?? '').toUpperCase();
    if (!text.contains('TRIP')) return 0;
    final m = _numberThenTrip.firstMatch(text) ?? _tripThenNumber.firstMatch(text);
    return parseTrip(m?.group(1));
  }

  /// A row the planner (or the AI, the back-fill) wrote: fill-down stops there.
  static bool _written(PlanLine row) => tripOf(row) > 0 && sourceOf(row).isNotEmpty && sourceOf(row) != filled;

  /// The planner typed [value] in the TRIP of the row at [index] (rows in the plan's order). Returns new rows: that
  /// row TYPED (or cleared), the rows under it on the same truck refilled up to the next written row.
  static List<PlanLine> applyTripEdit(List<PlanLine> rows, int index, Object? value) {
    final out = [...rows];
    if (index < 0 || index >= out.length) return out;
    final trip = parseTrip(value);
    final row = out[index].copyWith(tripNo: trip, tripSource: trip == 0 ? '' : typed);
    out[index] = row;
    final truck = row.truckRefid;
    if (truck <= 0) return out;
    // what the rows under it carry: this row's trip, or (cleared) the trip of the nearest row above on the truck
    var carry = trip;
    if (carry == 0) {
      for (var i = index - 1; i >= 0; i--) {
        if (out[i].truckRefid == truck && tripOf(out[i]) > 0) {
          carry = tripOf(out[i]);
          break;
        }
      }
    }
    for (var i = index + 1; i < out.length; i++) {
      if (out[i].truckRefid != truck) continue;
      if (_written(out[i])) break;
      out[i] = out[i].copyWith(tripNo: carry, tripSource: carry == 0 ? '' : filled);
    }
    return out;
  }

  /// What the TRIP shows for this row.
  static TripCell cell(PlanLine row) {
    final trip = tripOf(row);
    if (trip > 0) {
      final source = sourceOf(row);
      return TripCell(trip, source == typed || source == ai ? TripKind.typed : TripKind.filled);
    }
    final remarks = tripInRemarks(row.remarks);
    return remarks > 0 ? TripCell(remarks, TripKind.remarks) : const TripCell(0, TripKind.none);
  }

  /// The two save fields, always sent ("NONE" tells the backend this screen keeps trips and the row has none).
  static Map<String, dynamic> forSave(PlanLine row) {
    final trip = tripOf(row);
    if (trip == 0 || row.truckRefid <= 0) return {'tripNo': null, 'tripSource': none};
    final source = sourceOf(row);
    return {'tripNo': trip, 'tripSource': source.isEmpty ? typed : source};
  }
}

enum TripKind { typed, filled, remarks, none }

/// The number to show (0 = nothing) and how it looks: typed bold, filled grey, from Remarks grey italic.
class TripCell {
  const TripCell(this.value, this.kind);

  final int value;
  final TripKind kind;

  String get label => value > 0 ? '$value' : '';

  String get hint => switch (kind) {
        TripKind.typed => 'Trip typed here',
        TripKind.filled => 'Filled from the trip above',
        TripKind.remarks => 'Read from Remarks',
        TripKind.none => 'Trip of this truck: 1, 2, 3',
      };
}
