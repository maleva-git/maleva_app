import 'dart:convert';
import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';
import '../../models/shared/bluetooth_model.dart';
import '../../utils/app_globals.dart';

class RememberedPrinterStore {
  const RememberedPrinterStore();
  List<BluetoothModel> get devices => bluetoothdeviceList;
  set connected(bool value) => currentconnectionstate = value;

  Future<void> save(BluetoothDevice device) async {
    connected = true;
    bluetoothdeviceList.clear();
    final BluetoothModel record = BluetoothModel.Empty();
    record.name = device.name;
    record.address = device.address;
    record.type = device.type;
    bluetoothdeviceList.add(record);
    await AppGlobals.storagenew.setString('BlueTooth', jsonEncode(bluetoothdeviceList[0].toJson()));
  }
}
