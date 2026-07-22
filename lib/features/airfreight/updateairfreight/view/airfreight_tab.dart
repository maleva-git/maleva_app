import 'package:maleva/core/utils/system_helpers.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/menu/menulist.dart';
import '../../../../core/theme/palette.dart';
import '../../../mastersearch/JobAllStatus.dart';
import '../../../transaction/salesorder/add/view/salesorderadd_tab.dart';
import '../bloc/airfreight_bloc.dart';
import '../bloc/airfreight_event.dart';
import '../bloc/airfreight_state.dart';
import 'package:maleva/features/operations/models/job_all_status_model.dart';

const kGradient = LinearGradient(colors: [Palette.blue700, Palette.blue400], begin: Alignment.topLeft, end: Alignment.bottomRight);
const double kTabletBreak = 600;

class AirFrieghtUpdate extends StatelessWidget {
  final String? JobNo;
  final int? JobId;
  const AirFrieghtUpdate({super.key, this.JobNo, this.JobId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => AirFreightBloc()..add(AirFreightStarted(jobNo: JobNo, jobId: JobId, context: ctx)),
      child: const _AirFreightPage(),
    );
  }
}

class _AirFreightPage extends StatefulWidget {
  const _AirFreightPage();
  @override State<_AirFreightPage> createState() => _AirFreightPageState();
}

class _AirFreightPageState extends State<_AirFreightPage> {
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source, int saleOrderId) async {
    if (saleOrderId == 0) {
      toastMsg('Enter Job No', '', context);
      return;
    }
    final file = await _picker.pickImage(source: source);
    if (file == null) return;
    final url = await SystemHelpers.upload(File(file.path), ApiConstants.apiPostImage, saleOrderId, 'SalesOrder', 'AirFrieght');
    if (!mounted) return;
    context.read<AirFreightBloc>().add(AirFreightImagePicked(url));
  }

  @override
  Widget build(BuildContext context) {
    final userName = AppGlobals.storagenew.getString('Username') ?? '';

    return BlocListener<AirFreightBloc, AirFreightState>(
      listener: (context, state) async {
        if (state is AirFreightSaveSuccess) {
          await ConfirmationOK('Updated Successfully', context);
        }
        if (state is AirFreightInvalidJobType) {
          if (!context.mounted) return;
          toastMsg('Enter Air Frieght JobNo', '', context);
        }
        if (state is AirFreightError) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message, style: GoogleFonts.lato(color: Colors.white)), backgroundColor: const Color(0xFFB33040), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
        }
      },
      child: WillPopScope(
        onWillPop: () async { Navigator.pop(context); return false; },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Palette.grey100,
          appBar: _buildAppBar(context, userName),
          drawer: const Menulist(),
          body: BlocBuilder<AirFreightBloc, AirFreightState>(
            builder: (context, state) {
              if (state is AirFreightInitial || state is AirFreightLoading) {
                return const Center(child: SpinKitFoldingCube(color: Palette.blue400, size: 35));
              }
              if (state is AirFreightLoaded) {
                return GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: _AirFreightBody(state: state, onPickImage: (source) => _pickImage(source, state.saleOrderId)),
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
      automaticallyImplyLeading: false, elevation: 0, toolbarHeight: 62,
      flexibleSpace: Container(decoration: const BoxDecoration(gradient: kGradient)),
      leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20), color: Colors.white, onPressed: () => Navigator.pop(context)),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Air Frieght Update', style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17, letterSpacing: 0.3)),
          Text(userName, style: GoogleFonts.lato(color: Colors.white.withValues(alpha: 0.65), fontWeight: FontWeight.w500, fontSize: 12)),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
          child: _AppBarButton(
            label: 'UPDATE',
            onPressed: () {
              final s = context.read<AirFreightBloc>().state;
              if (s is! AirFreightLoaded) return;
              if (s.statusName.isEmpty && !s.imageUploadEnabled) { toastMsg('Enter Details to update', '', context); return; }
              if (s.jobNoText.isEmpty) { toastMsg('Enter Job No', '', context); return; }
              if (s.awbNo.isEmpty) { toastMsg('Enter AWB No', '', context); return; }
              if (s.imageUploadEnabled && s.images.isEmpty) { toastMsg('Select Images !!', '', context); return; }
              ConfirmationMsgYesNo(context, 'Are you sure to Update ?').then((ok) {
                if (!context.mounted) return;
                if (ok == true) context.read<AirFreightBloc>().add(AirFreightSaveRequested(context));
              });
            },
          ),
        ),
      ],
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }
}

