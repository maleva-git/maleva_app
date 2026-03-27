import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/features/dashboard/admin_dashboard/tabs/spareparts/view/sparepartsview.dart';
import '../../../../../../SparePartsEntry/SparePartsViewPage.dart';
import '../bloc/spareparts_bloc.dart';
import '../bloc/spareparts_event.dart';
import '../bloc/spareparts_state.dart';

// ── Entry Point ───────────────────────────────────────────────────────────────
class SparePartsEntryPage extends StatelessWidget {
  const SparePartsEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SparePartsBloc.form(context),
      child: const _SparePartsEntryBody(),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────
class _SparePartsEntryBody extends StatelessWidget {
  const _SparePartsEntryBody();

  static final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return BlocConsumer<SparePartsBloc, SparePartsState>(
      listener: (context, state) {
        if (state is SparePartsSubmitSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Submitted successfully ✅",
                style: GoogleFonts.lato(color: colour.kWhite)),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ));
          context
              .read<SparePartsBloc>()
              .add(const ResetSparePartsFormEvent());
        }
        if (state is SparePartsEntryError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      builder: (context, state) {
        if (state is! SparePartsEntryState) return const SizedBox.shrink();

        return isTablet
            ? _buildTabletLayout(context, state)
            : _buildMobileLayout(context, state);
      },
    );
  }

  // ══════════════════════════════════════════════════════
  // TABLET — Two Column
  // ══════════════════════════════════════════════════════
  Widget _buildTabletLayout(
      BuildContext context, SparePartsEntryState s) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── LEFT (55%) — Form ──
          Expanded(
            flex: 55,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: _buildFormContent(context, s, isTablet: true),
            ),
          ),

          const SizedBox(width: 20),

          // ── RIGHT (45%) — Preview Panel ──
          Expanded(
            flex: 45,
            child: _SparePartsPreviewPanel(state: s),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // MOBILE — Single Column
  // ══════════════════════════════════════════════════════
  Widget _buildMobileLayout(
      BuildContext context, SparePartsEntryState s) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
      child: _buildFormContent(context, s, isTablet: false),
    );
  }

  // ══════════════════════════════════════════════════════
  // SHARED — Form Content
  // ══════════════════════════════════════════════════════
  Widget _buildFormContent(
      BuildContext context, SparePartsEntryState s,
      {required bool isTablet}) {
    final bloc = context.read<SparePartsBloc>();
    final truckName = objfun.GetTruckList
        .where((t) => t.Id.toString() == s.selectedTruck)
        .map((t) => t.AccountName ?? '')
        .firstOrNull ?? '';

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Title (tablet-ல மட்டும்) ──
          if (isTablet) ...[
            Row(children: [
              Container(
                width: 4, height: 30,
                decoration: BoxDecoration(
                  color: colour.kPrimary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Text('SPARE PARTS ENTRY',
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colour.kPrimaryDark,
                    letterSpacing: 1.2,
                  )),
            ]),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Text('Entry Form',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: colour.kPrimaryLight,
                    fontWeight: FontWeight.w500,
                  )),
            ),
            const SizedBox(height: 24),
          ],

          // ════════════════════════════
          // SECTION 1 — Vehicle & Date
          // ════════════════════════════
          _SectionCard(
            icon: Icons.local_shipping_rounded,
            title: "Vehicle & Date",
            isTablet: isTablet,
            children: [
              _SelectTile(
                icon: Icons.local_shipping_outlined,
                label: "Truck Name",
                value: truckName.isNotEmpty ? truckName : null,
                placeholder: "Tap to select truck",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          SparePartsTruckSelectPage(bloc: bloc)),
                ),
              ),

              const SizedBox(height: 12),

              _SelectTile(
                icon: Icons.calendar_today_rounded,
                label: "Entry Date",
                value: s.selectedDate != null
                    ? DateFormat('dd-MM-yyyy').format(s.selectedDate!)
                    : null,
                placeholder: "Tap to select date",
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: s.selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    builder: (ctx, child) => Theme(
                      data: Theme.of(ctx).copyWith(
                          colorScheme: const ColorScheme.light(
                              primary: colour.kPrimary)),
                      child: child!,
                    ),
                  );
                  if (picked != null) {
                    bloc.add(SelectSparePartsDateEvent(picked));
                  }
                },
              ),
            ],
          ),

          SizedBox(height: isTablet ? 16 : 14),

          // ════════════════════════════
          // SECTION 2 — Spare Parts Details
          // ════════════════════════════
          _SectionCard(
            icon: Icons.build_rounded,
            title: "Spare Parts Details",
            isTablet: isTablet,
            children: [
              TextFormField(
                initialValue: s.spareParts,
                maxLines: 4,
                onChanged: (v) =>
                    bloc.add(UpdateSparePartsTextEvent(v)),
                validator: (v) =>
                (v == null || v.trim().isEmpty)
                    ? "Please enter spare parts"
                    : null,
                decoration: _decor(
                    "Spare Parts Description",
                    Icons.description_rounded),
              ),

              const SizedBox(height: 12),

              TextFormField(
                initialValue: s.amount,
                keyboardType: TextInputType.number,
                onChanged: (v) =>
                    bloc.add(UpdateSparePartsAmountEvent(v)),
                validator: (v) =>
                (v == null || v.trim().isEmpty)
                    ? "Please enter amount"
                    : null,
                decoration: _decor(
                    "Amount", Icons.currency_rupee_rounded),
              ),
            ],
          ),

          SizedBox(height: isTablet ? 16 : 14),

          // ════════════════════════════
          // SECTION 3 — Document
          // ════════════════════════════
          _SectionCard(
            icon: Icons.attach_file_rounded,
            title: "Document",
            isTablet: isTablet,
            children: [
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colour.kAccent,
                    foregroundColor: colour.kPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                            color: colour.kPrimary)),
                    elevation: 0,
                  ),
                  onPressed: () => bloc.pickDocument(),
                  icon: const Icon(Icons.cloud_upload_rounded),
                  label: Text(
                    (s.pickedImage == null && s.pickedPDF == null)
                        ? "Upload Document"
                        : "Change Document",
                    style: GoogleFonts.lato(
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              if (s.pickedImage != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(s.pickedImage!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover),
                ),
              ] else if (s.pickedPDF != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colour.kAccent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: colour.kPrimary.withOpacity(0.2)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.picture_as_pdf,
                        color: Colors.red, size: 36),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        s.pickedPDF!.path.split('/').last,
                        style: GoogleFonts.lato(
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                ),
              ],
            ],
          ),

          SizedBox(height: isTablet ? 28 : 24),

          // ════════════════════════════
          // Submit + View Buttons
          // ════════════════════════════
          Row(children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity,
                      isTablet ? 58 : 55),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          isTablet ? 16 : 14)),
                  elevation: 0,
                ),
                onPressed: s.isSubmitting
                    ? null
                    : () {
                  if (_formKey.currentState!.validate()) {
                    bloc.add(const SubmitSparePartsEvent());
                  }
                },
                child: s.isSubmitting
                    ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(
                        color: colour.kWhite, strokeWidth: 2))
                    : Text("Submit",
                    style: GoogleFonts.lato(
                        fontSize: isTablet ? 17 : 18,
                        fontWeight: FontWeight.bold,
                        color: colour.kWhite)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity,
                      isTablet ? 58 : 55),
                  backgroundColor: colour.kPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          isTablet ? 16 : 14)),
                  elevation: 0,
                ),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SparePartsView())),
                child: Text("View",
                    style: GoogleFonts.lato(
                        fontSize: isTablet ? 17 : 18,
                        fontWeight: FontWeight.bold,
                        color: colour.kWhite)),
              ),
            ),
          ]),

          SizedBox(height: isTablet ? 20 : 0),
        ],
      ),
    );
  }
}

