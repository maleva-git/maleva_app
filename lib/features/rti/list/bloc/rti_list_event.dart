part of 'rti_list_bloc.dart';

sealed class RtiListEvent extends Equatable {
  const RtiListEvent();

  @override
  List<Object?> get props => [];
}

/// The page opened: load the pickers and the first-open list (My RTIs off).
final class RtiListStarted extends RtiListEvent {
  const RtiListStarted();
}

/// The filter form changed (nothing loads until [RtiListApplied]).
final class RtiListDraftChanged extends RtiListEvent {
  const RtiListDraftChanged(this.filter);

  final RtiListFilter filter;

  @override
  List<Object?> get props => [filter];
}

/// View (or Enter in RTI No): load the draft filters.
final class RtiListApplied extends RtiListEvent {
  const RtiListApplied();
}

/// A chip changed one filter: apply it straight away.
final class RtiListQuickFilterChanged extends RtiListEvent {
  const RtiListQuickFilterChanged(this.filter);

  final RtiListFilter filter;

  @override
  List<Object?> get props => [filter];
}

/// Clear: today, My RTIs on, then load (`handleClear`).
final class RtiListCleared extends RtiListEvent {
  const RtiListCleared();
}

/// Retry after a slow or failed load: the applied filters again.
final class RtiListRetried extends RtiListEvent {
  const RtiListRetried();
}

/// "Not Salary Entered RTI": a client filter, applied at once (no reload), as React.
final class RtiListNotSalaryToggled extends RtiListEvent {
  const RtiListNotSalaryToggled(this.value);

  final bool value;

  @override
  List<Object?> get props => [value];
}

/// The search bar: finds RTI or job numbers among the loaded RTIs only (client side).
final class RtiListFindChanged extends RtiListEvent {
  const RtiListFindChanged(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}

/// A row picked for the preview; the same row again closes it (React's `handleRowClick`).
final class RtiListRowSelected extends RtiListEvent {
  const RtiListRowSelected(this.id, {this.toggle = true});

  final int id;
  final bool toggle;

  @override
  List<Object?> get props => [id, toggle];
}

final class RtiListPreviewClosed extends RtiListEvent {
  const RtiListPreviewClosed();
}

/// Send the RTI to its truck's WhatsApp group (the page has asked first).
final class RtiShareRequested extends RtiListEvent {
  const RtiShareRequested(this.row);

  final RtiListRow row;

  @override
  List<Object?> get props => [row];
}

final class RtiReportRequested extends RtiListEvent {
  const RtiReportRequested(this.row);

  final RtiListRow row;

  @override
  List<Object?> get props => [row];
}

/// The 30 s timer of load [request] ran out.
final class _RtiListSlow extends RtiListEvent {
  const _RtiListSlow(this.request);

  final int request;

  @override
  List<Object?> get props => [request];
}