class _AirFreightBody extends StatelessWidget {
  final AirFreightLoaded state;
  final Future<void> Function(ImageSource) onPickImage;
  const _AirFreightBody({required this.state, required this.onPickImage});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > kTabletBreak;
        final hPad = isTablet ? constraints.maxWidth * 0.08 : 14.0;
        return ListView(
          padding: EdgeInsets.fromLTRB(hPad, 14, hPad, 24),
          children: [
            _JobNoRow(state: state, isTablet: isTablet), const SizedBox(height: 12),
            if (state.jobType.isNotEmpty) ...[ _ReadonlyInfoChip(label: state.jobType, isTablet: isTablet), const SizedBox(height: 10) ],
            _FieldLabel('Status', isTablet), const SizedBox(height: 6), _StatusField(state: state, isTablet: isTablet), const SizedBox(height: 12),
            _FieldLabel('AWB No', isTablet), const SizedBox(height: 6), _AwbField(state: state, isTablet: isTablet), const SizedBox(height: 12),
            _ImageUploadRow(state: state, isTablet: isTablet, onPickImage: onPickImage), const SizedBox(height: 10),
            _ImageGrid(state: state, isTablet: isTablet),
          ],
        );
      },
    );
  }
}


class _JobNoRow extends StatefulWidget {
  final AirFreightLoaded state;
  final bool isTablet;
  const _JobNoRow({required this.state, required this.isTablet});
  @override State<_JobNoRow> createState() => _JobNoRowState();
}

