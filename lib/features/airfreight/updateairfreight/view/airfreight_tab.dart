import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/models/model.dart';
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/MasterSearch/JobAllStatus.dart';
import 'package:maleva/Transaction/SaleOrderDetails.dart';

import '../bloc/airfreight_bloc.dart';
import '../bloc/airfreight_event.dart';
import '../bloc/airfreight_state.dart';


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
class AirFrieghtUpdate extends StatelessWidget {
  final String? JobNo;
  final int?    JobId;

  const AirFrieghtUpdate(
      {super.key, this.JobNo, this.JobId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AirFreightBloc()
        ..add(AirFreightStarted(jobNo: JobNo, jobId: JobId)),
      child: const _AirFreightPage(),
    );
  }
}

// ─── Page ─────────────────────────────────────────────────────────────────────
class _AirFreightPage extends StatefulWidget {
  const _AirFreightPage();

  @override
  State<_AirFreightPage> createState() =>
      _AirFreightPageState();
}

class _AirFreightPageState extends State<_AirFreightPage> {
  final _picker = ImagePicker();

  Future<void> _pickImage(
      ImageSource source, int saleOrderId) async {
    if (saleOrderId == 0) {
      objfun.toastMsg('Enter Job No', '', context);
      return;
    }
    final file = await _picker.pickImage(source: source);
    if (file == null) return;
    final url = await objfun.upload(
        File(file.path),
        objfun.apiPostimage,
        saleOrderId,
        'SalesOrder',
        'AirFrieght');
    context
        .read<AirFreightBloc>()
        .add(AirFreightImagePicked(url));
  }

