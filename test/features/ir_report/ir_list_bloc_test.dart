import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/network/legacy_api_exception.dart';
import 'package:maleva/features/ir_report/domain/entities/ir_filter.dart';
import 'package:maleva/features/ir_report/domain/entities/ir_list_result.dart';
import 'package:maleva/features/ir_report/domain/entities/ir_lookup.dart';
import 'package:maleva/features/ir_report/domain/entities/ir_report.dart';
import 'package:maleva/features/ir_report/domain/repositories/ir_repository.dart';
import 'package:maleva/features/ir_report/presentation/ir_view_status.dart';
import 'package:maleva/features/ir_report/presentation/list/bloc/ir_list_bloc.dart';
import 'package:mocktail/mocktail.dart';

class _MockIrRepository extends Mock implements IrRepository {}

void main() {
  late _MockIrRepository repository;

  final filter = IrFilter(fromDate: DateTime(2026, 9, 1), toDate: DateTime(2026, 9, 14));
  final accident = IrReport(
    id: 1,
    irDate: DateTime(2026, 9, 10, 8),
    statusId: 1,
    description: 'Truck accident at Westport',
    departmentId: 1000,
    departmentName: 'TRANSPORTATION',
    actualAmount: 500,
  );
  final compound = IrReport(
    id: 2,
    irDate: DateTime(2026, 9, 12, 15),
    statusId: 1,
    description: 'Police compound',
    departmentId: 1000,
    departmentName: 'TRANSPORTATION',
    actualAmount: 300,
  );

  setUpAll(() => registerFallbackValue(const IrFilter()));

  setUp(() {
    repository = _MockIrRepository();
    when(() => repository.statuses())
        .thenAnswer((_) async => const [IrStatus(id: 1, code: 'OPEN', name: 'Open')]);
    when(() => repository.search(any())).thenAnswer(
      (_) async => IrListResult(items: [accident, compound], totalAmount: 800, count: 2),
    );
  });

  IrListBloc buildBloc() =>
      IrListBloc(repository: repository, initialFilter: filter, searchDebounce: Duration.zero);

  IrListState loaded() => IrListState(
        filter: filter,
        status: IrViewStatus.success,
        items: [accident, compound],
        totalAmount: 800,
      );

  blocTest<IrListBloc, IrListState>(
    'opening the list loads the statuses and the reports for the filter',
    build: buildBloc,
    act: (bloc) => bloc.add(const IrListStarted()),
    wait: const Duration(milliseconds: 20),
    verify: (bloc) {
      expect(bloc.state.status, IrViewStatus.success);
      expect(bloc.state.items, [accident, compound]);
      expect(bloc.state.totalAmount, 800);
      expect(bloc.state.statuses.single.code, 'OPEN');
      verify(() => repository.search(filter)).called(1);
    },
  );

  blocTest<IrListBloc, IrListState>(
    'a failed search shows the server message',
    setUp: () => when(() => repository.search(any()))
        .thenThrow(const LegacyApiException('Comid is required', statusCode: 400)),
    build: buildBloc,
    act: (bloc) => bloc.add(const IrListRefreshed()),
    wait: const Duration(milliseconds: 20),
    verify: (bloc) {
      expect(bloc.state.status, IrViewStatus.failure);
      expect(bloc.state.errorMessage, 'Comid is required');
    },
  );

  blocTest<IrListBloc, IrListState>(
    'changing a filter searches again with the new filter',
    build: buildBloc,
    seed: loaded,
    act: (bloc) => bloc.add(IrListFilterChanged(filter.copyWith(openOnly: true))),
    wait: const Duration(milliseconds: 20),
    verify: (bloc) {
      expect(bloc.state.filter.openOnly, isTrue);
      verify(() => repository.search(filter.copyWith(openOnly: true))).called(1);
    },
  );

  blocTest<IrListBloc, IrListState>(
    'the same filter again does not search again',
    build: buildBloc,
    seed: loaded,
    act: (bloc) => bloc.add(IrListFilterChanged(filter)),
    wait: const Duration(milliseconds: 20),
    expect: () => <IrListState>[],
    verify: (_) => verifyNever(() => repository.search(any())),
  );

  blocTest<IrListBloc, IrListState>(
    'typing in the search box searches with the trimmed text',
    build: buildBloc,
    seed: loaded,
    act: (bloc) => bloc.add(const IrListSearchChanged('  westport ')),
    wait: const Duration(milliseconds: 50),
    verify: (bloc) {
      expect(bloc.state.filter.search, 'westport');
      verify(() => repository.search(filter.copyWith(search: 'westport'))).called(1);
    },
  );

  blocTest<IrListBloc, IrListState>(
    'deleting removes the row and its amount from the total',
    setUp: () => when(() => repository.delete(1)).thenAnswer((_) async {}),
    build: buildBloc,
    seed: loaded,
    act: (bloc) => bloc.add(IrListDeleteRequested(accident)),
    verify: (bloc) {
      expect(bloc.state.items, [compound]);
      expect(bloc.state.totalAmount, 300);
      expect(bloc.state.deletingId, isNull);
      expect(bloc.state.message?.isError, isFalse);
    },
  );

  blocTest<IrListBloc, IrListState>(
    'a failed delete keeps the row and says why',
    setUp: () => when(() => repository.delete(1))
        .thenThrow(const LegacyApiException('IR 1 was not found', statusCode: 404)),
    build: buildBloc,
    seed: loaded,
    act: (bloc) => bloc.add(IrListDeleteRequested(accident)),
    verify: (bloc) {
      expect(bloc.state.items, [accident, compound]);
      expect(bloc.state.message?.text, 'IR 1 was not found');
      expect(bloc.state.message?.isError, isTrue);
    },
  );
}
