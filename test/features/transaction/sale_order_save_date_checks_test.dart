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

/// The questions before saving (vessel-master-and-ptp-schedule, app task 3.4).
void main() {
  group('planPickupSchedule', () {
    test('an earlier pickup is offered the day before the ETA, keeping its time', () {
      final q = planPickupSchedule(offJob(pickup: '2026-10-11 09:00:00', delivery: '2026-10-11 14:00:00'))!;

      expect(q.etaLabel, 'Off ETA');
      expect(q.targetDay, DateTime(2026, 10, 14));
      expect(q.lines.map((l) => l.next), [DateTime(2026, 10, 14, 9), DateTime(2026, 10, 14, 14)]);
      expect(q.bothEmpty, isFalse);
    });

    test('empty dates are offered at 00:00; dates already the day before ask nothing', () {
      final empty = planPickupSchedule(offJob())!;
      expect(empty.bothEmpty, isTrue);
      expect(empty.lines.map((l) => l.next), [DateTime(2026, 10, 14), DateTime(2026, 10, 14)]);

      expect(planPickupSchedule(offJob(pickup: '2026-10-14 09:00:00', delivery: '2026-10-14 15:00:00')), isNull);
    });

    test('no ETA, or both vessel sections hidden (general cargo), asks nothing', () {
      expect(planPickupSchedule(offJob().copyWith(checkBoxValueOETA: false)), isNull);
      expect(planPickupSchedule(offJob().copyWith(visibleOffVessel: false)), isNull);
    });

    test('a month end is crossed correctly', () {
      final q = planPickupSchedule(offJob(eta: '2026-11-01 06:00:00', pickup: '2026-10-28 09:00:00'))!;
      expect(q.lines.first.next, DateTime(2026, 10, 31, 9));
    });
  });

  group('planPtpTimes', () {
    final calls = {VesselLeg.off: const LegCall('FM NAMTHONG EXCELLENCE', _call)};

    test('a typed ETA an hour or more from PTP is named with PTP\'s', () {
      final q = planPtpTimes(offJob(eta: '2026-10-16 10:00:00'), calls)!;

      expect(q.vessels, 'FM NAMTHONG EXCELLENCE 2653');
      expect(q.lines.single.label, 'ETA');
      expect(q.lines.single.ptp, DateTime(2026, 10, 14, 15));
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

    blocTest<SalesOrderAddBloc, SalesOrderAddState>(
      'Save stops at the pickup question; "Change" saves pickup and delivery on the day before',
      build: build,
      seed: () => offJob(pickup: '2026-10-11 09:00:00'),
      act: (b) async {
        b.add(SaveSalesOrderEvent());
        await Future<void>.delayed(Duration.zero);
        expect(last(b).saveQuestion, isA<PickupScheduleQuestion>());
        verifyNever(() => saleOrders.save(any()));
        b.add(SaveDateQuestionAnswered(true));
      },
      verify: (b) {
        expect(last(b).savedMessage, 'Created Successfully');
        final body = savedBody();
        expect(body['pickupDate'], '2026-10-14T09:00:00');
        expect(body['deliveryDate'], '2026-10-14T00:00:00');
      },
    );

    blocTest<SalesOrderAddBloc, SalesOrderAddState>(
      '"Keep my dates" saves them as they are',
      build: build,
      seed: () => offJob(pickup: '2026-10-11 09:00:00'),
      act: (b) async {
        b.add(SaveSalesOrderEvent());
        await Future<void>.delayed(Duration.zero);
        b.add(SaveDateQuestionAnswered(false));
      },
      verify: (b) {
        final body = savedBody();
        expect(body['pickupDate'], '2026-10-11T09:00:00');
        expect(body['deliveryDate'], isNull);
      },
    );

    blocTest<SalesOrderAddBloc, SalesOrderAddState>(
      'a typed ETA unlike PTP\'s is asked first; "Use PTP\'s times" saves PTP\'s ETA, then the pickup question follows',
      build: build,
      seed: () => offJob(eta: '2026-10-16 10:00:00', pickup: '2026-10-13 09:00:00', delivery: '2026-10-13 09:00:00')
          .copyWith(savedLegCalls: {VesselLeg.off: const LegCall('FM NAMTHONG EXCELLENCE', _call)}),
      act: (b) async {
        b.add(SaveSalesOrderEvent());
        await Future<void>.delayed(Duration.zero);
        expect(last(b).saveQuestion, isA<PtpTimeQuestion>());
        b.add(SaveDateQuestionAnswered(true));
      },
      verify: (b) {
        // PTP's 14 Oct ETA makes 13 Oct the right day, so no pickup question was needed
        expect(last(b).savedMessage, 'Created Successfully');
        expect(savedBody()['oeta'], '2026-10-14T15:00:00');
      },
    );

    blocTest<SalesOrderAddBloc, SalesOrderAddState>(
      'a loaded order asks nothing for an unrelated save',
      build: build,
      seed: () {
        final loaded = offJob(pickup: '2026-10-11 09:00:00').copyWith(editId: 21732);
        return loaded.copyWith(ptpSettledKey: ptpTimeKey(loaded), scheduleSettledKey: scheduleKey(loaded));
      },
      act: (b) => b.add(SaveSalesOrderEvent()),
      verify: (b) {
        expect(last(b).savedMessage, 'Updated Successfully');
        expect(last(b).saveQuestion, isNull);
      },
    );
  });
}
