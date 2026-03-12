import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;

import '../bloc/inventoryreport_bloc.dart';
import '../bloc/inventoryreport_event.dart';
import '../bloc/inventoryreport_state.dart';

// ── Port filter data with icons ───────────────────────────────────────────────
const kPortChips = [
  {"id": 1, "name": "PTP",         "icon": Icons.anchor},
  {"id": 2, "name": "WP",          "icon": Icons.water},
  {"id": 3, "name": "NP",          "icon": Icons.north},
  {"id": 4, "name": "SP",          "icon": Icons.south},
  {"id": 5, "name": "Klia",        "icon": Icons.flight_land},
  {"id": 6, "name": "PasirGudang", "icon": Icons.warehouse},
];

// ── Entry Point ───────────────────────────────────────────────────────────────
class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InventoryBloc(context),
      child: const _InventoryBody(),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────
class _InventoryBody extends StatelessWidget {
  const _InventoryBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InventoryBloc, InventoryState>(
      builder: (context, state) {
        final s         = state is InventoryLoaded ? state : null;
        final isLoading = s?.isLoading ?? false;
        final portId    = s?.selectedPortId ?? 1;
        final fromDate  = s?.fromDate ?? DateTime.now();
        final toDate    = s?.toDate   ?? DateTime.now();

        final custName = objfun.CustomerList
            .where((c) => c.Id == s?.selectedCustomerId)
            .map((c) => c.AccountName ?? '')
            .firstOrNull ?? '';

        return SingleChildScrollView(
          // Need scroll because filter section is taller now
          // But list needs Expanded — use CustomScrollView approach
          child: SizedBox(
            height: MediaQuery.of(context).size.height -
                kToolbarHeight -
                MediaQuery.of(context).padding.top -
                kBottomNavigationBarHeight,
            child: Column(children: [

              // ════════════════════════════════════════════════════
              // SECTION 1 — PORT FILTER (Icon + label vertical chips)
              // ════════════════════════════════════════════════════
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: colour.kWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colour.kAccent, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                        color: colour.kPrimary.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3)),
                  ],
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section label
                      Row(children: [
                        Container(
                          width: 24, height: 24,
                          decoration: const BoxDecoration(
                              color: colour.kAccent, shape: BoxShape.circle),
                          child: const Icon(Icons.anchor_rounded,
                              color: colour.kPrimary, size: 13),
                        ),
                        const SizedBox(width: 6),
                        Text("Port Filter",
                            style: GoogleFonts.lato(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: colour.kPrimaryDark)),
                      ]),

                      const SizedBox(height: 10),

                      // Icon + label chips — horizontal scroll
                      SizedBox(
                        height: 72,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: kPortChips.length,
                          itemBuilder: (_, i) {
                            final f        = kPortChips[i];
                            final isActive = portId == f['id'];
                            final icon     = f['icon'] as IconData;

                            return GestureDetector(
                              onTap: () => context
                                  .read<InventoryBloc>()
                                  .add(SelectPortFilterEvent(f['id'] as int)),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                margin: const EdgeInsets.only(right: 10),
                                width: 70,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? colour.kPrimary
                                      : colour.kAccent,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: isActive
                                          ? colour.kPrimary
                                          : colour.kPrimaryLight
                                          .withOpacity(0.3)),
                                  boxShadow: isActive
                                      ? [
                                    BoxShadow(
                                        color: colour.kPrimary
                                            .withOpacity(0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3))
                                  ]
                                      : [],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(icon,
                                        size: 22,
                                        color: isActive
                                            ? colour.kWhite
                                            : colour.kPrimary),
                                    const SizedBox(height: 5),
                                    Text(f['name'] as String,
                                        style: GoogleFonts.lato(
                                            fontSize: 11,
                                            fontWeight: isActive
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                            color: isActive
                                                ? colour.kWhite
                                                : colour.kPrimaryDark),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ]),
              ),

              const SizedBox(height: 8),

              // ════════════════════════════════════════════════════
              // SECTION 2 — CUSTOMER SELECT (Separate section card)
              // ════════════════════════════════════════════════════
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colour.kWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colour.kAccent, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                        color: colour.kPrimary.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3)),
                  ],
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section label
                      Row(children: [
                        Container(
                          width: 24, height: 24,
                          decoration: const BoxDecoration(
                              color: colour.kAccent, shape: BoxShape.circle),
                          child: const Icon(Icons.person_rounded,
                              color: colour.kPrimary, size: 13),
                        ),
                        const SizedBox(width: 6),
                        Text("Customer & Status",
                            style: GoogleFonts.lato(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: colour.kPrimaryDark)),
                      ]),

