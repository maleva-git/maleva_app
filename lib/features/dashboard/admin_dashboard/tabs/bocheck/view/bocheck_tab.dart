import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import '../bloc/bocheck_bloc.dart';
import '../bloc/bocheck_event.dart';
import '../bloc/bocheck_state.dart';
import 'package:maleva/core/colors/colors.dart' as colour;


// ── Entry Point ───────────────────────────────────────────────────────────────
class BocPage extends StatelessWidget {
  const BocPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BocBloc(context),
      child: const _BocBody(),
    );


  }
}

// ── Body ──────────────────────────────────────────────────────────────────────
class _BocBody extends StatefulWidget {
  const _BocBody();

  @override
  State<_BocBody> createState() => _BocBodyState();
}

class _BocBodyState extends State<_BocBody> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final value = _searchController.text.trim();
    context.read<BocBloc>().add(LoadBocReport(searchValue: value));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Search Bar ──────────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: colour.kAccent,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: colour.kPrimaryLight.withOpacity(0.3)),
            ),
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _onSearch(),
              decoration: InputDecoration(
                hintText: "Search bills, invoices...",
                hintStyle: GoogleFonts.lato(
                  color: Colors.grey.shade500,
                  fontSize: 16,
                ),
                prefixIcon: const Icon(Icons.search_rounded, color: colour.kPrimary),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded,
                      color: colour.kPrimary),
                  onPressed: _onSearch,
                ),
                filled: false,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                border: InputBorder.none,
              ),
              style: GoogleFonts.lato(
                color: Colors.black87,
                fontSize: 17,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Results ─────────────────────────────────────────────────────────
          Expanded(
            child: BlocBuilder<BocBloc, BocState>(
              builder: (context, state) {

                // ── Initial ──
                if (state is BocInitial) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_rounded,
                            size: 64, color: colour.kAccent),
                        const SizedBox(height: 12),
                        Text(
                          "Search bills or invoices above",
                          style: GoogleFonts.lato(
                              fontSize: 15, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                // ── Loading ──
                if (state is BocLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: colour.kPrimary),
                  );
                }

                // ── Error ──
                if (state is BocError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                              color: Colors.red, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _onSearch,
                          icon: const Icon(Icons.refresh),
                          label: const Text("Retry"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: colour.kPrimary),
                        ),
                      ],
                    ),
                  );
                }

                // ── Empty ──
                if (state is BocEmpty) {
                  return Center(
                    child: Text(
                      "No records found.",
                      style: GoogleFonts.lato(
                          fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                // ── Loaded ──
                if (state is BocLoaded) {
                  return ListView.builder(
                    itemCount: state.boDetails.length,
                    itemBuilder: (context, index) {
                      final data = state.boDetails[index];
                      return _BocCard(data: data);
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── BOC Card ──────────────────────────────────────────────────────────────────
class _BocCard extends StatelessWidget {
  final BoDetailResponse data;
  const _BocCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final masters = data.masters;
    final details = data.details;

    return Column(
      children: masters.map<Widget>((master) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: colour.kWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colour.kAccent, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: colour.kPrimary.withOpacity(0.07),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Card Header ─────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 16),
                decoration: const BoxDecoration(
                  color: colour.kPrimary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.receipt_long_rounded,
                            color: colour.kWhite, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          master.billNoDisplay,
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colour.kWhite,
                          ),
                        ),
                      ],
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: master.billStatus == "Open"
                            ? Colors.green.shade400
                            : Colors.red.shade400,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        master.billStatus,
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colour.kWhite,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Card Body ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    _buildInfoRow(Icons.store_rounded, "Supplier",
                        master.supplierName),
                    _buildDivider(),

                    _buildInfoRow(Icons.person_rounded, "Employee",
                        master.employeeName),
                    _buildDivider(),

                    // Invoice row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: colour.kAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.description_rounded,
                              color: colour.kPrimary, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Invoice",
                                style: GoogleFonts.lato(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "${master.invoiceNo}  ",
                                      style: GoogleFonts.lato(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: colour.kPrimaryDark,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "(${master.invoiceDate})",
                                      style: GoogleFonts.lato(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    _buildDivider(),

                    // Net Amount — highlighted
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: colour.kAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.currency_rupee_rounded,
                              color: colour.kPrimary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Net Amount: ₹${master.netAmt.toStringAsFixed(2)}",
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colour.kPrimaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildDivider(),

                    _buildInfoRow(Icons.notes_rounded, "Description",
                        master.description),

                    // ── Order Details ──────────────────────────────────────
                    if (details.isNotEmpty) ...[
                      _buildDivider(),
                      Text(
                        "Order Details",
                        style: GoogleFonts.lato(
                          fontSize: 13,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...details.map<Widget>((d) => _DetailItem(detail: d)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDivider() =>
      Divider(color: colour.kAccent, thickness: 1.5, height: 24);

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colour.kAccent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: colour.kPrimary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.lato(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isNotEmpty ? value : "Not Available",
                style: GoogleFonts.lato(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: colour.kPrimaryDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Detail Item Card ──────────────────────────────────────────────────────────
class _DetailItem extends StatelessWidget {
  final dynamic detail;
  const _DetailItem({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colour.kAccent.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colour.kPrimaryLight.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2_rounded,
                  color: colour.kPrimary, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  detail.productName,
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colour.kPrimaryDark,
                  ),
                ),
              ),
            ],
          ),
          if (detail.RemarksD != null && detail.RemarksD!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 24),
              child: Text(
                "Remarks: ${detail.RemarksD}",
                style: GoogleFonts.lato(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}