class _JobNoRowState extends State<_JobNoRow> {
  late TextEditingController _ctrl;
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.state.jobNoText);

    _focusNode.addListener(() {
      // 🔥 FIX 1: Add a tiny delay so the tap has time to register before list closes
      if (!_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) _removeOverlay();
        });
      }
    });
  }

  @override
  void didUpdateWidget(_JobNoRow old) {
    super.didUpdateWidget(old);
    if (widget.state.jobNoText != _ctrl.text && !_focusNode.hasFocus) {
      _ctrl.text = widget.state.jobNoText;
      _ctrl.selection = TextSelection.collapsed(offset: widget.state.jobNoText.length);
    }
  }

  void _onSearchChanged(String value) {
    context.read<AirFreightBloc>().add(AirFreightJobNoTextChanged(value));
    if (value.isEmpty) {
      _removeOverlay();
      return;
    }
    final predictions = AppGlobals.JobNoList.where((e) => e['CNumber'].toString().contains(value)).toList();
    if (predictions.isNotEmpty) {
      _showOverlay(predictions);
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay(List<dynamic> predictions) {
    _removeOverlay();
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    // 🔥 FIX 2: Capture the BLoC before entering the Overlay
    final bloc = context.read<AirFreightBloc>();

    _overlayEntry = OverlayEntry(
        builder: (overlayCtx) => Positioned(
            width: size.width * (widget.isTablet ? 0.6 : 0.6),
            child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0.0, size.height + 5.0),
                child: Material(
                    elevation: 4.0,
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 250),
                        child: ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: predictions.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, color: Palette.grey200p),
                            itemBuilder: (ctx, i) {
                              final cnum = predictions[i]['CNumber'].toString();
                              return InkWell(
                                onTap: () {
                                  _focusNode.unfocus();
                                  _removeOverlay();
                                  // 🔥 FIX 3: Use the captured BLoC and widget's context
                                  bloc.add(AirFreightJobNoSelected(
                                    saleOrderId: predictions[i]['Id'],
                                    jobNo: cnum,
                                    context: context,
                                  ));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.work_outline_rounded, size: 16, color: Palette.blue400),
                                      const SizedBox(width: 10),
                                      Text(cnum, style: GoogleFonts.lato(color: Palette.textDark2, fontWeight: FontWeight.w600, fontSize: widget.isTablet ? AppGlobals.FontLow + 1 : AppGlobals.FontLow)),
                                    ],
                                  ),
                                ),
                              );
                            }
                        )
                    )
                )
            )
        )
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final isTablet = widget.isTablet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel('Job No', isTablet),
        const SizedBox(height: 6),
        CompositedTransformTarget(
          link: _layerLink,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _ctrl,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.done,
                  onChanged: _onSearchChanged,
                  style: GoogleFonts.lato(color: Palette.textDark2, fontWeight: FontWeight.w600, fontSize: isTablet ? AppGlobals.FontLow + 1 : AppGlobals.FontLow),
                  decoration: InputDecoration(
                    hintText: 'Job No',
                    hintStyle: GoogleFonts.lato(color: Palette.kTextMuted, fontSize: isTablet ? AppGlobals.FontLow + 1 : AppGlobals.FontLow),
                    filled: true, fillColor: Palette.grey200p,
                    prefixIcon: const Icon(Icons.tag_rounded, color: Palette.blue400, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Palette.cardBorder, width: 0.5)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Palette.blue400, width: 1.5)),
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
                      toastMsg('Enter Job No', '', context);
                      return;
                    }
                    int finalSaleId = s.saleOrderId;
                    if (finalSaleId == 0) {
                      final match = AppGlobals.JobNoList.where((e) => e['CNumber'].toString() == s.jobNoText).toList();
                      if(match.isNotEmpty) finalSaleId = match.first['Id'];
                    }

                    await OnlineApi.EditSalesOrder(finalSaleId, int.tryParse(s.jobNoText) ?? 0);

                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SalesOrdersAdd(
                          SaleDetails: null,
                          SaleMaster: AppGlobals.SaleEditMasterList,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusField extends StatelessWidget {
  final AirFreightLoaded state;
  final bool isTablet;
  const _StatusField({required this.state, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return InkWell(

      onTap: () async {
        if (state.jobNoText.isEmpty && state.statusName.isEmpty) { toastMsg('Enter Job No', '', context); return; }
        if (state.statusName.isNotEmpty) { context.read<AirFreightBloc>().add(AirFreightStatusCleared()); return; }

        // 🔥 FIXED: Removed 'context' from EditSalesOrder
        await OnlineApi.EditSalesOrder(state.saleOrderId, int.tryParse(state.jobNoText) ?? 0);
        if (!context.mounted) return;
        await OnlineApi.SelectAllJobStatus(context, AppGlobals.SaleEditMasterList[0]['JobMasterRefId']);

        if (!context.mounted) return;
        Navigator.push(context, MaterialPageRoute(builder: (_) => const JobAllStatus(Searchby: 1, SearchId: 0, JobTypeId: 0))).then((navRes) { if (navRes != null) { AppGlobals.SelectAllStatusList = navRes; }
          final sel = AppGlobals.SelectAllStatusList;
          if (sel.Status != 0) {
            if (!context.mounted) return;
            context.read<AirFreightBloc>().add(AirFreightStatusSelected(statusId: sel.Status, statusName: sel.StatusName));
            AppGlobals.SelectAllStatusList = JobAllStatusModel.Empty();
          }
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(color: Palette.grey200p, borderRadius: BorderRadius.circular(10), border: Border.all(color: Palette.cardBorder, width: 0.5)),
        child: Row(
          children: [
            Expanded(child: Text(state.statusName.isEmpty ? 'Select Status' : state.statusName, style: GoogleFonts.lato(color: state.statusName.isEmpty ? Palette.kTextMuted : Palette.textDark2, fontWeight: state.statusName.isEmpty ? FontWeight.w500 : FontWeight.w600, fontSize: isTablet ? AppGlobals.FontLow + 1 : AppGlobals.FontLow), overflow: TextOverflow.ellipsis)),
            Icon(state.statusName.isNotEmpty ? Icons.close_rounded : Icons.search_rounded, size: 20, color: Palette.blue400),
          ],
        ),
      ),
    );
  }
}

class _AwbField extends StatefulWidget {
  final AirFreightLoaded state;
  final bool isTablet;
  const _AwbField({required this.state, required this.isTablet});
  @override State<_AwbField> createState() => _AwbFieldState();
}

class _AwbFieldState extends State<_AwbField> {
  late TextEditingController _ctrl;
  @override void initState() { super.initState(); _ctrl = TextEditingController(text: widget.state.awbNo); }
  @override void didUpdateWidget(_AwbField old) {
    super.didUpdateWidget(old);
    if (widget.state.awbNo != _ctrl.text) {
      _ctrl.text = widget.state.awbNo;
      _ctrl.selection = TextSelection.collapsed(offset: widget.state.awbNo.length);
    }
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl, textCapitalization: TextCapitalization.characters, textInputAction: TextInputAction.done,
      onChanged: (v) => context.read<AirFreightBloc>().add(AirFreightAwbNoChanged(v)),
      style: GoogleFonts.lato(color: Palette.textDark2, fontWeight: FontWeight.w600, fontSize: widget.isTablet ? AppGlobals.FontLow + 1 : AppGlobals.FontLow),
      decoration: InputDecoration(hintText: 'AWB NO', hintStyle: GoogleFonts.lato(color: Palette.kTextMuted, fontSize: widget.isTablet ? AppGlobals.FontLow + 1 : AppGlobals.FontLow), filled: true, fillColor: Palette.grey200p, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Palette.cardBorder, width: 0.5)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Palette.blue400, width: 1.5))),
    );
  }
}

