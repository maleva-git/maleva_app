import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import '../../../../../../core/colors/colors.dart';
import '../../../../../../core/theme/tokens.dart';
import '../bloc/pettycash_bloc.dart';
import '../bloc/pettycash_event.dart';
import '../bloc/pettycash_state.dart';

// ── Entry Point ───────────────────────────────────────────────────────────────
class PettyCashPage extends StatelessWidget {
  const PettyCashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PettyCashBloc(context),
      child: const _PettyCashBody(),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────
class _PettyCashBody extends StatelessWidget {
  const _PettyCashBody();

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return BlocBuilder<PettyCashBloc, PettyCashState>(
      builder: (context, state) {
        final fromDate = _getFromDate(state);
        final toDate   = _getToDate(state);

        return Padding(
          padding: EdgeInsets.all(isTablet ? 16 : 10),
          child: Column(
            children: [
              // ── Title ──
              Text(
                "Petty Cash",
                style: GoogleFonts.lato(
                  fontSize: objfun.FontLarge,
                  fontWeight: FontWeight.bold,
                  color: AppTokens.brandDark,
                ),
              ),

              SizedBox(height: isTablet ? 14 : 10),

              // ── Date Filter Bar ──
              _DateFilterBar(
                fromDate: fromDate,
                toDate: toDate,
                isLoading: state is PettyCashLoading,
                isTablet: isTablet,
              ),

              SizedBox(height: isTablet ? 14 : 10),

              // ── Content ──
              Expanded(
                child: isTablet
                    ? _buildTabletLayout(context, state)
                    : _buildContent(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════
  // TABLET — Two Column
  // ══════════════════════════════════════════════════════
  Widget _buildTabletLayout(
      BuildContext context, PettyCashState state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── LEFT (55%) — List ──
        Expanded(
          flex: 55,
          child: _buildContent(context, state, isTablet: true),
        ),

        const SizedBox(width: 16),

        // ── RIGHT (45%) — Detail Panel ──
        Expanded(
          flex: 45,
          child: state is PettyCashLoaded &&
              state.selectedMaster != null
              ? _PettyCashDetailPanel(
            master: state.selectedMaster!,
            details: state.detailRecords
                .where((d) =>
            d.pettyCashMasterRefId ==
                state.selectedMaster!.Id)
                .toList(),
          )
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
      PettyCashState state, {
        bool isTablet = false,
      }) {
    if (state is PettyCashLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTokens.brandGradientStart));
    }

    if (state is PettyCashError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(state.message,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                    color: Colors.red, fontSize: 14)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context
                  .read<PettyCashBloc>()
                  .add(const LoadPettyCashEvent()),
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTokens.brandGradientStart),
            ),
          ],
        ),
      );
    }

    if (state is PettyCashInitial) {
      return Center(
        child: Text(
          "Select dates and press View",
          style:
          GoogleFonts.lato(fontSize: 15, color: Colors.grey),
        ),
      );
    }

    if (state is PettyCashLoaded) {
      if (state.masterRecords.isEmpty) {
        return Center(
          child: Text("No records found",
              style: GoogleFonts.lato(
                  fontSize: 16, color: Colors.grey)),
        );
      }

      return ListView.builder(
        itemCount: state.masterRecords.length,
        itemBuilder: (context, index) {
          final master = state.masterRecords[index];
          final related = state.detailRecords
              .where(
                  (d) => d.pettyCashMasterRefId == master.Id)
              .toList();
          final isSelected =
              isTablet && state.selectedMaster?.Id == master.Id;

          return _PettyCashCard(
            master: master,
            details: related,
            isTablet: isTablet,
            isSelected: isSelected,
            onTap: () {
              if (isTablet) {
                context.read<PettyCashBloc>().add(
                    SelectPettyCashMasterEvent(master));
              } else {
                _showDialog(context, master, related);
              }
            },
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  void _showDialog(
      BuildContext context,
      PattycashMasterModel master,
      List<PattyCashDetailsModel> details,
      ) {
    showDialog(
      context: context,
      builder: (_) =>
          _PettyCashDialog(master: master, details: details),
    );
  }

  DateTime _getFromDate(PettyCashState s) {
    if (s is PettyCashInitial) return s.fromDate;
    if (s is PettyCashLoading) return s.fromDate;
    if (s is PettyCashLoaded) return s.fromDate;
    if (s is PettyCashError) return s.fromDate;
    return DateTime.now();
  }

  DateTime _getToDate(PettyCashState s) {
    if (s is PettyCashInitial) return s.toDate;
    if (s is PettyCashLoading) return s.toDate;
    if (s is PettyCashLoaded) return s.toDate;
    if (s is PettyCashError) return s.toDate;
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
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : 12,
        vertical:   isTablet ? 12 : 10,
      ),
      decoration: BoxDecoration(
        color: AppTokens.brandLight,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
        border:
        Border.all(color: AppTokens.brandMid.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // From Date
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("From",
                    style: GoogleFonts.lato(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w600)),
                Text(
                  DateFormat("dd-MM-yy").format(fromDate),
                  style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: objfun.FontLow,
                      color: AppTokens.brandDark),
                ),
              ],
            ),
          ),

          _DateBtn(onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: fromDate,
              firstDate: DateTime(1900),
              lastDate: DateTime(2050),
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                    colorScheme: const ColorScheme.light(
                        primary: AppTokens.brandGradientStart)),
                child: child!,
              ),
            );
            if (picked != null && context.mounted) {
              context
                  .read<PettyCashBloc>()
                  .add(SelectFromDateEvent(picked));
            }
          }),

