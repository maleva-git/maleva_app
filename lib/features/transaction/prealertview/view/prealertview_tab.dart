import 'package:maleva/core/utils/system_helpers.dart';
import 'package:maleva/core/network/api_legacy_helper.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/menu/menulist.dart';
import '../../../../core/theme/tokens.dart';
import '../../../dashboard/common_tabs/transportDB/view/transportdb_tab.dart';
import '../../../dashboard/admin_dashboard/view/admin_dashboard.dart';
import '../../../dashboard/airfreight_dashboard/view/airfreight_dashboard.dart';
import '../../../dashboard/boarding_dashboard/view/boarding_dashboard.dart';
import '../../../dashboard/forwarding_dashboard/view/forwarding_dashboard.dart';
import '../../../dashboard/operationadmin_dashboard/view/operationadmin_dashboard.dart';
import '../../../dashboard/sales_dashboard/view/salesdashboard_dashboard.dart';
import '../../../home/view/home_tab.dart';
import '../../../mastersearch/Customer.dart';
import '../../../mastersearch/JobType.dart';
import '../../../mastersearch/Port.dart';
import '../bloc/prealertview_bloc.dart';
import '../bloc/prealertview_event.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/core/models/shared/response_view_model.dart';
import 'package:maleva/core/models/shared/customer_model.dart';
import 'package:maleva/features/operations/models/job_status_model.dart';
import 'package:maleva/features/operations/models/job_type_model.dart';

class PreAlertReport extends StatelessWidget {
  const PreAlertReport({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (providerContext) => PreAlertBloc()..add(PreAlertStarted(providerContext)),
      child: const _PreAlertPage(),
    );
  }
}

class _PreAlertPage extends StatelessWidget {
  const _PreAlertPage();

  Future<void> _generatePdf(BuildContext context, PreAlertLoaded s) async {
    const reportName = 'PreAlertReport';
    final master = {
      'SoId':                0,
      'Comid':               AppGlobals.storagenew.getInt('Comid') ?? 0,
      'Fromdate':            s.fromDate,
      'Todate':              s.toDate,
      'CustomerId':          s.custId,
      'DId':                 0,
      'TId':                 0,
      'Jobid':               s.jobId,
      'SPort':               s.portId,
      'completestatusnotshow': s.completeStatusNotShow,
      'Search':              s.vessel.isNotEmpty ? s.vessel : null,
      'Remarks':             '3',
      'DeliveryDone':        s.checkDelivery,
      'ETA':                 s.etaEnabled,
      'ETAType':             s.etaRadioVal,
      'Pickupdate':          s.checkPickUp,
      'Cons':                s.checkConsolidated,
    };
    final header = {'Content-Type': 'application/json; charset=UTF-8'};
    final resultData = await ApiLegacyHelper.apiAllinoneSelectArray(
        '${ApiConstants.apiPreAlertReport}$reportName', master, header, context);

    if (resultData != null && resultData != '') {
      final value = ResponseViewModel.fromJson(resultData);
      if (value.IsSuccess == true) {
        SystemHelpers.launchInBrowser(value.data1);
      }
    }
  }

