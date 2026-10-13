import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_api.dart';
import 'package:maleva/core/mailmonitor/response_report_models.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/features/mail_monitor/report/booking_rules.dart';
import 'package:maleva/features/mail_monitor/report/booking_speed_page.dart';
import 'package:maleva/features/mail_monitor/report/response_rules.dart';
import 'package:maleva/features/mail_monitor/report/summary_speaker.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/local_fonts.dart';
import 'response_fixtures.dart';

class _Api extends Mock implements MailMonitorApi {}

class _Speaker implements SummarySpeaker {
  final spoken = <String>[];

  @override
  Future<SpeakResult> speak(String text, {required String voice}) async {
    spoken.add('$voice: $text');
    return SpeakResult.spoken;
  }

  @override
  Future<void> stop() async {}
}

// Sun 11 Oct 2026, 09:30 in Malaysia.
final _now = DateTime.utc(2026, 10, 11, 1, 30);
const _last7 = ReportRange('2026-10-05', '2026-10-11');

Map<String, dynamic> _emp(String name, int bookings, bool ranked, num median) => {
      'employee': name,
      'bookings': bookings,
      'ranked': ranked,
      'medianToSaleOrder': median,
      'avgToSaleOrder': median + 5,
      'medianToReply': median + 35,
      'avgToReply': median + 40,
      'fastestToSaleOrder': 10,
      'slowestToSaleOrder': 200,
    };

BookingSpeedReport _report() => BookingSpeedReport.fromJava({
      'from': '2026-10-05',
      'to': '2026-10-11',
      'minBookingsToRank': 5,
      'company': {
        'bookings': 13,
        'medianToSaleOrder': 55,
        'avgToSaleOrder': 62,
        'medianToReply': 90,
        'avgToReply': 97,
        'existingJobs': 2,
        'withoutSaleOrder': 1,
      },
      'employees': [_emp('SHALINI', 6, true, 50), _emp('ANU', 5, true, 70), _emp('SANTHIA', 2, false, 30)],
      'jobs': [
        {
          'jobNumber': 'MY002605623', 'mailboxId': 1, 'mailbox': 'cs1@maleva.com.my', 'employee': 'SHALINI',
          'bookingReceivedAt': '2026-10-07T02:15:00Z', 'saleOrderCreatedAt': '2026-10-07T03:05:00Z',
          'jobReplyAt': '2026-10-07T03:40:00Z', 'minutesToSaleOrder': 50, 'minutesToReply': 85, 'status': 'BOOKED',
          'afterHours': false,
        },
        {
          'jobNumber': 'MY002604512', 'mailboxId': 1, 'mailbox': 'cs1@maleva.com.my', 'employee': 'SHALINI',
          'bookingReceivedAt': '2026-10-08T12:30:00Z', 'saleOrderCreatedAt': '2026-10-01T01:00:00Z',
          'jobReplyAt': '2026-10-09T01:00:00Z', 'status': 'EXISTING_JOB', 'afterHours': true,
        },
      ],
    });

