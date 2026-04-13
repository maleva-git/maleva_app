import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/menu/menulist.dart';
import '../bloc/fuelentryview_bloc.dart';
import '../bloc/fuelentryview_event.dart';
import '../bloc/fuelentryview_state.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const kHeaderGradStart = Color(0xFF1A3A8F);
const kHeaderGradEnd   = Color(0xFF4A6FD4);
const kCardBorder      = Color(0xFFC5D0EE);
const kPageBg          = Color(0xFFF4F6FB);
const kTextDark        = Color(0xFF1E2D5E);
const kTextMid         = Color(0xFF4A5A8A);
const kTextMuted       = Color(0xFF8A96BF);
const kDetailBg        = Color(0xFFF0F4FF);
const kChipBg          = Color(0xFFEEF2FF);
const kAccentRed       = Color(0xFFB33040);

const kGradient = LinearGradient(
  colors: [kHeaderGradStart, kHeaderGradEnd],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const double kTabletBreak = 600;

// ─── Root ─────────────────────────────────────────────────────────────────────
class FuelEntryView extends StatelessWidget {
  const FuelEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      FuelEntryViewBloc()..add(FuelEntryViewStarted()),
      child: const _FuelEntryViewPage(),
    );
  }
}

// ─── Page ─────────────────────────────────────────────────────────────────────
class _FuelEntryViewPage extends StatelessWidget {
  const _FuelEntryViewPage();

  @override
  Widget build(BuildContext context) {
    final userName =
        objfun.storagenew.getString('Username') ?? '';

    return BlocListener<FuelEntryViewBloc, FuelEntryViewState>(
      listener: (context, state) {
        if (state is FuelEntryViewError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message,
                  style:
                  GoogleFonts.lato(color: Colors.white)),
              backgroundColor: kAccentRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return false;
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: kPageBg,
          appBar: _buildAppBar(context, userName),
          drawer: const Menulist(),
          body: BlocBuilder<FuelEntryViewBloc,
              FuelEntryViewState>(
            builder: (context, state) {
              if (state is FuelEntryViewInitial ||
                  state is FuelEntryViewLoading) {
                return const Center(
                  child: SpinKitFoldingCube(
                      color: kHeaderGradEnd, size: 35),
                );
              }
              if (state is FuelEntryViewLoaded) {
                return _FuelEntryViewBody(state: state);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, String userName) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      toolbarHeight: 62,
      flexibleSpace: Container(
          decoration:
          const BoxDecoration(gradient: kGradient)),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 20),
        color: Colors.white,
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fuel Entry View',
              style: GoogleFonts.lato(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  letterSpacing: 0.3)),
          const SizedBox(height: 2),
          Text(userName,
              style: GoogleFonts.lato(
                  color: Colors.white.withOpacity(0.65),
                  fontWeight: FontWeight.w500,
                  fontSize: 12)),
        ],
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────
class _FuelEntryViewBody extends StatelessWidget {
  final FuelEntryViewLoaded state;
  const _FuelEntryViewBody({required this.state});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > kTabletBreak;
        final hPad =
        isTablet ? constraints.maxWidth * 0.05 : 12.0;

        return Column(
          children: [
            // ── Date filter bar ──────────────────────────
            _DateFilterBar(
                state: state,
                isTablet: isTablet,
                hPad: hPad),

            // ── Table header ─────────────────────────────
            _TableHeader(isTablet: isTablet, hPad: hPad),

            // ── List ─────────────────────────────────────
            Expanded(
              child: state.items.isEmpty
                  ? _EmptyState()
                  : _FuelList(
                  state: state,
                  isTablet: isTablet,
                  hPad: hPad),
            ),
          ],
        );
      },
    );
  }
}

// ─── Date Filter Bar ──────────────────────────────────────────────────────────
class _DateFilterBar extends StatelessWidget {
  final FuelEntryViewLoaded state;
  final bool   isTablet;
  final double hPad;

