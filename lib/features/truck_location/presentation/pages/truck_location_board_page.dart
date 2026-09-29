import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/widgets/debounced_search_bar.dart';

import '../../domain/truck_location_rules.dart' as rules;
import '../bloc/truck_location_bloc.dart';
import '../truck_location_view_status.dart';
import '../widgets/truck_location_day_tab.dart';
import '../widgets/truck_location_save_bar.dart';
import '../widgets/truck_location_week_tab.dart';

/// The Truck Location Board: where every truck is, Sunday to Saturday. Two
/// tabs over one bloc - DAY for the typing, WEEK to read and check - with the
/// one Save all pinned at the bottom.
class TruckLocationBoardPage extends StatefulWidget {
  const TruckLocationBoardPage({super.key});

  @override
  State<TruckLocationBoardPage> createState() => _TruckLocationBoardPageState();
}

class _TruckLocationBoardPageState extends State<TruckLocationBoardPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 2, vsync: this);

  bool _searchOpen = false;
  bool _expandAll = false;
  int _expandAllVersion = 0;

  @override
  void initState() {
    super.initState();
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onMenu(String action) async {
    final bloc = context.read<TruckLocationBloc>();
    switch (action) {
      case 'search':
        setState(() => _searchOpen = !_searchOpen);
        if (!_searchOpen) bloc.add(const TruckLocationSearchChanged(''));
      case 'sort_location':
        bloc.add(TruckLocationSortChanged(
            bloc.state.sort == TruckLocationSort.byLocation
                ? TruckLocationSort.shared
                : TruckLocationSort.byLocation));
      case 'sort_truck':
        bloc.add(TruckLocationSortChanged(
            bloc.state.sort == TruckLocationSort.byTruck
                ? TruckLocationSort.shared
                : TruckLocationSort.byTruck));
      case 'fill_day':
        bloc.add(const TruckLocationFillDayPressed());
      case 'show_done':
        bloc.add(const TruckLocationShowDoneToggled());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TruckLocationBloc, TruckLocationState>(
      listenWhen: (previous, current) => previous.message != current.message,
      listener: (context, state) {
        final message = state.message;
        if (message == null) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(message.text),
            backgroundColor:
                message.isError ? AppTokens.statusDanger : AppTokens.brandDeep,
            behavior: SnackBarBehavior.floating,
          ));
      },
      builder: (context, state) {
        final bloc = context.read<TruckLocationBloc>();
        final dayName = state.selectedDayIndex >= 0
            ? rules.dayNames[state.selectedDayIndex]
            : 'day';

        return PopScope(
          // Leaving with unsaved edits asks first (rule 10).
          canPop: !state.hasUnsaved,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            final navigator = Navigator.of(context);
            if (await confirmDiscardChanges(context) && navigator.mounted) {
              navigator.pop();
            }
          },
          child: Scaffold(
            backgroundColor: AppTokens.surfacePage,
            appBar: AppBar(
              backgroundColor: AppTokens.appBarBg,
              iconTheme: const IconThemeData(color: AppTokens.appBarIcon),
              title: Text('Truck Location',
                  style: AppTypography.pageTitleWhite),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [Tab(text: 'DAY'), Tab(text: 'WEEK')],
              ),
              actions: [
                if (_tabController.index == 1)
                  IconButton(
                    tooltip: _expandAll ? 'Collapse all' : 'Expand all',
                    icon: Icon(_expandAll ? Icons.unfold_less : Icons.unfold_more),
                    onPressed: () => setState(() {
                      _expandAll = !_expandAll;
                      _expandAllVersion++;
                    }),
                  ),
                PopupMenuButton<String>(
                  onSelected: _onMenu,
                  itemBuilder: (context) => [
                    CheckedPopupMenuItem(
                      value: 'search',
                      checked: _searchOpen,
                      child: const Text('Search truck'),
                    ),
                    CheckedPopupMenuItem(
                      value: 'sort_location',
                      checked: state.sort == TruckLocationSort.byLocation,
                      child: const Text('Sort by location'),
                    ),
                    CheckedPopupMenuItem(
                      value: 'sort_truck',
                      checked: state.sort == TruckLocationSort.byTruck,
                      child: const Text('Sort by truck'),
                    ),
                    PopupMenuItem(
                      value: 'fill_day',
                      child: Text('Fill $dayName from previous'),
                    ),
                    CheckedPopupMenuItem(
                      value: 'show_done',
                      checked: state.showDone,
                      child: Text('Show done (${state.doneCount})'),
                    ),
                  ],
                ),
              ],
            ),
            body: Column(
              children: [
                if (_searchOpen)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: DebouncedSearchBar(
                      isTablet: false,
                      hintText: 'Search truck',
                      onChanged: (text) =>
                          bloc.add(TruckLocationSearchChanged(text)),
                    ),
                  ),
                if (state.savingOrder)
                  const LinearProgressIndicator(minHeight: 2),
                Expanded(child: _body(state)),
                const TruckLocationSaveBar(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _body(TruckLocationState state) {
    switch (state.status) {
      case TruckLocationStatus.initial:
      case TruckLocationStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case TruckLocationStatus.failure:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  // The server's own message (a 400 comes through as typed).
                  state.errorMessage ?? 'Something went wrong.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium(color: AppTokens.textPrimary),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context
                      .read<TruckLocationBloc>()
                      .add(const TruckLocationRetryPressed()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTokens.brandPrimary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      case TruckLocationStatus.success:
        return TabBarView(
          controller: _tabController,
          children: [
            const TruckLocationDayTab(),
            TruckLocationWeekTab(
              expandAll: _expandAll,
              expandAllVersion: _expandAllVersion,
            ),
          ],
        );
    }
  }
}
