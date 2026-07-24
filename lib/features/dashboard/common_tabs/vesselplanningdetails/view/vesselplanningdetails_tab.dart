import 'package:maleva/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/menu/menulist.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/tokens.dart';
import '../bloc/vesselplanningdetails_bloc.dart';
import '../bloc/vesselplanningdetails_event.dart';
import '../bloc/vesselplanningdetails_state.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/colors/colors.dart' as colour;

class VesselPlanningDetailsView extends StatelessWidget {
  final int masterId; // ✅ 1. Add the ID here
  const VesselPlanningDetailsView({super.key, required this.masterId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VesselPlanningDetailsBloc>()
      // ✅ 2. Pass the ID to the Startup event
        ..add(VesselPlanningDetailsStartupRequested(masterId)),
      child: _VesselPlanningDetailsView(masterId: masterId), 
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
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            Navigator.pop(context);
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
        AppGlobals.storagenew.getString('Username') ?? '';
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
            style: AppTypography.heading1(color: AppTokens.appBarTitle, fontWeight: FontWeight.bold),
          ),
          if (userName.isNotEmpty)
            Text(
              userName,
              style: AppTypography.bodySmall(color: AppTokens.invoicePillBg, fontWeight: FontWeight.w500),
            ),
        ],
      ),
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
                : _buildDataTable(state.vesselPlanningList),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(List<dynamic> details) {
    final headerStyle = AppTypography.bodyMedium(color: Colors.white, fontWeight: FontWeight.w700);
    final rowStyle = AppTypography.bodyMedium(color: colour.kTextDark, fontWeight: FontWeight.w600);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTokens.maintCardBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: const AlwaysScrollableScrollPhysics(),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(colour.kHeaderGradEnd),
              dataRowMinHeight: 40,
              dataRowMaxHeight: 40,
              columnSpacing: 20,
              horizontalMargin: 16,
              dividerThickness: 0.5,
              columns: [
                DataColumn(label: Text('JOB NO', style: headerStyle)),
                DataColumn(label: Text('CUSTOMER', style: headerStyle)),
                DataColumn(label: Text('VESSEL', style: headerStyle)),
                DataColumn(label: Text('PORT', style: headerStyle)),
                DataColumn(label: Text('JOB TYPE', style: headerStyle)),
                DataColumn(label: Text('STATUS', style: headerStyle)),
                DataColumn(label: Text('PKG', style: headerStyle)),
                DataColumn(label: Text('REMARKS', style: headerStyle)),
                DataColumn(label: Text('OETA', style: headerStyle)),
                DataColumn(label: Text('ETA', style: headerStyle)),
                DataColumn(label: Text('OETB', style: headerStyle)),
                DataColumn(label: Text('ETB', style: headerStyle)),
                DataColumn(label: Text('OETD', style: headerStyle)),
                DataColumn(label: Text('ETD', style: headerStyle)),
              ],
              rows: details.map<DataRow>((item) {
                return DataRow(
                  cells: [
                    DataCell(Text(item['JobNo']?.toString() ?? '-', style: rowStyle.copyWith(color: AppTokens.brandPrimary, fontWeight: FontWeight.bold))),
                    DataCell(Text(item['CustomerName']?.toString() ?? '-', style: rowStyle)),
                    DataCell(Text(item['Loadingvesselname']?.toString() ?? '-', style: rowStyle)),
                    DataCell(Text(item['OPort']?.toString() ?? '-', style: rowStyle)),
                    DataCell(Text(item['JobName']?.toString() ?? '-', style: rowStyle)),
                    DataCell(Text(item['JobStatus']?.toString() ?? '-', style: rowStyle.copyWith(color: AppTokens.statusSuccess))),
                    DataCell(Text(item['pkg']?.toString() ?? '-', style: rowStyle)),
                    DataCell(Text(item['Remarks']?.toString() ?? '-', style: rowStyle)),
                    DataCell(Text(_formatDate(item['SOETA']), style: rowStyle)),
                    DataCell(Text(_formatDate(item['SETA']), style: rowStyle)),
                    DataCell(Text(_formatDate(item['SOETB']), style: rowStyle)),
                    DataCell(Text(_formatDate(item['SETB']), style: rowStyle)),
                    DataCell(Text(_formatDate(item['SOETD']), style: rowStyle)),
                    DataCell(Text(_formatDate(item['SETD']), style: rowStyle)),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(dynamic dtStr) {
    if (dtStr == null || dtStr.toString().isEmpty || dtStr.toString() == '-') return '-';
    try {
      DateTime dt = DateTime.parse(dtStr.toString());
      if (dt.year == 1900) return '-';
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (e) {
      return dtStr.toString();
    }
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
          boxShadow: const [
            BoxShadow(color: Palette.brandGlow, blurRadius: 6)
          ],
        ),
        child: Text(
          'Total: $count',
          style: AppTypography.bodyMedium(color: Palette.white, fontWeight: FontWeight.w600),
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
              color: Palette.grey400.withValues(alpha: 0.6)),
          const SizedBox(height: 12),
          Text('No vessel planning records',
              style: AppTypography.heading2(color: AppTokens.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Pull down to refresh',
              style: AppTypography.bodyMedium(color: AppTokens.textMuted)),
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
                style: AppTypography.heading2(color: AppTokens.textPrimary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(message,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMedium(color: AppTokens.textMuted)),
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