// ── Preview Panel (Tablet right column) ──────────────────────────────────────
class _SparePartsPreviewPanel extends StatelessWidget {
  final SparePartsEntryState state;
  const _SparePartsPreviewPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    final s = state;
    final truckName = objfun.GetTruckList
        .where((t) => t.Id.toString() == s.selectedTruck)
        .map((t) => t.AccountName ?? '')
        .firstOrNull ?? 'Not selected';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colour.kWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colour.kAccent, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: colour.kPrimary.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Panel header
            Row(children: [
              Container(
                width: 4, height: 22,
                decoration: BoxDecoration(
                  color: colour.kPrimary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Text('Entry Preview',
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: colour.kPrimaryDark,
                  )),
            ]),

            const SizedBox(height: 20),

            // Truck highlight banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: colour.kPrimary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Truck',
                      style: GoogleFonts.lato(
                        fontSize: 11,
                        color: colour.kWhite.withOpacity(0.75),
                      )),
                  const SizedBox(height: 4),
                  Text(
                    truckName,
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colour.kWhite,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _previewRow(Icons.calendar_today_rounded, 'Entry Date',
                s.selectedDate != null
                    ? DateFormat('dd MMM yyyy').format(s.selectedDate!)
                    : 'Not selected'),
            const SizedBox(height: 12),

            _previewRow(Icons.currency_rupee_rounded, 'Amount',
                s.amount.isNotEmpty ? '₹ ${s.amount}' : '-'),
            const SizedBox(height: 12),

            // Spare Parts description preview
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: colour.kAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.build_rounded,
                      color: colour.kPrimary, size: 17),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Spare Parts',
                          style: GoogleFonts.lato(
                            fontSize: 11,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w600,
                          )),
                      const SizedBox(height: 2),
                      Text(
                        s.spareParts.isNotEmpty
                            ? s.spareParts
                            : '-',
                        style: GoogleFonts.lato(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colour.kPrimaryDark,
                          height: 1.4,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Document status
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colour.kAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.attach_file_rounded,
                        color: colour.kPrimary, size: 16),
                    const SizedBox(width: 6),
                    Text('Document',
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colour.kPrimaryDark,
                        )),
                  ]),
                  const SizedBox(height: 8),

                  // Image preview inside panel
                  if (s.pickedImage != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(s.pickedImage!,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover),
                    ),
                  ] else ...[
                    Row(children: [
                      Icon(
                        s.pickedPDF != null
                            ? Icons.picture_as_pdf
                            : Icons.radio_button_unchecked_rounded,
                        color: s.pickedPDF != null
                            ? Colors.red
                            : Colors.grey,
                        size: 15,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          s.pickedPDF != null
                              ? s.pickedPDF!.path.split('/').last
                              : 'No document uploaded',
                          style: GoogleFonts.lato(
                              fontSize: 12,
                              color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ]),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tips
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colour.kAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.lightbulb_rounded,
                        color: colour.kPrimary, size: 16),
                    const SizedBox(width: 6),
                    Text('Tips',
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colour.kPrimaryDark,
                        )),
                  ]),
                  const SizedBox(height: 8),
                  _tipRow('Select truck and date first'),
                  _tipRow('Amount field is required'),
                  _tipRow('Document upload is optional'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _previewRow(
      IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: colour.kAccent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: colour.kPrimary, size: 17),
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
                    fontWeight: FontWeight.w600,
                  )),
              const SizedBox(height: 2),
              Text(value,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colour.kPrimaryDark,
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tipRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        const Icon(Icons.check_circle_rounded,
            color: colour.kPrimary, size: 13),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: GoogleFonts.lato(
                fontSize: 12,
                color: Colors.grey[600],
              )),
        ),
      ]),
    );
  }
}

