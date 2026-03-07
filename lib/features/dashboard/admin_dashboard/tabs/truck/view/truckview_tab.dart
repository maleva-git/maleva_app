import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import '../../../../../../core/models/model.dart';
import '../bloc/truck_bloc.dart';
import '../bloc/truck_state.dart';
import 'package:maleva/core/colors/colors.dart' as colour;


class TruckDetailsReportPage extends StatelessWidget {
  const TruckDetailsReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => TruckDetailsBloc(context: ctx)..add(const LoadTruckDetailsEvent()),
      child: const _TruckReportView(),
    );
  }
}


class _TruckReportView extends StatelessWidget {
  const _TruckReportView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TruckDetailsBloc, TruckDetailsState>(
      listener: (context, state) {
        if (state is TruckErrorState) {
          objfun.msgshow(
            state.errorMessage, '',
            colour.kWhite,
            colour.kPrimary,
            null,
            18.00 - objfun.reducesize,
            objfun.tll, objfun.tgc,
            context, 2,
          );
        }
      },
      builder: (context, state) {
        final isLoading  = state is TruckLoadingState;
        final truckList  = state is TruckLoadedState ? state.truckData : <TruckDetailsModel>[];

        return Container(
          color: const Color(0xFFF4F6FF),
          child: Column(
            children: [
              // ── Header ────────────────────────────────────────────────────
              _Header(),
              const SizedBox(height: 4),

              // ── List ──────────────────────────────────────────────────────
              Expanded(
                child: isLoading
                    ? const Center(
                    child: CircularProgressIndicator(color: colour.kPrimary))
                    : truckList.isEmpty
                    ? const _EmptyState()
                    : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: truckList.length,
                  itemBuilder: (context, index) {
                    return _TruckCard(
                      truck: truckList[index],
                      index: index,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          Container(
            width: 4, height: 26,
            decoration: BoxDecoration(
              color: colour.kPrimary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'TRUCK DETAILS',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: colour.kPrimaryDark,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Truck Card ───────────────────────────────────────────────────────────────
class _TruckCard extends StatelessWidget {
  final TruckDetailsModel truck;
  final int index;

  const _TruckCard({required this.truck, required this.index});

  @override
  Widget build(BuildContext context) {
    final isEven = index % 2 == 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isEven ? colour.kWhite : colour.kAccent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: colour.kPrimary.withOpacity(0.08),
          onTap: () => _showTruckDialog(context, truck),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isEven
                    ? colour.kAccent
                    : colour.kPrimaryLight.withOpacity(0.3),
                width: 1.2,
              ),
              boxShadow: isEven
                  ? [
                BoxShadow(
                  color: colour.kPrimary.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ]
                  : [],
            ),
            child: Row(
              children: [
                // ── Truck Icon Badge ────────────────────────────────────
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: isEven
                        ? colour.kAccent
                        : colour.kPrimary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_shipping_rounded,
                    color: colour.kPrimary, size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // ── Truck Number ────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        truck.TruckNumber.isNotEmpty
                            ? truck.TruckNumber
                            : '-',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colour.kPrimaryDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap to view expiry details',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: colour.kPrimaryLight.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Arrow ───────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isEven ? colour.kAccent : colour.kPrimary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: colour.kPrimary, size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Truck Detail Dialog ──────────────────────────────────────────────────────
  void _showTruckDialog(BuildContext context, TruckDetailsModel truck) {
    final expiryItems = [
      {'label': 'Apad Expiry',          'date': truck.ApadExp},
      {'label': 'RotexMy Expiry',       'date': truck.RotexMyExp},
      {'label': 'RotexSG Expiry',       'date': truck.RotexSGExp},
      {'label': 'Puspacom Expiry',      'date': truck.PuspacomExp},
      {'label': 'Insurance Expiry',     'date': truck.InsuratnceExp},
      {'label': 'Bonam Expiry',         'date': truck.BonamExp},
      {'label': 'PTP Sticker Expiry',   'date': truck.PTPStickerExp},
      {'label': 'SID Expiry',           'date': truck.SIDExp},
    ];

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Dialog Header ─────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [colour.kPrimary, colour.kPrimaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colour.kWhite.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.local_shipping_rounded,
                          color: colour.kWhite, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Truck Info',
                              style: GoogleFonts.poppins(
                                  color: colour.kWhite.withOpacity(0.8),
                                  fontSize: 11)),
                          Text(
                            truck.TruckNumber.isNotEmpty
                                ? truck.TruckNumber
                                : '-',
                            style: GoogleFonts.poppins(
                              color: colour.kWhite,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Expiry Rows ───────────────────────────────────────────
              ...expiryItems.map((e) => _ExpiryRow(
                label: e['label'] as String,
                rawDate: e['date'] as String?,
              )),

              const SizedBox(height: 12),

              // ── Close Button ─────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colour.kPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  child: Text('Close',
                      style: GoogleFonts.poppins(
                          color: colour.kWhite,
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

  const _ExpiryRow({required this.label, required this.rawDate});

  @override
  Widget build(BuildContext context) {
    final formatted = TruckDetailsBloc.formatTruckDate(rawDate);
    final color     = TruckDetailsBloc.expiryColor(rawDate);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Color dot
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),

          // Label
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: colour.kPrimaryDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Date chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              formatted,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(
            color: colour.kAccent,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.local_shipping_outlined,
              size: 44, color: colour.kPrimary),
        ),
        const SizedBox(height: 16),
        Text(
          'No Trucks Found',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: colour.kPrimaryDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'No truck data available at the moment.',
          style: GoogleFonts.poppins(
              fontSize: 12, color: colour.kPrimaryLight),
        ),
      ],
    );
  }
}