import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/MasterSearch/Employee.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/Transaction/Planning/PlanningDetails.dart';
import 'package:maleva/DashBoard/CustomerService/CustDashboard.dart';
import 'package:maleva/DashBoard/TransportDB/TransportDashboard.dart';
import 'package:maleva/DashBoard/User/UserDashboard.dart';
import '../../../../core/theme/tokens.dart';
import '../../../dashboard/admin_dashboard/view/admin_dashboard.dart';
import '../../../dashboard/operationadmin_dashboard/view/operationadmin_dashboard.dart';
import '../bloc/planning_bloc.dart';
import '../bloc/planning_event.dart';
import '../bloc/planning_state.dart';
import 'package:maleva/core/colors/colors.dart' as colour;

TextStyle _body(double size,
    {Color color = colour.kText, FontWeight fw = FontWeight.normal}) =>
    GoogleFonts.dmSans(fontSize: size, color: color, fontWeight: fw);

TextStyle _label(double size,
    {Color color = colour.kTextDim, FontWeight fw = FontWeight.w600}) =>
    GoogleFonts.dmSans(fontSize: size, color: color, fontWeight: fw);

class PlanningView extends StatelessWidget {
  const PlanningView({super.key});

  static String get _today =>
      DateFormat("yyyy-MM-dd").format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PlanningBloc(context)
        ..add(LoadPlanningEvent(
          fromDate: _today,
          toDate: _today,
          employeeId: objfun.EmpRefId,
          planningNo: '',
        )),
      child: const _PlanningScaffold(),
    );
  }
}

class _PlanningScaffold extends StatelessWidget {
  const _PlanningScaffold();

  void _onBackPressed(BuildContext context) {
    final role = objfun.storagenew.getString('RulesType') ?? '';
    final Widget dest = switch (role) {
      'ADMIN'          => const NewAdminDashboard(),
      'SALES'          => const CustDashboard(),
      'TRANSPORTATION' => const TransportDashboard(),
      'OPERATIONADMIN' => const OperationAdminDashboard(),
      _                => const Homemobile(),
    };
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => dest));
  }

  @override
  Widget build(BuildContext context) {
    final userName =
        objfun.storagenew.getString('Username') ?? '';
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return BlocListener<PlanningBloc, PlanningState>(
      // Navigate to edit page when password verified
      listenWhen: (_, curr) => curr is PlanningNavigateToEdit,
      listener: (context, state) {
        if (state is PlanningNavigateToEdit) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const PlanningDetailsView()),
          );
        }
      },
      child: WillPopScope(
        onWillPop: () async {
          _onBackPressed(context);
          return false;
        },
        child: Scaffold(
          backgroundColor: colour.kBg,
          appBar: _buildAppBar(context, userName),
          drawer: const Menulist(),
          body: BlocBuilder<PlanningBloc, PlanningState>(
            builder: (context, state) {
              if (state is PlanningLoading) {
                return const _FullScreenLoader();
              }
              if (state is PlanningError) {
                return _ErrorView(
                  message: state.message,
                  onRetry: () => context.read<PlanningBloc>().add(
                    LoadPlanningEvent(
                      fromDate:
                      DateFormat("yyyy-MM-dd").format(DateTime.now()),
                      toDate:
                      DateFormat("yyyy-MM-dd").format(DateTime.now()),
                      employeeId: objfun.EmpRefId,
                      planningNo: '',
                    ),
                  ),
                );
              }
              if (state is PlanningLoaded) {
                return isTablet
                    ? _TabletLayout(state: state)
                    : _MobileLayout(state: state);
              }
              return const SizedBox();
            },
          ),
          floatingActionButton: _FilterFab(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, String userName) {
    return AppBar(
      backgroundColor: colour.kSurface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: colour.kTextDim, size: 20),
        onPressed: () => _onBackPressed(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Planning',
              style: GoogleFonts.dmSerifDisplay(
                  fontSize: 18,
                  color: colour.kText,
                  fontWeight: FontWeight.bold)),
          Text(userName,
              style: _label(11, color: AppTokens.planTextMuted)),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.transparent,
              colour.kGold.withOpacity(0.4),
              Colors.transparent,
            ]),
          ),
        ),
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  final PlanningLoaded state;
  const _MobileLayout({required this.state});

  @override
  Widget build(BuildContext context) {
    return state.masterList.isEmpty
        ? const _EmptyView()
        : ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: state.masterList.length,
      itemBuilder: (context, index) => _PlanningCard(
        master: state.masterList[index],
        index: index,
        state: state,
        isTablet: false,
      ),
    );
  }
}