class _ImageUploadRow extends StatelessWidget {
  final AirFreightLoaded state; final bool isTablet; final Future<void> Function(ImageSource) onPickImage;
  const _ImageUploadRow({required this.state, required this.isTablet, required this.onPickImage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Palette.grey200p, borderRadius: BorderRadius.circular(10), border: Border.all(color: Palette.cardBorder, width: 0.5)),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.read<AirFreightBloc>().add(AirFreightImageUploadToggled(!state.imageUploadEnabled)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180), width: isTablet ? 22 : 18, height: isTablet ? 22 : 18,
              decoration: BoxDecoration(gradient: state.imageUploadEnabled ? kGradient : null, border: state.imageUploadEnabled ? null : Border.all(color: Palette.cardBorder, width: 1.5), borderRadius: BorderRadius.circular(5)),
              child: state.imageUploadEnabled ? const Icon(Icons.check_rounded, size: 12, color: Colors.white) : null,
            ),
          ),
          const SizedBox(width: 10), Text('Upload Image', style: GoogleFonts.lato(color: Palette.textDark2, fontWeight: FontWeight.w600, fontSize: isTablet ? AppGlobals.FontMedium + 1 : AppGlobals.FontMedium)),
          const Spacer(),
          _PickBtn(icon: Icons.photo_outlined, enabled: state.imageUploadEnabled, isTablet: isTablet, onTap: () => onPickImage(ImageSource.gallery)),
          const SizedBox(width: 4),
          _PickBtn(icon: Icons.camera_alt_outlined, enabled: state.imageUploadEnabled, isTablet: isTablet, onTap: () => onPickImage(ImageSource.camera)),
        ],
      ),
    );
  }
}

class _PickBtn extends StatelessWidget {
  final IconData icon; final bool enabled; final bool isTablet; final VoidCallback onTap;
  const _PickBtn({required this.icon, required this.enabled, required this.isTablet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null, borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: enabled ? Palette.blue700.withValues(alpha: 0.08) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: isTablet ? 28 : 24, color: enabled ? Palette.blue700 : Palette.kTextMuted),
      ),
    );
  }
}

