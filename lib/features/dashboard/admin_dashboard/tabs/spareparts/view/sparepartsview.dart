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
    final isTablet = MediaQuery.of(context).size.width >= 600;

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
          final fromDate  = _getFrom(state);
          final toDate    = _getTo(state);
          final records   = state is SparePartsViewState
              ? state.records
              : <dynamic>[];
          final isLoading = state is SparePartsViewState
              ? state.isLoading
              : false;
          final selected  = state is SparePartsViewState
              ? state.selectedRecord
              : null;

          return Padding(
            padding: EdgeInsets.all(isTablet ? 16 : 16),
            child: Column(children: [

              // ── Date Filter Bar ──
              _DateFilterBar(
                fromDate:  fromDate,
                toDate:    toDate,
                isLoading: isLoading,
                isTablet:  isTablet,
              ),

              const SizedBox(height: 16),

              // ── Content ──
              Expanded(
                child: isTablet
                    ? _buildTabletLayout(
                    context, state, records,
                    isLoading, selected)
                    : _buildContent(
                    context, isLoading, records,
                    isTablet: false),
              ),
            ]),
          );
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // TABLET — Two Column
  // ══════════════════════════════════════════════════════
  Widget _buildTabletLayout(
      BuildContext context,
      SparePartsState state,
      List<dynamic> records,
      bool isLoading,
      Map<String, dynamic>? selected,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── LEFT (55%) — List ──
        Expanded(
          flex: 55,
          child: _buildContent(
              context, isLoading, records,
              isTablet: true,
              selected: selected),
        ),

        const SizedBox(width: 16),

        // ── RIGHT (45%) — Detail Panel ──
        Expanded(
          flex: 45,
          child: selected != null
              ? _SparePartsDetailPanel(item: selected)
              : _EmptyDetailPanel(),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════
  // SHARED — Content Builder
  // ══════════════════════════════════════════════════════
  Widget _buildContent(
      BuildContext context,
      bool isLoading,
      List<dynamic> records, {
        required bool isTablet,
        Map<String, dynamic>? selected,
      }) {
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
      itemBuilder: (context, i) {
        final item = records[i] as Map<String, dynamic>;
        final isSelected = isTablet &&
            selected != null &&
            selected['Id'] == item['Id'];

        return _SparePartsCard(
          item: item,
          isTablet: isTablet,
          isSelected: isSelected,
          onTap: () {
            if (isTablet) {
              context.read<SparePartsBloc>().add(
                  SelectSparePartsRecordEvent(item));
            } else {
              _showImageDialog(context, item);
            }
          },
        );
      },
    );
  }

  void _showImageDialog(
      BuildContext context, Map<String, dynamic> item) {
    final hasDoc = item['DocumentPath'] != null &&
        item['DocumentPath'].toString().isNotEmpty;
    if (!hasDoc) return;
    showDialog(
      context: context,
      builder: (_) => _ImagePreviewDialog(
          imageUrl: objfun.port + item['DocumentPath']),
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

// ── Date Filter Bar ───────────────────────────────────────────────────────────
class _DateFilterBar extends StatelessWidget {
  final DateTime fromDate;
  final DateTime toDate;
  final bool isLoading;
  final bool isTablet;

  const _DateFilterBar({
    required this.fromDate,
    required this.toDate,
    required this.isLoading,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 14 : 12),
      decoration: BoxDecoration(
        color: kAccent,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(color: kPrimaryLight.withOpacity(0.3)),
      ),
      child: Column(children: [
        Row(children: [
          Expanded(
            child: _DateTile(
              label: "From Date",
              value: DateFormat('yyyy-MM-dd').format(fromDate),
              isTablet: isTablet,
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
                if (picked != null && context.mounted) {
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
              isTablet: isTablet,
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
                if (picked != null && context.mounted) {
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
              padding: EdgeInsets.symmetric(
                  vertical: isTablet ? 16 : 14),
              backgroundColor: kPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text("Search",
                style: GoogleFonts.lato(
                    fontSize: isTablet ? 17 : 16,
                    fontWeight: FontWeight.bold,
                    color: kWhite)),
          ),
        ),
      ]),
    );
  }
}

// ── Spare Parts Card ──────────────────────────────────────────────────────────
class _SparePartsCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isTablet;
  final bool isSelected;
  final VoidCallback onTap;

  const _SparePartsCard({
    required this.item,
    required this.isTablet,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasDoc = item['DocumentPath'] != null &&
        item['DocumentPath'].toString().isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: isTablet ? 10 : 14),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius:
          BorderRadius.circular(isTablet ? 12 : 16),
          border: Border.all(
            color: isSelected ? kPrimary : kAccent,
            width: isSelected ? 2.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: kPrimary
                  .withOpacity(isSelected ? 0.15 : 0.06),
              blurRadius: isSelected ? 14 : 10,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 10 : 16),
          child: isTablet
              ? _buildTabletContent()
              : _buildMobileContent(context, hasDoc),
        ),
      ),
    );
  }

  // Tablet: compact — truck + amount only
  Widget _buildTabletContent() {
    return Row(children: [
      Container(
        width: 38, height: 38,
        decoration: const BoxDecoration(
            color: kAccent, shape: BoxShape.circle),
        child: const Icon(Icons.local_shipping_rounded,
            color: kPrimary, size: 20),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${item['TruckName'] ?? '-'}",
                style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryDark),
                overflow: TextOverflow.ellipsis),
            Text("${item['EntryDate'] ?? '-'}",
                style: GoogleFonts.lato(
                    fontSize: 12,
                    color: Colors.grey[500])),
          ],
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: kAccent,
            borderRadius: BorderRadius.circular(8)),
        child: Text("₹${item['Amount'] ?? '-'}",
            style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                color: kPrimary,
                fontSize: 13)),
      ),
    ]);
  }

  // Mobile: full card (same as before)
  Widget _buildMobileContent(
      BuildContext context, bool hasDoc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            width: 44, height: 44,
            decoration: const BoxDecoration(
                color: kAccent, shape: BoxShape.circle),
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
                          fontSize: 13,
                          color: Colors.grey[500])),
                ]),
          ),
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

        Row(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.build_rounded,
                  color: kPrimaryLight, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item['SpareParts'] ?? '-',
                  style: GoogleFonts.lato(
                      fontSize: 14,
                      color: kPrimaryDark,
                      height: 1.4),
                ),
              ),
            ]),

        if (hasDoc) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => showDialog(
              context: context,
              builder: (_) => _ImagePreviewDialog(
                  imageUrl:
                  objfun.port + item['DocumentPath']),
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
      ],
    );
  }
}