class _TabletLayout extends StatelessWidget {
  final PlanningLoaded state;
  const _TabletLayout({required this.state});

  @override
  Widget build(BuildContext context) {
    return state.masterList.isEmpty
        ? const _EmptyView()
        : ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
      itemCount: state.masterList.length,
      itemBuilder: (context, index) => _PlanningCard(
        master: state.masterList[index],
        index: index,
        state: state,
        isTablet: true,
      ),
    );
  }
}

class _PlanningCard extends StatelessWidget {
  final PlanningMasterModel master;
  final int index;
  final PlanningLoaded state;
  final bool isTablet;

  const _PlanningCard({
    required this.master,
    required this.index,
    required this.state,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final isExpanded = state.expandedIndex == index;
    final details = state.detailsMap[index] ?? [];

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 14 : 12),
      decoration: BoxDecoration(
        color: colour.kSurface,
        borderRadius: BorderRadius.circular(isTablet ? 22 : 18),
        border: Border.all(
          color: isExpanded
              ? colour.kGold.withOpacity(0.4)
              : colour.kBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
          if (isExpanded)
            BoxShadow(
              color: colour.kGold.withOpacity(0.06),
              blurRadius: 20,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isTablet ? 22 : 18),
        child: Column(
          children: [
            // ── Left accent bar + main content ──
            IntrinsicHeight(
              child: Row(
                children: [
                  // Gold accent bar
                  Container(
                    width: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isExpanded
                            ? [colour.kGold, colour.kGold.withOpacity(0.3)]
                            : [colour.kCobalt, colour.kCobalt.withOpacity(0.2)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onLongPress: () => _showPasswordDialog(context),
                      child: Padding(
                        padding: EdgeInsets.all(isTablet ? 18 : 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Row 1: Planning No + Date
                            Row(
                              children: [
                                // Planning No chip
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: colour.kCobalt.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: colour.kCobalt.withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    master.PLANINGNoDisplay,
                                    style: _body(isTablet ? 13 : 12,
                                        color: colour.kCobalt,
                                        fw: FontWeight.w700),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Row(children: [
                                  const Icon(Icons.calendar_today_rounded,
                                      size: 12, color: AppTokens.planTextMuted),
                                  const SizedBox(width: 5),
                                  Text(
                                    master.PLANINGDate.toString(),
                                    style: _label(isTablet ? 12 : 11),
                                  ),
                                ]),
                              ],
                            ),
                            // Row 2: Remarks
                            if (master.Remarks.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(children: [
                                const Icon(Icons.notes_rounded,
                                    size: 12, color: AppTokens.planTextMuted),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    master.Remarks,
                                    style: _label(isTablet ? 12 : 11),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ]),
                            ],
                            const SizedBox(height: 10),
                            // Row 3: Action buttons
                            Row(children: [
                              // Expand toggle
                              _ActionBtn(
                                icon: isExpanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                label: isExpanded ? 'Hide' : 'Details',
                                color: isExpanded ? colour.kGold : colour.kCobalt,
                                onTap: () => context
                                    .read<PlanningBloc>()
                                    .add(TogglePlanningExpand(
                                  index: index,
                                  masterRefId: master.Id,
                                )),
                              ),
                              const SizedBox(width: 8),
                              // PDF Export
                              _ActionBtn(
                                icon: Icons.picture_as_pdf_outlined,
                                label: 'Export',
                                color: colour.kDanger,
                                onTap: () => context
                                    .read<PlanningBloc>()
                                    .add(SharePlanningPdfEvent(
                                  id: master.Id,
                                  planningNoDisplay:
                                  master.PLANINGNoDisplay,
                                )),
                              ),
                              // PDF loading indicator
                              if (state is PlanningPdfLoading) ...[
                                const SizedBox(width: 10),
                                const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colour.kGold,
                                  ),
                                ),
                              ]
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Expanded Details Section ──
            if (isExpanded) ...[
              Container(height: 1, color: colour.kBorder),
              _DetailsSection(
                  details: details, isTablet: isTablet),
            ],
          ],
        ),
      ),
    );
  }

  void _showPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dContext) => _PasswordDialog(
        onConfirm: (pwd) async {
          Navigator.pop(dContext);
          // Verify password
          final resultData = await objfun.apiAllinoneSelectArray(
            "${objfun.apiEditPassword}$pwd&type=EditPassword&Comid=${objfun.Comid}",
            null, null, context,
          );
          if (resultData != null &&
              resultData.isNotEmpty &&
              resultData["IsSuccess"] == true) {
            context.read<PlanningBloc>().add(EditPlanningEvent(
              id: master.Id,
              planningNo: master.PLANINGNo,
            ));
          } else {
            objfun.ConfirmationOK("Invalid Password !!!", context);
          }
        },
      ),
    );
  }
}

class _DetailsSection extends StatelessWidget {
  final List<dynamic> details;
  final bool isTablet;
  const _DetailsSection(
      {required this.details, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    if (details.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text('No job records',
              style: _label(13, color: AppTokens.planTextMuted)),
        ),
      );
    }

    return Container(
      color: colour.kSurface2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sub-header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: colour.kGold,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text('Job Details',
                  style: _body(12,
                      color: colour.kGold, fw: FontWeight.w700)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colour.kGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border:
                  Border.all(color: colour.kGold.withOpacity(0.3)),
                ),
                child: Text('${details.length}',
                    style: _label(11, color: colour.kGold)),
              ),
            ]),
          ),
          // Column headers
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
            child: Row(children: [
              Expanded(
                  flex: 2,
                  child: Text('Job No',
                      style: _label(10,
                          color: AppTokens.planTextMuted,
                          fw: FontWeight.w700))),
              Expanded(
                  flex: 2,
                  child: Text('Job Date',
                      style: _label(10,
                          color: AppTokens.planTextMuted,
                          fw: FontWeight.w700))),
              Expanded(
                  flex: 2,
                  child: Text('Truck',
                      style: _label(10,
                          color: AppTokens.planTextMuted,
                          fw: FontWeight.w700))),
            ]),
          ),
          // Detail rows
          ...details.map((item) => _DetailRow(
              item: item, isTablet: isTablet)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isTablet;
  const _DetailRow({required this.item, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: EdgeInsets.all(isTablet ? 14 : 12),
      decoration: BoxDecoration(
        color: colour.kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colour.kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              flex: 2,
              child: Text(
                '${item["JobNo"]}',
                style: _body(isTablet ? 12 : 11,
                    color: colour.kCobalt, fw: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${item["JobDate"]}',
                style: _label(isTablet ? 12 : 11),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${item["TruckName"]}',
                style: _body(isTablet ? 12 : 11,
                    color: colour.kSuccess, fw: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]),
          if ('${item["Remarks"]}'.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.notes_rounded,
                  size: 11, color: AppTokens.planTextMuted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${item["Remarks"]}',
                  style: _label(isTablet ? 11 : 10,
                      color: AppTokens.planTextMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
          ],
        ],
      ),
    );
  }
}

class _FilterFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showFilterSheet(context),
      backgroundColor: AppTokens.invoiceHeaderStart,
      icon: const Icon(Icons.tune_rounded, color: colour.kBg, size: 20),
      label: Text('Filter',
          style: _body(13, color: colour.kBg, fw: FontWeight.w700)),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final bloc = context.read<PlanningBloc>();
    final loaded = bloc.state is PlanningLoaded
        ? bloc.state as PlanningLoaded
        : null;

    // Local controllers for the sheet
    final empController = TextEditingController(
        text: loaded?.employeeName ?? '');
    final planNoController = TextEditingController(
        text: loaded?.planningNo ?? '');
    var fromDate = loaded?.fromDate ??
        DateFormat("yyyy-MM-dd").format(DateTime.now());
    var toDate = loaded?.toDate ??
        DateFormat("yyyy-MM-dd").format(DateTime.now());
    var checkLoggedEmp = loaded?.checkLoggedEmp ?? true;
    var empId = loaded?.employeeId ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (_, setSheetState) {
          return Container(
            decoration: const BoxDecoration(
              color: colour.kSurface,
              borderRadius:
              BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(
                  top: BorderSide(color: colour.kBorder, width: 1)),
            ),
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom:
              MediaQuery.of(sheetCtx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colour.kBorder,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Row(children: [
                    Container(
                      width: 3,
                      height: 18,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTokens.invoiceHeaderStart, colour.kCobalt],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('Filter Planning',
                        style: GoogleFonts.dmSerifDisplay(
                            fontSize: 18,
                            color: colour.kText)),
                  ]),

                  const SizedBox(height: 20),

                  // Date row
                  Row(children: [
                    Expanded(
                      child: _SheetDateBtn(
                        label: 'From',
                        date: fromDate,
                        onPick: (d) =>
                            setSheetState(() => fromDate = d),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SheetDateBtn(
                        label: 'To',
                        date: toDate,
                        onPick: (d) =>
                            setSheetState(() => toDate = d),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 14),

                  // Employee field
                  _SheetTextField(
                    controller: empController,
                    hint: 'Select Employee',
                    readOnly: true,
                    suffixIcon: Icon(
                      empController.text.isNotEmpty
                          ? Icons.close_rounded
                          : Icons.search_rounded,
                      color: checkLoggedEmp
                          ? AppTokens.planTextMuted
                          : colour.kCobalt,
                    ),
                    onSuffixTap: checkLoggedEmp
                        ? null
                        : () async {
                      if (empController.text.isEmpty) {
                        await OnlineApi.SelectEmployee(
                            context, 'sales', 'admin');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                              const Employee(
                                  Searchby: 1,
                                  SearchId: 0)),
                        ).then((_) {
                          setSheetState(() {
                            empController.text = objfun
                                .SelectEmployeeList
                                .AccountName;
                            empId = objfun
                                .SelectEmployeeList.Id;
                            objfun.SelectEmployeeList =
                                EmployeeModel.Empty();
                          });
                        });
                      } else {
                        setSheetState(() {
                          empController.text = '';
                          empId = 0;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 14),

                  // Planning No field
                  _SheetTextField(
                    controller: planNoController,
                    hint: 'Planning No',
                    textCapitalization: TextCapitalization.characters,
                  ),

                  const SizedBox(height: 14),

                  // L.Emp checkbox
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: colour.kSurface2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colour.kBorder),
                    ),
                    child: Row(children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: Checkbox(
                          value: checkLoggedEmp,
                          activeColor: AppTokens.invoiceHeaderStart,
                          checkColor: colour.kBg,
                          side: const BorderSide(
                              color: AppTokens.planTextMuted, width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                          onChanged: (v) => setSheetState(
                                  () => checkLoggedEmp = v!),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('Logged-in Employee',
                          style: _body(13,
                              color: colour.kTextDim,
                              fw: FontWeight.w500)),
                    ]),
                  ),

                  const SizedBox(height: 22),

                  // Action buttons
                  Row(children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(sheetCtx);
                          final resolvedEmpId = checkLoggedEmp
                              ? objfun.EmpRefId
                              : empId;
                          bloc.add(LoadPlanningEvent(
                            fromDate: fromDate,
                            toDate: toDate,
                            employeeId: resolvedEmpId,
                            planningNo: planNoController.text,
                          ));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTokens.invoiceHeaderStart,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: Text('View',
                            style: _body(14,
                                color: colour.kBg,
                                fw: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(sheetCtx),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colour.kTextDim,
                          side: const BorderSide(color: colour.kBorder),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(14)),
                        ),
                        child: Text('Close',
                            style: _body(14,
                                color: colour.kTextDim,
                                fw: FontWeight.w600)),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PasswordDialog extends StatefulWidget {
  final Future<void> Function(String password) onConfirm;
  const _PasswordDialog({required this.onConfirm});

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _ctrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: colour.kSurface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTokens.invoiceHeaderStart.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppTokens.invoiceHeaderStart.withOpacity(0.3)),
              ),
              child: const Icon(Icons.lock_outline_rounded,
                  color: AppTokens.invoiceHeaderStart, size: 28),
            ),
            const SizedBox(height: 16),
            Text('Edit Password',
                style: GoogleFonts.dmSerifDisplay(
                    fontSize: 18, color: colour.kText)),
            const SizedBox(height: 4),
            Text('Enter password to edit this planning',
                style: _label(12, color: AppTokens.planTextMuted)),
            const SizedBox(height: 20),
            // Password field
            TextField(
              controller: _ctrl,
              autofocus: true,
              obscureText: true,
              textCapitalization: TextCapitalization.characters,
              style: _body(14, color: colour.kText, fw: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Enter password',
                hintStyle: _label(13),
                filled: true,
                fillColor: colour.kSurface2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: colour.kBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: colour.kBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                  const BorderSide(color: AppTokens.invoiceHeaderStart, width: 1.5),
                ),
                prefixIcon: const Icon(Icons.key_rounded,
                    color: AppTokens.invoiceHeaderStart, size: 18),
              ),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () async {
                    if (_ctrl.text.isEmpty) {
                      objfun.ConfirmationOK(
                          "Enter Password !!", context);
                      return;
                    }
                    setState(() => _loading = true);
                    await widget.onConfirm(_ctrl.text);
                    setState(() => _loading = false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTokens.invoiceHeaderStart,
                    padding:
                    const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colour.kBg,
                    ),
                  )
                      : Text('Confirm',
                      style: _body(14,
                          color: colour.kBg, fw: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colour.kTextDim,
                    side: const BorderSide(color: colour.kBorder),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Cancel',
                      style: _body(14,
                          color: colour.kTextDim,
                          fw: FontWeight.w600)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}


class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: _body(11, color: color, fw: FontWeight.w700)),
        ]),
      ),
    );
  }
}

class _SheetDateBtn extends StatelessWidget {
  final String label;
  final String date;
  final void Function(String) onPick;

  const _SheetDateBtn({
    required this.label,
    required this.date,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final displayDate = DateFormat('dd MMM yyyy')
        .format(DateTime.parse(date));
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.parse(date),
          firstDate: DateTime(1900),
          lastDate: DateTime(2050),
          builder: (_, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppTokens.invoiceHeaderStart,
                onPrimary: colour.kBg,
                surface: colour.kSurface,
                onSurface: colour.kText,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          onPick(DateFormat("yyyy-MM-dd").format(picked));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colour.kSurface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colour.kBorder),
        ),
        child: Row(children: [
          const Icon(Icons.calendar_today_rounded,
              size: 13, color: AppTokens.invoiceHeaderStart),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: _label(9, color: AppTokens.planTextMuted)),
                Text(displayDate,
                    style: _body(12,
                        color: colour.kText, fw: FontWeight.w600)),
              ]),
        ]),
      ),
    );
  }
}

