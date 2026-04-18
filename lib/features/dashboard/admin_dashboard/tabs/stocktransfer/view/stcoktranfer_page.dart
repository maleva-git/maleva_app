import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/MasterSearch/WareHouseList.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/menu/menulist.dart';

import '../bloc/stock_transfer_bloc.dart';



// ─── Design Tokens ───────────────────────────────────────────────────────────
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

const double _kTablet = 600.0; // breakpoint

// ═════════════════════════════════════════════════════════════════════════════
// Entry point
// ═════════════════════════════════════════════════════════════════════════════
class StockTransferPage extends StatelessWidget {
  const StockTransferPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StockTransferBloc()..add(const StockTransferInitialized()),
      child: const _StockTransferView(),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Root view — BlocConsumer + Scaffold
// ═════════════════════════════════════════════════════════════════════════════
class _StockTransferView extends StatelessWidget {
  const _StockTransferView();

  @override
  Widget build(BuildContext context) {
    final userName = objfun.storagenew.getString('Username') ?? '';

    return BlocConsumer<StockTransferBloc, StockTransferState>(
      listenWhen: (_, curr) =>
      (curr is StockTransferLoaded && curr.message != null) ||
          curr is StockTransferInitError,
      listener: (context, state) async {
        if (state is StockTransferInitError) {
          _snack(context, state.message, MessageType.error);
          return;
        }
        if (state is StockTransferLoaded && state.message != null) {
          final msg = state.message!;
          if (msg.type == MessageType.success) {
            await _okDialog(context, msg.text);
          } else {
            _snack(context, msg.text, msg.type);
          }
          if (context.mounted) {
            context.read<StockTransferBloc>().add(const StockTransferMessageDismissed());
          }
        }
      },
      builder: (context, state) {
        return PopScope(
          canPop: true,
          child: Scaffold(
            backgroundColor: kPageBg,
            drawer: const Menulist(),
            appBar: _buildAppBar(context, userName),
            body: _buildBody(context, state),
          ),
        );
      },
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context, String userName) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kHeaderGradStart, kHeaderGradEnd],
          ),
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Stock Transfer Update',
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
              Text(userName,
                  style: GoogleFonts.poppins(
                      color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w400)),
            ],
          ),
          actions: const [SizedBox(width: 12)],
        ),
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _buildBody(BuildContext context, StockTransferState state) {
    if (state is StockTransferInitialLoading) {
      return const Center(
          child: SpinKitFoldingCube(color: kHeaderGradEnd, size: 35));
    }
    if (state is StockTransferInitError) {
      return Center(
          child: Text(state.message,
              style: GoogleFonts.poppins(color: kAccentRed),
              textAlign: TextAlign.center));
    }
    if (state is StockTransferLoaded) {
      return Stack(children: [
        // ── LayoutBuilder picks mobile or tablet ─────────────────────────
        LayoutBuilder(
          builder: (context, constraints) => constraints.maxWidth >= _kTablet
              ? _TabletLayout(state: state)
              : _MobileLayout(state: state),
        ),
        // ── Busy overlay ─────────────────────────────────────────────────
        if (state.isBusy)
          Container(
            color: Colors.black26,
            child: const Center(
                child: SpinKitFoldingCube(color: kHeaderGradEnd, size: 35)),
          ),
      ]);
    }
    return const SizedBox.shrink();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  static void _snack(BuildContext ctx, String msg, MessageType type) {
    final color = type == MessageType.error
        ? kAccentRed
        : type == MessageType.success
        ? const Color(0xFF2E7D32)
        : kHeaderGradEnd;
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.poppins(color: Colors.white)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(14),
    ));
  }

  static Future<void> _okDialog(BuildContext ctx, String msg) async {
    await showDialog<void>(
      context: ctx,
      builder: (dlg) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Success',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: kTextDark)),
        content: Text(msg,
            style: GoogleFonts.poppins(color: kTextMid)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlg).pop(),
            child: Text('OK',
                style: GoogleFonts.poppins(
                    color: kHeaderGradEnd, fontWeight: FontWeight.w600)),
          )
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// MOBILE LAYOUT — single column
// ═════════════════════════════════════════════════════════════════════════════
class _MobileLayout extends StatelessWidget {
  final StockTransferLoaded state;
  const _MobileLayout({required this.state});

  @override
  Widget build(BuildContext context) {
    final d = state.data;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
        child: Column(children: [
          // Stats + Scan button row
          _StatsBar(data: d, isTablet: false),
          const SizedBox(height: 10),
          // Warehouse + job no + Save row
          _ActionBar(data: d, isTablet: false),
          const SizedBox(height: 14),
          // Scanned list
          Expanded(child: _ScannedList(data: d, isTablet: false)),
        ]),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TABLET LAYOUT — two column
// ═════════════════════════════════════════════════════════════════════════════
class _TabletLayout extends StatelessWidget {
  final StockTransferLoaded state;
  const _TabletLayout({required this.state});

  @override
  Widget build(BuildContext context) {
    final d = state.data;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left panel — controls
            SizedBox(
              width: 330,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _JobCard(data: d),
                  const SizedBox(height: 16),
                  _WareHouseField(data: d),
                  const SizedBox(height: 16),
                  _StatsBar(data: d, isTablet: true),
                  const SizedBox(height: 16),
                  _ActionBar(data: d, isTablet: true),
                ],
              ),
            ),
            const SizedBox(width: 20),
            // Right panel — list
            Expanded(child: _ScannedList(data: d, isTablet: true)),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS — isTablet flag adjusts padding / size / direction
// ═════════════════════════════════════════════════════════════════════════════

// ── Stats bar (Total | Scanned | PortName | ScanButton) ───────────────────
class _StatsBar extends StatelessWidget {
  final StockTransferData data;
  final bool isTablet;
  const _StatsBar({required this.data, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StockTransferBloc>();

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 14 : 12,
          vertical: isTablet ? 12 : 10),
      decoration: BoxDecoration(
        color: kDetailBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kCardBorder),
      ),
      child: Row(children: [
        _NumBadge(label: 'Total', value: data.totalPkg, color: kTextDark),
        const SizedBox(width: 10),
        _NumBadge(label: 'Scanned', value: data.scnPkg, color: kAccentRed),
        const SizedBox(width: 10),
        if (!isTablet)
          Expanded(
            child: Text(
              data.portName.isEmpty ? '—' : data.portName,
              style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w600, color: kTextDark),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        if (!isTablet) const SizedBox(width: 8),
        if (isTablet)
          Expanded(
            child: _progressBar(data),
          ),
        if (isTablet) const SizedBox(width: 10),
        // Scan button — on mobile it's compact, tablet has label
        ElevatedButton.icon(
          onPressed: () => bloc.add(const StockTransferBarcodeScanned()),
          style: ElevatedButton.styleFrom(
            backgroundColor: kHeaderGradEnd,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 14 : 10,
                vertical: isTablet ? 12 : 10),
            elevation: 4,
          ),
          icon: const Icon(Icons.center_focus_weak,
              color: Colors.white, size: 18),
          label: isTablet
              ? Text('SCAN',
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700))
              : const SizedBox.shrink(),
        ),
      ]),
    );
  }

  Widget _progressBar(StockTransferData d) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        d.portName.isEmpty ? '—' : d.portName,
        style: GoogleFonts.poppins(
            fontSize: 11, fontWeight: FontWeight.w600, color: kTextDark),
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 4),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: d.totalPkg > 0 ? d.scnPkg / d.totalPkg : 0,
          backgroundColor: kCardBorder,
          valueColor: const AlwaysStoppedAnimation<Color>(kHeaderGradEnd),
          minHeight: 6,
        ),
      ),
    ]);
  }
}

