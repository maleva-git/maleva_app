

import 'dart:ui';

import 'package:equatable/equatable.dart';

import '../../../../../../core/theme/tokens.dart';

enum UnReleaseStatus { initial, loading, success, failure }

class UnReleaseState extends Equatable {
  const UnReleaseState({
    this.status = UnReleaseStatus.initial,
    this.unReleaseList = const [],
    this.errorMessage = '',
    this.type = 0,
  });

  final UnReleaseStatus status;
  final List<Map<String, dynamic>> unReleaseList;
  final String errorMessage;
  final int type;

  // ── Derived helpers ───────────────────────────────────────

  bool get isLoading => status == UnReleaseStatus.loading;
  bool get hasData =>
      status == UnReleaseStatus.success && unReleaseList.isNotEmpty;
  bool get isEmpty =>
      status == UnReleaseStatus.success && unReleaseList.isEmpty;

  /// Alternating row tint using the app palette.
  /// Even rows → white, Odd rows → soft blue-50 tint.
  Color cardColor(int index) =>
      index.isEven ? AppTokens.surfaceCard : AppTokens.transBlueBg;

  UnReleaseState copyWith({
    UnReleaseStatus? status,
    List<Map<String, dynamic>>? unReleaseList,
    String? errorMessage,
    int? type,
  }) {
    return UnReleaseState(
      status: status ?? this.status,
      unReleaseList: unReleaseList ?? this.unReleaseList,
      errorMessage: errorMessage ?? this.errorMessage,
      type: type ?? this.type,
    );
  }

  @override
  List<Object?> get props => [status, unReleaseList, errorMessage, type];
}