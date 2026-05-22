import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/menu/menulist.dart';

import '../../../../../../core/theme/tokens.dart';
import '../bloc/vesselplanningdetails_bloc.dart';
import '../bloc/vesselplanningdetails_event.dart';
import '../bloc/vesselplanningdetails_state.dart';


// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

class VesselPlanningDetailsView extends StatelessWidget {
  const VesselPlanningDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VesselPlanningDetailsBloc()
        ..add(const VesselPlanningDetailsStartupRequested()),
      child: const _VesselPlanningDetailsView(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// View — stateless; no controllers or local state needed
// ─────────────────────────────────────────────────────────────────────────────

class _VesselPlanningDetailsView extends StatelessWidget {
  const _VesselPlanningDetailsView();

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VesselPlanningDetailsBloc,
        VesselPlanningDetailsState>(
      listener: (ctx, state) {
        if (state.status == VesselPlanningDetailsStatus.failure) {
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
          onWillPop: () async {
            Navigator.of(context).pop();
            return true;
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

  // ── Scaffold ───────────────────────────────────────────────────────────────

  Widget _buildScaffold(BuildContext ctx,
      VesselPlanningDetailsState state, bool isTablet) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppTokens.surfacePage,
      appBar: _buildAppBar(ctx, isTablet),
      drawer: const Menulist(),
      body: state.isLoading
          ? const Center(
          child: SpinKitFoldingCube(
              color: AppTokens.spinKit, size: 35))
          : state.status == VesselPlanningDetailsStatus.failure
          ? _ErrorWidget(
        message: state.errorMessage,
        onRetry: () => ctx
            .read<VesselPlanningDetailsBloc>()
            .add(const VesselPlanningDetailsStartupRequested()),
      )
          : _buildBody(ctx, state, isTablet),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(
      BuildContext ctx, bool isTablet) {
    final String userName =
        objfun.storagenew.getString('Username') ?? '';
    return AppBar(
      flexibleSpace: Container(
          decoration:
          const BoxDecoration(gradient: AppTokens.headerGradient)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme:
      const IconThemeData(color: AppTokens.appBarIcon),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(ctx),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Vessel Details',
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
          onPressed: () => ctx
              .read<VesselPlanningDetailsBloc>()
              .add(const VesselPlanningDetailsRefreshRequested()),
        ),
      ],
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────

  Widget _buildBody(BuildContext ctx,
      VesselPlanningDetailsState state, bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? 10 : 5),
      child: Column(
        children: [
          // ── Column header ──────────────────────────────────────────────
          _ColumnHeaderCard(isTablet: isTablet),

          const SizedBox(height: 6),

          // ── Summary pill ───────────────────────────────────────────────
          _SummaryPill(count: state.vesselPlanningList.length),

          const SizedBox(height: 4),

          // ── List ───────────────────────────────────────────────────────
          Expanded(
            child: state.isEmpty
                ? const _EmptyWidget()
                : RefreshIndicator(
              color: AppTokens.brandPrimary,
              onRefresh: () async {
                ctx.read<VesselPlanningDetailsBloc>().add(
                    const VesselPlanningDetailsRefreshRequested());
                await Future.delayed(
                    const Duration(milliseconds: 600));
              },
              child: ListView.builder(
                physics:
                const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                    bottom: isTablet ? 20 : 12),
                itemCount: state.vesselPlanningList.length,
                itemBuilder: (_, i) => Padding(
                  padding:
                  const EdgeInsets.only(bottom: 8),
                  child: _VesselCard(
                    index: i,
                    item: state.vesselPlanningList[i],
                    isTablet: isTablet,
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
// Column header card
// Mirrors the original 5-row header structure with the same flex values
// ─────────────────────────────────────────────────────────────────────────────

class _ColumnHeaderCard extends StatelessWidget {
  const _ColumnHeaderCard({required this.isTablet});
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final double fs = isTablet ? 13 : 11;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        gradient: AppTokens.headerGradient,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Palette.brandGlow, blurRadius: 6,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: S.No | Remarks | Job Type
          _hRow([
            _hText('S.No',     flex: 1, fs: fs),
            _hText('Remarks',  flex: 3, fs: fs),
            _hText('Job Type', flex: 4, fs: fs),
          ]),
          const SizedBox(height: 5),
          const Divider(color: Colors.white38, height: 1),
          const SizedBox(height: 5),
          // Row 2: Off Vessel | Load Vessel
          _hRow([
            _hText('Off Vessel',  flex: 3, fs: fs),
            _hText('Load Vessel', flex: 3, fs: fs),
          ]),
          const SizedBox(height: 5),
          // Row 3: Origin | Destination | Package
          _hRow([
            _hText('Origin',      flex: 3, fs: fs),
            _hText('Destination', flex: 3, fs: fs),
            _hText('Package',     flex: 4, fs: fs),
          ]),
          const SizedBox(height: 5),
          // Row 4: Customer Name | Job No
          _hRow([
            _hText('Customer Name', flex: 4, fs: fs),
            _hText('Job No',        flex: 2, fs: fs),
          ]),
          const SizedBox(height: 5),
          // Row 5: Cargo Loc | Status | PIC
          _hRow([
            _hText('Cargo Loc', flex: 3, fs: fs),
            _hText('Status',    flex: 2, fs: fs),
            _hText('PIC',       flex: 3, fs: fs),
          ]),
        ],
      ),
    );
  }

  Widget _hRow(List<Widget> children) =>
      Row(children: children);

  Widget _hText(String text,
      {required int flex, required double fs}) =>
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
          'Total: $count',
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
// Vessel planning card
// Mirrors the original 5-row card layout with matching flex values
// ─────────────────────────────────────────────────────────────────────────────

class _VesselCard extends StatelessWidget {
  const _VesselCard({
    required this.index,
    required this.item,
    required this.isTablet,
  });

  final int index;
  final dynamic item;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final double cardH =
        MediaQuery.of(context).size.height *
            (isTablet ? 0.18 : 0.20);
    final double fs = isTablet ? 13 : objfun.FontCardText;

    return SizedBox(
      height: cardH,
      child: Card(
        elevation: 6,
        shadowColor: Colors.black26,
        color: AppTokens.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: AppTokens.brandPrimary.withOpacity(0.35),
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 12 : 6, vertical: 4),
          child: Column(
            children: [
              // ── Row 1: S.No | Remarks | Job Type ───────────────────
              Expanded(
                flex: 1,
                child: Row(children: [
                  Expanded(
                    flex: 1,
                    child: _cell(
                      '${index + 1}',
                      fs: fs,
                      bold: true,
                      color: AppTokens.brandPrimary,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: _cell(
                      item['Remarks']?.toString() ?? '',
                      fs: fs,
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: _cell(
                      item['JobName']?.toString() ?? '',
                      fs: fs,
                    ),
                  ),
                ]),
              ),

              // ── Row 2: Off Vessel | Loading Vessel ─────────────────
              Expanded(
                flex: 1,
                child: Row(children: [
                  Expanded(
                    flex: 3,
                    child: _cell(
                      item['Offvesselname']?.toString() ?? '',
                      fs: fs,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: _cell(
                      item['Loadingvesselname']?.toString() ?? '',
                      fs: fs,
                    ),
                  ),
                ]),
              ),

              // ── Row 3: Origin | Destination | Package ──────────────
              Expanded(
                flex: 1,
                child: Row(children: [
                  Expanded(
                    flex: 3,
                    child: _cell(
                      item['Origin']?.toString() ?? '',
                      fs: fs,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: _cell(
                      item['Destination']?.toString() ?? '',
                      fs: fs,
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: _cell(
                      item['pkg']?.toString() ?? '',
                      fs: fs,
                    ),
                  ),
                ]),
              ),

              // ── Row 4: Customer Name | Job No ──────────────────────
              Expanded(
                flex: 1,
                child: Row(children: [
                  Expanded(
                    flex: 4,
                    child: _cell(
                      item['CustomerName']?.toString() ?? '',
                      fs: fs,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: _jobNoChip(
                      item['JobNo']?.toString() ?? '',
                      fs: fs - 1,
                    ),
                  ),
                ]),
              ),

              // ── Row 5: Cargo Loc | Job Status | PIC ───────────────
              Expanded(
                flex: 1,
                child: Row(children: [
                  Expanded(
                    flex: 3,
                    child: _cell(
                      item['Cargo']?.toString() ?? '',
                      fs: fs,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: _statusChip(
                      item['JobStatus']?.toString() ?? '',
                      fs: fs - 1,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: _cell(
                      item['EmployeeName']?.toString() ?? '',
                      fs: fs,
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Micro widgets ──────────────────────────────────────────────────────────

  Widget _cell(
      String text, {
        required double fs,
        bool bold = false,
        Color? color,
      }) {
    return Text(
      text.isEmpty ? '—' : text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.lato(
        fontSize: fs,
        fontWeight: bold ? FontWeight.bold : FontWeight.w600,
        color: color ?? AppTokens.textPrimary,
        letterSpacing: 0.2,
      ),
    );
  }

  /// Job number pill — branded colour, rounded border
  Widget _jobNoChip(String jobNo, {required double fs}) {
    if (jobNo.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTokens.brandPrimary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTokens.brandPrimary.withOpacity(0.35),
          width: 0.8,
        ),
      ),
      child: Text(
        jobNo,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.lato(
          fontSize: fs,
          fontWeight: FontWeight.bold,
          color: AppTokens.brandPrimary,
        ),
      ),
    );
  }

  /// Job status pill — tinted background matching the status
  Widget _statusChip(String status, {required double fs}) {
    if (status.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTokens.statusSuccess.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTokens.statusSuccess.withOpacity(0.35),
          width: 0.8,
        ),
      ),
      child: Text(
        status,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.lato(
          fontSize: fs,
          fontWeight: FontWeight.bold,
          color: AppTokens.statusSuccess,
        ),
      ),
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
          Icon(Icons.directions_boat_outlined,
              size: 64,
              color: Palette.grey400.withOpacity(0.6)),
          const SizedBox(height: 12),
          Text('No vessel planning records',
              style: GoogleFonts.lato(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTokens.textSecondary)),
          const SizedBox(height: 4),
          Text('Pull down to refresh',
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