import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/models/shared/sale_edit_detail_model.dart';
import 'package:maleva/core/sale_order/sale_order_api.dart';
import 'package:maleva/core/vessel_master/vessel_master_api.dart';
import 'package:maleva/core/vessel_master/vessel_master_models.dart';
import 'package:maleva/features/transaction/salesorder/add/bloc/salesorderadd_bloc.dart';
import 'package:maleva/features/transaction/salesorder/add/bloc/salesorderadd_event.dart';
import 'package:maleva/features/transaction/salesorder/add/bloc/salesorderadd_state.dart';
import 'package:maleva/features/transaction/salesorder/add/bloc/save_date_checks.dart';
import 'package:maleva/features/transaction/salesorder/add/data/salesorderadd_repository.dart';
import 'package:mocktail/mocktail.dart';

import 'sale_order_save_body_test.dart' show form;

class _Context extends Mock implements BuildContext {}

class _SaleOrders extends Mock implements SaleOrderApi {}

class _VesselMasters extends Mock implements VesselMasterApi {}

/// FM NAMTHONG EXCELLENCE 2653 as PTP lists it.
const _call = PtpCall(
  id: 42,
  port: 'PTP',
  vesselName: 'FM NAMTHONG EXCELLENCE',
  voyage: '2653',
  arriveAt: '2026-10-14T15:00',
  arriveEstimated: true,
  departAt: '2026-10-15T18:00',
  departEstimated: true,
);

/// An off-leg job with ETA 15 Oct 15:00 and the given pickup / delivery (null = empty).
SalesOrderAddLoaded offJob({String? pickup, String? delivery, String eta = '2026-10-15 15:00:00'}) => form().copyWith(
      txtCustomer: 'ACME',
      custId: 5,
      txtJobType: 'SEA FRIEGHT EXPORT',
      jobTypeId: 5,
      productViewList: [SaleEditDetailModel.fromJava({'itemMasterRefId': 9, 'itemQty': 1, 'salesRate': 10})],
      productIds: [9],
      visibleLoadingVessel: false,
      txtOffVessel: 'FM NAMTHONG EXCELLENCE',
      checkBoxValueOETA: true,
      dtpOETAdate: eta,
      checkBoxValuePickUp: pickup != null,
      dtpPickUpdate: pickup ?? '2026-10-02 09:30:00',
      checkBoxValueDelivery: delivery != null,
      dtpDeliverydate: delivery ?? '2026-10-02 09:30:00',
    );

