import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/models/model.dart';
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/MasterSearch/Customer.dart';
import 'package:maleva/MasterSearch/Employee.dart';
import 'package:maleva/MasterSearch/JobType.dart';
import 'package:maleva/Transaction/SaleOrder/SalesOrderAdd.dart';
import 'package:maleva/DashBoard/CustomerService/CustDashboard.dart';
import 'package:maleva/DashBoard/TransportDB/TransportDashboard.dart';
import 'package:maleva/DashBoard/User/UserDashboard.dart';
import '../../../../dashboard/admin_dashboard/view/admin_dashboard.dart';
import '../../../../dashboard/operationadmin_dashboard/view/operationadmin_dashboard.dart';
import '../../add/view/enquirytradd_tab.dart';
import '../bloc/enquirytrview_bloc.dart';
import '../bloc/enquirytrview_event.dart';
import '../bloc/enquirytrview_state.dart';
import 'package:maleva/core/colors/colors.dart' as colour;

// ─── Design Tokens ────────────────────────────────────────────────────────────


const kGradient = LinearGradient(
  colors: [colour.kHeaderGradStart, colour.kHeaderGradEnd],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ─── Root ─────────────────────────────────────────────────────────────────────
class EnquiryTRView extends StatelessWidget {
  const EnquiryTRView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EnquiryViewBloc()..add(EnquiryViewStarted()),
      child: const _EnquiryViewPage(),
    );
  }
}

// ─── Page ─────────────────────────────────────────────────────────────────────
class _EnquiryViewPage extends StatelessWidget {
  const _EnquiryViewPage();

