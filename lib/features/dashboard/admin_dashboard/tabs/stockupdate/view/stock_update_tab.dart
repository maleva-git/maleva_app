import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/models/model.dart';
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/MasterSearch/JobAllStatus.dart';
import 'package:maleva/MasterSearch/WareHouseList.dart';

import '../bloc/stock_update_bloc.dart';
import '../bloc/stock_update_event.dart';
import '../bloc/stock_update_state.dart';


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
const kAccentRed       = Color(0xFFB33040);

const kGradient = LinearGradient(
  colors: [kHeaderGradStart, kHeaderGradEnd],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const double kTabletBreak = 600;

// ─── Root ─────────────────────────────────────────────────────────────────────
class StockUpdate extends StatelessWidget {
  const StockUpdate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      StockUpdateBloc()..add(StockUpdateStarted()),
      child: const _StockUpdatePage(),
    );
  }
}

// ─── Page ─────────────────────────────────────────────────────────────────────
class _StockUpdatePage extends StatefulWidget {
  const _StockUpdatePage();

  @override
  State<_StockUpdatePage> createState() =>
      _StockUpdatePageState();
}

class _StockUpdatePageState
    extends State<_StockUpdatePage> {
  final _picker = ImagePicker();

  Future<void> _pickImage(
      ImageSource source,
      int saleOrderId,
      String statusName) async {
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
    context
        .read<StockUpdateBloc>()
        .add(StockUpdateImagePicked(url));
  }

  @override
  Widget build(BuildContext context) {
    final userName =
        objfun.storagenew.getString('Username') ?? '';

    return BlocListener<StockUpdateBloc, StockUpdateState>(
      listener: (context, state) async {
        if (state is StockUpdateSaveSuccess) {
          await objfun.ConfirmationOK(
              'Updated Successfully', context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => const StockUpdate()),
          );
        }
        if (state is StockUpdateError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message,
                  style: GoogleFonts.lato(
                      color: Colors.white)),
              backgroundColor: kAccentRed,
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
          body: BlocBuilder<StockUpdateBloc, StockUpdateState>(
            builder: (context, state) {
              if (state is StockUpdateInitial ||
                  state is StockUpdateLoading) {
                return const Center(
                  child: SpinKitFoldingCube(
                      color: kHeaderGradEnd, size: 35),
                );
              }
              if (state is StockUpdateLoaded) {
                return _StockUpdateBody(
                  state:       state,
                  onPickImage: (src) => _pickImage(
                      src,
                      state.saleOrderId,
                      state.statusName),
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
          Text('Stock Update',
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
        // Refresh button
        Padding(
          padding: const EdgeInsets.only(
              right: 12, top: 10, bottom: 10),
          child: Container(
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
                onTap: () => context
                    .read<StockUpdateBloc>()
                    .add(StockUpdateClearRequested()),
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.refresh_rounded,
                      color: Colors.white, size: 20),
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
class _StockUpdateBody extends StatelessWidget {
  final StockUpdateLoaded state;
  final Future<void> Function(ImageSource) onPickImage;

  const _StockUpdateBody(
      {required this.state, required this.onPickImage});

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
            // ── Row 1: Packages + ScnPkg + SCAN ────────
            _PackagesScanRow(
                state: state, isTablet: isTablet),
            const SizedBox(height: 12),

            // ── Warehouse search ─────────────────────
            _WarehouseField(
                state: state, isTablet: isTablet),
            const SizedBox(height: 12),

            // ── Tablet: status + jobno + save in one row
            // Mobile: stacked ───────────────────────
            isTablet
                ? _TabletStatusRow(state: state)
                : _MobileStatusSection(state: state),
            const SizedBox(height: 12),

            // ── Scanned stock list ───────────────────
            _ScannedList(
                state: state, isTablet: isTablet),
            const SizedBox(height: 12),

            // ── Image upload row ─────────────────────
            _ImageUploadRow(
              state:       state,
              isTablet:    isTablet,
              onPickImage: onPickImage,
            ),
            const SizedBox(height: 10),

            // ── Image grid ───────────────────────────
            _ImageGrid(
                state: state, isTablet: isTablet),
          ],
        );
      },
    );
  }
}

// ─── Packages + ScnPkg + SCAN button ─────────────────────────────────────────
class _PackagesScanRow extends StatelessWidget {
  final StockUpdateLoaded state;
  final bool isTablet;
  const _PackagesScanRow(
      {required this.state, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kCardBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
              color: kHeaderGradStart.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Packages label + total
          Expanded(
            flex: 4,
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.lato(
                    color: kTextDark,
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet
                        ? objfun.FontMedium + 1
                        : objfun.FontMedium),
                children: [
                  const TextSpan(text: 'Packages: '),
                  TextSpan(
                    text: state.totalPkg.toString(),
                    style: const TextStyle(
                        color: kHeaderGradStart),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Scanned count
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: state.scnPkg > 0
                  ? kAccentRed.withOpacity(0.10)
                  : kDetailBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              state.scnPkg.toString(),
              style: GoogleFonts.lato(
                color: state.scnPkg > 0
                    ? kAccentRed
                    : kTextMuted,
                fontWeight: FontWeight.w700,
                fontSize: isTablet
                    ? objfun.FontMedium + 1
                    : objfun.FontMedium,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('SCAN',
              style: GoogleFonts.lato(
                  color: kTextMid,
                  fontWeight: FontWeight.w600,
                  fontSize: isTablet
                      ? objfun.FontMedium + 1
                      : objfun.FontMedium)),
          const SizedBox(width: 8),
          // Scan button
          _ScanButton(isTablet: isTablet),
        ],
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  final bool isTablet;
  const _ScanButton({required this.isTablet});

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
          onTap: () => context
              .read<StockUpdateBloc>()
              .add(StockUpdateBarcodeScanRequested()),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 11 : 9),
            child: Icon(
              Icons.center_focus_weak_rounded,
              color: Colors.white,
              size: isTablet ? 26 : 22,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Warehouse Field ─────────────────────────────────────────────────────────
class _WarehouseField extends StatelessWidget {
  final StockUpdateLoaded state;
  final bool isTablet;
  const _WarehouseField(
      {required this.state, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (state.warehouseName.isNotEmpty) {
          context
              .read<StockUpdateBloc>()
              .add(StockUpdateWarehouseCleared());
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const WareHouse(
                Searchby: 1,
                SearchId: 0,
              )),
        ).then((_) {
          final sel = objfun.SelectWareHouseList;
          if (sel.Id != 0) {
            context.read<StockUpdateBloc>().add(
                StockUpdateWarehouseSelected(
                    warehouseId:   sel.Id,
                    warehouseName: sel.PortName));
            objfun.SelectWareHouseList =
                WareHouseModel.Empty();
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
            const Icon(Icons.warehouse_outlined,
                size: 20, color: kHeaderGradEnd),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                state.warehouseName.isEmpty
                    ? 'Select Location'
                    : state.warehouseName,
                style: GoogleFonts.lato(
                  color: state.warehouseName.isEmpty
                      ? kTextMuted
                      : kTextDark,
                  fontWeight: state.warehouseName.isEmpty
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
              state.warehouseName.isNotEmpty
                  ? Icons.close_rounded
                  : Icons.search_rounded,
              size: 18,
              color: kHeaderGradEnd,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Mobile: Status + JobNo + Save stacked ───────────────────────────────────
class _MobileStatusSection extends StatelessWidget {
  final StockUpdateLoaded state;
  const _MobileStatusSection({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _StatusField(
                    state: state, isTablet: false)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '  ${state.jobNo}',
                style: GoogleFonts.lato(
                    color: kTextDark,
                    fontWeight: FontWeight.w700,
                    fontSize: objfun.FontMedium),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _SaveButton(state: state, isTablet: false),
          ],
        ),
      ],
    );
  }
}

// ─── Tablet: Status + JobNo + Save in one row ─────────────────────────────────
class _TabletStatusRow extends StatelessWidget {
  final StockUpdateLoaded state;
  const _TabletStatusRow({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            flex: 3,
            child: _StatusField(
                state: state, isTablet: true)),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            '  ${state.jobNo}',
            style: GoogleFonts.lato(
                color: kTextDark,
                fontWeight: FontWeight.w700,
                fontSize: objfun.FontMedium + 1),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        _SaveButton(state: state, isTablet: true),
      ],
    );
  }
}

// ─── Status Search Field ──────────────────────────────────────────────────────
class _StatusField extends StatelessWidget {
  final StockUpdateLoaded state;
  final bool isTablet;
  const _StatusField(
      {required this.state, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (state.statusName.isNotEmpty) {
          context
              .read<StockUpdateBloc>()
              .add(StockUpdateStatusCleared());
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => JobAllStatus(
                Searchby: 1,
                SearchId: 0,
                JobTypeId: state.jobId,
              )),
        ).then((_) {
          final sel = objfun.SelectAllStatusList;
          if (sel.Status != 0) {
            context.read<StockUpdateBloc>().add(
                StockUpdateStatusSelected(
                    statusId:   sel.Status,
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
              size: 18,
              color: kHeaderGradEnd,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Save Button (update icon) ────────────────────────────────────────────────
class _SaveButton extends StatelessWidget {
  final StockUpdateLoaded state;
  final bool isTablet;
  const _SaveButton(
      {required this.state, required this.isTablet});

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
          onTap: () async {
            if (state.totalPkg != 0 &&
                state.totalPkg == state.scnPkg) {
              if (state.stockId != 0) {
                final ok = await objfun.ConfirmationMsgYesNo(
                    context,
                    'Do you want to update the Status ?');
                if (ok == true) {
                  context
                      .read<StockUpdateBloc>()
                      .add(StockUpdateSaveRequested());
                }
              } else {
                await objfun.ConfirmationOK(
                    'Invalid Details', context);
              }
            } else {
              await objfun.ConfirmationOK(
                  'Stock Mismatch', context);
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 13 : 11),
            child: Icon(
              Icons.save_as_outlined,
              color: Colors.white,
              size: isTablet ? 22 : 19,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Scanned Stock List ───────────────────────────────────────────────────────
class _ScannedList extends StatelessWidget {
  final StockUpdateLoaded state;
  final bool isTablet;
  const _ScannedList(
      {required this.state, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    if (state.stockNoList.isEmpty) {
      return Container(
        height: isTablet ? 140 : 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border:
          Border.all(color: kCardBorder, width: 0.5),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_scanner_rounded,
                  size: isTablet ? 36 : 28,
                  color: kTextMuted),
              const SizedBox(height: 8),
              Text('No Stock Scanned',
                  style: GoogleFonts.lato(
                      color: kTextMuted, fontSize: 13)),
            ],
          ),
        ),
      );
    }

    return Container(
      constraints: BoxConstraints(
          maxHeight: isTablet ? 240 : 180),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kCardBorder, width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.all(6),
          itemCount: state.stockNoList.length,
          separatorBuilder: (_, __) =>
          const Divider(height: 1, color: kDetailBg),
          itemBuilder: (ctx, i) => _ScannedItemRow(
            barcode:  state.stockNoList[i].toString(),
            index:    i,
            isTablet: isTablet,
          ),
        ),
      ),
    );
  }
}

class _ScannedItemRow extends StatelessWidget {
  final String barcode;
  final int    index;
  final bool   isTablet;
  const _ScannedItemRow({
    required this.barcode,
    required this.index,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Container(
            width: isTablet ? 26 : 22,
            height: isTablet ? 26 : 22,
            decoration: BoxDecoration(
              color: kChipBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: GoogleFonts.lato(
                    color: kHeaderGradStart,
                    fontWeight: FontWeight.w700,
                    fontSize: 10),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              barcode,
              style: GoogleFonts.lato(
                color: kTextDark,
                fontWeight: FontWeight.w600,
                fontSize: isTablet
                    ? objfun.FontCardText + 1
                    : objfun.FontCardText,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            onTap: () => context
                .read<StockUpdateBloc>()
                .add(StockUpdateScannedItemDeleted(index)),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: kAccentRed.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                size: isTablet ? 20 : 17,
                color: kAccentRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Image Upload Row ─────────────────────────────────────────────────────────
class _ImageUploadRow extends StatelessWidget {
  final StockUpdateLoaded state;
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
                .read<StockUpdateBloc>()
                .add(StockUpdateImageUploadToggled(
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
  final StockUpdateLoaded state;
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
                      .read<StockUpdateBloc>()
                      .add(StockUpdateImageDeleted(i));
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