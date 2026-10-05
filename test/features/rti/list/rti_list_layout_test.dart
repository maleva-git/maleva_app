import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/theme/app_theme.dart';
import 'package:maleva/features/rti/list/bloc/rti_list_bloc.dart';
import 'package:maleva/features/rti/list/data/rti_list_repository.dart';
import 'package:maleva/features/rti/list/models/rti_list_filter.dart';
import 'package:maleva/features/rti/list/models/rti_list_row.dart';
import 'package:maleva/features/rti/list/view/phone/rti_list_phone_view.dart';
import 'package:maleva/features/rti/list/view/tablet/rti_list_tablet_view.dart';
import 'package:mocktail/mocktail.dart';

class _Repo extends Mock implements RtiListRepository {}

void main() {
  setUpAll(() => registerFallbackValue(RtiListFilter.initial(DateTime(2026))));

  final rows = [
    for (var i = 1; i <= 6; i++)
      RtiListRow(
        id: i,
        rtiNo: 'RTI00000000$i',
        rtiDate: DateTime(2026, 10, 5),
        driverName: 'Driver with a long name $i',
        truckName: 'WXY 12$i',
        remarks: i.isEven ? 'Remarks that are long enough to need an ellipsis on a phone' : '',
        amount: i.isEven ? 0 : 120.5,
        jobs: [for (var j = 0; j < 12; j++) RtiListJob(jobNo: 'TR0026-04$j', customerName: 'Customer $j')],
      ),
  ];

  Future<RtiListBloc> pump(WidgetTester tester, Size size, Widget Function() view, {bool dark = false}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = _Repo();
    when(() => repo.companyId).thenReturn(6);
    when(() => repo.employeeId).thenReturn(42);
    when(() => repo.isDriver).thenReturn(false);
    when(() => repo.drivers()).thenAnswer((_) async => const []);
    when(() => repo.trucks()).thenAnswer((_) async => const []);
    when(() => repo.list(any())).thenAnswer((_) async => rows);
    when(() => repo.preview(any())).thenAnswer((_) async => RtiPreviewData(destination: 'Shah Alam', jobs: rows.first.jobs));
    final bloc = RtiListBloc(repository: repo, openUrl: (_) async {}, today: () => DateTime(2026, 10, 5))..add(const RtiListStarted());
    await tester.pumpWidget(MaterialApp(
      // AppTheme loads Google Fonts over the network; the plain theme with the tokens is enough here.
      theme: ThemeData(
        useMaterial3: true,
        brightness: dark ? Brightness.dark : Brightness.light,
        extensions: [dark ? MalevaColors.dark : MalevaColors.light],
      ),
      home: BlocProvider.value(value: bloc, child: view()),
    ));
    await tester.pumpAndSettle();
    return bloc;
  }

  testWidgets('phone: cards, stats, preview sheet', (tester) async {
    await pump(tester, const Size(390, 844), () => const RtiListPhoneView());
    expect(find.text('Records'), findsOneWidget);
    expect(find.text('RTI000000001'), findsOneWidget);
    await tester.tap(find.text('RTI000000001'));
    await tester.pumpAndSettle();
    expect(find.text('DESTINATION'), findsOneWidget);
    expect(find.text('+2 more'), findsOneWidget);
  });

  testWidgets('phone, dark', (tester) async {
    await pump(tester, const Size(390, 844), () => const RtiListPhoneView(), dark: true);
    expect(find.text('Total Amount'), findsOneWidget);
  });

  testWidgets('tablet portrait: list and preview pane (dark)', (tester) async {
    final bloc = await pump(tester, const Size(820, 1180), () => const RtiListTabletPortraitView(), dark: true);
    bloc.add(const RtiListRowSelected(1));
    await tester.pumpAndSettle();
    expect(find.text('Shah Alam'), findsOneWidget);
  });

  testWidgets('tablet landscape: filter panel, table, preview', (tester) async {
    await pump(tester, const Size(1366, 1024), () => const RtiListTabletLandscapeView());
    expect(find.text('Filter RTI'), findsOneWidget);
    expect(find.text('RTI NO'), findsOneWidget);
  });
}
