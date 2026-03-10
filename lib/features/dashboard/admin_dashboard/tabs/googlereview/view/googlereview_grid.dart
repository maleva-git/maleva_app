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
      create: (_) => ReviewBloc(context)..add(const LoadGridEmployeesEvent()),
      child: const _ReviewGridBody(),
    );
  }
}

// ── Grid Body ─────────────────────────────────────────────────────────────────
class _ReviewGridBody extends StatelessWidget {
  const _ReviewGridBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimary,
        title: Text('Google Reviews',
            style: GoogleFonts.lato(
                color: kWhite, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: kWhite),
      ),
      body: BlocConsumer<ReviewBloc, ReviewState>(
        listener: (context, state) {
          if (state is ReviewError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is! ReviewGridState) {
            return const Center(
                child: CircularProgressIndicator(color: kPrimary));
          }

          return Column(
            children: [
              // ── Filter Bar ───────────────────────────────────────────────
              Container(
                color: kAccent,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    // Date Range
                    IconButton(
                      icon: const Icon(Icons.date_range_rounded,
                          color: kPrimary),
                      onPressed: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                          builder: (context, child) => Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                  primary: kPrimary),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          context.read<ReviewBloc>().add(
                            SelectDateRangeEvent(
                              fromDate: picked.start,
                              toDate: picked.end,
                            ),
                          );
                        }
                      },
                    ),

                    // Date display
                    if (state.fromDate != null && state.toDate != null)
                      Text(
                        '${DateFormat('dd/MM').format(state.fromDate!)} - ${DateFormat('dd/MM').format(state.toDate!)}',
                        style: GoogleFonts.lato(
                            fontSize: 12,
                            color: kPrimaryDark,
                            fontWeight: FontWeight.w600),
                      ),

                    const SizedBox(width: 8),

                    // Employee Dropdown
                    Expanded(
                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: kWhite,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: kPrimaryLight.withOpacity(0.3)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            value: state.selectedEmpId,
                            hint: Text('Select Employee',
                                style: GoogleFonts.lato(
                                    color: Colors.grey, fontSize: 13)),
                            icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: kPrimary),
                            items: state.employees
                                .map((e) => DropdownMenuItem(
                              value: e.Id,
                              child: Text(e.AccountName,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.lato(
                                      color: kPrimaryDark,
                                      fontSize: 13)),
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
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Reviews List ─────────────────────────────────────────────
              Expanded(
                child: state.loading
                    ? const Center(
                    child:
                    CircularProgressIndicator(color: kPrimary))
                    : (state.selectedEmpId == null ||
                    state.fromDate == null ||
                    state.toDate == null)
                    ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.filter_list_rounded,
                          size: 64,
                          color: kAccent),
                      const SizedBox(height: 12),
                      Text(
                        'Select employee and date range',
                        style: GoogleFonts.lato(
                            fontSize: 15,
                            color: Colors.grey),
                      ),
                    ],
                  ),
                )
                    : state.reviews.isEmpty
                    ? Center(
                  child: Text('No reviews found',
                      style: GoogleFonts.lato(
                          fontSize: 16,
                          color: Colors.grey)),
                )
                    : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: state.reviews.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final r = state.reviews[i];
                    return _ReviewCard(
                      review: r,
                      onDelete: () async {
                        final confirm =
                        await objfun.ConfirmationMsgYesNo(
                          context,
                          "Delete this review?",
                        );
                        if (confirm) {
                          context.read<ReviewBloc>().add(
                              DeleteReviewEvent(r.id));
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimary,
        child: const Icon(Icons.add, color: kWhite),
        onPressed: () => Navigator.pop(context, true),
      ),
    );
  }
}

// ── Review Card ───────────────────────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  final Review review;
  final VoidCallback onDelete;

  const _ReviewCard({required this.review, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kAccent, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
              color: kAccent, shape: BoxShape.circle),
          child: const Icon(Icons.star_rounded, color: kPrimary, size: 22),
        ),
        title: Text(
          '${review.shopName} (${review.employeeName ?? ''})',
          style: GoogleFonts.lato(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: kPrimaryDark),
        ),
        subtitle: Text(
          'Review: ${review.googleReview ?? ''}\nDate: ${DateFormat('yyyy-MM-dd').format(review.supportDate)}',
          style: GoogleFonts.lato(fontSize: 13, color: Colors.grey[600]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                  color: kAccent,
                  borderRadius: BorderRadius.circular(8)),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.delete_rounded,
                    color: Colors.red, size: 18),
                onPressed: onDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}