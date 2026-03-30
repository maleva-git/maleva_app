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



// ─── Entry point ────────────────────────────────────────────────────────────────
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

// ─── Page ────────────────────────────────────────────────────────────────────────
class _VesselPlanningPage extends StatelessWidget {
  const _VesselPlanningPage();

  @override
  Widget build(BuildContext context) {
    final isTablet = objfun.MalevaScreen != 1;
    final userName = objfun.storagenew.getString('Username') ?? "";

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
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context, userName, isTablet),
        drawer: const Menulist(),
        body: BlocBuilder<VesselPlanningBloc, VesselPlanningState>(
          builder: (context, state) {
            if (state is VesselPlanningLoading || state is VesselPlanningInitial) {
              return const Center(
                child: SpinKitFoldingCube(color: colour.spinKitColor, size: 35.0),
              );
            }
            if (state is VesselPlanningLoaded) {
              return _VesselPlanningBody(state: state, isTablet: isTablet);
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showFilterSheet(context),
          tooltip: 'Open filter',
          child: const Icon(Icons.filter_alt_outlined),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, String userName, bool isTablet) {
    return AppBar(
      automaticallyImplyLeading: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vessel Planning',
            style: GoogleFonts.lato(
              color: colour.topAppBarColor,
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? objfun.FontMedium + 2 : objfun.FontMedium,
            ),
          ),
          Text(
            userName,
            style: GoogleFonts.lato(
              color: colour.commonColorLight,
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? objfun.FontLow : objfun.FontLow - 2,
            ),
          ),
        ],
      ),
      iconTheme: const IconThemeData(color: colour.topAppBarColor),
    );
  }

  // ─── Filter Bottom Sheet ──────────────────────────────────────────────────────
  void _showFilterSheet(BuildContext pageContext) {
    final bloc = pageContext.read<VesselPlanningBloc>();
    final currentState = bloc.state is VesselPlanningLoaded
        ? bloc.state as VesselPlanningLoaded
        : null;

    String fromDate = currentState?.fromDate ?? DateFormat("yyyy-MM-dd").format(DateTime.now());
    String toDate = currentState?.toDate ?? DateFormat("yyyy-MM-dd").format(DateTime.now());
    String planningNo = currentState?.planningNo ?? '';
    bool isLoggedInEmp = currentState?.isLoggedInEmp ?? true;
    int empId = currentState?.empId ?? 0;
    String empName = currentState?.empName ?? '';

    final txtPlanningNo = TextEditingController(text: planningNo);
    final txtEmployee = TextEditingController(text: empName);

    showModalBottomSheet(
      context: pageContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          final isTablet = objfun.MalevaScreen != 1;
          final labelStyle = GoogleFonts.lato(
            color: colour.commonColor,
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? objfun.FontLow + 1 : objfun.FontLow,
          );

          Future<void> pickDate(bool isFrom) async {
            final picked = await showDatePicker(
              context: ctx,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2050),
            );
            if (picked != null) {
              final formatted = DateFormat("yyyy-MM-dd").format(picked);
              setSheetState(() {
                if (isFrom) {
                  fromDate = formatted;
                } else {
                  toDate = formatted;
                }
              });
            }
          }

          return Padding(
            padding: EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Date row ──
                  Row(
                    children: [
                      Expanded(
                        child: _DateTile(
                          label: 'From',
                          date: fromDate,
                          onTap: () => pickDate(true),
                          labelStyle: labelStyle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DateTile(
                          label: 'To',
                          date: toDate,
                          onTap: () => pickDate(false),
                          labelStyle: labelStyle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Employee ──
                  TextField(
                    controller: txtEmployee,
                    readOnly: true,
                    style: labelStyle,
                    decoration: InputDecoration(
                      hintText: "Select Employee",
                      hintStyle: GoogleFonts.lato(
                        fontSize: objfun.FontLow,
                        fontWeight: FontWeight.bold,
                        color: colour.commonColorLight,
                      ),
                      suffixIcon: InkWell(
                        onTap: () async {
                          await OnlineApi.SelectEmployee(ctx, 'sales', 'admin');
                          if (txtEmployee.text.isEmpty && !isLoggedInEmp) {
                            Navigator.push(
                              ctx,
                              MaterialPageRoute(
                                builder: (_) => const Employee(Searchby: 1, SearchId: 0),
                              ),
                            ).then((_) {
                              setSheetState(() {
                                txtEmployee.text = objfun.SelectEmployeeList.AccountName;
                                empId = objfun.SelectEmployeeList.Id;
                                empName = txtEmployee.text;
                                objfun.SelectEmployeeList = EmployeeModel.Empty();
                              });
                            });
                          } else {
                            setSheetState(() {
                              txtEmployee.text = '';
                              empId = 0;
                              empName = '';
                              objfun.SelectEmployeeList = EmployeeModel.Empty();
                            });
                          }
                        },
                        child: Icon(
                          txtEmployee.text.isNotEmpty ? Icons.close : Icons.search_rounded,
                          color: isLoggedInEmp ? colour.commonColorDisabled : colour.commonColorred,
                        ),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: colour.commonColor),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: colour.commonColorred),
                      ),
                      contentPadding: const EdgeInsets.only(left: 10, right: 20, top: 10),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Planning No ──
                  TextField(
                    controller: txtPlanningNo,
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.done,
                    style: labelStyle,
                    decoration: InputDecoration(
                      hintText: 'Planning No',
                      hintStyle: GoogleFonts.lato(
                        fontSize: objfun.FontLow,
                        fontWeight: FontWeight.bold,
                        color: colour.commonColorLight,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: colour.commonColor),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: colour.commonColorred),
                      ),
                      contentPadding: const EdgeInsets.only(left: 10, right: 20, top: 10),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── L.Emp checkbox ──
                  Row(
                    children: [
                      Checkbox(
                        value: isLoggedInEmp,
                        activeColor: colour.commonColorred,
                        onChanged: (val) => setSheetState(() => isLoggedInEmp = val!),
                      ),
                      Text('L.Emp', style: labelStyle),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // ── Buttons ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
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
                        child: Text('View', style: GoogleFonts.lato(fontSize: objfun.FontMedium)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('Close', style: GoogleFonts.lato(fontSize: objfun.FontMedium)),
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

// ─── Body ────────────────────────────────────────────────────────────────────────
class _VesselPlanningBody extends StatelessWidget {
  final VesselPlanningLoaded state;
  final bool isTablet;

  const _VesselPlanningBody({required this.state, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        children: [
          // ── Grid Header ──
          Container(
            height: isTablet ? height * 0.07 : height * 0.06,
            color: colour.commonColor,
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: _GridHeader(isTablet: isTablet),
          ),

          // ── List ──
          Expanded(
            child: state.masterList.isEmpty
                ? Center(
              child: Text(
                'No Record',
                style: GoogleFonts.lato(fontSize: objfun.FontMedium),
              ),
            )
                : ListView.builder(
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
      ),
    );
  }
}

// ─── Grid Header ─────────────────────────────────────────────────────────────────
class _GridHeader extends StatelessWidget {
  final bool isTablet;
  const _GridHeader({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.lato(
      color: colour.ButtonForeColor,
      fontWeight: FontWeight.bold,
      fontSize: isTablet ? objfun.FontLow + 1 : objfun.FontLow,
    );
    return Column(
      children: [
        Expanded(
          child: Row(children: [
            Expanded(flex: 3, child: Text("Planning No", style: style)),
            Expanded(flex: 3, child: Text("Planning Date", style: style)),
          ]),
        ),
        Expanded(
          child: Row(children: [
            Expanded(flex: 3, child: Text("Remarks", style: style)),
          ]),
        ),
        Expanded(
          child: Row(children: [
            const Expanded(flex: 1, child: SizedBox()),
            Expanded(flex: 1, child: Text("Export", textAlign: TextAlign.center, style: style)),
          ]),
        ),
      ],
    );
  }
}

// ─── Planning Card ────────────────────────────────────────────────────────────────
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
    final cardHeight = isExpanded
        ? (isTablet ? height * 0.60 : height * 0.55)
        : (isTablet ? height * 0.14 : height * 0.12);

    final textStyle = GoogleFonts.lato(
      color: colour.commonColor,
      fontWeight: FontWeight.bold,
      fontSize: isTablet ? objfun.FontCardText + 1 : objfun.FontCardText,
      letterSpacing: 0.3,
    );

    return SizedBox(
      height: cardHeight,
      child: InkWell(
        onLongPress: () => _showPasswordDialog(context),
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: colour.commonColor, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              // ── Row 1: Planning No + Date ──
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(1),
                        child: Text(
                          "   ${item.VESSELPLANINGNoDisplay}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: textStyle,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Text(
                          item.VESSELPLANINGDate.toString(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: textStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Row 2: Remarks ──
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(1),
                        child: Text(
                          "  ${item.Remarks}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: textStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Row 3: Expand + PDF ──
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        icon: const Icon(Icons.expand_circle_down, color: colour.commonColor),
                        onPressed: () {
                          context.read<VesselPlanningBloc>().add(
                            VesselPlanningRowToggled(
                              index: index,
                              masterRefId: item.Id,
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        icon: const Icon(Icons.picture_as_pdf_outlined, color: colour.commonColor),
                        onPressed: () {
                          context.read<VesselPlanningBloc>().add(
                            VesselPlanningShareRequested(
                              id: item.Id,
                              planningNoDisplay: item.VESSELPLANINGNoDisplay,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // ── Expanded Details ──
              if (isExpanded)
                Expanded(
                  flex: 8,
                  child: _DetailsSection(
                    details: selectedDetails,
                    isTablet: isTablet,
                    height: height,
                    width: width,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPasswordDialog(BuildContext context) {
    final txtPassword = TextEditingController();
    final bloc = context.read<VesselPlanningBloc>();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        return Dialog(
          elevation: 40,
          child: SizedBox(
            width: 200,
            height: 220,
            child: Column(
              children: [
                ListView(shrinkWrap: true, children: [
                  Container(
                    width: 350,
                    height: 150,
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(image: DecorationImage(image: objfun.lockimg)),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 85, left: 35, right: 35, bottom: 25),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                          color: colour.commonColorLight.withOpacity(1.0),
                        ),
                        child: TextField(
                          controller: txtPassword,
                          cursorColor: colour.commonColor,
                          textCapitalization: TextCapitalization.characters,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            hintText: 'Edit Password',
                            hintStyle: GoogleFonts.lato(
                              fontSize: objfun.FontMedium,
                              fontWeight: FontWeight.bold,
                              color: colour.commonColor.withOpacity(0.6),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(color: colour.commonColor),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            contentPadding: const EdgeInsets.only(left: 10, right: 20, top: 10),
                          ),
                          style: GoogleFonts.lato(
                            color: colour.commonColor,
                            fontWeight: FontWeight.bold,
                            fontSize: objfun.FontLow,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: colour.commonColor),
                        onPressed: () async {
                          if (txtPassword.text.isEmpty) {
                            objfun.ConfirmationOK("Enter Password !!", dialogCtx);
                            return;
                          }
                          await objfun
                              .apiAllinoneSelectArray(
                            "${objfun.apiEditPassword}${txtPassword.text}&type=EditPassword&Comid=${objfun.Comid}",
                            null,
                            null,
                            dialogCtx,
                          )
                              .then((resultData) {
                            if (resultData.length != 0 && resultData["IsSuccess"] == true) {
                              txtPassword.text = '';
                              Navigator.pop(dialogCtx);
                              bloc.add(VesselPlanningEditRequested(
                                id: item.Id,
                                planningNo: item.VESSELPLANINGNo,
                              ));
                            } else {
                              txtPassword.text = '';
                              objfun.ConfirmationOK("Invalid Password !!!", dialogCtx);
                            }
                          });
                        },
                        child: Text(
                          'Ok',
                          style: GoogleFonts.lato(
                            fontSize: objfun.FontMedium,
                            color: colour.commonColorLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Details Section ──────────────────────────────────────────────────────────────
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
      color: colour.ButtonForeColor,
      fontWeight: FontWeight.bold,
      fontSize: isTablet ? objfun.FontCardText + 1 : objfun.FontCardText,
      letterSpacing: 0.3,
    );
    final rowStyle = GoogleFonts.lato(
      color: colour.commonColor,
      fontWeight: FontWeight.bold,
      fontSize: isTablet ? objfun.FontCardText + 1 : objfun.FontCardText,
      letterSpacing: 0.3,
    );

    return ListView(
      children: [
        // Detail header
        Container(
          height: isTablet ? height * 0.05 : height * 0.04,
          color: colour.commonColor,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            children: [
              Expanded(flex: 2, child: Text("Job No", style: headerStyle)),
              Expanded(flex: 2, child: Text("Job Date", style: headerStyle)),
              Expanded(flex: 3, child: Text("Remarks", style: headerStyle)),
            ],
          ),
        ),

        // Detail rows
        SizedBox(
          height: isTablet ? height * 0.38 : height * 0.32,
          child: details.isEmpty
              ? Center(child: Text('No Record', style: GoogleFonts.lato(fontSize: objfun.FontMedium)))
              : ListView.builder(
            itemCount: details.length,
            itemBuilder: (ctx, i) {
              return SizedBox(
                height: isTablet ? 50 : 45,
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: colour.commonColor, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          "  ${details[i]["JobNo"]}",
                          style: rowStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          details[i]["JobDate"].toString(),
                          style: rowStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          details[i]["Remarks"].toString(),
                          style: rowStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Date Tile helper ─────────────────────────────────────────────────────────────
class _DateTile extends StatelessWidget {
  final String label;
  final String date;
  final VoidCallback onTap;
  final TextStyle labelStyle;

  const _DateTile({
    required this.label,
    required this.date,
    required this.onTap,
    required this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final displayDate = DateFormat("dd-MM-yy").format(DateTime.parse(date));
    return Row(
      children: [
        Text(displayDate, style: labelStyle),
        const SizedBox(width: 4),
        Material(
          color: Colors.transparent,
          child: IconButton(
            icon: const Icon(Icons.calendar_month_outlined, size: 28, color: colour.commonColor),
            onPressed: onTap,
          ),
        ),
      ],
    );
  }
}