  @override
  Widget build(BuildContext context) {
    final userName =
        objfun.storagenew.getString('Username') ?? '';

    return BlocListener<AirFreightBloc, AirFreightState>(
      listener: (context, state) async {
        if (state is AirFreightSaveSuccess) {
          await objfun.ConfirmationOK(
              'Updated Successfully', context);
        }
        if (state is AirFreightInvalidJobType) {
          objfun.toastMsg(
              'Enter Air Frieght JobNo', '', context);
        }
        if (state is AirFreightError) {
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
          body: BlocBuilder<AirFreightBloc, AirFreightState>(
            builder: (context, state) {
              if (state is AirFreightInitial ||
                  state is AirFreightLoading) {
                return const Center(
                  child: SpinKitFoldingCube(
                      color: kHeaderGradEnd, size: 35),
                );
              }
              if (state is AirFreightLoaded) {
                return GestureDetector(
                  onTap: () => context
                      .read<AirFreightBloc>()
                      .add(AirFreightOverlayDismissed()),
                  child: _AirFreightBody(
                    state:       state,
                    onPickImage: (source) => _pickImage(
                        source, state.saleOrderId),
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
          Text('Air Frieght Update',
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
            label: 'UPDATE',
            onPressed: () {
              final s =
                  context.read<AirFreightBloc>().state;
              if (s is! AirFreightLoaded) return;

              if (s.statusName.isEmpty &&
                  !s.imageUploadEnabled) {
                objfun.toastMsg(
                    'Enter Details to update', '', context);
                return;
              }
              if (s.jobNoText.isEmpty) {
                objfun.toastMsg(
                    'Enter Job No', '', context);
                return;
              }
              if (s.awbNo.isEmpty) {
                objfun.toastMsg(
                    'Enter AWB No', '', context);
                return;
              }
              if (s.imageUploadEnabled && s.images.isEmpty) {
                objfun.toastMsg(
                    'Select Images !!', '', context);
                return;
              }
              objfun
                  .ConfirmationMsgYesNo(context,
                  'Are you sure to Update ?')
                  .then((ok) {
                if (ok == true) {
                  context
                      .read<AirFreightBloc>()
                      .add(AirFreightSaveRequested());
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
class _AirFreightBody extends StatelessWidget {
  final AirFreightLoaded state;
  final Future<void> Function(ImageSource) onPickImage;

  const _AirFreightBody(
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
            // ── Job No + View ────────────────────────────
            _JobNoRow(state: state, isTablet: isTablet),
            const SizedBox(height: 12),

            // ── Job Type (read-only) ─────────────────────
            if (state.jobType.isNotEmpty) ...[
              _ReadonlyInfoChip(
                  label: state.jobType,
                  isTablet: isTablet),
              const SizedBox(height: 10),
            ],

            // ── Status field ─────────────────────────────
            _FieldLabel('Status', isTablet),
            const SizedBox(height: 6),
            _StatusField(
                state: state, isTablet: isTablet),
            const SizedBox(height: 12),

            // ── Tablet: AWB on right of status row; mobile: below ──
            _FieldLabel('AWB No', isTablet),
            const SizedBox(height: 6),
            _AwbField(state: state, isTablet: isTablet),
            const SizedBox(height: 12),

            // ── Image upload toggle ──────────────────────
            _ImageUploadRow(
              state:       state,
              isTablet:    isTablet,
              onPickImage: onPickImage,
            ),
            const SizedBox(height: 10),

            // ── Image grid ───────────────────────────────
            _ImageGrid(
                state: state, isTablet: isTablet),
          ],
        );
      },
    );
  }
}

// ─── Job No + View Button ─────────────────────────────────────────────────────
class _JobNoRow extends StatefulWidget {
  final AirFreightLoaded state;
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
                    .read<AirFreightBloc>()
                    .add(AirFreightJobNoTextChanged(v)),
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
                        color: kHeaderGradEnd, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: _GradientButton(
                label:    'VIEW',
                icon:     Icons.arrow_circle_right_outlined,
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

        // Inline autocomplete
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
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: s.jobNoSuggestions.length,
              separatorBuilder: (_, __) =>
              const Divider(height: 1, color: kDetailBg),
              itemBuilder: (ctx, i) {
                final item = s.jobNoSuggestions[i];
                final cnum =
                item['CNumber'].toString();
                return InkWell(
                  onTap: () => context
                      .read<AirFreightBloc>()
                      .add(AirFreightJobNoSelected(
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

// ─── Status Search Field ──────────────────────────────────────────────────────
class _StatusField extends StatelessWidget {
  final AirFreightLoaded state;
  final bool isTablet;
  const _StatusField(
      {required this.state, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (state.jobNoText.isEmpty &&
            state.statusName.isEmpty) {
          objfun.toastMsg('Enter Job No', '', context);
          return;
        }
        if (state.statusName.isNotEmpty) {
          context
              .read<AirFreightBloc>()
              .add(AirFreightStatusCleared());
          return;
        }
        await OnlineApi.EditSalesOrder(
            context,
            state.saleOrderId,
            int.tryParse(state.jobNoText) ?? 0);
        await OnlineApi.SelectAllJobStatus(
            context,
            objfun.SaleEditMasterList[0]
            ['JobMasterRefId']);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const JobAllStatus(
                  Searchby: 1,
                  SearchId: 0,
                  JobTypeId: 0)),
        ).then((_) {
          final sel = objfun.SelectAllStatusList;
          if (sel.Status != 0) {
            context.read<AirFreightBloc>().add(
                AirFreightStatusSelected(
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
                    ? 'Select Status'
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

// ─── AWB No Field ─────────────────────────────────────────────────────────────
class _AwbField extends StatefulWidget {
  final AirFreightLoaded state;
  final bool isTablet;
  const _AwbField(
      {required this.state, required this.isTablet});

  @override
  State<_AwbField> createState() => _AwbFieldState();
}

class _AwbFieldState extends State<_AwbField> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl =
        TextEditingController(text: widget.state.awbNo);
  }

  @override
  void didUpdateWidget(_AwbField old) {
    super.didUpdateWidget(old);
    if (widget.state.awbNo != _ctrl.text) {
      _ctrl.text = widget.state.awbNo;
      _ctrl.selection = TextSelection.collapsed(
          offset: widget.state.awbNo.length);
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
      textCapitalization: TextCapitalization.characters,
      textInputAction: TextInputAction.done,
      onChanged: (v) => context
          .read<AirFreightBloc>()
          .add(AirFreightAwbNoChanged(v)),
      style: GoogleFonts.lato(
          color: kTextDark,
          fontWeight: FontWeight.w600,
          fontSize: widget.isTablet
              ? objfun.FontLow + 1
              : objfun.FontLow),
      decoration: InputDecoration(
        hintText: 'AWB NO',
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
    );
  }
}

// ─── Image Upload Toggle Row ──────────────────────────────────────────────────
class _ImageUploadRow extends StatelessWidget {
  final AirFreightLoaded state;
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
                .read<AirFreightBloc>()
                .add(AirFreightImageUploadToggled(
                !state.imageUploadEnabled)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width:  isTablet ? 22 : 18,
              height: isTablet ? 22 : 18,
              decoration: BoxDecoration(
                gradient:
                state.imageUploadEnabled ? kGradient : null,
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
            icon:    Icons.photo_outlined,
            enabled: state.imageUploadEnabled,
            isTablet: isTablet,
            onTap: () => onPickImage(ImageSource.gallery),
          ),
          const SizedBox(width: 4),
          _PickBtn(
            icon:    Icons.camera_alt_outlined,
            enabled: state.imageUploadEnabled,
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
  final bool     enabled;
  final bool     isTablet;
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
  final AirFreightLoaded state;
  final bool isTablet;

  const _ImageGrid(
      {required this.state, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final gridCols   = isTablet ? 4 : 3;
    final gridHeight = isTablet ? 320.0 : 260.0;

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
                '${objfun.imagepath}SalesOrder/${state.saleOrderId}/AirFrieght/${state.images[i]}';
            return InkWell(
              onLongPress: () async {
                final ok =
                await objfun.ConfirmationMsgYesNo(
                    ctx,
                    'Are you sure to Delete ?');
                if (ok == true) {
                  context
                      .read<AirFreightBloc>()
                      .add(AirFreightImageDeleted(i));
                }
              },
              onTap: () =>
                  _showPreview(ctx, url),
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

// ─── Reusable Widgets ─────────────────────────────────────────────────────────
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

class _ReadonlyInfoChip extends StatelessWidget {
  final String label;
  final bool   isTablet;
  const _ReadonlyInfoChip(
      {required this.label, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kChipBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kCardBorder, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.flight_outlined,
              size: 16, color: kHeaderGradEnd),
          const SizedBox(width: 8),
          Text(label,
              style: GoogleFonts.lato(
                  color: kHeaderGradStart,
                  fontWeight: FontWeight.w600,
                  fontSize: isTablet
                      ? objfun.FontLow + 1
                      : objfun.FontLow)),
        ],
      ),
    );
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