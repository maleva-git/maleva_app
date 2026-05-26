part of 'bluetooth_bloc.dart';

enum BluetoothStatus {
  initial,
  scanning,
  connectingToDevice,
  connected,
  saved,        // device saved to prefs → UI listener pops navigation
  disconnected,
  failure,
}

class BluetoothState extends Equatable {
  const BluetoothState({
    this.status         = BluetoothStatus.initial,
    this.scanResults    = const [],
    this.isScanning     = false,
    this.isBlueOn       = false,
    this.isAutoConnecting = false,
    this.selectedDevice,
    this.errorMessage   = '',
  });

  final BluetoothStatus status;
  final List<BluetoothDevice> scanResults;
  final bool isScanning;

  /// Reflects BluetoothPrintPlus.blueState — true when BT radio is on
  final bool isBlueOn;

  /// True when PrintData was supplied and we are auto-connecting on open
  final bool isAutoConnecting;

  final BluetoothDevice? selectedDevice;
  final String errorMessage;

  // ── Derived ───────────────────────────────────────────────
  bool get isConnected    => status == BluetoothStatus.connected;
  bool get isSaved        => status == BluetoothStatus.saved;
  bool get isConnecting   => status == BluetoothStatus.connectingToDevice;

  BluetoothState copyWith({
    BluetoothStatus? status,
    List<BluetoothDevice>? scanResults,
    bool? isScanning,
    bool? isBlueOn,
    bool? isAutoConnecting,
    BluetoothDevice? selectedDevice,
    String? errorMessage,
    bool clearDevice = false,
  }) {
    return BluetoothState(
      status:           status           ?? this.status,
      scanResults:      scanResults      ?? this.scanResults,
      isScanning:       isScanning       ?? this.isScanning,
      isBlueOn:         isBlueOn         ?? this.isBlueOn,
      isAutoConnecting: isAutoConnecting ?? this.isAutoConnecting,
      selectedDevice:   clearDevice ? null : (selectedDevice ?? this.selectedDevice),
      errorMessage:     errorMessage     ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status, scanResults, isScanning, isBlueOn,
    isAutoConnecting, selectedDevice, errorMessage,
  ];
}