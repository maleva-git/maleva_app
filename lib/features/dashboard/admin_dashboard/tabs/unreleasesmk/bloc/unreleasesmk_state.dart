




import 'dart:ui';

import 'package:equatable/equatable.dart';

import '../../../../../../core/theme/palette.dart';
import '../../../../../../core/theme/tokens.dart';

enum UnReleaseSMKStatus { initial, loading, success, failure }

class UnReleaseSMKState extends Equatable {
  const UnReleaseSMKState({
    this.status = UnReleaseSMKStatus.initial,
    this.unReleaseList = const [],
    this.errorMessage = '',
  });

  final UnReleaseSMKStatus status;
  final List<Map<String, dynamic>> unReleaseList;
  final String errorMessage;

  // ── Derived helpers ───────────────────────────────────────

  bool get isLoading => status == UnReleaseSMKStatus.loading;
  bool get hasData =>
      status == UnReleaseSMKStatus.success && unReleaseList.isNotEmpty;
  bool get isEmpty =>
      status == UnReleaseSMKStatus.success && unReleaseList.isEmpty;

  /// Alternating row tint: even → white, odd → blue-50
  Color cardColor(int index) =>
      index.isEven ? AppTokens.surfaceCard : AppTokens.transBlueBg;

  /// Colour-code DayCount badge: >30 red, 15–30 amber, <15 green
  Color dayCountColor(int days) {
    if (days > 30) return Palette.redError;
    if (days >= 15) return Palette.amber;
    return Palette.greenEco;
  }

  UnReleaseSMKState copyWith({
    UnReleaseSMKStatus? status,
    List<Map<String, dynamic>>? unReleaseList,
    String? errorMessage,
  }) {
    return UnReleaseSMKState(
      status: status ?? this.status,
      unReleaseList: unReleaseList ?? this.unReleaseList,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, unReleaseList, errorMessage];
}