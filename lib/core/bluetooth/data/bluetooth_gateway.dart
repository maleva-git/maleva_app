import 'dart:typed_data';
import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';

/// Plugin boundary; stream ownership remains with the page's BLoC.
class BluetoothGateway {
  const BluetoothGateway();
  bool get isBlueOn => BluetoothPrintPlus.isBlueOn;
  Stream<List<BluetoothDevice>> get scanResults => BluetoothPrintPlus.scanResults;
  Stream<bool> get isScanning => BluetoothPrintPlus.isScanning;
  Stream<BlueState> get blueState => BluetoothPrintPlus.blueState;
  Stream<ConnectState> get connectState => BluetoothPrintPlus.connectState;
  Stream<Uint8List> get receivedData => BluetoothPrintPlus.receivedData;
  Future<dynamic> connect(BluetoothDevice device) => BluetoothPrintPlus.connect(device);
  Future<dynamic> startScan({required Duration timeout}) => BluetoothPrintPlus.startScan(timeout: timeout);
  Future<dynamic> stopScan() => BluetoothPrintPlus.stopScan();
}
