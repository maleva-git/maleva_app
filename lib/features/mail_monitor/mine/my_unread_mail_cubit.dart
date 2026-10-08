import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_api.dart';
import 'package:maleva/core/mailmonitor/my_unread_models.dart';

class MyUnreadMailState {
  const MyUnreadMailState({this.mail, this.loading = false, this.error});

  final MyUnreadMail? mail;
  final bool loading;

  /// The server's message when nothing could be loaded.
  final String? error;
}

/// A "you have unread mail" push arrived: the open bar and screen reload at once instead of waiting.
class MyUnreadMailSignals {
  MyUnreadMailSignals._();

  static final StreamController<void> _refresh = StreamController<void>.broadcast();

  static Stream<void> get refresh => _refresh.stream;

  static void pushArrived() => _refresh.add(null);
}

/// The signed-in employee's unread mail (shared `/api/mail-monitor/my-unread`). Reloads every [every] while
/// shown, on pull-to-refresh, and when a MAIL_UNREAD push arrives.
class MyUnreadMailCubit extends Cubit<MyUnreadMailState> {
  MyUnreadMailCubit(this._api, {Duration every = const Duration(seconds: 60), Stream<void>? signals})
      : _every = every,
        super(const MyUnreadMailState(loading: true)) {
    _signals = (signals ?? MyUnreadMailSignals.refresh).listen((_) => load());
  }

  final MailMonitorApi _api;
  final Duration _every;
  Timer? _timer;
  StreamSubscription<void>? _signals;

  Future<void> load() async {
    try {
      final mail = await _api.myUnread();
      if (!isClosed) emit(MyUnreadMailState(mail: mail));
    } catch (e) {
      // keep the last numbers; with none, say why (a driver or an unlinked person simply sees nothing)
      if (!isClosed) emit(MyUnreadMailState(mail: state.mail, error: state.mail == null ? '$e' : null));
    }
  }

  void startAutoRefresh() {
    _timer?.cancel();
    _timer = Timer.periodic(_every, (_) => load());
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _signals?.cancel();
    return super.close();
  }
}
