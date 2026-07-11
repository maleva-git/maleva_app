

import 'package:equatable/equatable.dart';

abstract class FWBreakSealEvent extends Equatable {
  const FWBreakSealEvent();

  @override
  List<Object?> get props => [];
}

// ─── Lifecycle ────────────────────────────────────────────────────────────────

/// Fired once when the screen initialises – loads the job-number list.
class FWBreakSealInitialised extends FWBreakSealEvent {
  const FWBreakSealInitialised();
}

// ─── Tab ─────────────────────────────────────────────────────────────────────

class FWBreakSealTabChanged extends FWBreakSealEvent {
  final int index;
  const FWBreakSealTabChanged(this.index);

  @override
  List<Object?> get props => [index];
}

// ─── SMK auto-complete ────────────────────────────────────────────────────────

/// User typed in one of the SMK text fields.
class FWBreakSealSmkChanged extends FWBreakSealEvent {
  /// 1 | 2 | 3
  final int smkType;
  final String value;
  const FWBreakSealSmkChanged({required this.smkType, required this.value});

  @override
  List<Object?> get props => [smkType, value];
}

/// User tapped a suggestion from the overlay.
class FWBreakSealSmkSelected extends FWBreakSealEvent {
  final int smkType;
  final Map<String, dynamic> prediction;
  const FWBreakSealSmkSelected(
      {required this.smkType, required this.prediction});

  @override
  List<Object?> get props => [smkType, prediction];
}

/// Close the overlay (back-press, focus lost, etc.)
class FWBreakSealOverlayClosed extends FWBreakSealEvent {
  const FWBreakSealOverlayClosed();
}

// ─── Employee search ──────────────────────────────────────────────────────────

/// User tapped the search / clear icon on a "Break Seal By" field.
class FWBreakSealEmpSearchTapped extends FWBreakSealEvent {
  /// 1 | 2 | 3
  final int smkType;
  final bool isClear;
  const FWBreakSealEmpSearchTapped(
      {required this.smkType, required this.isClear});

  @override
  List<Object?> get props => [smkType, isClear];
}

/// Returned from the Employee picker screen.
class FWBreakSealEmpSelected extends FWBreakSealEvent {
  final int smkType;
  final int empId;
  final String empName;
  const FWBreakSealEmpSelected(
      {required this.smkType, required this.empId, required this.empName});

  @override
  List<Object?> get props => [smkType, empId, empName];
}

// ─── ExRef text changes ───────────────────────────────────────────────────────

class FWBreakSealExRefChanged extends FWBreakSealEvent {
  final int smkType;
  final String value;
  const FWBreakSealExRefChanged({required this.smkType, required this.value});

  @override
  List<Object?> get props => [smkType, value];
}

// ─── Submit ───────────────────────────────────────────────────────────────────

class FWBreakSealUpdateSubmitted extends FWBreakSealEvent {
  const FWBreakSealUpdateSubmitted();
}

// ─── Reset ────────────────────────────────────────────────────────────────────

class FWBreakSealCleared extends FWBreakSealEvent {
  const FWBreakSealCleared();
}