          Container(
            width: 1, height: 30,
            color: AppTokens.brandMid.withOpacity(0.3),
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),

          // To Date
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("To",
                    style: GoogleFonts.lato(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w600)),
                Text(
                  DateFormat("dd-MM-yy").format(toDate),
                  style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: objfun.FontLow,
                      color: AppTokens.brandDark),
                ),
              ],
            ),
          ),

          _DateBtn(onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: toDate,
              firstDate: DateTime(1900),
              lastDate: DateTime(2050),
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                    colorScheme: const ColorScheme.light(
                        primary: AppTokens.brandGradientStart)),
                child: child!,
              ),
            );
            if (picked != null && context.mounted) {
              context
                  .read<PettyCashBloc>()
                  .add(SelectToDateEvent(picked));
            }
          }),

          const SizedBox(width: 8),

          ElevatedButton(
            onPressed: isLoading
                ? null
                : () => context
                .read<PettyCashBloc>()
                .add(const LoadPettyCashEvent()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTokens.brandGradientStart,
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 18 : 14,
                vertical:   isTablet ? 12 : 10,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text("View",
                style: GoogleFonts.lato(
                    color: kWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: objfun.FontLow)),
          ),
        ],
      ),
    );
  }
}

// ── Date Button ───────────────────────────────────────────────────────────────
class _DateBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _DateBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
            color: AppTokens.brandGradientStart,
            borderRadius: BorderRadius.circular(8)),
        child: const Icon(Icons.calendar_month_outlined,
            color: kWhite, size: 18),
      ),
    );
  }
}

// ── Petty Cash Card ───────────────────────────────────────────────────────────
class _PettyCashCard extends StatelessWidget {
  final PattycashMasterModel master;
  final List<PattyCashDetailsModel> details;
  final bool isTablet;
  final bool isSelected;
  final VoidCallback onTap;

  const _PettyCashCard({
    required this.master,
    required this.details,
    required this.isTablet,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.symmetric(
          horizontal: isTablet ? 2 : 4,
          vertical:   isTablet ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius:
          BorderRadius.circular(isTablet ? 12 : 16),
          border: Border.all(
            color: isSelected ? AppTokens.brandGradientStart : AppTokens.brandLight,
            width: isSelected ? 2.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTokens.brandGradientStart
                  .withOpacity(isSelected ? 0.15 : 0.07),
              blurRadius: isSelected ? 14 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 10 : 14),
          child: Row(
            children: [
              Container(
                width: isTablet ? 38 : 46,
                height: isTablet ? 38 : 46,
                decoration: const BoxDecoration(
                    color: AppTokens.brandLight, shape: BoxShape.circle),
                child: Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppTokens.brandGradientStart,
                    size: isTablet ? 20 : 22),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      master.employeeName ?? "-",
                      style: GoogleFonts.lato(
                          fontSize: isTablet ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: AppTokens.brandDark),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      master.cNumberDisplay ?? "-",
                      style: GoogleFonts.lato(
                          fontSize: isTablet ? 12 : 13,
                          color: Colors.grey[600]),
                    ),
                    if (!isTablet)
                      Text(
                        DateFormat('dd-MM-yyyy')
                            .format(master.pettyCashDate),
                        style: GoogleFonts.lato(
                            fontSize: 13,
                            color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 8 : 10,
                  vertical:   isTablet ? 4 : 6,
                ),
                decoration: BoxDecoration(
                    color: AppTokens.brandLight,
                    borderRadius:
                    BorderRadius.circular(10)),
                child: Text(
                  "RM ${master.amount ?? '-'}",
                  style: GoogleFonts.lato(
                      fontSize: isTablet ? 13 : 14,
                      fontWeight: FontWeight.bold,
                      color: AppTokens.brandGradientStart),
                ),
              ),
            ],
          ),
        ),
      ),
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
        border: Border.all(color: AppTokens.brandLight, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: AppTokens.brandGradientStart.withOpacity(0.05),
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
                color: AppTokens.brandLight, shape: BoxShape.circle),
            child: const Icon(Icons.touch_app_rounded,
                color: AppTokens.brandGradientStart, size: 32),
          ),
          const SizedBox(height: 16),
          Text("Select a record",
              style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTokens.brandDark)),
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
class _PettyCashDetailPanel extends StatelessWidget {
  final PattycashMasterModel master;
  final List<PattyCashDetailsModel> details;