                      const SizedBox(height: 10),

                      Row(children: [
                        // Customer select tile
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              final bloc = context.read<InventoryBloc>();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => InventoryCustomerSelectPage(
                                      bloc: bloc),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 11),
                              decoration: BoxDecoration(
                                color: custName.isNotEmpty
                                    ? colour.kAccent
                                    : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: custName.isNotEmpty
                                      ? colour.kPrimaryLight.withOpacity(0.4)
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Row(children: [
                                Icon(Icons.person_rounded,
                                    color: custName.isNotEmpty
                                        ? colour.kPrimary
                                        : Colors.grey,
                                    size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text("Customer",
                                            style: GoogleFonts.lato(
                                                fontSize: 10,
                                                color: custName.isNotEmpty
                                                    ? colour.kPrimary
                                                    : Colors.grey,
                                                fontWeight:
                                                FontWeight.w600)),
                                        Text(
                                          custName.isNotEmpty
                                              ? custName
                                              : "Select Customer",
                                          style: GoogleFonts.lato(
                                              fontSize: 12,
                                              color: custName.isNotEmpty
                                                  ? colour.kPrimaryDark
                                                  : Colors.grey.shade400,
                                              fontWeight: custName.isNotEmpty
                                                  ? FontWeight.bold
                                                  : FontWeight.normal),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ]),
                                ),
                                Icon(Icons.chevron_right_rounded,
                                    color: custName.isNotEmpty
                                        ? colour.kPrimary
                                        : Colors.grey.shade400,
                                    size: 18),
                              ]),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Active checkbox
                        GestureDetector(
                          onTap: () => context.read<InventoryBloc>().add(
                              ToggleInventoryStatusEvent(
                                  !(s?.isChecked ?? false))),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 11),
                            decoration: BoxDecoration(
                              color: (s?.isChecked ?? false)
                                  ? colour.kPrimary
                                  : colour.kAccent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: (s?.isChecked ?? false)
                                      ? colour.kPrimary
                                      : colour.kPrimaryLight
                                      .withOpacity(0.3)),
                            ),
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    (s?.isChecked ?? false)
                                        ? Icons.check_box_rounded
                                        : Icons.check_box_outline_blank_rounded,
                                    color: (s?.isChecked ?? false)
                                        ? colour.kWhite
                                        : colour.kPrimary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Text("Active",
                                      style: GoogleFonts.lato(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: (s?.isChecked ?? false)
                                              ? colour.kWhite
                                              : colour.kPrimaryDark)),
                                ]),
                          ),
                        ),
                      ]),
                    ]),
              ),

              const SizedBox(height: 8),

              // ════════════════════════════════════════════════════
              // SECTION 3 — DATE FILTER
              // ════════════════════════════════════════════════════
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: colour.kAccent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: colour.kPrimaryLight.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: _DateCell(
                        label: "From",
                        value: DateFormat('dd-MM-yy').format(fromDate),
                        onTap: () => _pickDate(context, fromDate,
                                (d) => context.read<InventoryBloc>().add(
                                SelectInventoryFromDateEvent(d))),
                      ),
                    ),
                    _calBtn(() => _pickDate(context, fromDate,
                            (d) => context.read<InventoryBloc>().add(
                            SelectInventoryFromDateEvent(d)))),
                    Container(
                        width: 1,
                        height: 28,
                        color: colour.kPrimaryLight.withOpacity(0.3),
                        margin:
                        const EdgeInsets.symmetric(horizontal: 8)),
                    Expanded(
                      child: _DateCell(
                        label: "To",
                        value: DateFormat('dd-MM-yy').format(toDate),
                        onTap: () => _pickDate(context, toDate,
                                (d) => context.read<InventoryBloc>().add(
                                SelectInventoryToDateEvent(d))),
                      ),
                    ),
                    _calBtn(() => _pickDate(context, toDate,
                            (d) => context.read<InventoryBloc>().add(
                            SelectInventoryToDateEvent(d)))),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () => context
                          .read<InventoryBloc>()
                          .add(const SearchInventoryByDateEvent()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colour.kPrimary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: Text("Search",
                          style: GoogleFonts.lato(
                              color: colour.kWhite,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ),
                  ]),
                ),
              ),

              const SizedBox(height: 6),

              // Record count strip
              if (!isLoading && (s?.records.isNotEmpty ?? false))
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 2),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: colour.kAccent,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(
                          "${s!.records.length} records",
                          style: GoogleFonts.lato(
                              color: colour.kPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ),
                  ]),
                ),

              Divider(
                  color: colour.kAccent, thickness: 1.5, height: 10),

              // ════════════════════════════════════════════════════
              // SECTION 4 — 2-COLUMN GRID LIST
              // ════════════════════════════════════════════════════
              Expanded(
                child: isLoading
                    ? const Center(
                    child: CircularProgressIndicator(
                        color: colour.kPrimary))
                    : state is InventoryError
                    ? _errorView(context, state.message)
                    : (s == null || s.records.isEmpty)
                    ? Center(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 60,
                              color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text("No Records Found",
                              style: GoogleFonts.lato(
                                  fontSize: 16,
                                  color: Colors.grey)),
                        ]))
                    : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(
                      8, 4, 8, 20),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: s.records.length,
                  itemBuilder: (_, i) =>
                      _InventoryGridCard(
                          item: s.records[i]),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  Future<void> _pickDate(BuildContext context, DateTime initial,
      ValueChanged<DateTime> onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme:
            const ColorScheme.light(primary: colour.kPrimary)),
        child: child!,
      ),
    );
    if (picked != null) onPicked(picked);
  }

  Widget _errorView(BuildContext context, String msg) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 48),
        const SizedBox(height: 12),
        Text(msg,
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(color: Colors.red)),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => context
              .read<InventoryBloc>()
              .add(const LoadInventoryListsEvent()),
          icon: const Icon(Icons.refresh),
          label: const Text("Retry"),
          style: ElevatedButton.styleFrom(
              backgroundColor: colour.kPrimary),
        ),
      ]),
    );
  }
}

