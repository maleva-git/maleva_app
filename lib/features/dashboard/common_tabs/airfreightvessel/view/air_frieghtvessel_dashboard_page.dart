import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../core/models/model.dart';
import '../../../../../core/theme/palette.dart';
import 'package:maleva/core/utils/app_globals.dart';
import '../../../../mastersearch/JobStatus.dart';
import '../../../../mastersearch/Port.dart';
import '../../stockinentry/view/stock_in_entry_ui.dart';
import '../bloc/air_frieghtvessel_dashboard_bloc.dart';
import '../bloc/air_frieghtvessel_dashboard_event.dart';
import '../bloc/air_frieghtvessel_dashboard_state.dart';
import 'package:maleva/features/operations/models/job_status_model.dart';


class VesselDashboard extends StatelessWidget {
  const VesselDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VesselDashboardBloc()..add(VesselDashboardStarted()),
      child: const _VesselDashboardView(),
    );
  }
}

class _VesselDashboardView extends StatelessWidget {
  const _VesselDashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.grey50,
      body: SafeArea(
        child: BlocConsumer<VesselDashboardBloc, VesselDashboardState>(
          listener: (context, state) {
            if (state.errorMessage.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Palette.redAccent,
                  content: Text(state.errorMessage, style: GoogleFonts.lato(color: Palette.white)),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEliteHeader(context),
                _buildFilterSection(context, state),
                Expanded(
                  child: state.isLoading
                      ? const Center(child: SpinKitFoldingCube(color: Palette.blue500, size: 35.0))
                      : state.vesselList.isEmpty
                      ? Center(
                      child: Text('No Vessel Data Found',
                          style: GoogleFonts.lato(color: Palette.grey500, fontSize: 16)))
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    itemCount: state.vesselList.length,
                    itemBuilder: (ctx, index) {
                      final item = state.vesselList[index];
                      return _buildEliteCard(context, item, index);
                    },
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  // ─── Custom Header (Logout Button Removed) ─────────────────────────────
  Widget _buildEliteHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vessel Report',
            style: GoogleFonts.lato(
              color: Palette.blue700,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Manage and track your vessel statuses',
            style: GoogleFonts.lato(color: Palette.grey600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ─── Modern Filter Section ──────────────────────────────────────────────
  Widget _buildFilterSection(BuildContext context, VesselDashboardState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Palette.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Palette.brandBorder.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          // Row 1: Status & Port
          Row(
            children: [
              Expanded(
                child: _buildEliteInput(
                  hint: state.statusName.isEmpty ? "Select Status" : state.statusName,
                  icon: state.statusName.isEmpty ? Icons.search : Icons.close,
                  iconColor: state.statusName.isEmpty ? Palette.blue400 : Palette.redDanger,
                  onTap: () {
                    if (state.statusName.isEmpty) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const JobStatus(Searchby: 1, SearchId: 0)))
                          .then((_) {
                        if (!context.mounted) return;
                        if (AppGlobals.SelectJobStatusList.Id != 0) {
                          context.read<VesselDashboardBloc>().add(VesselStatusSelected(
                              statusId: AppGlobals.SelectJobStatusList.Id, statusName: AppGlobals.SelectJobStatusList.Name));
                          AppGlobals.SelectJobStatusList = JobStatusModel.Empty();
                        }
                      });
                    } else {
                      context.read<VesselDashboardBloc>().add(VesselStatusCleared());
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEliteInput(
                  hint: "Select Port",
                  icon: Icons.location_on_outlined,
                  iconColor: Palette.blue400,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const Port(Searchby: 1, SearchId: 0)))
                        .then((_) {
                      if (!context.mounted) return;
                      if (AppGlobals.SelectedPortName.isNotEmpty) {
                        context.read<VesselDashboardBloc>().add(VesselPortAdded(AppGlobals.SelectedPortName));
                        context.read<VesselDashboardBloc>().add(VesselLoadRequested());
                        AppGlobals.SelectedPortName = "";
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: Remarks & Action Buttons
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Palette.grey50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Palette.grey200),
                  ),
                  child: Text(
                    state.remarks.isEmpty ? "No Remarks..." : state.remarks,
                    style: GoogleFonts.lato(
                      color: state.remarks.isEmpty ? Palette.grey500 : Palette.textDark2,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _buildActionBtn(Icons.find_replace, Palette.blue600, () {
                context.read<VesselDashboardBloc>().add(VesselLoadRequested());
              }),
              const SizedBox(width: 8),
              _buildActionBtn(Icons.delete_outline, Palette.redDanger, () {
                context.read<VesselDashboardBloc>().add(VesselRemarksCleared());
                context.read<VesselDashboardBloc>().add(VesselLoadRequested());
              }),
            ],
          ),
          const SizedBox(height: 12),

          // Row 3: Dates
          Row(
            children: [
              _buildDateBadge(context, "From", state.fromDate, true, state),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.arrow_forward_rounded, color: Palette.grey400, size: 16),
              ),
              _buildDateBadge(context, "To", state.toDate, false, state),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Elite Vessel Card (Overflow Fixed) ──────────────────────────────────
  Widget _buildEliteCard(BuildContext context, Map<String, dynamic> item, int index) {
    bool isExpired = _isExpired(item);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isExpired ? Palette.rose.withOpacity(0.04) : Palette.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isExpired ? Palette.rose.withOpacity(0.3) : Palette.grey200),
        boxShadow: [
          BoxShadow(color: Palette.grey200.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onLongPress: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Stockinentry(
                  JobNo: item["JobNo"].toString(),
                  JobId: item["Id"],
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item["Loadingvesselname"] ?? "Unknown Vessel",
                        style: GoogleFonts.lato(color: Palette.textDark2, fontSize: 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Palette.blue50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item["Port"] ?? "No Port",
                        style: GoogleFonts.lato(color: Palette.blue600, fontSize: 12, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.airplane_ticket_outlined, size: 16, color: Palette.grey500),
                    const SizedBox(width: 6),
                    // Expanded added here to fix the RenderFlex overflow
                    Expanded(
                      child: Text(
                        "AWB: ${item["AWBNo"]}",
                        style: GoogleFonts.lato(color: Palette.grey600, fontSize: 13, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Palette.grey200),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "Status: ${item["JobStatus"]}",
                        style: GoogleFonts.lato(color: Palette.textNavy, fontSize: 11, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────

  Widget _buildEliteInput({required String hint, required IconData icon, required Color iconColor, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Palette.grey50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Palette.grey200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                hint,
                style: GoogleFonts.lato(color: Palette.grey600, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(icon, color: iconColor, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildDateBadge(BuildContext context, String label, String dateText, bool isFrom, VesselDashboardState state) {
    return Expanded(
      child: InkWell(
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2050),
          );
          if (picked != null) {
            if (!context.mounted) return;
            String formatted = DateFormat("yyyy-MM-dd").format(picked);
            if (isFrom) {
              context.read<VesselDashboardBloc>().add(VesselDatesChanged(fromDate: formatted, toDate: state.toDate));
            } else {
              context.read<VesselDashboardBloc>().add(VesselDatesChanged(fromDate: state.fromDate, toDate: formatted));
            }
            context.read<VesselDashboardBloc>().add(VesselLoadRequested());
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            color: Palette.blue50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Palette.blue200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today_rounded, size: 14, color: Palette.blue600),
              const SizedBox(width: 6),
              Text(
                dateText,
                style: GoogleFonts.lato(color: Palette.blue700, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isExpired(Map<String, dynamic> item) {
    DateTime? targetETA = item["SETB"] == "" ? null : DateTime.parse(item["SETB"]);
    DateTime? targetOETA = item["SOETB"] == "" ? null : DateTime.parse(item["SOETB"]);
    DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
    if ((targetETA != null && yesterday.isAfter(targetETA)) || (targetOETA != null && yesterday.isAfter(targetOETA))) {
      return true;
    }
    return false;
  }
}