class _SheetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool readOnly;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixTap;
  final TextCapitalization textCapitalization;

  const _SheetTextField({
    required this.controller,
    required this.hint,
    this.readOnly = false,
    this.suffixIcon,
    this.onSuffixTap,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      textCapitalization: textCapitalization,
      style: _body(13, color: colour.kText, fw: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: _label(13),
        filled: true,
        fillColor: colour.kSurface2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: colour.kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: colour.kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: colour.kCobalt, width: 1.5),
        ),
        suffixIcon: suffixIcon != null
            ? GestureDetector(
            onTap: onSuffixTap, child: suffixIcon)
            : null,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
      ),
    );
  }
}

class _FullScreenLoader extends StatefulWidget {
  const _FullScreenLoader();
  @override
  State<_FullScreenLoader> createState() => _FullScreenLoaderState();
}

class _FullScreenLoaderState extends State<_FullScreenLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.9)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTokens.invoiceHeaderStart.withOpacity(_anim.value * 0.15),
                border: Border.all(
                    color: AppTokens.invoiceHeaderStart.withOpacity(_anim.value), width: 2),
              ),
              child: Icon(Icons.local_shipping_rounded,
                  color: AppTokens.invoiceHeaderStart.withOpacity(_anim.value), size: 28),
            ),
            const SizedBox(height: 16),
            Text('Loading Planning...',
                style: _label(13, color: AppTokens.planTextMuted)),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colour.kSurface,
            shape: BoxShape.circle,
            border: Border.all(color: colour.kBorder),
          ),
          child: const Icon(Icons.inbox_rounded,
              color: AppTokens.planTextMuted, size: 36),
        ),
        const SizedBox(height: 14),
        Text('No Planning Records',
            style:
            GoogleFonts.dmSerifDisplay(fontSize: 18, color: colour.kText)),
        const SizedBox(height: 6),
        Text('Try adjusting your filter',
            style: _label(13, color: AppTokens.planTextMuted)),
      ]),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colour.kDanger.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: colour.kDanger.withOpacity(0.3)),
            ),
            child: const Icon(Icons.error_outline_rounded,
                color: colour.kDanger, size: 32),
          ),
          const SizedBox(height: 14),
          Text('Something went wrong',
              style: GoogleFonts.dmSerifDisplay(
                  fontSize: 18, color: colour.kText)),
          const SizedBox(height: 8),
          Text(message,
              style: _label(12, color: AppTokens.planTextMuted),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: colour.kCobalt,
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.refresh_rounded,
                color: colour.kText, size: 18),
            label: Text('Retry',
                style: _body(14, color: colour.kText, fw: FontWeight.w600)),
          ),
        ]),
      ),
    );
  }
}