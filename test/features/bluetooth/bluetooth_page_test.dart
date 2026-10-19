import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/bluetooth/bloc/bluetooth_bloc.dart';
import 'package:maleva/core/bluetooth/view/Bluetooth_tab.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'bluetooth_contract_test.dart' show FakeBluetoothGateway;
import '../../support/local_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(installLocalTestFonts);
  testWidgets('auto-connect without printer returns once and closes subscriptions', (tester) async {
    bluetoothdeviceList.clear();
    final gateway = FakeBluetoothGateway();
    final bloc = BluetoothBloc(gateway: gateway);
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) => Scaffold(
      body: TextButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => BluetoothPage(printData: const [], createBloc: () => bloc))),
        child: const Text('Open printer'))))));
    await tester.tap(find.text('Open printer'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Open printer'), findsOneWidget);
    expect(find.byType(BluetoothPage), findsNothing);
    // The page calls bloc.close() when it is popped, but close() completes on
    // the real event loop, which the widget test's fake clock never advances
    // (newer Flutter SDKs). Give it a little real time before checking.
    await tester.runAsync(() async {
      for (var i = 0; i < 100 && !bloc.isClosed; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    });
    expect(bloc.isClosed, isTrue);
    expect(gateway.scans.hasListener, isFalse);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    await gateway.dispose();
  });
}
