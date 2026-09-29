import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/utils/dialog_helper.dart';
import 'package:maleva/core/widgets/custom_app_bar.dart';

import '../../domain/entities/ir_report.dart';
import '../ir_permissions.dart';
import '../ir_report_routes.dart';
import '../ir_view_status.dart';
import '../list/bloc/ir_list_bloc.dart';
import '../widgets/ir_feedback.dart';
import '../widgets/ir_filter_bar.dart';
import '../widgets/ir_format.dart';
import '../widgets/ir_report_card.dart';
import '../widgets/ir_summary_header.dart';

/// The IR list as its own screen, opened from the drawer menu.
class IrListPage extends StatelessWidget {
  const IrListPage({super.key, required this.permissions});

  final IrPermissions permissions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.surfacePage,
      appBar: CustomGradientAppBar(
        title: 'Incident Reports',
        showBackButton: true,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () => context.read<IrListBloc>().add(const IrListRefreshed()),
          ),
        ],
      ),
      body: IrListView(permissions: permissions),
    );
  }
}

/// The IR list with its filters and the New IR button. Shared by the drawer
/// screen and the dashboard tab; needs an [IrListBloc] above it.
class IrListView extends StatelessWidget {
  const IrListView({super.key, required this.permissions});

  final IrPermissions permissions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.surfacePage,
      floatingActionButton: permissions.canAdd
          ? FloatingActionButton.extended(
              // No hero: the dashboard tab and the drawer screen can both be
              // on the navigation stack, each with this button.
              heroTag: null,
              backgroundColor: AppTokens.brandPrimary,
              foregroundColor: Colors.white,
              onPressed: () => _openForm(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('New IR'),
            )
          : null,
      body: BlocListener<IrListBloc, IrListState>(
        listenWhen: (previous, current) =>
            current.message != null && previous.message != current.message,
        listener: (context, state) => showIrMessage(context, state.message!),
        child: Column(
          children: [
            const IrFilterBar(),
            Expanded(
              child: BlocBuilder<IrListBloc, IrListState>(
                builder: (context, state) => _buildBody(context, state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, IrListState state) {
    final bloc = context.read<IrListBloc>();

    final firstLoad = state.items.isEmpty &&
        (state.status == IrViewStatus.initial || state.status == IrViewStatus.loading);
    if (firstLoad) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == IrViewStatus.failure && state.items.isEmpty) {
      return IrMessageView(
        icon: Icons.cloud_off_rounded,
        title: 'Could not load incident reports',
        message: state.errorMessage,
        actionLabel: 'Retry',
        onAction: () => bloc.add(const IrListRefreshed()),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _refresh(bloc),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        // Bottom padding keeps the last card clear of the floating button.
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        itemCount: state.items.isEmpty ? 2 : state.items.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _header(state);
          if (state.items.isEmpty) {
            return const Padding(
              padding: EdgeInsets.only(top: 40),
              child: IrMessageView(
                icon: Icons.fact_check_outlined,
                title: 'No incident reports',
                message: 'Nothing matches these filters.',
              ),
            );
          }
          final report = state.items[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: IrReportCard(
              report: report,
              deleting: state.deletingId == report.id,
              onTap: () => _openForm(context, report: report),
              onDelete: permissions.canDelete(report)
                  ? () => _confirmDelete(context, report)
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _header(IrListState state) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IrSummaryHeader(
            count: state.items.length,
            totalAmount: state.totalAmount,
            loading: state.status == IrViewStatus.loading,
          ),
          if (state.status == IrViewStatus.failure) ...[
            const SizedBox(height: 8),
            IrInlineError(message: state.errorMessage ?? 'Could not refresh the list'),
          ],
        ],
      ),
    );
  }

  Future<void> _refresh(IrListBloc bloc) async {
    bloc.add(const IrListRefreshed());
    await bloc.stream.firstWhere((state) => state.status != IrViewStatus.loading);
  }

  /// A report the user may not change opens read-only, so everyone can still
  /// read the full details.
  Future<void> _openForm(BuildContext context, {IrReport? report}) async {
    final bloc = context.read<IrListBloc>();
    final saved = await Navigator.of(context).push(IrReportRoutes.form(
      reportId: report?.id,
      readOnly: report != null && !permissions.canEdit(report),
    ));
    if (saved != true || !context.mounted) return;
    showIrMessage(context, IrUiMessage('Incident report saved'));
    bloc.add(const IrListRefreshed());
  }

  Future<void> _confirmDelete(BuildContext context, IrReport report) async {
    final bloc = context.read<IrListBloc>();
    final confirmed = await ConfirmationMsgYesNo(
      context,
      'Delete the incident report of ${IrFormat.date(report.irDate)}?',
    );
    if (confirmed) bloc.add(IrListDeleteRequested(report));
  }
}