class _NumBadge extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _NumBadge(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(value.toString(),
          style: GoogleFonts.poppins(
              fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      Text(label,
          style: GoogleFonts.poppins(fontSize: 10, color: kTextMuted)),
    ]);
  }
}

// ── Action bar: warehouse (mobile only) + job no + save/clear ─────────────
class _ActionBar extends StatelessWidget {
  final StockTransferData data;
  final bool isTablet;
  const _ActionBar({required this.data, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StockTransferBloc>();

    if (isTablet) {
      // Tablet: two full-width stacked buttons (warehouse handled by _WareHouseField separately)
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _saveBtn(context, bloc, isTablet: true),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => bloc.add(const StockTransferCleared()),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: kCardBorder, width: 1.5),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          icon: const Icon(Icons.refresh_rounded, color: kTextMid, size: 18),
          label: Text('CLEAR ALL',
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: kTextMid)),
        ),
      ]);
    }

    // Mobile: warehouse field + job no chip + save icon button in one row
    return Row(children: [
      Expanded(flex: 5, child: _WareHouseField(data: data)),
      const SizedBox(width: 8),
      if (data.jobNo.isNotEmpty)
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
                color: kChipBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kCardBorder)),
            child: Text(data.jobNo,
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: kTextDark),
                overflow: TextOverflow.ellipsis),
          ),
        ),
      const SizedBox(width: 8),
      _saveBtn(context, bloc, isTablet: false),
    ]);
  }

  Widget _saveBtn(BuildContext context, StockTransferBloc bloc,
      {required bool isTablet}) {
    return ElevatedButton(
      onPressed: () => _handleSave(context, data, bloc),
      style: ElevatedButton.styleFrom(
        backgroundColor: kHeaderGradStart,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 0 : 14,
            vertical: isTablet ? 14 : 12),
        elevation: 4,
      ),
      child: isTablet
          ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.swap_horiz_rounded,
            color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Text('TRANSFER STOCK',
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.6)),
      ])
          : const Icon(Icons.save_as_outlined, color: Colors.white, size: 20),
    );
  }

  Future<void> _handleSave(BuildContext context, StockTransferData data,
      StockTransferBloc bloc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dlg) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Confirm Transfer',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: kTextDark)),
        content: Text(
            'Transfer ${data.scnPkg} package(s) to ${data.selectedWareHouseName}?',
            style: GoogleFonts.poppins(color: kTextMid)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlg).pop(false),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: kTextMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: kHeaderGradEnd,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            onPressed: () => Navigator.of(dlg).pop(true),
            child: Text('Confirm',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      bloc.add(const StockTransferUpdateRequested());
    }
  }
}

