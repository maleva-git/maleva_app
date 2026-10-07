import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_api.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_models.dart';

class MailboxListState {
  const MailboxListState({this.list, this.loading = false, this.error, this.notice});

  final MailboxList? list;
  final bool loading;

  /// Why the list could not be loaded (the server's message), when there is no list to show.
  final String? error;

  /// A one-off message for a snack bar ("Checking all mailboxes…", a 409 reason).
  final String? notice;

  MailboxListState copyWith({MailboxList? list, bool? loading, String? error, String? notice}) =>
      MailboxListState(list: list ?? this.list, loading: loading ?? this.loading, error: error, notice: notice);
}

/// The Mailbox Monitor list. The app has no live push, so it reloads every [every] while the tab
/// is open (and on pull-to-refresh); "Check now" asks the server to check every mailbox.
class MailboxListCubit extends Cubit<MailboxListState> {
  MailboxListCubit(this._api, {Duration every = const Duration(seconds: 60)})
      : _every = every,
        super(const MailboxListState(loading: true));

  final MailMonitorApi _api;
  final Duration _every;

  /// The API this list uses, so pages opened from it share it.
  MailMonitorApi get api => _api;
  Timer? _timer;

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final list = await _api.mailboxes();
      if (!isClosed) emit(MailboxListState(list: list));
    } catch (e) {
      if (!isClosed) emit(MailboxListState(list: state.list, error: state.list == null ? '$e' : null, notice: state.list == null ? null : '$e'));
    }
  }

  void startAutoRefresh() {
    _timer?.cancel();
    _timer = Timer.periodic(_every, (_) => load());
  }

  Future<void> checkNow() async {
    try {
      await _api.checkNow();
      if (!isClosed) emit(state.copyWith(notice: 'Checking all mailboxes. The list updates in a moment.'));
      Timer(const Duration(seconds: 20), () {
        if (!isClosed) load();
      });
    } catch (e) {
      if (!isClosed) emit(state.copyWith(notice: '$e'));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
