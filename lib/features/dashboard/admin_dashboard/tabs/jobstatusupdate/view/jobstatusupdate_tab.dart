import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/menu/menulist.dart';

import '../../../../../../core/di/injection.dart';
import '../../../../../mastersearch/JobAllStatus.dart';
import '../../saleorderdetails/view/saleorderdetails_tab.dart';
import '../bloc/jobstatusupdate_bloc.dart';
import '../bloc/jobstatusupdate_event.dart';
import '../bloc/jobstatusupdate_state.dart';


// ─── Entry point ─────────────────────────────────────────────────────────────

class JobStatusUpdate extends StatelessWidget {
  const JobStatusUpdate({super.key});

  @override
  Widget build(BuildContext context) {
    return
      BlocProvider(
        create: (context) => sl<JobStatusUpdateBloc>()
          ..add(const JobStatusUpdateStarted()),
        child: const _JobStatusUpdateView(),
      );
  }
}

// ─── Main view ────────────────────────────────────────────────────────────────

class _JobStatusUpdateView extends StatefulWidget {
  const _JobStatusUpdateView();

  @override
  State<_JobStatusUpdateView> createState() => _JobStatusUpdateViewState();
}

class _JobStatusUpdateViewState extends State<_JobStatusUpdateView> {
  // Controllers — owned here so they stay alive across rebuilds
  final TextEditingController _jobNoCtrl = TextEditingController();
  final TextEditingController _statusCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // Overlay for autocomplete (UI concern, not BLoC concern)
  OverlayEntry? _overlayEntry;
  final GlobalKey _appBarKey = GlobalKey();

  @override
  void dispose() {
    _jobNoCtrl.dispose();
    _statusCtrl.dispose();
    _removeOverlay();
    super.dispose();
  }

