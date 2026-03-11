import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/features/dashboard/admin_dashboard/tabs/summonentry/view/summonview_tab.dart';
import '../bloc/summonentry_bloc.dart';
import '../bloc/summonentry_event.dart';
import '../bloc/summonentry_state.dart';

const List<String> kMalaysiaList  = ['Parking', 'Traffic', 'Summon', 'Compound', 'Others'];
const List<String> kSingaporeList = ['ERP', 'Parking', 'Traffic', 'Summon', 'Others'];

// ── Entry Point ───────────────────────────────────────────────────────────────
class SummonEntryPage extends StatelessWidget {
  const SummonEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SummonBloc.form(context),
      child: const _SummonEntryBody(),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────
class _SummonEntryBody extends StatelessWidget {
  const _SummonEntryBody();

  static final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SummonBloc, SummonState>(
      listener: (context, state) {
        if (state is SummonSubmitSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Submitted successfully ✅",
                style: GoogleFonts.lato(color: kWhite)),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ));
          context.read<SummonBloc>().add(const ResetEntryFormEvent());
        }
        if (state is SummonEntryError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      builder: (context, state) {
        if (state is! SummonEntryState) return const SizedBox.shrink();

        final s    = state;
        final bloc = context.read<SummonBloc>();
        final summonList = s.selectedCountry == 'Malaysia' ? kMalaysiaList : kSingaporeList;

        // Selected truck display name
        final truckName = objfun.GetTruckList
            .where((t) => t.Id.toString() == s.selectedTruck)
            .map((t) => t.AccountName ?? '')
            .firstOrNull ?? '';

        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ════════════════════════════════════════════════
                // SECTION 1 — Vehicle & Date
                // ════════════════════════════════════════════════
                _SectionCard(
                  icon: Icons.local_shipping_rounded,
                  title: "Vehicle & Date",
                  children: [

                    // Truck selector — tap to open bottom sheet
                    _SelectTile(
                      icon: Icons.local_shipping_outlined,
                      label: "Truck Name",
                      value: truckName.isNotEmpty ? truckName : null,
                      placeholder: "Tap to select truck",
                      onTap: () => _openTruckSheet(context, bloc),
                    ),

                    const SizedBox(height: 12),

                    // Date picker
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
                                colorScheme:
                                const ColorScheme.light(primary: kPrimary)),
                            child: child!,
                          ),
                        );
                        if (picked != null) bloc.add(SelectEntryDateEvent(picked));
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ════════════════════════════════════════════════
                // SECTION 2 — Country & Summon Type
                // ════════════════════════════════════════════════
                _SectionCard(
                  icon: Icons.public_rounded,
                  title: "Country & Summon",
                  children: [

                    // Country toggle buttons
                    Row(
                      children: ['Malaysia', 'Singapore'].map((country) {
                        final active = s.selectedCountry == country;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => bloc.add(SelectCountryEvent(country)),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: EdgeInsets.only(
                                  right: country == 'Malaysia' ? 6 : 0,
                                  left: country == 'Singapore' ? 6 : 0),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              decoration: BoxDecoration(
                                color: active ? kPrimary : kAccent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: active
                                      ? kPrimary
                                      : kPrimaryLight.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    active
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    color: active ? kWhite : kPrimaryLight,
                                    size: 17,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(country,
                                      style: GoogleFonts.lato(
                                          color: active ? kWhite : kPrimaryDark,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 14),

                    // Summon type dropdown
                    DropdownButtonFormField<String>(
                      value: summonList.contains(s.selectedSummon)
                          ? s.selectedSummon
                          : null,
                      isExpanded: true,
                      decoration: _decor("Summon Type", Icons.warning_amber_rounded),
                      items: summonList
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => bloc.add(SelectSummonTypeEvent(v)),
                      validator: (v) =>
                      (v == null || v.isEmpty) ? "Please select summon type" : null,
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ════════════════════════════════════════════════
                // SECTION 3 — Charges
                // ════════════════════════════════════════════════
                _SectionCard(
                  icon: Icons.receipt_long_rounded,
                  title: "Charges",
                  children: [
                    _field("Amount", s.amount,
                            (v) => bloc.add(UpdateAmountEvent(v)),
                        icon: Icons.currency_rupee_rounded,
                        keyboard: TextInputType.number,
                        validator: (v) =>
                        (v == null || v.isEmpty) ? "Enter amount" : null),
                    const SizedBox(height: 12),
                    _field("PortPass", s.portPass,
                            (v) => bloc.add(UpdatePortPassEvent(v)),
                        icon: Icons.door_front_door_rounded),
                    const SizedBox(height: 12),
                    _field("TruckLcnMnt", s.truckLcnMnt,
                            (v) => bloc.add(UpdateTruckLcnMntEvent(v)),
                        icon: Icons.assignment_rounded),
                    const SizedBox(height: 12),
                    _field("Levy", s.levy,
                            (v) => bloc.add(UpdateLevyEvent(v)),
                        icon: Icons.price_change_rounded,
                        keyboard: TextInputType.number),
                    const SizedBox(height: 12),
                    _field("Fuel", s.fuel,
                            (v) => bloc.add(UpdateFuelEvent(v)),
                        icon: Icons.local_gas_station_rounded,
                        keyboard: TextInputType.number),
                  ],
                ),

                const SizedBox(height: 14),

                // ════════════════════════════════════════════════
                // SECTION 4 — Document
                // ════════════════════════════════════════════════
                _SectionCard(
                  icon: Icons.attach_file_rounded,
                  title: "Document",
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAccent,
                          foregroundColor: kPrimary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: kPrimary)),
                          elevation: 0,
                        ),
                        onPressed: () =>
                            context.read<SummonBloc>().pickDocument(context),
                        icon: const Icon(Icons.cloud_upload_rounded),
                        label: Text(
                          (s.pickedImage == null && s.pickedPDF == null)
                              ? "Upload Document"
                              : "Change Document",
                          style: GoogleFonts.lato(
                              fontSize: 15, fontWeight: FontWeight.w600),
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
                          color: kAccent,
                          borderRadius: BorderRadius.circular(10),
                          border:
                          Border.all(color: kPrimary.withOpacity(0.2)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.picture_as_pdf,
                              color: Colors.red, size: 36),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              s.pickedPDF!.path.split('/').last,
                              style: GoogleFonts.lato(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ]),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 24),

                // ════════════════════════════════════════════════
                // Submit + View Buttons
                // ════════════════════════════════════════════════
                Row(children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 55),
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: s.isSubmitting
                          ? null
                          : () {
                        if (_formKey.currentState!.validate()) {
                          bloc.add(const SubmitSummonEvent());
                        }
                      },
                      child: s.isSubmitting
                          ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              color: kWhite, strokeWidth: 2))
                          : Text("Submit",
                          style: GoogleFonts.lato(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: kWhite)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 55),
                        backgroundColor: kPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SummonView())),
                      child: Text("View",
                          style: GoogleFonts.lato(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: kWhite)),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Truck Select Page (Navigator.push) ───────────────────────────────────────
void _openTruckSheet(BuildContext context, SummonBloc bloc) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => _TruckSelectPage(bloc: bloc)),
  );
}

