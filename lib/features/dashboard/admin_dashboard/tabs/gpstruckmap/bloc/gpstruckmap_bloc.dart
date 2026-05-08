import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'gpstruckmap_event.dart';
import 'gpstruckmap_state.dart';

const String _kBase  = 'https://hst-api.wialon.com/wialon/ajax.html';
const String _kToken =
    'bcf761fd35a8ddcb42c042d48c8bcb95702666AF9C6669DBEA5935A50FD26A59D7E9C8CE';

const Duration _kPollInterval = Duration(seconds: 30);
const Duration _kTimeout      = Duration(seconds: 20);

class GpsTruckMapBloc extends Bloc<GpsTruckMapEvent, GpsTruckMapState> {
  Timer?  _pollTimer;
  String? _sid;
  final Map<int, String> _unitNames = {};

  GpsTruckMapBloc() : super(const GpsTruckMapInitial()) {
    on<LoadTruckPositions>(_onLoad);
    on<RefreshTruckPositions>(_onRefresh);
    on<SelectTruck>(_onSelect);
    on<LoadTruckPath>(_onLoadPath);
    on<ClearSelection>(_onClear);
  }

  // ── Event handlers ─────────────────────────────────────────────────────────

  Future<void> _onLoad(LoadTruckPositions _, Emitter<GpsTruckMapState> emit) async {
    emit(const GpsTruckMapLoading());
    try {
      _sid = await _login();
      _unitNames.clear();
      debugPrint('[GPS] SID: $_sid');

      final trucks = await _fetchLivePositions(_sid!);
      debugPrint('[GPS] Live trucks loaded: ${trucks.length}');
      emit(GpsTruckMapLoaded(trucks: trucks));
      _startPolling();
    } catch (e) {
      debugPrint('[GPS] Load error: $e');
      emit(GpsTruckMapError(_friendly(e)));
    }
  }

  Future<void> _onRefresh(RefreshTruckPositions _, Emitter<GpsTruckMapState> emit) async {
    final cur = state;
    if (cur is! GpsTruckMapLoaded) return;

    emit(cur.copyWith(isRefreshing: true));

    try {
      _sid ??= await _login();
      final unitIds = _unitNames.keys.toList();
      final newTrucks = await _subscribeAndParse(_sid!, unitIds);

      // Create a Map of the old trucks for quick lookup
      final Map<int, TruckPosition> updatedMap = {
        for (var t in cur.trucks) t.unitId: t
      };

      // Overwrite only the trucks that gave us new data
      for (var nt in newTrucks) {
        updatedMap[nt.unitId] = nt;
      }

      emit(cur.copyWith(
        trucks: updatedMap.values.toList(),
        isRefreshing: false,
      ));
    } catch (e) {
      // Handle error...
    }
  }
  void _onSelect(SelectTruck e, Emitter<GpsTruckMapState> emit) {
    final cur = state;
    if (cur is GpsTruckMapLoaded) {
      emit(cur.copyWith(
        selected:  e.truck,
        clearPath: cur.selected?.unitId != e.truck.unitId,
      ));
    }
  }

  Future<void> _onLoadPath(LoadTruckPath e, Emitter<GpsTruckMapState> emit) async {
    final cur = state;
    if (cur is! GpsTruckMapLoaded) return;
    emit(cur.copyWith(isLoadingPath: true));
    try {
      _sid ??= await _login();
      final points = await _fetchTodayPath(_sid!, e.truck.unitId);
      debugPrint('[GPS] Path points for ${e.truck.truckName}: ${points.length}');
      emit(cur.copyWith(path: points, isLoadingPath: false));
    } catch (e2) {
      debugPrint('[GPS] Path error: $e2');
      emit(cur.copyWith(isLoadingPath: false));
    }
  }

  void _onClear(ClearSelection _, Emitter<GpsTruckMapState> emit) {
    final cur = state;
    if (cur is GpsTruckMapLoaded) {
      emit(cur.copyWith(clearSelected: true, clearPath: true));
    }
  }

  // ── Login ──────────────────────────────────────────────────────────────────

  Future<String> _login() async {
    final uri = Uri.parse(
      '$_kBase?svc=token/login'
          '&params=${Uri.encodeComponent('{"token":"$_kToken","fl":"1"}')}',
    );
    final resp = await http.get(uri).timeout(_kTimeout);
    if (resp.statusCode != 200) throw Exception('Login HTTP ${resp.statusCode}');
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    if (body.containsKey('error')) throw Exception('Wialon login error: ${body['error']}');
    return body['eid'] as String;
  }

