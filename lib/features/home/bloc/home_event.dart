import 'package:equatable/equatable.dart';

abstract class HomeDashboardEvent extends Equatable {
  const HomeDashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Fired once on page init — runs store version check then marks ready
class HomeDashboardStartupRequested extends HomeDashboardEvent {
  const HomeDashboardStartupRequested();
}

/// User confirmed exit from back-press dialog
class HomeDashboardExitConfirmed extends HomeDashboardEvent {
  const HomeDashboardExitConfirmed();
}