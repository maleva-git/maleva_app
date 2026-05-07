import 'dart:async';
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'gpstruckmap_event.dart';
import 'gpstruckmap_state.dart';


// ─────────────────────────────────────────────────────────────────────────────
//  Wialon token — same value already used in your web app (gpsapilist.cs)
// ─────────────────────────────────────────────────────────────────────────────
const String _kWialonBase  = 'https://hst-api.wialon.com/wialon/ajax.html';
const String _kWialonToken =
    'bcf761fd35a8ddcb42c042d48c8bcb95702666AF9C6669DBEA5935A50FD26A59D7E9C8CE';

/// How often we re-fetch truck positions while the tab is open
const Duration _kPollInterval = Duration(seconds: 30);

class GpsTruckMapBloc extends Bloc<GpsTruckMapEvent, GpsTruckMapState> {
  Timer?  _pollTimer;
  String? _wialonSid; // session id returned after token login

  GpsTruckMapBloc() : super(const GpsTruckMapInitial()) {
    on<LoadTruckPositions>(_onLoad);
    on<RefreshTruckPositions>(_onRefresh);
    on<SelectTruck>(_onSelectTruck);
    on<ClearSelection>(_onClearSelection);
  }

  // ── 1. Initial load ────────────────────────────────────────────────────────
  Future<void> _onLoad(
      LoadTruckPositions event,
      Emitter<GpsTruckMapState> emit,
      ) async {
    emit(const GpsTruckMapLoading());
    try {
      _wialonSid ??= await _wialonLogin();
      final trucks = await _fetchPositions(_wialonSid!);
      emit(GpsTruckMapLoaded(trucks: trucks));
      _startPolling();
    } catch (e) {
      emit(GpsTruckMapError(_friendlyError(e)));
    }
  }

  // ── 2. Polling refresh ─────────────────────────────────────────────────────
  Future<void> _onRefresh(
      RefreshTruckPositions event,
      Emitter<GpsTruckMapState> emit,
      ) async {
    final current = state;
    if (current is! GpsTruckMapLoaded) return;
    emit(current.copyWith(isRefreshing: true));
    try {
      // Re-login if session expired (Wialon sessions last ~1 hour)
      _wialonSid ??= await _wialonLogin();
      final trucks = await _fetchPositions(_wialonSid!);
      emit(current.copyWith(trucks: trucks, isRefreshing: false));
    } catch (e) {
      // On session expiry, clear sid so next refresh re-authenticates
      if (e.toString().contains('1')) _wialonSid = null;
      emit(current.copyWith(isRefreshing: false));
    }
  }

  // ── 3. Truck selected ──────────────────────────────────────────────────────
  void _onSelectTruck(SelectTruck event, Emitter<GpsTruckMapState> emit) {
    final current = state;
    if (current is GpsTruckMapLoaded) {
      emit(current.copyWith(selected: event.truck));
    }
  }

  // ── 4. Clear selection ─────────────────────────────────────────────────────
  void _onClearSelection(ClearSelection event, Emitter<GpsTruckMapState> emit) {
    final current = state;
    if (current is GpsTruckMapLoaded) {
      emit(current.copyWith(clearSelected: true));
    }
  }

  // ── Wialon helpers ─────────────────────────────────────────────────────────

  /// Login with token → returns session id (sid)
  Future<String> _wialonLogin() async {
    final url = Uri.parse(
      '$_kWialonBase?svc=token/login'
          '&params={"token":"$_kWialonToken","fl":"0x1"}',
    );
    final resp = await http.get(url).timeout(const Duration(seconds: 15));
    if (resp.statusCode != 200) throw Exception('Wialon login HTTP ${resp.statusCode}');
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    if (json.containsKey('error')) throw Exception('Wialon error: ${json['error']}');
    return json['eid'] as String;
  }

  /// Fetch all AVL units with their last position (flag 0x101 = base+lastMessage)
  Future<List<TruckPosition>> _fetchPositions(String sid) async {
    final params = jsonEncode({
      'spec': {
        'itemsType':     'avl_unit',
        'propName':      'sys_name',
        'propValueMask': '*',
        'sortType':      'sys_name',
      },
      'force': 1,
      'flags': 0x101, // name + last-message (position & speed)
      'from':  0,
      'to':    0,
    });
    final url = Uri.parse(
      '$_kWialonBase?svc=core/search_items&sid=$sid&params=${Uri.encodeComponent(params)}',
    );
    final resp = await http.get(url).timeout(const Duration(seconds: 15));
    if (resp.statusCode != 200) throw Exception('Wialon search HTTP ${resp.statusCode}');
    final json      = jsonDecode(resp.body) as Map<String, dynamic>;
    if (json.containsKey('error')) {
      // error 1 = invalid session — caller should re-login
      throw Exception('${json['error']}');
    }
    final items     = (json['items'] as List? ?? []);
    final formatter = DateFormat('dd/MM HH:mm');
    final now       = DateTime.now();

    return items
        .where((item) {
      // Only include units that have a valid last position
      final pos = item['pos'];
      return pos != null && pos['y'] != null && pos['x'] != null;
    })
        .map<TruckPosition>((item) {
      final pos    = item['pos'] as Map<String, dynamic>;
      final tMs    = (pos['t'] as int? ?? 0) * 1000;
      final dt     = tMs > 0
          ? DateTime.fromMillisecondsSinceEpoch(tMs)
          : now;
      final speed  = (pos['s'] as num? ?? 0).toDouble();
      return TruckPosition(
        unitId:      item['id'] as int,
        truckName:   item['nm'] as String? ?? 'Unknown',
        lat:         (pos['y'] as num).toDouble(),
        lng:         (pos['x'] as num).toDouble(),
        speedKmh:    speed,
        lastUpdate:  formatter.format(dt),
      );
    })
        .toList();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_kPollInterval, (_) {
      if (!isClosed) add(const RefreshTruckPositions());
    });
  }

  String _friendlyError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('socket') || msg.contains('network')) {
      return 'No internet connection. Check your network.';
    }
    if (msg.contains('timeout')) {
      return 'GPS server timed out. Pull to retry.';
    }
    return 'Could not load truck positions. $e';
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }
}