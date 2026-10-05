import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/rti/bloc/rti_entry_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'rti_mocks.dart';

// Decision Q-REV = B: GET /revise → the form shows was → now → edit → PUT → "RTI revised successfully".
Map<String, dynamic> master({Object? stops = const []}) => {
      'id': 44, 'cnumberDisplay': 'RTI000000044', 'saleDate': '2026-10-02T00:00:00', 'driverRefId': 5, 'truckRefId': 72,
      'routeActivities': stops,
    };

void main() {
  setUpAll(() => registerFallbackValue(<String, dynamic>{}));

  Future<(RtiEntryBloc, MockRtiEntryApi)> loaded({Object? reviseStops = const []}) async {
    final m = mockRepository();
    when(() => m.lookup.saleOrder(any())).thenThrow(Exception('offline'));
    when(() => m.api.load(44)).thenAnswer((_) async => (
          master: master(stops: [{'id': 3, 'sequenceNo': 1, 'activityType': 'SEAL', 'fullRoute': 'PTP'}]),
          lines: [
            {'id': 9, 'saleOrderMasterRefId': 20498, 'salary': 120, 'jobNo': 'TR1', 'customerName': 'ACME', 'destinationD': 'KL', 'deliveryDateD': '2026-10-03T00:00:00'},
          ],
        ));
    when(() => m.api.revise(44)).thenAnswer((_) async {
      final mm = master(stops: reviseStops);
      return (
        master: mm,
        lines: [
          {'id': 9, 'saleOrderMasterRefId': 20498, 'salary': 120, 'jobNo': 'TR1', 'customerName': 'ACME', 'destinationD': 'SHAH ALAM', 'deliveryDateD': '2026-10-04T00:00:00'},
        ],
      );
    });
    final b = RtiEntryBloc(repository: m.repo)..add(const RtiEntryStarted(rtiId: 44));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    return (b, m.api);
  }

  test('revise loads the sales-order values and lists each change as was → now', () async {
    final (b, _) = await loaded();
    b.add(const RtiReviseRequested());
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(b.state.inRevise, isTrue);
    expect(b.state.grid.single.destinationD, 'SHAH ALAM');
    expect(b.state.reviseChanges[20498], const [
      RtiReviseChange('Destination', 'KL', 'SHAH ALAM'),
      RtiReviseChange('Delivery', '03/10/2026', '04/10/2026'),
    ]);
    expect(b.state.notice!.text, startsWith('Revised from the sales orders: 2 changes in 1 job.'));
    await b.close();
  });

  test('null route activities keep the stops already loaded', () async {
    final (b, _) = await loaded(reviseStops: null);
    b.add(const RtiReviseRequested());
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(b.state.stops.single.id, 3);
    await b.close();
  });

  test('an empty list from the server replaces them (the update replaces every stop)', () async {
    final (b, _) = await loaded(reviseStops: const []);
    b.add(const RtiReviseRequested());
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(b.state.stops, isEmpty);
    await b.close();
  });

  test('save after revise is a PUT of the edited values and says "RTI revised successfully"', () async {
    final (b, api) = await loaded(reviseStops: null);
    Map<String, dynamic>? body;
    List<Map<String, dynamic>>? lines;
    List<Map<String, dynamic>>? stops;
    when(() => api.save(any(), any(), routeActivities: any(named: 'routeActivities'))).thenAnswer((i) async {
      body = i.positionalArguments.first as Map<String, dynamic>;
      lines = (i.positionalArguments[1] as List).cast<Map<String, dynamic>>();
      stops = i.namedArguments[#routeActivities] as List<Map<String, dynamic>>?;
      return {'id': 44};
    });
    b.add(const RtiReviseRequested());
    await Future<void>.delayed(const Duration(milliseconds: 20));
    b.add(const RtiJobCellEdited(0, 'Salary', '150'));
    b.add(const RtiSaveRequested());
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(body!['id'], 44);
    expect(body!['cNumberDisplay'], 'RTI000000044');
    expect(lines!.single['salary'], 150);
    expect(lines!.single['destinationD'], 'SHAH ALAM');
    expect(lines!.single['rtiMasterRefId'], 44);
    expect(stops!.single['id'], 3);
    expect(b.state.notice!.text, 'RTI revised successfully');
    expect(b.state.inRevise, isFalse);
    await b.close();
  });

  test('a revise without a saved RTI is refused', () async {
    final b = RtiEntryBloc(repository: mockRepository().repo);
    b.add(const RtiReviseRequested());
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(b.state.notice!.text, 'No RTI selected to revise.');
    await b.close();
  });

  test('an empty revise answer → "Failed to load revise data."', () async {
    final (b, api) = await loaded();
    when(() => api.revise(44)).thenAnswer((_) async => (master: <String, dynamic>{}, lines: <Map<String, dynamic>>[]));
    b.add(const RtiReviseRequested());
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(b.state.notice!.text, 'Failed to load revise data.');
    expect(b.state.inRevise, isFalse);
    await b.close();
  });
}
