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
import 'package:maleva/MasterSearch/JobType.dart';
import 'package:maleva/MasterSearch/Location.dart';
import '../../../../../core/theme/tokens.dart';
import '../bloc/enquirytradd_bloc.dart';
import '../bloc/enquirytradd_event.dart';
import '../bloc/enquirytradd_state.dart';
import 'package:maleva/core/colors/colors.dart' as colour;

const kGradient = LinearGradient(
  colors: [AppTokens.invoiceHeaderStart, colour.kHeaderGradEnd],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class AddEnquiryTR extends StatelessWidget {
  final Map<String, dynamic>? SaleMaster;
  const AddEnquiryTR({super.key, this.SaleMaster});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      EnquiryAddBloc()..add(EnquiryAddStarted(saleMaster: SaleMaster)),
      child: const _AddEnquiryPage(),
    );
  }
}


class _AddEnquiryPage extends StatelessWidget {
  const _AddEnquiryPage();

  @override
  Widget build(BuildContext context) {
    final isTablet = objfun.MalevaScreen != 1;
    final userName = objfun.storagenew.getString('Username') ?? '';

    return BlocListener<EnquiryAddBloc, EnquiryAddState>(
      listener: (context, state) async {
        if (state is EnquiryAddSaveSuccess) {
          await objfun.ConfirmationOK('Created Successfully', context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AddEnquiryTR()),
          );
        }
        if (state is EnquiryAddError) {
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
          Navigator.pop(context);
          return false;
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: colour.kPageBg,
          appBar: _buildAppBar(context, userName, isTablet),
          drawer: const Menulist(),
          body: BlocBuilder<EnquiryAddBloc, EnquiryAddState>(
            builder: (context, state) {
              if (state is EnquiryAddInitial || state is EnquiryAddLoading) {
                return const Center(
                  child:
                  SpinKitFoldingCube(color: colour.kHeaderGradEnd, size: 35),
                );
              }
              if (state is EnquiryAddLoaded) {
                return _AddEnquiryBody(state: state, isTablet: isTablet);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
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
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enquiry TR Add',
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
          child: _SaveButton(
            onPressed: () async {
              final confirm = await objfun.ConfirmationMsgYesNo(
                  context, 'Do You Want to Save ?');
              if (confirm == true) {
                final state = context.read<EnquiryAddBloc>().state;
                if (state is EnquiryAddLoaded &&
                    state.custName.isEmpty) {
                  objfun.toastMsg('Enter Customer Name', '', context);
                  return;
                }
                context
                    .read<EnquiryAddBloc>()
                    .add(EnquiryAddSaveRequested());
              }
            },
          ),
        ),
      ],
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────
class _AddEnquiryBody extends StatelessWidget {
  final EnquiryAddLoaded state;
  final bool isTablet;

  const _AddEnquiryBody(
      {required this.state, required this.isTablet});

  void _emit(BuildContext context, EnquiryAddEvent event) =>
      context.read<EnquiryAddBloc>().add(event);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
      children: [
        // ── Customer ────────────────────────────────────────────────
        _SectionLabel('Customer Name', isTablet),
        const SizedBox(height: 6),
        _AddSearchField(
          hint: 'Customer Name',
          value: state.custName,
          onSearch: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                  const Customer(Searchby: 1, SearchId: 0)),
            ).then((_) async {
              final sel = objfun.SelectCustomerList;
              if (sel.Id != 0) {
                _emit(context, EnquiryAddCustomerChanged(
                    custId: sel.Id, custName: sel.AccountName));
                await OnlineApi.loadCustomerCurrency(context, sel.Id);
                objfun.SelectCustomerList = CustomerModel.Empty();
              }
            });
          },
          onClear: () => _emit(context, EnquiryAddCustomerCleared()),
        ),
        const SizedBox(height: 12),

        // ── Job Type ─────────────────────────────────────────────────
        _SectionLabel('Job Type', isTablet),
        const SizedBox(height: 6),
        _AddSearchField(
          hint: 'Select Job Type',
          value: state.jobTypeName,
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
                _emit(context, EnquiryAddJobTypeChanged(
                    jobTypeId: sel.Id, jobTypeName: sel.Name));
                objfun.SelectJobTypeList = JobTypeModel.Empty();
              }
            });
          },
          onClear: () => _emit(context, EnquiryAddJobTypeCleared()),
        ),
        const SizedBox(height: 12),

        // ── Notify Date ───────────────────────────────────────────────
        _SectionLabel('Notify Date', isTablet),
        const SizedBox(height: 6),
        _DateTimeField(
          dateStr: state.notifyDate,
          enabled: true,
          width: width,
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2050),
              builder: _datepickerTheme,
            );
            if (picked != null) {
              _emit(context,
                  EnquiryAddNotifyDateChanged(picked.toString()));
            }
          },
        ),
        const SizedBox(height: 12),

        // ── Origin ────────────────────────────────────────────────────
        _SectionLabel('Origin', isTablet),
        const SizedBox(height: 6),
        _AddSearchField(
          hint: 'Select Origin',
          value: state.originName,
          onSearch: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                  const Location(Searchby: 1, SearchId: 0)),
            ).then((_) {
              final sel = objfun.SelectLocationList;
              if (sel.Id != 0) {
                _emit(context, EnquiryAddOriginChanged(
                    originId: sel.Id, originName: sel.Location));
                objfun.SelectLocationList = LocationModel.Empty();
              }
            });
          },
          onClear: () => _emit(context, EnquiryAddOriginCleared()),
        ),
        const SizedBox(height: 12),

        // ── Destination ───────────────────────────────────────────────
        _SectionLabel('Destination', isTablet),
        const SizedBox(height: 6),
        _AddSearchField(
          hint: 'Select Destination',
          value: state.destinationName,
          onSearch: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                  const Location(Searchby: 1, SearchId: 0)),
            ).then((_) {
              final sel = objfun.SelectLocationList;
              if (sel.Id != 0) {
                _emit(context, EnquiryAddDestinationChanged(
                    destinationId: sel.Id,
                    destinationName: sel.Location));
                objfun.SelectLocationList = LocationModel.Empty();
              }
            });
          },
          onClear: () =>
              _emit(context, EnquiryAddDestinationCleared()),
        ),
        const SizedBox(height: 12),

        // ── Collection Date ───────────────────────────────────────────
        _DateTimeRow(
          label: 'Collection Date',
          dateStr: state.collectionDate,
          enabled: state.checkCollection,
          isTablet: isTablet,
          onTap: () async {
            if (!state.checkCollection) return;
            await _pickDateTime(
              context,
              onPicked: (dt) => _emit(
                  context, EnquiryAddCollectionDateChanged(dt.toString())),
            );
          },
          onCheckChanged: (v) => _emit(context,
              EnquiryAddCheckboxChanged(field: 'collection', value: v)),
        ),
        const SizedBox(height: 12),

        // ── Delivery Date ─────────────────────────────────────────────
        _DateTimeRow(
          label: 'Delivery Date',
          dateStr: state.deliveryDate,
          enabled: state.checkDelivery,
          isTablet: isTablet,
          onTap: () async {
            if (!state.checkDelivery) return;
            await _pickDateTime(
              context,
              onPicked: (dt) => _emit(
                  context, EnquiryAddDeliveryDateChanged(dt.toString())),
            );
          },
          onCheckChanged: (v) => _emit(context,
              EnquiryAddCheckboxChanged(field: 'delivery', value: v)),
        ),
        const SizedBox(height: 12),

        // ── Quantity + Weight ─────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _AddTextField(
                hint: 'Quantity',
                value: state.quantity,
                onChanged: (v) => _emit(context,
                    EnquiryAddTextChanged(field: 'quantity', value: v)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AddTextField(
                hint: 'Weight',
                value: state.weight,
                onChanged: (v) => _emit(context,
                    EnquiryAddTextChanged(field: 'weight', value: v)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── L Port + O Port ───────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _AddTextField(
                hint: 'L Port',
                value: state.lPort,
                onChanged: (v) => _emit(context,
                    EnquiryAddTextChanged(field: 'lPort', value: v)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AddTextField(
                hint: 'O Port',
                value: state.oPort,
                onChanged: (v) => _emit(context,
                    EnquiryAddTextChanged(field: 'oPort', value: v)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Future<void> _pickDateTime(
      BuildContext context, {
        required void Function(DateTime) onPicked,
      }) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      initialDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: _datepickerTheme,
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    final t = time ?? TimeOfDay.now();
    onPicked(DateTime(date.year, date.month, date.day, t.hour, t.minute));
  }

  Widget _datepickerTheme(BuildContext ctx, Widget? child) => Theme(
    data: Theme.of(ctx).copyWith(
      colorScheme: const ColorScheme.light(
        primary: AppTokens.invoiceHeaderStart,
        onPrimary: Colors.white,
        surface: Colors.white,
        onSurface: colour.kTextDark,
      ),
    ),
    child: child!,
  );
}

// ─── Section label ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  final bool isTablet;
  const _SectionLabel(this.text, this.isTablet);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.lato(
        color: colour.kTextMid,
        fontWeight: FontWeight.w600,
        fontSize: isTablet ? objfun.FontLow + 1 : objfun.FontLow,
        letterSpacing: 0.2,
      ),
    );
  }
}

// ─── Date time field (read-only tap to pick) ──────────────────────────────────
class _DateTimeField extends StatelessWidget {
  final String dateStr;
  final bool enabled;
  final double width;
  final VoidCallback onTap;

  const _DateTimeField({
    required this.dateStr,
    required this.enabled,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String display;
    try {
      display = DateFormat(width <= 370 ? 'dd-MM-yy' : 'dd-MM-yyyy')
          .format(DateTime.parse(dateStr));
    } catch (_) {
      display = dateStr;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: colour.kDetailBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTokens.maintCardBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                display,
                style: GoogleFonts.lato(
                  color: enabled ? colour.kTextDark : AppTokens.planTextMuted,
                  fontWeight: FontWeight.w600,
                  fontSize: objfun.FontLow,
                ),
              ),
            ),
            const Icon(Icons.calendar_month_outlined,
                size: 20, color: colour.kHeaderGradEnd),
          ],
        ),
      ),
    );
  }
}

