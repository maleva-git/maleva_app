import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_api.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_models.dart';

class UnreadMailState {
  const UnreadMailState({
    this.items = const [],
    this.total = 0,
    this.nextPage = 0,
    this.query = '',
    this.loading = false,
    this.error,
  });

  final List<PreviewItem> items;
  final int total;
  final int nextPage;
  final String query;
  final bool loading;
  final String? error;

  bool get hasMore => items.length < total;
}

/// All unread mail of one mailbox, 50 a page, newest first, read live from the mailbox.
/// Kept only in this screen's state.
class UnreadMailCubit extends Cubit<UnreadMailState> {
  UnreadMailCubit(this._api, this.mailboxId, {this.pageSize = 50}) : super(const UnreadMailState());

  final MailMonitorApi _api;
  final int mailboxId;
  final int pageSize;

  /// Starts again at the first page, with [query] searched by the mail server.
  Future<void> search(String query) async {
    emit(UnreadMailState(query: query.trim(), loading: true));
    await _fetch(0, const []);
  }

  Future<void> loadMore() async {
    if (state.loading || !state.hasMore) return;
    emit(UnreadMailState(items: state.items, total: state.total, nextPage: state.nextPage, query: state.query, loading: true));
    await _fetch(state.nextPage, state.items);
  }

  Future<void> _fetch(int page, List<PreviewItem> before) async {
    try {
      final r = await _api.unread(mailboxId, page: page, size: pageSize, query: state.query);
      if (isClosed) return;
      emit(UnreadMailState(items: [...before, ...r.items], total: r.total, nextPage: page + 1, query: state.query));
    } catch (e) {
      if (isClosed) return;
      emit(UnreadMailState(items: before, total: state.total, nextPage: page, query: state.query, error: '$e'));
    }
  }
}