// ── Truck Select Page ─────────────────────────────────────────────────────────
class SparePartsTruckSelectPage extends StatefulWidget {
  final SparePartsBloc bloc;
  const SparePartsTruckSelectPage(
      {super.key, required this.bloc});

  @override
  State<SparePartsTruckSelectPage> createState() =>
      _SparePartsTruckSelectPageState();
}

class _SparePartsTruckSelectPageState
    extends State<SparePartsTruckSelectPage> {
  final _searchCtrl = TextEditingController();
  late List<GetTruckModel> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = List.from(objfun.GetTruckList);
  }

  void _search(String q) {
    setState(() {
      _filtered = q.isEmpty
          ? List.from(objfun.GetTruckList)
          : objfun.GetTruckList
          .where((t) => (t.AccountName ?? '')
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
        title: Text("Select Truck",
            style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: colour.kWhite)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: colour.kPrimary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchCtrl,
              textCapitalization: TextCapitalization.characters,
              onChanged: _search,
              style: GoogleFonts.lato(
                  color: colour.kPrimaryDark,
                  fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Search Truck No...',
                hintStyle: GoogleFonts.lato(color: Colors.grey),
                prefixIcon: const Icon(Icons.search,
                    color: colour.kPrimary),
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
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            child: Row(children: [
              Text("${_filtered.length} trucks found",
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
                      color: Colors.grey.shade300,
                      size: 56),
                  const SizedBox(height: 10),
                  Text("No trucks found",
                      style: GoogleFonts.lato(
                          fontSize: 16,
                          color: Colors.grey)),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 4),
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final truck = _filtered[i];
                return GestureDetector(
                  onTap: () {
                    widget.bloc.add(
                        SelectSparePartsTruckEvent(
                            truck.Id.toString()));
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin:
                    const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: colour.kWhite,
                      borderRadius:
                      BorderRadius.circular(14),
                      border: Border.all(
                          color: colour.kAccent,
                          width: 1.5),
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
                        width: 40, height: 40,
                        decoration: const BoxDecoration(
                            color: colour.kAccent,
                            shape: BoxShape.circle),
                        child: const Icon(
                            Icons.local_shipping_outlined,
                            color: colour.kPrimary,
                            size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          truck.AccountName ?? '',
                          style: GoogleFonts.lato(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: colour.kPrimaryDark),
                        ),
                      ),
                      const Icon(
                          Icons.chevron_right_rounded,
                          color: colour.kPrimaryLight),
                    ]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
}

// ── Section Card ──────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;
  final bool isTablet;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: isTablet ? 30 : 28,
              height: isTablet ? 30 : 28,
              decoration: const BoxDecoration(
                  color: colour.kAccent,
                  shape: BoxShape.circle),
              child: Icon(icon,
                  color: colour.kPrimary,
                  size: isTablet ? 16 : 15),
            ),
            const SizedBox(width: 8),
            Text(title,
                style: GoogleFonts.lato(
                    fontSize: isTablet ? 14 : 13,
                    fontWeight: FontWeight.bold,
                    color: colour.kPrimaryDark)),
          ]),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isTablet ? 18 : 16),
            decoration: BoxDecoration(
              color: colour.kWhite,
              borderRadius:
              BorderRadius.circular(isTablet ? 18 : 16),
              border:
              Border.all(color: colour.kAccent, width: 1.5),
              boxShadow: [
                BoxShadow(
                    color: colour.kPrimary.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3)),
              ],
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children),
          ),
        ]);
  }
}