  void _navigateBack(BuildContext context) {
    final role = AppGlobals.storagenew.getString('RulesType') ?? '';
    Widget dest;
    switch (role) {
      case 'ADMIN': dest = const NewAdminDashboard(); break;
      case 'SALES': dest = const SalesDashboard(); break;
      case 'TRANSPORTATION': dest = const TransportDashboard(); break;
      case 'OPERATIONADMIN': dest = const OperationAdminDashboard(); break;
      case 'AIR FRIEGHT': dest = const AirfreightDashboard(); break;
      case 'BOARDING': case 'OPERATION': dest = const BoardingDashboard(); break;
      case 'FORWARDING': dest = const ForwardingDashboard(); break;
      default: dest = const Homemobile();
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => dest));
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = AppGlobals.MalevaScreen != 1;
    final userName = AppGlobals.storagenew.getString('Username') ?? '';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _navigateBack(context);
      },
      child: Scaffold(
        backgroundColor: colour.kPageBg,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          toolbarHeight: isTablet ? 70 : 62,
          flexibleSpace: Container(decoration: const BoxDecoration(gradient: colour.kGradient)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
            onPressed: () => _navigateBack(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pre Alert Report', style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.w700, fontSize: isTablet ? AppGlobals.FontMedium + 2 : AppGlobals.FontMedium)),
              Text(userName, style: GoogleFonts.lato(color: Colors.white.withValues(alpha: 0.65), fontWeight: FontWeight.w500, fontSize: isTablet ? AppGlobals.FontLow : AppGlobals.FontLow - 1)),
            ],
          ),
        ),
        drawer: const Menulist(),
        body: BlocBuilder<PreAlertBloc, PreAlertState>(
          builder: (context, state) {
            if (state is PreAlertLoading || state is PreAlertInitial) {
              return const Center(child: SpinKitFoldingCube(color: AppTokens.invoiceHeaderEnd, size: 35));
            }
            if (state is PreAlertError) {
              return Center(child: Text(state.message));
            }
            if (state is PreAlertLoaded) {
              return _buildFilterForm(context, state, isTablet);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildFilterForm(BuildContext context, PreAlertLoaded local, bool isTablet) {
    void emit(PreAlertEvent event) => context.read<PreAlertBloc>().add(event);

    Future<void> pickDate(bool isFrom) async {
      final picked = await showDatePicker(
        context: context, initialDate: DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime(2050),
      );
      if (picked != null) {
        final formatted = DateFormat('yyyy-MM-dd').format(picked);
        emit(isFrom ? PreAlertFromDateChanged(formatted) : PreAlertToDateChanged(formatted));
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _SheetDateTile(label: 'From', date: local.fromDate, onTap: () => pickDate(true))),
              const SizedBox(width: 10),
              Expanded(child: _SheetDateTile(label: 'To', date: local.toDate, onTap: () => pickDate(false))),
            ],
          ),
          const SizedBox(height: 12),
          _PASearchField(
            hint: 'Customer Name', value: local.custName,
            onSearch: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Customer(Searchby: 1, SearchId: 0))).then((navRes) { if (navRes != null) { AppGlobals.SelectCustomerList = navRes; }
              if (AppGlobals.SelectCustomerList.Id != 0) {
                emit(PreAlertCustomerChanged(custId: AppGlobals.SelectCustomerList.Id, custName: AppGlobals.SelectCustomerList.AccountName));
                AppGlobals.SelectCustomerList = CustomerModel.Empty();
              }
            }),
            onClear: () => emit(PreAlertCustomerCleared()),
          ),
          const SizedBox(height: 10),
          _PASearchField(
            hint: 'Select Job Type', value: local.jobName, disabled: local.checkLEmp,
            onSearch: () async {
              await OnlineApi.SelectJobType(context); if (!context.mounted) return;Navigator.push(context, MaterialPageRoute(builder: (_) => const JobType(Searchby: 1, SearchId: 0))).then((navRes) { if (navRes != null) { AppGlobals.SelectJobTypeList = navRes; }
                if (AppGlobals.SelectJobTypeList.Id != 0) {
                  emit(PreAlertJobTypeChanged(jobId: AppGlobals.SelectJobTypeList.Id, jobName: AppGlobals.SelectJobTypeList.Name));
                  AppGlobals.SelectJobTypeList = JobTypeModel.Empty();
                }
              });
            },
            onClear: () => emit(PreAlertJobTypeCleared()),
          ),
          const SizedBox(height: 10),
          _PASearchField(
            hint: 'Select Port', value: local.portName,
            onSearch: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Port(Searchby: 1, SearchId: 0))).then((navRes) {
              if (AppGlobals.SelectedPortName.isNotEmpty) {
                emit(PreAlertPortChanged(portId: 0, portName: AppGlobals.SelectedPortName));
                AppGlobals.SelectJobStatusList = JobStatusModel.Empty();
              }
            }),
            onClear: () => emit(PreAlertPortCleared()),
          ),
          const SizedBox(height: 10),
          _PATextField(
            hint: 'Vessel', value: local.vessel,
            onChanged: (v) => emit(PreAlertVesselChanged(v)),
          ),
          const SizedBox(height: 14),
          _CheckboxGrid(
            local: local,
            onChanged: (field, val) => emit(PreAlertCheckboxChanged(field: field, value: val)),
            isTablet: isTablet,
          ),
          const SizedBox(height: 14),
          _ETARadioRow(
            etaVal: local.etaVal,
            onChanged: (val, radio, enabled) => emit(PreAlertETAChanged(etaVal: val, etaRadio: radio, etaEnabled: enabled)),
            isTablet: isTablet,
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: _GradientButton(
              label: 'View',
              onPressed: () => _generatePdf(context, local),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reusable UI Components ───────────────────────────────────────────────────

class _SheetDateTile extends StatelessWidget {
  final String label;
  final String date;
  final VoidCallback onTap;

  const _SheetDateTile({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final displayDate = DateFormat('dd-MM-yy').format(DateTime.parse(date));
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: colour.kDetailBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTokens.maintCardBorder, width: 0.5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: GoogleFonts.lato(color: AppTokens.planTextMuted, fontWeight: FontWeight.w700, fontSize: 9)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(displayDate, style: GoogleFonts.lato(color: colour.kTextDark, fontWeight: FontWeight.w700, fontSize: 13)),
                const Icon(Icons.calendar_month_outlined, size: 18, color:AppTokens.invoiceHeaderEnd),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PASearchField extends StatelessWidget {
  final String hint; final String value; final bool disabled; final VoidCallback onSearch; final VoidCallback onClear;
  const _PASearchField({required this.hint, required this.value, this.disabled = false, required this.onSearch, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: disabled ? null : (value.isEmpty ? onSearch : onClear),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: disabled ? const Color(0xFFF5F5F5) : colour.kDetailBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTokens.maintCardBorder, width: 0.5)),
        child: Row(
          children: [
            Expanded(child: Text(value.isEmpty ? hint : value, style: GoogleFonts.lato(color: value.isEmpty ? AppTokens.planTextMuted : colour.kTextDark, fontWeight: value.isEmpty ? FontWeight.w500 : FontWeight.w600, fontSize: AppGlobals.FontLow))),
            Icon(value.isNotEmpty ? Icons.close_rounded : Icons.search_rounded, size: 20, color: disabled ? AppTokens.planTextMuted :AppTokens.invoiceHeaderEnd),
          ],
        ),
      ),
    );
  }
}

class _PATextField extends StatelessWidget {
  final String hint; final String value; final void Function(String) onChanged;
  const _PATextField({required this.hint, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: value)..selection = TextSelection.collapsed(offset: value.length),
      textCapitalization: TextCapitalization.characters, textInputAction: TextInputAction.done, onChanged: onChanged,
      style: GoogleFonts.lato(color: colour.kTextDark, fontWeight: FontWeight.w600, fontSize: AppGlobals.FontLow),
      decoration: InputDecoration(hintText: hint, hintStyle: GoogleFonts.lato(color: AppTokens.planTextMuted, fontSize: AppGlobals.FontLow), filled: true, fillColor: colour.kDetailBg, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTokens.maintCardBorder, width: 0.5)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color:AppTokens.invoiceHeaderEnd, width: 1.5))),
    );
  }
}

