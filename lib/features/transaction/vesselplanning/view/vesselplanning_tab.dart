import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/core/models/model.dart';
import '../../../../core/theme/tokens.dart';
import '../../../dashboard/admin_dashboard/tabs/vesselplanningdetails/view/vesselplanningdetails_tab.dart';
import '../../../mastersearch/Employee.dart';
import '../bloc/vesselplanning_bloc.dart';
import '../bloc/vesselplanning_event.dart';
import '../bloc/vesselplanning_state.dart';



const kGradient = LinearGradient(
  colors: [AppTokens.invoiceHeaderStart, colour.kHeaderGradEnd],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const kGradientVertical = LinearGradient(
  colors: [AppTokens.invoiceHeaderStart, Color(0xFF2D56C8)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);


// ─── Root Widget ──────────────────────────────────────────────────────────────
class VesselPlanningView extends StatelessWidget {
  const VesselPlanningView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final today = DateFormat("yyyy-MM-dd").format(DateTime.now());

        return VesselPlanningBloc()
          ..add(VesselPlanningStarted())
          ..add(VesselPlanningFilterChanged(
            fromDate: today,
            toDate: today,
            planningNo: '',
            empId: 0,
            empName: '', // 💥 Itha add pannunga
            isLoggedInEmp: false,
          ));
      },
      child: const _VesselPlanningPage(),
    );
  }
}

class _VesselPlanningPage extends StatelessWidget {
  const _VesselPlanningPage();

