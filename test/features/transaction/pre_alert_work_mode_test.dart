import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/employee/employee_api.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/features/transaction/prealertview/bloc/pre_alert_ports.dart';
import 'package:maleva/features/transaction/prealertview/bloc/prealertview_bloc.dart';

/// The Pre Alert tab of the boarding / forwarding agent dashboards (boarding-pre-alert-tab).
void main() {
  group('port choice', () {
    test('own ports only, first selected, duplicates and blanks dropped', () {
      final c = PreAlertPortChoice.of(assigned: ['WESTPORT-B18', ' ', 'NORTHPORT- B10', 'WESTPORT-B18'], companyPorts: ['PTP-J33']);
      expect(c.ports, ['WESTPORT-B18', 'NORTHPORT- B10']);
      expect(c.restricted, isTrue);
      expect(c.selected, 'WESTPORT-B18');
    });

    test('no port assigned: every company port, All Ports selected (as the web)', () {
      final c = PreAlertPortChoice.of(assigned: const [], companyPorts: const ['PTP-J33', 'WESTPORT-B18']);
      expect(c.ports, ['PTP-J33', 'WESTPORT-B18']);
      expect(c.restricted, isFalse);
      expect(c.selected, '');
    });
  });

  group('port sent with the report', () {
    test('the tab always sends its port; All Ports sends none', () {
      expect(preAlertPortParam(workMode: true, checkPort: false, portName: 'PTP-J33'), 'PTP-J33');
      expect(preAlertPortParam(workMode: true, checkPort: false, portName: ''), isNull);
    });

    test('the drawer screen sends it only with "Port" ticked, as the web', () {
      expect(preAlertPortParam(workMode: false, checkPort: false, portName: 'PTP-J33'), isNull);
      expect(preAlertPortParam(workMode: false, checkPort: true, portName: ' PTP-J33 '), 'PTP-J33');
      expect(preAlertPortParam(workMode: false, checkPort: true, portName: ''), isNull);
    });
  });

  test('the tab starts on ETA All, Delivery Done and the first own port', () {
    final s = PreAlertBloc.preAlertWorkStart(
      today: '2026-10-20',
      choice: PreAlertPortChoice.of(assigned: const ['NORTHPORT- B10', 'PTP-J33']),
    );
    expect(s.workMode, isTrue);
    expect(s.etaEnabled, isTrue);
    expect(s.etaVal, '3'); // either vessel's ETA
    expect(s.checkDelivery, isTrue);
    expect(s.checkLEmp, isFalse); // owner: L.Emp always unticked in the tab
    expect(s.portName, 'NORTHPORT- B10');
    expect(s.fromDate, '2026-10-20');
    expect(s.toDate, '2026-10-20');
    // a later change keeps the mode and the port list
    final next = s.copyWith(portName: 'PTP-J33');
    expect(next.workMode, isTrue);
    expect(next.portChoice.ports, ['NORTHPORT- B10', 'PTP-J33']);
  });

  // `/api/port-masters/company/{id}/active` answers `{success, message, data}`
  // (seen on device 2026-10-20: its success message was shown as an error).
  group('port-master answer', () {
    test('{success, message, data}', () {
      final body = {'success': true, 'statusCode': 200, 'message': 'Active ports retrieved successfully', 'data': [{'portName': 'PTP-J33'}]};
      expect(EmployeeApi.portRows(body), [{'portName': 'PTP-J33'}]);
    });

    test('{IsSuccess, Data1} and a bare list', () {
      expect(EmployeeApi.portRows({'IsSuccess': true, 'Data1': [1]}), [1]);
      expect(EmployeeApi.portRows([2]), [2]);
    });

    test('success false is a failure with the message', () {
      expect(() => EmployeeApi.portRows({'success': false, 'message': 'No access'}),
          throwsA(isA<ApiFailure>().having((f) => f.message, 'message', 'No access')));
    });
  });
}