  @override
  Widget build(BuildContext context) {
    final isTablet = objfun.MalevaScreen != 1;
    final userName = objfun.storagenew.getString('Username') ?? '';

    return BlocListener<EnquiryViewBloc, EnquiryViewState>(
      listener: (context, state) {
        if (state is EnquiryViewNavigateToEdit) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEnquiryTR(SaleMaster: state.item),
            ),
          );
        }
        if (state is EnquiryViewNavigateToPushSaleOrder) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SalesOrderAdd(
                SaleDetails: null,
                SaleMaster: state.enquiryList,
              ),
            ),
          );
        }
        if (state is EnquiryViewShowDetails) {
          _showDetailsDialog(context, state.item);
        }
        if (state is EnquiryViewError) {
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
          backgroundColor: colour.kPageBg,
          appBar: _buildAppBar(context, userName, isTablet),
          drawer: const Menulist(),
          body: BlocBuilder<EnquiryViewBloc, EnquiryViewState>(
            builder: (context, state) {
              if (state is EnquiryViewInitial || state is EnquiryViewLoading) {
                return const Center(
                  child: SpinKitFoldingCube(color: colour.kHeaderGradEnd, size: 35),
                );
              }
              if (state is EnquiryViewLoaded) {
                return _EnquiryViewBody(state: state, isTablet: isTablet);
              }
              return const SizedBox.shrink();
            },
          ),
          floatingActionButton: _EFab(
            onPressed: () {
              final state = context.read<EnquiryViewBloc>().state;
              if (state is EnquiryViewLoaded) {
                _showFilterSheet(context, state);
              }
            },
          ),
        ),
      ),
    );
  }

  void _navigateBack(BuildContext context) {
    final role = objfun.storagenew.getString('RulesType') ?? '';
    Widget dest;
    switch (role) {
      case 'ADMIN':
        dest = const NewAdminDashboard();
        break;
      case 'SALES':
        dest = const CustDashboard();
        break;
      case 'TRANSPORTATION':
        dest = const TransportDashboard();
        break;
      case 'OPERATIONADMIN':
        dest = const OperationAdminDashboard();
        break;
      default:
        dest = const Homemobile();
    }
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => dest));
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, String userName, bool isTablet) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      toolbarHeight: isTablet ? 70 : 62,
      flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: kGradient)),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        color: Colors.white,
        onPressed: () => _navigateBack(context),
      ),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enquiry TR View',
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
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
          child: _AddButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddEnquiryTR()),
            ),
          ),
        ),
      ],
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  void _showFilterSheet(BuildContext pageContext, EnquiryViewLoaded current) {
    showModalBottomSheet(
      context: pageContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: pageContext.read<EnquiryViewBloc>(),
        child: _FilterSheet(current: current),
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, Map<String, dynamic> item) {
    var collectionDate = '';
    var deliveryDate = '';
    if ((item['SPickupDate'] ?? '') != '' && item['PickupDate'] != null) {
      collectionDate = DateFormat('dd-MM-yyyy HH:mm')
          .format(DateTime.parse(item['PickupDate']));
    }
    if ((item['SDeliveryDate'] ?? '') != '' && item['DeliveryDate'] != null) {
      deliveryDate = DateFormat('dd-MM-yyyy HH:mm')
          .format(DateTime.parse(item['DeliveryDate']));
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          width: 320,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colour.kHeaderGradStart.withOpacity(0.15),
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
                    const Icon(Icons.info_outline_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Details',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailRow('Customer', item['CustomerName'] ?? ''),
                    _DetailRow('Job Type',  item['JobType'] ?? ''),
                    _DetailRow('Notify Date', item['SForwardingDate'] ?? ''),
                    _DetailRow('Collection Date', collectionDate),
                    _DetailRow('Delivery Date',   deliveryDate),
                    _DetailRow('Origin',      item['Origin'] ?? ''),
                    _DetailRow('Destination', item['Destination'] ?? ''),
                    _DetailRow('Quantity',    item['Quantity']?.toString() ?? ''),
                    _DetailRow('Weight',      item['TotalWeight']?.toString() ?? ''),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Detail Row helper ────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: GoogleFonts.lato(
                    color: colour.kTextMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 12)),
          ),
          Expanded(
            child: Text(value.isEmpty ? '-' : value,
                style: GoogleFonts.lato(
                    color: colour.kTextDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────
class _EnquiryViewBody extends StatelessWidget {
  final EnquiryViewLoaded state;
  final bool isTablet;

  const _EnquiryViewBody({required this.state, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Column(
      children: [
        // Grid header
        Container(
          height: isTablet ? height * 0.07 : height * 0.06,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [colour.kHeaderGradStart, Color(0xFF2D56C8)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: _GridHeader(isTablet: isTablet),
        ),

        // List
        Expanded(
          child: state.masterList.isEmpty
              ? _EmptyState()
              : ListView.builder(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 10),
            itemCount: state.masterList.length,
            itemBuilder: (ctx, index) {
              final item = state.masterList[index]
              as Map<String, dynamic>;
              return _EnquiryCard(
                item: item,
                index: index,
                isTablet: isTablet,
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
      letterSpacing: 0.5,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(flex: 3, child: Text('CUSTOMER NAME', style: style)),
        Expanded(flex: 3, child: Text('NOTIFY DATE',   style: style)),
      ],
    );
  }
}

// ─── Enquiry Card ─────────────────────────────────────────────────────────────
class _EnquiryCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;
  final bool isTablet;

  const _EnquiryCard({
    required this.item,
    required this.index,
    required this.isTablet,
  });

  Color _cardColor() {
    if (item['ForwardingDate'] == null) return colour.kCardBg;
    final now     = DateTime.now();
    final today   = DateFormat('yyyy-MM-dd').format(now);
    final tomorrow = DateFormat('yyyy-MM-dd').format(now.add(const Duration(days: 1)));
    final notify  = DateFormat('yyyy-MM-dd')
        .format(DateTime.parse(item['ForwardingDate']));

    if (notify == today ||
        DateTime.parse(item['ForwardingDate']).isBefore(now)) {
      return const Color(0xFFFFCDD2);
    } else if (notify == tomorrow) {
      return const Color(0xFFFFF9C4);
    }
    return colour.kCardBg;
  }

  Color _dotColor() {
    if (item['ForwardingDate'] == null) return colour.kTextMuted;
    final now     = DateTime.now();
    final today   = DateFormat('yyyy-MM-dd').format(now);
    final tomorrow = DateFormat('yyyy-MM-dd').format(now.add(const Duration(days: 1)));
    final notify  = DateFormat('yyyy-MM-dd')
        .format(DateTime.parse(item['ForwardingDate']));

    if (notify == today ||
        DateTime.parse(item['ForwardingDate']).isBefore(now)) {
      return const Color(0xFFE53935);
    } else if (notify == tomorrow) {
      return const Color(0xFFF9A825);
    }
    return const Color(0xFF388E3C);
  }

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

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onDoubleTap: () => context
            .read<EnquiryViewBloc>()
            .add(EnquiryViewDetailsRequested(item)),
        onLongPress: () => context
            .read<EnquiryViewBloc>()
            .add(EnquiryViewEditRequested(item)),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: _cardColor(),
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
              children: [
                // Top accent
                Container(
                    height: 3,
                    decoration:
                    const BoxDecoration(gradient: kGradient)),

                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CUSTOMER', style: labelStyle),
                            const SizedBox(height: 2),
                            Text(
                              item['CustomerName'] ?? '',
                              style: valStyle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('NOTIFY DATE', style: labelStyle),
                            const SizedBox(height: 2),
                            Text(
                              item['SForwardingDate'] ?? '',
                              style: valStyle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _dotColor(),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),

                // Action chips
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    children: [
                      _CardChip(
                        icon: Icons.fast_forward_sharp,
                        label: 'Push to SO',
                        onTap: () async {
                          final confirm =
                          await objfun.ConfirmationMsgYesNo(
                              context,
                              'Do You Want to Push to SalesOrder ?');
                          if (confirm == true) {
                            context.read<EnquiryViewBloc>().add(
                                EnquiryViewPushToSaleOrder(index));
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      _CardChip(
                        icon: Icons.cancel_outlined,
                        label: 'Cancel',
                        color: const Color(0xFFB33040),
                        onTap: () async {
                          final confirm =
                          await objfun.ConfirmationMsgYesNo(
                              context,
                              'Do You Want to Cancel the Enquiry ?');
                          if (confirm == true) {
                            context.read<EnquiryViewBloc>().add(
                                EnquiryViewCancelRequested(
                                    item['Id']));
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      _CardChip(
                        icon: Icons.info_outline_rounded,
                        label: 'Details',
                        onTap: () => context
                            .read<EnquiryViewBloc>()
                            .add(EnquiryViewDetailsRequested(item)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Filter Sheet ─────────────────────────────────────────────────────────────
class _FilterSheet extends StatefulWidget {
  final EnquiryViewLoaded current;
  const _FilterSheet({required this.current});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late EnquiryViewLoaded _local;

  @override
  void initState() {
    super.initState();
    _local = widget.current;
  }

  void _emit(EnquiryViewEvent e) =>
      context.read<EnquiryViewBloc>().add(e);

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2050),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
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
    if (picked == null) return;
    final f = DateFormat('yyyy-MM-dd').format(picked);
    setState(() {
      if (isFrom) {
        _local = _local.copyWith(fromDate: f);
        _emit(EnquiryViewFromDateChanged(f));
      } else {
        _local = _local.copyWith(toDate: f);
        _emit(EnquiryViewToDateChanged(f));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = objfun.MalevaScreen != 1;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                margin: const EdgeInsets.only(top: 12, bottom: 18),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: colour.kCardBorder,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text('Filter',
                style: GoogleFonts.lato(
                    color: colour.kHeaderGradStart,
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

            // Customer
            _ESearchField(
              hint: 'Customer Name',
              value: _local.custName,
              onSearch: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                      const Customer(Searchby: 1, SearchId: 0)),
                ).then((_) {
                  final sel = objfun.SelectCustomerList;
                  if (sel.Id != 0) {
                    setState(() {
                      _local = _local.copyWith(
                          custId: sel.Id, custName: sel.AccountName);
                    });
                    _emit(EnquiryViewCustomerChanged(
                        custId: sel.Id, custName: sel.AccountName));
                    objfun.SelectCustomerList = CustomerModel.Empty();
                  }
                });
              },
              onClear: () {
                setState(
                        () => _local = _local.copyWith(custId: 0, custName: ''));
                _emit(EnquiryViewCustomerCleared());
              },
            ),
            const SizedBox(height: 10),

            // Job Type
            _ESearchField(
              hint: 'Job Type',
              value: _local.jobName,
              onSearch: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                      const JobType(Searchby: 1, SearchId: 0)),
                ).then((_) async {
                  final sel = objfun.SelectJobTypeList;
                  if (sel.Id != 0) {
                    await OnlineApi.SelectAllJobStatus(context, sel.Id);
                    setState(() {
                      _local =
                          _local.copyWith(jobId: sel.Id, jobName: sel.Name);
                    });
                    _emit(EnquiryViewJobTypeChanged(
                        jobId: sel.Id, jobName: sel.Name));
                    objfun.SelectJobTypeList = JobTypeModel.Empty();
                  }
                });
              },
              onClear: () {
                setState(
                        () => _local = _local.copyWith(jobId: 0, jobName: ''));
                _emit(EnquiryViewJobTypeCleared());
              },
            ),
            const SizedBox(height: 10),

            // Employee
            _ESearchField(
              hint: 'Select Employee',
              value: _local.empName,
              disabled: _local.checkLEmp,
              onSearch: () async {
                await OnlineApi.SelectEmployee(context, 'sales', 'admin');
                if (!_local.checkLEmp) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                        const Employee(Searchby: 1, SearchId: 0)),
                  ).then((_) {
                    final sel = objfun.SelectEmployeeList;
                    if (sel.Id != 0) {
                      setState(() {
                        _local = _local.copyWith(
                            empId: sel.Id, empName: sel.AccountName);
                      });
                      _emit(EnquiryViewEmployeeChanged(
                          empId: sel.Id, empName: sel.AccountName));
                      objfun.SelectEmployeeList = EmployeeModel.Empty();
                    }
                  });
                }
              },
              onClear: () {
                setState(
                        () => _local = _local.copyWith(empId: 0, empName: ''));
                _emit(EnquiryViewEmployeeCleared());
              },
            ),
            const SizedBox(height: 12),

            // Checkboxes
            Row(
              children: [
                _AnimatedCheckbox(
                  label: 'L.Emp',
                  value: _local.checkLEmp,
                  onChanged: (v) {
                    setState(() => _local = _local.copyWith(checkLEmp: v));
                    _emit(EnquiryViewCheckboxChanged(
                        field: 'lEmp', value: v));
                  },
                ),
                const SizedBox(width: 20),
                _AnimatedCheckbox(
                  label: 'ENQ',
                  value: _local.checkEnq,
                  onChanged: (v) {
                    setState(() => _local = _local.copyWith(checkEnq: v));
                    _emit(EnquiryViewCheckboxChanged(
                        field: 'enq', value: v));
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _GradientButton(
                  label: 'View',
                  onPressed: () {
                    _emit(EnquiryViewLoadRequested(useDate: true));
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
              color: colour.kChipBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.assignment_outlined,
                size: 32, color: colour.kHeaderGradEnd),
          ),
          const SizedBox(height: 14),
          Text('No Records Found',
              style: GoogleFonts.lato(
                  color: colour.kTextDark, fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 4),
          Text('Try adjusting your filters',
              style: GoogleFonts.lato(color: colour.kTextMuted, fontSize: 12)),
        ],
      ),
    );
  }
}

// ─── FAB ──────────────────────────────────────────────────────────────────────
class _EFab extends StatelessWidget {
  final VoidCallback onPressed;
  const _EFab({required this.onPressed});

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

// ─── Add Button in AppBar ─────────────────────────────────────────────────────
class _AddButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _AddButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text('Add',
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

// ─── Shared reusable widgets ──────────────────────────────────────────────────

class _CardChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _CardChip(
      {required this.icon,
        required this.label,
        required this.onTap,
        this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? colour.kHeaderGradStart;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color != null
              ? color!.withOpacity(0.08)
              : colour.kChipBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: color != null
                  ? color!.withOpacity(0.3)
                  : colour.kCardBorder,
              width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: c),
            const SizedBox(width: 4),
            Text(label,
                style: GoogleFonts.lato(
                    color: c,
                    fontWeight: FontWeight.w600,
                    fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _SheetDateTile extends StatelessWidget {
  final String label;
  final String date;
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colour.kDetailBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colour.kCardBorder, width: 0.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(),
              style: GoogleFonts.lato(
                  color: colour.kTextMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 9,
                  letterSpacing: 0.6)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(d,
                  style: GoogleFonts.lato(
                      color: colour.kTextDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
              const Icon(Icons.calendar_month_outlined,
                  size: 18, color: colour.kHeaderGradEnd),
            ],
          ),
        ]),
      ),
    );
  }
}

class _ESearchField extends StatelessWidget {
  final String hint;
  final String value;
  final bool disabled;
  final VoidCallback onSearch;
  final VoidCallback onClear;

  const _ESearchField({
    required this.hint,
    required this.value,
    this.disabled = false,
    required this.onSearch,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: disabled ? null : (value.isEmpty ? onSearch : onClear),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: disabled ? const Color(0xFFF5F5F5) : colour.kDetailBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colour.kCardBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value.isEmpty ? hint : value,
                style: GoogleFonts.lato(
                  color: value.isEmpty ? colour.kTextMuted : colour.kTextDark,
                  fontWeight:
                  value.isEmpty ? FontWeight.w500 : FontWeight.w600,
                  fontSize: objfun.FontLow,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              value.isNotEmpty ? Icons.close_rounded : Icons.search_rounded,
              size: 20,
              color: disabled ? colour.kTextMuted : colour.kHeaderGradEnd,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final void Function(bool) onChanged;

  const _AnimatedCheckbox(
      {required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isTablet = objfun.MalevaScreen != 1;
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                gradient: value ? kGradient : null,
                border: value
                    ? null
                    : Border.all(color: colour.kCardBorder, width: 1.5),
                borderRadius: BorderRadius.circular(5),
              ),
              child: value
                  ? const Icon(Icons.check_rounded,
                  size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 6),
            Text(label,
                style: GoogleFonts.lato(
                    color: colour.kTextDark,
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet
                        ? objfun.FontLow + 1
                        : objfun.FontLow)),
          ],
        ),
      ),
    );
  }
}

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
              offset: const Offset(0, 4))
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
            child: Text(label,
                style: GoogleFonts.lato(
                    color: colour.kHeaderGradStart,
                    fontWeight: FontWeight.w700,
                    fontSize: objfun.FontMedium)),
          ),
        ),
      ),
    );
  }
}