class _ImageGrid extends StatelessWidget {
  final AirFreightLoaded state; final bool isTablet;
  const _ImageGrid({required this.state, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final gridCols = isTablet ? 4 : 3; final gridHeight = isTablet ? 320.0 : 260.0;
    return Container(
      height: gridHeight,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Palette.cardBorder, width: 0.5)),
      child: state.images.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.image_outlined, size: isTablet ? 48 : 36, color: Palette.kTextMuted), const SizedBox(height: 8), Text('No images uploaded', style: GoogleFonts.lato(color: Palette.kTextMuted, fontSize: 13))]))
          : ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: gridCols, crossAxisSpacing: 6, mainAxisSpacing: 6),
          itemCount: state.images.length,
          itemBuilder: (ctx, i) {
            final url = '${AppGlobals.imagepath}SalesOrder/${state.saleOrderId}/AirFrieght/${state.images[i]}';
            return InkWell(
              onLongPress: () async {
                final ok = await ConfirmationMsgYesNo(ctx, 'Are you sure to Delete ?');
                if (!context.mounted) return;
                if (ok == true) context.read<AirFreightBloc>().add(AirFreightImageDeleted(i, context));
              },
              onTap: () => _showPreview(ctx, url),
              borderRadius: BorderRadius.circular(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: url, fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: Palette.grey200p, child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Palette.blue400, strokeWidth: 2)))),
                  errorWidget: (_, __, ___) => Container(color: Palette.grey200p, child: const Icon(Icons.image_not_supported_outlined, color: Palette.blue400)),
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
      context: context, barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(12), child: CachedNetworkImage(imageUrl: url, placeholder: (_, __) => const CircularProgressIndicator(color: Palette.blue400))),
            const SizedBox(height: 12),
            CircleAvatar(backgroundColor: Colors.white, child: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: Palette.blue700))),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text; final bool isTablet;
  const _FieldLabel(this.text, this.isTablet);
  @override Widget build(BuildContext context) => Text(text, style: GoogleFonts.lato(color: Palette.textMid, fontWeight: FontWeight.w600, fontSize: isTablet ? AppGlobals.FontLow + 1 : AppGlobals.FontLow));
}

class _ReadonlyInfoChip extends StatelessWidget {
  final String label; final bool isTablet;
  const _ReadonlyInfoChip({required this.label, required this.isTablet});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Palette.chipBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: Palette.cardBorder, width: 0.5)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.flight_outlined, size: 16, color: Palette.blue400), const SizedBox(width: 8), Text(label, style: GoogleFonts.lato(color: Palette.blue700, fontWeight: FontWeight.w600, fontSize: isTablet ? AppGlobals.FontLow + 1 : AppGlobals.FontLow))]));
}

class _GradientButton extends StatelessWidget {
  final String label; final IconData icon; final bool isTablet; final VoidCallback onPressed;
  const _GradientButton({required this.label, required this.icon, required this.isTablet, required this.onPressed});
  @override Widget build(BuildContext context) => Container(decoration: BoxDecoration(gradient: kGradient, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Palette.blue700.withValues(alpha: 0.30), blurRadius: 8, offset: const Offset(0, 3))]), child: Material(color: Colors.transparent, child: InkWell(onTap: onPressed, borderRadius: BorderRadius.circular(10), child: Padding(padding: EdgeInsets.symmetric(horizontal: isTablet ? 18 : 12, vertical: isTablet ? 13 : 11), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(label, style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.w700, fontSize: isTablet ? AppGlobals.FontMedium + 1 : AppGlobals.FontMedium)), const SizedBox(width: 6), Icon(icon, color: Colors.white, size: isTablet ? 20 : 17)])))));
}

class _AppBarButton extends StatelessWidget {
  final String label; final VoidCallback onPressed;
  const _AppBarButton({required this.label, required this.onPressed});
  @override Widget build(BuildContext context) => Container(decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 0.5)), child: Material(color: Colors.transparent, child: InkWell(onTap: onPressed, borderRadius: BorderRadius.circular(8), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), child: Text(label, style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.w700, fontSize: AppGlobals.FontMedium))))));
}