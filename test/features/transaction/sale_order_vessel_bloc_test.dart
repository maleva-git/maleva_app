import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/models/shared/sale_edit_detail_model.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/sale_order/sale_order_api.dart';
import 'package:maleva/core/vessel_master/vessel_master_api.dart';
import 'package:maleva/core/vessel_master/vessel_master_models.dart';
import 'package:maleva/features/transaction/salesorder/add/bloc/sale_order_save_body.dart';
import 'package:maleva/features/transaction/salesorder/add/bloc/salesorderadd_bloc.dart';
import 'package:maleva/features/transaction/salesorder/add/bloc/salesorderadd_event.dart';
import 'package:maleva/features/transaction/salesorder/add/bloc/salesorderadd_state.dart';
import 'package:maleva/features/transaction/salesorder/add/bloc/vessel_pick.dart';
import 'package:maleva/features/transaction/salesorder/add/data/salesorderadd_repository.dart';
import 'package:mocktail/mocktail.dart';

import 'sale_order_save_body_test.dart' show form;

class _Context extends Mock implements BuildContext {}

class _SaleOrders extends Mock implements SaleOrderApi {}

class _VesselMasters extends Mock implements VesselMasterApi {}

/// MAERSK RIO NEGRO 641S as the suggest answer gives it (api-contract.md).
const _call = PtpCall(
  id: 412,
  port: 'PTP',
  vesselName: 'MAERSK RIO NEGRO',
  voyage: '641S',
  scn: '269EK6',
  arriveAt: '2026-10-10T06:30',
  arriveEstimated: true,
  departAt: '2026-10-11T17:00',
  departEstimated: true,
);
const _vessel = VesselSuggestion(vesselMasterId: 88, vesselName: 'MAERSK RIO NEGRO', calls: [_call]);