// ── 2-Column Grid Card ────────────────────────────────────────────────────────
class _InventoryGridCard extends StatelessWidget {
  final InventoryModel item;
  const _InventoryGridCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colour.kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colour.kAccent, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: colour.kPrimary.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(children: [

        // ── Blue header ──────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 10),
          decoration: const BoxDecoration(
            color: colour.kPrimary,
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.jobType ?? '-',
                    style: GoogleFonts.lato(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: colour.kWhite),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: colour.kWhite.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(item.jobStatus ?? '-',
                      style: GoogleFonts.lato(
                          fontSize: 10,
                          color: colour.kWhite,
                          fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ]),
        ),

        // ── Body ────────────────────────────────────────────
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Qty + Weight chips
                  Wrap(spacing: 5, runSpacing: 4, children: [
                    _miniChip(Icons.numbers_rounded, item.cargoQTY),
                    _miniChip(Icons.scale_rounded,   item.cargoWeight),
                  ]),

                  const SizedBox(height: 8),

                  _gridRow(Icons.directions_boat_rounded,
                      item.offVesselName),
                  const SizedBox(height: 4),
                  _gridRow(Icons.local_shipping_rounded,
                      item.loadingVesselName),
                  const SizedBox(height: 4),
                  _gridRow(Icons.person_rounded, item.employeeName),
                  const SizedBox(height: 4),
                  _gridRow(Icons.access_time_rounded, item.eta),

                  const Spacer(),

                  // AWB + dates at bottom
                  Divider(
                      color: colour.kAccent, height: 10, thickness: 1),
                  Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        _tinyText("In: ${item.oiDateIn ?? '-'}"),
                        _tinyText("Out: ${item.odiDateOut ?? '-'}"),
                      ]),
                  const SizedBox(height: 2),
                  _tinyText("AWB: ${item.awbNo ?? '-'}"),
                ]),
          ),
        ),
      ]),
    );
  }

  Widget _miniChip(IconData icon, String? val) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: colour.kAccent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: colour.kPrimary),
        const SizedBox(width: 3),
        Text(val ?? '-',
            style: GoogleFonts.lato(
                fontSize: 11,
                color: colour.kPrimaryDark,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _gridRow(IconData icon, String? val) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 12, color: colour.kPrimaryLight),
      const SizedBox(width: 5),
      Expanded(
        child: Text(val ?? '-',
            style: GoogleFonts.lato(
                fontSize: 11, color: colour.kPrimaryDark),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ),
    ]);
  }

  Widget _tinyText(String t) => Text(t,
      style:
      GoogleFonts.lato(fontSize: 10, color: Colors.grey[400]));
}

