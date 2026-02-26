import 'dart:convert';
import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:bluetooth_print_plus/src/enum_tool.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:maleva/core/models/model.dart';
import 'package:bluetooth_print_plus/src/blue_device.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

class Bluetoothpage extends StatefulWidget {
  final List<BarcodePrintModel>? PrintData;
   Bluetoothpage({super.key,this.PrintData});

  @override
  BluetoothpageState createState() => BluetoothpageState();
}

class BluetoothpageState extends State<Bluetoothpage> {
  BluetoothDevice? _device;
  late StreamSubscription<bool> _isScanningSubscription;
  late StreamSubscription<BlueState> _blueStateSubscription;
  late StreamSubscription<ConnectState> _connectStateSubscription;
  late StreamSubscription<Uint8List> _receivedDataSubscription;
  late StreamSubscription<List<BluetoothDevice>> _scanResultsSubscription;
  List<BluetoothDevice> _scanResults = [];


  @override
  void initState() {
    super.initState();
    initBluetoothPrintPlusListen();
  }

  @override
  void dispose() {
    super.dispose();
    _isScanningSubscription.cancel();
    _blueStateSubscription.cancel();
    _connectStateSubscription.cancel();
    _receivedDataSubscription.cancel();
    _scanResultsSubscription.cancel();
    _scanResults.clear();
  }

  Future<void> initBluetoothPrintPlusListen() async {
    /// listen scanResults
    _scanResultsSubscription = BluetoothPrintPlus.scanResults.listen((event) {
      if (mounted) {
        setState(() {
          _scanResults = event;
        });
      }
    });

    /// listen isScanning
    _isScanningSubscription = BluetoothPrintPlus.isScanning.listen((event) {
      print('********** isScanning: $event **********');
      if (mounted) {
        setState(() {});
      }
    });

    /// listen blue state
    _blueStateSubscription = BluetoothPrintPlus.blueState.listen((event) {
      print('********** blueState change: $event **********');
      if (mounted) {
        setState(() {});
      }
    });

    /// listen connect state
    _connectStateSubscription = BluetoothPrintPlus.connectState.listen((event) async {
      print('********** connectState change: $event **********');
      switch (event) {
        case ConnectState.connected:
          setState(() {
            if (_device == null) return;
            saveclose();
          });
          break;
        case ConnectState.disconnected:
          objfun.currentconnectionstate = false;
          setState(() {
            // _device = null;
          });
          break;
      }
    });

    /// listen received data
    _receivedDataSubscription = BluetoothPrintPlus.receivedData.listen((data) {
      print('********** received data: $data **********');

      /// do something...
    });
    if (widget.PrintData != null) {
      _device = BluetoothDevice(
          objfun.bluetoothdeviceList[0].name,
          objfun.bluetoothdeviceList[0].address);
      await BluetoothPrintPlus.connect(_device!);
    }
  }
  Future  saveclose() async{
    objfun.msgshow('Connected Successfully ', "", Colors.white, Colors.red, null,
        18.00 - objfun.reducesize, objfun.tll, objfun.tgc, null, 2);
    objfun.bluetoothdeviceList.clear();
    BluetoothModel ls =BluetoothModel.Empty();
    ls.name=_device!.name;
    ls.address=_device!.address;
    ls.type=_device!.type;
    objfun.bluetoothdeviceList.add(ls);
    objfun.storagenew.setString('BlueTooth',jsonEncode(objfun.bluetoothdeviceList[0].toJson()));
    Navigator.of(context).pop();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('BluetoothPrintPlus'),
        ),
        body: ((widget.PrintData != null) ? Center(
          child: SpinKitFoldingCube(
            color: colour.commonColorred,
            size: 35.0 - objfun.reducesize,
          ),
        ) : SafeArea(
            child: BluetoothPrintPlus.isBlueOn
                ? ListView(
              children: _scanResults
                  .map((device) =>
                  Container(
                    padding: EdgeInsets.only(
                        left: 10, right: 10, bottom: 5),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(device.name),
                                Text(
                                  device.address,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                                Divider(),
                              ],
                            )),
                        SizedBox(
                          width: 10,
                        ),
                        OutlinedButton(
                          onPressed: () async {
                            _device = device;
                            await BluetoothPrintPlus.connect(device);
                          },
                          child: const Text("connect"),
                        )
                      ],
                    ),
                  ))
                  .toList(),
            )
                : buildBlueOffWidget())),
        floatingActionButton: ((widget.PrintData != null)
            ? null
            :
        BluetoothPrintPlus.isBlueOn ? buildScanButton(context) : null));
  }

  Widget buildBlueOffWidget() {
    return Center(
        child: Text(
          "Bluetooth is turned off\nPlease turn on Bluetooth...",
          style: TextStyle(
              fontWeight: FontWeight.w700, fontSize: 16, color: Colors.red),
          textAlign: TextAlign.center,
        ));
  }

  Widget buildScanButton(BuildContext context) {
    if (BluetoothPrintPlus.isScanningNow) {
      return FloatingActionButton(
        onPressed: onStopPressed,
        backgroundColor: Colors.red,
        child: Icon(Icons.stop),
      );
    } else {
      return FloatingActionButton(
          onPressed: onScanPressed,
          backgroundColor: Colors.green,
          child: Text("SCAN"));
    }
  }

  Future onScanPressed() async {
    try {
      await BluetoothPrintPlus.startScan(timeout: Duration(seconds: 10));
    } catch (e) {
      print("onScanPressed error: $e");
    }
  }

  Future onStopPressed() async {
    try {
      BluetoothPrintPlus.stopScan();
    } catch (e) {
      print("onStopPressed error: $e");
    }
  }
}