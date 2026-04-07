import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/models/model.dart';
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/MasterSearch/Driver.dart';
import 'package:maleva/MasterSearch/Truck.dart';
import 'package:maleva/Transport/RTI/UpdateRTIStatus.dart';
import 'package:maleva/DashBoard/AirFrieght/AirFrieghtDashboard.dart';
import 'package:maleva/DashBoard/Boarding/BoardingDashboard.dart';
import 'package:maleva/DashBoard/Driver/DriverDashboard.dart';
import 'package:maleva/DashBoard/Forwarding/ForwardingDashboard.dart';
import 'package:maleva/DashBoard/TransportDB/TransportDashboard.dart';
import 'package:maleva/DashBoard/User/UserDashboard.dart';
import 'package:maleva/features/dashboard/admin_dashboard/view/admin_dashboard.dart';
import '../../../dashboard/operationadmin_dashboard/view/operationadmin_dashboard.dart';
import '../bloc/updatertidetails_bloc.dart';
import '../bloc/updatertidetails_event.dart';
import '../bloc/updatertidetails_state.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const kHeaderGradStart = Color(0xFF1A3A8F);
const kHeaderGradEnd   = Color(0xFF4A6FD4);
const kCardBorder      = Color(0xFFC5D0EE);
const kPageBg          = Color(0xFFF4F6FB);
const kTextDark        = Color(0xFF1E2D5E);
const kTextMid         = Color(0xFF4A5A8A);
const kTextMuted       = Color(0xFF8A96BF);
const kDetailBg        = Color(0xFFF0F4FF);
const kChipBg          = Color(0xFFEEF2FF);

const kGradient = LinearGradient(
  colors: [kHeaderGradStart, kHeaderGradEnd],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const double kTabletBreak = 600;

// ─── Root ─────────────────────────────────────────────────────────────────────
class UpdateRTI extends StatelessWidget {
  const UpdateRTI({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UpdateRTIBloc()..add(UpdateRTIStarted()),
      child: const _UpdateRTIPage(),
    );
  }
}

// ─── Page ─────────────────────────────────────────────────────────────────────
class _UpdateRTIPage extends StatelessWidget {
  const _UpdateRTIPage();

  @override
  Widget build(BuildContext context) {
    final userName = objfun.storagenew.getString('Username') ?? '';

    return BlocListener<UpdateRTIBloc, UpdateRTIState>(
      listener: (context, state) {
        if (state is UpdateRTIError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message,
                  style: GoogleFonts.lato(color: Colors.white)),
              backgroundColor: const Color(0xFFB33040),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
      child: WillPopScope(
        onWillPop: () async {
          _navigateBack(context);
          return false;
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: kPageBg,
          appBar: _buildAppBar(context, userName),
          drawer: const Menulist(),
          body: BlocBuilder<UpdateRTIBloc, UpdateRTIState>(
            builder: (context, state) {
              if (state is UpdateRTIInitial || state is UpdateRTILoading) {
                return const Center(
                  child: SpinKitFoldingCube(color: kHeaderGradEnd, size: 35),
                );
              }
              if (state is UpdateRTILoaded) {
                return _UpdateRTIBody(state: state);
              }
              return const SizedBox.shrink();
            },
          ),
          floatingActionButton: _RTIFab(
            onPressed: () {
              final s = context.read<UpdateRTIBloc>().state;
              if (s is UpdateRTILoaded) _showFilterSheet(context, s);
            },
          ),
        ),
      ),
    );
  }

  void _navigateBack(BuildContext context) {
    Widget dest;
    if (objfun.DriverLogin == 1) {
      dest = const DriverDashboard();
    } else {
      switch (objfun.storagenew.getString('RulesType')) {
        case 'ADMIN':
          dest = const NewAdminDashboard();
          break;
        case 'TRANSPORTATION':
          dest = const TransportDashboard();
          break;
        case 'OPERATIONADMIN':
          dest = const OperationAdminDashboard();
          break;
        case 'AIR FRIEGHT':
          dest = const AirFrieghtDashboard();
          break;
        case 'BOARDING':
        case 'OPERATION':
          dest = const BoardingDashboard();
          break;
        case 'FORWARDING':
          dest = const ForwardingDashboard();
          break;
        default:
          dest = const Homemobile();
      }
    }
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => dest));
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, String userName) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      toolbarHeight: 62,
      flexibleSpace:
      Container(decoration: const BoxDecoration(gradient: kGradient)),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        color: Colors.white,
        onPressed: () => _navigateBack(context),
      ),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Update RTI',
              style: GoogleFonts.lato(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  letterSpacing: 0.3)),
          const SizedBox(height: 2),
          Text(userName,
              style: GoogleFonts.lato(
                  color: Colors.white.withOpacity(0.65),
                  fontWeight: FontWeight.w500,
                  fontSize: 12)),
        ],
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  void _showFilterSheet(BuildContext pageContext, UpdateRTILoaded current) {
    showModalBottomSheet(
      context: pageContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: pageContext.read<UpdateRTIBloc>(),
        child: _FilterSheet(current: current),
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────
class _UpdateRTIBody extends StatelessWidget {
  final UpdateRTILoaded state;
  const _UpdateRTIBody({required this.state});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > kTabletBreak;
        final hPad     = isTablet ? constraints.maxWidth * 0.04 : 5.0;

        return Column(
          children: [
            // ── Grid header ──────────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [kHeaderGradStart, Color(0xFF2D56C8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: hPad + 5, vertical: 6),
              child: _GridHeader(isTablet: isTablet),
            ),

            // ── List ────────────────────────────────────────────────
            Expanded(
              child: state.masterList.isEmpty
                  ? _EmptyState()
                  : isTablet
                  ? _TabletRTIList(
                  state: state, hPad: hPad)
                  : _MobileRTIList(
                  state: state, hPad: hPad),
            ),
          ],
        );
      },
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
      letterSpacing: 0.5,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(children: [
          Expanded(flex: 2, child: Text('RTI NO',    style: style)),
          Expanded(flex: 2, child: Text('RTI DATE',  style: style)),
          Expanded(flex: 2, child: Text('AMOUNT',    style: style)),
        ]),
        const SizedBox(height: 3),
        Row(children: [
          Expanded(flex: 3, child: Text('DRIVER NAME', style: style)),
        ]),
        const SizedBox(height: 3),
        Row(children: [
          Expanded(flex: 3, child: Text('TRUCK NAME', style: style)),
          Expanded(flex: 3, child: Text('REMARKS',    style: style)),
        ]),
      ],
    );
  }
}

