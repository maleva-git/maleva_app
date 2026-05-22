part of 'bluetooth_bloc.dart';

abstract class BluetoothEvent extends Equatable {
  const BluetoothEvent();
  @override
  List<Object?> get props => [];
}

/// Boot — sets up all stream listeners.
/// [autoConnect] = true when PrintData was passed (auto-connects to saved device).
class BluetoothInitialized extends BluetoothEvent {
  final bool autoConnect;
  const BluetoothInitialized({this.autoConnect = false});
  @override
  List<Object?> get props => [autoConnect];
}

/// User tapped SCAN button
class BluetoothScanStarted extends BluetoothEvent {
  const BluetoothScanStarted();
}

/// User tapped STOP button
class BluetoothScanStopped extends BluetoothEvent {
  const BluetoothScanStopped();
}

/// User tapped "connect" on a device row
class BluetoothDeviceConnectRequested extends BluetoothEvent {
  final BluetoothDevice device;
  const BluetoothDeviceConnectRequested(this.device);
  @override
  List<Object?> get props => [device];
}

// ── Internal events — dispatched from stream listeners inside the BLoC ────────

class _BluetoothScanResultsUpdated extends BluetoothEvent {
  final List<BluetoothDevice> results;
  const _BluetoothScanResultsUpdated(this.results);
  @override
  List<Object?> get props => [results];
}

class _BluetoothScanningChanged extends BluetoothEvent {
  final bool isScanning;
  const _BluetoothScanningChanged(this.isScanning);
  @override
  List<Object?> get props => [isScanning];
}

class _BluetoothStateChanged extends BluetoothEvent {
  final BlueState blueState;
  const _BluetoothStateChanged(this.blueState);
  @override
  List<Object?> get props => [blueState.index];
}

class _BluetoothConnectStateChanged extends BluetoothEvent {
  final ConnectState connectState;
  final BluetoothDevice? device;
  const _BluetoothConnectStateChanged(this.connectState, {this.device});
  @override
  List<Object?> get props => [connectState.index];
}