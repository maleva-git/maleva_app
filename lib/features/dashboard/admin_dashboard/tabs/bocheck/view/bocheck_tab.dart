import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/models/model.dart';
import '../../../../../../core/theme/tokens.dart';
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
  final TextEditingController _searchController =
  TextEditingController();

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
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return isTablet
        ? _buildTabletLayout(context)
        : _buildMobileLayout(context);
  }

  // ══════════════════════════════════════════════════════
  // TABLET — Two Column
  // ══════════════════════════════════════════════════════
  Widget _buildTabletLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── LEFT (300px) — Search + hint/status
          SizedBox(
            width: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Row(children: [
                  Container(
                    width: 4, height: 30,
                    decoration: BoxDecoration(
                      color: colour.kPrimary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('BOC CHECK',
                      style: GoogleFonts.lato(
                        fontSize:      20,
                        fontWeight:    FontWeight.bold,
                        color:         AppTokens.brandDark,
                        letterSpacing: 1.2,
                      )),
                ]),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: Text('Search bills & invoices',
                      style: GoogleFonts.lato(
                        fontSize:   14,
                        color:      AppTokens.brandMid,
                        fontWeight: FontWeight.w500,
                      )),
                ),
                const SizedBox(height: 20),

                // Search bar
                _SearchBar(
                    controller: _searchController,
                    onSearch: _onSearch,
                    isTablet: true),

                const SizedBox(height: 20),

                // State hints (initial/loading) in left panel
                BlocBuilder<BocBloc, BocState>(
                  builder: (context, state) {
                    if (state is BocInitial) {
                      return _InitialHint(isTablet: true);
                    }
                    if (state is BocLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                            color: colour.kPrimary),
                      );
                    }
                    if (state is BocError) {
                      return _ErrorState(
                          message: state.message,
                          onRetry: _onSearch,
                          isTablet: true);
                    }
                    if (state is BocLoaded) {
                      // Results count badge
                      return _ResultCountBadge(
                          count: state.boDetails.length);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // ── RIGHT — Results
          Expanded(
            child: BlocBuilder<BocBloc, BocState>(
              builder: (context, state) {
                if (state is BocInitial || state is BocLoading) {
                  return const SizedBox.shrink();
                }
                if (state is BocError) {
                  return const SizedBox.shrink();
                }
                if (state is BocEmpty) {
                  return _EmptyState(isTablet: true);
                }
                if (state is BocLoaded) {
                  return ListView.builder(
                    itemCount: state.boDetails.length,
                    itemBuilder: (context, index) =>
                        _BocCard(
                            data:     state.boDetails[index],
                            isTablet: true),
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

  // ══════════════════════════════════════════════════════
  // MOBILE — Single Column
  // ══════════════════════════════════════════════════════
  Widget _buildMobileLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SearchBar(
              controller: _searchController,
              onSearch: _onSearch,
              isTablet: false),
          const SizedBox(height: 20),

          Expanded(
            child: BlocBuilder<BocBloc, BocState>(
              builder: (context, state) {
                if (state is BocInitial) {
                  return _InitialHint(isTablet: false);
                }
                if (state is BocLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: colour.kPrimary),
                  );
                }
                if (state is BocError) {
                  return _ErrorState(
                      message: state.message,
                      onRetry: _onSearch,
                      isTablet: false);
                }
                if (state is BocEmpty) {
                  return _EmptyState(isTablet: false);
                }
                if (state is BocLoaded) {
                  return ListView.builder(
                    itemCount: state.boDetails.length,
                    itemBuilder: (context, index) =>
                        _BocCard(
                            data:     state.boDetails[index],
                            isTablet: false),
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

// ─── Search Bar ───────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final bool isTablet;
  const _SearchBar({
    required this.controller,
    required this.onSearch,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colour.kAccent,
        borderRadius: BorderRadius.circular(isTablet ? 24 : 22),
        border:
        Border.all(color: AppTokens.brandMid.withOpacity(0.3)),
      ),
      child: TextField(
        controller: controller,
        onSubmitted: (_) => onSearch(),
        decoration: InputDecoration(
          hintText:  "Search bills, invoices...",
          hintStyle: GoogleFonts.lato(
            color:    Colors.grey.shade500,
            fontSize: isTablet ? 15 : 16,
          ),
          prefixIcon: Icon(Icons.search_rounded,
              color: colour.kPrimary,
              size:  isTablet ? 22 : 20),
          suffixIcon: IconButton(
            icon: Icon(Icons.arrow_forward_ios_rounded,
                color: colour.kPrimary,
                size:  isTablet ? 20 : 18),
            onPressed: onSearch,
          ),
          filled:         false,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 22 : 20,
            vertical:   isTablet ? 16 : 14,
          ),
          border: InputBorder.none,
        ),
        style: GoogleFonts.lato(
          color:    Colors.black87,
          fontSize: isTablet ? 16 : 17,
        ),
      ),
    );
  }
}

// ─── Result Count Badge (Tablet left panel) ───────────────────────────────────
class _ResultCountBadge extends StatelessWidget {
  final int count;
  const _ResultCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [colour.kPrimary, AppTokens.brandDark],
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:     colour.kPrimary.withOpacity(0.28),
            blurRadius: 16,
            offset:    const Offset(0, 6),
          ),
        ],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colour.kWhite.withOpacity(0.20),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.receipt_long_rounded,
              color: colour.kWhite, size: 22),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Results Found',
                style: GoogleFonts.lato(
                  fontSize:   12,
                  color:      colour.kWhite.withOpacity(0.75),
                  fontWeight: FontWeight.w500,
                )),
            Text('$count',
                style: GoogleFonts.lato(
                  fontSize:   28,
                  color:      colour.kWhite,
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
      ]),
    );
  }
}

// ─── Initial Hint ─────────────────────────────────────────────────────────────
class _InitialHint extends StatelessWidget {
  final bool isTablet;
  const _InitialHint({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_rounded,
              size:  isTablet ? 72 : 64,
              color: colour.kAccent),
          const SizedBox(height: 12),
          Text(
            "Search bills or invoices above",
            style: GoogleFonts.lato(
                fontSize: isTablet ? 16 : 15,
                color:    Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ─── Error State ──────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool isTablet;
  const _ErrorState({
    required this.message,
    required this.onRetry,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline,
              color: Colors.red,
              size:  isTablet ? 60 : 48),
          SizedBox(height: isTablet ? 16 : 12),
          Text(message,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                  color:    Colors.red,
                  fontSize: isTablet ? 15 : 14)),
          SizedBox(height: isTablet ? 20 : 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon:  Icon(Icons.refresh,
                size: isTablet ? 20 : 18),
            label: Text("Retry",
                style: GoogleFonts.lato(
                    fontSize: isTablet ? 15 : 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: colour.kPrimary,
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 28 : 20,
                vertical:   isTablet ? 12 : 10,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isTablet;
  const _EmptyState({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("No records found.",
          style: GoogleFonts.lato(
              fontSize: isTablet ? 18 : 16,
              color:    Colors.grey)),
    );
  }
}

// ─── BOC Card ─────────────────────────────────────────────────────────────────
class _BocCard extends StatelessWidget {
  final BoDetailResponse data;
  final bool isTablet;
  const _BocCard({required this.data, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final masters = data.masters;
    final details = data.details;

    return Column(
      children: masters.map<Widget>((master) {
        return Container(
          margin: EdgeInsets.symmetric(
              vertical: isTablet ? 12 : 10),
          decoration: BoxDecoration(
            color:         colour.kWhite,
            borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
            border: Border.all(color: colour.kAccent, width: 1.5),
            boxShadow: [
              BoxShadow(
                color:     colour.kPrimary.withOpacity(0.07),
                blurRadius: 12,
                offset:    const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Card Header
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 22 : 18,
                  vertical:   isTablet ? 18 : 16,
                ),
                decoration: BoxDecoration(
                  color: colour.kPrimary,
                  borderRadius: BorderRadius.only(
                    topLeft:  Radius.circular(isTablet ? 24 : 20),
                    topRight: Radius.circular(isTablet ? 24 : 20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Icon(Icons.receipt_long_rounded,
                          color: colour.kWhite,
                          size:  isTablet ? 24 : 22),
                      const SizedBox(width: 10),
                      Text(master.billNoDisplay,
                          style: GoogleFonts.lato(
                            fontSize:   isTablet ? 20 : 18,
                            fontWeight: FontWeight.bold,
                            color:      colour.kWhite,
                          )),
                    ]),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 14 : 12,
                        vertical:   isTablet ? 6  : 5,
                      ),
                      decoration: BoxDecoration(
                        color: master.billStatus == "Open"
                            ? Colors.green.shade400
                            : Colors.red.shade400,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(master.billStatus,
                          style: GoogleFonts.lato(
                            fontSize:   isTablet ? 13 : 12,
                            fontWeight: FontWeight.bold,
                            color:      colour.kWhite,
                          )),
                    ),
                  ],
                ),
              ),

              // Card Body
              Padding(
                padding: EdgeInsets.all(isTablet ? 22 : 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.store_rounded,
                        "Supplier", master.supplierName,
                        isTablet: isTablet),
                    _buildDivider(),

                    _buildInfoRow(Icons.person_rounded,
                        "Employee", master.employeeName,
                        isTablet: isTablet),
                    _buildDivider(),

                    // Invoice row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width:  isTablet ? 40 : 36,
                          height: isTablet ? 40 : 36,
                          decoration: BoxDecoration(
                            color:         colour.kAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.description_rounded,
                              color: colour.kPrimary,
                              size:  isTablet ? 20 : 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text("Invoice",
                                  style: GoogleFonts.lato(
                                    fontSize:      isTablet ? 13 : 12,
                                    color:         Colors.grey[500],
                                    fontWeight:    FontWeight.w600,
                                    letterSpacing: 0.5,
                                  )),
                              const SizedBox(height: 2),
                              RichText(
                                text: TextSpan(children: [
                                  TextSpan(
                                    text: "${master.invoiceNo}  ",
                                    style: GoogleFonts.lato(
                                      fontSize:   isTablet ? 16 : 15,
                                      fontWeight: FontWeight.bold,
                                      color:      AppTokens.brandDark,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                    "(${master.invoiceDate})",
                                    style: GoogleFonts.lato(
                                      fontSize: isTablet ? 14 : 13,
                                      color:    Colors.grey[600],
                                    ),
                                  ),
                                ]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    _buildDivider(),

                    // Net Amount
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 16 : 14,
                        vertical:   isTablet ? 12 : 10,
                      ),
                      decoration: BoxDecoration(
                        color:         colour.kAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(children: [
                        Icon(Icons.currency_rupee_rounded,
                            color: colour.kPrimary,
                            size:  isTablet ? 22 : 20),
                        const SizedBox(width: 8),
                        Text(
                          "Net Amount: ₹${master.netAmt.toStringAsFixed(2)}",
                          style: GoogleFonts.lato(
                            fontSize:   isTablet ? 17 : 16,
                            fontWeight: FontWeight.bold,
                            color:      AppTokens.brandDark,
                          ),
                        ),
                      ]),
                    ),
                    _buildDivider(),

                    _buildInfoRow(Icons.notes_rounded,
                        "Description", master.description,
                        isTablet: isTablet),

                    // Order Details
                    if (details.isNotEmpty) ...[
                      _buildDivider(),
                      Text("Order Details",
                          style: GoogleFonts.lato(
                            fontSize:      isTablet ? 14 : 13,
                            color:         Colors.grey[500],
                            fontWeight:    FontWeight.w600,
                            letterSpacing: 0.5,
                          )),
                      const SizedBox(height: 10),
                      ...details.map<Widget>((d) =>
                          _DetailItem(
                              detail: d, isTablet: isTablet)),
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

  Widget _buildInfoRow(
      IconData icon, String label, String value,
      {required bool isTablet}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width:  isTablet ? 40 : 36,
          height: isTablet ? 40 : 36,
          decoration: BoxDecoration(
            color:         colour.kAccent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon,
              color: colour.kPrimary,
              size:  isTablet ? 20 : 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.lato(
                    fontSize:      isTablet ? 13 : 12,
                    color:         Colors.grey[500],
                    fontWeight:    FontWeight.w600,
                    letterSpacing: 0.5,
                  )),
              const SizedBox(height: 2),
              Text(
                value.isNotEmpty ? value : "Not Available",
                style: GoogleFonts.lato(
                  fontSize:   isTablet ? 16 : 15,
                  fontWeight: FontWeight.w700,
                  color:      AppTokens.brandDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Detail Item ──────────────────────────────────────────────────────────────
class _DetailItem extends StatelessWidget {
  final dynamic detail;
  final bool isTablet;
  const _DetailItem(
      {required this.detail, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 12 : 10),
      padding: EdgeInsets.all(isTablet ? 14 : 12),
      decoration: BoxDecoration(
        color:         colour.kAccent.withOpacity(0.6),
        borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
        border: Border.all(
            color: AppTokens.brandMid.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.inventory_2_rounded,
                color: colour.kPrimary,
                size:  isTablet ? 18 : 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                detail.productName,
                style: GoogleFonts.lato(
                  fontSize:   isTablet ? 16 : 15,
                  fontWeight: FontWeight.w700,
                  color:      AppTokens.brandDark,
                ),
              ),

            ),
          ]),
          if (detail.RemarksD != null &&
              detail.RemarksD!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 24),
              child: Text(
                "Remarks: ${detail.RemarksD}",
                style: GoogleFonts.lato(
                  fontSize:  isTablet ? 14 : 13,
                  color:     Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}