import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import '../../../../../../Transaction/SaleOrder/SalesOrderAdd.dart';
import '../bloc/transport_bloc.dart';
import '../bloc/transport_event.dart';
import '../bloc/transport_state.dart';

// ─── Constants ─────────────────────────────────────────────────────────────────


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
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return BlocConsumer<TransportBloc, TransportState>(
      listener: (context, state) {
        if (state is TransportErrorState) {
          objfun.msgshow(
            state.errorMessage, '',
            Colors.white,
            colour.kBlue,
            null,
            18.00 - objfun.reducesize,
            objfun.tll, objfun.tgc,
            context, 2,
          );
        }
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
        final isPlanToday   = state is TransportLoadedState
            ? state.isPlanToday
            : true;
        final transportList = state is TransportLoadedState
            ? state.transportList
            : <Map<String, dynamic>>[];

        return Container(
          color: colour.kBg,
          child: isTablet
              ? _buildTabletLayout(
              context, isLoading, isPlanToday, transportList)
              : _buildMobileLayout(
              context, isLoading, isPlanToday, transportList),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════
  // TABLET — Two Column
  // ══════════════════════════════════════════════════════
  Widget _buildTabletLayout(
      BuildContext context,
      bool isLoading,
      bool isPlanToday,
      List<Map<String, dynamic>> transportList,
      ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── LEFT (35%) — Header + Toggle + Stats
          Expanded(
            flex: 35,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(title: 'Transport Report', isTablet: true),
                  const SizedBox(height: 20),

                  _DayToggle(
                    isPlanToday: isPlanToday,
                    isTablet:    true,
                    onToday: () => context
                        .read<TransportBloc>()
                        .add(const LoadTransportDataEvent(type: 0)),
                    onTomorrow: () => context
                        .read<TransportBloc>()
                        .add(const LoadTransportDataEvent(type: 1)),
                  ),
                  const SizedBox(height: 20),

                  // ── Count badge
                  _CountBadge(
                    count:    transportList.length,
                    isTablet: true,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          const SizedBox(width: 16),

          // ── RIGHT (65%) — List
          Expanded(
            flex: 65,
            child: Column(
              children: [
                _ListHeader(isTablet: true),
                const SizedBox(height: 10),
                Expanded(
                  child: isLoading
                      ? const Center(
                      child: CircularProgressIndicator(
                          color: colour.kBlue))
                      : transportList.isEmpty
                      ? const _EmptyState(isTablet: true)
                      : ListView.builder(
                    physics:
                    const BouncingScrollPhysics(),
                    itemCount: transportList.length,
                    itemBuilder: (context, index) {
                      final item = transportList[index];
                      return _TransportCard(
                        index: index,
                        customerName: item["CustomerName"]
                            ?.toString() ??
                            '-',
                        item:        item,
                        isTablet:    true,
                        onTap: () => _showDetailDialog(
                            context, item),
                        onLongPress: () => context
                            .read<TransportBloc>()
                            .add(LongPressTransportItemEvent(
                            id: item["Id"] as int)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // MOBILE — Single Column
  // ══════════════════════════════════════════════════════
  Widget _buildMobileLayout(
      BuildContext context,
      bool isLoading,
      bool isPlanToday,
      List<Map<String, dynamic>> transportList,
      ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      children: [
        _SectionHeader(title: 'Transport Report', isTablet: false),
        const SizedBox(height: 16),

        _DayToggle(
          isPlanToday: isPlanToday,
          isTablet:    false,
          onToday: () => context
              .read<TransportBloc>()
              .add(const LoadTransportDataEvent(type: 0)),
          onTomorrow: () => context
              .read<TransportBloc>()
              .add(const LoadTransportDataEvent(type: 1)),
        ),
        const SizedBox(height: 16),

        _ListHeader(isTablet: false),
        const SizedBox(height: 8),

        if (isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Center(
                child: CircularProgressIndicator(color: colour.kBlue)),
          )
        else if (transportList.isEmpty)
          const _EmptyState(isTablet: false)
        else
          ...List.generate(transportList.length, (index) {
            final item = transportList[index];
            return _TransportCard(
              index:        index,
              customerName: item["CustomerName"]?.toString() ?? '-',
              item:         item,
              isTablet:     false,
              onTap:        () => _showDetailDialog(context, item),
              onLongPress:  () => context
                  .read<TransportBloc>()
                  .add(LongPressTransportItemEvent(
                  id: item["Id"] as int)),
            );
          }),
      ],
    );
  }

  // ── Detail Dialog (unchanged) ─────────────────────────────────────────────
  void _showDetailDialog(
      BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 4, height: 22,
                  decoration: BoxDecoration(
                    color: colour.kBlue,
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
                      color: colour.kHeaderGradStart,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: colour.kHeaderGradStart, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ]),
              const SizedBox(height: 12),
              const Divider(color: colour.kBlueBg),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight:
                  MediaQuery.of(context).size.height * 0.6,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...item.entries.map((e) => Padding(
                        padding:
                        const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(e.key,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: colour.kHeaderGradStart,
                                    fontWeight: FontWeight.w500,
                                  )),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                  e.value?.toString() ?? '-',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: colour.kHeaderGradStart,
                                  )),
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
  final bool isTablet;
  const _SectionHeader(
      {required this.title, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 4,
        height: isTablet ? 30 : 26,
        decoration: BoxDecoration(
          color: colour.kBlue,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      const SizedBox(width: 10),
      Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize:      isTablet ? 20 : 17,
          fontWeight:    FontWeight.w700,
          color:         colour.kHeaderGradStart,
          letterSpacing: 1.2,
        ),
      ),
    ]);
  }
}

// ─── Count Badge (Tablet only left panel-ல காட்டும்) ─────────────────────────
class _CountBadge extends StatelessWidget {
  final int count;
  final bool isTablet;
  const _CountBadge({required this.count, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [colour.kBlue, colour.kHeaderGradStart],
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:     colour.kBlue.withOpacity(0.30),
            blurRadius: 16,
            offset:    const Offset(0, 6),
          ),
        ],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color:         Colors.white.withOpacity(0.20),
            shape:         BoxShape.circle,
          ),
          child: const Icon(Icons.local_shipping_outlined,
              color: Colors.white, size: 22),
        ),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Total Records',
              style: GoogleFonts.poppins(
                fontSize:   12,
                color:      Colors.white.withOpacity(0.75),
                fontWeight: FontWeight.w500,
              )),
          Text('$count',
              style: GoogleFonts.poppins(
                fontSize:   26,
                color:      Colors.white,
                fontWeight: FontWeight.w700,
              )),
        ]),
      ]),
    );
  }
}

