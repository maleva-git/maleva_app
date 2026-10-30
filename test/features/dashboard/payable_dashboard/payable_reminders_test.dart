import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/dashboard/payable_dashboard/reminders/data/reminder_models.dart';
import 'package:maleva/features/dashboard/payable_dashboard/reminders/data/reminders_api.dart';
import 'package:maleva/features/dashboard/payable_dashboard/reminders/reminder_route.dart';
import 'package:maleva/features/dashboard/payable_dashboard/reminders/view/reminder_form_page.dart';
import 'package:maleva/features/dashboard/payable_dashboard/reminders/view/reminder_look.dart';
import 'package:maleva/features/dashboard/payable_dashboard/reminders/view/reminders_view.dart';
import 'package:maleva/features/dashboard/payable_dashboard/reminders/view/today_reminders_card.dart';
import 'package:maleva/features/mail_monitor/mine/push_route.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/local_fonts.dart';

class RouteAdapter implements HttpClientAdapter {
  final Map<String, (int, String)> replies = {};
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? stream, Future<void>? cancelFuture) async {
    requests.add(options);
    final (status, body) = replies['${options.method} ${options.path}'] ?? (404, '{}');
    return ResponseBody.fromString(body, status, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

class MockApi extends Mock implements RemindersApi {}

String ok(Object data) => jsonEncode({'IsSuccess': true, 'StatusCode': 200, 'Data1': data});

Map<String, dynamic> dayItem(int id, String title, String day, String state, {String? planned, String doneBy = ''}) => {
      'reminderId': id,
      'title': title,
      'notes': '',
      'time': '09:00',
      'dueOn': day,
      'planned': planned ?? day,
      'state': state,
      'doneBy': doneBy,
      'followUps': 0,
      'audience': 'TEAM',
    };

ReminderMonth november() => ReminderMonth.fromJava({
      'month': '2026-11',
      'today': '2026-11-03',
      'days': [
        {'date': '2026-11-03', 'items': [dayItem(1, 'Print TNG invoice', '2026-11-03', 'SENT')]},
        {'date': '2026-11-05', 'items': [dayItem(2, 'Port charges payment', '2026-11-05', 'UPCOMING')]},
        {'date': '2026-11-10', 'items': [dayItem(3, 'Print Konica invoice', '2026-11-10', 'UPCOMING')]},
      ],
    });

ReminderItem tng() => ReminderItem.fromJava({
      'id': 1, 'title': 'Print TNG invoice', 'repeat': 'MONTHLY', 'dayOfMonth': 3, 'time': '09:00', 'whenOffDay': 'BEFORE',
      'audience': 'TEAM', 'people': [], 'fromMonth': '2026-10', 'paused': false, 'followUp': true, 'nextDue': '2026-12-03',
    });

void main() {
  setUpAll(installLocalTestFonts);
  setUpAll(() {
    registerFallbackValue(DateTime(2026));
    registerFallbackValue(ReminderForm());
  });

  group('models and words', () {
    test('a month, its states and moves', () {
      final m = ReminderMonth.fromJava({
        'month': '2026-12',
        'today': '2026-12-01',
        'days': [
          {'date': '2026-12-31', 'items': [dayItem(1, 'TNG', '2026-12-31', 'UPCOMING', planned: '2027-01-03')]},
        ],
      });
      final d = m.on(DateTime(2026, 12, 31)).single;
      expect(d.moved, isTrue);
      expect(d.state, DayState.upcoming);
      expect(m.on(DateTime(2026, 12, 30)), isEmpty);
    });

    test('rule in words, times, ordinals', () {
      expect(ruleText(tng()), 'Every month on the 3rd at 9:00 am · weekend / holiday → working day before');
      expect(timeLabel('14:30'), '2:30 pm');
      expect(timeLabel('00:05'), '12:05 am');
      expect(ordinal(11), '11th');
      expect(ordinal(22), '22nd');
    });

    test('form checks and the body it sends', () {
      final f = ReminderForm();
      expect(f.problems(), ['Type what to remember', 'Choose the day of the month']);
      f
        ..title = ' Print TNG invoice '
        ..dayOfMonth = 3
        ..audience = 'PEOPLE';
      expect(f.problems(), ['Choose at least one person']);
      f.people.add(41);
      expect(f.toJson(), {
        'title': 'Print TNG invoice',
        'notes': null,
        'repeat': 'MONTHLY',
        'dayOfMonth': 3,
        'onDate': null,
        'time': '09:00',
        'whenOffDay': 'BEFORE',
        'audience': 'PEOPLE',
        'people': [41],
        'fromMonth': null,
        'toMonth': null,
        'paused': false,
        'followUp': true,
      });
    });

    test('today counts what is still to do', () {
      final t = ReminderToday.fromJava({
        'due': [dayItem(1, 'a', '2026-11-03', 'SENT'), dayItem(2, 'b', '2026-11-03', 'DONE')],
        'open': [dayItem(3, 'c', '2026-11-02', 'OVERDUE')],
      });
      expect(t.toDo, 2);
    });
  });

  group('notice routes', () {
    test('a reminder notice opens its day; other notices are not taken', () {
      expect(payableReminderRoute('PAYABLE_REMINDER', '/payable/reminders?day=2026-11-03'), '/payable/reminders?day=2026-11-03');
      expect(payableReminderRoute('PAYABLE_REMINDER_FOLLOWUP', ''), '/payable/reminders');
      expect(payableReminderRoute('VESSEL_ETA_CHANGED', '/x'), isNull);
      expect(routeForPush({'type': 'PAYABLE_REMINDER', 'link': '/payable/reminders?day=2026-11-03'}),
          '/payable/reminders?day=2026-11-03');
      expect(routeForPayload('PAYABLE_REMINDER_FOLLOWUP'), '/payable/reminders');
      expect(reminderDayOf('2026-11-03'), DateTime(2026, 11, 3));
      expect(reminderDayOf('x'), isNull);
    });
  });

  test('api: calendar, done, create', () async {
    final adapter = RouteAdapter();
    final api = RemindersApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter);
    adapter.replies['GET /api/payable-reminders/calendar'] = (200, ok({'month': '2026-11', 'today': '2026-11-03', 'days': []}));
    adapter.replies['POST /api/payable-reminders/1/done'] = (200, ok(dayItem(1, 'TNG', '2026-11-03', 'DONE', doneBy: 'AMY')));
    adapter.replies['POST /api/payable-reminders'] = (200, ok({'id': 9, 'title': 'TNG', 'dayOfMonth': 3}));
    expect((await api.calendar('2026-11')).month, '2026-11');
    expect(adapter.requests.last.queryParameters, {'month': '2026-11'});
    final d = await api.done(1, DateTime(2026, 11, 3));
    expect(d.state, DayState.done);
    expect(d.doneBy, 'AMY');
    expect(adapter.requests.last.queryParameters, {'dueOn': '2026-11-03'});
    expect((await api.create(ReminderForm(title: 'TNG', dayOfMonth: 3))).id, 9);
    expect((adapter.requests.last.data as Map)['dayOfMonth'], 3);
  });

  group('screens', () {
    late MockApi api;
    setUp(() {
      api = MockApi();
      when(() => api.calendar(any())).thenAnswer((_) async => november());
      when(() => api.done(any(), any(), note: any(named: 'note')))
          .thenAnswer((_) async => ReminderDay.fromJava(dayItem(1, 'Print TNG invoice', '2026-11-03', 'DONE')));
      when(() => api.list()).thenAnswer((_) async => [tng()]);
      when(() => api.delete(any())).thenAnswer((_) async {});
      when(() => api.people()).thenAnswer((_) async => const [ReminderPerson(41, 'AMY', 1100)]);
      when(() => api.preview(any())).thenAnswer((_) async => [
            ReminderDay.fromJava(dayItem(0, 'x', '2026-11-03', 'UPCOMING')),
            ReminderDay.fromJava(dayItem(0, 'x', '2026-12-03', 'UPCOMING')),
            ReminderDay.fromJava(dayItem(0, 'x', '2026-12-31', 'UPCOMING', planned: '2027-01-03')),
          ]);
      when(() => api.create(any())).thenAnswer((_) async => tng());
    });

    Future<void> pumpCalendar(WidgetTester tester, {Size size = const Size(360, 1400)}) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
          home: RemindersView(api: api, initialDay: DateTime(2026, 11, 3), clock: () => DateTime(2026, 11, 3, 10))));
      await tester.pumpAndSettle();
    }

    testWidgets('calendar on a 360 px phone: the chosen day, Done, another day, next month', (tester) async {
      await pumpCalendar(tester);
      expect(find.text('November 2026'), findsOneWidget);
      expect(find.text('Print TNG invoice'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const ValueKey('rem-quick-done-1')));
      await tester.pumpAndSettle();
      verify(() => api.done(1, DateTime(2026, 11, 3))).called(1);

      await tester.tap(find.byKey(const ValueKey('rem-day-5')));
      await tester.pump();
      expect(find.text('Port charges payment'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('rem-next')));
      await tester.pumpAndSettle();
      verify(() => api.calendar('2026-12')).called(1);
    });

    testWidgets('a reminder sheet: delete asks first', (tester) async {
      await pumpCalendar(tester);
      await tester.tap(find.byKey(const ValueKey('rem-item-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('rem-delete')));
      await tester.pumpAndSettle();
      expect(find.text('Delete "Print TNG invoice"?'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('rem-delete-confirm')));
      await tester.pumpAndSettle();
      verify(() => api.delete(1)).called(1);
    });

    testWidgets('form: quick pick, the next days from the server, save', (tester) async {
      tester.view.physicalSize = const Size(360, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: ReminderFormPage(api: api)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const ValueKey('rem-pick-3')));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(find.textContaining('Thu 31 Dec, 9:00 am  (moved from Sun 3 Jan)'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('rem-save')));
      await tester.pumpAndSettle();
      final sent = verify(() => api.create(captureAny())).captured.single as ReminderForm;
      expect(sent.title, 'Print TNG invoice');
      expect(sent.dayOfMonth, 3);
      expect(sent.whenOffDay, 'BEFORE');
    });

    testWidgets('form: nothing chosen is refused before asking the server', (tester) async {
      tester.view.physicalSize = const Size(360, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: ReminderFormPage(api: api)));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('rem-save')));
      await tester.pumpAndSettle();
      expect(find.text('Please check'), findsOneWidget);
      verifyNever(() => api.create(any()));
    });

    testWidgets('Today card: to do count, earlier day first, Done', (tester) async {
      when(() => api.today()).thenAnswer((_) async => ReminderToday.fromJava({
            'due': [dayItem(2, 'Port charges payment', '2026-11-05', 'SENT')],
            'open': [dayItem(1, 'Print TNG invoice', '2026-11-03', 'OVERDUE')],
          }));
      when(() => api.done(any(), any(), note: any(named: 'note')))
          .thenAnswer((_) async => ReminderDay.fromJava(dayItem(1, 'x', '2026-11-03', 'DONE')));
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: TodayRemindersCard(api: api)))));
      await tester.pumpAndSettle();
      expect(find.text('2 to do'), findsOneWidget);
      expect(find.textContaining('Due Tue 3 Nov · not done yet'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('today-rem-done-1')));
      await tester.pumpAndSettle();
      verify(() => api.done(1, DateTime(2026, 11, 3))).called(1);
    });
  });
}
