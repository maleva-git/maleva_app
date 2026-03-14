import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import '../bloc/googlereview_bloc.dart';
import '../bloc/googlereview_event.dart';
import '../bloc/googlereview_state.dart';

// ── Color Palette ─────────────────────────────────────────────────────────────
const Color kPrimary      = Color(0xFF1555F3);
const Color kPrimaryDark  = Color(0xFF0D3DB5);
const Color kPrimaryLight = Color(0xFF4D7EF7);
const Color kAccent       = Color(0xFFE8EEFF);
const Color kWhite        = Colors.white;

// ── Entry Point ───────────────────────────────────────────────────────────────
class ReviewGridPage extends StatelessWidget {
  const ReviewGridPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      ReviewBloc(context)..add(const LoadGridEmployeesEvent()),
      child: const _ReviewGridBody(),
    );
  }
}

// ── Grid Body ─────────────────────────────────────────────────────────────────
class _ReviewGridBody extends StatelessWidget {
  const _ReviewGridBody();

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimary,
        toolbarHeight: isTablet ? 64 : 56,
        title: Text('Google Reviews',
            style: GoogleFonts.lato(
              color:      kWhite,
              fontWeight: FontWeight.bold,
              fontSize:   isTablet ? 20 : 18,
            )),
        iconTheme: const IconThemeData(color: kWhite),
      ),
      body: BlocConsumer<ReviewBloc, ReviewState>(
        listener: (context, state) {
          if (state is ReviewError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:         Text(state.message),
                  backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is! ReviewGridState) {
            return const Center(
                child: CircularProgressIndicator(color: kPrimary));
          }

          return isTablet
              ? _buildTabletLayout(context, state)
              : _buildMobileLayout(context, state);
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimary,
        child: const Icon(Icons.add, color: kWhite),
        onPressed: () => Navigator.pop(context, true),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // TABLET — Two Column
  // ══════════════════════════════════════════════════════
  Widget _buildTabletLayout(
      BuildContext context, ReviewGridState state) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── LEFT (280px) — Filter + Stats
          SizedBox(
            width: 280,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section title
                Row(children: [
                  Container(
                    width: 4, height: 28,
                    decoration: BoxDecoration(
                      color:         kPrimary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('FILTERS',
                      style: GoogleFonts.lato(
                        fontSize:      18,
                        fontWeight:    FontWeight.bold,
                        color:         kPrimaryDark,
                        letterSpacing: 1.2,
                      )),
                ]),
                const SizedBox(height: 20),

                // Filter card
                _FilterCard(state: state, isTablet: true),
                const SizedBox(height: 20),

                // Count badge (when reviews loaded)
                if (state.reviews.isNotEmpty)
                  _CountBadge(count: state.reviews.length),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // ── RIGHT — Review list
          Expanded(
            child: _buildReviewContent(context, state, isTablet: true),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // MOBILE — Single Column
  // ══════════════════════════════════════════════════════
  Widget _buildMobileLayout(
      BuildContext context, ReviewGridState state) {
    return Column(children: [
      _FilterCard(state: state, isTablet: false),
      Expanded(
        child: _buildReviewContent(context, state, isTablet: false),
      ),
    ]);
  }

  // ══════════════════════════════════════════════════════
  // SHARED — Review content area
  // ══════════════════════════════════════════════════════
  Widget _buildReviewContent(
      BuildContext context,
      ReviewGridState state, {
        required bool isTablet,
      }) {
    if (state.loading) {
      return const Center(
          child: CircularProgressIndicator(color: kPrimary));
    }

    if (state.selectedEmpId == null ||
        state.fromDate == null ||
        state.toDate == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_list_rounded,
                size:  isTablet ? 72 : 64,
                color: kAccent),
            SizedBox(height: isTablet ? 16 : 12),
            Text(
              'Select employee and date range',
              style: GoogleFonts.lato(
                  fontSize: isTablet ? 16 : 15,
                  color:    Colors.grey),
            ),
          ],
        ),
      );
    }

    if (state.reviews.isEmpty) {
      return Center(
        child: Text('No reviews found',
            style: GoogleFonts.lato(
                fontSize: isTablet ? 18 : 16,
                color:    Colors.grey)),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(isTablet ? 0 : 12),
      itemCount:     state.reviews.length,
      separatorBuilder: (_, __) =>
          SizedBox(height: isTablet ? 10 : 8),
      itemBuilder: (_, i) {
        final r = state.reviews[i];
        return _ReviewCard(
          review:   r,
          isTablet: isTablet,
          onDelete: () async {
            final confirm = await objfun.ConfirmationMsgYesNo(
              context,
              "Delete this review?",
            );
            if (confirm) {
              context
                  .read<ReviewBloc>()
                  .add(DeleteReviewEvent(r.id));
            }
          },
        );
      },
    );
  }
}

// ─── Filter Card ──────────────────────────────────────────────────────────────
class _FilterCard extends StatelessWidget {
  final ReviewGridState state;
  final bool isTablet;
  const _FilterCard({required this.state, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isTablet ? Colors.transparent : kAccent,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 0 : 12,
        vertical:   isTablet ? 0 : 8,
      ),
      child: isTablet
          ? _tabletFilter(context)
          : _mobileFilter(context),
    );
  }

  // Tablet — vertical stack
  Widget _tabletFilter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date picker button
        GestureDetector(
          onTap: () => _pickDateRange(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color:         kAccent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: kPrimaryLight.withOpacity(0.3)),
            ),
            child: Row(children: [
              const Icon(Icons.date_range_rounded,
                  color: kPrimary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  state.fromDate != null && state.toDate != null
                      ? '${DateFormat('dd MMM').format(state.fromDate!)} - ${DateFormat('dd MMM').format(state.toDate!)}'
                      : 'Select date range',
                  style: GoogleFonts.lato(
                    fontSize:   14,
                    color:      state.fromDate != null
                        ? kPrimaryDark
                        : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: kPrimaryLight, size: 20),
            ]),
          ),
        ),

        const SizedBox(height: 12),

        // Employee dropdown
        Text('Employee',
            style: GoogleFonts.lato(
              fontSize:   12,
              color:      Colors.grey[600],
              fontWeight: FontWeight.w600,
            )),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color:         kWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: kPrimaryLight.withOpacity(0.3)),
          ),
          child: _employeeDropdown(context, fontSize: 14),
        ),
      ],
    );
  }

  // Mobile — horizontal row
  Widget _mobileFilter(BuildContext context) {
    return Row(children: [
      IconButton(
        icon: const Icon(Icons.date_range_rounded, color: kPrimary),
        onPressed: () => _pickDateRange(context),
      ),

      if (state.fromDate != null && state.toDate != null)
        Text(
          '${DateFormat('dd/MM').format(state.fromDate!)} - ${DateFormat('dd/MM').format(state.toDate!)}',
          style: GoogleFonts.lato(
            fontSize:   12,
            color:      kPrimaryDark,
            fontWeight: FontWeight.w600,
          ),
        ),

      const SizedBox(width: 8),

      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color:         kWhite,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: kPrimaryLight.withOpacity(0.3)),
          ),
          child: _employeeDropdown(context, fontSize: 13),
        ),
      ),
    ]);
  }

  Widget _employeeDropdown(BuildContext context,
      {required double fontSize}) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        isExpanded: true,
        value:      state.selectedEmpId,
        hint: Text('Select Employee',
            style: GoogleFonts.lato(
                color: Colors.grey, fontSize: fontSize)),
        icon: const Icon(Icons.keyboard_arrow_down_rounded,
            color: kPrimary),
        items: state.employees
            .map((e) => DropdownMenuItem(
          value: e.Id,
          child: Text(e.AccountName,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.lato(
                  color:    kPrimaryDark,
                  fontSize: fontSize)),
        ))
            .toList(),
        onChanged: (v) {
          if (v != null) {
            context
                .read<ReviewBloc>()
                .add(SelectGridEmployeeEvent(v));
          }
        },
      ),
    );
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context:   context,
      firstDate: DateTime(2020),
      lastDate:  DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
          const ColorScheme.light(primary: kPrimary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      context.read<ReviewBloc>().add(
        SelectDateRangeEvent(
          fromDate: picked.start,
          toDate:   picked.end,
        ),
      );
    }
  }
}