// ── Customer Select Page ──────────────────────────────────────────────────────
class InventoryCustomerSelectPage extends StatefulWidget {
  final InventoryBloc bloc;
  const InventoryCustomerSelectPage({super.key, required this.bloc});

  @override
  State<InventoryCustomerSelectPage> createState() =>
      _InventoryCustomerSelectPageState();
}

class _InventoryCustomerSelectPageState
    extends State<InventoryCustomerSelectPage> {
  final _searchCtrl = TextEditingController();
  late List<CustomerModel> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = List.from(objfun.CustomerList);
  }

  void _search(String q) {
    setState(() {
      _filtered = q.isEmpty
          ? List.from(objfun.CustomerList)
          : objfun.CustomerList
          .where((c) => (c.AccountName ?? '')
          .toUpperCase()
          .contains(q.toUpperCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: colour.kPrimary,
        foregroundColor: colour.kWhite,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: colour.kWhite, size: 20),
        ),
        title: Text("Select Customer",
            style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: colour.kWhite)),
        centerTitle: true,
      ),
      body: Column(children: [
        // Search bar
        Container(
          color: colour.kPrimary,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: TextField(
            controller: _searchCtrl,
            onChanged: _search,
            style: GoogleFonts.lato(
                color: colour.kPrimaryDark,
                fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'Search Customer...',
              hintStyle: GoogleFonts.lato(color: Colors.grey),
              prefixIcon:
              const Icon(Icons.search, color: colour.kPrimary),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              filled: true,
              fillColor: colour.kWhite,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 14),
            ),
          ),
        ),

        // Count
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 10),
          child: Row(children: [
            Icon(Icons.person_rounded,
                color: colour.kPrimaryLight, size: 16),
            const SizedBox(width: 6),
            Text("${_filtered.length} customers",
                style: GoogleFonts.lato(
                    fontSize: 13,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600)),
          ]),
        ),

        Expanded(
          child: _filtered.isEmpty
              ? Center(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off_rounded,
                        color: Colors.grey.shade300, size: 56),
                    const SizedBox(height: 10),
                    Text("No customers found",
                        style: GoogleFonts.lato(
                            fontSize: 16, color: Colors.grey)),
                  ]))
              : ListView.builder(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 4),
            itemCount: _filtered.length,
            itemBuilder: (_, i) {
              final c = _filtered[i];
              return GestureDetector(
                onTap: () {
                  widget.bloc.add(
                      SelectInventoryCustomerEvent(c.Id));
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: colour.kWhite,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: colour.kAccent, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                          color: colour.kPrimary
                              .withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(children: [
                    Container(
                      width: 38, height: 38,
                      decoration: const BoxDecoration(
                          color: colour.kAccent,
                          shape: BoxShape.circle),
                      child: const Icon(Icons.person_rounded,
                          color: colour.kPrimary, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(c.AccountName ?? '',
                          style: GoogleFonts.lato(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colour.kPrimaryDark)),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: colour.kPrimaryLight),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
Widget _calBtn(VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 34, height: 34,
      decoration: BoxDecoration(
          color: colour.kPrimary,
          borderRadius: BorderRadius.circular(8)),
      child: const Icon(Icons.calendar_month_outlined,
          color: colour.kWhite, size: 18),
    ),
  );
}

class _DateCell extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _DateCell(
      {required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.lato(
                    fontSize: 10,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600)),
            Text(value,
                style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: colour.kPrimaryDark)),
          ]),
    );
  }
}