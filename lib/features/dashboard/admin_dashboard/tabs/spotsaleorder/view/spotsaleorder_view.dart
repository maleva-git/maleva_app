import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import '../bloc/spotsaleorder_bloc.dart';
import '../bloc/spotsaleorder_event.dart';
import '../bloc/spotsaleorder_state.dart';



// ── Entry Point ───────────────────────────────────────────────────────────────
class SpotSaleViewPage extends StatelessWidget {
  final DateTime? fromDate;
  final DateTime? toDate;
  const SpotSaleViewPage({super.key, this.fromDate, this.toDate});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SpotSaleBloc.view(context, fromDate: fromDate, toDate: toDate),
      child: const _SpotSaleViewBody(),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────
class _SpotSaleViewBody extends StatelessWidget {
  const _SpotSaleViewBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: colour.kPrimary,
        foregroundColor: colour.kWhite,
        elevation: 0,
        title: Text("Spot Sale Entries",
            style: GoogleFonts.lato(
                fontWeight: FontWeight.bold, color: colour.kWhite)),
        centerTitle: true,
      ),
      body: BlocConsumer<SpotSaleBloc, SpotSaleState>(
        listener: (context, state) {
          if (state is SpotSaleViewError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ));
          }
        },
        builder: (context, state) {
          final fromDate  = _from(state);
          final toDate    = _to(state);
          final records   = state is SpotSaleViewState ? state.records : <dynamic>[];
          final isLoading = state is SpotSaleViewState ? state.isLoading : false;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [

              // ── Date Filter ────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colour.kAccent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: colour.kPrimaryLight.withOpacity(0.3)),
                ),
                child: Column(children: [
                  Row(children: [
                    Expanded(
                      child: _DateTile(
                        label: "From Date",
                        value: DateFormat('yyyy-MM-dd').format(fromDate),
                        onTap: () async {
                          final p = await _pickDate(context, fromDate);
                          if (p != null) {
                            context
                                .read<SpotSaleBloc>()
                                .add(SelectViewFromDateEvent(p));
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DateTile(
                        label: "To Date",
                        value: DateFormat('yyyy-MM-dd').format(toDate),
                        onTap: () async {
                          final p = await _pickDate(context, toDate);
                          if (p != null) {
                            context
                                .read<SpotSaleBloc>()
                                .add(SelectViewToDateEvent(p));
                          }
                        },
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () => context
                          .read<SpotSaleBloc>()
                          .add(const LoadSpotSaleViewEvent()),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: colour.kPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: Text("Search",
                          style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colour.kWhite)),
                    ),
                  ),
                ]),
              ),

              const SizedBox(height: 16),

              // ── Record count strip ─────────────────────────────
              if (!isLoading && records.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colour.kAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text("${records.length} records",
                          style: GoogleFonts.lato(
                              color: colour.kPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ),
                  ]),
                ),

              // ── List ───────────────────────────────────────────
              Expanded(child: _buildContent(context, isLoading, records)),
            ]),
          );
        },
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, bool isLoading, List<dynamic> records) {
    if (isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: colour.kPrimary));
    }
    if (records.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.receipt_long_outlined,
              size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text("No Records Found",
              style: GoogleFonts.lato(fontSize: 18, color: Colors.grey)),
        ]),
      );
    }
    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, i) => _SpotSaleCard(
        item: records[i],
        context: context,
      ),
    );
  }

  Future<DateTime?> _pickDate(BuildContext context, DateTime initial) {
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme:
            const ColorScheme.light(primary: colour.kPrimary)),
        child: child!,
      ),
    );
  }

  DateTime _from(SpotSaleState s) {
    if (s is SpotSaleViewState) return s.fromDate;
    if (s is SpotSaleViewError) return s.fromDate;
    return DateTime.now();
  }

  DateTime _to(SpotSaleState s) {
    if (s is SpotSaleViewState) return s.toDate;
    if (s is SpotSaleViewError) return s.toDate;
    return DateTime.now();
  }
}

// ── Spot Sale Card ────────────────────────────────────────────────────────────
class _SpotSaleCard extends StatelessWidget {
  final dynamic item;
  final BuildContext context;
  const _SpotSaleCard({required this.item, required this.context});

