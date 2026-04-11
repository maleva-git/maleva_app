import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/models/model.dart';
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/MasterSearch/Truck.dart';
import '../bloc/licenseupdate_bloc.dart';
import '../bloc/licenseupdate_event.dart';
import '../bloc/licenseupdate_state.dart';

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

// All 12 expiry keys with display labels
const List<(String, String)> kExpiryFields = [
  ('rotexMyExp',    'RotexMy Exp'),
  ('rotexSGExp',    'RotexSG Exp'),
  ('puspacomExp',   'Puspacom Exp'),
  ('rotexMyExp1',   'RotexMy Exp 1'),
  ('rotexSGExp1',   'RotexSG Exp 1'),
  ('puspacomExp1',  'Puspacom Exp 1'),
  ('insuratnceExp', 'Insurance Exp'),
  ('bonamExp',      'Bonam Exp'),
  ('apadExp',       'Apad Exp'),
  ('serviceExp',    'Service Exp'),
  ('alignmentExp',  'Alignment Exp'),
  ('greeceExp',     'Greece Exp'),
];

// ─── Root ─────────────────────────────────────────────────────────────────────
class LicenseUpdate extends StatelessWidget {
  const LicenseUpdate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      LicenseUpdateBloc()..add(LicenseUpdateStarted()),
      child: const _LicenseUpdatePage(),
    );
  }
}

// ─── Page ─────────────────────────────────────────────────────────────────────
class _LicenseUpdatePage extends StatelessWidget {
  const _LicenseUpdatePage();

