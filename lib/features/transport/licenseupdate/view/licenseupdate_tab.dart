import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/menu/menulist.dart';
import '../../../../core/theme/palette.dart';
import '../../../mastersearch/Truck.dart';
import '../bloc/licenseupdate_bloc.dart';
import '../bloc/licenseupdate_event.dart';
import '../bloc/licenseupdate_state.dart';
import 'package:maleva/core/models/shared/get_truck_model.dart';




const kGradient = LinearGradient(
  colors: [Palette.blue700, Palette.blue400],
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
        AppGlobals.storagenew.getString('Username') ?? '';

    return BlocListener<LicenseUpdateBloc, LicenseUpdateState>(
      listener: (context, state) async {
        if (state is LicenseUpdateSaveSuccess) {
          await ConfirmationOK(
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
          backgroundColor: Palette.grey100,
          appBar: _buildAppBar(context, userName),
          drawer: const Menulist(),
          body:
          BlocBuilder<LicenseUpdateBloc, LicenseUpdateState>(
            builder: (context, state) {
              if (state is LicenseUpdateInitial ||
                  state is LicenseUpdateLoading) {
                return const Center(
                  child: SpinKitFoldingCube(
                      color: Palette.blue400, size: 35),
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
                    toastMsg(
                        'Enter Truck No', '', context);
                    return;
                  }
                  ConfirmationMsgYesNo(context,
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
            final sel = AppGlobals.SelectTruckList;
            if (sel.Id != 0) {
              context.read<LicenseUpdateBloc>().add(
                  LicenseUpdateTruckSelected(
                      truckId: sel.Id,
                      truckName: sel.AccountName));
              AppGlobals.SelectTruckList =
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
          color: Palette.grey200p,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Palette.cardBorder, width: 0.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.local_shipping_outlined,
                size: 20, color: Palette.blue400),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                state.truckName.isEmpty
                    ? 'Select Truck No'
                    : state.truckName,
                style: GoogleFonts.lato(
                  color: state.truckName.isEmpty
                      ? Palette.kTextMuted
                      : Palette.textDark2,
                  fontWeight: state.truckName.isEmpty
                      ? FontWeight.w500
                      : FontWeight.w600,
                  fontSize: isTablet
                      ? AppGlobals.FontLow + 1
                      : AppGlobals.FontLow,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              state.truckName.isNotEmpty
                  ? Icons.close_rounded
                  : Icons.search_rounded,
              size: 20,
              color: Palette.blue400,
            ),
          ],
        ),
      ),
    );
  }
}

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
            label: 'Truck Type',
            fieldKey: 'truckType',
            value: state.truckType,
            isTablet: false),
      ],
    );
  }
}


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
      color: Palette.textMid,
      fontWeight: FontWeight.w600,
      fontSize:
      isTablet ? AppGlobals.FontMedium + 1 : AppGlobals.FontMedium,
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
                          primary: Palette.blue700,
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: Palette.textDark2,
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
                        ? Palette.grey200p
                        : const Color(0xFFEEEEEE),
                    borderRadius:
                    BorderRadius.circular(10),
                    border: Border.all(
                        color: Palette.cardBorder, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          display,
                          style: GoogleFonts.lato(
                            color: enabled
                                ? Palette.textDark2
                                : Palette.kTextMuted,
                            fontWeight: FontWeight.w600,
                            fontSize: isTablet
                                ? AppGlobals.FontLow + 1
                                : AppGlobals.FontLow,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 18,
                        color: enabled
                            ? Palette.blue400
                            : Palette.kTextMuted,
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
                      color: Palette.cardBorder,
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
                color: Palette.textMid,
                fontWeight: FontWeight.w600,
                fontSize: widget.isTablet
                    ? AppGlobals.FontLow + 1
                    : AppGlobals.FontLow)),
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
            color: Palette.textDark2,
            fontWeight: FontWeight.w600,
            fontSize: widget.isTablet
                ? AppGlobals.FontLow + 1
                : AppGlobals.FontLow,
          ),
          decoration: InputDecoration(
            hintText: widget.label,
            hintStyle: GoogleFonts.lato(
                color: Palette.kTextMuted,
                fontSize: widget.isTablet
                    ? AppGlobals.FontLow + 1
                    : AppGlobals.FontLow),
            filled: true,
            fillColor: isAdmin ? Palette.grey200p : const Color(0xFFEEEEEE),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: Palette.cardBorder, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: Palette.blue400, width: 1.5),
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
                color: Palette.textDark2,
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
                    fontSize: AppGlobals.FontMedium)),
          ),
        ),
      ),
    );
  }
}