BookingSpeedReport _insightsReport() => BookingSpeedReport.fromJava({
    'from': '2026-10-05',
    'to': '2026-10-11',
    'minBookingsToRank': 5,
    'company': {'bookings': 13, 'medianToSaleOrder': 55, 'existingJobs': 0, 'withoutSaleOrder': 0},
    'employees': [_emp('SHALINI', 6, true, 50)],
    'jobs': <Map<String, dynamic>>[],
    'waitingReady': true,
    'checkReady': true,
    'pendingSaleOrders': [
      {'id': 1, 'mailboxId': 1, 'uid': 41, 'subject': 'Offload instruction APL ESPLANADE', 'sender': 'ops@fujiglobal.co.kr',
        'receivedAt': '2026-10-11T02:00:00Z', 'waitingMinutes': 300, 'replied': true,
        'mailboxes': ['cs1@maleva.com.my'], 'owners': ['SHALINI'], 'alerted': true},
      {'id': 2, 'mailboxId': 2, 'uid': 42, 'subject': 'Booking: 2 pallets', 'sender': 'ops@gac.com',
        'receivedAt': '2026-10-11T05:00:00Z', 'waitingMinutes': 120, 'replied': false,
        'mailboxes': ['operation@maleva.com.my'], 'owners': ['SANTHIA']},
    ],
    'pendingByPerson': [
      {'employee': 'SHALINI', 'mails': 1, 'oldestMinutes': 300},
      {'employee': 'SANTHIA', 'mails': 1, 'oldestMinutes': 120},
    ],
    'bookingMails': {'mails': 24, 'confirmed': 18, 'unchecked': 6, 'rejected': 2, 'replied': 20, 'medianFirstReply': 35, 'ruleRightPct': 90},
    'alertMinutes': 60,
    'waiting': [
      {'id': 9, 'mailbox': 'operation@maleva.com.my', 'senderDomain': 'fujiglobal.co.kr',
        'receivedAt': '2026-10-11T00:00:00Z', 'waitingMinutes': 75, 'alerted': true},
      {'id': 10, 'mailboxId': 3, 'uid': 41, 'mailbox': 'eswaran@maleva.com.my', 'senderDomain': 'thecavepoint.com',
        'sender': 'ops@thecavepoint.com', 'receivedAt': '2026-10-11T00:00:00Z', 'waitingMinutes': 30, 'alerted': false,
        'mailboxes': ['eswaran@maleva.com.my', 'naga@maleva.com.my', 'puviyarasu@maleva.com.my'],
        'subject': '[OFFLOAD INSTRUCTION] CMA CGM VASCO DE GAMA'},
    ],
    'insights': {
      'spread': [
        {'key': 'B0', 'label': 'Within 30 min', 'bookings': 2},
        {'key': 'B1', 'label': '30-60 min', 'bookings': 7},
        {'key': 'B2', 'label': '1-2 h', 'bookings': 0},
        {'key': 'B3', 'label': '2-4 h', 'bookings': 4},
        {'key': 'B4', 'label': 'Over 4 h', 'bookings': 0},
      ],
      'byArrival': [
        {'key': 'T2', 'label': '10:00-12:00', 'bookings': 9, 'medianToSaleOrder': 45},
        {'key': 'T5', 'label': '17:00 to closing', 'bookings': 4, 'medianToSaleOrder': 150},
      ],
      'byWeekday': [{'key': 'MONDAY', 'label': 'Mon', 'bookings': 13, 'medianToSaleOrder': 55}],
      'byDomain': [{'key': 'gac.com', 'label': 'gac.com', 'bookings': 9, 'medianToSaleOrder': 45}],
      'byMailbox': <Map<String, dynamic>>[],
      'daily': [{'day': '2026-10-06', 'bookings': 13, 'medianToSaleOrder': 55}],
      'slowSpots': [
        {'kind': 'ARRIVAL', 'label': '17:00 to closing', 'bookings': 4, 'medianToSaleOrder': 150, 'times': 2.7},
      ],
      'officeHoursMedian': 50,
      'afterHoursMedian': 90,
    },
  });