/// The sales form's vessel suggestions, PTP fill, close spelling and links (vessel-master-and-ptp-schedule).
void main() {
  late _SaleOrders saleOrders;
  late _VesselMasters vessels;

  setUpAll(() => registerFallbackValue(<VesselLinkRequest>[]));

  setUp(() {
    saleOrders = _SaleOrders();
    vessels = _VesselMasters();
  });

  SalesOrderAddBloc build() =>
      SalesOrderAddBloc(_Context(), SalesOrderAddRepository(), saleOrders: saleOrders, vesselMasters: vessels);

  SalesOrderAddLoaded last(SalesOrderAddBloc bloc) => bloc.state as SalesOrderAddLoaded;

  group('picking a PTP call (task 2.3)', () {
    blocTest<SalesOrderAddBloc, SalesOrderAddState>(
      'an empty off leg gets O ETA, O ETD (boxes ticked) and O SCN; ETB and the loading leg stay',
      build: build,
      seed: () => form().copyWith(txtLoadingVessel: 'CMA CGM PETRON', txtLSCN: 'L1', checkBoxValueLETA: true),
      act: (b) => b.add(VesselPicked(VesselLeg.off, _vessel, call: _call)),
      verify: (b) {
        final s = last(b);
        expect(s.txtOffVessel, 'MAERSK RIO NEGRO');
        expect(s.dtpOETAdate, '2026-10-10 06:30:00');
        expect(s.checkBoxValueOETA, isTrue);
        expect(s.dtpOETDdate, '2026-10-11 17:00:00');
        expect(s.checkBoxValueOETD, isTrue);
        expect(s.txtOSCN, '269EK6');
        expect(s.checkBoxValueOETB, isFalse, reason: 'an unticked ETB stays unticked');
        expect(s.dtpOETBdate, '2026-10-02 09:30:00');
        expect(s.txtLoadingVessel, 'CMA CGM PETRON');
        expect(s.txtLSCN, 'L1');
        expect(s.dtpLETAdate, '2026-10-02 09:30:00');
        expect(s.pickedOff?.vesselMasterId, 88);
        expect(s.pickedOff?.ptpVesselCallId, 412);
        expect(s.vesselFillQuestion, isNull);
        expect(s.pickedLoading, isNull);
      },
    );

    blocTest<SalesOrderAddBloc, SalesOrderAddState>(
      'a loading pick fills L ETA, L ETD and L SCN only',
      build: build,
      seed: () => form(),
      act: (b) => b.add(VesselPicked(VesselLeg.loading, _vessel, call: _call)),
      verify: (b) {
        final s = last(b);
        expect(s.txtLoadingVessel, 'MAERSK RIO NEGRO');
        expect([s.dtpLETAdate, s.checkBoxValueLETA], ['2026-10-10 06:30:00', true]);
        expect([s.dtpLETDdate, s.checkBoxValueLETD], ['2026-10-11 17:00:00', true]);
        expect(s.checkBoxValueLETB, isFalse);
        expect(s.txtLSCN, '269EK6');
        expect([s.checkBoxValueOETA, s.txtOSCN, s.txtOffVessel], [false, '', '']);
      },
    );

    blocTest<SalesOrderAddBloc, SalesOrderAddState>(
      'a typed O ETA asks first, and "no" keeps 10 Oct 09:00 (filling only what was empty)',
      build: build,
      seed: () => form().copyWith(dtpOETAdate: '2026-10-10 09:00:00', checkBoxValueOETA: true),
      act: (b) async {
        b.add(VesselPicked(VesselLeg.off, _vessel, call: _call));
        await Future<void>.delayed(Duration.zero);
        final q = last(b).vesselFillQuestion;
        expect(q, isNotNull, reason: 'the form asks before replacing');
        expect(q!.differing.map((d) => d.field), ['ETA']);
        expect(last(b).dtpOETAdate, '2026-10-10 09:00:00', reason: 'nothing replaced while asking');
        b.add(VesselFillAnswered(false));
      },
      verify: (b) {
        final s = last(b);
        expect(s.vesselFillQuestion, isNull);
        expect(s.dtpOETAdate, '2026-10-10 09:00:00');
        expect(s.checkBoxValueOETA, isTrue);
        expect(s.dtpOETDdate, '2026-10-11 17:00:00', reason: 'the empty ETD is still filled');
        expect(s.txtOSCN, '269EK6');
        expect(s.txtOffVessel, 'MAERSK RIO NEGRO');
      },
    );

    blocTest<SalesOrderAddBloc, SalesOrderAddState>(
      '"yes" replaces the typed ETA and SCN with PTP\'s',
      build: build,
      seed: () => form().copyWith(dtpOETAdate: '2026-10-10 09:00:00', checkBoxValueOETA: true, txtOSCN: 'OLD'),
      act: (b) async {
        b.add(VesselPicked(VesselLeg.off, _vessel, call: _call));
        await Future<void>.delayed(Duration.zero);
        expect(last(b).vesselFillQuestion!.differing.map((d) => d.field), ['ETA', 'SCN']);
        b.add(VesselFillAnswered(true));
      },
      verify: (b) {
        expect(last(b).dtpOETAdate, '2026-10-10 06:30:00');
        expect(last(b).txtOSCN, '269EK6');
      },
    );

    blocTest<SalesOrderAddBloc, SalesOrderAddState>(
      'the same values already typed do not ask',
      build: build,
      seed: () => form().copyWith(dtpOETAdate: '2026-10-10 06:30:00', checkBoxValueOETA: true, txtOSCN: '269ek6'),
      act: (b) => b.add(VesselPicked(VesselLeg.off, _vessel, call: _call)),
      verify: (b) => expect(last(b).vesselFillQuestion, isNull),
    );

    blocTest<SalesOrderAddBloc, SalesOrderAddState>(
      'a vessel without a call sets the name only; typing afterwards drops the pick',
      build: build,
      seed: () => form(),
      act: (b) async {
        b.add(VesselPicked(VesselLeg.loading, const VesselSuggestion(vesselMasterId: 91, vesselName: 'CMA CGM PETRA')));
        await Future<void>.delayed(Duration.zero);
        expect(last(b).pickedLoading?.vesselMasterId, 91);
        expect(last(b).checkBoxValueLETA, isFalse);
        b.add(UpdateTextField('txtLoadingVessel', 'CMA CGM PETRAX'));
      },
      verify: (b) {
        expect(last(b).txtLoadingVessel, 'CMA CGM PETRAX');
        expect(last(b).pickedLoading, isNull);
      },
    );
  });

  group('"Did you mean" on leaving the field (task 2.4)', () {
    blocTest<SalesOrderAddBloc, SalesOrderAddState>(
      'a SAME vessel takes the master spelling silently',
      setUp: () => when(() => vessels.similar('MSK RIO NEGRO')).thenAnswer(
          (_) async => const SimilarVessel(match: 'SAME', vesselMasterId: 88, vesselName: 'MAERSK RIO NEGRO')),
      build: build,
      seed: () => form().copyWith(txtOffVessel: 'MSK RIO NEGRO'),
      act: (b) => b.add(VesselFieldLeft(VesselLeg.off)),
      verify: (b) {
        expect(last(b).txtOffVessel, 'MAERSK RIO NEGRO');
        expect(last(b).pickedOff?.vesselMasterId, 88);
        expect(last(b).didYouMean, isNull);
      },
    );

    blocTest<SalesOrderAddBloc, SalesOrderAddState>(
      'a CLOSE vessel asks once; "Keep my spelling" is not asked again for that text',
      setUp: () => when(() => vessels.similar('CMA CGM PETRON')).thenAnswer(
          (_) async => const SimilarVessel(match: 'CLOSE', vesselMasterId: 91, vesselName: 'CMA CGM PETRA')),
      build: build,
      seed: () => form().copyWith(txtOffVessel: 'CMA CGM PETRON'),
      act: (b) async {
        b.add(VesselFieldLeft(VesselLeg.off));
        await Future<void>.delayed(Duration.zero);
        expect(last(b).didYouMean?.name, 'CMA CGM PETRA');
        b.add(DidYouMeanAnswered(false));
        await Future<void>.delayed(Duration.zero);
        b.add(VesselFieldLeft(VesselLeg.off));
      },
      verify: (b) {
        expect(last(b).txtOffVessel, 'CMA CGM PETRON');
        expect(last(b).didYouMean, isNull);
        expect(last(b).pickedOff, isNull);
        verify(() => vessels.similar('CMA CGM PETRON')).called(1);
      },
    );

    blocTest<SalesOrderAddBloc, SalesOrderAddState>(
      '"Use" takes the suggested name and its master id',
      setUp: () => when(() => vessels.similar('CMA CGM PETRON')).thenAnswer(
          (_) async => const SimilarVessel(match: 'CLOSE', vesselMasterId: 91, vesselName: 'CMA CGM PETRA')),
      build: build,
      seed: () => form().copyWith(txtLoadingVessel: 'CMA CGM PETRON'),
      act: (b) async {
        b.add(VesselFieldLeft(VesselLeg.loading));
        await Future<void>.delayed(Duration.zero);
        b.add(DidYouMeanAnswered(true));
      },
      verify: (b) {
        expect(last(b).txtLoadingVessel, 'CMA CGM PETRA');
        expect(last(b).pickedLoading?.vesselMasterId, 91);
      },
    );

    blocTest<SalesOrderAddBloc, SalesOrderAddState>(
      'NONE, a failed check, a picked name and short text never prompt',
      setUp: () {
        when(() => vessels.similar('NEW VESSEL')).thenAnswer((_) async => const SimilarVessel(match: 'NONE'));
        when(() => vessels.similar('OFFLINE')).thenThrow(const ApiFailure('No internet connection'));
      },
      build: build,
      seed: () => form().copyWith(txtLoadingVessel: 'NEW VESSEL', txtOffVessel: 'OFFLINE'),
      act: (b) async {
        b.add(VesselFieldLeft(VesselLeg.loading));
        b.add(VesselFieldLeft(VesselLeg.off));
        await Future<void>.delayed(Duration.zero);
        b.add(VesselPicked(VesselLeg.off, _vessel));
        b.add(VesselFieldLeft(VesselLeg.off));
        b.add(UpdateTextField('txtLoadingVessel', 'N'));
        b.add(VesselFieldLeft(VesselLeg.loading));
      },
      verify: (b) {
        expect(last(b).didYouMean, isNull);
        expect(last(b).txtLoadingVessel, 'N');
        verifyNever(() => vessels.similar('MAERSK RIO NEGRO'));
        verifyNever(() => vessels.similar('N'));
      },
    );
  });

  group('links after a successful save (task 2.5)', () {
    SalesOrderAddLoaded saveable() => form().copyWith(
          txtCustomer: 'ACME',
          custId: 5,
          txtJobType: 'SHIP SPARE',
          jobTypeId: 2,
          productViewList: [SaleEditDetailModel.fromJava({'itemMasterRefId': 9, 'itemQty': 1, 'salesRate': 10})],
          productIds: [9],
          txtLoadingVessel: 'CMA CGM PETRON',
        );

    blocTest<SalesOrderAddBloc, SalesOrderAddState>(
      'a failing link request still says "Created Successfully"',
      setUp: () {
        when(() => saleOrders.save(any())).thenAnswer((_) async => {'id': 51234});
        when(() => vessels.saveLinks(any(), any())).thenThrow(const ApiFailure('Server error occurred. (500)'));
      },
      build: build,
      seed: () => saveable(),
      act: (b) async {
        b.add(VesselPicked(VesselLeg.off, _vessel, call: _call));
        await Future<void>.delayed(Duration.zero);
        b.add(SaveSalesOrderEvent());
        await Future<void>.delayed(Duration.zero);
        b.add(SaveDateQuestionAnswered(false)); // the pickup question (O ETA now set): leave empty
      },
      verify: (b) {
        expect(last(b).savedMessage, 'Created Successfully');
        expect(last(b).isSaved, isTrue);
        final sent = verify(() => vessels.saveLinks(51234, captureAny())).captured.single as List<VesselLinkRequest>;
        expect(sent.map((l) => l.toJava()), [
          {'leg': 'LOADING', 'vesselName': 'CMA CGM PETRON', 'vesselMasterId': null, 'ptpVesselCallId': null},
          {'leg': 'OFF', 'vesselName': 'MAERSK RIO NEGRO', 'vesselMasterId': 88, 'ptpVesselCallId': 412},
        ]);
      },
    );

    blocTest<SalesOrderAddBloc, SalesOrderAddState>(
      'an update without an id in the answer links the edited order; an edited name drops its ids',
      setUp: () {
        when(() => saleOrders.save(any())).thenAnswer((_) async => <String, dynamic>{});
        when(() => vessels.saveLinks(any(), any())).thenAnswer((_) async => const []);
      },
      build: build,
      seed: () => saveable().copyWith(editId: 40),
      act: (b) async {
        b.add(VesselPicked(VesselLeg.off, _vessel, call: _call));
        await Future<void>.delayed(Duration.zero);
        b.add(UpdateTextField('txtOffVessel', 'MAERSK RIO NEGRO X'));
        b.add(SaveSalesOrderEvent());
        await Future<void>.delayed(Duration.zero);
        b.add(SaveDateQuestionAnswered(false)); // the pickup question (O ETA now set): leave empty
      },
      verify: (b) {
        expect(last(b).savedMessage, 'Updated Successfully');
        final sent = verify(() => vessels.saveLinks(40, captureAny())).captured.single as List<VesselLinkRequest>;
        expect(sent.last.toJava(),
            {'leg': 'OFF', 'vesselName': 'MAERSK RIO NEGRO X', 'vesselMasterId': null, 'ptpVesselCallId': null});
      },
    );

    blocTest<SalesOrderAddBloc, SalesOrderAddState>(
      'the save body is the same with or without a pick (ids never go into it)',
      build: build,
      seed: () => saveable(),
      act: (b) => b.add(VesselPicked(VesselLeg.loading, const VesselSuggestion(vesselMasterId: 91, vesselName: 'CMA CGM PETRON'))),
      verify: (b) => expect(saleOrderSaveBody(last(b), companyId: 6, employeeId: 7),
          saleOrderSaveBody(saveable(), companyId: 6, employeeId: 7)),
    );

    blocTest<SalesOrderAddBloc, SalesOrderAddState>(
      'a failed save sends no links',
      setUp: () => when(() => saleOrders.save(any())).thenThrow(const ApiFailure('Customer is required')),
      build: build,
      seed: () => saveable(),
      act: (b) => b.add(SaveSalesOrderEvent()),
      verify: (b) {
        expect(last(b).savedMessage, 'Customer is required');
        verifyNever(() => vessels.saveLinks(any(), any()));
      },
    );
  });

  test('formDateOf writes the form date string', () {
    expect(formDateOf(DateTime(2026, 10, 1, 6, 5)), '2026-10-01 06:05:00');
  });
}
