import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/dashboard/common_tabs/transport/bloc/transport_bloc.dart';
import 'package:maleva/features/dashboard/common_tabs/transport/bloc/transport_event.dart';
import 'package:maleva/features/dashboard/common_tabs/transport/bloc/transport_state.dart';
import 'package:maleva/features/dashboard/common_tabs/transport/data/transport_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockTransportRepository extends Mock implements TransportRepository {}

void main() {
  blocTest<TransportBloc, TransportState>(
    'an employee long-press opens the sale order',
    build: () => TransportBloc(repository: MockTransportRepository(), isDriver: () => false),
    act: (bloc) => bloc.add(const LongPressTransportItemEvent(id: 40)),
    expect: () => [isA<TransportNavigateToEditState>().having((s) => s.id, 'id', 40)],
  );

  blocTest<TransportBloc, TransportState>(
    'a driver long-press does nothing: Sale Order Add is an office screen',
    build: () => TransportBloc(repository: MockTransportRepository(), isDriver: () => true),
    act: (bloc) => bloc.add(const LongPressTransportItemEvent(id: 40)),
    expect: () => <TransportState>[],
  );
}