void main() {
  setUpAll(() async {
    await installLocalTestFonts();
    registerFallbackValue(_last7);
  });

  group('models', () {
    test('booking speed reads the Java answer as sent', () {
      final r = _report();
      expect(r.company.bookings, 13);
      expect(r.ranked.map((e) => e.employee), ['SHALINI', 'ANU']);
      expect(r.unranked.single.employee, 'SANTHIA');
      expect(r.newestJobs.first.jobNumber, 'MY002604512');
      expect(r.newestJobs.first.status, BookingStatus.existingJob);
      expect(r.newestJobs.first.minutesToSaleOrder, isNull);
    });

    test('reading line and reasons say why with the numbers', () {
      final row = responseRow({
        'reasons': ['READS_RARELY', 'OLD_UNREAD'],
        'reading': {'officeDays': 6, 'readDays': 2, 'unreadNow': 900, 'oldestUnreadOfficeDays': 12},
      });
      expect(reasonTexts(row), ['Mail read on only 2 of 6 office days', 'Oldest unread mail is 12 office days old']);
      expect(readingText(row), 'Read on 2 of 6 office days · 900 unread · oldest 12 office days');
      expect(readingText(responseRow()), isNull);
    });

    test('an AI point keeps its why and speaks it', () {
      final s = ResponseSummary.fromJava({
        'text': '',
        'points': [
          {
            'mailboxId': 4, 'mailbox': 'box4@maleva.com.my', 'category': 'WATCH', 'text': 'box4 needs a look.',
            'why': 'mail read on 1 of 6 office days', 'suggestion': 'Check the inbox twice a day.', 'checked': true,
          },
        ],
      });
      expect(s.items.single.why, 'mail read on 1 of 6 office days');
      expect(s.points.single, 'box4 needs a look. Why: mail read on 1 of 6 office days. Check the inbox twice a day.');
    });
  });

  group('page', () {
    late _Api api;
    late _Speaker speaker;
    setUp(() {
      api = _Api();
      speaker = _Speaker();
    });

    Future<void> pump(WidgetTester tester, Size size) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: BookingSpeedPage(api: api, clock: () => _now, speaker: speaker)));
      await tester.pump();
    }

    testWidgets('phone: totals, fastest, ranked and unranked apart, jobs newest first', (tester) async {
      when(() => api.bookingSpeed(any())).thenAnswer((_) async => _report());
      await pump(tester, const Size(400, 3200));

      verify(() => api.bookingSpeed(_last7)).called(1);
      expect(find.text('13'), findsOneWidget);
      expect(find.text('2 existing jobs left out'), findsOneWidget);
      expect(find.text('Fewer than 5 bookings · shown, not ranked'), findsOneWidget);
      expect(find.text('SANTHIA'), findsOneWidget);
      expect(find.text('Existing job'), findsOneWidget);
      expect(find.textContaining('(after hours)'), findsOneWidget);
      expect(
          tester.getTopLeft(find.text('MY002604512')).dy, lessThan(tester.getTopLeft(find.text('MY002605623')).dy));
      expect(tester.takeException(), isNull);
    });

    testWidgets('phone: the podium, the no-employee notice, and the job chips and search', (tester) async {
      final r = _report();
      final withMissing = BookingSpeedReport(
        from: r.from,
        to: r.to,
        company: r.company,
        jobs: r.jobs,
        minBookingsToRank: 5,
        employees: [
          ...r.employees,
          EmployeeSpeed.fromJava({..._emp(noEmployee, 43, false, 129)}),
        ],
      );
      when(() => api.bookingSpeed(any())).thenAnswer((_) async => withMissing);
      await pump(tester, const Size(390, 3600));

      expect(find.text('1st'), findsOneWidget);
      expect(find.text('2nd'), findsOneWidget);
      expect(find.textContaining('43 bookings have no employee on the sale order'), findsOneWidget);
      expect(find.text(noEmployee), findsNothing);   // never in the ranking
      expect(find.text('All (2)'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Counted (1)'));
      await tester.pump();
      expect(find.text('MY002605623'), findsOneWidget);
      expect(find.text('MY002604512'), findsNothing);
      await tester.tap(find.text('All (2)'));
      await tester.pump();
      await tester.enterText(find.byType(TextField), '4512');
      await tester.pump();
      expect(find.text('MY002604512'), findsOneWidget);
      expect(find.text('MY002605623'), findsNothing);
    });

    test('initials, bar share and filters', () {
      expect(initials('SANTHIA SARAVANAN'), 'SS');
      expect(initials('shalini'), 'S');
      expect(barShare(30, 120), 0.25);
      expect(barShare(1, 1000), 0.04);
      expect(barShare(null, 10), 0);
      final jobs = _report().newestJobs;
      expect(filterJobs(jobs, BookingStatus.existingJob, '').single.jobNumber, 'MY002604512');
      expect(filterJobs(jobs, null, 'cs1@').length, 2);
    });

    testWidgets('statistics, waiting bookings, and the AI summary written, named and read aloud', (tester) async {
      final r = _insightsReport();
      when(() => api.bookingSpeed(any())).thenAnswer((_) async => r);
      when(() => api.bookingSummary(any(), language: any(named: 'language'))).thenAnswer((_) async =>
          BookingSummary.fromJava({
            'provider': 'gemini',
            'model': 'flash-lite',
            'points': [
              {'about': 'EMPLOYEE', 'employee': 'SHALINI', 'text': 'SHALINI is the fastest: 50 m median.',
                'why': '6 bookings', 'suggestion': null, 'checked': true},
              {'about': 'SLOW_SPOT', 'employee': null, 'text': 'Bookings after 17:00 are slow.',
                'why': '4 bookings, 2 h 30 m', 'suggestion': 'Check evening mail first.', 'checked': true},
            ],
          }));
      await pump(tester, const Size(390, 5200));

      expect(find.text('Booking mails waiting now (2)'), findsOneWidget);
      expect(find.text('from ops@thecavepoint.com'), findsOneWidget);
      expect(find.text('[OFFLOAD INSTRUCTION] CMA CGM VASCO DE GAMA'), findsOneWidget);
      expect(find.text('Word rule right'), findsOneWidget);
      expect(find.text('90%'), findsOneWidget);
      expect(find.text('to eswaran@maleva.com.my, naga@maleva.com.my, puviyarasu@maleva.com.my'), findsOneWidget);
      expect(find.text('from fujiglobal.co.kr'), findsOneWidget);
      expect(find.text('Where bookings get slow'), findsOneWidget);
      expect(find.textContaining('2.7x the team'), findsOneWidget);
      expect(find.text('How fast bookings became a sale order'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Write summary'));
      await tester.pumpAndSettle();
      verify(() => api.bookingSummary(_last7, language: 'en')).called(1);
      expect(find.text('SHALINI is the fastest: 50 m median.'), findsOneWidget);
      expect(find.text('Slow spot'), findsOneWidget);
      expect(find.text('→ Check evening mail first.'), findsOneWidget);

      await tester.tap(find.text('Read aloud'));
      await tester.pumpAndSettle();
      expect(speaker.spoken.single, startsWith('en-US: SHALINI is the fastest: 50 m median. Why: 6 bookings.'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('tablet: the statistics lay out in two columns without overflow', (tester) async {
      when(() => api.bookingSpeed(any())).thenAnswer((_) async => _insightsReport());
      await pump(tester, const Size(1100, 3400));
      expect(find.text('By weekday'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tablet: lays out without overflow', (tester) async {
      when(() => api.bookingSpeed(any())).thenAnswer((_) async => _report());
      await pump(tester, const Size(1100, 2400));
      expect(find.text('ANU'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('503 says it is not set up yet', (tester) async {
      when(() => api.bookingSpeed(any()))
          .thenThrow(const ApiFailure('Run db/mail-booking-speed.sql first', statusCode: 503));
      await pump(tester, const Size(400, 1200));
      expect(find.text('Booking speed is not set up yet'), findsOneWidget);
    });
  });

  testWidgets('a waiting booking mail opens read-only', (tester) async {
    final api = _Api();
    when(() => api.bookingSpeed(any())).thenAnswer((_) async => _insightsReport());
    when(() => api.message(3, 41)).thenThrow(Exception('offline'));
    tester.view.physicalSize = const Size(390, 5200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: BookingSpeedPage(api: api, clock: () => _now, speaker: _Speaker())));
    await tester.pump();
    await tester.tap(find.text('[OFFLOAD INSTRUCTION] CMA CGM VASCO DE GAMA'));
    await tester.pumpAndSettle();
    expect(find.text('Mail'), findsOneWidget);           // the read-only mail page
    verify(() => api.message(3, 41)).called(1);
  });

  testWidgets('Not a booking saves the check and reloads the numbers', (tester) async {
    final api = _Api();
    when(() => api.bookingSpeed(any())).thenAnswer((_) async => _insightsReport());
    when(() => api.checkBooking(10, false)).thenAnswer((_) async {});
    tester.view.physicalSize = const Size(390, 5200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: BookingSpeedPage(api: api, clock: () => _now, speaker: _Speaker())));
    await tester.pump();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Not a booking').last);
    await tester.pumpAndSettle();
    verify(() => api.checkBooking(10, false)).called(1);
    verify(() => api.bookingSpeed(any())).called(2);
    expect(find.text('Marked as not a booking'), findsOneWidget);
  });

  testWidgets('confirmed bookings without a sale order, per person', (tester) async {
    final api = _Api();
    when(() => api.bookingSpeed(any())).thenAnswer((_) async => _insightsReport());
    tester.view.physicalSize = const Size(390, 6400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: BookingSpeedPage(api: api, clock: () => _now, speaker: _Speaker())));
    await tester.pump();
    expect(find.text('Confirmed bookings without a sale order (2)'), findsOneWidget);
    expect(find.text('replied, no job no.'), findsOneWidget);
    expect(find.text('no reply yet'), findsOneWidget);
    expect(find.textContaining('After 2 h 00 m of office time'), findsOneWidget);
    expect(find.text('alerted'), findsWidgets);
    await tester.tap(find.textContaining('SANTHIA · 1 pending'));
    await tester.pump();
    expect(find.text('Booking: 2 pallets'), findsOneWidget);
    expect(find.text('Offload instruction APL ESPLANADE'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
