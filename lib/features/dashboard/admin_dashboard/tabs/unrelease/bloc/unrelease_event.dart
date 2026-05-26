

import 'package:equatable/equatable.dart';

abstract class UnReleaseEvent extends Equatable {
  const UnReleaseEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered on page load or tab switch (type 0 = K1/K2/K3, type 1 = K8)
class UnReleaseDataRequested extends UnReleaseEvent {
  final int type;

  const UnReleaseDataRequested({this.type = 0});

  @override
  List<Object?> get props => [type];
}

/// Pull-to-refresh
class UnReleaseRefreshRequested extends UnReleaseEvent {
  final int type;

  const UnReleaseRefreshRequested({this.type = 0});

  @override
  List<Object?> get props => [type];
}