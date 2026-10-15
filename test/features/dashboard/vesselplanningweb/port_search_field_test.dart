import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/dashboard/common_tabs/vesselplanningweb/view/port_search_field.dart';

void main() {
  const ports = ['WESTPORT-B18', 'NORTHPORT- B10', 'SOUTHPORT-B11', 'KUANTAN PORT -C13', 'PTP-J33'];

  group('PortSearchText', () {
    test('matches any part of the name in any case', () {
      expect(PortSearchText.matches('north', ports), ['NORTHPORT- B10']);
      expect(PortSearchText.matches('b1', ports), ['WESTPORT-B18', 'NORTHPORT- B10', 'SOUTHPORT-B11']);
      expect(PortSearchText.matches('', ports), ports);
      expect(PortSearchText.matches('zzz', ports), isEmpty);
    });

    test('searches only the part after the last comma and hides ports already chosen', () {
      expect(PortSearchText.matches('WESTPORT-B18,port', ports), ['NORTHPORT- B10', 'SOUTHPORT-B11', 'KUANTAN PORT -C13']);
    });

    test('right after a pick it offers the remaining ports', () {
      expect(PortSearchText.matches('WESTPORT-B18', ports), ['NORTHPORT- B10', 'SOUTHPORT-B11', 'KUANTAN PORT -C13', 'PTP-J33']);
    });

    test('a pick replaces what is typed, or is added after the chosen ports', () {
      expect(PortSearchText.pick('nor', 'NORTHPORT- B10', ports), 'NORTHPORT- B10');
      expect(PortSearchText.pick('WESTPORT-B18,ptp', 'PTP-J33', ports), 'WESTPORT-B18,PTP-J33');
      expect(PortSearchText.pick('WESTPORT-B18', 'PTP-J33', ports), 'WESTPORT-B18,PTP-J33');
      expect(PortSearchText.pick('', 'PTP-J33', ports), 'PTP-J33');
    });
  });

  testWidgets('typing shows the matching ports and a tap adds one', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: PortSearchField(controller: controller, ports: ports))),
    ));
    await tester.enterText(find.byType(TextField), 'kuan');
    await tester.pumpAndSettle();
    expect(find.text('KUANTAN PORT -C13'), findsOneWidget);
    expect(find.text('WESTPORT-B18'), findsNothing);
    await tester.tap(find.text('KUANTAN PORT -C13'));
    await tester.pumpAndSettle();
    expect(controller.text, 'KUANTAN PORT -C13');

    await tester.enterText(find.byType(TextField), '${controller.text},west');
    await tester.pumpAndSettle();
    await tester.tap(find.text('WESTPORT-B18'));
    await tester.pumpAndSettle();
    expect(controller.text, 'KUANTAN PORT -C13,WESTPORT-B18');
  });
}
