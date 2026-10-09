import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/forwarding_request/forwarding_request_api.dart';
import 'package:maleva/core/forwarding_request/forwarding_request_models.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/forwarding_requests/bloc/forwarding_requests_cubit.dart';
import 'package:maleva/features/forwarding_requests/view/forwarding_request_card.dart';
import 'package:maleva/features/forwarding_requests/view/forwarding_request_detail_page.dart';
import 'package:maleva/features/forwarding_requests/view/forwarding_request_edit_page.dart';
import 'package:maleva/features/forwarding_requests/view/forwarding_request_filter_page.dart';

/// The route paths the push notices open (see push_route.dart).
const String forwardingRequestsPath = '/forwarding_requests';
const String myForwardingRequestsPath = '/forwarding_requests/mine';

/// Standalone screen (drawer, push notice, deep link). [mine] is Customer Service's own requests, read-only.
class ForwardingRequestsPage extends StatelessWidget {
  const ForwardingRequestsPage({super.key, this.mine = false, this.api});

  final bool mine;
  final ForwardingRequestApi? api;

  @override
  Widget build(BuildContext context) => MalevaThemeScope(
        child: Scaffold(
          appBar: AppBar(title: Text(mine ? 'My Forwarding Requests' : 'Forwarding Requests')),
          body: ForwardingRequestsBody(mine: mine, api: api),
        ),
      );
}

/// The list itself, also used as a dashboard tab. One card per request; the team taps a card to
/// work its ticks, Customer Service taps to read its progress. Phone: one column; tablet: two.
class ForwardingRequestsBody extends StatelessWidget {
  const ForwardingRequestsBody({super.key, this.mine = false, this.api});

  final bool mine;
  final ForwardingRequestApi? api;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => ForwardingRequestsCubit(api ?? sl<ForwardingRequestApi>(), mine: mine)..load(),
        child: _Body(mine: mine),
      );
}

class _Body extends StatelessWidget {
  const _Body({required this.mine});

  final bool mine;

  Future<void> _open(BuildContext context, ForwardingRequest r) async {
    final cubit = context.read<ForwardingRequestsCubit>();
    if (mine) {
      await Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (_) => ForwardingRequestDetailPage(request: r)));
      return;
    }
    await Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
      builder: (_) => ForwardingRequestEditPage(
        request: r,
        onSave: (ticks) => cubit.saveTicks(r.id, ticks),
        onCancelRequest: () => cubit.cancel(r.id),
      ),
    ));
  }

  Future<void> _filter(BuildContext context) async {
    final cubit = context.read<ForwardingRequestsCubit>();
    final next = await ForwardingRequestFilterPage.open(context, cubit.state.filter);
    if (next != null) await cubit.applyFilter(next);
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<ForwardingRequestsCubit, ForwardingRequestsState>(
        builder: (context, state) {
          final mc = context.mc;
          final f = state.filter;
          return Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(children: [
                Expanded(
                  child: Text(
                    '${state.rows.length} request${state.rows.length == 1 ? '' : 's'} · ${state.openCount} open'
                    '${state.overdueCount > 0 ? ' · ${state.overdueCount} overdue' : ''}',
                    style: TextStyle(color: mc.muted, fontSize: 13),
                  ),
                ),
                Badge(
                  isLabelVisible: f.activeCount > 0,
                  label: Text('${f.activeCount}'),
                  child: IconButton.outlined(tooltip: 'Filter', onPressed: () => _filter(context), icon: const Icon(Icons.tune)),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Estimated ${_day(f.fromDate)} – ${_day(f.toDate)}', style: TextStyle(fontSize: 12, color: mc.muted)),
              ),
            ),
            Expanded(
              child: state.loading && state.rows.isEmpty
                  ? const SkeletonList()
                  : state.error != null && state.rows.isEmpty
                      ? ErrorState(title: 'Could not load the requests', message: state.error, onRetry: () => context.read<ForwardingRequestsCubit>().load())
                      : state.rows.isEmpty
                          ? EmptyState(
                              title: mine ? 'No requests of yours in this window' : 'No forwarding requests in this window',
                              message: 'Widen the dates in the filter.',
                              actionLabel: 'Filter',
                              onAction: () => _filter(context))
                          : RefreshIndicator(
                              onRefresh: () => context.read<ForwardingRequestsCubit>().load(),
                              child: ResponsiveLayout(
                                phone: (_) => _list(context, state, columns: 1),
                                tabletPortrait: (_) => _list(context, state, columns: 2),
                                tabletLandscape: (_) => _list(context, state, columns: 3),
                              ),
                            ),
            ),
          ]);
        },
      );

  Widget _list(BuildContext context, ForwardingRequestsState state, {required int columns}) {
    if (columns == 1) {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
        itemCount: state.rows.length,
        itemBuilder: (_, i) => ForwardingRequestCard(state.rows[i], busy: state.busyId == state.rows[i].id, onTap: () => _open(context, state.rows[i])),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, mainAxisExtent: 150, crossAxisSpacing: 8),
      itemCount: state.rows.length,
      itemBuilder: (_, i) => ForwardingRequestCard(state.rows[i], busy: state.busyId == state.rows[i].id, onTap: () => _open(context, state.rows[i])),
    );
  }

  static String _day(String ymd) {
    if (ymd.isEmpty) return '…';
    final p = ymd.split('-');
    return p.length == 3 ? '${p[2]}/${p[1]}/${p[0]}' : ymd;
  }
}
