import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:maleva/features/truck_location/domain/entities/truck_location_week.dart';
import 'package:maleva/features/truck_location/domain/repositories/truck_location_repository.dart';
import 'package:maleva/features/truck_location/domain/truck_location_rules.dart' as rules;
import 'package:maleva/features/truck_location/presentation/bloc/truck_location_bloc.dart';
import 'package:maleva/features/truck_location/presentation/truck_location_view_status.dart';

class _MockRepository extends Mock implements TruckLocationRepository {}

void main() {
  // A Sunday, so defaultPlanningDay lands on Monday the 21st.
  const today = '2026-09-20';
  final days = rules.weekDays(today);

  TruckLocationRow row(int id, String name, {List<String>? locations, bool done = false}) =>
      TruckLocationRow(
        truckRefId: id,
        truckName: name,
        truckNumber: name,
        truckType: '40FT',
        truckStatus: 'ACTIVE',
        locations: locations ?? ['Port Klang', '', '', '', '', '', ''],
        lastKnownLocation: 'Yard',
        done: done,
      );

  final week = TruckLocationWeek(
    weekStart: today,
    days: days,
    rows: [row(7, 'JSD 4521'), row(8, 'WXY 1000')],
  );

  late _MockRepository repository;

  setUp(() {
    repository = _MockRepository();
    when(() => repository.week(any())).thenAnswer((_) async => week);
  });

  TruckLocationBloc build() =>
      TruckLocationBloc(repository: repository, today: () => today);

  group('load', () {
    blocTest<TruckLocationBloc, TruckLocationState>(
      'loads the week and opens on tomorrow',
      build: build,
      act: (bloc) => bloc.add(const TruckLocationStarted()),
      expect: () => [
        isA<TruckLocationState>()
            .having((s) => s.status, 'status', TruckLocationStatus.loading),
        isA<TruckLocationState>()
            .having((s) => s.status, 'status', TruckLocationStatus.success)
            .having((s) => s.week, 'week', week)
            .having((s) => s.selectedDay, 'selectedDay', '2026-09-21'),
      ],
    );

    blocTest<TruckLocationBloc, TruckLocationState>(
      'a failed load keeps the server message for the error screen',
      build: build,
      setUp: () => when(() => repository.week(any()))
          .thenThrow(Exception('Company is required')),
      act: (bloc) => bloc.add(const TruckLocationStarted()),
      expect: () => [
        isA<TruckLocationState>()
            .having((s) => s.status, 'status', TruckLocationStatus.loading),
        isA<TruckLocationState>()
            .having((s) => s.status, 'status', TruckLocationStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', 'Company is required'),
      ],
    );
  });

  group('save all', () {
    blocTest<TruckLocationBloc, TruckLocationState>(
      'sends only the cells that differ from what is saved',
      build: build,
      setUp: () {
        when(() => repository.saveWeek(
              weekStart: any(named: 'weekStart'),
              cells: any(named: 'cells'),
              doneTicks: any(named: 'doneTicks'),
            )).thenAnswer((_) async => week);
      },
      act: (bloc) async {
        bloc.add(const TruckLocationStarted());
        await Future<void>.delayed(Duration.zero);
        bloc
          // typed back to the saved value: nothing to send
          ..add(TruckLocationCellEdited(
              truckRefId: 7, planDate: days[0], value: 'Port Klang '))
          // a real change
          ..add(TruckLocationCellEdited(
              truckRefId: 7, planDate: days[1], value: ' Senai '))
          ..add(const TruckLocationSaveAllPressed());
      },
      verify: (_) {
        final captured = verify(() => repository.saveWeek(
              weekStart: captureAny(named: 'weekStart'),
              cells: captureAny(named: 'cells'),
              doneTicks: captureAny(named: 'doneTicks'),
            )).captured;
        expect(captured[0], today);
        expect(captured[1], [
          TruckLocationCellChange(
              truckRefId: 7, planDate: days[1], location: 'Senai'),
        ]);
        expect(captured[2], isEmpty);
      },
    );

    blocTest<TruckLocationBloc, TruckLocationState>(
      'sends a changed Done tick and drops it once saved',
      build: build,
      setUp: () {
        final savedWeek = TruckLocationWeek(
          weekStart: today,
          days: days,
          rows: [row(7, 'JSD 4521', done: true), row(8, 'WXY 1000')],
        );
        when(() => repository.saveWeek(
              weekStart: any(named: 'weekStart'),
              cells: any(named: 'cells'),
              doneTicks: any(named: 'doneTicks'),
            )).thenAnswer((_) async => savedWeek);
      },
      act: (bloc) async {
        bloc.add(const TruckLocationStarted());
        await Future<void>.delayed(Duration.zero);
        bloc
          ..add(const TruckLocationDoneToggled(truckRefId: 7, done: true))
          ..add(const TruckLocationSaveAllPressed());
      },
      verify: (bloc) {
        final captured = verify(() => repository.saveWeek(
              weekStart: captureAny(named: 'weekStart'),
              cells: captureAny(named: 'cells'),
              doneTicks: captureAny(named: 'doneTicks'),
            )).captured;
        expect(captured[1], isEmpty);
        expect(captured[2],
            [const TruckLocationDoneTick(truckRefId: 7, done: true)]);
        // The saved week now says done, so the unsaved tick is gone.
        expect(bloc.state.doneEdits, isEmpty);
        expect(bloc.state.hasUnsaved, isFalse);
      },
    );

    blocTest<TruckLocationBloc, TruckLocationState>(
      'a failed save keeps the edits and shows the server message',
      build: build,
      setUp: () {
        when(() => repository.saveWeek(
              weekStart: any(named: 'weekStart'),
              cells: any(named: 'cells'),
              doneTicks: any(named: 'doneTicks'),
            )).thenThrow(
            Exception('Truck 7 is not on the truck location board'));
      },
      act: (bloc) async {
        bloc.add(const TruckLocationStarted());
        await Future<void>.delayed(Duration.zero);
        bloc
          ..add(TruckLocationCellEdited(
              truckRefId: 7, planDate: days[1], value: 'Senai'))
          ..add(const TruckLocationSaveAllPressed());
      },
      verify: (bloc) {
        expect(bloc.state.saving, isFalse);
        expect(bloc.state.edits, {'7|${days[1]}': 'Senai'});
        expect(bloc.state.message?.text,
            'Truck 7 is not on the truck location board');
        expect(bloc.state.message?.isError, isTrue);
      },
    );
  });

  group('reorder', () {
    blocTest<TruckLocationBloc, TruckLocationState>(
      'saves the whole board order at once',
      build: build,
      setUp: () {
        when(() => repository.saveOrder(any())).thenAnswer((_) async {});
      },
      act: (bloc) async {
        bloc.add(const TruckLocationStarted());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const TruckLocationRowMoved(movedId: 8, targetId: 7));
      },
      verify: (bloc) {
        verify(() => repository.saveOrder([8, 7])).called(1);
        expect(bloc.state.rows.map((r) => r.truckRefId).toList(), [8, 7]);
      },
    );

    blocTest<TruckLocationBloc, TruckLocationState>(
      'puts the row back when the order save fails',
      build: build,
      setUp: () {
        when(() => repository.saveOrder(any()))
            .thenThrow(Exception('Order save failed'));
      },
      act: (bloc) async {
        bloc.add(const TruckLocationStarted());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const TruckLocationRowMoved(movedId: 8, targetId: 7));
      },
      verify: (bloc) {
        expect(bloc.state.rows.map((r) => r.truckRefId).toList(), [7, 8]);
        expect(bloc.state.savingOrder, isFalse);
        expect(bloc.state.message?.isError, isTrue);
      },
    );
  });

  group('refresh', () {
    blocTest<TruckLocationBloc, TruckLocationState>(
      'reloads the week and keeps unsaved edits',
      build: build,
      act: (bloc) async {
        bloc.add(const TruckLocationStarted());
        await Future<void>.delayed(Duration.zero);
        bloc
          ..add(TruckLocationCellEdited(
              truckRefId: 7, planDate: days[1], value: 'Senai'))
          ..add(const TruckLocationRefreshed());
      },
      verify: (bloc) {
        // Loaded twice: once at start, once on refresh.
        verify(() => repository.week(any())).called(2);
        expect(bloc.state.edits, {'7|${days[1]}': 'Senai'});
        expect(bloc.state.week, week);
      },
    );

    blocTest<TruckLocationBloc, TruckLocationState>(
      'changing week forgets the edits',
      build: build,
      act: (bloc) async {
        bloc.add(const TruckLocationStarted());
        await Future<void>.delayed(Duration.zero);
        bloc
          ..add(TruckLocationCellEdited(
              truckRefId: 7, planDate: days[1], value: 'Senai'))
          ..add(const TruckLocationWeekShifted(7));
      },
      verify: (bloc) {
        expect(bloc.state.edits, isEmpty);
      },
    );
  });

  group('fill day from previous', () {
    blocTest<TruckLocationBloc, TruckLocationState>(
      'copies the hint into every empty cell of the selected day, unsaved',
      build: build,
      act: (bloc) async {
        bloc.add(const TruckLocationStarted());
        await Future<void>.delayed(Duration.zero);
        // Selected day is Monday; both trucks have Sunday = Port Klang.
        bloc.add(const TruckLocationFillDayPressed());
      },
      verify: (bloc) {
        expect(bloc.state.edits, {
          '7|${days[1]}': 'Port Klang',
          '8|${days[1]}': 'Port Klang',
        });
        // Unsaved, not saved: nothing has touched the repository.
        verifyNever(() => repository.saveWeek(
              weekStart: any(named: 'weekStart'),
              cells: any(named: 'cells'),
              doneTicks: any(named: 'doneTicks'),
            ));
      },
    );
  });
}
