import 'package:equatable/equatable.dart';

enum HomeDashboardStatus { initial, loading, ready, failure }

class HomeDashboardState extends Equatable {
  const HomeDashboardState({
    this.status       = HomeDashboardStatus.initial,
    this.errorMessage = '',
    this.canUpdate    = false, // true → UI shows the store update dialog
  });

  final HomeDashboardStatus status;
  final String errorMessage;

  /// Set to true when AppVersionUpdate.checkForUpdates() says an update
  /// is available. The UI listener reads this and shows the alert dialog
  /// (which needs context — so it cannot live in the BLoC).
  final bool canUpdate;

  // ── Derived ───────────────────────────────────────────────
  bool get isLoading => status == HomeDashboardStatus.loading;
  bool get isReady   => status == HomeDashboardStatus.ready;

  HomeDashboardState copyWith({
    HomeDashboardStatus? status,
    String? errorMessage,
    bool? canUpdate,
  }) {
    return HomeDashboardState(
      status:       status       ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      canUpdate:    canUpdate    ?? this.canUpdate,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, canUpdate];
}