// ── Warehouse field (used in both layouts) ─────────────────────────────────
class _WareHouseField extends StatelessWidget {
  final StockTransferData data;
  const _WareHouseField({required this.data});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StockTransferBloc>();
    final hasValue = data.selectedWareHouseName.isNotEmpty;

    return GestureDetector(
      onTap: () {
        if (!hasValue) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const WareHouse(Searchby: 1, SearchId: 0)),
          ).then((_) {
            final sel = objfun.SelectWareHouseList;
            if (sel.Id != 0) {
              bloc.add(StockTransferWareHouseSelected(
                  portName: sel.PortName ?? '', wareHouseId: sel.Id));
              objfun.SelectWareHouseList = WareHouseModel.Empty();
            }
          });
        } else {
          bloc.add(const StockTransferWareHouseCleared());
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: hasValue ? kHeaderGradEnd : kCardBorder, width: 1.5),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(children: [
          Icon(Icons.warehouse_outlined,
              color: hasValue ? kHeaderGradEnd : kTextMuted, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hasValue ? data.selectedWareHouseName : 'Select WareHouse',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                color: hasValue ? kTextDark : kTextMuted,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(hasValue ? Icons.close_rounded : Icons.search_rounded,
              color: hasValue ? kAccentRed : kTextMid, size: 20),
        ]),
      ),
    );
  }
}

