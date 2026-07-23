import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/menu/menulist.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/tokens.dart';
import '../bloc/planningdetails_bloc.dart';
import '../bloc/planningdetails_event.dart';
import '../bloc/planningdetails_state.dart';


// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

class PlanningDetailsView extends StatelessWidget {
  const PlanningDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return
      BlocProvider(
        create: (context) => sl<PlanningDetailsBloc>()
          ..add(const PlanningDetailsStartupRequested()),
        child: const _PlanningDetailsView(),
      );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// View — stateful only for search TextEditingController
// ─────────────────────────────────────────────────────────────────────────────

class _PlanningDetailsView extends StatefulWidget {
  const _PlanningDetailsView();

  @override
  State<_PlanningDetailsView> createState() => _PlanningDetailsViewState();
}

class _PlanningDetailsViewState extends State<_PlanningDetailsView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Back press ─────────────────────────────────────────────────────────────

  Future<bool> _onBackPressed() async {
    Navigator.of(context).pop();
    return true;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlanningDetailsBloc, PlanningDetailsState>(
      listener: (ctx, state) {
        if (state.status == PlanningDetailsStatus.failure) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            backgroundColor: Palette.redError,
            content: Text(state.errorMessage,
                style: GoogleFonts.lato(color: Palette.white)),
            duration: const Duration(seconds: 3),
          ));
        }
      },
      builder: (ctx, state) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            await _onBackPressed();
          },
          child: LayoutBuilder(
            builder: (_, constraints) {
              final bool isTablet = constraints.maxWidth >= 600;
              return _buildScaffold(ctx, state, isTablet);
            },
          ),
        );
      },
    );
  }

  Widget _buildScaffold(
      BuildContext ctx, PlanningDetailsState state, bool isTablet) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppTokens.surfacePage,
      appBar: _buildAppBar(isTablet),
      drawer: const Menulist(),
      body: state.isLoading
          ? const Center(
          child: SpinKitFoldingCube(
              color: AppTokens.spinKit, size: 35))
          : state.status == PlanningDetailsStatus.failure
          ? _ErrorWidget(
        message: state.errorMessage,
        onRetry: () => ctx
            .read<PlanningDetailsBloc>()
            .add(const PlanningDetailsStartupRequested()),
      )
          : _buildBody(ctx, state, isTablet),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(bool isTablet) {
    final String userName =
        AppGlobals.storagenew.getString('Username') ?? '';
    return AppBar(
      flexibleSpace: Container(
          decoration:
          const BoxDecoration(gradient: AppTokens.headerGradient)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppTokens.appBarIcon),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Planning Details',
            style: GoogleFonts.lato(
              color: AppTokens.appBarTitle,
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 18 : 16,
            ),
          ),
          if (userName.isNotEmpty)
            Text(
              userName,
              style: GoogleFonts.lato(
                color: AppTokens.invoicePillBg,
                fontSize: isTablet ? 13 : 11,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded,
              color: AppTokens.appBarIcon),
          tooltip: 'Refresh',
          onPressed: () => context
              .read<PlanningDetailsBloc>()
              .add(const PlanningDetailsRefreshRequested()),
        ),
      ],
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────

  Widget _buildBody(
      BuildContext ctx, PlanningDetailsState state, bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? 12 : 6),
      child: Column(
        children: [
          // ── Search field ───────────────────────────────────────────────
              _SearchField(
                controller: _searchController,
                isTablet: isTablet,
                onChanged: (q) => ctx
                    .read<PlanningDetailsBloc>()
                    .add(PlanningDetailsSearchChanged(q)),
                onClear: () {
                  _searchController.clear();
                  ctx
                      .read<PlanningDetailsBloc>()
                      .add(const PlanningDetailsSearchChanged(''));
                },
              ),

              const SizedBox(height: 6),

              // ── Summary pill ───────────────────────────────────────────────
              _SummaryPill(count: state.filteredPlanningList.length),

              const SizedBox(height: 6),

              // ── Data Table ──────────────────────────────────────────────────
              Expanded(
                child: state.filteredPlanningList.isEmpty
                    ? const SizedBox.shrink()
                    : RefreshIndicator(
                        color: AppTokens.brandPrimary,
                        onRefresh: () async {
                          ctx.read<PlanningDetailsBloc>().add(const PlanningDetailsRefreshRequested());
                          await Future.delayed(const Duration(milliseconds: 600));
                        },
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              clipBehavior: Clip.antiAlias,
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(AppTokens.invoiceHeaderStart),
                                headingTextStyle: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold, fontSize: isTablet ? 13 : 11),
                                dataRowMinHeight: 35,
                                dataRowMaxHeight: 50,
                                dataTextStyle: GoogleFonts.lato(color: AppTokens.textPrimary, fontSize: isTablet ? 13 : 11, fontWeight: FontWeight.w500),
                                columnSpacing: 25,
                                border: TableBorder(
                                  horizontalInside: BorderSide(color: AppTokens.surfaceBorder.withValues(alpha: 0.5), width: 1),
                                  verticalInside: BorderSide(color: AppTokens.surfaceBorder.withValues(alpha: 0.5), width: 1),
                                ),
                                columns: const [
                                  DataColumn(label: Text('S.No')),
                                  DataColumn(label: Text('Remarks')),
                                  DataColumn(label: Text('Truck')),
                                  DataColumn(label: Text('Pickup Date')),
                                  DataColumn(label: Text('Delivery Date')),
                                  DataColumn(label: Text('Origin')),
                                  DataColumn(label: Text('Destination')),
                                  DataColumn(label: Text('Package')),
                                  DataColumn(label: Text('Customer')),
                                  DataColumn(label: Text('Job No')),
                                  DataColumn(label: Text('Vessel')),
                                  DataColumn(label: Text('Status')),
                                  DataColumn(label: Text('PIC')),
                                  DataColumn(label: Text('LETA')),
                                  DataColumn(label: Text('OETA')),
                                ],
                                rows: state.filteredPlanningList.asMap().entries.map((e) {
                                  final i = e.key;
                                  final item = e.value;
                                  return DataRow(
                                    color: WidgetStateProperty.all(i % 2 == 0 ? Colors.white : AppTokens.surfaceCard),
                                    cells: [
                                      DataCell(Text('${i + 1}')),
                                      DataCell(Text('${item["Remarks"] ?? ""}')),
                                      DataCell(Text('${item["TruckName"] ?? ""}')),
                                      DataCell(Text('${item["SPickupDate"] ?? ""}')),
                                      DataCell(Text('${item["SDeliveryDate"] ?? ""}')),
                                      DataCell(Text('${item["Origin"] ?? ""}')),
                                      DataCell(Text('${item["Destination"] ?? ""}')),
                                      DataCell(Text('${item["pkg"] ?? ""}')),
                                      DataCell(Text('${item["CustomerName"] ?? ""}')),
                                      DataCell(Text('${item["JobNo"] ?? ""}', style: const TextStyle(color: AppTokens.brandPrimary, fontWeight: FontWeight.bold))),
                                      DataCell(Text('${item["VesselName"] ?? ""}')),
                                      DataCell(Text('${item["JobStatus"] ?? ""}')),
                                      DataCell(Text('${item["EmployeeName"] ?? ""}')),
                                      DataCell(Text('${item["LETA"] ?? ""}')),
                                      DataCell(Text('${item["OETA"] ?? ""}')),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search field
// ─────────────────────────────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.isTablet,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final bool isTablet;
  final void Function(String) onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: GoogleFonts.lato(
          fontSize: isTablet ? 14 : 13, color: AppTokens.textPrimary),
      decoration: InputDecoration(
        hintText: 'Search by Planning No / PIC / Date / Port',
        hintStyle: GoogleFonts.lato(
            fontSize: isTablet ? 13 : 12,
            color: AppTokens.textSecondary),
        prefixIcon: const Icon(Icons.search,
            color: AppTokens.brandPrimary, size: 20),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear,
              color: AppTokens.textSecondary, size: 18),
          onPressed: onClear,
        )
            : null,
        filled: true,
        fillColor: AppTokens.surfaceCard,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
            const BorderSide(color: AppTokens.surfaceBorder)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
            const BorderSide(color: AppTokens.surfaceBorder)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: AppTokens.brandPrimary, width: 1.5)),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary pill
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          gradient: AppTokens.headerGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Palette.brandGlow, blurRadius: 6)
          ],
        ),
        child: Text(
          'Results: $count',
          style: GoogleFonts.lato(
              color: Palette.white,
              fontWeight: FontWeight.w600,
              fontSize: 12),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Column header card
class _EmptyWidget extends StatelessWidget {
  const _EmptyWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded,
              size: 64,
              color: Palette.grey400.withValues(alpha: 0.6)),
          const SizedBox(height: 12),
          Text('No planning records found',
              style: GoogleFonts.lato(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTokens.textSecondary)),
          const SizedBox(height: 4),
          Text('Adjust filters or refresh',
              style: GoogleFonts.lato(
                  fontSize: 12, color: AppTokens.textMuted)),
        ],
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget(
      {required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 56, color: Palette.redError),
            const SizedBox(height: 12),
            Text('Failed to load data',
                style: GoogleFonts.lato(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTokens.textPrimary)),
            const SizedBox(height: 6),
            Text(message,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lato(
                    fontSize: 12, color: AppTokens.textMuted)),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTokens.brandPrimary,
                foregroundColor: Palette.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text('Retry',
                  style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}