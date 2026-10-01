import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/bluetooth/bloc/bluetooth_bloc.dart';
import 'package:maleva/core/bluetooth/data/bluetooth_gateway.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeBluetoothGateway extends BluetoothGateway {
  final scans = StreamController<List<BluetoothDevice>>.broadcast();
  final scanning = StreamController<bool>.broadcast();
  final blue = StreamController<BlueState>.broadcast();
  final connection = StreamController<ConnectState>.broadcast();
  final received = StreamController<Uint8List>.broadcast();
  Duration? timeout;
  bool failConnect = false;
  final connections = <BluetoothDevice>[];
  int stops = 0;
  @override bool get isBlueOn => true;
  @override Stream<List<BluetoothDevice>> get scanResults => scans.stream;
  @override Stream<bool> get isScanning => scanning.stream;
  @override Stream<BlueState> get blueState => blue.stream;
  @override Stream<ConnectState> get connectState => connection.stream;
  @override Stream<Uint8List> get receivedData => received.stream;
  @override Future<void> connect(BluetoothDevice device) async {
    connections.add(device);
    if (failConnect) throw StateError('fixture connection failure');
  }
  @override Future<void> startScan({required Duration timeout}) async { this.timeout = timeout; }
  @override Future<void> stopScan() async { stops++; }
  Future<void> dispose() async {
    await scans.close(); await scanning.close(); await blue.close();
    await connection.close(); await received.close();
  }
}
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeBluetoothGateway gateway;
  late BluetoothBloc bloc;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    AppGlobals.storagenew = await SharedPreferences.getInstance();
    bluetoothdeviceList.clear();
    currentconnectionstate = false;
    gateway = FakeBluetoothGateway();
    bloc = BluetoothBloc(gateway: gateway);
  });
  tearDown(() async { if (!bloc.isClosed) await bloc.close(); await gateway.dispose(); });
  Future<void> initialize() async {
    final ready = bloc.stream.firstWhere((s) => s.isBlueOn);
    bloc.add(const BluetoothInitialized()); await ready;
  }
  test('scan timeout, results and subscription ownership', () async {
    await initialize();
    expect(gateway.scans.hasListener, isTrue);
    bloc.add(const BluetoothScanStarted());
    await Future<void>.delayed(Duration.zero);
    expect(gateway.timeout, const Duration(seconds: 10));
    final result = bloc.stream.firstWhere((s) => s.scanResults.isNotEmpty);
    gateway.scans.add([BluetoothDevice('', 'fixture-address')]); await result;
    expect(bloc.state.scanResults.single.name, '');
    bloc.add(const BluetoothScanStopped());
    await Future<void>.delayed(Duration.zero);
    expect(gateway.stops, 1);
    await bloc.close();
    expect([gateway.scans.hasListener, gateway.scanning.hasListener, gateway.blue.hasListener,
      gateway.connection.hasListener, gateway.received.hasListener], everyElement(false));
  });
  test('missing remembered printer reports failure without connecting', () async {
    final failed = bloc.stream.firstWhere((s) => s.status == BluetoothStatus.failure);
    bloc.add(const BluetoothInitialized(autoConnect: true)); await failed;
    expect(bloc.state.errorMessage, 'No saved Bluetooth device found. Please scan and connect.');
    expect(gateway.connections, isEmpty);
  });
  test('connection stores exact preference record before saved state', () async {
    await initialize();
    final device = BluetoothDevice('fixture printer', 'fixture-address');
    final connecting = bloc.stream.firstWhere((s) => s.status == BluetoothStatus.connectingToDevice);
    bloc.add(BluetoothDeviceConnectRequested(device)); await connecting;
    final saved = bloc.stream.firstWhere((s) => s.status == BluetoothStatus.saved);
    gateway.connection.add(ConnectState.connected); await saved;
    final data = jsonDecode(AppGlobals.storagenew.getString('BlueTooth')!) as Map;
    expect(data['name'], device.name); expect(data['address'], device.address);
    expect(data['type'], device.type); expect(bluetoothdeviceList.length, 1);
    expect(currentconnectionstate, isTrue);
    await bloc.close();
    bloc = BluetoothBloc(gateway: gateway);
    final auto = bloc.stream.firstWhere((s) => s.status == BluetoothStatus.connectingToDevice);
    bloc.add(const BluetoothInitialized(autoConnect: true)); await auto;
    expect(gateway.connections.last.address, device.address);
  });
  test('connection exception retains failure state and message', () async {
    await initialize(); gateway.failConnect = true;
    final failed = bloc.stream.firstWhere((s) => s.status == BluetoothStatus.failure);
    bloc.add(BluetoothDeviceConnectRequested(BluetoothDevice('fixture', 'address')));
    await failed;
    expect(bloc.state.errorMessage, contains('fixture connection failure'));
    expect(AppGlobals.storagenew.containsKey('BlueTooth'), isFalse);
  });
}