  // ─── Overlay helpers ───────────────────────────────────────────────────────

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay(List<Map<String, dynamic>> suggestions) {
    _removeOverlay();
    if (suggestions.isEmpty) return;

    final double height = MediaQuery.of(context).size.height;
    final RenderBox? appBarBox =
    _appBarKey.currentContext?.findRenderObject() as RenderBox?;
    if (appBarBox == null) return;

    final topOffset = objfun.MalevaScreen == 1
        ? appBarBox.size.height + height * 0.12 + 10
        : appBarBox.size.height + height * 0.22 + 10;

    _overlayEntry = OverlayEntry(
      builder: (_) => Positioned(
        top: topOffset,
        left: objfun.MalevaScreen == 1 ? 10 : 70,
        right: objfun.MalevaScreen == 1 ? 10 : 500,
        child: Material(
          color: colour.commonColorLight,
          elevation: 1,
          textStyle: GoogleFonts.lato(
            textStyle: TextStyle(
              color: colour.commonColor,
              fontWeight: FontWeight.bold,
              fontSize: objfun.FontLow,
              letterSpacing: 0.3,
            ),
          ),
          child: SizedBox(
            height: 350,
            child: ListView(
              children: suggestions.map((s) {
                return InkWell(
                  onTap: () {
                    _jobNoCtrl.text = s['CNumber'].toString();
                    context.read<JobStatusUpdateBloc>().add(
                      JobStatusUpdateSuggestionSelected(
                        jobNo: s['CNumber'].toString(),
                        saleOrderId: s['Id'] as int,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Text(s['CNumber'].toString()),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  // ─── Image picker ──────────────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source, int saleOrderId) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) return;

    final imageName = await objfun.upload(
      File(pickedFile.path),
      objfun.apiPostimage,
      saleOrderId,
      'SalesOrder',
      'Boarding',
    );

    if (imageName.isNotEmpty && mounted) {
      context
          .read<JobStatusUpdateBloc>()
          .add(JobStatusUpdateImagePicked(imageName));
    }
  }

  // ─── Date/time picker ─────────────────────────────────────────────────────

  Future<void> _pickDateTime({required bool isStart}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final combined = DateTime(
        date.year, date.month, date.day, time.hour, time.minute);
    final formatted =
    DateFormat('yyyy-MM-dd HH:mm:ss').format(combined);

    if (isStart) {
      context
          .read<JobStatusUpdateBloc>()
          .add(JobStatusUpdateStartTimePicked(formatted));
    } else {
      context
          .read<JobStatusUpdateBloc>()
          .add(JobStatusUpdateEndTimePicked(formatted));
    }
  }

  // ─── Back press ───────────────────────────────────────────────────────────

  Future<bool> _onWillPop() async {
    if (_overlayEntry != null) {
      _removeOverlay();
      context
          .read<JobStatusUpdateBloc>()
          .add(const JobStatusUpdateOverlayCleared());
      return false;
    }
    Navigator.of(context).pop();
    return true;
  }

  // ─── Confirmation helpers (keep UI dialog logic in View) ──────────────────

  Future<bool> _confirm(String msg) =>
      objfun.ConfirmationMsgYesNo(context, msg);

  Future<void> _ok(String msg) => objfun.ConfirmationOK(msg, context);

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<JobStatusUpdateBloc, JobStatusUpdateState>(
      listener: _handleStateChange,
      builder: (context, state) {
        return WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Colors.white,
            drawer: const Menulist(),
            appBar: _buildAppBar(context, state),
            body: state.status == JobStatusUpdateStatus.loading
                ? const Center(
              child: SpinKitFoldingCube(
                color: colour.spinKitColor,
                size: 35,
              ),
            )
                : _buildBody(context, state),
          ),
        );
      },
    );
  }

  // ─── Listener ─────────────────────────────────────────────────────────────

  void _handleStateChange(
      BuildContext context, JobStatusUpdateState state) {
    // Sync text controllers with BLoC state
    if (_jobNoCtrl.text != state.jobNo) {
      _jobNoCtrl.text = state.jobNo;
      _jobNoCtrl.selection = TextSelection.fromPosition(
          TextPosition(offset: _jobNoCtrl.text.length));
    }
    if (_statusCtrl.text != state.statusName) {
      _statusCtrl.text = state.statusName;
    }

    // Autocomplete overlay
    if (state.action == JobStatusUpdateAction.showAutocomplete) {
      _showOverlay(state.autocompleteSuggestions);
    } else if (state.action == JobStatusUpdateAction.hideAutocomplete) {
      _removeOverlay();
    }

    // Reset and reload after successful update
    if (state.action == JobStatusUpdateAction.resetAndReload) {
      _ok('Updated Successfully').then((_) {
        context
            .read<JobStatusUpdateBloc>()
            .add(const JobStatusUpdateFormCleared());
      });
    }

    // Error messages
    if (state.status == JobStatusUpdateStatus.failure &&
        state.errorMessage.isNotEmpty) {
      objfun.toastMsg(state.errorMessage, '', context);
    }
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(
      BuildContext context, JobStatusUpdateState state) {
    final height = MediaQuery.of(context).size.height;
    return AppBar(
      key: _appBarKey,
      automaticallyImplyLeading: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          _removeOverlay();
          context
              .read<JobStatusUpdateBloc>()
              .add(const JobStatusUpdateOverlayCleared());
          Navigator.pop(context);
        },
      ),
      title: SizedBox(
        height: height * 0.05,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                'Job Status Update',
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    color: colour.topAppBarColor,
                    fontWeight: FontWeight.bold,
                    fontSize: objfun.FontMedium,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Text(
                state.userName,
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    color: colour.commonColorLight,
                    fontWeight: FontWeight.bold,
                    fontSize: objfun.FontLow - 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      iconTheme: const IconThemeData(color: colour.topAppBarColor),
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 7, bottom: 7, left: 7),
          child: SizedBox(
            width: 70,
            height: 25,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colour.commonColorLight,
                side: const BorderSide(color: colour.commonColor),
                elevation: 20,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.all(4),
              ),
              onPressed: () async {
                final ok = await _confirm('Are you sure to Update ?');
                if (ok) {
                  context
                      .read<JobStatusUpdateBloc>()
                      .add(const JobStatusUpdateSubmitted());
                }
              },
              child: Text(
                'Update',
                style: GoogleFonts.lato(
                  fontSize: objfun.FontMedium,
                  fontWeight: FontWeight.bold,
                  color: colour.commonColor,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
      ],
    );
  }

  // ─── Body ─────────────────────────────────────────────────────────────────

  Widget _buildBody(BuildContext context, JobStatusUpdateState state) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
      child: ListView(
        children: [
          // ── Bill type radio row ────────────────────────────────────────
          _BillTypeRadioRow(
            billType: state.billType,
            onChanged: (val) => context
                .read<JobStatusUpdateBloc>()
                .add(JobStatusUpdateBillTypeChanged(val)),
          ),
          const SizedBox(height: 6),

          // ── Job No + View button ───────────────────────────────────────
          _JobNoRow(
            jobNoCtrl: _jobNoCtrl,
            state: state,
            onJobNoChanged: (val) => context
                .read<JobStatusUpdateBloc>()
                .add(JobStatusUpdateJobNoChanged(val)),
            onViewPressed: () async {
              if (state.jobNo.isEmpty) {
                objfun.toastMsg('Enter Job No', '', context);
                return;
              }
              await OnlineApi.EditSalesOrder(
                   state.saleOrderId, int.tryParse(state.jobNo) ?? 0); if (!context.mounted) return;Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => SaleOrderDetails(
                    saleDetails: null,
                    saleMaster: objfun.SaleEditMasterList,
                  )));
            },
          ),
          const SizedBox(height: 7),

          // ── Status field ──────────────────────────────────────────────
          _StatusField(
            statusCtrl: _statusCtrl,
            state: state,
            onSearchTap: () async {
              if (state.jobNo.isEmpty && state.statusName.isEmpty) {
                objfun.toastMsg('Enter Job No', '', context);
                return;
              }
              if (state.statusName.isEmpty && state.jobNo.isNotEmpty) {
                await OnlineApi.EditSalesOrder(

                    state.saleOrderId,
                    int.tryParse(state.jobNo) ?? 0); if (!context.mounted) return;await OnlineApi.SelectAllJobStatus(
                    context,
                    objfun.SaleEditMasterList[0]['JobMasterRefId'] as int); if (!context.mounted) return;Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const JobAllStatus(
                          Searchby: 1, SearchId: 0, JobTypeId: 0)),
                ).then((_navRes) { if (_navRes != null) { objfun.SelectAllStatusList = _navRes; }
                  final selected = objfun.SelectAllStatusList;
                  if (selected.StatusName.isNotEmpty) {
                    context.read<JobStatusUpdateBloc>().add(
                      JobStatusUpdateStatusSelected(
                        statusName: selected.StatusName,
                        statusId: selected.Status,
                      ),
                    );
                    objfun.SelectAllStatusList = JobAllStatusModel.Empty();
                  }
                });
              } else {
                context
                    .read<JobStatusUpdateBloc>()
                    .add(const JobStatusUpdateStatusCleared());
              }
            },
          ),
          const SizedBox(height: 7),

          // ── Start time ────────────────────────────────────────────────
          _TimeRow(
            label: 'Start Time',
            checked: state.checkBoxStartTime,
            dateTimeStr: state.dtpStartTime,
            onToggle: (v) => context
                .read<JobStatusUpdateBloc>()
                .add(JobStatusUpdateStartTimeToggled(v ?? false)),
            onPickTime: () => _pickDateTime(isStart: true),
          ),
          const SizedBox(height: 4),

          // ── End time ──────────────────────────────────────────────────
          _TimeRow(
            label: 'End Time',
            checked: state.checkBoxEndTime,
            dateTimeStr: state.dtpEndTime,
            onToggle: (v) => context
                .read<JobStatusUpdateBloc>()
                .add(JobStatusUpdateEndTimeToggled(v ?? false)),
            onPickTime: () => _pickDateTime(isStart: false),
          ),
          const SizedBox(height: 7),

          // ── Image upload checkbox ─────────────────────────────────────
          Row(
            children: [
              Checkbox(
                value: state.checkBoxImageUpload,
                onChanged: (v) => context
                    .read<JobStatusUpdateBloc>()
                    .add(JobStatusUpdateImageUploadToggled(v ?? false)),
                activeColor: colour.commonColor,
              ),
              Text(
                'Image Upload',
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    color: colour.commonColor,
                    fontWeight: FontWeight.bold,
                    fontSize: objfun.FontLow,
                  ),
                ),
              ),
            ],
          ),

          // ── Image picker buttons (only when checkbox is on) ───────────
          if (state.checkBoxImageUpload) ...[
            const SizedBox(height: 7),
            _ImagePickerButtons(
              onCameraTap: () => _pickImage(
                  ImageSource.camera, state.saleOrderId),
              onGalleryTap: () => _pickImage(
                  ImageSource.gallery, state.saleOrderId),
            ),
          ],
          const SizedBox(height: 10),

          // ── Image grid ────────────────────────────────────────────────
          if (state.imageNetworkNames.isNotEmpty)
            _ImageGrid(
              state: state,
              onPreview: (i) => _showPreviewDialog(context, state, i),
              onDelete: (i) async {
                final ok =
                await _confirm('Are you sure to Delete ?');
                if (ok) {
                  context
                      .read<JobStatusUpdateBloc>()
                      .add(JobStatusUpdateImageDeleted(i));
                }
              },
            ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ─── Image preview dialog ─────────────────────────────────────────────────

  Future<void> _showPreviewDialog(
      BuildContext context, JobStatusUpdateState state, int index) async {
    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CachedNetworkImage(
              placeholder: (_, __) =>
              const CircularProgressIndicator(),
              imageUrl:
              '${objfun.imagepath}SalesOrder/${state.saleOrderId}/Boarding/${state.imageNetworkNames[index]}',
            ),
            const SizedBox(height: 7),
            CircleAvatar(
              backgroundColor: colour.commonColorLight,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.clear, color: colour.commonColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXTRACTED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

// ─── Bill type radio row ──────────────────────────────────────────────────────

class _BillTypeRadioRow extends StatelessWidget {
  const _BillTypeRadioRow({
    required this.billType,
    required this.onChanged,
  });

  final String billType;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Radio<String>(
            value: '0',
            groupValue: billType,
            onChanged: (v) => onChanged(v!),
          ),
        ),
        Expanded(
          child: Text(
            'MY',
            style: GoogleFonts.lato(
              textStyle: TextStyle(
                color: colour.commonColor,
                fontWeight: FontWeight.bold,
                fontSize: objfun.FontMedium,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
        Expanded(
          child: Radio<String>(
            value: '1',
            groupValue: billType,
            onChanged: (v) => onChanged(v!),
          ),
        ),
        Expanded(
          child: Text(
            'TR',
            style: GoogleFonts.lato(
              textStyle: TextStyle(
                color: colour.commonColor,
                fontWeight: FontWeight.bold,
                fontSize: objfun.FontMedium,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Job No row ───────────────────────────────────────────────────────────────

class _JobNoRow extends StatelessWidget {
  const _JobNoRow({
    required this.jobNoCtrl,
    required this.state,
    required this.onJobNoChanged,
    required this.onViewPressed,
  });

  final TextEditingController jobNoCtrl;
  final JobStatusUpdateState state;
  final ValueChanged<String> onJobNoChanged;
  final VoidCallback onViewPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Job No text field
        Expanded(
          flex: 3,
          child: SizedBox(
            height: objfun.SizeConfig.safeBlockVertical * 6,
            child: TextField(
              controller: jobNoCtrl,
              cursorColor: colour.commonColor,
              autofocus: false,
              keyboardType: TextInputType.number,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.done,
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  color: colour.commonColor,
                  fontWeight: FontWeight.bold,
                  fontSize: objfun.FontLow,
                  letterSpacing: 0.3,
                ),
              ),
              decoration: InputDecoration(
                hintText: 'Job No',
                hintStyle: GoogleFonts.lato(
                  textStyle: TextStyle(
                    fontSize: objfun.FontMedium,
                    fontWeight: FontWeight.bold,
                    color: colour.commonColorLight,
                  ),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: colour.commonColor),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: colour.commonColorred),
                ),
                contentPadding:
                const EdgeInsets.only(left: 10, right: 20, top: 10),
              ),
              onChanged: onJobNoChanged,
            ),
          ),
        ),
        const SizedBox(width: 7),
        // View button
        Expanded(
          flex: 2,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colour.commonColor,
              elevation: 20,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            ),
            onPressed: onViewPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'VIEW',
                  style: GoogleFonts.lato(
                    fontSize: objfun.FontMedium,
                    fontWeight: FontWeight.bold,
                    color: colour.commonColorLight,
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(Icons.arrow_circle_right,
                    color: colour.commonColorLight),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Status field ─────────────────────────────────────────────────────────────

class _StatusField extends StatelessWidget {
  const _StatusField({
    required this.statusCtrl,
    required this.state,
    required this.onSearchTap,
  });

  final TextEditingController statusCtrl;
  final JobStatusUpdateState state;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: objfun.SizeConfig.safeBlockVertical * 6,
      child: TextField(
        controller: statusCtrl,
        readOnly: true,
        textCapitalization: TextCapitalization.characters,
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.name,
        style: GoogleFonts.lato(
          textStyle: TextStyle(
            color: colour.commonColor,
            fontWeight: FontWeight.bold,
            fontSize: objfun.FontLow,
            letterSpacing: 0.3,
          ),
        ),
        decoration: InputDecoration(
          hintText: 'Select Status',
          hintStyle: GoogleFonts.lato(
            textStyle: TextStyle(
              fontSize: objfun.FontMedium,
              fontWeight: FontWeight.bold,
              color: colour.commonColorLight,
            ),
          ),
          suffixIcon: InkWell(
            onTap: onSearchTap,
            child: Icon(
              state.statusName.isNotEmpty
                  ? Icons.close
                  : Icons.search_rounded,
              color: colour.commonColorred,
              size: 30,
            ),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: colour.commonColor),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: colour.commonColorred),
          ),
          contentPadding:
          const EdgeInsets.only(left: 10, right: 20, top: 10),
        ),
      ),
    );
  }
}

// ─── Time row (checkbox + datetime display + picker) ─────────────────────────

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.label,
    required this.checked,
    required this.dateTimeStr,
    required this.onToggle,
    required this.onPickTime,
  });

  final String label;
  final bool checked;
  final String dateTimeStr;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onPickTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: checked,
          onChanged: onToggle,
          activeColor: colour.commonColor,
        ),
        Text(
          label,
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              color: colour.commonColor,
              fontWeight: FontWeight.bold,
              fontSize: objfun.FontLow,
            ),
          ),
        ),
        if (checked) ...[
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: onPickTime,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: colour.commonColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateTimeStr.isNotEmpty
                          ? DateFormat('dd-MM-yyyy HH:mm')
                          .format(DateTime.parse(dateTimeStr))
                          : 'Pick date & time',
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(
                          color: colour.commonColor,
                          fontWeight: FontWeight.bold,
                          fontSize: objfun.FontCardText,
                        ),
                      ),
                    ),
                    const Icon(Icons.calendar_month_outlined,
                        color: colour.commonColor, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Image picker buttons ────────────────────────────────────────────────────

class _ImagePickerButtons extends StatelessWidget {
  const _ImagePickerButtons({
    required this.onCameraTap,
    required this.onGalleryTap,
  });

  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: colour.commonColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: onCameraTap,
            icon: const Icon(Icons.camera_alt,
                color: colour.commonColorLight),
            label: Text(
              'Camera',
              style: GoogleFonts.lato(
                fontSize: objfun.FontLow,
                fontWeight: FontWeight.bold,
                color: colour.commonColorLight,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: colour.commonColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: onGalleryTap,
            icon: const Icon(Icons.photo_library,
                color: colour.commonColorLight),
            label: Text(
              'Gallery',
              style: GoogleFonts.lato(
                fontSize: objfun.FontLow,
                fontWeight: FontWeight.bold,
                color: colour.commonColorLight,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Image grid ───────────────────────────────────────────────────────────────

class _ImageGrid extends StatelessWidget {
  const _ImageGrid({
    required this.state,
    required this.onPreview,
    required this.onDelete,
  });

  final JobStatusUpdateState state;
  final ValueChanged<int> onPreview;
  final ValueChanged<int> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Uploaded Images (${state.imageNetworkNames.length})',
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              color: colour.commonColor,
              fontWeight: FontWeight.bold,
              fontSize: objfun.FontLow,
            ),
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.imageNetworkNames.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (_, i) {
            final url =
                '${objfun.imagepath}SalesOrder/${state.saleOrderId}/Boarding/${state.imageNetworkNames[i]}';
            return Stack(
              children: [
                // Image thumbnail
                GestureDetector(
                  onTap: () => onPreview(i),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (_, __) => Container(
                        color: colour.commonColorLight,
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: colour.commonColorLight,
                        child: const Icon(Icons.broken_image,
                            color: colour.commonColor),
                      ),
                    ),
                  ),
                ),
                // Delete button
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => onDelete(i),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(3),
                      child: const Icon(Icons.close,
                          size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}