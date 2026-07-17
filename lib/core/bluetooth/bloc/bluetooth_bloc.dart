import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';
import 'package:bluetooth_print_plus/src/blue_device.dart';
import 'package:bluetooth_print_plus/src/enum_tool.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/utils/printer_helper.dart';
import 'package:maleva/core/models/shared/bluetooth_model.dart';
part 'bluetooth_event.dart';
part 'bluetooth_state.dart';

class BluetoothBloc extends Bloc<BluetoothEvent, BluetoothState> {
  BluetoothBloc() : super(const BluetoothState()) {
    on<BluetoothInitialized>(_onInit);
    on<BluetoothScanStarted>(_onScanStarted);
    on<BluetoothScanStopped>(_onScanStopped);
    on<BluetoothDeviceConnectRequested>(_onConnectDevice);
    on<_BluetoothScanResultsUpdated>(_onScanResults);
    on<_BluetoothScanningChanged>(_onScanningChanged);
    on<_BluetoothStateChanged>(_onBlueStateChanged);
    on<_BluetoothConnectStateChanged>(_onConnectStateChanged);
  }

  // ── Stream subscriptions — managed here, cancelled in close() ─────────────
  StreamSubscription<List<BluetoothDevice>>? _scanResultsSub;
  StreamSubscription<bool>?                  _isScanSub;
  StreamSubscription<BlueState>?             _blueStateSub;
  StreamSubscription<ConnectState>?          _connectStateSub;
  StreamSubscription<Uint8List>?             _receivedDataSub;

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> _onInit(
      BluetoothInitialized event,
      Emitter<BluetoothState> emit,
      ) async {

    // FIX 1: await used for isBlueOn
    bool isBlueOn = await BluetoothPrintPlus.isBlueOn;

    emit(state.copyWith(
      isBlueOn: isBlueOn,
    ));

    // ── Subscribe to all hardware streams ─────────────────────────────────

    _scanResultsSub = BluetoothPrintPlus.scanResults.listen((results) {
      add(_BluetoothScanResultsUpdated(results));
    });

    _isScanSub = BluetoothPrintPlus.isScanning.listen((scanning) {
      add(_BluetoothScanningChanged(scanning));
    });

    _blueStateSub = BluetoothPrintPlus.blueState.listen((blueState) {
      add(_BluetoothStateChanged(blueState));
    });

    _connectStateSub = BluetoothPrintPlus.connectState.listen((connectState) {
      add(_BluetoothConnectStateChanged(
        connectState,
        device: state.selectedDevice,
      ));
    });

    _receivedDataSub = BluetoothPrintPlus.receivedData.listen((data) {
      debugPrint('Bluetooth received data: $data');
    });

    // ── Auto-connect when PrintData was passed ────────────────────────────

    if (event.autoConnect) {
      // FIX 2: Check if list is not empty, else throw error to avoid infinite loading
      if (bluetoothdeviceList.isNotEmpty) {
        // FIX 3: Correct BluetoothDevice object creation
        final device = BluetoothDevice(
          bluetoothdeviceList[0].name,
          bluetoothdeviceList[0].address,
        );

        emit(state.copyWith(
          isAutoConnecting: true,
          selectedDevice:   device,
          status:           BluetoothStatus.connectingToDevice,
        ));

        try {
          await BluetoothPrintPlus.connect(device);
        } catch (e, st) {
          emit(state.copyWith(
            status:       BluetoothStatus.failure,
            errorMessage: "Connection Failed: ${e.toString()}",
            isAutoConnecting: false,
          ));
          _log(e, st);
        }
      } else {
        // No device saved, but tried to auto-connect
        emit(state.copyWith(
          status: BluetoothStatus.failure,
          errorMessage: 'No saved Bluetooth device found. Please scan and connect.',
          isAutoConnecting: false,
        ));
      }
    }
  }

  // ── Scan ──────────────────────────────────────────────────────────────────

