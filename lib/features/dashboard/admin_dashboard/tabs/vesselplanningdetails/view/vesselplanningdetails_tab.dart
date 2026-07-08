import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/menu/menulist.dart';
import '../../../../../../core/di/injection.dart';
import '../../../../../../core/theme/tokens.dart';
import '../bloc/vesselplanningdetails_bloc.dart';
import '../bloc/vesselplanningdetails_event.dart';
import '../bloc/vesselplanningdetails_state.dart';

class VesselPlanningDetailsView extends StatelessWidget {
  final int masterId; // ✅ 1. Add the ID here
  const VesselPlanningDetailsView({super.key, required this.masterId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VesselPlanningDetailsBloc>()
      // ✅ 2. Pass the ID to the Startup event
        ..add(VesselPlanningDetailsStartupRequested(masterId)),
      child: _VesselPlanningDetailsView(masterId: masterId), // ✅ 3. Pass it to the inner view
    );
  }
}

class _VesselPlanningDetailsView extends StatelessWidget {
  final int masterId; // ✅ 4. Add the ID here
  const _VesselPlanningDetailsView({required this.masterId});

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
        // ✅ 5. FIX: Pass the masterId to the Retry event
        onRetry: () => ctx
            .read<VesselPlanningDetailsBloc>()
            .add(VesselPlanningDetailsStartupRequested(masterId)),
      )
          : _buildBody(ctx, state, isTablet),
    );
  }

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
          icon: const Icon(Icons.refresh_rounded, color: AppTokens.appBarIcon),
          tooltip: 'Refresh',
          // ✅ Passed ID here
          onPressed: () => ctx
              .read<VesselPlanningDetailsBloc>()
              .add(VesselPlanningDetailsRefreshRequested(masterId)),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext ctx,
      VesselPlanningDetailsState state, bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? 10 : 5),
      child: Column(
        children: [

          const SizedBox(height: 6),
          const SizedBox(height: 6),
          _SummaryPill(count: state.vesselPlanningList.length),

          const SizedBox(height: 4),

          Expanded(
            child: state.isEmpty
                ? const _EmptyWidget()
                : RefreshIndicator(
              color: AppTokens.brandPrimary,
              onRefresh: () async {
                // ✅ Passed ID here
                ctx.read<VesselPlanningDetailsBloc>().add(
                    VesselPlanningDetailsRefreshRequested(masterId));
                await Future.delayed(const Duration(milliseconds: 600));
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


// Removed _ColumnHeaderCard

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

class _VesselCard extends StatelessWidget {
  const _VesselCard({
    required this.index,
    required this.item,
    required this.isTablet,
  });

  final int index;
  final dynamic item;
  final bool isTablet;

  String _formatDate(dynamic date) {
    if (date == null || date.toString().isEmpty) return '-';
    String d = date.toString();
    if (d.contains('T')) {
      List<String> parts = d.split('T');
      if (parts.length == 2) {
        String time = parts[1].length > 5 ? parts[1].substring(0, 5) : parts[1];
        return '${parts[0]} $time';
      }
    }
    return d;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      color: AppTokens.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppTokens.brandPrimary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            // Row 1
            Row(children: [
              Expanded(child: _GridItem('Job No', item['JobNo']?.toString() ?? '', isPrimary: true)),
              Expanded(child: _GridItem('Customer', item['CustomerName']?.toString() ?? '')),
            ]),
            const SizedBox(height: 12),
            // Row 2
            Row(children: [
              Expanded(child: _GridItem('Vessel', item['Loadingvesselname']?.toString() ?? '')),
              Expanded(child: _GridItem('Port', item['OPort']?.toString() ?? '')),
            ]),
            const SizedBox(height: 12),
            // Row 3
            Row(children: [
              Expanded(child: _GridItem('Job Type', item['JobName']?.toString() ?? '')),
              Expanded(child: _GridItem('Status', item['JobStatus']?.toString() ?? '', isStatus: true)),
            ]),
            const SizedBox(height: 12),
            // Row 4
            Row(children: [
              Expanded(child: _GridItem('Package', item['pkg']?.toString() ?? '')),
              Expanded(child: _GridItem('Remarks', item['Remarks']?.toString() ?? '')),
            ]),
            const SizedBox(height: 12),
            const Divider(color: Colors.black12, height: 1),
            const SizedBox(height: 12),
            // Row 5: OETA / ETA
            Row(children: [
              Expanded(child: _GridItem('OETA', _formatDate(item['OETA']))),
              Expanded(child: _GridItem('ETA', _formatDate(item['ETA']))),
            ]),
            const SizedBox(height: 12),
            // Row 6: OETB / ETB
            Row(children: [
              Expanded(child: _GridItem('OETB', _formatDate(item['OETB']))),
              Expanded(child: _GridItem('ETB', _formatDate(item['ETB']))),
            ]),
            const SizedBox(height: 12),
            // Row 7: OETD / ETD
            Row(children: [
              Expanded(child: _GridItem('OETD', _formatDate(item['OETD']))),
              Expanded(child: _GridItem('ETD', _formatDate(item['ETD']))),
            ]),
          ],
        ),
      ),
    );
  }
}

// ── Micro widgets ──────────────────────────────────────────────────────────

class _GridItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isPrimary;
  final bool isStatus;

  const _GridItem(this.label, this.value, {super.key, this.isPrimary = false, this.isStatus = false});

  @override
  Widget build(BuildContext context) {
    String displayValue = value.isEmpty ? '-' : value;
    
    Widget contentWidget;
    if (isPrimary && displayValue != '-') {
      contentWidget = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppTokens.brandPrimary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(displayValue, style: GoogleFonts.lato(color: AppTokens.brandPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
      );
    } else if (isStatus && displayValue != '-') {
      contentWidget = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppTokens.statusSuccess.withOpacity(0.12),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(displayValue, style: GoogleFonts.lato(color: AppTokens.statusSuccess, fontWeight: FontWeight.bold, fontSize: 13)),
      );
    } else {
      contentWidget = Text(displayValue, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.lato(color: AppTokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 13));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.lato(color: AppTokens.planTextMuted, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        contentWidget,
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