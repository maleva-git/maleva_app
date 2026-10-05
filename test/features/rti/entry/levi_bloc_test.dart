import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/features/rti/bloc/levi_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'rti_mocks.dart';

// R/rtiLeviEntryModal.test.tsx and the checks of RTILeviEntryModal.tsx:365-439.
const rtiId = 77;
Map<String, dynamic> leviRow() => {'id': 900, 'cNumberDisplay': 'LE000003236', 'enterLink': 'IN', 'exitLink': '1ST LINK', 'truckRefId': 72, 'driverRefId': 5, 'amount': 40, 'saleDate': '2026-10-01'};

void main() {
  late MockLeviApi api;
  late MockAttachmentsApi files;
  late Completer<({List<Map<String, dynamic>> items, double? entriesTotal})> byRti;
  final saved = <Map<String, dynamic>>[];

  setUp(() {
    api = MockLeviApi();
    files = MockAttachmentsApi();
    saved.clear();
    byRti = Completer();
    when(() => api.companyId).thenReturn(6);
    when(() => api.byRti(rtiId)).thenAnswer((_) => byRti.future);
    when(() => api.nextNumber()).thenAnswer((_) async => 'LE000003237');
    when(() => api.save(any())).thenAnswer((i) async {
      saved.add(i.positionalArguments.first as Map<String, dynamic>);
      return {'id': 901, 'cNumberDisplay': 'LE000003238'};
    });
    when(() => files.list(folder: any(named: 'folder'), recordId: any(named: 'recordId'))).thenAnswer((_) async => []);
  });

  LeviBloc open() => LeviBloc(
        api: api,
        attachments: files,
        context: const LeviContext(rtiId: rtiId, rtiNo: 'RTI000000077', truckRefId: '72', driverRefId: '5', eLink: '1st link', exLink: '2ND LINK', employeeRefId: 3),
      )..add(const LeviOpened());

  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 10));

  test('opens on a blank IN with the RTI truck, driver and Enter link', () async {
    final b = open();
    await settle();
    expect([b.state.form.entryType, b.state.form.link, b.state.form.truckRefId, b.state.form.driverRefId], ['IN', '1ST LINK', '72', '5']);
    expect(b.state.listStatus, LeviListStatus.loading);
    expect(b.state.documentNumber, 'LE000003237');
    b.add(const LeviEntryTypeChanged('OUT'));
    await settle();
    expect(b.state.form.link, '2ND LINK');
    await b.close();
  });

  test('saves while the RTI read is still in flight', () async {
    final b = open();
    await settle();
    b.add(LeviFormPatched((f) => f.copyWith(amount: '50')));
    b.add(const LeviSaveRequested());
    await settle();
    byRti.complete((items: <Map<String, dynamic>>[], entriesTotal: null));
    await settle();
    expect(saved, hasLength(1));
    expect(saved.single, {
      'companyRefId': 6, 'truckRefId': 72, 'driverRefId': 5, 'rtiRefId': rtiId, 'employeeRefId': 3,
      'saleDate': b.state.form.saleDate, 'amount': 50, 'enterLink': 'IN', 'exitLink': '1ST LINK',
    });
    expect(b.state.message, 'Levi entries LE000003238 saved');
    expect([b.state.entryId, b.state.entryNumber], [901, 'LE000003238']);
    await b.close();
  });

  test('still saves when the RTI read fails outright', () async {
    final b = open();
    await settle();
    b.add(LeviFormPatched((f) => f.copyWith(amount: '12.5')));
    byRti.completeError(const ApiFailure('404'));
    await settle();
    b.add(const LeviSaveRequested());
    await settle();
    expect(saved.single['amount'], 12.5);
    await b.close();
  });

  test('does not file a second levi for a leg that already has one', () async {
    final b = open();
    await settle();
    b.add(LeviFormPatched((f) => f.copyWith(amount: '50')));
    await settle();
    byRti.complete((items: [leviRow()], entriesTotal: 40.0));
    b.add(const LeviSaveRequested());
    await settle();
    expect(saved, isEmpty);
    expect(b.state.message, 'This RTI already has an IN levi (LE000003236). Press Save again to update it.');
    expect([b.state.documentNumber, b.state.form.amount, b.state.saveLabel], ['LE000003236', '50', 'Update IN']);
    b.add(const LeviSaveRequested());
    await settle();
    expect(saved.single['id'], 900);
    expect(saved.single['amount'], 50);
    await b.close();
  });

  test('does not overwrite typing when the read lands late', () async {
    final b = open();
    await settle();
    b.add(LeviFormPatched((f) => f.copyWith(amount: '77')));
    await settle();
    byRti.complete((items: [leviRow()], entriesTotal: 40.0));
    await settle();
    expect(b.state.form.amount, '77');
    expect(b.state.entryId, 0);
    await b.close();
  });

  test('an RTI with a filed IN opens on it', () async {
    byRti.complete((items: [leviRow()], entriesTotal: 40.0));
    final b = open();
    await settle();
    expect([b.state.entryId, b.state.form.amount, b.state.form.entryType], [900, '40', 'IN']);
    expect(b.state.entryOfType('OUT'), isNull);
    expect(b.state.amountTotalText, '40.00');
    await b.close();
  });

  test('the checks, in order and word for word', () async {
    byRti.complete((items: <Map<String, dynamic>>[], entriesTotal: null));
    final b = open();
    await settle();
    Future<String?> msg(String amount, {String type = 'IN', String truck = '72', String driver = '5'}) async {
      b.add(LeviFormPatched((f) => f.copyWith(amount: amount, entryType: type, truckRefId: truck, driverRefId: driver)));
      b.add(const LeviSaveRequested());
      await settle();
      return b.state.message;
    }

    expect(await msg('1', type: ''), 'Choose IN or OUT');
    expect(await msg('1', truck: ''), 'Select a truck');
    expect(await msg('1', driver: ''), 'Select a driver');
    expect(await msg(' '), 'Enter an amount');
    expect(await msg('abc'), 'Enter an amount');
    expect(await msg('-1'), 'Amount must not be negative');
    expect(saved, isEmpty);
    await b.close();
  });

  test('without a saved RTI: "Save the RTI first"', () async {
    final b = LeviBloc(api: api, attachments: files, context: const LeviContext(rtiId: 0))..add(const LeviOpened());
    await settle();
    b.add(LeviFormPatched((f) => f.copyWith(amount: '1', truckRefId: '1', driverRefId: '1')));
    b.add(const LeviSaveRequested());
    await settle();
    expect(b.state.message, 'Save the RTI first');
    await b.close();
  });

  test('delete (after the confirm) says "levi entry deleted" and starts a new entry of that leg', () async {
    byRti.complete((items: [leviRow()], entriesTotal: 40.0));
    when(() => api.delete(900)).thenAnswer((_) async {});
    final b = open();
    await settle();
    b.add(LeviDeleteRequested(b.state.items.single));
    await settle();
    expect(b.state.message, 'levi entry deleted');
    expect([b.state.entryId, b.state.form.entryType, b.state.form.amount], [0, 'IN', '']);
    await b.close();
  });

  test('a failed save without a server message → "Could not save the levi entry"', () async {
    byRti.complete((items: <Map<String, dynamic>>[], entriesTotal: null));
    when(() => api.save(any())).thenThrow(const ApiFailure(''));
    final b = open();
    await settle();
    b.add(LeviFormPatched((f) => f.copyWith(amount: '5')));
    b.add(const LeviSaveRequested());
    await settle();
    expect(b.state.message, 'Could not save the levi entry');
    expect(b.state.busy, isFalse);
    await b.close();
  });
}