// ─── Mobile list ─────────────────────────────────────────────────────────────
class _MobileRTIList extends StatelessWidget {
  final UpdateRTILoaded state;
  final double hPad;
  const _MobileRTIList({required this.state, required this.hPad});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(hPad, 6, hPad, 24),
      itemCount: state.masterList.length,
      itemBuilder: (ctx, i) => _RTICard(
        item:          state.masterList[i],
        index:         i,
        state:         state,
        isTablet:      false,
      ),
    );
  }
}

// ─── Tablet list (wider cards, 2-col detail grid) ─────────────────────────────
class _TabletRTIList extends StatelessWidget {
  final UpdateRTILoaded state;
  final double hPad;
  const _TabletRTIList({required this.state, required this.hPad});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(hPad, 6, hPad, 24),
      itemCount: state.masterList.length,
      itemBuilder: (ctx, i) => _RTICard(
        item:          state.masterList[i],
        index:         i,
        state:         state,
        isTablet:      true,
      ),
    );
  }
}

// ─── RTI Master Card ──────────────────────────────────────────────────────────
class _RTICard extends StatelessWidget {
  final dynamic item; // RTIViewMasterModel
  final int     index;
  final UpdateRTILoaded state;
  final bool    isTablet;

  const _RTICard({
    required this.item,
    required this.index,
    required this.state,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final isExpanded = state.expandedIndex == index;
    final valStyle   = GoogleFonts.lato(
      color:      kTextDark,
      fontWeight: FontWeight.w600,
      fontSize:   isTablet ? objfun.FontCardText + 1 : objfun.FontCardText,
    );
    final labelStyle = GoogleFonts.lato(
      color:      kTextMuted,
      fontWeight: FontWeight.w600,
      fontSize:   isTablet ? 10 : 9,
      letterSpacing: 0.4,
    );

    // Filter details for this master item
    final details = state.detailList
        .where((d) => d.RTIMasterRefId == item.Id)
        .toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kCardBorder, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: kHeaderGradStart.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top gradient accent
              Container(
                  height: 3,
                  decoration:
                  const BoxDecoration(gradient: kGradient)),

              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: RTI No + Date + Amount
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _CardField(
                              label: 'RTI NO',
                              value: item.RTINoDisplay.toString(),
                              valStyle: valStyle,
                              labelStyle: labelStyle),
                        ),
                        Expanded(
                          flex: 2,
                          child: _CardField(
                              label: 'DATE',
                              value: item.RTIDate.toString(),
                              valStyle: valStyle,
                              labelStyle: labelStyle),
                        ),
                        Expanded(
                          flex: 2,
                          child: _CardField(
                              label: 'AMOUNT',
                              value: item.Amount.toString(),
                              valStyle: valStyle,
                              labelStyle: labelStyle),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Row 2: Driver Name
                    _CardField(
                        label: 'DRIVER',
                        value: item.DriverName.toString(),
                        valStyle: valStyle,
                        labelStyle: labelStyle),
                    const SizedBox(height: 6),

                    // Row 3: Truck + Remarks
                    Row(
                      children: [
                        Expanded(
                          child: _CardField(
                              label: 'TRUCK',
                              value: item.TruckName.toString(),
                              valStyle: valStyle,
                              labelStyle: labelStyle),
                        ),
                        Expanded(
                          child: _CardField(
                              label: 'REMARKS',
                              value: item.Remarks.toString(),
                              valStyle: valStyle.copyWith(color: kTextMid),
                              labelStyle: labelStyle),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action chips row
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 8),
                child: Row(
                  children: [
                    _CardChip(
                      icon: isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      label: isExpanded ? 'Collapse' : 'Details',
                      onTap: () => context
                          .read<UpdateRTIBloc>()
                          .add(UpdateRTIRowToggled(index)),
                    ),
                    const SizedBox(width: 8),
                    _CardChip(
                      icon: Icons.picture_as_pdf_outlined,
                      label: 'PDF',
                      onTap: () => context
                          .read<UpdateRTIBloc>()
                          .add(UpdateRTIShareRequested(
                          id: item.Id,
                          rtiNoDisplay: item.RTINoDisplay)),
                    ),
                  ],
                ),
              ),

              // Expanded details
              if (isExpanded)
                _DetailsSection(
                  details:  details,
                  masterId: item.Id,
                  rtiNo:    item.RTINoDisplay,
                  isTablet: isTablet,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Card field helper ────────────────────────────────────────────────────────
class _CardField extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle valStyle;
  final TextStyle labelStyle;

  const _CardField({
    required this.label,
    required this.value,
    required this.valStyle,
    required this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 2),
        Text(value,
            style: valStyle, overflow: TextOverflow.ellipsis, maxLines: 1),
      ],
    );
  }
}

// ─── Expanded Details Section ─────────────────────────────────────────────────
class _DetailsSection extends StatelessWidget {
  final List<dynamic> details;
  final int           masterId;
  final String        rtiNo;
  final bool          isTablet;

  const _DetailsSection({
    required this.details,
    required this.masterId,
    required this.rtiNo,
    required this.isTablet,
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
      color: kTextDark,
      fontWeight: FontWeight.w500,
      fontSize: isTablet ? objfun.FontCardText : objfun.FontCardText - 1,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Detail header strip
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 6),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kHeaderGradStart, Color(0xFF2D56C8)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              Row(children: [
                Expanded(flex: 2, child: Text('JOB NO',   style: headerStyle)),
                Expanded(flex: 2, child: Text('JOB DATE', style: headerStyle)),
                Expanded(flex: 2, child: Text('SALARY',   style: headerStyle)),
              ]),
              const SizedBox(height: 3),
              Row(children: [
                Expanded(flex: 3, child: Text('CUSTOMER', style: headerStyle)),
              ]),
              const SizedBox(height: 3),
              Row(children: [
                Expanded(flex: 2, child: Text('PPIC', style: headerStyle)),
                Expanded(flex: 2, child: Text('DPIC', style: headerStyle)),
              ]),
            ],
          ),
        ),

