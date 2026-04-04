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


import '../../../../core/theme/tokens.dart';
import '../bloc/updateboardingdetails_bloc.dart';
import '../bloc/updateboardingdetails_event.dart';
import '../bloc/updateboardingdetails_state.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────

// const kCardBorder      = Color(0xFFC5D0EE);
// const kPageBg          = Color(0xFFF4F6FB);

// const kTextMid         = Color(0xFF4A5A8A);
// const kTextMuted       = Color(0xFF8A96BF);
// const kDetailBg        = Color(0xFFF0F4FF);
// const kChipBg          = Color(0xFFEEF2FF);

const kGradient = LinearGradient(
  colors: [AppTokens.invoiceHeaderStart, AppTokens.invoiceHeaderEnd],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const double kTabletBreak = 600;

// ─── Root ─────────────────────────────────────────────────────────────────────
class BoardingStatusUpdate extends StatelessWidget {
  final String? JobNo;
  final int?    JobId;

  const BoardingStatusUpdate({super.key, this.JobNo, this.JobId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BoardingStatusBloc()
        ..add(BoardingStatusStarted(jobNo: JobNo, jobId: JobId)),
      child: const _BoardingStatusPage(),
    );
  }
}

// ─── Page ─────────────────────────────────────────────────────────────────────
class _BoardingStatusPage extends StatefulWidget {
  const _BoardingStatusPage();

  @override
  State<_BoardingStatusPage> createState() => _BoardingStatusPageState();
}

class _BoardingStatusPageState extends State<_BoardingStatusPage> {
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source, int saleOrderId) async {
    if (saleOrderId == 0) {
      objfun.toastMsg('Enter Job No', '', context);
      return;
    }
    final file = await _picker.pickImage(source: source);
    if (file == null) return;
    final url = await objfun.upload(
        File(file.path), objfun.apiPostimage, saleOrderId, 'SalesOrder', 'Boarding');
    context.read<BoardingStatusBloc>().add(BoardingStatusImagePicked(url));
  }

  @override
  Widget build(BuildContext context) {
    final userName = objfun.storagenew.getString('Username') ?? '';

    return BlocListener<BoardingStatusBloc, BoardingStatusState>(
      listener: (context, state) async {
        if (state is BoardingStatusSaveSuccess) {
          await objfun.ConfirmationOK('Updated Successfully', context);
        }
        if (state is BoardingStatusNavigateToDetails) {
          final s = context.read<BoardingStatusBloc>().state;
          if (s is BoardingStatusLoaded && s.jobNoText.isNotEmpty) {
            await OnlineApi.EditSalesOrder(
                context, s.saleOrderId, int.tryParse(s.jobNoText) ?? 0);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SaleOrderDetails(
                  SaleDetails: null,
                  SaleMaster: objfun.SaleEditMasterList,
                ),
              ),
            );
          }
        }
        if (state is BoardingStatusError) {
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
          backgroundColor: AppTokens.invoicePageBg,
          appBar: _buildAppBar(context, userName),
          drawer: const Menulist(),
          body: BlocBuilder<BoardingStatusBloc, BoardingStatusState>(
            builder: (context, state) {
              if (state is BoardingStatusInitial ||
                  state is BoardingStatusLoading) {
                return const Center(
                  child: SpinKitFoldingCube(color: AppTokens.invoiceHeaderEnd, size: 35),
                );
              }
              if (state is BoardingStatusLoaded) {
                return GestureDetector(
                  onTap: () => context
                      .read<BoardingStatusBloc>()
                      .add(BoardingStatusOverlayDismissed()),
                  child: _BoardingStatusBody(
                    state: state,
                    onPickImage: (source) =>
                        _pickImage(source, state.saleOrderId),
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
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status Update',
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
          padding: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
          child: _AppBarButton(
            label: 'UPDATE',
            onPressed: () {
              final s = context.read<BoardingStatusBloc>().state;
              if (s is! BoardingStatusLoaded) return;

              if (s.statusName.isEmpty &&
                  !s.startTimeEnabled &&
                  !s.endTimeEnabled &&
                  !s.imageUploadEnabled) {
                objfun.toastMsg('Enter Details to update', '', context);
                return;
              }
              if (s.jobNoText.isEmpty) {
                objfun.toastMsg('Enter Job No', '', context);
                return;
              }
              if (s.imageUploadEnabled && s.images.isEmpty) {
                objfun.toastMsg('Select Images !!', '', context);
                return;
              }
              objfun
                  .ConfirmationMsgYesNo(
                  context, 'Are you sure to Update ?')
                  .then((ok) {
                if (ok == true) {
                  context
                      .read<BoardingStatusBloc>()
                      .add(BoardingStatusSaveRequested());
                }
              });
            },
          ),
        ),
        const SizedBox(width: 4),
      ],
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────
class _BoardingStatusBody extends StatelessWidget {
  final BoardingStatusLoaded state;
  final Future<void> Function(ImageSource) onPickImage;

  const _BoardingStatusBody(
      {required this.state, required this.onPickImage});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > kTabletBreak;
        // Tablet: centre content with horizontal padding
        final hPad = isTablet ? constraints.maxWidth * 0.08 : 14.0;

        return ListView(
          padding:
          EdgeInsets.fromLTRB(hPad, 14, hPad, 24),
          children: [
            // ── BillType radio ────────────────────────────────────────
            _BillTypeRow(billType: state.billType, isTablet: isTablet),
            const SizedBox(height: 12),

            // ── Job No + View button ──────────────────────────────────
            _JobNoRow(state: state, isTablet: isTablet),
            const SizedBox(height: 10),

            // ── Status field ──────────────────────────────────────────
            _FieldLabel('Status', isTablet),
            const SizedBox(height: 6),
            _StatusField(state: state, isTablet: isTablet),
            const SizedBox(height: 12),

            // ── Tablet: 2-col for Start + End time ────────────────────
            isTablet
                ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _DateTimeRow(
                    label: 'Start',
                    dateTime: state.startTime,
                    enabled: state.startTimeEnabled,
                    isTablet: isTablet,
                    onTap: () =>
                        _pickDateTime(context, isStart: true),
                    onCheckChanged: (v) => context
                        .read<BoardingStatusBloc>()
                        .add(BoardingStatusStartTimeCheckboxChanged(v)),
                  ),
                ),
                SizedBox(width: constraints.maxWidth * 0.04),
                Expanded(
                  child: _DateTimeRow(
                    label: 'End',
                    dateTime: state.endTime,
                    enabled: state.endTimeEnabled,
                    isTablet: isTablet,
                    onTap: () =>
                        _pickDateTime(context, isStart: false),
                    onCheckChanged: (v) => context
                        .read<BoardingStatusBloc>()
                        .add(BoardingStatusEndTimeCheckboxChanged(v)),
                  ),
                ),
              ],
            )
                : Column(
              children: [
                _DateTimeRow(
                  label: 'Start',
                  dateTime: state.startTime,
                  enabled: state.startTimeEnabled,
                  isTablet: isTablet,
                  onTap: () =>
                      _pickDateTime(context, isStart: true),
                  onCheckChanged: (v) => context
                      .read<BoardingStatusBloc>()
                      .add(BoardingStatusStartTimeCheckboxChanged(v)),
                ),
                const SizedBox(height: 10),
                _DateTimeRow(
                  label: 'End',
                  dateTime: state.endTime,
                  enabled: state.endTimeEnabled,
                  isTablet: isTablet,
                  onTap: () =>
                      _pickDateTime(context, isStart: false),
                  onCheckChanged: (v) => context
                      .read<BoardingStatusBloc>()
                      .add(BoardingStatusEndTimeCheckboxChanged(v)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Image upload toggle row ───────────────────────────────
            _ImageUploadRow(
              state: state,
              isTablet: isTablet,
              onPickImage: onPickImage,
            ),
            const SizedBox(height: 10),

            // ── Image grid ────────────────────────────────────────────
            _ImageGrid(
              state: state,
              isTablet: isTablet,
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickDateTime(BuildContext context,
      {required bool isStart}) async {
    final s = context.read<BoardingStatusBloc>().state;
    if (s is! BoardingStatusLoaded) return;
    final enabled =
    isStart ? s.startTimeEnabled : s.endTimeEnabled;
    if (!enabled) return;

    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      initialDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTokens.invoiceHeaderStart,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: AppTokens.maintTextDark,
          ),
        ),
        child: child!,
      ),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx)
            .copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    final t = time ?? TimeOfDay.now();
    final combined = DateTime(
        date.year, date.month, date.day, t.hour, t.minute);
    final formatted =
    DateFormat('yyyy-MM-dd HH:mm:ss').format(combined);

    if (isStart) {
      context
          .read<BoardingStatusBloc>()
          .add(BoardingStatusStartTimeChanged(formatted));
    } else {
      context
          .read<BoardingStatusBloc>()
          .add(BoardingStatusEndTimeChanged(formatted));
    }
  }
}

// ─── Bill Type Radio Row ──────────────────────────────────────────────────────
class _BillTypeRow extends StatelessWidget {
  final String billType;
  final bool   isTablet;
  const _BillTypeRow({required this.billType, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: AppTokens.maintDetailBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTokens.maintCardBorder, width: 0.5),
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
                .read<BoardingStatusBloc>()
                .add(BoardingStatusBillTypeChanged(v)),
          ),
          SizedBox(width: isTablet ? 40 : 24),
          _RadioOption(
            label: 'TR',
            value: '1',
            groupValue: billType,
            isTablet: isTablet,
            onChanged: (v) => context
                .read<BoardingStatusBloc>()
                .add(BoardingStatusBillTypeChanged(v)),
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
    final selected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding:
        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width:  isTablet ? 22 : 18,
              height: isTablet ? 22 : 18,
              decoration: BoxDecoration(
                shape:    BoxShape.circle,
                gradient: selected ? kGradient : null,
                border:   Border.all(
                  color: selected ? AppTokens.invoiceHeaderEnd : AppTokens.maintCardBorder,
                  width: selected ? 0 : 1.5,
                ),
              ),
              child: selected
                  ? const Icon(Icons.circle, size: 10, color: Colors.white)
                  : null,
            ),
            SizedBox(width: isTablet ? 8 : 6),
            Text(label,
                style: GoogleFonts.lato(
                  color:      selected ? AppTokens.invoiceHeaderStart : AppTokens.maintTextMid,
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

// ─── Job No field + View button row ──────────────────────────────────────────
class _JobNoRow extends StatefulWidget {
  final BoardingStatusLoaded state;
  final bool isTablet;
  const _JobNoRow({required this.state, required this.isTablet});

  @override
  State<_JobNoRow> createState() => _JobNoRowState();
}

class _JobNoRowState extends State<_JobNoRow> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.state.jobNoText);
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
    final s = widget.state;
    final isTablet = widget.isTablet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FieldLabel('Job No', isTablet),
        const SizedBox(height: 6),

        Row(
          children: [
            // Text field
            Expanded(
              flex: 3,
              child: TextField(
                controller: _ctrl,
                keyboardType: TextInputType.number,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                style: GoogleFonts.lato(
                    color: AppTokens.maintTextDark,
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet
                        ? objfun.FontLow + 1
                        : objfun.FontLow),
                onChanged: (v) => context
                    .read<BoardingStatusBloc>()
                    .add(BoardingStatusJobNoTextChanged(v)),
                decoration: InputDecoration(
                  hintText: 'Job No',
                  hintStyle: GoogleFonts.lato(
                      color: AppTokens.planTextMuted,
                      fontSize: isTablet
                          ? objfun.FontLow + 1
                          : objfun.FontLow),
                  filled: true,
                  fillColor: AppTokens.maintDetailBg,
                  prefixIcon: const Icon(Icons.tag_rounded,
                      color: AppTokens.invoiceHeaderEnd, size: 20),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 13),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppTokens.maintCardBorder, width: 0.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppTokens.invoiceHeaderEnd, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // View button
            Expanded(
              flex: 2,
              child: _GradientButton(
                label: 'VIEW',
                icon: Icons.arrow_circle_right_outlined,
                isTablet: isTablet,
                onPressed: () async {
                  if (s.jobNoText.isEmpty) {
                    objfun.toastMsg('Enter Job No', '', context);
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
                        SaleMaster: objfun.SaleEditMasterList,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        // Autocomplete suggestions
        if (s.jobNoSuggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 180),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTokens.maintCardBorder, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: AppTokens.invoiceHeaderStart.withOpacity(0.10),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: s.jobNoSuggestions.length,
              separatorBuilder: (_, __) =>
              const Divider(height: 1, color: AppTokens.maintDetailBg),
              itemBuilder: (ctx, i) {
                final item = s.jobNoSuggestions[i];
                final cnum = item['CNumber'].toString();
                return InkWell(
                  onTap: () => context
                      .read<BoardingStatusBloc>()
                      .add(BoardingStatusJobNoSelected(
                      saleOrderId: item['Id'], jobNo: cnum)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.work_outline_rounded,
                            size: 16, color: AppTokens.invoiceHeaderEnd),
                        const SizedBox(width: 10),
                        Text(cnum,
                            style: GoogleFonts.lato(
                                color: AppTokens.maintTextDark,
                                fontWeight: FontWeight.w600,
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

// ─── Status search field ──────────────────────────────────────────────────────
class _StatusField extends StatelessWidget {
  final BoardingStatusLoaded state;
  final bool isTablet;
  const _StatusField({required this.state, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (state.jobNoText.isEmpty && state.statusName.isEmpty) {
          objfun.toastMsg('Enter Job No', '', context);
          return;
        }
        if (state.statusName.isNotEmpty) {
          context
              .read<BoardingStatusBloc>()
              .add(BoardingStatusStatusCleared());
          return;
        }
        await OnlineApi.EditSalesOrder(
            context, state.saleOrderId, int.tryParse(state.jobNoText) ?? 0);
        await OnlineApi.SelectAllJobStatus(
            context,
            objfun.SaleEditMasterList[0]['JobMasterRefId']);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const JobAllStatus(
                  Searchby: 1, SearchId: 0, JobTypeId: 0)),
        ).then((_) {
          final sel = objfun.SelectAllStatusList;
          if (sel.Status != 0) {
            context.read<BoardingStatusBloc>().add(
                BoardingStatusStatusSelected(
                    statusId: sel.Status, statusName: sel.StatusName));
            objfun.SelectAllStatusList = JobAllStatusModel.Empty();
          }
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppTokens.maintDetailBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTokens.maintCardBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                state.statusName.isEmpty
                    ? 'Select Status'
                    : state.statusName,
                style: GoogleFonts.lato(
                  color: state.statusName.isEmpty ? AppTokens.planTextMuted : AppTokens.maintTextDark,
                  fontWeight: state.statusName.isEmpty
                      ? FontWeight.w500
                      : FontWeight.w600,
                  fontSize:
                  isTablet ? objfun.FontLow + 1 : objfun.FontLow,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              state.statusName.isNotEmpty
                  ? Icons.close_rounded
                  : Icons.search_rounded,
              size: 20,
              color: AppTokens.invoiceHeaderEnd,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── DateTime row with checkbox ───────────────────────────────────────────────
class _DateTimeRow extends StatelessWidget {
  final String   label;
  final String   dateTime;
  final bool     enabled;
  final bool     isTablet;
  final VoidCallback onTap;
  final void Function(bool) onCheckChanged;

  const _DateTimeRow({
    required this.label,
    required this.dateTime,
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
          .format(DateTime.parse(dateTime));
    } catch (_) {
      display = dateTime;
    }

    return Row(
      children: [
        SizedBox(
          width: isTablet ? 50 : 42,
          child: Text(
            label,
            style: GoogleFonts.lato(
              color: AppTokens.maintTextMid,
              fontWeight: FontWeight.w600,
              fontSize: isTablet ? objfun.FontMedium + 1 : objfun.FontMedium,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 6),

        // Date container
        Expanded(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: enabled ? AppTokens.maintDetailBg : const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTokens.maintCardBorder, width: 0.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      display,
                      style: GoogleFonts.lato(
                        color: enabled ? AppTokens.maintTextDark : AppTokens.planTextMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: isTablet
                            ? objfun.FontLow
                            : objfun.FontLow - 1,
                      ),
                    ),
                  ),
                  Icon(Icons.calendar_month_outlined,
                      size: 18,
                      color: enabled ? AppTokens.invoiceHeaderEnd : AppTokens.planTextMuted),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Checkbox
        InkWell(
          onTap: () => onCheckChanged(!enabled),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width:  isTablet ? 24 : 20,
            height: isTablet ? 24 : 20,
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

// ─── Image upload row ─────────────────────────────────────────────────────────
class _ImageUploadRow extends StatelessWidget {
  final BoardingStatusLoaded state;
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
      padding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTokens.maintDetailBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTokens.maintCardBorder, width: 0.5),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => context
                .read<BoardingStatusBloc>()
                .add(BoardingStatusImageUploadToggled(
                !state.imageUploadEnabled)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width:  isTablet ? 22 : 18,
              height: isTablet ? 22 : 18,
              decoration: BoxDecoration(
                gradient: state.imageUploadEnabled ? kGradient : null,
                border: state.imageUploadEnabled
                    ? null
                    : Border.all(color: AppTokens.maintCardBorder, width: 1.5),
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
                  color: AppTokens.maintTextDark,
                  fontWeight: FontWeight.w600,
                  fontSize: isTablet
                      ? objfun.FontMedium + 1
                      : objfun.FontMedium)),
          const Spacer(),
          _ImagePickBtn(
            icon: Icons.photo_outlined,
            enabled: state.imageUploadEnabled,
            isTablet: isTablet,
            onTap: () => onPickImage(ImageSource.gallery),
          ),
          const SizedBox(width: 4),
          _ImagePickBtn(
            icon: Icons.camera_alt_outlined,
            enabled: state.imageUploadEnabled,
            isTablet: isTablet,
            onTap: () => onPickImage(ImageSource.camera),
          ),
        ],
      ),
    );
  }
}

class _ImagePickBtn extends StatelessWidget {
  final IconData icon;
  final bool     enabled;
  final bool     isTablet;
  final VoidCallback onTap;

  const _ImagePickBtn({
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
              ? AppTokens.invoiceHeaderStart.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon,
            size:  isTablet ? 28 : 24,
            color: enabled ? AppTokens.invoiceHeaderStart : AppTokens.planTextMuted),
      ),
    );
  }
}

// ─── Image Grid ───────────────────────────────────────────────────────────────
class _ImageGrid extends StatelessWidget {
  final BoardingStatusLoaded state;
  final bool isTablet;

  const _ImageGrid({required this.state, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final gridCols   = isTablet ? 4 : 3;
    final gridHeight = isTablet ? 320.0 : 260.0;

    return Container(
      height: gridHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTokens.maintCardBorder, width: 0.5),
      ),
      child: state.images.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined,
                size: isTablet ? 48 : 36, color: AppTokens.planTextMuted),
            const SizedBox(height: 8),
            Text('No images uploaded',
                style: GoogleFonts.lato(
                    color: AppTokens.planTextMuted, fontSize: 13)),
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
                '${objfun.imagepath}SalesOrder/${state.saleOrderId}/Boarding/${state.images[i]}';
            return InkWell(
              onLongPress: () async {
                final ok = await objfun.ConfirmationMsgYesNo(
                    ctx, 'Are you sure to Delete ?');
                if (ok == true) {
                  context.read<BoardingStatusBloc>().add(
                      BoardingStatusImageDeleted(i));
                }
              },
              onTap: () => _showPreview(ctx, url),
              borderRadius: BorderRadius.circular(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: AppTokens.maintDetailBg,
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: AppTokens.invoiceHeaderEnd,
                            strokeWidth: 2),
                      ),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppTokens.maintDetailBg,
                    child: const Icon(Icons.image_not_supported_outlined,
                        color: AppTokens.invoiceHeaderEnd),
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
                placeholder: (_, __) => const CircularProgressIndicator(
                    color: AppTokens.invoiceHeaderEnd),
              ),
            ),
            const SizedBox(height: 12),
            CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded,
                    color: AppTokens.invoiceHeaderStart),
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
            color: AppTokens.maintTextMid,
            fontWeight: FontWeight.w600,
            fontSize:
            isTablet ? objfun.FontLow + 1 : objfun.FontLow));
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
            color: AppTokens.invoiceHeaderStart.withOpacity(0.30),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
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
              mainAxisAlignment: MainAxisAlignment.center,
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
  const _AppBarButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: Colors.white.withOpacity(0.4), width: 0.5),
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