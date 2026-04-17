import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/models/model.dart';
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/MasterSearch/JobAllStatus.dart';
import 'package:maleva/Transaction/SaleOrderDetails.dart';

import '../bloc/stock_in_entry_bloc.dart';
import '../bloc/stock_in_entry_event.dart';
import '../bloc/stock_in_entry_state.dart';


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
const kHighlight       = Color(0xFF0D47A1);

const kGradient = LinearGradient(
  colors: [kHeaderGradStart, kHeaderGradEnd],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const double kTabletBreak = 600;

// ─── Root ─────────────────────────────────────────────────────────────────────
class Stockinentry extends StatelessWidget {
  final String? JobNo;
  final int?    JobId;
  const Stockinentry({super.key, this.JobNo, this.JobId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StockInEntryBloc()
        ..add(StockInEntryStarted(jobNo: JobNo, jobId: JobId)),
      child: const StockInEntryPage(),
    );
  }
}

// ─── Page ─────────────────────────────────────────────────────────────────────
class StockInEntryPage extends StatefulWidget {
  const StockInEntryPage();

  @override
  State<StockInEntryPage> createState() =>
      _StockInEntryPageState();
}

class _StockInEntryPageState
    extends State<StockInEntryPage> {
  final _picker = ImagePicker();

  Future<void> _pickImage(
      ImageSource source, int saleOrderId, String statusName) async {
    if (statusName.isEmpty) {
      objfun.toastMsg('Select Status!!', '', context);
      return;
    }
    final file = await _picker.pickImage(source: source);
    if (file == null) return;
    final url = await objfun.upload(
        File(file.path),
        objfun.apiPostimage,
        saleOrderId,
        'SalesOrder',
        statusName.replaceAll(' ', ''));
    context.read<StockInEntryBloc>().add(StockInEntryImagePicked(url));
  }

  @override
  Widget build(BuildContext context) {
    final userName =
        objfun.storagenew.getString('Username') ?? '';

    return BlocListener<StockInEntryBloc, StockInEntryState>(
      listener: (context, state) async {
        // ── Stock exists confirmation dialog ──────────
        if (state is StockInEntryStockExistsConfirmNeeded) {
          final ok = await objfun.ConfirmationMsgYesNo(
              context,
              'Stock Already Exists !! Do you want Remove and Save ??');
          if (ok == true) {
            context.read<StockInEntryBloc>().add(
                StockInEntryJobNoSelected(
                    saleOrderId: state.saleOrderId,
                    jobNo: state.jobNo,
                    stockExistsConfirmed: true));
          }
        }
        // ── Save success ──────────────────────────────
        if (state is StockInEntrySaveSuccess) {
          await objfun.ConfirmationOK(
              'Saved Successfully', context);
          // Print barcode
          await _doPrint(state.stockId, context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => const Stockinentry()),
          );
        }
        // ── Error ─────────────────────────────────────
        if (state is StockInEntryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message,
                  style: GoogleFonts.lato(
                      color: Colors.white)),
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
          body: BlocBuilder<StockInEntryBloc, StockInEntryState>(
            builder: (context, state) {
              if (state is StockInEntryInitial ||
                  state is StockInEntryLoading) {
                return const Center(
                  child: SpinKitFoldingCube(
                      color: kHeaderGradEnd, size: 35),
                );
              }
              if (state is StockInEntryLoaded) {
                return GestureDetector(
                  onTap: () => context
                      .read<StockInEntryBloc>()
                      .add(StockInEntryOverlayDismissed()),
                  child: _StockInEntryBody(
                    state:       state,
                    onPickImage: (src) => _pickImage(
                        src,
                        state.saleOrderId,
                        state.statusName),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Future<void> _doPrint(
      int stockId, BuildContext context) async {
    final comId = objfun.storagenew.getInt('Comid') ?? 0;
    final header = {'Content-Type': 'application/json; charset=UTF-8'};
    final result = await objfun.apiAllinoneSelectArray(
        '${objfun.apiPrintStock}$stockId&Comid=$comId',
        {},
        header,
        null);
    if (result != '') {
      final value = ResponseViewModel.fromJson(result);
      if (value.IsSuccess == true) {
        final d0 = value.data1[0];
        final total = int.tryParse(
            d0['NumberOfPackages'].toString()) ??
            0;
        final printData = List.generate(
          total,
              (i) => BarcodePrintModel(
            'MALEVA',
            d0['VesselName'],
            d0['VesselName'],
            '${d0['JobNo']}-${i + 1}/$total',
            d0['SSaleDate'],
            d0['JobNo'],
            d0['JobNo'],
            '[ ${i + 1}/$total ]',
          ),
        );
        await objfun.printdata(printData);
      }
    }
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
          Text('Stock Entry',
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
            label: 'SAVE',
            onPressed: () {
              final s = context
                  .read<StockInEntryBloc>()
                  .state;
              if (s is! StockInEntryLoaded) return;

              if (s.saleOrderId == 0 ||
                  s.jobNoText.isEmpty) {
                objfun.toastMsg(
                    'Select Job', '', context);
                return;
              }
              if (s.statusId == 0 ||
                  s.statusName.isEmpty) {
                objfun.toastMsg(
                    'Select Status', '', context);
                return;
              }
              if (s.packages.isEmpty) {
                objfun.toastMsg(
                    'Enter Packages', '', context);
                return;
              }
              if (int.tryParse(s.packages) !=
                  s.weightPkg) {
                objfun.toastMsg(
                    'Invalid Packages', '', context);
                return;
              }
              objfun
                  .ConfirmationMsgYesNo(
                  context, 'Do you want to Save ?')
                  .then((ok) {
                if (ok == true) {
                  context
                      .read<StockInEntryBloc>()
                      .add(StockInEntrySaveRequested());
                }
              });
            },
          ),
        ),
      ],
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────
class _StockInEntryBody extends StatelessWidget {
  final StockInEntryLoaded state;
  final Future<void> Function(ImageSource) onPickImage;

  const _StockInEntryBody(
      {required this.state, required this.onPickImage});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > kTabletBreak;
        final hPad =
        isTablet ? constraints.maxWidth * 0.08 : 14.0;

        return ListView(
          padding:
          EdgeInsets.fromLTRB(hPad, 14, hPad, 24),
          children: [
            // ── BillType radio ────────────────────────
            _BillTypeRow(
                billType: state.billType,
                isTablet: isTablet),
            const SizedBox(height: 10),

            // ── Job No + View ─────────────────────────
            _JobNoRow(state: state, isTablet: isTablet),
            const SizedBox(height: 12),

            // ── Tablet: 2-col info + form fields ──────
            isTablet
                ? _TabletFormLayout(
                state: state,
                gap: constraints.maxWidth * 0.04)
                : _MobileFormLayout(state: state),
            const SizedBox(height: 12),

            // ── Status field ──────────────────────────
            _FieldLabel('Job Status', isTablet),
            const SizedBox(height: 6),
            _StatusField(
                state: state, isTablet: isTablet),
            const SizedBox(height: 12),

            // ── Image upload row ──────────────────────
            _ImageUploadRow(
              state:       state,
              isTablet:    isTablet,
              onPickImage: onPickImage,
            ),
            const SizedBox(height: 10),

            // ── Image grid ────────────────────────────
            _ImageGrid(
                state: state, isTablet: isTablet),
          ],
        );
      },
    );
  }
}

// ─── Bill Type Radio ─────────────────────────────────────────────────────────
class _BillTypeRow extends StatelessWidget {
  final String billType;
  final bool   isTablet;
  const _BillTypeRow(
      {required this.billType, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: kDetailBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kCardBorder, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _RadioOption(
            label: 'MY',
            value: '0',
            groupValue: billType,
            isTablet: isTablet,
            onChanged: (v) => context
                .read<StockInEntryBloc>()
                .add(StockInEntryBillTypeChanged(v)),
          ),
          SizedBox(width: isTablet ? 40 : 24),
          _RadioOption(
            label: 'TR',
            value: '1',
            groupValue: billType,
            isTablet: isTablet,
            onChanged: (v) => context
                .read<StockInEntryBloc>()
                .add(StockInEntryBillTypeChanged(v)),
          ),
        ],
      ),
    );
  }
}

class _RadioOption extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final bool   isTablet;
  final void Function(String) onChanged;
  const _RadioOption({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.isTablet,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final sel = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 6),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width:  isTablet ? 22 : 18,
              height: isTablet ? 22 : 18,
              decoration: BoxDecoration(
                shape:    BoxShape.circle,
                gradient: sel ? kGradient : null,
                border:   Border.all(
                  color: sel ? kHeaderGradEnd : kCardBorder,
                  width: sel ? 0 : 1.5,
                ),
              ),
              child: sel
                  ? const Icon(Icons.circle,
                  size: 10, color: Colors.white)
                  : null,
            ),
            SizedBox(width: isTablet ? 8 : 6),
            Text(label,
                style: GoogleFonts.lato(
                  color: sel ? kHeaderGradStart : kTextMid,
                  fontWeight: FontWeight.w700,
                  fontSize: isTablet
                      ? objfun.FontMedium + 1
                      : objfun.FontMedium,
                )),
          ],
        ),
      ),
    );
  }
}

