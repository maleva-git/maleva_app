import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/menu/menulist.dart';
import '../../view/bloc/fuelentryview_bloc.dart';
import '../../view/bloc/fuelentryview_event.dart';
import '../../view/view/fuelentryview_tab.dart';
import '../bloc/fuelentry_bloc.dart';
import '../bloc/fuelentry_event.dart';
import '../bloc/fuelentry_state.dart';



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
class FuelEntry extends StatelessWidget {
  const FuelEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FuelEntryBloc()..add(FuelEntryStarted()),
      child: const _FuelEntryPage(),
    );
  }
}

// ─── Page ─────────────────────────────────────────────────────────────────────
class _FuelEntryPage extends StatelessWidget {
  const _FuelEntryPage();

  @override
  Widget build(BuildContext context) {
    final userName =
        objfun.storagenew.getString('Username') ?? '';

    return BlocListener<FuelEntryBloc, FuelEntryState>(
      listener: (context, state) async {
        if (state is FuelEntrySaveSuccess) {
          await objfun.ConfirmationOK(
              'Saved Successfully', context);
        }
        if (state is FuelEntryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message,
                  style:
                  GoogleFonts.lato(color: Colors.white)),
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
          backgroundColor: kPageBg,
          appBar: _buildAppBar(context, userName),
          drawer: const Menulist(),
          body:
          BlocBuilder<FuelEntryBloc, FuelEntryState>(
            builder: (context, state) {
              if (state is FuelEntryInitial ||
                  state is FuelEntryLoading) {
                return const Center(
                  child: SpinKitFoldingCube(
                      color: kHeaderGradEnd, size: 35),
                );
              }
              if (state is FuelEntryLoaded) {
                return _FuelEntryBody(state: state);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, String userName) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      toolbarHeight: 62,
      flexibleSpace: Container(
          decoration:
          const BoxDecoration(gradient: kGradient)),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 20),
        color: Colors.white,
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fuel Entry',
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
      actions: [
        Padding(
          padding: const EdgeInsets.only(
              right: 12, top: 10, bottom: 10),
          child: _AppBarButton(
            label: 'View',
            onPressed: () => Navigator.push(
              context,
         /*     MaterialPageRoute(
                  builder: (_) => const FuelEntryView()),*/

              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => FuelEntryViewBloc()..add(FuelEntryViewStarted()),
                  child: const FuelEntryView(),
                ),
              ),
            ),
          ),
        ),
      ],
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────
class _FuelEntryBody extends StatelessWidget {
  final FuelEntryLoaded state;
  const _FuelEntryBody({required this.state});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > kTabletBreak;
        // Tablet: centre the form card with proportional padding
        final hPad =
        isTablet ? constraints.maxWidth * 0.15 : 0.0;

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: isTablet
                ? _FuelEntryCard(
                state: state, isTablet: true)
                : _FuelEntryCard(
                state: state, isTablet: false),
          ),
        );
      },
    );
  }
}

// ─── Form Card ────────────────────────────────────────────────────────────────
class _FuelEntryCard extends StatelessWidget {
  final FuelEntryLoaded state;
  final bool isTablet;
  const _FuelEntryCard(
      {required this.state, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
          isTablet ? 0 : 14,
          isTablet ? 32 : 20,
          isTablet ? 0 : 14,
          24),
      decoration: isTablet
          ? BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: kCardBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color:
            kHeaderGradStart.withOpacity(0.10),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      )
          : null,
      padding: isTablet
          ? const EdgeInsets.all(32)
          : EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Truck name banner ───────────────────────
          _TruckBanner(isTablet: isTablet),
          SizedBox(height: isTablet ? 24 : 20),

          // ── Fuel No (read-only) ─────────────────────
          _FormRow(
            label: 'Fuel No',
            isTablet: isTablet,
            child: _ReadonlyField(
                value: state.fuelNo,
                isTablet: isTablet),
          ),
          SizedBox(height: isTablet ? 16 : 12),

          // ── Entry Date ──────────────────────────────
          _FormRow(
            label: 'Entry Date',
            isTablet: isTablet,
            child: _DateField(
                state: state, isTablet: isTablet),
          ),
          SizedBox(height: isTablet ? 16 : 12),