/// The question before saving (vessel-master-and-ptp-schedule, app task 3.4). Pickup and delivery do not
/// follow the ETA: the owner removed that question on 2026-10-13.
void main() {
  group('planPtpTimes', () {
    final calls = {VesselLeg.off: const LegCall('FM NAMTHONG EXCELLENCE', _call)};

    test('a typed ETA an hour or more from PTP is named with PTP\'s', () {
      final q = planPtpTimes(offJob(eta: '2026-10-16 10:00:00'), calls)!;

      expect(q.vessels, 'FM NAMTHONG EXCELLENCE 2653');
      expect(q.lines.single.label, 'ETA');
      expect(q.lines.single.ptp, DateTime(2026, 10, 14, 15));
    });

    test('the question names the schedule the call is from', () {
      PtpTimeQuestion ask(PtpCall call) =>
          planPtpTimes(offJob(eta: '2026-10-16 10:00:00'), {VesselLeg.off: LegCall('FM NAMTHONG EXCELLENCE', call)})!;

      final ptp = ask(_call);
      expect(ptp.title, "PTP's schedule shows another time");
      expect(ptp.message, startsWith('PTP lists FM NAMTHONG EXCELLENCE 2653 at other times'));
      expect(ptp.useText, "Use PTP's times");

      final westports = ask(const PtpCall(id: 43, port: 'WESTPORTS', vesselName: 'FM NAMTHONG EXCELLENCE',
          voyage: '2653', arriveAt: '2026-10-14T15:00', arriveEstimated: true));
      expect(westports.title, "Westports' schedule shows another time");
      expect(westports.useText, "Use Westports' times");
      expect(westports.lines.single.source, 'Westports');

      final mmsw = ask(const PtpCall(id: 44, port: 'MMSW', vesselName: 'FM NAMTHONG EXCELLENCE', scn: '267DF4',
          arriveAt: '2026-10-14T15:00', arriveEstimated: true));
      expect(mmsw.title, "MMSW's schedule shows another time");
      expect(mmsw.message, startsWith('MMSW lists FM NAMTHONG EXCELLENCE SCN 267DF4'));
    });

    test('under an hour, a renamed vessel, or no call asks nothing', () {
      expect(planPtpTimes(offJob(eta: '2026-10-14 15:30:00'), calls), isNull);
      expect(planPtpTimes(offJob(eta: '2026-10-16 10:00:00').copyWith(txtOffVessel: 'CMA CGM PETRON'), calls), isNull);
      expect(planPtpTimes(offJob(eta: '2026-10-16 10:00:00'), const {}), isNull);
    });
  });

  group('saving', () {
    late _SaleOrders saleOrders;
    late _VesselMasters vessels;

    setUpAll(() => registerFallbackValue(<VesselLinkRequest>[]));

    setUp(() {
      saleOrders = _SaleOrders();
      vessels = _VesselMasters();
      when(() => saleOrders.save(any())).thenAnswer((_) async => {'id': 51234});
      when(() => vessels.saveLinks(any(), any())).thenAnswer((_) async => const []);
    });

    SalesOrderAddBloc build() =>
        SalesOrderAddBloc(_Context(), SalesOrderAddRepository(), saleOrders: saleOrders, vesselMasters: vessels);
    SalesOrderAddLoaded last(SalesOrderAddBloc b) => b.state as SalesOrderAddLoaded;
    Map<String, dynamic> savedBody() => verify(() => saleOrders.save(captureAny())).captured.single as Map<String, dynamic>;

    SalesOrderAddLoaded ptpJob() => offJob(eta: '2026-10-16 10:00:00', pickup: '2026-10-11 09:00:00')
        .copyWith(savedLegCalls: {VesselLeg.off: const LegCall('FM NAMTHONG EXCELLENCE', _call)});

    blocTest<SalesOrderAddBloc, SalesOrderAddState>(
      'a typed ETA unlike PTP\'s stops the save; "Use PTP\'s times" saves PTP\'s ETA and nothing else is asked',
      build: build,
      seed: ptpJob,
      act: (b) async {
        b.add(SaveSalesOrderEvent());
        await Future<void>.delayed(Duration.zero);
        expect(last(b).saveQuestion, isA<PtpTimeQuestion>());
        verifyNever(() => saleOrders.save(any()));
        b.add(SaveDateQuestionAnswered(true));
      },
      verify: (b) {
        expect(last(b).savedMessage, 'Created Successfully');
        expect(last(b).saveQuestion, isNull);
        final body = savedBody();
        expect(body['oeta'], '2026-10-14T15:00:00');
        // pickup and delivery do not follow the ETA: saved as typed
        expect(body['pickupDate'], '2026-10-11T09:00:00');
        expect(body['deliveryDate'], isNull);
      },
    );

    blocTest<SalesOrderAddBloc, SalesOrderAddState>(
      '"Keep my times" saves the typed ETA',
      build: build,
      seed: ptpJob,
      act: (b) async {
        b.add(SaveSalesOrderEvent());
        await Future<void>.delayed(Duration.zero);
        b.add(SaveDateQuestionAnswered(false));
      },
      verify: (b) {
        expect(last(b).savedMessage, 'Created Successfully');
        expect(savedBody()['oeta'], '2026-10-16T10:00:00');
      },
    );

    blocTest<SalesOrderAddBloc, SalesOrderAddState>(
      'pickup and delivery days before the ETA (or empty) save without a question',
      build: build,
      seed: () => offJob(pickup: '2026-10-11 09:00:00'),
      act: (b) => b.add(SaveSalesOrderEvent()),
      verify: (b) {
        expect(last(b).savedMessage, 'Created Successfully');
        expect(last(b).saveQuestion, isNull);
        final body = savedBody();
        expect(body['pickupDate'], '2026-10-11T09:00:00');
        expect(body['deliveryDate'], isNull);
      },
    );

    blocTest<SalesOrderAddBloc, SalesOrderAddState>(
      'a loaded order asks nothing for an unrelated save',
      build: build,
      seed: () {
        final loaded = offJob(pickup: '2026-10-11 09:00:00').copyWith(editId: 21732);
        return loaded.copyWith(ptpSettledKey: ptpTimeKey(loaded));
      },
      act: (b) => b.add(SaveSalesOrderEvent()),
      verify: (b) {
        expect(last(b).savedMessage, 'Updated Successfully');
        expect(last(b).saveQuestion, isNull);
      },
    );
  });
}