class _TruckSelectPage extends StatefulWidget {
  final SummonBloc bloc;
  const _TruckSelectPage({required this.bloc});

  @override
  State<_TruckSelectPage> createState() => _TruckSelectPageState();
}

class _TruckSelectPageState extends State<_TruckSelectPage> {
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
        backgroundColor: kPrimary,
        foregroundColor: kWhite,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: kWhite, size: 20),
        ),
        title: Text("Select Truck",
            style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: kWhite)),
        centerTitle: true,
      ),
      body: Column(
        children: [

          // ── Search Bar ──────────────────────────────────────────────
          Container(
            color: kPrimary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchCtrl,
              textCapitalization: TextCapitalization.characters,
              onChanged: _search,
              style: GoogleFonts.lato(
                  color: kPrimaryDark, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Search Truck No...',
                hintStyle: GoogleFonts.lato(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: kPrimary),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                filled: true,
                fillColor: kWhite,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
              ),
            ),
          ),

          // ── Count label ─────────────────────────────────────────────
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Text("${_filtered.length} trucks found",
                    style: GoogleFonts.lato(
                        fontSize: 13,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),

          // ── Truck List ──────────────────────────────────────────────
          Expanded(
            child: _filtered.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off_rounded,
                      color: Colors.grey.shade300, size: 56),
                  const SizedBox(height: 10),
                  Text("No trucks found",
                      style: GoogleFonts.lato(
                          fontSize: 16, color: Colors.grey)),
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
                        SelectTruckEvent(truck.Id.toString()));
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: kWhite,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: kAccent, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                            color: kPrimary.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Row(children: [
                      Container(
                        width: 40, height: 40,
                        decoration: const BoxDecoration(
                            color: kAccent, shape: BoxShape.circle),
                        child: const Icon(
                            Icons.local_shipping_outlined,
                            color: kPrimary, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          truck.AccountName ?? '',
                          style: GoogleFonts.lato(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: kPrimaryDark),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: kPrimaryLight),
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

// ── Section Card Widget ───────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        Row(children: [
          Container(
            width: 28, height: 28,
            decoration: const BoxDecoration(
                color: kAccent, shape: BoxShape.circle),
            child: Icon(icon, color: kPrimary, size: 15),
          ),
          const SizedBox(width: 8),
          Text(title,
              style: GoogleFonts.lato(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryDark,
                  letterSpacing: 0.3)),
        ]),
        const SizedBox(height: 8),

        // Card body
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kAccent, width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: kPrimary.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3)),
            ],
          ),
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ),
      ],
    );
  }
}

// ── Select Tile (Truck / Date) ────────────────────────────────────────────────
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
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: hasValue ? kAccent : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasValue
                ? kPrimaryLight.withOpacity(0.4)
                : Colors.grey.shade300,
            width: 1.2,
          ),
        ),
        child: Row(children: [
          Icon(icon, color: hasValue ? kPrimary : Colors.grey, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.lato(
                        fontSize: 11,
                        color: hasValue ? kPrimary : Colors.grey,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  hasValue ? value! : placeholder,
                  style: GoogleFonts.lato(
                      fontSize: 14,
                      color: hasValue ? kPrimaryDark : Colors.grey.shade400,
                      fontWeight:
                      hasValue ? FontWeight.bold : FontWeight.normal),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: hasValue ? kPrimary : Colors.grey.shade400),
        ]),
      ),
    );
  }
}

// ── Reusable form field ───────────────────────────────────────────────────────
Widget _field(
    String label,
    String initial,
    ValueChanged<String> onChanged, {
      required IconData icon,
      TextInputType keyboard = TextInputType.text,
      FormFieldValidator<String>? validator,
    }) {
  return TextFormField(
    initialValue: initial,
    keyboardType: keyboard,
    onChanged: onChanged,
    validator: validator,
    decoration: _decor(label, icon),
  );
}

InputDecoration _decor(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: kPrimaryDark),
    prefixIcon: Icon(icon, color: kPrimary, size: 20),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kPrimary, width: 1.5)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
        BorderSide(color: kPrimaryLight.withOpacity(0.35))),
    filled: true,
    fillColor: Colors.grey.shade50,
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  );
}