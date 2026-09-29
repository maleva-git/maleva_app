part of 'ir_list_bloc.dart';

sealed class IrListEvent extends Equatable {
  const IrListEvent();

  @override
  List<Object?> get props => [];
}

/// The page opened.
final class IrListStarted extends IrListEvent {
  const IrListStarted();
}

/// Pull-to-refresh, the refresh button, or a save on the form.
final class IrListRefreshed extends IrListEvent {
  const IrListRefreshed();
}

final class IrListFilterChanged extends IrListEvent {
  const IrListFilterChanged(this.filter);

  final IrFilter filter;

  @override
  List<Object?> get props => [filter];
}

/// Every keystroke in the search box; debounced by the bloc.
final class IrListSearchChanged extends IrListEvent {
  const IrListSearchChanged(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}

/// Sent after the user confirmed.
final class IrListDeleteRequested extends IrListEvent {
  const IrListDeleteRequested(this.report);

  final IrReport report;

  @override
  List<Object?> get props => [report];
}

/// Internal. Every reload goes through this one handler, which is restartable:
/// a newer request cancels an older one whichever control started it, so a
/// slow response for an old filter can never replace the list for a new one.
final class _IrListFetchRequested extends IrListEvent {
  const _IrListFetchRequested();
}
