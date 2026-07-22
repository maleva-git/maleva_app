import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/menu/menulist.dart';

import '../../../../../core/di/injection.dart';
import '../../../../transport/updatertidetails/view/updatertidetails_tab.dart';
import '../bloc/rtistatus_bloc.dart';
import '../bloc/rtistatus_event.dart';
import '../bloc/rtistatus_state.dart';



// ─── Entry-point widget ───────────────────────────────────────────────────────

class RTIStatusPage extends StatelessWidget {
  final List<dynamic> rtiDetails;

  const RTIStatusPage({super.key, required this.rtiDetails});

  @override
  Widget build(BuildContext context) {
    return
      BlocProvider(
        create: (context) => sl<RTIStatusBloc>()
          ..add(RTIStatusInitialized(rtiDetails: rtiDetails)),
        child: const _RTIStatusView(),
      );
  }
}

// ─── Internal view ────────────────────────────────────────────────────────────

class _RTIStatusView extends StatelessWidget {
  const _RTIStatusView();

  static const List<String> _driverStatuses = ['PickUp', 'Delivery'];

  @override
  Widget build(BuildContext context) {
    // Responsive: tablet if width >= 768
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 768;

    return BlocConsumer<RTIStatusBloc, RTIStatusState>(
      listener: (context, state) async {
        // Show success dialog
        if (state.successMessage != null) {
          await ConfirmationOK(state.successMessage!, context);

          // Navigate back to OldUpdateRTI after successful status mail
          if (state.status == RTIStatusStatus.success &&
              state.jobNo.isEmpty) {
            // jobNo is cleared after RTIStatusClearRequested → means update was done
            if (!context.mounted) return;
Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const UpdateRTI()),
            );
          }
        }

        // Show error banner/toast
        if (state.errorMessage != null) {
          msgshow(
            state.errorMessage!,
            '',
            Colors.white,
            Colors.red,
            null,
            18.0 - AppGlobals.reducesize,
            AppGlobals.tll,
            AppGlobals.tgc,
            context,
            2,
          );
        }

        // Show image preview dialog
        if (state.previewImageIndex != null) {
          if (!context.mounted) return;
          _showPreviewDialog(context, state);
          // Clear the trigger immediately
          if (!context.mounted) return;
          context
              .read<RTIStatusBloc>()
              .emit(state.copyWith(clearPreview: true));
        }
      },
      builder: (context, state) {
        final bloc = context.read<RTIStatusBloc>();
        final userName =
            AppGlobals.storagenew.getString('Username') ?? '';

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            Navigator.pop(context);
          },
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Colors.white,
            drawer: const Menulist(),
            appBar: _buildAppBar(context, state, bloc, userName, isTablet),
            body: state.status == RTIStatusStatus.loading
                ? const Center(
              child: SpinKitFoldingCube(
                color: colour.spinKitColor,
                size: 35.0,
              ),
            )
                : _buildBody(context, state, bloc, isTablet),
          ),
        );
      },
    );
  }

  // ─── AppBar ────────────────────────────────────────────────────────────────

  AppBar _buildAppBar(
      BuildContext context,
      RTIStatusState state,
      RTIStatusBloc bloc,
      String userName,
      bool isTablet,
      ) {
    final height = MediaQuery.of(context).size.height;
    final titleFontSize =
    isTablet ? AppGlobals.FontLarge.toDouble() : AppGlobals.FontMedium.toDouble();
    final subFontSize = isTablet
        ? AppGlobals.FontLow.toDouble()
        : (AppGlobals.FontLow - 2).toDouble();

    return AppBar(
      automaticallyImplyLeading: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: SizedBox(
        height: height * 0.05,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                'RTI Status',
                style: GoogleFonts.lato(
                  color: colour.topAppBarColor,
                  fontWeight: FontWeight.bold,
                  fontSize: titleFontSize,
                ),
              ),
            ),
            Expanded(
              child: Text(
                userName,
                style: GoogleFonts.lato(
                  color: colour.commonColorLight,
                  fontWeight: FontWeight.bold,
                  fontSize: subFontSize,
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
            width: isTablet ? 100 : 70,
            height: 25,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colour.commonColorLight,
                side: const BorderSide(
                    color: colour.commonColor, width: 1),
                elevation: 20,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.all(4),
              ),
              onPressed: () async {
                final confirm = await ConfirmationMsgYesNo(
                    context, 'Are you sure to update ?');
                if (confirm) {
                  bloc.add(const RTIStatusUpdateRequested());
                }
              },
              child: Text(
                'UPDATE',
                style: GoogleFonts.lato(
                  fontSize: isTablet
                      ? AppGlobals.FontMedium.toDouble()
                      : AppGlobals.FontMedium.toDouble(),
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

  Widget _buildBody(
      BuildContext context,
      RTIStatusState state,
      RTIStatusBloc bloc,
      bool isTablet,
      ) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    // Tablet uses wider padding + larger grid columns
    final hPadding = isTablet ? 30.0 : 15.0;
    final gridColumns = isTablet ? 4 : 3;
    final imageGridHeight = isTablet ? height * 0.60 : height * 0.57;

    return Padding(
      padding:
      EdgeInsets.only(top: 15, left: hPadding, right: hPadding),
      child: ListView(
        children: [
          // ─── RTI No (read-only) ─────────────────────────────────────
          _readOnlyField(
            value: state.rtiNo,
            hint: 'RTI No',
            isTablet: isTablet,
          ),
          const SizedBox(height: 7),

          // ─── Job No (read-only) ─────────────────────────────────────
          _readOnlyField(
            value: state.jobNo,
            hint: 'Job No',
            isTablet: isTablet,
          ),
          const SizedBox(height: 7),

          // ─── Driver status dropdown ─────────────────────────────────
          SizedBox(
            height: isTablet ? height * 0.07 : height * 0.06,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: colour.commonColorLight,
                border: Border.all(),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: state.driverStatus,
                  onChanged: (value) {
                    if (value != null) {
                      bloc.add(RTIStatusDriverStatusChanged(
                          status: value));
                    }
                  },
                  style: GoogleFonts.lato(
                    color: colour.commonColor,
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet
                        ? AppGlobals.FontMedium.toDouble() + 2
                        : AppGlobals.FontMedium.toDouble(),
                  ),
                  items: _driverStatuses
                      .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(
                      s,
                      style: GoogleFonts.lato(
                        color: colour.commonColor,
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet
                            ? AppGlobals.FontMedium.toDouble() + 2
                            : AppGlobals.FontMedium.toDouble(),
                      ),
                    ),
                  ))
                      .toList(),
                ),
              ),
            ),
          ),

          const SizedBox(height: 5),

          // ─── Image upload checkbox + camera / gallery buttons ───────
          Row(
            children: [
              Transform.scale(
                scale: isTablet ? 1.5 : 1.3,
                child: Checkbox(
                  value: state.checkBoxImageUpload,
                  side:
                  const BorderSide(color: colour.commonColor),
                  activeColor: colour.commonColorred,
                  onChanged: (v) => bloc.add(
                      RTIStatusImageUploadToggled(value: v ?? false)),
                ),
              ),
              Text(
                'Upload Image',
                style: GoogleFonts.lato(
                  color: colour.commonColor,
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet
                      ? AppGlobals.FontMedium.toDouble() + 2
                      : AppGlobals.FontMedium.toDouble(),
                ),
              ),
              const Spacer(),
              // Gallery button
              IconButton(
                onPressed: state.checkBoxImageUpload
                    ? () {
                  if (state.jobNo.isEmpty) {
                    toastMsg(
                        'Enter JobNo!!', '', context);
                    return;
                  }
                  bloc.add(const RTIStatusImagePickRequested(
                      fromCamera: false));
                }
                    : null,
                icon: Icon(
                  Icons.photo,
                  size: isTablet ? 45 : 35,
                  color: state.checkBoxImageUpload
                      ? colour.commonColor
                      : colour.commonColorDisabled,
                ),
              ),
              // Camera button
              IconButton(
                onPressed: state.checkBoxImageUpload
                    ? () {
                  if (state.jobNo.isEmpty) {
                    toastMsg(
                        'Enter JobNo!!', '', context);
                    return;
                  }
                  bloc.add(const RTIStatusImagePickRequested(
                      fromCamera: true));
                }
                    : null,
                icon: Icon(
                  Icons.camera_alt,
                  size: isTablet ? 45 : 35,
                  color: state.checkBoxImageUpload
                      ? colour.commonColor
                      : colour.commonColorDisabled,
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          // ─── Image grid ────────────────────────────────────────────
          Container(
            height: imageGridHeight,
            width: width * 0.4,
            decoration: BoxDecoration(
                border: Border.all(color: colour.commonColorLight)),
            child: state.imageNetwork.isEmpty
                ? Center(
              child: Text(
                'No Image Selected.',
                style: GoogleFonts.lato(
                  color: colour.commonColorLight,
                  fontWeight: FontWeight.bold,
                  fontSize: AppGlobals.FontLow.toDouble(),
                ),
              ),
            )
                : GridView.builder(
              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridColumns,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: state.imageNetwork.length,
              itemBuilder: (context, index) {
                final imageUrl =
                    '${AppGlobals.imagepath}SalesOrder/${state.saleOrderId}/${state.driverFolder}/${state.imageNetwork[index]}';

                return InkWell(
                  onLongPress: () async {
                    final confirm =
                    await ConfirmationMsgYesNo(
                        context,
                        'Are you sure to Delete ?');
                    if (confirm) {
                      bloc.add(RTIStatusImageDeleteRequested(
                          index: index));
                    }
                  },
                  onTap: () => bloc.add(
                      RTIStatusImagePreviewRequested(
                          index: index)),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.fill,
                    placeholder: (_, __) => const Center(
                        child: CircularProgressIndicator()),
                    errorWidget: (_, __, ___) => const Icon(
                        Icons.broken_image,
                        color: Colors.red),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── Read-only text field ─────────────────────────────────────────────────

  Widget _readOnlyField({
    required String value,
    required String hint,
    required bool isTablet,
  }) {
    return SizedBox(
      height: isTablet
          ? SizeConfig.safeBlockVertical * 7
          : SizeConfig.safeBlockVertical * 6,
      child: TextField(
        controller: TextEditingController(text: value),
        readOnly: true,
        showCursor: false,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.lato(
            color: colour.commonColorLight,
            fontWeight: FontWeight.bold,
            fontSize: isTablet
                ? AppGlobals.FontMedium.toDouble() + 2
                : AppGlobals.FontMedium.toDouble(),
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
        style: GoogleFonts.lato(
          color: colour.commonColor,
          fontWeight: FontWeight.bold,
          fontSize: isTablet
              ? AppGlobals.FontLow.toDouble() + 2
              : AppGlobals.FontLow.toDouble(),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // ─── Image preview dialog ─────────────────────────────────────────────────

  void _showPreviewDialog(BuildContext context, RTIStatusState state) {
    final index = state.previewImageIndex!;
    final imageUrl =
        '${AppGlobals.imagepath}SalesOrder/${state.saleOrderId}/${state.driverFolder}/${state.imageNetwork[index]}';

    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl,
              placeholder: (_, __) =>
              const CircularProgressIndicator(),
              errorWidget: (_, __, ___) =>
              const Icon(Icons.broken_image, color: Colors.red),
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