  const _PettyCashDetailPanel({
    required this.master,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTokens.brandLight, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: AppTokens.brandGradientStart.withOpacity(0.07),
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
              color: AppTokens.brandGradientStart,
              borderRadius: BorderRadius.only(
                topLeft:  Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(children: [
              const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: kWhite,
                  size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  master.employeeName ?? "Petty Cash Details",
                  style: GoogleFonts.lato(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: kWhite),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
          ),

          // ── Detail rows — Scrollable ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow(Icons.tag_rounded, "C Number",
                      master.cNumberDisplay ?? "-"),
                  _divider(),
                  _infoRow(
                      Icons.calendar_today_rounded,
                      "Date",
                      DateFormat('dd-MM-yyyy')
                          .format(master.pettyCashDate)),
                  _divider(),
                  _infoRow(Icons.payment_rounded,
                      "Payment Status",
                      master.paymentStatus ?? "-"),
                  _divider(),
                  _infoRow(Icons.currency_rupee_rounded,
                      "Amount",
                      "RM ${master.amount ?? '-'}"),

                  if (details.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text("Details",
                        style: GoogleFonts.lato(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTokens.brandDark)),
                    const SizedBox(height: 8),
                    ...details.map((d) => Container(
                      margin: const EdgeInsets.only(
                          bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTokens.brandLight,
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                              "Item: ${d.items ?? '-'}",
                              style: GoogleFonts.lato(
                                  fontWeight:
                                  FontWeight.w600,
                                  color: AppTokens.brandDark)),
                          Text(
                              "Notes: ${d.notes ?? '-'}",
                              style: GoogleFonts.lato(
                                  color:
                                  Colors.grey[700])),
                          Text(
                              "Amount: RM ${d.amount ?? '-'}",
                              style: GoogleFonts.lato(
                                  fontWeight:
                                  FontWeight.bold,
                                  color: AppTokens.brandGradientStart)),
                        ],
                      ),
                    )),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
              color: AppTokens.brandLight,
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: AppTokens.brandGradientStart, size: 15),
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
                      color: AppTokens.brandDark)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider() =>
      Divider(color: AppTokens.brandLight, thickness: 1.5, height: 20);
}

// ── Dialog (Mobile only) ──────────────────────────────────────────────────────
class _PettyCashDialog extends StatelessWidget {
  final PattycashMasterModel master;
  final List<PattyCashDetailsModel> details;

  const _PettyCashDialog({
    required this.master,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight:
            MediaQuery.of(context).size.height * 0.85),
        child: Container(
          decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: 20, horizontal: 24),
                decoration: const BoxDecoration(
                  color: AppTokens.brandGradientStart,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                ),
                child: Row(children: [
                  const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: kWhite,
                      size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      master.employeeName ??
                          "Petty Cash Details",
                      style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: kWhite),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ]),
              ),

              // Body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      _infoRow(Icons.tag_rounded,
                          "C Number",
                          master.cNumberDisplay ?? "-"),
                      _divider(),
                      _infoRow(
                          Icons.calendar_today_rounded,
                          "Date",
                          DateFormat('dd-MM-yyyy')
                              .format(master.pettyCashDate)),
                      _divider(),
                      _infoRow(Icons.payment_rounded,
                          "Payment Status",
                          master.paymentStatus ?? "-"),
                      _divider(),
                      _infoRow(
                          Icons.currency_rupee_rounded,
                          "Amount",
                          "RM ${master.amount ?? '-'}"),

                      if (details.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text("Details",
                            style: GoogleFonts.lato(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTokens.brandDark)),
                        const SizedBox(height: 8),
                        ...details.map((d) => Container(
                          margin: const EdgeInsets.only(
                              bottom: 10),
                          padding:
                          const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTokens.brandLight,
                            borderRadius:
                            BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "Item: ${d.items ?? '-'}",
                                  style: GoogleFonts.lato(
                                      fontWeight:
                                      FontWeight.w600,
                                      color: AppTokens.brandDark)),
                              Text(
                                  "Notes: ${d.notes ?? '-'}",
                                  style: GoogleFonts.lato(
                                      color: Colors
                                          .grey[700])),
                              Text(
                                  "Amount: RM ${d.amount ?? '-'}",
                                  style: GoogleFonts.lato(
                                      fontWeight:
                                      FontWeight.bold,
                                      color: AppTokens.brandGradientStart)),
                            ],
                          ),
                        )),
                      ],

                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTokens.brandGradientStart,
                            padding:
                            const EdgeInsets.symmetric(
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: () =>
                              Navigator.pop(context),
                          child: Text("Close",
                              style: GoogleFonts.lato(
                                  color: kWhite,
                                  fontSize: 16,
                                  fontWeight:
                                  FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
              color: AppTokens.brandLight,
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: AppTokens.brandGradientStart, size: 16),
        ),
        const SizedBox(width: 12),
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
                      color: AppTokens.brandDark)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider() =>
      Divider(color: AppTokens.brandLight, thickness: 1.5, height: 20);
}