  @override
  Widget build(BuildContext ctx) {
    final hasDoc = item['DocumentPath'] != null &&
        item['DocumentPath'].toString().isNotEmpty;

    return GestureDetector(
      onTap: () => _navigate(ctx),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: colour.kWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colour.kAccent, width: 1.5),
          boxShadow: [
            BoxShadow(
                color: colour.kPrimary.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Column(children: [

          // ── Blue header ─────────────────────────────────────────
          Container(
            width: double.infinity,
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: colour.kPrimary,
              borderRadius:
              BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(children: [
              const Icon(Icons.local_shipping_rounded,
                  color: colour.kWhite, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item['SVehicleName'] ?? '-',
                  style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colour.kWhite),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colour.kWhite.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item['StatusName'] ?? '-',
                  style: GoogleFonts.lato(
                      color: colour.kWhite,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ]),
          ),

          // ── Info grid ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              Row(children: [
                Expanded(
                    child: _infoCell(Icons.confirmation_number_rounded,
                        "AWB No", item['AWBNo'] ?? '-')),
                Expanded(
                    child: _infoCell(Icons.inventory_2_rounded,
                        "Qty", item['Quantity']?.toString() ?? '-')),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                    child: _infoCell(Icons.scale_rounded,
                        "Weight", item['TotalWeight']?.toString() ?? '-')),
                Expanded(
                    child: _infoCell(
                        Icons.anchor_rounded, "Port", item['Port'] ?? '-')),
              ]),
            ]),
          ),

          // ── Document Image ──────────────────────────────────────
          if (hasDoc)
            GestureDetector(
              onTap: () => showDialog(
                context: ctx,
                builder: (_) => _ImagePreviewDialog(
                    imageUrl: objfun.port + item['DocumentPath']),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16)),
                child: Image.network(
                  objfun.port + item['DocumentPath'],
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
        ]),
      ),
    );
  }

  Widget _infoCell(IconData icon, String label, String value) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 14, color: colour.kPrimaryLight),
      const SizedBox(width: 6),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: GoogleFonts.lato(fontSize: 10, color: Colors.grey[400])),
          Text(value,
              style: GoogleFonts.lato(
                  fontSize: 13,
                  color: colour.kPrimaryDark,
                  fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis),
        ]),
      ),
    ]);
  }

  void _navigate(BuildContext ctx) {
    final id     = item['Id'] as int? ?? 0;
    final rules  = objfun.storagenew.getString('RulesType') ?? '';

    // Keep your existing navigation logic
    if (rules == "ADMIN") {
      // Navigator.push(ctx, MaterialPageRoute(
      //   builder: (_) => AdminDashboard(editId: id, initialTabIndex: 22)));
    } else if (rules == "ADMIN2") {
      // Navigator.push(ctx, MaterialPageRoute(
      //   builder: (_) => Admin2Dashboard(editId: id, initialTabIndex: 9)));
    } else {
      // Navigator.push(ctx, MaterialPageRoute(
      //   builder: (_) => BoardingDashboard(editId: id, viewId: 2)));
    }
  }
}

// ── Date Tile ─────────────────────────────────────────────────────────────────
class _DateTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _DateTile(
      {required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: colour.kWhite,
          borderRadius: BorderRadius.circular(10),
          border:
          Border.all(color: colour.kPrimaryLight.withOpacity(0.35)),
        ),
        child: Row(children: [
          const Icon(Icons.date_range_rounded,
              color: colour.kPrimary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.lato(
                          fontSize: 10, color: Colors.grey[500])),
                  Text(value,
                      style: GoogleFonts.lato(
                          fontSize: 13,
                          color: colour.kPrimaryDark,
                          fontWeight: FontWeight.w600)),
                ]),
          ),
        ]),
      ),
    );
  }
}

// ── Image Preview Dialog ──────────────────────────────────────────────────────
class _ImagePreviewDialog extends StatelessWidget {
  final String imageUrl;
  const _ImagePreviewDialog({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black87,
      insetPadding: const EdgeInsets.all(10),
      child: Stack(children: [
        InteractiveViewer(
            child: Image.network(imageUrl, fit: BoxFit.contain)),
        Positioned(
          top: 10, right: 10,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.close, color: colour.kWhite, size: 20),
            ),
          ),
        ),
        Positioned(
          bottom: 20, right: 20,
          child: FloatingActionButton(
            backgroundColor: colour.kWhite,
            child: const Icon(Icons.share, color: colour.kPrimaryDark),
            onPressed: () => _shareImage(imageUrl, context),
          ),
        ),
      ]),
    );
  }

  Future<void> _shareImage(String url, BuildContext context) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final path =
          '${tempDir.path}/spot_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final response = await http.get(Uri.parse(url));
      await File(path).writeAsBytes(response.bodyBytes);
      await Share.shareXFiles([XFile(path)], text: "Spot Sale Document");
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Sharing failed: $e")));
    }
  }
}