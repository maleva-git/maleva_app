import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import '../bloc/employeemaster_bloc.dart';
import '../bloc/employeemaster_event.dart';
import '../bloc/employeemaster_state.dart';
import 'employeeadd_tab.dart';

const Color kPrimary      = Color(0xFF1555F3);
const Color kPrimaryDark  = Color(0xFF0D3DB5);
const Color kPrimaryLight = Color(0xFF4D7EF7);
const Color kAccent       = Color(0xFFE8EEFF);
const Color kWhite        = Colors.white;


class EmployeeViewPage extends StatelessWidget {
  const EmployeeViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => EmployeeMasterBloc.list(ctx),
      child: const _EmployeeListBody(),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────
class _EmployeeListBody extends StatelessWidget {
  const _EmployeeListBody();

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return BlocConsumer<EmployeeMasterBloc, EmployeeState>(
      listener: (context, state) async {
        if (state is EmployeeDeleteSuccess) {
          await objfun.ConfirmationOK(state.message, context);
        }
        if (state is EmployeeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is EmployeeListLoading) {
          return const Center(
              child: CircularProgressIndicator(color: kPrimary));
        }

        if (state is EmployeeError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    color: Colors.red, size: 48),
                const SizedBox(height: 12),
                Text(state.message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context
                      .read<EmployeeMasterBloc>()
                      .add(const LoadEmployeesmasterEvent()),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Retry"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary),
                ),
              ],
            ),
          );
        }

        if (state is EmployeeListLoaded) {
          return Container(
            color: Colors.grey.shade100,
            child: isTablet
                ? _buildTabletLayout(context, state)
                : _buildMobileLayout(context, state),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  // ══════════════════════════════════════════════════════
  // TABLET — Two Column
  // ══════════════════════════════════════════════════════
  Widget _buildTabletLayout(
      BuildContext context, EmployeeListLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── LEFT (55%) — Search + List ──
          Expanded(
            flex: 55,
            child: Column(
              children: [
                _buildSearchBar(context, isTablet: true),
                const SizedBox(height: 12),
                _buildTitleBar(context, isTablet: true),
                const SizedBox(height: 10),
                Expanded(
                  child: _buildList(context, state, isTablet: true),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // ── RIGHT (45%) — Detail Panel ──
          Expanded(
            flex: 45,
            child: state.selectedRecord != null
                ? _EmployeeDetailPanel(
              record: state.selectedRecord!,
              onEdit: () => _navigateToEdit(
                  context, state.selectedRecord!),
              onDelete: () => _confirmDelete(
                  context, state.selectedRecord!),
            )
                : _EmptyDetailPanel(),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // MOBILE — Single Column
  // ══════════════════════════════════════════════════════
  Widget _buildMobileLayout(
      BuildContext context, EmployeeListLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: _buildSearchBar(context, isTablet: false),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 18, vertical: 4),
          child: _buildTitleBar(context, isTablet: false),
        ),
        Expanded(
          child: _buildList(context, state, isTablet: false),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════
  // SHARED BUILDERS
  // ══════════════════════════════════════════════════════
  Widget _buildSearchBar(BuildContext context,
      {required bool isTablet}) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius:
        BorderRadius.circular(isTablet ? 14 : 12),
        border:
        Border.all(color: kPrimaryLight.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
              color: kPrimary.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: TextField(
        onChanged: (q) => context
            .read<EmployeeMasterBloc>()
            .add(SearchEmployeeMasterEvent(q)),
        decoration: InputDecoration(
          prefixIcon:
          const Icon(Icons.search, color: kPrimary),
          hintText: 'Search Employee...',
          hintStyle: GoogleFonts.lato(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: isTablet ? 16 : 14,
            horizontal: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildTitleBar(BuildContext context,
      {required bool isTablet}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Employee's List",
            style: GoogleFonts.lato(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: kPrimaryDark)),
        GestureDetector(
          onTap: () async {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const EmployeeAddPage()));
            context
                .read<EmployeeMasterBloc>()
                .add(const LoadEmployeesmasterEvent());
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: kAccent,
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.add_rounded,
                color: kPrimary, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildList(BuildContext context,
      EmployeeListLoaded state,
      {required bool isTablet}) {
    if (state.filteredRecords.isEmpty) {
      return Center(
        child: Text('No Employees found',
            style: GoogleFonts.lato(
                fontSize: 16,
                color: Colors.grey.shade600)),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(isTablet ? 4 : 16),
      itemCount: state.filteredRecords.length,
      itemBuilder: (context, i) {
        final record = state.filteredRecords[i];
        final isSelected = isTablet &&
            state.selectedRecord?.Id == record.Id;

        return _EmployeeCard(
          record: record,
          isTablet: isTablet,
          isSelected: isSelected,
          onTap: () {
            if (isTablet) {
              context.read<EmployeeMasterBloc>().add(
                  SelectEmployeeRecordEvent(record));
            } else {
              _showDetailsDialog(context, record);
            }
          },
          onEdit: () => _navigateToEdit(context, record),
          onDelete: () => _confirmDelete(context, record),
        );
      },
    );
  }

  Future<void> _navigateToEdit(
      BuildContext context, EmployeeDetailsModel record) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) =>
                EmployeeAddPage(existingEmployee: record)));
    context
        .read<EmployeeMasterBloc>()
        .add(const LoadEmployeesmasterEvent());
  }

  Future<void> _confirmDelete(
      BuildContext context, EmployeeDetailsModel record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text("Confirm Delete"),
        content: Text("Delete ${record.EmployeeName}?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete",
                style: TextStyle(color: kWhite)),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      context.read<EmployeeMasterBloc>().add(
          DeleteEmployeeMasterEvent(record.Id));
    }
  }

  void _showDetailsDialog(
      BuildContext context, EmployeeDetailsModel record) {
    showDialog(
      context: context,
      builder: (_) => _EmployeeDetailsDialog(record: record),
    );
  }
}

// ── Employee Card ─────────────────────────────────────────────────────────────
class _EmployeeCard extends StatelessWidget {
  final EmployeeDetailsModel record;
  final bool isTablet;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EmployeeCard({
    required this.record,
    required this.isTablet,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  String _fmt(String? d) {
    if (d == null || d.isEmpty) return '—';
    try {
      return DateFormat('dd-MM-yyyy').format(DateTime.parse(d));
    } catch (_) {
      return d;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = record.Active != 0;
    final statusColor =
    isActive ? Colors.green.shade600 : Colors.red.shade600;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: isTablet ? 10 : 14),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius:
          BorderRadius.circular(isTablet ? 14 : 18),
          border: Border.all(
            color: isSelected ? kPrimary : kAccent,
            width: isSelected ? 2.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: kPrimary.withOpacity(
                  isSelected ? 0.15 : 0.07),
              blurRadius: isSelected ? 14 : 10,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 10 : 16),
          child: isTablet
              ? _buildTabletContent(statusColor, isActive)
              : _buildMobileContent(statusColor, isActive),
        ),
      ),
    );
  }

  // Tablet: compact row — name + status + diff badge
  Widget _buildTabletContent(Color statusColor, bool isActive) {
    return Row(
      children: [
        Container(
          width: 38, height: 38,
          decoration: const BoxDecoration(
              color: kAccent, shape: BoxShape.circle),
          child: const Icon(Icons.person_rounded,
              color: kPrimary, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(record.EmployeeName ?? 'Unknown',
                  style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryDark),
                  overflow: TextOverflow.ellipsis),
              Text(record.MobileNo ?? 'No phone',
                  style: GoogleFonts.lato(
                      fontSize: 12,
                      color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(
                isActive
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                color: statusColor,
                size: 12),
            const SizedBox(width: 3),
            Text(isActive ? 'Active' : 'Inactive',
                style: GoogleFonts.lato(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11)),
          ]),
        ),
      ],
    );
  }

  // Mobile: full card (same as before)
  Widget _buildMobileContent(Color statusColor, bool isActive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 46, height: 46,
              decoration: const BoxDecoration(
                  color: kAccent, shape: BoxShape.circle),
              child: const Icon(Icons.person_rounded,
                  color: kPrimary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record.EmployeeName ?? 'Unknown',
                      style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryDark)),
                  Text(record.MobileNo ?? 'No phone',
                      style: GoogleFonts.lato(
                          fontSize: 13,
                          color: Colors.grey[600])),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                        isActive
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: statusColor,
                        size: 14),
                    const SizedBox(width: 4),
                    Text(isActive ? 'Active' : 'Inactive',
                        style: GoogleFonts.lato(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12)),
                  ]),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Divider(color: kAccent, thickness: 1),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _chip(Icons.calendar_today_rounded, "Joining",
              _fmt(record.JoiningDate)),
          _chip(Icons.event_rounded, "Leaving",
              _fmt(record.LeavingDate)),
        ]),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _actionBtn(
              icon: Icons.edit_rounded,
              label: "Edit",
              color: kPrimary,
              bg: kAccent,
              onTap: onEdit,
            ),
            const SizedBox(width: 8),
            _actionBtn(
              icon: Icons.delete_rounded,
              label: "Delete",
              color: Colors.red,
              bg: Colors.red.withOpacity(0.08),
              onTap: onDelete,
            ),
          ],
        ),
      ],
    );
  }

  Widget _chip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: kAccent,
          borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: kPrimary),
        const SizedBox(width: 4),
        Text("$label: $value",
            style: GoogleFonts.lato(
                fontSize: 12,
                color: kPrimaryDark,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.lato(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ]),
      ),
    );
  }
}

