import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/features/dashboard/admin_dashboard/tabs/spotsaleorder/view/spotsaleorder_view.dart';
import '../../../../../../core/theme/tokens.dart';
import '../bloc/spotsaleorder_bloc.dart';
import '../bloc/spotsaleorder_event.dart';
import '../bloc/spotsaleorder_state.dart';

// ── Entry Point ───────────────────────────────────────────────────────────────
class SpotSaleEntryPage extends StatelessWidget {
  final int editId;
  const SpotSaleEntryPage({super.key, this.editId = 0});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SpotSaleBloc.form(context, editId: editId),
      child: const _SpotSaleEntryBody(),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────
class _SpotSaleEntryBody extends StatelessWidget {
  const _SpotSaleEntryBody();

  static final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return BlocConsumer<SpotSaleBloc, SpotSaleState>(
      listener: (context, state) {
        if (state is SpotSaleSubmitSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Submitted successfully ✅",
                style: GoogleFonts.lato(color: colour.kWhite)),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ));
          context
              .read<SpotSaleBloc>()
              .add(const ResetSpotSaleFormEvent());
        }
        if (state is SpotSaleEntryError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      builder: (context, state) {
        if (state is! SpotSaleEntryState) return const SizedBox.shrink();

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
      BuildContext context, SpotSaleEntryState s) {
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
            child: _SpotSalePreviewPanel(state: s),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // MOBILE — Single Column
  // ══════════════════════════════════════════════════════
  Widget _buildMobileLayout(
      BuildContext context, SpotSaleEntryState s) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
      child: _buildFormContent(context, s, isTablet: false),
    );
  }

  // ══════════════════════════════════════════════════════
  // SHARED — Form Content
  // ══════════════════════════════════════════════════════
  Widget _buildFormContent(
      BuildContext context, SpotSaleEntryState s,
      {required bool isTablet}) {
    final bloc = context.read<SpotSaleBloc>();

    final jobTypeName = objfun.JobTypeList
        .where((j) => j.Id.toString() == s.selectedJobType)
        .map((j) => j.Name ?? '')
        .firstOrNull ?? '';

    final jobStatusName = objfun.JobStatusList
        .where((j) => j.Id.toString() == s.selectedJobStatus)
        .map((j) => j.Name ?? '')
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
              Text('SPOT SALE ENTRY',
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
                    color: AppTokens.brandMid,
                    fontWeight: FontWeight.w500,
                  )),
            ),
            const SizedBox(height: 24),
          ],

          // ════════════════════════════
          // SECTION 1 — Job Info
          // ════════════════════════════
          _SectionCard(
            icon: Icons.work_rounded,
            title: "Job Info",
            isTablet: isTablet,
            children: [
              _SelectTile(
                icon: Icons.category_rounded,
                label: "Job Type",
                value: jobTypeName.isNotEmpty ? jobTypeName : null,
                placeholder: "Tap to select Job Type",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          _JobTypeSelectPage(bloc: bloc)),
                ),
              ),

              const SizedBox(height: 12),

              _SelectTile(
                icon: Icons.flag_rounded,
                label: "Status",
                value: jobStatusName.isNotEmpty
                    ? jobStatusName
                    : null,
                placeholder: "Tap to select Status",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          _JobStatusSelectPage(bloc: bloc)),
                ),
              ),

              const SizedBox(height: 12),

              _SelectTile(
                icon: Icons.anchor_rounded,
                label: "Port",
                value: s.selectedPort,
                placeholder: "Tap to select Port",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          _PortSelectPage(bloc: bloc)),
                ),
              ),
            ],
          ),

          SizedBox(height: isTablet ? 16 : 14),

          // ════════════════════════════
          // SECTION 2 — Cargo Details
          // ════════════════════════════
          _SectionCard(
            icon: Icons.inventory_2_rounded,
            title: "Cargo Details",
            isTablet: isTablet,
            children: [
              TextFormField(
                initialValue: s.cargoQty,
                keyboardType: TextInputType.number,
                onChanged: (v) =>
                    bloc.add(UpdateCargoQtyEvent(v)),
                validator: (v) =>
                (v == null || v.trim().isEmpty)
                    ? "Please enter Cargo Qty"
                    : null,
                decoration: _decor(
                    "Cargo Qty", Icons.numbers_rounded),
              ),

              const SizedBox(height: 12),

              TextFormField(
                initialValue: s.vehicleName,
                onChanged: (v) =>
                    bloc.add(UpdateVehicleNameEvent(v)),
                validator: (v) =>
                (v == null || v.trim().isEmpty)
                    ? "Please enter Vehicle Name"
                    : null,
                decoration: _decor("Vehicle Name",
                    Icons.local_shipping_rounded),
              ),

              const SizedBox(height: 12),

              TextFormField(
                initialValue: s.awbNo,
                onChanged: (v) => bloc.add(UpdateAWBNoEvent(v)),
                validator: (v) =>
                (v == null || v.trim().isEmpty)
                    ? "Please enter AWB No"
                    : null,
                decoration: _decor("Air Waybill Number",
                    Icons.confirmation_number_rounded),
              ),

              const SizedBox(height: 12),

              TextFormField(
                initialValue: s.cargoWeight,
                keyboardType: TextInputType.number,
                onChanged: (v) =>
                    bloc.add(UpdateCargoWeightEvent(v)),
                validator: (v) =>
                (v == null || v.trim().isEmpty)
                    ? "Please enter Cargo Weight"
                    : null,
                decoration: _decor(
                    "Cargo Weight (kg)", Icons.scale_rounded),
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
                        color:
                        colour.kPrimary.withOpacity(0.2)),
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
              ] else if (s.networkImageUrl != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    s.networkImageUrl!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                    const Text("Unable to load image"),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 10),
                Text("No document uploaded",
                    style:
                    GoogleFonts.lato(color: Colors.grey)),
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
                    context.read<SpotSaleBloc>().add(
                        const SubmitSpotSaleEvent());
                  }
                },
                child: s.isSubmitting
                    ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(
                        color: colour.kWhite,
                        strokeWidth: 2))
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
                        builder: (_) =>
                        const SpotSaleViewPage())),
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
class _SpotSalePreviewPanel extends StatelessWidget {
  final SpotSaleEntryState state;
  const _SpotSalePreviewPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    final s = state;