// ── Select Tile ───────────────────────────────────────────────────────────────
class _SelectTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final String placeholder;
  final VoidCallback onTap;

  const _SelectTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color:
          hasValue ? colour.kAccent : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasValue
                ? colour.kPrimaryLight.withOpacity(0.4)
                : Colors.grey.shade300,
          ),
        ),
        child: Row(children: [
          Icon(icon,
              color: hasValue ? colour.kPrimary : Colors.grey,
              size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.lato(
                          fontSize: 11,
                          color: hasValue
                              ? colour.kPrimary
                              : Colors.grey,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    hasValue ? value! : placeholder,
                    style: GoogleFonts.lato(
                        fontSize: 14,
                        color: hasValue
                            ? colour.kPrimaryDark
                            : Colors.grey.shade400,
                        fontWeight: hasValue
                            ? FontWeight.bold
                            : FontWeight.normal),
                  ),
                ]),
          ),
          Icon(Icons.chevron_right_rounded,
              color: hasValue
                  ? colour.kPrimary
                  : Colors.grey.shade400),
        ]),
      ),
    );
  }
}

// ── Input Decoration ──────────────────────────────────────────────────────────
InputDecoration _decor(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: colour.kPrimaryDark),
    prefixIcon: Icon(icon, color: colour.kPrimary, size: 20),
    border:
    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
            color: colour.kPrimary, width: 1.5)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
            color: colour.kPrimaryLight.withOpacity(0.35))),
    filled: true,
    fillColor: Colors.grey.shade50,
    contentPadding: const EdgeInsets.symmetric(
        horizontal: 14, vertical: 14),
  );
}