  // ── Live positions ─────────────────────────────────────────────────────────
  //
  // SITUATION:
  //   • core/search_items (any flags)     → no position data (scope too low)
  //   • messages/load_last_messages        → error 2 (access denied)
  //   • avl_evts                           → error 2 (access denied)
  //   • core/update_data_flags             → WORKS and returns the initial
  //                                          state snapshot in its response body
  //
  // APPROACH:
  //   1. search_items(flags=1)  — just to enumerate unit IDs + names
  //   2. core/update_data_flags — subscribe with flags=0xFFFFFFFF to ask for
  //      every possible data field the token can access.  The response IS the
  //      initial state; we parse it directly (no avl_evts call needed).
  //   3. For refresh polling we repeat step 2 with mode=0 (set), which causes
  //      Wialon to re-send the full current state again.
  //
  Future<List<TruckPosition>> _fetchLivePositions(String sid) async {
    final items = await _searchItems(sid, flags: 1);
    debugPrint('[GPS] Total units: ${items.length}');
    if (items.isEmpty) return [];

    for (final i in items) {
      _unitNames[(i['id'] as num).toInt()] = i['nm'] as String? ?? 'Unknown';
    }
    final unitIds = _unitNames.keys.toList();

    return _subscribeAndParse(sid, unitIds);
  }

  // ── core/update_data_flags → parse response directly ──────────────────────

  Future<List<TruckPosition>> _subscribeAndParse(
      String sid,
      List<int> unitIds,
      ) async {
    if (unitIds.isEmpty) return [];

    // Use 0xFFFFFFFF to request every field the token is allowed to see.
    // Wialon silently strips any fields the token lacks rights for, so this
    // is safe — it won't error, it just won't return restricted fields.
    final params = jsonEncode({
      'spec': [
        {
          'type': 'col',
          'data': unitIds,
          'flags': 0xFFFFFFFF,
          'mode': 0,           // 0 = set (re-sends full current state)
        },
      ],
    });

    final uri = Uri.parse(
      '$_kBase?svc=core/update_data_flags'
          '&sid=${Uri.encodeComponent(sid)}'
          '&params=${Uri.encodeComponent(params)}',
    );

    final resp = await http.get(uri).timeout(_kTimeout);
    if (resp.statusCode != 200) {
      throw Exception('update_data_flags HTTP ${resp.statusCode}');
    }

    final raw = jsonDecode(resp.body);
    if (raw is Map && raw.containsKey('error')) {
      throw Exception('update_data_flags error: ${raw['error']}');
    }

    final items = raw as List? ?? [];
    debugPrint('[GPS] update_data_flags returned ${items.length} items');

    // ── DIAGNOSTIC: print first item in full so we can see every field ──────
    if (items.isNotEmpty) {
      final sample = const JsonEncoder.withIndent('  ').convert(items.first);
      debugPrint('[GPS] ===== FIRST ITEM (all flags) =====');
      for (var c = 0; c * 800 < sample.length; c++) {
        final s = c * 800;
        debugPrint('[GPS] ${sample.substring(s, (s + 800).clamp(0, sample.length))}');
      }
      debugPrint('[GPS] ===== END FIRST ITEM =====');
    }
    // ────────────────────────────────────────────────────────────────────────

    final fmt    = DateFormat('dd MMM HH:mm');
    final now    = DateTime.now();
    final result = <TruckPosition>[];

    for (final item in items) {
      final m      = item as Map<String, dynamic>;
      final unitId = (m['i'] as num?)?.toInt();
      if (unitId == null) continue;

      final nm = _unitNames[unitId] ?? 'Unknown';
      final d  = m['d'] as Map<String, dynamic>?;
      if (d == null) continue;

      Map<String, dynamic>? pos;
      DateTime?             dt;

      // ── Search every known Wialon location for GPS coordinates ─────────

      // 1. lmsg block (most common for hst-api)
      final lmsg = d['lmsg'] as Map<String, dynamic>?;
      if (lmsg != null) {
        pos = lmsg['pos'] as Map<String, dynamic>?;
        final t = (lmsg['t'] as num?)?.toInt() ?? 0;
        if (t > 0) dt = DateTime.fromMillisecondsSinceEpoch(t * 1000);
      }

      // 2. pos at root of d
      if (pos == null) {
        pos = d['pos'] as Map<String, dynamic>?;
        if (pos != null) {
          final t = (pos['t'] as num?)?.toInt() ?? 0;
          if (t > 0) dt = DateTime.fromMillisecondsSinceEpoch(t * 1000);
        }
      }

      // 3. last_message (some Wialon builds use this key)
      if (pos == null) {
        final lm = d['last_message'] as Map<String, dynamic>?;
        if (lm != null) {
          pos = lm['pos'] as Map<String, dynamic>?;
          final t = (lm['t'] as num?)?.toInt() ?? 0;
          if (t > 0) dt = DateTime.fromMillisecondsSinceEpoch(t * 1000);
        }
      }

      // 4. lp (last position shortcut used by some account tiers)
      if (pos == null) {
        pos = d['lp'] as Map<String, dynamic>?;
      }

      if (pos == null) {
        // Log EVERY key available so we know exactly what the token returns.
        debugPrint('[GPS] $nm — no pos found. d keys: ${d.keys.toList()}');
        continue;
      }

      final lat = (pos['y'] as num?)?.toDouble();
      final lng = (pos['x'] as num?)?.toDouble();
      if (lat == null || lng == null || (lat == 0.0 && lng == 0.0)) {
        debugPrint('[GPS] $nm — zero/null coords (lat:$lat lng:$lng)');
        continue;
      }

      final spd = (pos['s'] as num?)?.toDouble() ?? 0.0;
      dt ??= now;

      debugPrint('[GPS] ✓ $nm → lat:$lat lng:$lng speed:${spd}km/h '
          'at ${fmt.format(dt)}');

      result.add(TruckPosition(
        unitId:     unitId,
        truckName:  nm,
        lat:        lat,
        lng:        lng,
        speedKmh:   spd,
        lastUpdate: fmt.format(dt),
        lastSeen:   dt,
      ));
    }

    return result;
  }