// ── Empty Detail Panel ────────────────────────────────────────────────────────
class _EmptyDetailPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kAccent, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: kPrimary.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64, height: 64,
            decoration: const BoxDecoration(
                color: kAccent, shape: BoxShape.circle),
            child: const Icon(Icons.touch_app_rounded,
                color: kPrimary, size: 32),
          ),
          const SizedBox(height: 16),
          Text("Select an employee",
              style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryDark)),
          const SizedBox(height: 6),
          Text("Tap any card to view details",
              style: GoogleFonts.lato(
                  fontSize: 13, color: Colors.grey[500])),
        ],
      ),
    );
  }
}

// ── Employee Detail Panel (tablet right column) ───────────────────────────────
class _EmployeeDetailPanel extends StatelessWidget {
  final EmployeeDetailsModel record;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EmployeeDetailPanel({
    required this.record,
    required this.onEdit,
    required this.onDelete,
  });

  String _fmt(String? d) {
    if (d == null || d.isEmpty) return '—';
    try {
      return DateFormat('dd-MM-yyyy').format(DateTime.parse(d));
    } catch (_) {
      return d;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = record.Active != 0;
    final statusColor =
    isActive ? Colors.green.shade600 : Colors.red.shade600;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kAccent, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: kPrimary.withOpacity(0.07),
              blurRadius: 16,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          // ── Header ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                vertical: 16, horizontal: 20),
            decoration: const BoxDecoration(
              color: kPrimary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(children: [
              const Icon(Icons.person_rounded,
                  color: kWhite, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  record.EmployeeName ?? 'Employee Details',
                  style: GoogleFonts.lato(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: kWhite),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Status badge in header
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: kWhite.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12)),
                child: Text(
                  isActive ? 'Active' : 'Inactive',
                  style: GoogleFonts.lato(
                      color: kWhite,
                      fontWeight: FontWeight.w600,
                      fontSize: 12),
                ),
              ),
            ]),
          ),

