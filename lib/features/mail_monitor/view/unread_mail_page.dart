import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_api.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_models.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/mail_monitor/bloc/unread_mail_cubit.dart';
import 'package:maleva/features/mail_monitor/view/level_look.dart';
import 'package:maleva/features/mail_monitor/view/mail_message_page.dart';
import 'package:maleva/features/mail_monitor/view/mailbox_detail_page.dart';

/// Every unread mail of one mailbox, newest first, 50 at a time (scroll for more), with a search
/// the mail server runs. Read live; nothing is marked read; the server records each look.
class UnreadMailPage extends StatelessWidget {
  const UnreadMailPage({super.key, required this.api, required this.row});

  final MailMonitorApi api;
  final MailboxRow row;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => UnreadMailCubit(api, row.id)..search(''),
        child: _UnreadView(api: api, row: row),
      );
}

class _UnreadView extends StatefulWidget {
  const _UnreadView({required this.api, required this.row});

  final MailMonitorApi api;
  final MailboxRow row;

  @override
  State<_UnreadView> createState() => _UnreadViewState();
}

class _UnreadViewState extends State<_UnreadView> {
  final _search = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 300) {
        context.read<UnreadMailCubit>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Unread · ${widget.row.address}', overflow: TextOverflow.ellipsis)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              maxLength: 100,
              decoration: InputDecoration(
                hintText: 'Search subject or sender',
                prefixIcon: const Icon(Icons.search),
                counterText: '',
                isDense: true,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear search',
                  onPressed: () {
                    _search.clear();
                    context.read<UnreadMailCubit>().search('');
                  },
                ),
              ),
              onSubmitted: (q) => context.read<UnreadMailCubit>().search(q),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('Nothing is marked as read. Opening this list and each mail is recorded.',
                style: TextStyle(fontSize: 11, color: context.mc.muted)),
          ),
          Expanded(
            child: BlocBuilder<UnreadMailCubit, UnreadMailState>(
              builder: (context, s) {
                if (s.items.isEmpty && s.loading) return const SkeletonList();
                if (s.items.isEmpty && s.error != null) {
                  return ErrorState(title: 'Could not read the mailbox', message: s.error,
                      onRetry: () => context.read<UnreadMailCubit>().search(s.query));
                }
                if (s.items.isEmpty) {
                  return EmptyState(title: s.query.isEmpty ? 'No unread mail' : 'No unread mail matches this search');
                }
                return ListView.separated(
                  controller: _scroll,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  itemCount: s.items.length + 2,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text('${countText(s.items.length)} of ${countText(s.total)}',
                            style: TextStyle(fontSize: 12, color: context.mc.muted)),
                      );
                    }
                    if (i == s.items.length + 1) {
                      if (s.loading) return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
                      if (s.error != null) return TextButton(onPressed: context.read<UnreadMailCubit>().loadMore, child: Text('${s.error} · Retry'));
                      return const SizedBox(height: 24);
                    }
                    final item = s.items[i - 1];
                    return MailRowTile(
                      item: item,
                      onTap: item.uid > 0
                          ? () => Navigator.of(context).push(MaterialPageRoute<void>(
                                builder: (_) => MailMessagePage(api: widget.api, mailboxId: widget.row.id, uid: item.uid),
                              ))
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
