


import 'package:equatable/equatable.dart';

abstract class UnReleaseSMKEvent extends Equatable {
  const UnReleaseSMKEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load on page entry
class UnReleaseSMKDataRequested extends UnReleaseSMKEvent {
  const UnReleaseSMKDataRequested();
}

/// Pull-to-refresh
class UnReleaseSMKRefreshRequested extends UnReleaseSMKEvent {
  const UnReleaseSMKRefreshRequested();
}