    final jobTypeName = objfun.JobTypeList
        .where((j) => j.Id.toString() == s.selectedJobType)
        .map((j) => j.Name ?? '')
        .firstOrNull ?? 'Not selected';

    final jobStatusName = objfun.JobStatusList
        .where((j) => j.Id.toString() == s.selectedJobStatus)
        .map((j) => j.Name ?? '')
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

            // Job Type banner
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
                  Text('Job Type',
                      style: GoogleFonts.lato(
                        fontSize: 11,
                        color: colour.kWhite.withOpacity(0.75),
                      )),
                  const SizedBox(height: 4),
                  Text(
                    jobTypeName,
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

            _previewRow(Icons.flag_rounded,
                'Status', jobStatusName),
            const SizedBox(height: 12),

            _previewRow(Icons.anchor_rounded, 'Port',
                s.selectedPort ?? 'Not selected'),
            const SizedBox(height: 12),

            _previewRow(Icons.numbers_rounded, 'Cargo Qty',
                s.cargoQty.isNotEmpty ? s.cargoQty : '-'),
            const SizedBox(height: 12),

            _previewRow(Icons.local_shipping_rounded,
                'Vehicle Name',
                s.vehicleName.isNotEmpty
                    ? s.vehicleName
                    : '-'),
            const SizedBox(height: 12),

            _previewRow(Icons.confirmation_number_rounded,
                'AWB No',
                s.awbNo.isNotEmpty ? s.awbNo : '-'),
            const SizedBox(height: 12),

            _previewRow(Icons.scale_rounded, 'Cargo Weight',
                s.cargoWeight.isNotEmpty
                    ? '${s.cargoWeight} kg'
                    : '-'),

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

                  if (s.pickedImage != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(s.pickedImage!,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover),
                    ),
                  ] else if (s.networkImageUrl != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        s.networkImageUrl!,
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                        const SizedBox.shrink(),
                      ),
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
                              ? s.pickedPDF!.path
                              .split('/')
                              .last
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
                  _tipRow('Select Job Type and Status first'),
                  _tipRow('AWB No and Cargo Weight required'),
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
                  ),
                  overflow: TextOverflow.ellipsis),
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

// ── Select Pages (unchanged) ──────────────────────────────────────────────────
class _JobTypeSelectPage extends StatefulWidget {
  final SpotSaleBloc bloc;
  const _JobTypeSelectPage({required this.bloc});

  @override
  State<_JobTypeSelectPage> createState() =>
      _JobTypeSelectPageState();
}