// ─── Count Badge ──────────────────────────────────────────────────────────────
class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimary, kPrimaryDark],
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:     kPrimary.withOpacity(0.28),
            blurRadius: 16,
            offset:    const Offset(0, 6),
          ),
        ],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: kWhite.withOpacity(0.20),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.star_rounded,
              color: kWhite, size: 22),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Reviews',
                style: GoogleFonts.lato(
                  fontSize:   12,
                  color:      kWhite.withOpacity(0.75),
                  fontWeight: FontWeight.w500,
                )),
            Text('$count',
                style: GoogleFonts.lato(
                  fontSize:   28,
                  color:      kWhite,
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
      ]),
    );
  }
}

// ─── Review Card ──────────────────────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  final Review review;
  final VoidCallback onDelete;
  final bool isTablet;

  const _ReviewCard({
    required this.review,
    required this.onDelete,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:         kWhite,
        borderRadius: BorderRadius.circular(isTablet ? 18 : 14),
        border: Border.all(color: kAccent, width: 1.5),
        boxShadow: [
          BoxShadow(
            color:     kPrimary.withOpacity(0.07),
            blurRadius: 8,
            offset:    const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20 : 16,
          vertical:   isTablet ? 12 : 8,
        ),
        leading: Container(
          width:  isTablet ? 48 : 42,
          height: isTablet ? 48 : 42,
          decoration: const BoxDecoration(
              color: kAccent, shape: BoxShape.circle),
          child: Icon(Icons.star_rounded,
              color: kPrimary,
              size:  isTablet ? 26 : 22),
        ),
        title: Text(
          '${review.shopName} (${review.employeeName ?? ''})',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            fontSize:   isTablet ? 16 : 15,
            color:      kPrimaryDark,
          ),
        ),
        subtitle: Text(
          'Review: ${review.googleReview ?? ''}\nDate: ${DateFormat('yyyy-MM-dd').format(review.supportDate)}',
          style: GoogleFonts.lato(
            fontSize: isTablet ? 14 : 13,
            color:    Colors.grey[600],
          ),
        ),
        trailing: Container(
          width:  isTablet ? 38 : 34,
          height: isTablet ? 38 : 34,
          decoration: BoxDecoration(
            color:         kAccent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(Icons.delete_rounded,
                color: Colors.red,
                size:  isTablet ? 20 : 18),
            onPressed: onDelete,
          ),
        ),
      ),
    );
  }
}