          // ── Edit + Delete buttons ──
          Padding(
            padding:
            const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded,
                      color: kPrimary, size: 16),
                  label: Text("Edit",
                      style: GoogleFonts.lato(
                          color: kPrimary,
                          fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_rounded,
                      color: kWhite, size: 16),
                  label: Text("Delete",
                      style: GoogleFonts.lato(
                          color: kWhite,
                          fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(10)),
                  ),
                ),
              ),
            ]),
          ),

          // ── Detail rows — Scrollable ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _row("Email", record.Email),
                _row("Employee Type", record.EmployeeType),
                _row("Currency", record.Employeecurrency),
                _row("Mobile No", record.MobileNo),
                _row("Address 1", record.Address1),
                _row("Address 2", record.Address2),
                _row("City", record.City),
                _row("State", record.State),
                _row("Country", record.Country),
                _row("GST No", record.GSTNO),
                _row("User Name", record.UserName),
                _row("Joining Date", _fmt(record.JoiningDate)),
                _row("Leaving Date", _fmt(record.LeavingDate)),
                _row("Rules Type", record.RulesType),
                _row("Bank Name", record.BankName),
                _row("Account No", record.AccountNo),
                _row("Account Code", record.AccountCode),
                _row("Latitude", record.Latitude),
                _row("Longitude", record.longitude),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                  color: kAccent,
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.info_outline_rounded,
                  color: kPrimary, size: 15),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: GoogleFonts.lato(
                            fontSize: 11,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w600)),
                    Text(
                      value?.isNotEmpty == true ? value! : '—',
                      style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: kPrimaryDark),
                    ),
                  ]),
            ),
          ]),
    );
  }
}

