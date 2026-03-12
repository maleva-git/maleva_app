import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import '../bloc/spareparts_bloc.dart';
import '../bloc/spareparts_event.dart';
import '../bloc/spareparts_state.dart';


// ── Color Palette ─────────────────────────────────────────────────────────────
const Color kPrimary      = Color(0xFF1555F3);
const Color kPrimaryDark  = Color(0xFF0D3DB5);
const Color kPrimaryLight = Color(0xFF4D7EF7);
const Color kAccent       = Color(0xFFE8EEFF);
const Color kWhite        = Colors.white;

// ── Entry Point ───────────────────────────────────────────────────────────────
class SparePartsView extends StatelessWidget {
  final DateTime? fromDate;
  final DateTime? toDate;
  const SparePartsView({super.key, this.fromDate, this.toDate});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SparePartsBloc.view(context,
          fromDate: fromDate, toDate: toDate),
      child: const _SparePartsViewBody(),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────
class _SparePartsViewBody extends StatelessWidget {
  const _SparePartsViewBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: kPrimary,
        foregroundColor: kWhite,
        elevation: 0,
        title: Text("Spare Parts Entries",
            style: GoogleFonts.lato(
                fontWeight: FontWeight.bold, color: kWhite)),
        centerTitle: true,
      ),
      body: BlocConsumer<SparePartsBloc, SparePartsState>(
        listener: (context, state) {
          if (state is SparePartsViewError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ));
          }
        },
        builder: (context, state) {
          // Resolve dates from either state type
          final fromDate = _getFrom(state);
          final toDate   = _getTo(state);
          final records  = state is SparePartsViewState ? state.records : <dynamic>[];
          final isLoading = state is SparePartsViewState ? state.isLoading : false;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [

              // ── Date Filter ───────────────────────────────────
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kAccent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: kPrimaryLight.withOpacity(0.3)),
                ),
                child: Column(children: [
                  Row(children: [
                    Expanded(
                      child: _DateTile(
                        label: "From Date",
                        value: DateFormat('yyyy-MM-dd').format(fromDate),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: fromDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            builder: (ctx, child) => Theme(
                              data: Theme.of(ctx).copyWith(
                                  colorScheme: const ColorScheme.light(
                                      primary: kPrimary)),
                              child: child!,
                            ),
                          );
                          if (picked != null) {
                            context.read<SparePartsBloc>().add(
                                SelectSparePartsFromDateEvent(picked));
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
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: toDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            builder: (ctx, child) => Theme(
                              data: Theme.of(ctx).copyWith(
                                  colorScheme: const ColorScheme.light(
                                      primary: kPrimary)),
                              child: child!,
                            ),
                          );
                          if (picked != null) {
                            context.read<SparePartsBloc>().add(
                                SelectSparePartsToDateEvent(picked));
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
                          .read<SparePartsBloc>()
                          .add(const LoadSparePartsViewEvent()),
                      style: ElevatedButton.styleFrom(
                        padding:
                        const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: kPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: Text("Search",
                          style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: kWhite)),
                    ),
                  ),
                ]),
              ),

              const SizedBox(height: 16),

              // ── List / Loading / Empty ────────────────────────
              Expanded(child: _buildContent(isLoading, records)),
            ]),
          );
        },
      ),
    );
  }

  Widget _buildContent(bool isLoading, List<dynamic> records) {
    if (isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: kPrimary));
    }
    if (records.isEmpty) {
      return Center(
        child: Text("No Records Found",
            style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey)),
      );
    }
    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, i) => _SparePartsCard(item: records[i]),
    );
  }

  DateTime _getFrom(SparePartsState s) {
    if (s is SparePartsViewState) return s.fromDate;
    if (s is SparePartsViewError) return s.fromDate;
    return DateTime.now();
  }

  DateTime _getTo(SparePartsState s) {
    if (s is SparePartsViewState) return s.toDate;
    if (s is SparePartsViewError) return s.toDate;
    return DateTime.now();
  }
}

// ── Spare Parts Card ──────────────────────────────────────────────────────────
class _SparePartsCard extends StatelessWidget {
  final dynamic item;
  const _SparePartsCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final hasDoc = item['DocumentPath'] != null &&
        item['DocumentPath'].toString().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kAccent, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: kPrimary.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Header — Truck + Date
          Row(children: [
            Container(
              width: 44, height: 44,
              decoration:
              const BoxDecoration(color: kAccent, shape: BoxShape.circle),
              child: const Icon(Icons.local_shipping_rounded,
                  color: kPrimary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${item['TruckName'] ?? '-'}",
                        style: GoogleFonts.lato(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryDark)),
                    Text("${item['EntryDate'] ?? '-'}",
                        style: GoogleFonts.lato(
                            fontSize: 13, color: Colors.grey[500])),
                  ]),
            ),
            // Amount badge
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: kAccent,
                  borderRadius: BorderRadius.circular(10)),
              child: Text("₹${item['Amount'] ?? '-'}",
                  style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      color: kPrimary,
                      fontSize: 14)),
            ),
          ]),

          Divider(color: kAccent, thickness: 1.5, height: 20),

          // Spare Parts description
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.build_rounded, color: kPrimaryLight, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item['SpareParts'] ?? '-',
                style: GoogleFonts.lato(
                    fontSize: 14, color: kPrimaryDark, height: 1.4),
              ),
            ),
          ]),

          // Document image
          if (hasDoc) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => showDialog(
                context: context,
                builder: (_) => _ImagePreviewDialog(
                    imageUrl: objfun.port + item['DocumentPath']),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  objfun.port + item['DocumentPath'],
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 80,
                    color: kAccent,
                    child: const Center(
                        child: Icon(Icons.broken_image_rounded,
                            color: kPrimaryLight)),
                  ),
                ),
              ),
            ),
          ],
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
              child: const Icon(Icons.close, color: kWhite, size: 20),
            ),
          ),
        ),
        Positioned(
          bottom: 20, right: 20,
          child: FloatingActionButton(
            backgroundColor: kWhite,
            child: const Icon(Icons.share, color: kPrimaryDark),
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
          '${tempDir.path}/spare_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final response = await http.get(Uri.parse(url));
      await File(path).writeAsBytes(response.bodyBytes);
      await Share.shareXFiles([XFile(path)], text: "Spare Parts Document");
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Sharing failed: $e")));
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
          color: kWhite,
          borderRadius: BorderRadius.circular(10),
          border:
          Border.all(color: kPrimaryLight.withOpacity(0.35)),
        ),
        child: Row(children: [
          const Icon(Icons.date_range_rounded, color: kPrimary, size: 18),
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
                          color: kPrimaryDark,
                          fontWeight: FontWeight.w600)),
                ]),
          ),
        ]),
      ),
    );
  }
}