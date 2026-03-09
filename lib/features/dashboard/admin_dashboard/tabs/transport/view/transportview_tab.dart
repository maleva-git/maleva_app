import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import '../../../../../../Transaction/SaleOrder/SalesOrderAdd.dart';
import '../bloc/transport_bloc.dart';
import '../bloc/transport_event.dart';
import '../bloc/transport_state.dart';

// ─── Page ───────────────────────────────────────────────────────────────────────
class TransportReportPage extends StatelessWidget {
  const TransportReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransportBloc(context: context)
        ..add(const LoadTransportDataEvent(type: 0)),
      child: const _TransportReportView(),
    );
  }
}

// ─── View ────────────────────────────────────────────────────────────────────────
class _TransportReportView extends StatelessWidget {
  const _TransportReportView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransportBloc, TransportState>(
      listener: (context, state) {
        // ── Error → top banner (via your msgshow) ────────────────────────────
        if (state is TransportErrorState) {
          objfun.msgshow(
            state.errorMessage, '',
            Colors.white,
            const Color(0xFF1555F3),
            null,
            18.00 - objfun.reducesize,
            objfun.tll, objfun.tgc,
            context, 2,
          );
        }

        // ── Navigate to Edit screen ──────────────────────────────────────────
        if (state is TransportNavigateToEditState) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => SalesOrderAdd(
              SaleDetails: objfun.SaleEditDetailList,
              SaleMaster:  objfun.SaleEditMasterList,
            ),
          ));
        }
      },
      builder: (context, state) {
        final isLoading     = state is TransportLoadingState;
        final isPlanToday   = state is TransportLoadedState ? state.isPlanToday : true;
        final transportList = state is TransportLoadedState
            ? state.transportList
            : <Map<String, dynamic>>[];

        return Container(
          color: const Color(0xFFF4F6FF),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            children: [
              // ── Header ───────────────────────────────────────────────────
              _SectionHeader(title: 'Transport Report'),
              const SizedBox(height: 16),

              // ── Today / Tomorrow Toggle ───────────────────────────────────
              _DayToggle(
                isPlanToday: isPlanToday,
                onToday: () => context
                    .read<TransportBloc>()
                    .add(const LoadTransportDataEvent(type: 0)),
                onTomorrow: () => context
                    .read<TransportBloc>()
                    .add(const LoadTransportDataEvent(type: 1)),
              ),
              const SizedBox(height: 16),

              // ── List Header ───────────────────────────────────────────────
              _ListHeader(),
              const SizedBox(height: 8),

              // ── List ──────────────────────────────────────────────────────
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF1555F3))),
                )
              else if (transportList.isEmpty)
                const _EmptyState()
              else
                ...List.generate(transportList.length, (index) {
                  final item = transportList[index];
                  return _TransportCard(
                    index:        index,
                    customerName: item["CustomerName"]?.toString() ?? '-',
                    item:         item,
                    onTap: () => _showDetailDialog(context, item),
                    onLongPress: () => context
                        .read<TransportBloc>()
                        .add(LongPressTransportItemEvent(
                        id: item["Id"] as int)),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  // ── Detail Dialog ────────────────────────────────────────────────────────────
  void _showDetailDialog(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dialog header — fixed (scroll பண்ண வேண்டாம்)
              Row(
                children: [
                  Container(
                    width: 4, height: 22,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1555F3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item["CustomerName"]?.toString() ?? '-',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0D3DB5),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: Color(0xFF4D7EF7), size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFE8EEFF)),
              const SizedBox(height: 12),

              // ✅ Scrollable content
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...item.entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                e.key,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: const Color(0xFF4D7EF7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                e.value?.toString() ?? '-',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0D3DB5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
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
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4, height: 26,
          decoration: BoxDecoration(
            color: const Color(0xFF1555F3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0D3DB5),
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

// ─── Day Toggle ───────────────────────────────────────────────────────────────
class _DayToggle extends StatelessWidget {
  final bool isPlanToday;
  final VoidCallback onToday;
  final VoidCallback onTomorrow;

  const _DayToggle({
    required this.isPlanToday,
    required this.onToday,
    required this.onTomorrow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEFF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _ToggleTab(label: 'Today',    isActive: isPlanToday,  onTap: onToday),
          _ToggleTab(label: 'Tomorrow', isActive: !isPlanToday, onTap: onTomorrow),
        ],
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleTab(
      {required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF1555F3) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
              BoxShadow(
                color: const Color(0xFF1555F3).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
            ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : const Color(0xFF4D7EF7),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── List Header ──────────────────────────────────────────────────────────────
class _ListHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1555F3), Color(0xFF0D3DB5)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text('#',
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.8))),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Customer Name',
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── Transport Card ───────────────────────────────────────────────────────────
class _TransportCard extends StatelessWidget {
  final int index;
  final String customerName;
  final Map<String, dynamic> item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _TransportCard({
    required this.index,
    required this.customerName,
    required this.item,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isEven = index % 2 == 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isEven ? Colors.white : const Color(0xFFE8EEFF),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(14),
          splashColor: const Color(0xFF1555F3).withOpacity(0.08),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isEven
                    ? const Color(0xFFE8EEFF)
                    : const Color(0xFF4D7EF7).withOpacity(0.3),
                width: 1.2,
              ),
              boxShadow: isEven
                  ? [
                BoxShadow(
                  color: const Color(0xFF1555F3).withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ]
                  : [],
            ),
            child: Row(
              children: [
                // Index badge
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: isEven
                        ? const Color(0xFFE8EEFF)
                        : const Color(0xFF1555F3).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1555F3)),
                  ),
                ),
                const SizedBox(width: 10),

                // Customer name
                Expanded(
                  child: Text(
                    customerName,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0D3DB5)),
                  ),
                ),

                // Arrow hint
                const Icon(Icons.chevron_right_rounded,
                    color: Color(0xFF4D7EF7), size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFE8EEFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_shipping_outlined,
                size: 40, color: Color(0xFF1555F3)),
          ),
          const SizedBox(height: 16),
          Text(
            'No Transport Found',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0D3DB5),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'No data available for the selected date.',
            style: GoogleFonts.poppins(
                fontSize: 12, color: const Color(0xFF4D7EF7)),
          ),
        ],
      ),
    );
  }
}