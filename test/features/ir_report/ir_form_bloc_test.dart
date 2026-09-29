import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/network/legacy_api_exception.dart';
import 'package:maleva/features/ir_report/domain/entities/ir_draft.dart';
import 'package:maleva/features/ir_report/domain/entities/ir_lookup.dart';
import 'package:maleva/features/ir_report/domain/entities/ir_report.dart';
import 'package:maleva/features/ir_report/domain/repositories/ir_repository.dart';
import 'package:maleva/features/ir_report/presentation/form/bloc/ir_form_bloc.dart';
import 'package:maleva/features/ir_report/presentation/ir_view_status.dart';
import 'package:mocktail/mocktail.dart';

class _MockIrRepository extends Mock implements IrRepository {}

void main() {
  late _MockIrRepository repository;

  final now = DateTime(2026, 9, 14, 9, 0);
  const underReview = IrStatus(id: 2, code: 'UNDER_REVIEW', name: 'Under Review');
  const open = IrStatus(id: 1, code: 'OPEN', name: 'Open');
  const transportation = LookupOption(id: 1000, name: 'TRANSPORTATION');
  const lookups = IrLookups(
    // OPEN deliberately not first: the default is chosen by code, not position.
    statuses: [underReview, open],
    departments: [transportation],
  );

  final savedReport = IrReport(
    id: 7,
    irDate: DateTime(2026, 9, 10, 8, 15),
    statusId: 2,
    description: 'Spare dropped into the sea',
    departmentId: 1000,
    departmentName: 'TRANSPORTATION',
  );

  final completeDraft = IrDraft(
    irDate: now,
    status: open,
    department: transportation,
    description: 'Spare dropped into the sea',
  );

  setUpAll(() => registerFallbackValue(const IrDraft()));

  setUp(() {
    repository = _MockIrRepository();
    when(() => repository.lookups()).thenAnswer((_) async => lookups);
  });

  IrFormBloc buildBloc() => IrFormBloc(repository: repository, clock: () => now);

  IrFormState ready(IrDraft draft) =>
      IrFormState(loadStatus: IrViewStatus.success, lookups: lookups, draft: draft);

  blocTest<IrFormBloc, IrFormState>(
    'a new report starts now, on the OPEN status',
    build: buildBloc,
    act: (bloc) => bloc.add(const IrFormStarted()),
    verify: (bloc) {
      expect(bloc.state.loadStatus, IrViewStatus.success);
      expect(bloc.state.draft.irDate, now);
      expect(bloc.state.draft.status, open);
      expect(bloc.state.isNew, isTrue);
      verifyNever(() => repository.getById(any()));
    },
  );

  blocTest<IrFormBloc, IrFormState>(
    'editing loads the saved report into the form',
    setUp: () => when(() => repository.getById(7)).thenAnswer((_) async => savedReport),
    build: buildBloc,
    act: (bloc) => bloc.add(const IrFormStarted(reportId: 7)),
    verify: (bloc) {
      expect(bloc.state.draft.id, 7);
      expect(bloc.state.draft.status, underReview);
      expect(bloc.state.draft.description, 'Spare dropped into the sea');
    },
  );

  blocTest<IrFormBloc, IrFormState>(
    'the form fails to open when the lists cannot be loaded',
    setUp: () => when(() => repository.lookups())
        .thenThrow(const LegacyApiException('No internet connection. Check your network.')),
    build: buildBloc,
    act: (bloc) => bloc.add(const IrFormStarted()),
    verify: (bloc) {
      expect(bloc.state.loadStatus, IrViewStatus.failure);
      expect(bloc.state.loadError, 'No internet connection. Check your network.');
    },
  );

  blocTest<IrFormBloc, IrFormState>(
    'typing updates the draft without showing errors yet',
    build: buildBloc,
    seed: () => ready(IrDraft(irDate: now)),
    act: (bloc) => bloc.add(const IrFormTextChanged(IrField.description, 'Truck accident')),
    verify: (bloc) {
      expect(bloc.state.draft.description, 'Truck accident');
      expect(bloc.state.errors[IrField.status], isNotNull);
      expect(bloc.state.errorFor(IrField.status), isNull);
    },
  );

  blocTest<IrFormBloc, IrFormState>(
    'saving an incomplete form shows the errors and sends nothing',
    build: buildBloc,
    seed: () => ready(IrDraft(irDate: now)),
    act: (bloc) => bloc.add(const IrFormSubmitted()),
    verify: (bloc) {
      expect(bloc.state.showErrors, isTrue);
      expect(bloc.state.errorFor(IrField.status), isNotNull);
      expect(bloc.state.errorFor(IrField.department), isNotNull);
      expect(bloc.state.errorFor(IrField.description), isNotNull);
      expect(bloc.state.message?.isError, isTrue);
      verifyNever(() => repository.save(any()));
    },
  );

  blocTest<IrFormBloc, IrFormState>(
    'saving a complete form sends the draft and finishes',
    setUp: () => when(() => repository.save(any())).thenAnswer((_) async => savedReport),
    build: buildBloc,
    seed: () => ready(completeDraft),
    act: (bloc) => bloc.add(const IrFormSubmitted()),
    expect: () => [
      isA<IrFormState>().having((s) => s.submitStatus, 'submitStatus', IrSubmitStatus.submitting),
      isA<IrFormState>()
          .having((s) => s.submitStatus, 'submitStatus', IrSubmitStatus.success)
          .having((s) => s.saved, 'saved', savedReport),
    ],
    verify: (_) => verify(() => repository.save(completeDraft)).called(1),
  );

  blocTest<IrFormBloc, IrFormState>(
    'a rejected save keeps the form and shows the server reason',
    setUp: () => when(() => repository.save(any())).thenThrow(
      const LegacyApiException('Status 1 was not found for this company', statusCode: 400),
    ),
    build: buildBloc,
    seed: () => ready(completeDraft),
    act: (bloc) => bloc.add(const IrFormSubmitted()),
    verify: (bloc) {
      expect(bloc.state.submitStatus, IrSubmitStatus.failure);
      expect(bloc.state.draft, completeDraft);
      expect(bloc.state.message?.text, 'Status 1 was not found for this company');
    },
  );
}