// ── Empty Detail Panel ────────────────────────────────────────────────────────
class _EmptyDetailPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kAccent, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: kPrimary.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64, height: 64,
            decoration: const BoxDecoration(
                color: kAccent, shape: BoxShape.circle),
            child: const Icon(Icons.touch_app_rounded,
                color: kPrimary, size: 32),
          ),
          const SizedBox(height: 16),
          Text("Select a record",
              style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryDark)),
          const SizedBox(height: 6),
          Text("Tap any card to view details",
              style: GoogleFonts.lato(
                  fontSize: 13, color: Colors.grey[500])),
        ],
      ),
    );
  }
}

// ── Detail Panel (tablet right column) ───────────────────────────────────────
class _SparePartsDetailPanel extends StatelessWidget {
  final Map<String, dynamic> item;
  const _SparePartsDetailPanel({required this.item});

  @override
  Widget build(BuildContext context) {
    final hasDoc = item['DocumentPath'] != null &&
        item['DocumentPath'].toString().isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kAccent, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: kPrimary.withOpacity(0.07),
              blurRadius: 16,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          // ── Header ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                vertical: 16, horizontal: 20),
            decoration: const BoxDecoration(
              color: kPrimary,
              borderRadius: BorderRadius.only(
                topLeft:  Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(children: [
              const Icon(Icons.local_shipping_rounded,
                  color: kWhite, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item['TruckName'] ?? 'Spare Parts Details',
                  style: GoogleFonts.lato(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: kWhite),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
          ),

          // ── Detail rows + Image — Scrollable ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow(Icons.calendar_today_rounded,
                      "Entry Date",
                      item['EntryDate']?.toString() ?? '-'),
                  _divider(),
                  _detailRow(Icons.currency_rupee_rounded,
                      "Amount",
                      "₹${item['Amount'] ?? '-'}"),
                  _divider(),
                  _detailRow(Icons.build_rounded,
                      "Spare Parts",
                      item['SpareParts']?.toString() ?? '-'),

                  if (hasDoc) ...[
                    _divider(),
                    Text("Document",
                        style: GoogleFonts.lato(
                            fontSize: 11,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => _ImagePreviewDialog(
                            imageUrl: objfun.port +
                                item['DocumentPath']),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          objfun.port + item['DocumentPath'],
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(
                                height: 80,
                                color: kAccent,
                                child: const Center(
                                    child: Icon(
                                        Icons.broken_image_rounded,
                                        color: kPrimaryLight)),
                              ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
              color: kAccent,
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: kPrimary, size: 15),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.lato(
                      fontSize: 11,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w600)),
              Text(value,
                  style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: kPrimaryDark)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider() =>
      Divider(color: kAccent, thickness: 1.5, height: 20);
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
              child: const Icon(Icons.close,
                  color: kWhite, size: 20),
            ),
          ),
        ),
        Positioned(
          bottom: 20, right: 20,
          child: FloatingActionButton(
            backgroundColor: kWhite,
            child:
            const Icon(Icons.share, color: kPrimaryDark),
            onPressed: () => _shareImage(imageUrl, context),
          ),
        ),
      ]),
    );
  }

  Future<void> _shareImage(
      String url, BuildContext context) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final path =
          '${tempDir.path}/spare_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final response = await http.get(Uri.parse(url));
      await File(path).writeAsBytes(response.bodyBytes);
      await Share.shareXFiles([XFile(path)],
          text: "Spare Parts Document");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sharing failed: $e")));
    }
  }
}

// ── Date Tile ─────────────────────────────────────────────────────────────────
class _DateTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool isTablet;

  const _DateTile({
    required this.label,
    required this.value,
    required this.onTap,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 14 : 12,
          vertical:   isTablet ? 14 : 12,
        ),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: kPrimaryLight.withOpacity(0.35)),
        ),
        child: Row(children: [
          const Icon(Icons.date_range_rounded,
              color: kPrimary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.lato(
                          fontSize: 10,
                          color: Colors.grey[500])),
                  Text(value,
                      style: GoogleFonts.lato(
                          fontSize: isTablet ? 14 : 13,
                          color: kPrimaryDark,
                          fontWeight: FontWeight.w600)),
                ]),
          ),
        ]),
      ),
    );
  }
}