  const _DateFilterBar({
    required this.state,
    required this.isTablet,
    required this.hPad,
  });

  Future<void> _pick(BuildContext context, bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2050),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: kHeaderGradStart,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: kTextDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    final f = DateFormat('yyyy-MM-dd').format(picked);
    if (isFrom) {
      context
          .read<FuelEntryViewBloc>()
          .add(FuelEntryViewFromDateChanged(f));
    } else {
      context
          .read<FuelEntryViewBloc>()
          .add(FuelEntryViewToDateChanged(f));
    }
  }

  @override
  Widget build(BuildContext context) {
    String _fmt(String d) {
      try {
        return DateFormat('dd-MM-yy')
            .format(DateTime.parse(d));
      } catch (_) {
        return d;
      }
    }

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 10),
      child: isTablet
          ? Row(children: [
        _DateTile(
          label: 'From',
          display: _fmt(state.fromDate),
          isTablet: isTablet,
          onTap: () => _pick(context, true),
        ),
        const SizedBox(width: 12),
        _DateTile(
          label: 'To',
          display: _fmt(state.toDate),
          isTablet: isTablet,
          onTap: () => _pick(context, false),
        ),
        const SizedBox(width: 16),
        _ViewButton(isTablet: isTablet),
      ])
          : Column(
        children: [
          Row(children: [
            Expanded(
              child: _DateTile(
                label: 'From',
                display: _fmt(state.fromDate),
                isTablet: isTablet,
                onTap: () => _pick(context, true),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DateTile(
                label: 'To',
                display: _fmt(state.toDate),
                isTablet: isTablet,
                onTap: () => _pick(context, false),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          SizedBox(
              width: double.infinity,
              child: _ViewButton(isTablet: isTablet)),
        ],
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String   label;
  final String   display;
  final bool     isTablet;
  final VoidCallback onTap;
  const _DateTile({
    required this.label,
    required this.display,
    required this.isTablet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: kDetailBg,
          borderRadius: BorderRadius.circular(10),
          border:
          Border.all(color: kCardBorder, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(),
                style: GoogleFonts.lato(
                    color: kTextMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                    letterSpacing: 0.6)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                Text(display,
                    style: GoogleFonts.lato(
                        color: kTextDark,
                        fontWeight: FontWeight.w700,
                        fontSize: isTablet ? 14 : 13)),
                const Icon(
                    Icons.calendar_month_outlined,
                    size: 18,
                    color: kHeaderGradEnd),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewButton extends StatelessWidget {
  final bool isTablet;
  const _ViewButton({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: kGradient,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: kHeaderGradStart.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context
              .read<FuelEntryViewBloc>()
              .add(FuelEntryViewLoadRequested()),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 24 : 0,
                vertical: 10),
            child: Center(
              child: Text('View',
                  style: GoogleFonts.lato(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: isTablet
                          ? objfun.FontMedium + 1
                          : objfun.FontMedium)),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Table Header ─────────────────────────────────────────────────────────────
class _TableHeader extends StatelessWidget {
  final bool   isTablet;
  final double hPad;
  const _TableHeader(
      {required this.isTablet, required this.hPad});

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.lato(
      color: Colors.white.withOpacity(0.85),
      fontWeight: FontWeight.w600,
      fontSize: isTablet ? 11 : 10,
      letterSpacing: 0.5,
    );

    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: hPad, vertical: 6),
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: kGradient,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        Expanded(
            flex: 1,
            child: Text('SNo',
                textAlign: TextAlign.left,
                style: style)),
        Expanded(
            flex: 3,
            child: Text('Date',
                textAlign: TextAlign.center,
                style: style)),
        Expanded(
            flex: 3,
            child: Text('Liter',
                textAlign: TextAlign.right,
                style: style)),
        Expanded(
            flex: 3,
            child: Text('Amount',
                textAlign: TextAlign.right,
                style: style)),
        const Expanded(flex: 1, child: SizedBox.shrink()),
      ]),
    );
  }
}

// ─── Fuel List ────────────────────────────────────────────────────────────────
class _FuelList extends StatelessWidget {
  final FuelEntryViewLoaded state;
  final bool   isTablet;
  final double hPad;

  const _FuelList({
    required this.state,
    required this.isTablet,
    required this.hPad,
  });

  @override
  Widget build(BuildContext context) {
    // Tablet: 2-column grid; Mobile: single column list
    if (isTablet) {
      return GridView.builder(
        padding: EdgeInsets.symmetric(
            horizontal: hPad, vertical: 4),
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:   2,
          crossAxisSpacing: 10,
          mainAxisSpacing:  10,
          childAspectRatio: 4.5,
        ),
        itemCount: state.items.length,
        itemBuilder: (ctx, i) => _FuelRow(
          item:     state.items[i],
          index:    i,
          isTablet: true,
          onDelete: (item) => _confirmDelete(ctx, item),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
          horizontal: hPad, vertical: 4),
      itemCount: state.items.length,
      itemBuilder: (ctx, i) => _FuelRow(
        item:     state.items[i],
        index:    i,
        isTablet: false,
        onDelete: (item) => _confirmDelete(ctx, item),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, Map<String, dynamic> item) async {
    final ok = await objfun.ConfirmationMsgYesNo(
        context, 'Do You Want to Delete Fuel Entry ?');
    if (ok == true) {
      context
          .read<FuelEntryViewBloc>()
          .add(FuelEntryViewDeleteRequested(item));
    }
  }
}

// ─── Single Fuel Row Card ─────────────────────────────────────────────────────
class _FuelRow extends StatelessWidget {
  final Map<String, dynamic> item;
  final int     index;
  final bool    isTablet;
  final void Function(Map<String, dynamic>) onDelete;

  const _FuelRow({
    required this.item,
    required this.index,
    required this.isTablet,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final valStyle = GoogleFonts.lato(
      color: kTextDark,
      fontWeight: FontWeight.w600,
      fontSize:
      isTablet ? objfun.FontCardText + 1 : objfun.FontCardText,
    );

    final liter  = (item['Aliter']  as num?)?.toStringAsFixed(2) ?? '0.00';
    final amount = (item['AAmount'] as num?)?.toStringAsFixed(2) ?? '0.00';
    final date   = item['SSaleDate']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kCardBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: kHeaderGradStart.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // Left gradient accent
            Container(
              width: 4,
              height: double.infinity,
              decoration:
              const BoxDecoration(gradient: kGradient),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 10),
                child: Row(
                  children: [
                    // SNo
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: kChipBg,
                          borderRadius:
                          BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: GoogleFonts.lato(
                              color: kHeaderGradStart,
                              fontWeight: FontWeight.w700,
                              fontSize: isTablet ? 11 : 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Date
                    Expanded(
                      flex: 3,
                      child: Text(date,
                          textAlign: TextAlign.center,
                          style: valStyle,
                          overflow: TextOverflow.ellipsis),
                    ),
                    // Liter
                    Expanded(
                      flex: 3,
                      child: Text(liter,
                          textAlign: TextAlign.right,
                          style: valStyle,
                          overflow: TextOverflow.ellipsis),
                    ),
                    // Amount
                    Expanded(
                      flex: 3,
                      child: Text(amount,
                          textAlign: TextAlign.right,
                          style: valStyle,
                          overflow: TextOverflow.ellipsis),
                    ),
                    // Delete
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => onDelete(item),
                        icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 20,
                            color: kAccentRed),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
                color: kChipBg,
                borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.local_gas_station_outlined,
                size: 32, color: kHeaderGradEnd),
          ),
          const SizedBox(height: 14),
          Text('No Records Found',
              style: GoogleFonts.lato(
                  color: kTextDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 15)),
          const SizedBox(height: 4),
          Text('Select a date range and press View',
              style: GoogleFonts.lato(
                  color: kTextMuted, fontSize: 12)),
        ],
      ),
    );
  }
}