          // ── Liter ───────────────────────────────────
          _FormRow(
            label: 'Liter',
            isTablet: isTablet,
            child: _NumberField(
              hint: 'Liter',
              value: state.liter,
              isTablet: isTablet,
              onChanged: (v) => context
                  .read<FuelEntryBloc>()
                  .add(FuelEntryLiterChanged(v)),
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),

          // ── Amount ──────────────────────────────────
          _FormRow(
            label: 'Amount',
            isTablet: isTablet,
            child: _NumberField(
              hint: 'Amount',
              value: state.amount,
              isTablet: isTablet,
              onChanged: (v) => context
                  .read<FuelEntryBloc>()
                  .add(FuelEntryAmountChanged(v)),
            ),
          ),
          SizedBox(height: isTablet ? 28 : 20),

          // ── Save button ─────────────────────────────
          Align(
            alignment: isTablet
                ? Alignment.center
                : Alignment.centerLeft,
            child: _SaveButton(
              isTablet: isTablet,
              onPressed: () {
                final s = context
                    .read<FuelEntryBloc>()
                    .state;
                if (s is! FuelEntryLoaded) return;
                if (s.liter.isEmpty) {
                  objfun.toastMsg(
                      'Enter Liter', '', context);
                  return;
                }
                if (s.amount.isEmpty) {
                  objfun.toastMsg(
                      'Enter Amount', '', context);
                  return;
                }
                objfun
                    .ConfirmationMsgYesNo(context,
                    'Do You Want to Save Fuel Entry ?')
                    .then((ok) {
                  if (ok == true) {
                    context
                        .read<FuelEntryBloc>()
                        .add(FuelEntrySaveRequested());
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Truck Banner ─────────────────────────────────────────────────────────────
class _TruckBanner extends StatelessWidget {
  final bool isTablet;
  const _TruckBanner({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: kGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_shipping_outlined,
              size: 22, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Truck: ${objfun.DriverTruckName}',
              style: GoogleFonts.lato(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize:
                isTablet ? objfun.FontLarge : objfun.FontMedium,
                letterSpacing: 0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Form Row (label + input) ─────────────────────────────────────────────────
class _FormRow extends StatelessWidget {
  final String label;
  final Widget child;
  final bool   isTablet;

  const _FormRow({
    required this.label,
    required this.child,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    // Tablet: label on left, input takes remaining space
    if (isTablet) {
      return Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.lato(
                color: kTextMid,
                fontWeight: FontWeight.w600,
                fontSize: objfun.FontLow + 1,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: child),
        ],
      );
    }
    // Mobile: label above input
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.lato(
                color: kTextMid,
                fontWeight: FontWeight.w600,
                fontSize: objfun.FontLow)),
        const SizedBox(height: 5),
        child,
      ],
    );
  }
}

// ─── Read-only fuel No field ──────────────────────────────────────────────────
class _ReadonlyField extends StatelessWidget {
  final String value;
  final bool   isTablet;
  const _ReadonlyField(
      {required this.value, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: kChipBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kCardBorder, width: 0.5),
      ),
      child: Text(
        value.isEmpty ? '—' : value,
        textAlign: TextAlign.center,
        style: GoogleFonts.lato(
          color: kHeaderGradStart,
          fontWeight: FontWeight.w700,
          fontSize: isTablet
              ? objfun.FontLow + 1
              : objfun.FontLow,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── Date Field ───────────────────────────────────────────────────────────────
class _DateField extends StatelessWidget {
  final FuelEntryLoaded state;
  final bool   isTablet;
  const _DateField(
      {required this.state, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    String display;
    try {
      display = DateFormat('dd-MM-yy')
          .format(DateTime.parse(state.date));
    } catch (_) {
      display = state.date;
    }

    return InkWell(
      onTap: () async {
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
        if (picked != null) {
          context.read<FuelEntryBloc>().add(
              FuelEntryDateChanged(
                  DateFormat('yyyy-MM-dd').format(picked)));
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: kDetailBg,
          borderRadius: BorderRadius.circular(10),
          border:
          Border.all(color: kCardBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                display,
                style: GoogleFonts.lato(
                  color: kTextDark,
                  fontWeight: FontWeight.w600,
                  fontSize: isTablet
                      ? objfun.FontLow + 1
                      : objfun.FontLow,
                ),
              ),
            ),
            const Icon(Icons.calendar_month_outlined,
                size: 20, color: kHeaderGradEnd),
          ],
        ),
      ),
    );
  }
}

// ─── Number Text Field ────────────────────────────────────────────────────────
class _NumberField extends StatefulWidget {
  final String hint;
  final String value;
  final bool   isTablet;
  final void Function(String) onChanged;

  const _NumberField({
    required this.hint,
    required this.value,
    required this.isTablet,
    required this.onChanged,
  });

  @override
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_NumberField old) {
    super.didUpdateWidget(old);
    if (widget.value != _ctrl.text) {
      _ctrl.text = widget.value;
      _ctrl.selection = TextSelection.collapsed(
          offset: widget.value.length);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      onChanged: widget.onChanged,
      style: GoogleFonts.lato(
        color: kTextDark,
        fontWeight: FontWeight.w600,
        fontSize: widget.isTablet
            ? objfun.FontLow + 1
            : objfun.FontLow,
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: GoogleFonts.lato(
            color: kTextMuted,
            fontSize: widget.isTablet
                ? objfun.FontLow + 1
                : objfun.FontLow),
        filled: true,
        fillColor: kDetailBg,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
              color: kCardBorder, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
              color: kHeaderGradEnd, width: 1.5),
        ),
      ),
    );
  }
}

// ─── Save Button ──────────────────────────────────────────────────────────────
class _SaveButton extends StatelessWidget {
  final bool         isTablet;
  final VoidCallback onPressed;
  const _SaveButton(
      {required this.isTablet, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  isTablet ? 200 : null,
      height: isTablet ? 52  : 48,
      decoration: BoxDecoration(
        gradient: kGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: kHeaderGradStart.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              'Save',
              style: GoogleFonts.lato(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: isTablet
                    ? objfun.FontMedium + 1
                    : objfun.FontMedium,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── AppBar Button ────────────────────────────────────────────────────────────
class _AppBarButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _AppBarButton(
      {required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: Colors.white.withOpacity(0.4),
            width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
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