        // Detail rows — max height cap so card doesn't overflow
        SizedBox(
          height: isTablet ? 280 : 240,
          child: details.isEmpty
              ? Center(
              child: Text('No Records',
                  style: GoogleFonts.lato(
                      color: kTextMuted, fontSize: 12)))
              : ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: details.length,
            itemBuilder: (ctx, i) {
              final d = details[i];
              return InkWell(
                onLongPress: () {
                  final rtiDetails = [
                    {
                      'RtiId': d.RTIMasterRefId,
                      'RTINo': rtiNo,
                      'JobId': d.SaleOrderMasterRefId.toString(),
                      'JobNo': d.JobNo.toString(),
                    }
                  ];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            RTIStatus(RTIDetails: rtiDetails)),
                  );
                },
                child: Container(
                  color: i % 2 == 0 ? Colors.white : kDetailBg,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            '  ${d.JobNo}',
                            style: rowStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            d.JobDate.toString(),
                            style: rowStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            d.Salary.toString(),
                            style: rowStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]),
                      const SizedBox(height: 3),
                      Text(
                        '  ${d.CustomerName}',
                        style:
                        rowStyle.copyWith(color: kTextMid),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            '  ${d.PPIC}',
                            style: rowStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            d.DPIC.toString(),
                            style: rowStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]),
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