  // ── Unit list ──────────────────────────────────────────────────────────────

  Future<List<dynamic>> _searchItems(String sid, {required int flags}) async {
    final params = jsonEncode({
      'spec': {
        'itemsType':     'avl_unit',
        'propName':      'sys_name',
        'propValueMask': '*',
        'sortType':      'sys_name',
      },
      'force': 1,
      'flags': flags,
      'from':  0,
      'to':    0,
    });

    final uri = Uri.parse(
      '$_kBase?svc=core/search_items'
          '&sid=${Uri.encodeComponent(sid)}'
          '&params=${Uri.encodeComponent(params)}',
    );
    debugPrint('[GPS] search_items flags=$flags');

    final resp = await http.get(uri).timeout(_kTimeout);
    if (resp.statusCode != 200) throw Exception('search_items HTTP ${resp.statusCode}');
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    if (body.containsKey('error')) throw Exception('Wialon error: ${body['error']}');
    return (body['items'] as List?) ?? [];
  }

  // ── Today's path ───────────────────────────────────────────────────────────

  Future<List<PathPoint>> _fetchTodayPath(String sid, int unitId) async {
    final now        = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final fromEpoch  = todayStart.millisecondsSinceEpoch ~/ 1000;
    final toEpoch    = now.millisecondsSinceEpoch        ~/ 1000;

    final params = jsonEncode({
      'itemId':    unitId,
      'timeFrom':  fromEpoch,
      'timeTo':    toEpoch,
      'flags':     0x0001,
      'flagsMask': 0xFF00,
      'loadCount': 10000,
    });

    final uri = Uri.parse(
      '$_kBase?svc=messages/load_interval'
          '&sid=${Uri.encodeComponent(sid)}'
          '&params=${Uri.encodeComponent(params)}',
    );

    final resp = await http.get(uri).timeout(const Duration(seconds: 30));
    if (resp.statusCode != 200) throw Exception('load_interval HTTP ${resp.statusCode}');
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    if (body.containsKey('error')) throw Exception('load_interval error: ${body['error']}');

    final messages = (body['messages'] as List?) ?? [];
    debugPrint('[GPS] Path messages for unit $unitId: ${messages.length}');

    return messages.map((msg) {
      final m   = msg as Map<String, dynamic>;
      final pos = m['pos'] as Map<String, dynamic>?;
      if (pos == null) return null;
      final lat = (pos['y'] as num?)?.toDouble();
      final lng = (pos['x'] as num?)?.toDouble();
      if (lat == null || lng == null || (lat == 0.0 && lng == 0.0)) return null;
      return PathPoint(
        lat:      lat,
        lng:      lng,
        speedKmh: (pos['s'] as num?)?.toDouble() ?? 0.0,
        time:     DateTime.fromMillisecondsSinceEpoch(
            ((m['t'] as num?)?.toInt() ?? 0) * 1000),
      );
    }).whereType<PathPoint>().toList();
  }

  // ── Polling ────────────────────────────────────────────────────────────────

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_kPollInterval, (_) {
      if (!isClosed) add(const RefreshTruckPositions());
    });
  }

  String _friendly(Object e) {
    final s = e.toString().toLowerCase();
    if (s.contains('socket') || s.contains('network')) {
      return 'No internet. Check your connection.';
    }
    if (s.contains('timeout'))  return 'GPS server timed out. Tap retry.';
    if (s.contains('error: 1')) return 'GPS session expired. Tap retry.';
    return 'Could not load GPS data.\n$e';
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }
}