// ── Dialog (Mobile only) ──────────────────────────────────────────────────────
class _EmployeeDetailsDialog extends StatelessWidget {
  final EmployeeDetailsModel record;
  const _EmployeeDetailsDialog({required this.record});

  String _fmt(String? d) {
    if (d == null || d.isEmpty) return '—';
    try {
      return DateFormat('dd-MM-yyyy').format(DateTime.parse(d));
    } catch (_) {
      return d;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight:
            MediaQuery.of(context).size.height * 0.85),
        child: Container(
          decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: 20, horizontal: 24),
                decoration: const BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                child: Row(children: [
                  const Icon(Icons.person_rounded,
                      color: kWhite, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      record.EmployeeName ??
                          'Employee Details',
                      style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: kWhite),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ]),
              ),
              // Body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(children: [
                    _row("Email", record.Email),
                    _row("Employee Type",
                        record.EmployeeType),
                    _row("Currency",
                        record.Employeecurrency),
                    _row("Mobile No", record.MobileNo),
                    _row("Address 1", record.Address1),
                    _row("Address 2", record.Address2),
                    _row("City", record.City),
                    _row("State", record.State),
                    _row("Country", record.Country),
                    _row("GST No", record.GSTNO),
                    _row("User Name", record.UserName),
                    _row("Joining Date",
                        _fmt(record.JoiningDate)),
                    _row("Leaving Date",
                        _fmt(record.LeavingDate)),
                    _row("Rules Type", record.RulesType),
                    _row("Bank Name", record.BankName),
                    _row("Account No", record.AccountNo),
                    _row("Account Code",
                        record.AccountCode),
                    _row("Latitude", record.Latitude),
                    _row("Longitude", record.longitude),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimary,
                            padding:
                            const EdgeInsets.symmetric(
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(
                                    12)),
                            elevation: 0),
                        onPressed: () =>
                            Navigator.pop(context),
                        child: Text("Close",
                            style: GoogleFonts.lato(
                                color: kWhite,
                                fontSize: 16,
                                fontWeight:
                                FontWeight.bold)),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                  color: kAccent,
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.info_outline_rounded,
                  color: kPrimary, size: 15),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: GoogleFonts.lato(
                            fontSize: 11,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w600)),
                    Text(
                      value?.isNotEmpty == true
                          ? value!
                          : '—',
                      style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: kPrimaryDark),
                    ),
                  ]),
            ),
          ]),
    );
  }
}