// ── Job summary card — tablet only ────────────────────────────────────────
class _JobCard extends StatelessWidget {
  final StockTransferData data;
  const _JobCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kHeaderGradStart, kHeaderGradEnd],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: kHeaderGradStart.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          data.jobNo.isEmpty ? 'No Job Loaded' : data.jobNo,
          style: GoogleFonts.poppins(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        if (data.portName.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(data.portName,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: Colors.white70)),
        ],
        const SizedBox(height: 14),
        Row(children: [
          _GlassStat(label: 'Total', value: data.totalPkg),
          const SizedBox(width: 8),
          _GlassStat(label: 'Scanned', value: data.scnPkg, highlight: true),
          const SizedBox(width: 8),
          _GlassStat(
              label: 'Remaining',
              value: (data.totalPkg - data.scnPkg).clamp(0, 9999)),
        ]),
      ]),
    );
  }
}

class _GlassStat extends StatelessWidget {
  final String label;
  final int value;
  final bool highlight;
  const _GlassStat(
      {required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: highlight
              ? Colors.white.withOpacity(0.25)
              : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(children: [
          Text(value.toString(),
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 10, color: Colors.white70)),
        ]),
      ),
    );
  }
}

// ── Scanned items list ────────────────────────────────────────────────────
class _ScannedList extends StatelessWidget {
  final StockTransferData data;
  final bool isTablet;
  const _ScannedList({required this.data, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    if (data.stockNoList.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.qr_code_scanner,
              size: isTablet ? 72 : 56, color: kCardBorder),
          const SizedBox(height: 12),
          Text('No Stock Scanned',
              style: GoogleFonts.poppins(
                  color: kTextMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          if (isTablet) ...[
            const SizedBox(height: 6),
            Text('Tap SCAN to start',
                style: GoogleFonts.poppins(
                    color: kTextMuted.withOpacity(0.6), fontSize: 12)),
          ],
        ]),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Header — tablets get a count chip + progress bar
      if (isTablet) ...[
        Row(children: [
          Text('SCANNED PACKAGES',
              style: GoogleFonts.poppins(
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                  color: kTextMuted)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
                color: kChipBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kCardBorder)),
            child: Text('${data.scnPkg} / ${data.totalPkg}',
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: kHeaderGradEnd)),
          ),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value:
            data.totalPkg > 0 ? data.scnPkg / data.totalPkg : 0,
            backgroundColor: kCardBorder,
            valueColor:
            const AlwaysStoppedAnimation<Color>(kHeaderGradEnd),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 12),
      ],
      Expanded(
        child: ListView.separated(
          itemCount: data.stockNoList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) => _ItemCard(
            barcode: data.stockNoList[i],
            index: i,
            serialNo: i + 1,
            isTablet: isTablet,
          ),
        ),
      ),
    ]);
  }
}

class _ItemCard extends StatelessWidget {
  final String barcode;
  final int index;
  final int serialNo;
  final bool isTablet;
  const _ItemCard(
      {required this.barcode,
        required this.index,
        required this.serialNo,
        required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
        border: Border.all(color: kCardBorder),
        boxShadow: [
          BoxShadow(
              color: kHeaderGradStart.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 16 : 12, vertical: isTablet ? 6 : 2),
        leading: Container(
          width: isTablet ? 36 : 30,
          height: isTablet ? 36 : 30,
          decoration: BoxDecoration(
              color: kChipBg,
              borderRadius: BorderRadius.circular(isTablet ? 8 : 6)),
          alignment: Alignment.center,
          child: Text(serialNo.toString(),
              style: GoogleFonts.poppins(
                  fontSize: isTablet ? 13 : 11,
                  fontWeight: FontWeight.bold,
                  color: kHeaderGradEnd)),
        ),
        title: Text(barcode,
            style: GoogleFonts.poppins(
                fontSize: isTablet ? 14 : 13,
                fontWeight: FontWeight.w600,
                color: kTextDark),
            overflow: TextOverflow.ellipsis),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded,
              color: kAccentRed, size: 22),
          onPressed: () => context
              .read<StockTransferBloc>()
              .add(StockTransferItemRemoved(index)),
        ),
      ),
    );
  }
}