import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/MasterSearch/Employee.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/Transaction/VesselPlanning/VesselPlanningDetails.dart';
import '../bloc/vesselplanning_bloc.dart';
import '../bloc/vesselplanning_event.dart';
import '../bloc/vesselplanning_state.dart';



const kGradient = LinearGradient(
  colors: [colour.kHeaderGradStart, colour.kHeaderGradEnd],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const kGradientVertical = LinearGradient(
  colors: [colour.kHeaderGradStart, Color(0xFF2D56C8)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

// ─── Root Widget ──────────────────────────────────────────────────────────────
class VesselPlanningView extends StatelessWidget {
  const VesselPlanningView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VesselPlanningBloc()..add(VesselPlanningStarted()),
      child: const _VesselPlanningPage(),
    );
  }
}

// ─── Page ─────────────────────────────────────────────────────────────────────
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
            MaterialPageRoute(builder: (_) => const VesselPlanningDetailsView()),
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
                    primary: colour.kHeaderGradStart,
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
                        color: colour.kCardBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Sheet title
                  Text(
                    'Filter',
                    style: GoogleFonts.lato(
                      color: colour.kHeaderGradStart,
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
                        await OnlineApi.SelectEmployee(ctx, 'sales', 'admin');
                        if (txtEmployee.text.isEmpty) {
                          Navigator.push(
                            ctx,
                            MaterialPageRoute(
                              builder: (_) =>
                              const Employee(Searchby: 1, SearchId: 0),
                            ),
                          ).then((_) {
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
                            ? colour.kTextMuted
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
                                  : Border.all(color: colour.kCardBorder, width: 1.5),
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

                  // ── Buttons ──────────────────────────────────────────────
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
          Expanded(flex: 3, child: Text('PLANNING NO', style: style)),
          Expanded(flex: 3, child: Text('PLANNING DATE', style: style)),
        ]),
        Row(children: [
          Expanded(flex: 3, child: Text('REMARKS', style: style)),
        ]),
        Row(children: [
          const Expanded(flex: 3, child: SizedBox()),
          Expanded(
            flex: 2,
            child: Text('EXPORT', textAlign: TextAlign.center, style: style),
          ),
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
      color: colour.kTextMuted,
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
        onLongPress: () => _showPasswordDialog(context),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: colour.kCardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colour.kCardBorder, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: colour.kHeaderGradStart.withOpacity(0.07),
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
                      // Row 1: Planning No + Date
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('PLANNING NO', style: labelStyle),
                                const SizedBox(height: 2),
                                Text(
                                  item.VESSELPLANINGNoDisplay,
                                  style: valStyle,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('DATE', style: labelStyle),
                                const SizedBox(height: 2),
                                Text(
                                  item.VESSELPLANINGDate.toString(),
                                  style: valStyle,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Row 2: Remarks
                      Text('REMARKS', style: labelStyle),
                      const SizedBox(height: 2),
                      Text(
                        item.Remarks,
                        style: remarkStyle,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
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

  // ─── Password Dialog ───────────────────────────────────────────────────────
  void _showPasswordDialog(BuildContext context) {
    final txtPassword = TextEditingController();
    final bloc = context.read<VesselPlanningBloc>();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        return Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            width: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colour.kHeaderGradStart.withOpacity(0.18),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  decoration: const BoxDecoration(
                    gradient: kGradient,
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'Edit Password',
                        style: GoogleFonts.lato(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                // Body
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(image: objfun.lockimg),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        height: 100,
                        width: double.infinity,
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: txtPassword,
                        cursorColor: colour.kHeaderGradStart,
                        textCapitalization: TextCapitalization.characters,
                        textInputAction: TextInputAction.done,
                        style: GoogleFonts.lato(
                          color: colour.kTextDark,
                          fontWeight: FontWeight.w600,
                          fontSize: objfun.FontLow,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter password',
                          hintStyle: GoogleFonts.lato(
                            color: colour.kTextMuted,
                            fontSize: objfun.FontLow,
                          ),
                          filled: true,
                          fillColor: colour.kDetailBg,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: colour.kHeaderGradEnd, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: _GradientButton(
                          label: 'Confirm',
                          onPressed: () async {
                            if (txtPassword.text.isEmpty) {
                              objfun.ConfirmationOK(
                                  'Enter Password !!', dialogCtx);
                              return;
                            }
                            await objfun
                                .apiAllinoneSelectArray(
                              '${objfun.apiEditPassword}${txtPassword.text}&type=EditPassword&Comid=${objfun.Comid}',
                              null,
                              null,
                              dialogCtx,
                            )
                                .then((resultData) {
                              if (resultData.length != 0 &&
                                  resultData['IsSuccess'] == true) {
                                txtPassword.text = '';
                                Navigator.pop(dialogCtx);
                                bloc.add(VesselPlanningEditRequested(
                                  id: item.Id,
                                  planningNo: item.VESSELPLANINGNo,
                                ));
                              } else {
                                txtPassword.text = '';
                                objfun.ConfirmationOK(
                                    'Invalid Password !!!', dialogCtx);
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

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
    final headerStyle = GoogleFonts.lato(
      color: Colors.white.withOpacity(0.85),
      fontWeight: FontWeight.w600,
      fontSize: isTablet ? 10 : 9,
      letterSpacing: 0.5,
    );
    final rowStyle = GoogleFonts.lato(
      color: colour.kTextDark,
      fontWeight: FontWeight.w500,
      fontSize: isTablet ? objfun.FontCardText : objfun.FontCardText - 1,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Detail header
        Container(
          height: isTablet ? 36 : 32,
          decoration: const BoxDecoration(gradient: kGradientVertical),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Expanded(flex: 2, child: Text('JOB NO', style: headerStyle)),
              Expanded(flex: 2, child: Text('JOB DATE', style: headerStyle)),
              Expanded(flex: 3, child: Text('REMARKS', style: headerStyle)),
            ],
          ),
        ),

        // Detail rows
        SizedBox(
          height: isTablet ? height * 0.28 : height * 0.24,
          child: details.isEmpty
              ? Center(
            child: Text(
              'No records found',
              style: GoogleFonts.lato(
                  fontSize: objfun.FontLow, color: colour.kTextMuted),
            ),
          )
              : ListView.builder(
            shrinkWrap: true,
            itemCount: details.length,
            itemBuilder: (ctx, i) {
              final isOdd = i % 2 == 0;
              return Container(
                height: isTablet ? 42 : 38,
                color: isOdd ? Colors.white : colour.kDetailBg,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        details[i]['JobNo'] ?? '',
                        style: rowStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        details[i]['JobDate'].toString(),
                        style: rowStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        details[i]['Remarks'].toString(),
                        style: rowStyle.copyWith(color: colour.kTextMid),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
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
              color: colour.kTextMuted,
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
            color: colour.kHeaderGradStart.withOpacity(0.4),
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
          border: Border.all(color: colour.kCardBorder, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: colour.kHeaderGradStart),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.lato(
                color: colour.kHeaderGradStart,
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
          border: Border.all(color: colour.kCardBorder, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: GoogleFonts.lato(
                color: colour.kTextMuted,
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
          color: colour.kTextMuted,
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
          borderSide: const BorderSide(color: colour.kCardBorder, width: 0.5),
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
            color: colour.kHeaderGradStart.withOpacity(0.35),
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
        border: Border.all(color: colour.kCardBorder),
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
                color: colour.kHeaderGradStart,
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