// ─── Date + Time row with checkbox ───────────────────────────────────────────
class _DateTimeRow extends StatelessWidget {
  final String label;
  final String dateStr;
  final bool enabled;
  final bool isTablet;
  final VoidCallback onTap;
  final void Function(bool) onCheckChanged;

  const _DateTimeRow({
    required this.label,
    required this.dateStr,
    required this.enabled,
    required this.isTablet,
    required this.onTap,
    required this.onCheckChanged,
  });

  @override
  Widget build(BuildContext context) {
    String display;
    try {
      display = DateFormat('dd-MM-yyyy HH:mm:ss')
          .format(DateTime.parse(dateStr));
    } catch (_) {
      display = dateStr;
    }

    return Row(
      children: [
        // Label
        SizedBox(
          width: isTablet ? 140 : 110,
          child: Text(
            label,
            style: GoogleFonts.lato(
              color: colour.kTextMid,
              fontWeight: FontWeight.w600,
              fontSize: isTablet ? objfun.FontLow + 1 : objfun.FontLow,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 8),

        // Date container
        Expanded(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: colour.kDetailBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTokens.maintCardBorder, width: 0.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      display,
                      style: GoogleFonts.lato(
                        color: enabled ? colour.kTextDark : AppTokens.planTextMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: isTablet
                            ? objfun.FontLow + 1
                            : objfun.FontLow - 1,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 18,
                    color: enabled ? colour.kHeaderGradEnd : AppTokens.planTextMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Checkbox
        InkWell(
          onTap: () => onCheckChanged(!enabled),
          borderRadius: BorderRadius.circular(6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              gradient: enabled ? kGradient : null,
              border: enabled
                  ? null
                  : Border.all(color: AppTokens.maintCardBorder, width: 1.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: enabled
                ? const Icon(Icons.check_rounded,
                size: 14, color: Colors.white)
                : null,
          ),
        ),
      ],
    );
  }
}

// ─── Search field (tap to navigate) ──────────────────────────────────────────
class _AddSearchField extends StatelessWidget {
  final String hint;
  final String value;
  final bool disabled;
  final VoidCallback onSearch;
  final VoidCallback onClear;

  const _AddSearchField({
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: disabled ? const Color(0xFFF5F5F5) : colour.kDetailBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTokens.maintCardBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value.isEmpty ? hint : value,
                style: GoogleFonts.lato(
                  color: value.isEmpty ? AppTokens.planTextMuted : colour.kTextDark,
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
              color: disabled ? AppTokens.planTextMuted : colour.kHeaderGradEnd,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Text field ───────────────────────────────────────────────────────────────
class _AddTextField extends StatelessWidget {
  final String hint;
  final String value;
  final void Function(String) onChanged;

  const _AddTextField({
    required this.hint,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: value)
        ..selection = TextSelection.collapsed(offset: value.length),
      textCapitalization: TextCapitalization.characters,
      textInputAction: TextInputAction.done,
      onChanged: onChanged,
      style: GoogleFonts.lato(
        color: colour.kTextDark,
        fontWeight: FontWeight.w600,
        fontSize: objfun.FontLow,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
        GoogleFonts.lato(color: AppTokens.planTextMuted, fontSize: objfun.FontLow),
        filled: true,
        fillColor: colour.kDetailBg,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
          borderSide:
          const BorderSide(color: colour.kHeaderGradEnd, width: 1.5),
        ),
      ),
    );
  }
}

// ─── Save Button in AppBar ────────────────────────────────────────────────────
class _SaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _SaveButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border:
        Border.all(color: Colors.white.withOpacity(0.4), width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text('Save',
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