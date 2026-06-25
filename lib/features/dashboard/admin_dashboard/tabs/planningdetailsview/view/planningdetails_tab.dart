import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/menu/menulist.dart';

import '../../../../../../core/di/injection.dart';
import '../../../../../../core/theme/tokens.dart';
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
        return WillPopScope(
          onWillPop: _onBackPressed,
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
        objfun.storagenew.getString('Username') ?? '';
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
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 12 : 6),
          child: Column(
            children: [
          // ── Column header card ─────────────────────────────────────────
          _ColumnHeaderCard(isTablet: isTablet),

          const SizedBox(height: 6),

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

          const SizedBox(height: 4),

          // ── Summary pill ───────────────────────────────────────────────
          _SummaryPill(count: state.filteredPlanningList.length),

          const SizedBox(height: 4),

          // ── List ───────────────────────────────────────────────────────
          Expanded(
            child: state.filteredPlanningList.isEmpty
                ? const SizedBox.shrink()
                : RefreshIndicator(
                    color: AppTokens.brandPrimary,
                    onRefresh: () async {
                      ctx.read<PlanningDetailsBloc>().add(const PlanningDetailsRefreshRequested());
                      await Future.delayed(const Duration(milliseconds: 600));
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(bottom: isTablet ? 20 : 12),
                      itemCount: state.filteredPlanningList.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _PlanningCard(
                          index: i,
                          item: state.filteredPlanningList[i],
                          isTablet: isTablet,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    ),
  ),
);
}
}

// ─────────────────────────────────────────────────────────────────────────────
// Column header card
// ─────────────────────────────────────────────────────────────────────────────

class _ColumnHeaderCard extends StatelessWidget {
  const _ColumnHeaderCard({required this.isTablet});
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final double fs = isTablet ? 13 : 11;
    return Card(
      color: AppTokens.invoiceHeaderStart,
      elevation: 6,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
            color: AppTokens.brandPrimary.withOpacity(0.4), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _hRow([
              _hText('S.No', flex: 1, fs: fs),
              _hText('Remarks', flex: 3, fs: fs),
              _hText('Truck', flex: 2, fs: fs),
            ]),
            const SizedBox(height: 6),
            const Divider(color: Colors.white54, height: 1),
            const SizedBox(height: 6),
            _hRow([
              _hText('Pickup Date',   flex: 3, fs: fs),
              _hText('Delivery Date', flex: 3, fs: fs),
            ]),
            const SizedBox(height: 6),
            _hRow([
              _hText('Origin',      flex: 3, fs: fs),
              _hText('Destination', flex: 3, fs: fs),
              _hText('Package',     flex: 4, fs: fs),
            ]),
            const SizedBox(height: 6),
            _hRow([
              _hText('Customer', flex: 4, fs: fs),
              _hText('Job No',   flex: 2, fs: fs),
            ]),
            const SizedBox(height: 6),
            _hRow([
              _hText('Vessel', flex: 3, fs: fs),
              _hText('Status', flex: 2, fs: fs),
              _hText('PIC',    flex: 3, fs: fs),
            ]),
            const SizedBox(height: 6),
            _hRow([
              _hText('LETA', flex: 3, fs: fs),
              _hText('OETA', flex: 2, fs: fs),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _hRow(List<Widget> children) =>
      Row(children: children);

  Widget _hText(String text, {required int flex, required double fs}) =>
      Expanded(
        flex: flex,
        child: Text(
          text,
          style: GoogleFonts.lato(
            color: Palette.white,
            fontWeight: FontWeight.bold,
            fontSize: fs,
            letterSpacing: 0.3,
          ),
        ),
      );
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
          boxShadow: [
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
// Planning card
// ─────────────────────────────────────────────────────────────────────────────

class _PlanningCard extends StatelessWidget {
  const _PlanningCard({
    required this.index,
    required this.item,
    required this.isTablet,
  });

  final int index;
  final dynamic item;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 6,
        shadowColor: Colors.black26,
        color: AppTokens.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: AppTokens.brandPrimary.withOpacity(0.3),
            width: 0.8,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 14 : 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── TOP ROW: index avatar + remarks + job no chip ──────────
              Row(children: [
                CircleAvatar(
                  radius: isTablet ? 16 : 14,
                  backgroundColor: AppTokens.brandPrimary,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                        color: Palette.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item['Remarks'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lato(
                      fontSize: isTablet ? 14 : 13,
                      fontWeight: FontWeight.w700,
                      color: AppTokens.textPrimary,
                    ),
                  ),
                ),
                // Job No chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTokens.brandPrimary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTokens.brandPrimary.withOpacity(0.35),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    item['JobNo'] ?? '',
                    style: GoogleFonts.lato(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTokens.brandPrimary,
                    ),
                  ),
                ),
              ]),

              const Divider(height: 10),

              // ── ROW 2: Pickup + Delivery ───────────────────────────────
              Row(children: [
                Expanded(
                    child: _Info('Pickup',
                        item['SPickupDate'])),
                Expanded(
                    child: _Info('Delivery',
                        item['SDeliveryDate'])),
              ]),

              const SizedBox(height: 5),

              // ── ROW 3: Origin + Destination + Package ──────────────────
              Row(children: [
                Expanded(child: _Info('Origin',      item['Origin'])),
                Expanded(child: _Info('Destination', item['Destination'])),
                Expanded(child: _Info('Package',     item['pkg'])),
              ]),

              const SizedBox(height: 5),

              // ── ROW 4: Customer + Truck ────────────────────────────────
              Row(children: [
                Expanded(
                    child: _Info('Customer', item['CustomerName'])),
                Expanded(
                    child: _Info('Truck',    item['TruckName'])),
              ]),

              const SizedBox(height: 5),

              // ── ROW 5: Vessel + JobStatus + PIC ───────────────────────
              Row(children: [
                Expanded(
                    child: _Info('Vessel',    item['VesselName'])),
                Expanded(
                    child: _Info('Status',    item['JobStatus'])),
                Expanded(
                    child: _Info('PIC',       item['EmployeeName'])),
              ]),

              const SizedBox(height: 5),

              // ── ROW 6: LETA + OETA ────────────────────────────────────
              Row(children: [
                Expanded(child: _Info('LETA', item['LETA'])),
                Expanded(child: _Info('OETA', item['OETA'])),
              ]),
            ],
          ),
        ),
      );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _Info — label + value micro-widget (matches original _infoText)
// ─────────────────────────────────────────────────────────────────────────────

class _Info extends StatelessWidget {
  const _Info(this.label, this.value);
  final String label;
  final dynamic value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lato(
              fontSize: 9,
              color: AppTokens.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value?.toString().isNotEmpty == true ? value.toString() : '—',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.lato(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTokens.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty / Error placeholder widgets
// ─────────────────────────────────────────────────────────────────────────────

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
              color: Palette.grey400.withOpacity(0.6)),
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