  Future<void> _onScanStarted(
      BluetoothScanStarted event,
      Emitter<BluetoothState> emit,
      ) async {
    try {
      await BluetoothPrintPlus.startScan(timeout: const Duration(seconds: 10));
    } catch (e, st) {
      emit(state.copyWith(
        status:       BluetoothStatus.failure,
        errorMessage: e.toString(),
      ));
      _log(e, st);
    }
  }

  Future<void> _onScanStopped(
      BluetoothScanStopped event,
      Emitter<BluetoothState> emit,
      ) async {
    try {
      BluetoothPrintPlus.stopScan();
    } catch (e, st) {
      _log(e, st);
    }
  }

  // ── User-initiated device connection ──────────────────────────────────────

  Future<void> _onConnectDevice(
      BluetoothDeviceConnectRequested event,
      Emitter<BluetoothState> emit,
      ) async {
    emit(state.copyWith(
      selectedDevice: event.device,
      status:         BluetoothStatus.connectingToDevice,
    ));
    try {
      await BluetoothPrintPlus.connect(event.device);
    } catch (e, st) {
      emit(state.copyWith(
        status:       BluetoothStatus.failure,
        errorMessage: e.toString(),
      ));
      _log(e, st);
    }
  }

  // ── Stream event handlers ─────────────────────────────────────────────────

  void _onScanResults(
      _BluetoothScanResultsUpdated event,
      Emitter<BluetoothState> emit,
      ) {
    emit(state.copyWith(scanResults: event.results));
  }

  void _onScanningChanged(
      _BluetoothScanningChanged event,
      Emitter<BluetoothState> emit,
      ) {
    emit(state.copyWith(isScanning: event.isScanning));
  }

  void _onBlueStateChanged(
      _BluetoothStateChanged event,
      Emitter<BluetoothState> emit,
      ) {
    emit(state.copyWith(
      isBlueOn: event.blueState == BlueState.blueOn,
    ));
  }

  Future<void> _onConnectStateChanged(
      _BluetoothConnectStateChanged event,
      Emitter<BluetoothState> emit,
      ) async {
    switch (event.connectState) {
      case ConnectState.connected:
        if (state.selectedDevice == null) return;
        await _saveDeviceAndClose(emit);
        break;
      case ConnectState.disconnected:
        currentconnectionstate = false;
        emit(state.copyWith(status: BluetoothStatus.disconnected));
        break;
    }
  }

  // ── Save device to prefs ──────────────────────────────────────────────────

  Future<void> _saveDeviceAndClose(Emitter<BluetoothState> emit) async {
    try {
      final device = state.selectedDevice!;
      currentconnectionstate = true;

      // Update global device list
      bluetoothdeviceList.clear();
      final BluetoothModel ls = BluetoothModel.Empty();
      ls.name    = device.name;
      ls.address = device.address;
      ls.type    = device.type;
      bluetoothdeviceList.add(ls);

      // Persist to SharedPreferences
      await AppGlobals.storagenew.setString(
        'BlueTooth',
        jsonEncode(bluetoothdeviceList[0].toJson()),
      );

      // FIX 4: Removed msgshow from here to avoid null context crash.
      // Success message is now handled in the UI listener.

      emit(state.copyWith(
        status:         BluetoothStatus.saved,
        isAutoConnecting: false,
      ));
    } catch (e, st) {
      emit(state.copyWith(
        status:       BluetoothStatus.failure,
        errorMessage: e.toString(),
      ));
      _log(e, st);
    }
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  Future<void> close() {
    _scanResultsSub?.cancel();
    _isScanSub?.cancel();
    _blueStateSub?.cancel();
    _connectStateSub?.cancel();
    _receivedDataSub?.cancel();
    return super.close();
  }

  void _log(Object e, StackTrace st) {
    assert(() {
      debugPrint('BluetoothBloc error: $e\n$st');
      return true;
    }());
  }
}