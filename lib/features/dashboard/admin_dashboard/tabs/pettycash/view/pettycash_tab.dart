import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import '../../../../../../core/colors/colors.dart';
import '../bloc/pettycash_bloc.dart';
import '../bloc/pettycash_event.dart';
import '../bloc/pettycash_state.dart';



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

class _PettyCashBody extends StatelessWidget {
  const _PettyCashBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PettyCashBloc, PettyCashState>(
      builder: (context, state) {
        // Current dates from any state
        final fromDate = _getFromDate(state);
        final toDate = _getToDate(state);

        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [

              Text(
                "Petty Cash",
                style: GoogleFonts.lato(
                  fontSize: objfun.FontLarge,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryDark,
                ),
              ),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: kAccent,
                  borderRadius: BorderRadius.circular(14),
                  border:
                  Border.all(color: kPrimaryLight.withOpacity(0.3)),
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
                                color: kPrimaryDark),
                          ),
                        ],
                      ),
                    ),

                    // From Date Picker
                    _DateBtn(onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: fromDate,
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2050),
                        builder: (ctx, child) => Theme(
                          data: Theme.of(ctx).copyWith(
                              colorScheme: const ColorScheme.light(
                                  primary: kPrimary)),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        context
                            .read<PettyCashBloc>()
                            .add(SelectFromDateEvent(picked));
                      }
                    }),

                    Container(
                      width: 1,
                      height: 30,
                      color: kPrimaryLight.withOpacity(0.3),
                      margin:
                      const EdgeInsets.symmetric(horizontal: 8),
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
                                color: kPrimaryDark),
                          ),
                        ],
                      ),
                    ),

                    // To Date Picker
                    _DateBtn(onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: toDate,
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2050),
                        builder: (ctx, child) => Theme(
                          data: Theme.of(ctx).copyWith(
                              colorScheme: const ColorScheme.light(
                                  primary: kPrimary)),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        context
                            .read<PettyCashBloc>()
                            .add(SelectToDateEvent(picked));
                      }
                    }),

                    const SizedBox(width: 8),

                    // View Button
                    ElevatedButton(
                      onPressed: state is PettyCashLoading
                          ? null
                          : () => context
                          .read<PettyCashBloc>()
                          .add(const LoadPettyCashEvent()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
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
              ),

              const SizedBox(height: 10),

              Expanded(child: _buildContent(context, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, PettyCashState state) {
    // Loading
    if (state is PettyCashLoading) {
      return const Center(
          child: CircularProgressIndicator(color: kPrimary));
    }

    // Error
    if (state is PettyCashError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(state.message,
                textAlign: TextAlign.center,
                style:
                GoogleFonts.lato(color: Colors.red, fontSize: 14)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context
                  .read<PettyCashBloc>()
                  .add(const LoadPettyCashEvent()),
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
            ),
          ],
        ),
      );
    }

    // Initial — show prompt
    if (state is PettyCashInitial) {
      return Center(
        child: Text(
          "Select dates and press View",
          style: GoogleFonts.lato(fontSize: 15, color: Colors.grey),
        ),
      );
    }

    // Loaded
    if (state is PettyCashLoaded) {
      if (state.masterRecords.isEmpty) {
        return Center(
          child: Text("No records found",
              style: GoogleFonts.lato(fontSize: 16, color: Colors.grey)),
        );
      }

      return ListView.builder(
        itemCount: state.masterRecords.length,
        itemBuilder: (context, index) {
          final master = state.masterRecords[index];
          final related = state.detailRecords
              .where((d) => d.pettyCashMasterRefId == master.Id)
              .toList();

          return _PettyCashCard(master: master, details: related);
        },
      );
    }

    return const SizedBox.shrink();
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


class _DateBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _DateBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: kPrimary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.calendar_month_outlined,
            color: kWhite, size: 18),
      ),
    );
  }
}


class _PettyCashCard extends StatelessWidget {
  final PattycashMasterModel master;
  final List<PattyCashDetailsModel> details;

  const _PettyCashCard({required this.master, required this.details});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDialog(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kAccent, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: kPrimary.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Icon
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                    color: kAccent, shape: BoxShape.circle),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    color: kPrimary, size: 22),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      master.employeeName ?? "-",
                      style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      master.cNumberDisplay ?? "-",
                      style: GoogleFonts.lato(
                          fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('dd-MM-yyyy').format(master.pettyCashDate),
                      style: GoogleFonts.lato(
                          fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              // Amount badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: kAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "RM ${master.amount ?? '-'}",
                  style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: kPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85),
          child: Container(
            decoration: BoxDecoration(
                color: kWhite, borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 20, horizontal: 24),
                  decoration: const BoxDecoration(
                    color: kPrimary,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: kWhite,
                          size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          master.employeeName ?? "Petty Cash Details",
                          style: GoogleFonts.lato(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: kWhite),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable body
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
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
                        _infoRow(Icons.payment_rounded, "Payment Status",
                            master.paymentStatus ?? "-"),
                        _divider(),
                        _infoRow(Icons.currency_rupee_rounded, "Amount",
                            "RM ${master.amount ?? '-'}"),

                        if (details.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text("Details",
                              style: GoogleFonts.lato(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryDark)),
                          const SizedBox(height: 8),
                          ...details.map((d) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: kAccent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text("Item: ${d.items ?? '-'}",
                                    style: GoogleFonts.lato(
                                        fontWeight: FontWeight.w600,
                                        color: kPrimaryDark)),
                                Text("Notes: ${d.notes ?? '-'}",
                                    style: GoogleFonts.lato(
                                        color: Colors.grey[700])),
                                Text(
                                    "Amount: RM ${d.amount ?? '-'}",
                                    style: GoogleFonts.lato(
                                        fontWeight: FontWeight.bold,
                                        color: kPrimary)),
                              ],
                            ),
                          )),
                        ],

                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimary,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text("Close",
                                style: GoogleFonts.lato(
                                    color: kWhite,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
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
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
              color: kAccent, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: kPrimary, size: 16),
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
                      color: kPrimaryDark)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider() => Divider(color: kAccent, thickness: 1.5, height: 20);
}