// ─── Job No + View Row ────────────────────────────────────────────────────────
class _JobNoRow extends StatefulWidget {
  final StockInEntryLoaded state;
  final bool isTablet;
  const _JobNoRow(
      {required this.state, required this.isTablet});

  @override
  State<_JobNoRow> createState() => _JobNoRowState();
}

class _JobNoRowState extends State<_JobNoRow> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: widget.state.jobNoText);
  }

  @override
  void didUpdateWidget(_JobNoRow old) {
    super.didUpdateWidget(old);
    if (widget.state.jobNoText != _ctrl.text) {
      _ctrl.text = widget.state.jobNoText;
      _ctrl.selection = TextSelection.collapsed(
          offset: widget.state.jobNoText.length);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s        = widget.state;
    final isTablet = widget.isTablet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel('Job No', isTablet),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: _ctrl,
                keyboardType: TextInputType.number,
                textCapitalization:
                TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                onChanged: (v) => context
                    .read<StockInEntryBloc>()
                    .add(StockInEntryJobNoTextChanged(v)),
                style: GoogleFonts.lato(
                    color: kTextDark,
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet
                        ? objfun.FontLow + 1
                        : objfun.FontLow),
                decoration: InputDecoration(
                  hintText: 'Job No',
                  hintStyle: GoogleFonts.lato(
                      color: kTextMuted,
                      fontSize: isTablet
                          ? objfun.FontLow + 1
                          : objfun.FontLow),
                  filled: true,
                  fillColor: kDetailBg,
                  prefixIcon: const Icon(
                      Icons.tag_rounded,
                      color: kHeaderGradEnd,
                      size: 20),
                  contentPadding:
                  const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 13),
                  border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: kCardBorder, width: 0.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: kHeaderGradEnd,
                        width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: _GradientButton(
                label: 'VIEW',
                icon: Icons.arrow_circle_right_outlined,
                isTablet: isTablet,
                onPressed: () async {
                  if (s.jobNoText.isEmpty) {
                    objfun.toastMsg(
                        'Enter Job No', '', context);
                    return;
                  }
                  await OnlineApi.EditSalesOrder(
                      context,
                      s.saleOrderId,
                      int.tryParse(s.jobNoText) ?? 0);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SaleOrderDetails(
                        SaleDetails: null,
                        SaleMaster:
                        objfun.SaleEditMasterList,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        // Autocomplete
        if (s.jobNoSuggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints:
            const BoxConstraints(maxHeight: 180),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: kCardBorder, width: 0.5),
              boxShadow: [
                BoxShadow(
                    color:
                    kHeaderGradStart.withOpacity(0.10),
                    blurRadius: 10,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: s.jobNoSuggestions.length,
              separatorBuilder: (_, __) => const Divider(
                  height: 1, color: kDetailBg),
              itemBuilder: (ctx, i) {
                final item = s.jobNoSuggestions[i];
                final cnum =
                item['CNumber'].toString();
                return InkWell(
                  onTap: () => context
                      .read<StockInEntryBloc>()
                      .add(StockInEntryJobNoSelected(
                      saleOrderId: item['Id'],
                      jobNo: cnum)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(
                            Icons.work_outline_rounded,
                            size: 16,
                            color: kHeaderGradEnd),
                        const SizedBox(width: 10),
                        Text(cnum,
                            style: GoogleFonts.lato(
                                color: kTextDark,
                                fontWeight:
                                FontWeight.w600,
                                fontSize: isTablet
                                    ? objfun.FontLow + 1
                                    : objfun.FontLow)),
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

// ─── Mobile Form Layout ───────────────────────────────────────────────────────
class _MobileFormLayout extends StatelessWidget {
  final StockInEntryLoaded state;
  const _MobileFormLayout({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InfoRow('Stock No', state.stockNo, false, readonly: true),
        const SizedBox(height: 10),
        _DateRow(state: state, isTablet: false),
        const SizedBox(height: 10),
        _InfoRow('Ship Name',    state.shipName,    false),
        const SizedBox(height: 10),
        _InfoRow('Customer',     state.customerName,false),
        const SizedBox(height: 10),
        _InfoRow('Job Date',     state.jobDate,     false),
        const SizedBox(height: 10),
        _PackagesField(state: state, isTablet: false),
      ],
    );
  }
}

// ─── Tablet Form Layout (2-column) ───────────────────────────────────────────
class _TabletFormLayout extends StatelessWidget {
  final StockInEntryLoaded state;
  final double gap;
  const _TabletFormLayout(
      {required this.state, required this.gap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          Expanded(
              child: _InfoRow('Stock No', state.stockNo,
                  true,
                  readonly: true)),
          SizedBox(width: gap),
          Expanded(
              child: _DateRow(
                  state: state, isTablet: true)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: _InfoRow(
                  'Ship Name', state.shipName, true)),
          SizedBox(width: gap),
          Expanded(
              child: _InfoRow(
                  'Customer', state.customerName, true)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: _InfoRow(
                  'Job Date', state.jobDate, true)),
          SizedBox(width: gap),
          Expanded(
              child: _PackagesField(
                  state: state, isTablet: true)),
        ]),
      ],
    );
  }
}

// ─── Info Row (label + readonly value) ───────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool   isTablet;
  final bool   readonly;

  const _InfoRow(this.label, this.value, this.isTablet,
      {this.readonly = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label, isTablet),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: readonly ? kChipBg : kDetailBg,
            borderRadius: BorderRadius.circular(10),
            border:
            Border.all(color: kCardBorder, width: 0.5),
          ),
          child: Text(
            value.isEmpty ? '-' : value,
            style: GoogleFonts.lato(
              color:
              readonly ? kHeaderGradStart : kHighlight,
              fontWeight: FontWeight.w700,
              fontSize:
              isTablet ? objfun.FontLow : objfun.FontLow - 1,
              letterSpacing: readonly ? 0.5 : 0,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─── Stock Date Row ───────────────────────────────────────────────────────────
class _DateRow extends StatelessWidget {
  final StockInEntryLoaded state;
  final bool isTablet;
  const _DateRow(
      {required this.state, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    String display;
    try {
      display = DateFormat(
          isTablet ? 'dd-MM-yyyy' : 'dd-MM-yy')
          .format(DateTime.parse(state.stockDate));
    } catch (_) {
      display = state.stockDate;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel('Stock Date', isTablet),
        const SizedBox(height: 5),
        InkWell(
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
              context.read<StockInEntryBloc>().add(
                  StockInEntryDateChanged(
                      DateFormat('yyyy-MM-dd')
                          .format(picked)));
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: kDetailBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: kCardBorder, width: 0.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(display,
                      style: GoogleFonts.lato(
                          color: kTextDark,
                          fontWeight: FontWeight.w600,
                          fontSize: isTablet
                              ? objfun.FontLow + 1
                              : objfun.FontLow)),
                ),
                const Icon(
                    Icons.calendar_month_outlined,
                    size: 18,
                    color: kHeaderGradEnd),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Packages Field ───────────────────────────────────────────────────────────
class _PackagesField extends StatefulWidget {
  final StockInEntryLoaded state;
  final bool isTablet;
  const _PackagesField(
      {required this.state, required this.isTablet});

  @override
  State<_PackagesField> createState() =>
      _PackagesFieldState();
}

class _PackagesFieldState extends State<_PackagesField> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl =
        TextEditingController(text: widget.state.packages);
  }

  @override
  void didUpdateWidget(_PackagesField old) {
    super.didUpdateWidget(old);
    if (widget.state.packages != _ctrl.text) {
      _ctrl.text = widget.state.packages;
      _ctrl.selection = TextSelection.collapsed(
          offset: widget.state.packages.length);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel('Packages', widget.isTablet),
        const SizedBox(height: 5),
        TextField(
          controller: _ctrl,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          onChanged: (v) => context
              .read<StockInEntryBloc>()
              .add(StockInEntryPackagesChanged(v)),
          style: GoogleFonts.lato(
              color: kTextDark,
              fontWeight: FontWeight.w600,
              fontSize: widget.isTablet
                  ? objfun.FontLow + 1
                  : objfun.FontLow),
          decoration: InputDecoration(
            hintText: 'Packages',
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
                    color: kCardBorder, width: 0.5)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                    color: kHeaderGradEnd, width: 1.5)),
          ),
        ),
      ],
    );
  }
}

// ─── Status Field ─────────────────────────────────────────────────────────────
class _StatusField extends StatelessWidget {
  final StockInEntryLoaded state;
  final bool isTablet;
  const _StatusField(
      {required this.state, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (state.statusName.isNotEmpty) {
          context
              .read<StockInEntryBloc>()
              .add(StockInEntryStatusCleared());
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => JobAllStatus(
                Searchby: 1,
                SearchId: 0,
                JobTypeId: state.jobMasterId,
              )),
        ).then((_) {
          final sel = objfun.SelectAllStatusList;
          if (sel.Status != 0) {
            context.read<StockInEntryBloc>().add(
                StockInEntryStatusSelected(
                    statusId: sel.Status,
                    statusName: sel.StatusName));
            objfun.SelectAllStatusList =
                JobAllStatusModel.Empty();
          }
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 14),
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
                state.statusName.isEmpty
                    ? 'Job Status'
                    : state.statusName,
                style: GoogleFonts.lato(
                  color: state.statusName.isEmpty
                      ? kTextMuted
                      : kTextDark,
                  fontWeight: state.statusName.isEmpty
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
              state.statusName.isNotEmpty
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

// ─── Image Upload Row ─────────────────────────────────────────────────────────
class _ImageUploadRow extends StatelessWidget {
  final StockInEntryLoaded state;
  final bool isTablet;
  final Future<void> Function(ImageSource) onPickImage;

  const _ImageUploadRow({
    required this.state,
    required this.isTablet,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kDetailBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kCardBorder, width: 0.5),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => context
                .read<StockInEntryBloc>()
                .add(StockInEntryImageUploadToggled(
                !state.imageUploadEnabled)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width:  isTablet ? 22 : 18,
              height: isTablet ? 22 : 18,
              decoration: BoxDecoration(
                gradient: state.imageUploadEnabled
                    ? kGradient
                    : null,
                border: state.imageUploadEnabled
                    ? null
                    : Border.all(
                    color: kCardBorder, width: 1.5),
                borderRadius: BorderRadius.circular(5),
              ),
              child: state.imageUploadEnabled
                  ? const Icon(Icons.check_rounded,
                  size: 12, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Text('Upload Image',
              style: GoogleFonts.lato(
                  color: kTextDark,
                  fontWeight: FontWeight.w600,
                  fontSize: isTablet
                      ? objfun.FontMedium + 1
                      : objfun.FontMedium)),
          const Spacer(),
          _PickBtn(
            icon:     Icons.photo_outlined,
            enabled:  state.imageUploadEnabled,
            isTablet: isTablet,
            onTap: () => onPickImage(ImageSource.gallery),
          ),
          const SizedBox(width: 4),
          _PickBtn(
            icon:     Icons.camera_alt_outlined,
            enabled:  state.imageUploadEnabled,
            isTablet: isTablet,
            onTap: () => onPickImage(ImageSource.camera),
          ),
        ],
      ),
    );
  }
}

class _PickBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final bool isTablet;
  final VoidCallback onTap;
  const _PickBtn({
    required this.icon,
    required this.enabled,
    required this.isTablet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: enabled
              ? kHeaderGradStart.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon,
            size:  isTablet ? 28 : 24,
            color: enabled ? kHeaderGradStart : kTextMuted),
      ),
    );
  }
}

// ─── Image Grid ───────────────────────────────────────────────────────────────
class _ImageGrid extends StatelessWidget {
  final StockInEntryLoaded state;
  final bool isTablet;
  const _ImageGrid(
      {required this.state, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final gridCols   = isTablet ? 4 : 3;
    final gridHeight = isTablet ? 320.0 : 260.0;
    final folder =
    state.statusName.replaceAll(' ', '');

    return Container(
      height: gridHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kCardBorder, width: 0.5),
      ),
      child: state.images.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined,
                size: isTablet ? 48 : 36,
                color: kTextMuted),
            const SizedBox(height: 8),
            Text('No images uploaded',
                style: GoogleFonts.lato(
                    color: kTextMuted,
                    fontSize: 13)),
          ],
        ),
      )
          : ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridCols,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemCount: state.images.length,
          itemBuilder: (ctx, i) {
            final url =
                '${objfun.imagepath}SalesOrder/${state.saleOrderId}/$folder/${state.images[i]}';
            return InkWell(
              onLongPress: () async {
                final ok =
                await objfun.ConfirmationMsgYesNo(
                    ctx,
                    'Are you sure to Delete ?');
                if (ok == true) {
                  context
                      .read<StockInEntryBloc>()
                      .add(StockInEntryImageDeleted(i));
                }
              },
              onTap: () => _showPreview(ctx, url),
              borderRadius:
              BorderRadius.circular(8),
              child: ClipRRect(
                borderRadius:
                BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(
                        color: kDetailBg,
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child:
                            CircularProgressIndicator(
                                color: kHeaderGradEnd,
                                strokeWidth: 2),
                          ),
                        ),
                      ),
                  errorWidget: (_, __, ___) =>
                      Container(
                        color: kDetailBg,
                        child: const Icon(
                            Icons
                                .image_not_supported_outlined,
                            color: kHeaderGradEnd),
                      ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showPreview(BuildContext context, String url) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: url,
                placeholder: (_, __) =>
                const CircularProgressIndicator(
                    color: kHeaderGradEnd),
              ),
            ),
            const SizedBox(height: 12),
            CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded,
                    color: kHeaderGradStart),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared Reusable Widgets ──────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  final bool   isTablet;
  const _FieldLabel(this.text, this.isTablet);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: GoogleFonts.lato(
            color: kTextMid,
            fontWeight: FontWeight.w600,
            fontSize: isTablet
                ? objfun.FontLow + 1
                : objfun.FontLow));
  }
}

class _GradientButton extends StatelessWidget {
  final String   label;
  final IconData icon;
  final bool     isTablet;
  final VoidCallback onPressed;
  const _GradientButton({
    required this.label,
    required this.icon,
    required this.isTablet,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: kGradient,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: kHeaderGradStart.withOpacity(0.30),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 18 : 12,
                vertical: isTablet ? 13 : 11),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                Text(label,
                    style: GoogleFonts.lato(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: isTablet
                            ? objfun.FontMedium + 1
                            : objfun.FontMedium)),
                const SizedBox(width: 6),
                Icon(icon,
                    color: Colors.white,
                    size: isTablet ? 20 : 17),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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