class _CheckboxGrid extends StatelessWidget {
  final PreAlertLoaded local; final void Function(String field, bool value) onChanged; final bool isTablet;
  const _CheckboxGrid({required this.local, required this.onChanged, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final items = [('pickup', 'PickUp', local.checkPickUp), ('port', 'Port', local.checkPort), ('vesselName', 'Vessel Name', local.checkVesselName), ('consolidated', 'Consolidated', local.checkConsolidated), ('delivery', 'Delivery Done', local.checkDelivery), ('lEmp', 'L.Emp', local.checkLEmp)];
    return Wrap(
      spacing: 0, runSpacing: 4,
      children: items.map((item) {
        return SizedBox(
          width: MediaQuery.of(context).size.width * (isTablet ? 0.27 : 0.42),
          child: InkWell(
            onTap: () => onChanged(item.$1, !item.$3),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: Row(
                children: [
                  AnimatedContainer(duration: const Duration(milliseconds: 180), width: 18, height: 18, decoration: BoxDecoration(gradient: item.$3 ? colour.kGradient : null, border: item.$3 ? null : Border.all(color: AppTokens.maintCardBorder, width: 1.5), borderRadius: BorderRadius.circular(5)), child: item.$3 ? const Icon(Icons.check_rounded, size: 12, color: Colors.white) : null),
                  const SizedBox(width: 6),
                  Text(item.$2, style: GoogleFonts.lato(color: colour.kTextDark, fontWeight: FontWeight.w600, fontSize: isTablet ? AppGlobals.FontLow + 1 : AppGlobals.FontLow)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ETARadioRow extends StatelessWidget {
  final String etaVal; final void Function(String val, String radio, bool enabled) onChanged; final bool isTablet;
  const _ETARadioRow({required this.etaVal, required this.onChanged, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.lato(color: colour.kTextDark, fontWeight: FontWeight.w600, fontSize: isTablet ? AppGlobals.FontLow + 1 : AppGlobals.FontLow);
    final options = [('1', 'OETA', '1', true), ('2', 'LETA', '1', true), ('3', 'All', '2', true), ('0', 'None', 'O', false)];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(color: colour.kDetailBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTokens.maintCardBorder, width: 0.5)),
      child: Row(
        children: options.map((opt) {
          final selected = etaVal == opt.$1;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(opt.$1, opt.$3, opt.$4),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 16, height: 16, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: selected ?AppTokens.invoiceHeaderEnd : AppTokens.maintCardBorder, width: 1.5), gradient: selected ? colour.kGradient : null), child: selected ? const Icon(Icons.circle, size: 8, color: Colors.white) : null),
                    const SizedBox(width: 4),
                    Flexible(child: Text(opt.$2, style: style, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label; final VoidCallback onPressed;
  const _GradientButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: colour.kGradient, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: AppTokens.invoiceHeaderStart.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            child: Text(label, textAlign: TextAlign.center, style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.w700, fontSize: AppGlobals.FontMedium + 1)),
          ),
        ),
      ),
    );
  }
}