// ─── Day Toggle ───────────────────────────────────────────────────────────────
class _DayToggle extends StatelessWidget {
  final bool isPlanToday;
  final bool isTablet;
  final VoidCallback onToday;
  final VoidCallback onTomorrow;

  const _DayToggle({
    required this.isPlanToday,
    required this.isTablet,
    required this.onToday,
    required this.onTomorrow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isTablet ? 52 : 44,
      decoration: BoxDecoration(
        color:         colour.kBlueBg,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
      ),
      child: Row(children: [
        _ToggleTab(
            label:    'Today',
            isActive: isPlanToday,
            isTablet: isTablet,
            onTap:    onToday),
        _ToggleTab(
            label:    'Tomorrow',
            isActive: !isPlanToday,
            isTablet: isTablet,
            onTap:    onTomorrow),
      ]),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isTablet;
  final VoidCallback onTap;

  const _ToggleTab({
    required this.label,
    required this.isActive,
    required this.isTablet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin:   const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive ? colour.kHeaderGradStart : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
              BoxShadow(
                color:     colour.kHeaderGradStart.withOpacity(0.3),
                blurRadius: 8,
                offset:    const Offset(0, 3),
              )
            ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize:   isTablet ? 14 : 13,
              fontWeight: FontWeight.w600,
              color:      isActive ? Colors.white : colour.kBlueL,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── List Header ──────────────────────────────────────────────────────────────
class _ListHeader extends StatelessWidget {
  final bool isTablet;
  const _ListHeader({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 16,
        vertical:   isTablet ? 13 : 10,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [colour.kHeaderGradStart, colour.kHeaderGradStart],
          begin: Alignment.centerLeft,
          end:   Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      ),
      child: Row(children: [
        SizedBox(
          width: isTablet ? 36 : 32,
          child: Text('#',
              style: GoogleFonts.poppins(
                  fontSize:   isTablet ? 13 : 12,
                  fontWeight: FontWeight.w700,
                  color:      Colors.white.withOpacity(0.8))),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text('Customer Name',
              style: GoogleFonts.poppins(
                  fontSize:   isTablet ? 13 : 12,
                  fontWeight: FontWeight.w700,
                  color:      Colors.white)),
        ),
      ]),
    );
  }
}

// ─── Transport Card ───────────────────────────────────────────────────────────
class _TransportCard extends StatelessWidget {
  final int index;
  final String customerName;
  final Map<String, dynamic> item;
  final bool isTablet;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _TransportCard({
    required this.index,
    required this.customerName,
    required this.item,
    required this.isTablet,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isEven = index % 2 == 0;

    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 10 : 8),
      child: Material(
        color: isEven ? Colors.white : colour.kBlueBg,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
        child: InkWell(
          onTap:        onTap,
          onLongPress:  onLongPress,
          borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
          splashColor:  colour.kBlue.withOpacity(0.08),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 18 : 14,
              vertical:   isTablet ? 14 : 12,
            ),
            decoration: BoxDecoration(
              borderRadius:
              BorderRadius.circular(isTablet ? 16 : 14),
              border: Border.all(
                color: isEven
                    ? colour.kBlueBg
                    : colour.kBlueL.withOpacity(0.3),
                width: 1.2,
              ),
              boxShadow: isEven
                  ? [
                BoxShadow(
                  color:     colour.kBlue.withOpacity(0.05),
                  blurRadius: 6,
                  offset:    const Offset(0, 2),
                )
              ]
                  : [],
            ),
            child: Row(children: [
              // Index badge
              Container(
                width:  isTablet ? 32 : 28,
                height: isTablet ? 32 : 28,
                decoration: BoxDecoration(
                  color: isEven
                      ? colour.kBlueBg
                      : colour.kBlue.withOpacity(0.12),
                  borderRadius:
                  BorderRadius.circular(isTablet ? 10 : 8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: GoogleFonts.poppins(
                      fontSize:   isTablet ? 12 : 11,
                      fontWeight: FontWeight.w700,
                      color:      colour.kBlue),
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
                      fontSize:   isTablet ? 14 : 13,
                      fontWeight: FontWeight.w600,
                      color:      colour.kHeaderGradStart),
                ),
              ),

              // Arrow
              Icon(Icons.chevron_right_rounded,
                  color: colour.kBlueL,
                  size:  isTablet ? 22 : 18),
            ]),
          ),
        ),
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
    return Padding(
      padding: EdgeInsets.only(top: isTablet ? 60 : 48),
      child: Column(children: [
        Container(
          padding: EdgeInsets.all(isTablet ? 24 : 20),
          decoration: const BoxDecoration(
              color: colour.kBlueBg, shape: BoxShape.circle),
          child: Icon(Icons.local_shipping_outlined,
              size:  isTablet ? 48 : 40,
              color: colour.kBlue),
        ),
        SizedBox(height: isTablet ? 20 : 16),
        Text('No Transport Found',
            style: GoogleFonts.poppins(
              fontSize:   isTablet ? 17 : 15,
              fontWeight: FontWeight.w700,
              color:      colour.kHeaderGradStart,
            )),
        SizedBox(height: isTablet ? 8 : 6),
        Text('No data available for the selected date.',
            style: GoogleFonts.poppins(
                fontSize: isTablet ? 13 : 12,
                color:    colour.kBlueL)),
      ]),
    );
  }
}