  @override
  Widget build(BuildContext context) {
    final userName =
        objfun.storagenew.getString('Username') ?? '';

    return BlocListener<LicenseUpdateBloc, LicenseUpdateState>(
      listener: (context, state) async {
        if (state is LicenseUpdateSaveSuccess) {
          await objfun.ConfirmationOK(
              'Updated Successfully', context);
        }
        if (state is LicenseUpdateError) {
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
          BlocBuilder<LicenseUpdateBloc, LicenseUpdateState>(
            builder: (context, state) {
              if (state is LicenseUpdateInitial ||
                  state is LicenseUpdateLoading) {
                return const Center(
                  child: SpinKitFoldingCube(
                      color: kHeaderGradEnd, size: 35),
                );
              }
              if (state is LicenseUpdateLoaded) {
                return _LicenseUpdateBody(state: state);
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
          Text('License Update',
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
        BlocBuilder<LicenseUpdateBloc, LicenseUpdateState>(
          builder: (context, state) {
            if (state is! LicenseUpdateLoaded ||
                !state.admin) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(
                  right: 12, top: 10, bottom: 10),
              child: _AppBarButton(
                label: 'UPDATE',
                onPressed: () {
                  final s = context
                      .read<LicenseUpdateBloc>()
                      .state;
                  if (s is! LicenseUpdateLoaded) return;
                  if (s.truckNo.isEmpty) {
                    objfun.toastMsg(
                        'Enter Truck No', '', context);
                    return;
                  }
                  objfun
                      .ConfirmationMsgYesNo(context,
                      'Are you sure to Update ?')
                      .then((ok) {
                    if (ok == true) {
                      context.read<LicenseUpdateBloc>().add(
                          LicenseUpdateSaveRequested());
                    }
                  });
                },
              ),
            );
          },
        ),
      ],
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────
class _LicenseUpdateBody extends StatelessWidget {
  final LicenseUpdateLoaded state;
  const _LicenseUpdateBody({required this.state});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > kTabletBreak;
        final hPad =
        isTablet ? constraints.maxWidth * 0.07 : 14.0;

        return ListView(
          padding:
          EdgeInsets.fromLTRB(hPad, 14, hPad, 24),
          children: [
            // ── Truck selector ──────────────────────────
            _TruckSelectorField(
                state: state, isTablet: isTablet),
            const SizedBox(height: 12),

            // ── Truck text fields ───────────────────────
            // Tablet: 2-column grid, Mobile: single column
            isTablet
                ? _TruckFieldsTablet(
                state: state,
                gap:
                constraints.maxWidth * 0.03)
                : _TruckFieldsMobile(state: state),
            const SizedBox(height: 16),

            // ── Section header ──────────────────────────
            _SectionHeader(
                label: 'Expiry Dates',
                isTablet: isTablet),
            const SizedBox(height: 10),

            // ── 12 expiry date rows ─────────────────────
            // Tablet: 2-column GridView, Mobile: single column
            isTablet
                ? _ExpiryGridTablet(
                state: state,
                constraints: constraints)
                : _ExpiryListMobile(state: state),
          ],
        );
      },
    );
  }
}

// ─── Truck Selector ───────────────────────────────────────────────────────────
class _TruckSelectorField extends StatelessWidget {
  final LicenseUpdateLoaded state;
  final bool isTablet;
  const _TruckSelectorField(
      {required this.state, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (state.truckName.isEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                const Truck(Searchby: 1, SearchId: 0)),
          ).then((_) {
            final sel = objfun.SelectTruckList;
            if (sel.Id != 0) {
              context.read<LicenseUpdateBloc>().add(
                  LicenseUpdateTruckSelected(
                      truckId: sel.Id,
                      truckName: sel.AccountName));
              objfun.SelectTruckList =
                  GetTruckModel.Empty();
            }
          });
        } else {
          context
              .read<LicenseUpdateBloc>()
              .add(LicenseUpdateTruckCleared());
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: kDetailBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kCardBorder, width: 0.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.local_shipping_outlined,
                size: 20, color: kHeaderGradEnd),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                state.truckName.isEmpty
                    ? 'Select Truck No'
                    : state.truckName,
                style: GoogleFonts.lato(
                  color: state.truckName.isEmpty
                      ? kTextMuted
                      : kTextDark,
                  fontWeight: state.truckName.isEmpty
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
              state.truckName.isNotEmpty
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

// ─── Truck Fields — Mobile (single column) ────────────────────────────────────
class _TruckFieldsMobile extends StatelessWidget {
  final LicenseUpdateLoaded state;
  const _TruckFieldsMobile({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TruckTextField(
            label: 'Truck No 1',
            fieldKey: 'truckNo',
            value: state.truckNo,
            isTablet: false),
        const SizedBox(height: 10),
        _TruckTextField(
            label: 'Truck No 2',
            fieldKey: 'truckNo2',
            value: state.truckNo2,
            isTablet: false),
        const SizedBox(height: 10),
        _TruckTextField(
            label: 'Truck Name',
            fieldKey: 'truckName',
            value: state.truckNameField,
            isTablet: false),
        const SizedBox(height: 10),
        _TruckTextField(
            label: 'Longitude',
            fieldKey: 'longitude',
            value: state.longitude,
            isTablet: false),
        const SizedBox(height: 10),
        _TruckTextField(
            label: 'Latitude',
            fieldKey: 'latitude',
            value: state.latitude,
            isTablet: false),
        const SizedBox(height: 10),
        _TruckTextField(
            label: 'Truck Type',
            fieldKey: 'truckType',
            value: state.truckType,
            isTablet: false),
      ],
    );
  }
}

// ─── Truck Fields — Tablet (2-column) ────────────────────────────────────────
class _TruckFieldsTablet extends StatelessWidget {
  final LicenseUpdateLoaded state;
  final double gap;
  const _TruckFieldsTablet(
      {required this.state, required this.gap});

  @override
  Widget build(BuildContext context) {
    final fields = [
      ('Truck No 1',  'truckNo',       state.truckNo),
      ('Truck No 2',  'truckNo2',      state.truckNo2),
      ('Truck Name',  'truckName',     state.truckNameField),
      ('Longitude',   'longitude',     state.longitude),
      ('Latitude',    'latitude',      state.latitude),
      ('Truck Type',  'truckType',     state.truckType),
    ];

    return Column(
      children: [
        for (int i = 0; i < fields.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                    child: _TruckTextField(
                        label: fields[i].$1,
                        fieldKey: fields[i].$2,
                        value: fields[i].$3,
                        isTablet: true)),
                SizedBox(width: gap),
                Expanded(
                    child: i + 1 < fields.length
                        ? _TruckTextField(
                        label: fields[i + 1].$1,
                        fieldKey: fields[i + 1].$2,
                        value: fields[i + 1].$3,
                        isTablet: true)
                        : const SizedBox.shrink()),
              ],
            ),
          ),
      ],
    );
  }
}

// ─── Expiry List — Mobile (single column) ────────────────────────────────────
class _ExpiryListMobile extends StatelessWidget {
  final LicenseUpdateLoaded state;
  const _ExpiryListMobile({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: kExpiryFields
          .map((f) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _ExpiryDateRow(
          label:   f.$2,
          dateKey: f.$1,
          state:   state,
          isTablet: false,
        ),
      ))
          .toList(),
    );
  }
}

// ─── Expiry Grid — Tablet (2-column) ─────────────────────────────────────────
class _ExpiryGridTablet extends StatelessWidget {
  final LicenseUpdateLoaded state;
  final BoxConstraints constraints;
  const _ExpiryGridTablet(
      {required this.state, required this.constraints});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < kExpiryFields.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _ExpiryDateRow(
                    label:    kExpiryFields[i].$2,
                    dateKey:  kExpiryFields[i].$1,
                    state:    state,
                    isTablet: true,
                  ),
                ),
                SizedBox(width: constraints.maxWidth * 0.03),
                Expanded(
                  child: i + 1 < kExpiryFields.length
                      ? _ExpiryDateRow(
                    label:    kExpiryFields[i + 1].$2,
                    dateKey:  kExpiryFields[i + 1].$1,
                    state:    state,
                    isTablet: true,
                  )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ─── Single Expiry Date Row (label + date tile + checkbox) ────────────────────
class _ExpiryDateRow extends StatelessWidget {
  final String label;
  final String dateKey;
  final LicenseUpdateLoaded state;
  final bool   isTablet;

  const _ExpiryDateRow({
    required this.label,
    required this.dateKey,
    required this.state,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = state.cbByKey(dateKey);
    final dateStr = state.dateByKey(dateKey);

    String display;
    try {
      display = DateFormat('dd-MM-yyyy')
          .format(DateTime.parse(dateStr));
    } catch (_) {
      display = dateStr;
    }

    final labelStyle = GoogleFonts.lato(
      color: kTextMid,
      fontWeight: FontWeight.w600,
      fontSize:
      isTablet ? objfun.FontMedium + 1 : objfun.FontMedium,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 4),
        Row(
          children: [
            // Date tile
            Expanded(
              child: InkWell(
                onTap: () async {
                  if (!state.admin || !enabled) return;
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    initialDate: DateTime.now(),
                    lastDate: DateTime(2100),
                    builder: (ctx, child) => Theme(
                      data: Theme.of(ctx).copyWith(
                        colorScheme:
                        const ColorScheme.light(
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
                    context.read<LicenseUpdateBloc>().add(
                        LicenseUpdateDateChanged(
                          key:  dateKey,
                          date: DateFormat('yyyy-MM-dd')
                              .format(picked),
                        ));
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: enabled
                        ? kDetailBg
                        : const Color(0xFFEEEEEE),
                    borderRadius:
                    BorderRadius.circular(10),
                    border: Border.all(
                        color: kCardBorder, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          display,
                          style: GoogleFonts.lato(
                            color: enabled
                                ? kTextDark
                                : kTextMuted,
                            fontWeight: FontWeight.w600,
                            fontSize: isTablet
                                ? objfun.FontLow + 1
                                : objfun.FontLow,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 18,
                        color: enabled
                            ? kHeaderGradEnd
                            : kTextMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Animated gradient checkbox
            InkWell(
              onTap: () {
                if (!state.admin) return;
                context.read<LicenseUpdateBloc>().add(
                    LicenseUpdateCheckboxChanged(
                        key: dateKey, value: !enabled));
              },
              borderRadius: BorderRadius.circular(6),
              child: AnimatedContainer(
                duration:
                const Duration(milliseconds: 180),
                width:  isTablet ? 24 : 20,
                height: isTablet ? 24 : 20,
                decoration: BoxDecoration(
                  gradient: enabled ? kGradient : null,
                  border: enabled
                      ? null
                      : Border.all(
                      color: kCardBorder,
                      width: 1.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: enabled
                    ? const Icon(Icons.check_rounded,
                    size: 13, color: Colors.white)
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Truck TextField (with sync controller) ───────────────────────────────────
class _TruckTextField extends StatefulWidget {
  final String label;
  final String fieldKey;
  final String value;
  final bool   isTablet;

  const _TruckTextField({
    required this.label,
    required this.fieldKey,
    required this.value,
    required this.isTablet,
  });

  @override
  State<_TruckTextField> createState() =>
      _TruckTextFieldState();
}

class _TruckTextFieldState extends State<_TruckTextField> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_TruckTextField old) {
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
    final isAdmin = context.select(
            (LicenseUpdateBloc b) =>
        b.state is LicenseUpdateLoaded &&
            (b.state as LicenseUpdateLoaded).admin);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: GoogleFonts.lato(
                color: kTextMid,
                fontWeight: FontWeight.w600,
                fontSize: widget.isTablet
                    ? objfun.FontLow + 1
                    : objfun.FontLow)),
        const SizedBox(height: 4),
        TextField(
          controller: _ctrl,
          readOnly: !isAdmin,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.done,
          onChanged: (v) =>
              context.read<LicenseUpdateBloc>().add(
                  LicenseUpdateTextChanged(
                      field: widget.fieldKey,
                      value: v)),
          style: GoogleFonts.lato(
            color: kTextDark,
            fontWeight: FontWeight.w600,
            fontSize: widget.isTablet
                ? objfun.FontLow + 1
                : objfun.FontLow,
          ),
          decoration: InputDecoration(
            hintText: widget.label,
            hintStyle: GoogleFonts.lato(
                color: kTextMuted,
                fontSize: widget.isTablet
                    ? objfun.FontLow + 1
                    : objfun.FontLow),
            filled: true,
            fillColor: isAdmin ? kDetailBg : const Color(0xFFEEEEEE),
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
        ),
      ],
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  final bool   isTablet;
  const _SectionHeader(
      {required this.label, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
              gradient: kGradient,
              borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: GoogleFonts.lato(
                color: kTextDark,
                fontWeight: FontWeight.w700,
                fontSize:
                isTablet ? 15 : 14)),
      ],
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