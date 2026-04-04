import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import '../../../../../../core/models/model.dart';
import '../../../../../../core/theme/tokens.dart';
import '../bloc/truck_bloc.dart';
import '../bloc/truck_state.dart';
import 'package:maleva/core/colors/colors.dart' as colour;

class TruckDetailsReportPage extends StatelessWidget {
  const TruckDetailsReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => TruckDetailsBloc(context: ctx)
        ..add(const LoadTruckDetailsEvent()),
      child: const _TruckReportView(),
    );
  }
}

class _TruckReportView extends StatelessWidget {
  const _TruckReportView();

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return BlocConsumer<TruckDetailsBloc, TruckDetailsState>(
      listener: (context, state) {
        if (state is TruckErrorState) {
          objfun.msgshow(
            state.errorMessage, '',
            colour.kWhite, AppTokens.brandGradientStart, null,
            18.00 - objfun.reducesize,
            objfun.tll, objfun.tgc, context, 2,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is TruckLoadingState;
        final truckList = state is TruckLoadedState
            ? state.truckData
            : <TruckDetailsModel>[];

        return Container(
          color: const Color(0xFFF4F6FF),
          child: isTablet
              ? _buildTabletLayout(context, isLoading, truckList)
              : _buildMobileLayout(context, isLoading, truckList),
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
      List<TruckDetailsModel> truckList,
      ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── LEFT (30%) — Header + Count Badge
          Expanded(
            flex: 30,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(isTablet: true),
                  const SizedBox(height: 20),
                  _CountBadge(count: truckList.length),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          const SizedBox(width: 16),

          // ── RIGHT (70%) — Truck Grid
          Expanded(
            flex: 70,
            child: isLoading
                ? const Center(
                child: CircularProgressIndicator(
                    color: AppTokens.brandGradientStart))
                : truckList.isEmpty
                ? const _EmptyState(isTablet: true)
                : GridView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:   2,
                crossAxisSpacing: 12,
                mainAxisSpacing:  12,
                childAspectRatio: 3.2,
              ),
              itemCount: truckList.length,
              itemBuilder: (context, index) {
                return _TruckCard(
                  truck:    truckList[index],
                  index:    index,
                  isTablet: true,
                );
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
  Widget _buildMobileLayout(
      BuildContext context,
      bool isLoading,
      List<TruckDetailsModel> truckList,
      ) {
    return Column(
      children: [
        _Header(isTablet: false),
        const SizedBox(height: 4),
        Expanded(
          child: isLoading
              ? const Center(
              child: CircularProgressIndicator(
                  color: AppTokens.brandGradientStart))
              : truckList.isEmpty
              ? const _EmptyState(isTablet: false)
              : ListView.builder(
            padding:
            const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: truckList.length,
            itemBuilder: (context, index) {
              return _TruckCard(
                truck:    truckList[index],
                index:    index,
                isTablet: false,
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final bool isTablet;
  const _Header({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isTablet ? 0 : 20,
        isTablet ? 0 : 20,
        isTablet ? 0 : 20,
        isTablet ? 0 : 16,
      ),
      child: Row(children: [
        Container(
          width: 4,
          height: isTablet ? 30 : 26,
          decoration: BoxDecoration(
            color: AppTokens.brandGradientStart,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'TRUCK DETAILS',
          style: GoogleFonts.poppins(
            fontSize:      isTablet ? 20 : 17,
            fontWeight:    FontWeight.w700,
            color:         AppTokens.brandDark,
            letterSpacing: 1.2,
          ),
        ),
      ]),
    );
  }
}

// ─── Count Badge (Tablet left panel) ─────────────────────────────────────────
class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTokens.brandGradientStart, AppTokens.brandDark],
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:     AppTokens.brandGradientStart.withOpacity(0.30),
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
          child: const Icon(Icons.local_shipping_rounded,
              color: colour.kWhite, size: 22),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Trucks',
                style: GoogleFonts.poppins(
                  fontSize:   12,
                  color:      colour.kWhite.withOpacity(0.75),
                  fontWeight: FontWeight.w500,
                )),
            Text('$count',
                style: GoogleFonts.poppins(
                  fontSize:   28,
                  color:      colour.kWhite,
                  fontWeight: FontWeight.w700,
                )),
          ],
        ),
      ]),
    );
  }
}

// ─── Truck Card ───────────────────────────────────────────────────────────────
class _TruckCard extends StatelessWidget {
  final TruckDetailsModel truck;
  final int index;
  final bool isTablet;

  const _TruckCard({
    required this.truck,
    required this.index,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final isEven = index % 2 == 0;

    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 0 : 10),
      child: Material(
        color: isEven ? colour.kWhite : AppTokens.brandLight,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 16),
        child: InkWell(
          borderRadius: BorderRadius.circular(isTablet ? 16 : 16),
          splashColor: AppTokens.brandGradientStart.withOpacity(0.08),
          onTap: () => _showTruckDialog(context, truck, isTablet),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 12 : 14,
              vertical:   isTablet ? 10 : 14,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isEven
                    ? AppTokens.brandLight
                    : AppTokens.brandMid.withOpacity(0.3),
                width: 1.2,
              ),
              boxShadow: isEven
                  ? [
                BoxShadow(
                  color:     AppTokens.brandGradientStart.withOpacity(0.05),
                  blurRadius: 8,
                  offset:    const Offset(0, 3),
                )
              ]
                  : [],
            ),
            child: Row(children: [
              // Icon badge
              Container(
                width:  isTablet ? 36 : 42,
                height: isTablet ? 36 : 42,
                decoration: BoxDecoration(
                  color: isEven
                      ? AppTokens.brandLight
                      : AppTokens.brandGradientStart.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(isTablet ? 10 : 12),
                ),
                child: Icon(Icons.local_shipping_rounded,
                    color: AppTokens.brandGradientStart,
                    size: isTablet ? 18 : 22),
              ),
              const SizedBox(width: 10),

              // Truck number
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      truck.TruckNumber.isNotEmpty
                          ? truck.TruckNumber
                          : '-',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize:   isTablet ? 13 : 14,
                        fontWeight: FontWeight.w700,
                        color:      AppTokens.brandDark,
                      ),
                    ),
                    if (!isTablet) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Tap to view expiry details',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color:
                          AppTokens.brandMid.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isEven
                      ? AppTokens.brandLight
                      : AppTokens.brandGradientStart.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.chevron_right_rounded,
                    color: AppTokens.brandGradientStart,
                    size: isTablet ? 16 : 18),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  void _showTruckDialog(
      BuildContext context, TruckDetailsModel truck, bool isTablet) {
    final expiryItems = [
      {'label': 'Apad Expiry',        'date': truck.ApadExp},
      {'label': 'RotexMy Expiry',     'date': truck.RotexMyExp},
      {'label': 'RotexSG Expiry',     'date': truck.RotexSGExp},
      {'label': 'Puspacom Expiry',    'date': truck.PuspacomExp},
      {'label': 'Insurance Expiry',   'date': truck.InsuratnceExp},
      {'label': 'Bonam Expiry',       'date': truck.BonamExp},
      {'label': 'PTP Sticker Expiry', 'date': truck.PTPStickerExp},
      {'label': 'SID Expiry',         'date': truck.SIDExp},
    ];

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: isTablet ? 420 : double.infinity,
          padding: EdgeInsets.all(isTablet ? 24 : 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dialog header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isTablet ? 18 : 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTokens.brandGradientStart, AppTokens.brandDark],
                    begin: Alignment.topLeft,
                    end:   Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colour.kWhite.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.local_shipping_rounded,
                        color: colour.kWhite,
                        size: isTablet ? 22 : 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Truck Info',
                            style: GoogleFonts.poppins(
                                color:    colour.kWhite.withOpacity(0.8),
                                fontSize: isTablet ? 12 : 11)),
                        Text(
                          truck.TruckNumber.isNotEmpty
                              ? truck.TruckNumber
                              : '-',
                          style: GoogleFonts.poppins(
                            color:      colour.kWhite,
                            fontSize:   isTablet ? 17 : 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 16),

              // Expiry rows
              ...expiryItems.map((e) => _ExpiryRow(
                label:   e['label'] as String,
                rawDate: e['date'] as String?,
                isTablet: isTablet,
              )),

              const SizedBox(height: 12),

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTokens.brandGradientStart,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(
                        vertical: isTablet ? 14 : 12),
                    elevation: 0,
                  ),
                  child: Text('Close',
                      style: GoogleFonts.poppins(
                          color:      colour.kWhite,
                          fontSize:   isTablet ? 14 : 13,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Expiry Row ───────────────────────────────────────────────────────────────
class _ExpiryRow extends StatelessWidget {
  final String label;
  final String? rawDate;
  final bool isTablet;

  const _ExpiryRow({
    required this.label,
    required this.rawDate,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = TruckDetailsBloc.formatTruckDate(rawDate);
    final color     = TruckDetailsBloc.expiryColor(rawDate);

    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 10 : 8),
      child: Row(children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
              color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label,
              style: GoogleFonts.poppins(
                fontSize:   isTablet ? 13 : 12,
                color:      AppTokens.brandDark,
                fontWeight: FontWeight.w500,
              )),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 12 : 10,
            vertical:   isTablet ? 5  : 4,
          ),
          decoration: BoxDecoration(
            color:         color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border:        Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(formatted,
              style: GoogleFonts.poppins(
                fontSize:   isTablet ? 12 : 11,
                fontWeight: FontWeight.w600,
                color:      color,
              )),
        ),
      ]),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isTablet;
  const _EmptyState({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(isTablet ? 26 : 22),
          decoration: const BoxDecoration(
              color: AppTokens.brandLight, shape: BoxShape.circle),
          child: Icon(Icons.local_shipping_outlined,
              size:  isTablet ? 52 : 44,
              color: AppTokens.brandGradientStart),
        ),
        SizedBox(height: isTablet ? 20 : 16),
        Text('No Trucks Found',
            style: GoogleFonts.poppins(
              fontSize:   isTablet ? 17 : 15,
              fontWeight: FontWeight.w700,
              color:      AppTokens.brandDark,
            )),
        SizedBox(height: isTablet ? 8 : 6),
        Text('No truck data available at the moment.',
            style: GoogleFonts.poppins(
                fontSize: isTablet ? 13 : 12,
                color:    AppTokens.brandMid)),
      ],
    );
  }
}