class _JobTypeSelectPageState extends State<_JobTypeSelectPage> {
  final _searchCtrl = TextEditingController();
  late List<JobTypeModel> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = List.from(objfun.JobTypeList);
  }

  void _search(String q) {
    setState(() {
      _filtered = q.isEmpty
          ? List.from(objfun.JobTypeList)
          : objfun.JobTypeList
          .where((j) => (j.Name ?? '')
          .toUpperCase()
          .contains(q.toUpperCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _SelectPageScaffold(
      title: "Select Job Type",
      icon: Icons.category_rounded,
      searchCtrl: _searchCtrl,
      onSearch: _search,
      count: _filtered.length,
      listBuilder: (i) {
        final item = _filtered[i];
        return _SelectListTile(
          label: item.Name ?? '',
          onTap: () {
            widget.bloc
                .add(SelectJobTypeEvent(item.Id.toString()));
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
}

class _JobStatusSelectPage extends StatefulWidget {
  final SpotSaleBloc bloc;
  const _JobStatusSelectPage({required this.bloc});

  @override
  State<_JobStatusSelectPage> createState() =>
      _JobStatusSelectPageState();
}

class _JobStatusSelectPageState
    extends State<_JobStatusSelectPage> {
  final _searchCtrl = TextEditingController();
  late List<JobStatusModel> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = List.from(objfun.JobStatusList);
  }

  void _search(String q) {
    setState(() {
      _filtered = q.isEmpty
          ? List.from(objfun.JobStatusList)
          : objfun.JobStatusList
          .where((j) => (j.Name ?? '')
          .toUpperCase()
          .contains(q.toUpperCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _SelectPageScaffold(
      title: "Select Status",
      icon: Icons.flag_rounded,
      searchCtrl: _searchCtrl,
      onSearch: _search,
      count: _filtered.length,
      listBuilder: (i) {
        final item = _filtered[i];
        return _SelectListTile(
          label: item.Name ?? '',
          onTap: () {
            widget.bloc.add(
                SelectJobStatusEvent(item.Id.toString()));
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
}

class _PortSelectPage extends StatefulWidget {
  final SpotSaleBloc bloc;
  const _PortSelectPage({required this.bloc});

  @override
  State<_PortSelectPage> createState() => _PortSelectPageState();
}

class _PortSelectPageState extends State<_PortSelectPage> {
  final _searchCtrl = TextEditingController();
  late List<ListItem> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = List.from(objfun.Portlist);
  }

  void _search(String q) {
    setState(() {
      _filtered = q.isEmpty
          ? List.from(objfun.Portlist)
          : objfun.Portlist
          .where((p) => (p.name ?? '')
          .toUpperCase()
          .contains(q.toUpperCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _SelectPageScaffold(
      title: "Select Port",
      icon: Icons.anchor_rounded,
      searchCtrl: _searchCtrl,
      onSearch: _search,
      count: _filtered.length,
      listBuilder: (i) {
        final item = _filtered[i];
        return _SelectListTile(
          label: item.name ?? '',
          onTap: () {
            widget.bloc.add(SelectPortEvent(item.name));
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
}

// ── Shared Select Page Scaffold ───────────────────────────────────────────────
class _SelectPageScaffold extends StatelessWidget {
  final String title;
  final IconData icon;
  final TextEditingController searchCtrl;
  final ValueChanged<String> onSearch;
  final int count;
  final Widget Function(int index) listBuilder;

  const _SelectPageScaffold({
    required this.title,
    required this.icon,
    required this.searchCtrl,
    required this.onSearch,
    required this.count,
    required this.listBuilder,
  });

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
        title: Text(title,
            style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: colour.kWhite)),
        centerTitle: true,
      ),
      body: Column(children: [
        Container(
          color: colour.kPrimary,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: TextField(
            controller: searchCtrl,
            onChanged: onSearch,
            style: GoogleFonts.lato(
                color: colour.kPrimaryDark,
                fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'Search $title...',
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
            Icon(icon,
                color: AppTokens.brandMid, size: 16),
            const SizedBox(width: 6),
            Text("$count items found",
                style: GoogleFonts.lato(
                    fontSize: 13,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600)),
          ]),
        ),
        Expanded(
          child: count == 0
              ? Center(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off_rounded,
                      color: Colors.grey.shade300,
                      size: 56),
                  const SizedBox(height: 10),
                  Text("No items found",
                      style: GoogleFonts.lato(
                          fontSize: 16,
                          color: Colors.grey)),
                ]),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 4),
            itemCount: count,
            itemBuilder: (_, i) => listBuilder(i),
          ),
        ),
      ]),
    );
  }
}

// ── Shared List Tile ──────────────────────────────────────────────────────────
class _SelectListTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SelectListTile(
      {required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: colour.kWhite,
          borderRadius: BorderRadius.circular(14),
          border:
          Border.all(color: colour.kAccent, width: 1.5),
          boxShadow: [
            BoxShadow(
                color: colour.kPrimary.withOpacity(0.05),
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
            child: const Icon(
                Icons.check_circle_outline_rounded,
                color: colour.kPrimary,
                size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: GoogleFonts.lato(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colour.kPrimaryDark)),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppTokens.brandMid),
        ]),
      ),
    );
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
              border: Border.all(
                  color: colour.kAccent, width: 1.5),
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
          color: hasValue
              ? colour.kAccent
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasValue
                ? AppTokens.brandMid.withOpacity(0.4)
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
                    overflow: TextOverflow.ellipsis,
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
    labelStyle:
    const TextStyle(color: colour.kPrimaryDark),
    prefixIcon: Icon(icon, color: colour.kPrimary, size: 20),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
            color: colour.kPrimary, width: 1.5)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
            color: AppTokens.brandMid.withOpacity(0.35))),
    filled: true,
    fillColor: Colors.grey.shade50,
    contentPadding: const EdgeInsets.symmetric(
        horizontal: 14, vertical: 14),
  );
}