  @override
  Widget build(BuildContext context) {
    final isTablet = objfun.MalevaScreen != 1;
    final userName = objfun.storagenew.getString('Username') ?? '';

    return BlocListener<VesselPlanningBloc, VesselPlanningState>(
      listener: (context, state) {
        if (state is VesselPlanningNavigateToEdit) {
          Navigator.push(
            context,
            MaterialPageRoute(
              // ✅ Pass the ID from the state into the Details View
              builder: (_) => VesselPlanningDetailsView(masterId: state.id),
            ),
          );
        }
        if (state is VesselPlanningError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: GoogleFonts.lato(color: Colors.white)),
              backgroundColor: const Color(0xFFB33040),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: colour.kPageBg,
        appBar: _buildAppBar(context, userName, isTablet),
        drawer: const Menulist(),
        body: BlocBuilder<VesselPlanningBloc, VesselPlanningState>(
          builder: (context, state) {
            if (state is VesselPlanningLoading || state is VesselPlanningInitial) {
              return const Center(
                child: SpinKitFoldingCube(color: colour.kHeaderGradEnd, size: 35.0),
              );
            }
            if (state is VesselPlanningLoaded) {
              return _VesselPlanningBody(state: state, isTablet: isTablet);
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: _VPFab(
          onPressed: () => _showFilterSheet(context),
        ),
      ),
    );
  }

  // ─── AppBar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(
      BuildContext context, String userName, bool isTablet) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      toolbarHeight: isTablet ? 70 : 62,
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: kGradient),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        color: Colors.white,
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vessel Planning',
            style: GoogleFonts.lato(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: isTablet ? objfun.FontMedium + 2 : objfun.FontMedium,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            userName,
            style: GoogleFonts.lato(
              color: Colors.white.withOpacity(0.65),
              fontWeight: FontWeight.w500,
              fontSize: isTablet ? objfun.FontLow : objfun.FontLow - 1,
            ),
          ),
        ],
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  // ─── Filter Bottom Sheet ───────────────────────────────────────────────────
  void _showFilterSheet(BuildContext pageContext) {
    final bloc = pageContext.read<VesselPlanningBloc>();
    final currentState = bloc.state is VesselPlanningLoaded
        ? bloc.state as VesselPlanningLoaded
        : null;

    String fromDate = currentState?.fromDate ??
        DateFormat("yyyy-MM-dd").format(DateTime.now());
    String toDate = currentState?.toDate ??
        DateFormat("yyyy-MM-dd").format(DateTime.now());
    String planningNo = currentState?.planningNo ?? '';
    bool isLoggedInEmp = currentState?.isLoggedInEmp ?? true;
    int empId = currentState?.empId ?? 0;
    String empName = currentState?.empName ?? '';

    final txtPlanningNo = TextEditingController(text: planningNo);
    final txtEmployee   = TextEditingController(text: empName);

    showModalBottomSheet(
      context: pageContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          final isTablet = objfun.MalevaScreen != 1;

          Future<void> pickDate(bool isFrom) async {
            final picked = await showDatePicker(
              context: ctx,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2050),
              builder: (context, child) => Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppTokens.invoiceHeaderStart,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: colour.kTextDark,
                  ),
                ),
                child: child!,
              ),
            );
            if (picked != null) {
              final formatted = DateFormat("yyyy-MM-dd").format(picked);
              setSheetState(() {
                if (isFrom) fromDate = formatted;
                else toDate = formatted;
              });
            }
          }

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              top: 0,
              left: 16,
              right: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 18),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTokens.maintCardBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Sheet title
                  Text(
                    'Filter',
                    style: GoogleFonts.lato(
                      color: AppTokens.invoiceHeaderStart,
                      fontWeight: FontWeight.w700,
                      fontSize: isTablet ? 16 : 15,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Date row ────────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _SheetDateTile(
                          label: 'From',
                          date: fromDate,
                          onTap: () => pickDate(true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SheetDateTile(
                          label: 'To',
                          date: toDate,
                          onTap: () => pickDate(false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Employee ─────────────────────────────────────────────
                  _SheetTextField(
                    controller: txtEmployee,
                    hint: 'Select Employee',
                    readOnly: true,
                    suffixIcon: InkWell(
                      onTap: () async {
                        if (isLoggedInEmp) return;
                        await OnlineApi.SelectEmployee(ctx, 'sales', 'admin'); if (!ctx.mounted) return;
                        if (txtEmployee.text.isEmpty) {
                          Navigator.push(
                            ctx,
                            MaterialPageRoute(
                              builder: (_) =>
                              const Employee(Searchby: 1, SearchId: 0),
                            ),
                          ).then((_navRes) { if (_navRes != null) { objfun.SelectEmployeeList = _navRes; }
                            setSheetState(() {
                              txtEmployee.text =
                                  objfun.SelectEmployeeList.AccountName;
                              empId   = objfun.SelectEmployeeList.Id;
                              empName = txtEmployee.text;
                              objfun.SelectEmployeeList = EmployeeModel.Empty();
                            });
                          });
                        } else {
                          setSheetState(() {
                            txtEmployee.text = '';
                            empId   = 0;
                            empName = '';
                            objfun.SelectEmployeeList = EmployeeModel.Empty();
                          });
                        }
                      },
                      child: Icon(
                        txtEmployee.text.isNotEmpty
                            ? Icons.close_rounded
                            : Icons.search_rounded,
                        color: isLoggedInEmp
                            ? AppTokens.planTextMuted
                            : colour.kHeaderGradEnd,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Planning No ──────────────────────────────────────────
                  _SheetTextField(
                    controller: txtPlanningNo,
                    hint: 'Planning No',
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 10),

                  // ── L.Emp checkbox ───────────────────────────────────────
                  InkWell(
                    onTap: () =>
                        setSheetState(() => isLoggedInEmp = !isLoggedInEmp),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 2),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              gradient: isLoggedInEmp ? kGradient : null,
                              border: isLoggedInEmp
                                  ? null
                                  : Border.all(color: AppTokens.maintCardBorder, width: 1.5),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: isLoggedInEmp
                                ? const Icon(Icons.check_rounded,
                                size: 14, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Logged-in Employee',
                            style: GoogleFonts.lato(
                              color: colour.kTextDark,
                              fontWeight: FontWeight.w600,
                              fontSize: isTablet
                                  ? objfun.FontLow + 1
                                  : objfun.FontLow,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _GradientButton(
                        label: 'View',
                        onPressed: () {
                          pageContext.read<VesselPlanningBloc>().add(
                            VesselPlanningFilterChanged(
                              fromDate: fromDate,
                              toDate: toDate,
                              planningNo: txtPlanningNo.text,
                              empId: empId,
                              empName: txtEmployee.text, // 💥 TextBox-la enna name irukko atha pass pandrom
                              isLoggedInEmp: isLoggedInEmp,
                            ),
                          );
                          Navigator.pop(ctx);
                        },
                      ),
                      const SizedBox(width: 12),
                      _OutlineButton(
                        label: 'Close',
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────
class _VesselPlanningBody extends StatelessWidget {
  final VesselPlanningLoaded state;
  final bool isTablet;

  const _VesselPlanningBody({required this.state, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width  = MediaQuery.of(context).size.width;

    return Column(
      children: [
        // ── Grid Header ────────────────────────────────────────────────────
        Container(
          height: isTablet ? height * 0.09 : height * 0.08,
          decoration: const BoxDecoration(gradient: kGradientVertical),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: _GridHeader(isTablet: isTablet),
        ),

        // ── List ───────────────────────────────────────────────────────────
        Expanded(
          child: state.masterList.isEmpty
              ? _EmptyState()
              : ListView.builder(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            itemCount: state.masterList.length,
            itemBuilder: (ctx, index) {
              final item = state.masterList[index];
              final isExpanded = state.expandedIndex == index;
              return _PlanningCard(
                item: item,
                index: index,
                isExpanded: isExpanded,
                selectedDetails: state.selectedDetails,
                isTablet: isTablet,
                height: height,
                width: width,
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Grid Header ──────────────────────────────────────────────────────────────
class _GridHeader extends StatelessWidget {
  final bool isTablet;
  const _GridHeader({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.lato(
      color: Colors.white.withOpacity(0.85),
      fontWeight: FontWeight.w600,
      fontSize: isTablet ? 11 : 10,
      letterSpacing: 0.6,
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(children: [
          Expanded(flex: 3, child: Text('DATE RANGE', style: style)),
          Expanded(flex: 3, child: Text('PORT', style: style)),
        ]),
        Row(children: [
          Expanded(flex: 3, child: Text('PLANNING DATE', style: style)),
          Expanded(flex: 3, child: Text('REMARKS', style: style)),
        ]),
      ],
    );
  }
}

// ─── Planning Card ────────────────────────────────────────────────────────────
class _PlanningCard extends StatelessWidget {
  final VesselPlanningMasterModel item;
  final int index;
  final bool isExpanded;
  final List<dynamic> selectedDetails;
  final bool isTablet;
  final double height;
  final double width;

  const _PlanningCard({
    required this.item,
    required this.index,
    required this.isExpanded,
    required this.selectedDetails,
    required this.isTablet,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final valStyle = GoogleFonts.lato(
      color: colour.kTextDark,
      fontWeight: FontWeight.w600,
      fontSize: isTablet ? objfun.FontCardText + 1 : objfun.FontCardText,
    );
    final labelStyle = GoogleFonts.lato(
      color: AppTokens.planTextMuted,
      fontWeight: FontWeight.w600,
      fontSize: isTablet ? 10 : 9,
      letterSpacing: 0.4,
    );
    final remarkStyle = GoogleFonts.lato(
      color: colour.kTextMid,
      fontWeight: FontWeight.w500,
      fontSize: isTablet ? objfun.FontCardText : objfun.FontCardText - 1,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onLongPress: () {
          context.read<VesselPlanningBloc>().add(
            VesselPlanningEditRequested(
              id: item.Id,
              planningNo: item.VESSELPLANINGNo,
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: colour.kCardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTokens.maintCardBorder, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: AppTokens.invoiceHeaderStart.withOpacity(0.07),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top accent bar ────────────────────────────────────────
                Container(
                  height: 3,
                  decoration: const BoxDecoration(gradient: kGradient),
                ),

                // ── Main card content ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: DATE RANGE + PORT
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('DATE RANGE', style: labelStyle),
                                const SizedBox(height: 2),
                                Text(
                                  '${item.FDate} - ${item.TDate}',
                                  style: valStyle,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('PORT', style: labelStyle),
                                const SizedBox(height: 2),
                                Text(
                                  item.Search.isEmpty ? '-' : item.Search,
                                  style: valStyle,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Row 2: PLANNING DATE + REMARKS
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('PLANNING DATE', style: labelStyle),
                                const SizedBox(height: 2),
                                Text(
                                  item.VESSELPLANINGDate.toString(),
                                  style: valStyle,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('REMARKS', style: labelStyle),
                                const SizedBox(height: 2),
                                Text(
                                  item.Remarks.isEmpty ? '-' : item.Remarks,
                                  style: remarkStyle,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Action row ────────────────────────────────────────────
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    children: [
                      _CardActionChip(
                        icon: isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        label: isExpanded ? 'Collapse' : 'Details',
                        onTap: () {
                          context.read<VesselPlanningBloc>().add(
                            VesselPlanningRowToggled(
                              index: index,
                              masterRefId: item.Id,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _CardActionChip(
                        icon: Icons.picture_as_pdf_outlined,
                        label: 'Export PDF',
                        onTap: () {
                          context.read<VesselPlanningBloc>().add(
                            VesselPlanningShareRequested(
                              id: item.Id,
                              planningNoDisplay:
                              item.VESSELPLANINGNoDisplay,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // ── Expanded Details ──────────────────────────────────────
                if (isExpanded)
                  _DetailsSection(
                    details: selectedDetails,
                    isTablet: isTablet,
                    height: height,
                    width: width,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Details Section ──────────────────────────────────────────────────────────
// ─── Details Section ──────────────────────────────────────────────────────────
class _DetailsSection extends StatelessWidget {
  final List<dynamic> details;
  final bool isTablet;
  final double height;
  final double width;

  const _DetailsSection({
    required this.details,
    required this.isTablet,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    if (details.isEmpty) {
      return SizedBox(
        height: isTablet ? height * 0.28 : height * 0.24,
        child: Center(
          child: Text(
            'No records found',
            style: GoogleFonts.lato(
                fontSize: objfun.FontLow, color: AppTokens.planTextMuted),
          ),
        ),
      );
    }

    final headerStyle = GoogleFonts.lato(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      fontSize: 12,
    );
    final rowStyle = GoogleFonts.lato(
      color: colour.kTextDark,
      fontWeight: FontWeight.w600,
      fontSize: 12,
    );

    return SizedBox(
      height: isTablet ? height * 0.4 : height * 0.35,
      width: double.infinity,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTokens.maintCardBorder),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(colour.kHeaderGradEnd),
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

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colour.kChipBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.anchor_rounded,
              size: 32,
              color: colour.kHeaderGradEnd,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No Records Found',
            style: GoogleFonts.lato(
              color: colour.kTextDark,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try adjusting your filters',
            style: GoogleFonts.lato(
              color: AppTokens.planTextMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── FAB ──────────────────────────────────────────────────────────────────────
class _VPFab extends StatelessWidget {
  final VoidCallback onPressed;
  const _VPFab({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: kGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTokens.invoiceHeaderStart.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: const Icon(
            Icons.filter_alt_outlined,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

// ─── Reusable: Card Action Chip ───────────────────────────────────────────────
class _CardActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CardActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: colour.kChipBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTokens.maintCardBorder, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppTokens.invoiceHeaderStart),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.lato(
                color: AppTokens.invoiceHeaderStart,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reusable: Sheet Date Tile ────────────────────────────────────────────────
class _SheetDateTile extends StatelessWidget {
  final String label;
  final String date;
  final VoidCallback onTap;

  const _SheetDateTile({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayDate =
    DateFormat('dd-MM-yy').format(DateTime.parse(date));
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colour.kDetailBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTokens.maintCardBorder, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: GoogleFonts.lato(
                color: AppTokens.planTextMuted,
                fontWeight: FontWeight.w700,
                fontSize: 9,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  displayDate,
                  style: GoogleFonts.lato(
                    color: colour.kTextDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const Icon(
                  Icons.calendar_month_outlined,
                  size: 18,
                  color: colour.kHeaderGradEnd,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reusable: Sheet Text Field ───────────────────────────────────────────────
class _SheetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool readOnly;
  final Widget? suffixIcon;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;

  const _SheetTextField({
    required this.controller,
    required this.hint,
    this.readOnly = false,
    this.suffixIcon,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      style: GoogleFonts.lato(
        color: colour.kTextDark,
        fontWeight: FontWeight.w600,
        fontSize: objfun.FontLow,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.lato(
          color: AppTokens.planTextMuted,
          fontWeight: FontWeight.w500,
          fontSize: objfun.FontLow,
        ),
        filled: true,
        fillColor: colour.kDetailBg,
        suffixIcon: suffixIcon,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTokens.maintCardBorder, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: colour.kHeaderGradEnd, width: 1.5),
        ),
      ),
    );
  }
}

// ─── Reusable: Gradient Button ────────────────────────────────────────────────
class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _GradientButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: kGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTokens.invoiceHeaderStart.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 28, vertical: 11),
            child: Text(
              label,
              style: GoogleFonts.lato(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: objfun.FontMedium,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Reusable: Outline Button ─────────────────────────────────────────────────
class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _OutlineButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colour.kChipBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTokens.maintCardBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 28, vertical: 11),
            child: Text(
              label,
              style: GoogleFonts.lato(
                color: AppTokens.invoiceHeaderStart,
                fontWeight: FontWeight.w700,
                fontSize: objfun.FontMedium,
              ),
            ),
          ),
        ),
      ),
    );
  }
}