// ─── Filter Sheet ─────────────────────────────────────────────────────────────
class _FilterSheet extends StatefulWidget {
  final UpdateRTILoaded current;
  const _FilterSheet({required this.current});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late UpdateRTILoaded _local;
  late TextEditingController _rtiCtrl;

  @override
  void initState() {
    super.initState();
    _local  = widget.current;
    _rtiCtrl = TextEditingController(text: _local.rtiNo);
  }

  @override
  void dispose() {
    _rtiCtrl.dispose();
    super.dispose();
  }

  void _emit(UpdateRTIEvent e) =>
      context.read<UpdateRTIBloc>().add(e);

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2050),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: kHeaderGradStart,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: kTextDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    final f = DateFormat('yyyy-MM-dd').format(picked);
    setState(() {
      if (isFrom) {
        _local = _local.copyWith(fromDate: f);
        _emit(UpdateRTIFromDateChanged(f));
      } else {
        _local = _local.copyWith(toDate: f);
        _emit(UpdateRTIToDateChanged(f));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > kTabletBreak;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin:
                const EdgeInsets.only(top: 12, bottom: 18),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: kCardBorder,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text('Filter',
                style: GoogleFonts.lato(
                    color: kHeaderGradStart,
                    fontWeight: FontWeight.w700,
                    fontSize: isTablet ? 16 : 15)),
            const SizedBox(height: 16),

            // Date row
            Row(
              children: [
                Expanded(
                    child: _SheetDateTile(
                        label: 'From',
                        date: _local.fromDate,
                        onTap: () => _pickDate(true))),
                const SizedBox(width: 10),
                Expanded(
                    child: _SheetDateTile(
                        label: 'To',
                        date: _local.toDate,
                        onTap: () => _pickDate(false))),
              ],
            ),
            const SizedBox(height: 12),

            // Driver + Truck (hidden for driver login)
            if (_local.visibleDriverTruck) ...[
              _FilterSearchField(
                hint: 'Select Driver',
                value: _local.driverName,
                isTablet: isTablet,
                onSearch: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const Driver(
                            Searchby: 1, SearchId: 0)),
                  ).then((_) {
                    final sel = objfun.SelectDriverList;
                    if (sel.Id != 0) {
                      setState(() {
                        _local = _local.copyWith(
                            driverId: sel.Id,
                            driverName: sel.AccountName);
                      });
                      _emit(UpdateRTIDriverChanged(
                          driverId: sel.Id,
                          driverName: sel.AccountName));
                      objfun.SelectDriverList = GetTruckModel.Empty();
                    }
                  });
                },
                onClear: () {
                  setState(() => _local =
                      _local.copyWith(driverId: 0, driverName: ''));
                  _emit(UpdateRTIDriverCleared());
                },
              ),
              const SizedBox(height: 10),

              _FilterSearchField(
                hint: 'Select Truck',
                value: _local.truckName,
                isTablet: isTablet,
                onSearch: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const Truck(
                            Searchby: 1, SearchId: 0)),
                  ).then((_) {
                    final sel = objfun.SelectTruckList;
                    if (sel.Id != 0) {
                      setState(() {
                        _local = _local.copyWith(
                            truckId: sel.Id,
                            truckName: sel.AccountName);
                      });
                      _emit(UpdateRTITruckChanged(
                          truckId: sel.Id,
                          truckName: sel.AccountName));
                      objfun.SelectTruckList = GetTruckModel.Empty();
                    }
                  });
                },
                onClear: () {
                  setState(() => _local =
                      _local.copyWith(truckId: 0, truckName: ''));
                  _emit(UpdateRTITruckCleared());
                },
              ),
              const SizedBox(height: 10),
            ],

            // RTI No text field
            TextField(
              controller: _rtiCtrl,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.done,
              style: GoogleFonts.lato(
                  color: kTextDark,
                  fontWeight: FontWeight.w600,
                  fontSize: isTablet ? objfun.FontLow + 1 : objfun.FontLow),
              decoration: InputDecoration(
                hintText: 'RTI No',
                hintStyle: GoogleFonts.lato(
                    color: kTextMuted, fontSize: objfun.FontLow),
                filled: true,
                fillColor: kDetailBg,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 13),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                    const BorderSide(color: kCardBorder, width: 0.5)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: kHeaderGradEnd, width: 1.5)),
              ),
              onChanged: (v) {
                setState(() => _local = _local.copyWith(rtiNo: v));
                _emit(UpdateRTIRtiNoChanged(v));
              },
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _GradientButton(
                  label: 'View',
                  onPressed: () {
                    _emit(UpdateRTILoadRequested());
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 12),
                _OutlineButton(
                  label: 'Close',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
      ),
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
                color: kChipBg, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.assignment_outlined,
                size: 32, color: kHeaderGradEnd),
          ),
          const SizedBox(height: 14),
          Text('No Records Found',
              style: GoogleFonts.lato(
                  color: kTextDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 15)),
          const SizedBox(height: 4),
          Text('Use the filter to load RTI records',
              style: GoogleFonts.lato(color: kTextMuted, fontSize: 12)),
        ],
      ),
    );
  }
}

