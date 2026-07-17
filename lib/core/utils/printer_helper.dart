import 'dart:typed_data';
import 'package:bluetooth_print_plus/bluetooth_print_plus.dart' as bpp;
import 'package:maleva/core/models/shared/barcode_print_model.dart';
import 'package:maleva/core/models/shared/bluetooth_model.dart';

List<BluetoothModel> bluetoothdeviceList = [];

// Printer Work ---------------
bool currentconnectionstate = false;
bool esccommand = false;

Future printerinit() async {
  try {
    await bpp.BluetoothPrintPlus.connect(bpp.BluetoothDevice(
        bluetoothdeviceList[0].name, bluetoothdeviceList[0].address));
  } catch (e) {
    // Silent catch
  }
}

Future printfunction(List<BarcodePrintModel> obj) async {
  if (currentconnectionstate) {
    printdata(obj);
  } else {
    printerinit();
  }
}

Future printdata(List<BarcodePrintModel> obj) async {
  List<Uint8List?> obj1 = [];
  if (esccommand) {
    obj1 = await escTemplateCmd(obj);
  } else {
    obj1 = await tscTemplateCmd(obj);
  }
  for (var i = 0; i < obj1.length; i++) {
    bpp.BluetoothPrintPlus.write(obj1[i]);
  }
}

final escCommand = bpp.EscCommand();
Future<List<Uint8List?>> escTemplateCmd(List<BarcodePrintModel> obj) async {
  List<Uint8List?> returndata = [];
  for (var i = 0; i < obj.length; i++) {
    await escCommand.cleanCommand();
    await escCommand.print(feedLines: 1);
    await escCommand.newline();
    await escCommand.text(
        content: obj[i].CompanyName_Data,
        alignment: bpp.Alignment.center,
        style: bpp.EscTextStyle.underline,
        fontSize: bpp.EscFontSize.size7);
    await escCommand.newline();
    await escCommand.text(
        content: obj[i].ShipName_Data,
        alignment: bpp.Alignment.center,
        style: bpp.EscTextStyle.underline,
        fontSize: bpp.EscFontSize.size7);
    await escCommand.newline();
    await escCommand.code128(
        content: obj[i].Barcode_Data,
        alignment: bpp.Alignment.center,
        height: 120,
        width: 4,
        hriPosition: bpp.HriPosition.below);
    await escCommand.newline();
    await escCommand.text(
        content: "Date : ${obj[i].Date_Data}",
        alignment: bpp.Alignment.center,
        style: bpp.EscTextStyle.underline,
        fontSize: bpp.EscFontSize.size7);
    await escCommand.newline();
    await escCommand.text(
        content: "Job No : ${obj[i].JobNo_Data}",
        alignment: bpp.Alignment.center,
        style: bpp.EscTextStyle.underline,
        fontSize: bpp.EscFontSize.size7);
    await escCommand.newline();
    await escCommand.text(
        content: "Pkg : ${obj[i].Pkg_Data}",
        alignment: bpp.Alignment.center,
        style: bpp.EscTextStyle.underline,
        fontSize: bpp.EscFontSize.size7);
    await escCommand.print(feedLines: 1);
    final cmd = await escCommand.getCommand();
    returndata.add(cmd);
  }
  return returndata;
}

final tscCommand = bpp.TscCommand();
Future<List<Uint8List?>> tscTemplateCmd(List<BarcodePrintModel> obj) async {
  List<Uint8List?> returndata = [];
  for (var i = 0; i < obj.length; i++) {
    await tscCommand.cleanCommand();
    await tscCommand.size(width: 60, height: 62);
    await tscCommand.cls(); // must be after size
    await tscCommand.speed(8);
    await tscCommand.density(8);
    await tscCommand.text(
      content: obj[i].CompanyName_Data,
      x: 50,
      y: 10,
      xMulti: 2,
      yMulti: 2,
    );
    await tscCommand.text(
      content: obj[i].ShipName_Data,
      x: 50,
      y: 65,
      xMulti: 2,
      yMulti: 2,
    );
    await tscCommand.qrCode(
        content: obj[i].Barcode_Data,
        x: 50,
        y: 120,
        cellWidth: 6);
    await tscCommand.text(
      content: obj[i].JobNo_Data,
      x: 50,
      y: 270,
      xMulti: 2,
      yMulti: 2,
    );
    await tscCommand.text(
      content: obj[i].Pkg_Data,
      x: 50,
      y: 320,
      xMulti: 2,
      yMulti: 2,
    );
    await tscCommand.text(
      content: obj[i].Date_Data,
      x: 50,
      y: 370,
      xMulti: 2,
      yMulti: 2,
    );
    await tscCommand.print(1);
    final cmd = await tscCommand.getCommand();
    returndata.add(cmd);
  }
  return returndata;
}