// ─── FAB ──────────────────────────────────────────────────────────────────────
class _RTIFab extends StatelessWidget {
  final VoidCallback onPressed;
  const _RTIFab({required this.onPressed});

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
              color: kHeaderGradStart.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: const Icon(Icons.filter_alt_outlined,
              color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

// ─── Shared Reusable Widgets ──────────────────────────────────────────────────
class _CardChip extends StatelessWidget {
  final IconData icon;
  final String   label;
  final VoidCallback onTap;

  const _CardChip(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: kChipBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kCardBorder, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: kHeaderGradStart),
            const SizedBox(width: 4),
            Text(label,
                style: GoogleFonts.lato(
                    color: kHeaderGradStart,
                    fontWeight: FontWeight.w600,
                    fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _SheetDateTile extends StatelessWidget {
  final String   label;
  final String   date;
  final VoidCallback onTap;

  const _SheetDateTile(
      {required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final d = DateFormat('dd-MM-yy').format(DateTime.parse(date));
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: kDetailBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kCardBorder, width: 0.5),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(),
                  style: GoogleFonts.lato(
                      color: kTextMuted,
                      fontWeight: FontWeight.w700,
                      fontSize: 9,
                      letterSpacing: 0.6)),
              const SizedBox(height: 4),
              Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Text(d,
                        style: GoogleFonts.lato(
                            color: kTextDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                    const Icon(Icons.calendar_month_outlined,
                        size: 18, color: kHeaderGradEnd),
                  ]),
            ]),
      ),
    );
  }
}

class _FilterSearchField extends StatelessWidget {
  final String   hint;
  final String   value;
  final bool     isTablet;
  final VoidCallback onSearch;
  final VoidCallback onClear;

  const _FilterSearchField({
    required this.hint,
    required this.value,
    required this.isTablet,
    required this.onSearch,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: value.isEmpty ? onSearch : onClear,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: kDetailBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kCardBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value.isEmpty ? hint : value,
                style: GoogleFonts.lato(
                  color: value.isEmpty ? kTextMuted : kTextDark,
                  fontWeight: value.isEmpty
                      ? FontWeight.w500
                      : FontWeight.w600,
                  fontSize: isTablet
                      ? objfun.FontLow + 1
                      : objfun.FontLow,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              value.isNotEmpty
                  ? Icons.close_rounded
                  : Icons.search_rounded,
              size: 20,
              color: kHeaderGradEnd,
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _GradientButton(
      {required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: kGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: kHeaderGradStart.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 28, vertical: 11),
            child: Text(label,
                style: GoogleFonts.lato(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: objfun.FontMedium)),
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _OutlineButton(
      {required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kChipBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kCardBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 28, vertical: 11),
            child: Text(label,
                style: GoogleFonts.lato(
                    color: kHeaderGradStart,
                    fontWeight: FontWeight.w700,
                    fontSize: objfun.FontMedium)),
          ),
        ),
      ),
    );
  }
}