import 'package:flutter/material.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/employee/employee_api.dart';
import 'package:maleva/core/forwarding_request/forwarding_request_models.dart';
import 'package:maleva/core/models/shared/employee_model.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/forwarding_requests/view/forwarding_request_card.dart';
import 'package:maleva/features/planning/widgets/date_fields.dart';

/// The forwarding team works one request: the five ticks and their references, the seal and
/// break-seal employees, saved together by the Save button (nothing is sent before). Ticking a
/// step ticks every step below it; unticking a step unticks every step above it.
class ForwardingRequestEditPage extends StatefulWidget {
  const ForwardingRequestEditPage({super.key, required this.request, required this.onSave, required this.onCancelRequest, this.employeeApi});

  final ForwardingRequest request;

  /// Sends the ticks; throws the server's message when refused.
  final Future<ForwardingRequest> Function(ForwardingRequestTicks ticks) onSave;
  final Future<ForwardingRequest> Function() onCancelRequest;
  final EmployeeApi? employeeApi;

  @override
  State<ForwardingRequestEditPage> createState() => _ForwardingRequestEditPageState();
}

class _ForwardingRequestEditPageState extends State<ForwardingRequestEditPage> {
  late ForwardingRequestTicks ticks = ForwardingRequestTicks.fromRequest(widget.request);
  late final TextEditingController cNumber = TextEditingController(text: ticks.cNumber);
  late final TextEditingController submittedRef = TextEditingController(text: ticks.submittedRef);
  late final TextEditingController releaseNo = TextEditingController(text: ticks.releaseNo);
  List<EmployeeModel> employees = const [];
  String sealByName = '';
  String breakSealByName = '';
  bool saving = false;

  @override
  void initState() {
    super.initState();
    sealByName = widget.request.sealBy;
    breakSealByName = widget.request.breakSealBy;
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    try {
      final list = await (widget.employeeApi ?? sl<EmployeeApi>()).dropdown();
      if (mounted) setState(() => employees = list);
    } catch (_) {
      // the pickers stay empty; the ticks can still be saved
    }
  }

  @override
  void dispose() {
    cNumber.dispose();
    submittedRef.dispose();
    releaseNo.dispose();
    super.dispose();
  }

  ForwardingRequestTicks get _current => ticks.copyWith(cNumber: cNumber.text, submittedRef: submittedRef.text, releaseNo: releaseNo.text);

  void _step(ForwardingStep step, bool on) => setState(() {
        ticks = _current.step(step, on);
        cNumber.text = ticks.cNumber;
        submittedRef.text = ticks.submittedRef;
        releaseNo.text = ticks.releaseNo;
      });

  Future<void> _pickEmployee({required bool seal}) async {
    final current = seal ? ticks.sealById : ticks.breakSealById;
    final r = await showPickerSheet<int>(
      context,
      title: seal ? 'Seal by' : 'Break seal by',
      options: [for (final e in employees) PickOption(value: e.Id, label: e.AccountName)],
      current: current > 0 ? current : null,
      allowClear: true,
      searchHint: 'Search employee…',
    );
    if (r == null) return;
    setState(() {
      final id = r.cleared ? 0 : (r.value ?? 0);
      final name = id == 0 ? '' : employees.firstWhere((e) => e.Id == id).AccountName;
      if (seal) {
        ticks = ticks.copyWith(sealById: id);
        sealByName = name;
      } else {
        ticks = ticks.copyWith(breakSealById: id);
        breakSealByName = name;
      }
    });
  }

  Future<void> _save() async {
    final toSave = _current;
    final blocker = toSave.blocker;
    if (blocker != null) {
      showSnack(context, blocker, kind: SnackKind.error);
      return;
    }
    setState(() => saving = true);
    try {
      final saved = await widget.onSave(toSave);
      if (!mounted) return;
      showSnack(context, '${saved.formType} on ${saved.jobNo} saved');
      Navigator.pop(context, saved);
    } catch (e) {
      if (mounted) showSnack(context, '$e', kind: SnackKind.error);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _cancelRequest() async {
    final r = widget.request;
    final ok = await showConfirm(context,
        title: 'Cancel forwarding request',
        message: 'Cancel the ${r.formType} request for ${r.jobNo}? It stays in history as cancelled.',
        confirmLabel: 'Cancel request',
        destructive: true);
    if (!ok || !mounted) return;
    setState(() => saving = true);
    try {
      final cancelled = await widget.onCancelRequest();
      if (!mounted) return;
      showSnack(context, 'Request cancelled');
      Navigator.pop(context, cancelled);
    } catch (e) {
      if (mounted) showSnack(context, '$e', kind: SnackKind.error);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    final mc = context.mc;
    return MalevaThemeScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text('${r.formType} · ${r.jobNo}'),
          actions: [
            if (!r.cancelled)
              IconButton(tooltip: 'Cancel this request', onPressed: saving ? null : _cancelRequest, icon: const Icon(Icons.block)),
          ],
        ),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          DetailSection(
            title: 'Job',
            icon: Icons.work_outline,
            trailing: StatusPill(forwardingStatusLabel(r.status), tone: forwardingTone(r.status)),
            child: Column(children: [
              KeyValueRow('Customer', r.customerName),
              KeyValueRow('Vessel', r.vesselName),
              KeyValueRow('Job type', r.jobType),
              KeyValueRow('Estimated', forwardingWhen(r.estimatedDate)),
              KeyValueRow('Requested by', '${r.requestedBy} ${forwardingWhen(r.requestedDate)}'.trim()),
              if (r.remarks.isNotEmpty) KeyValueRow('Remarks', r.remarks),
            ]),
          ),
          const SizedBox(height: 8),
          DetailSection(
            title: 'Steps',
            icon: Icons.checklist,
            child: Column(children: [
              _tick('Documents received', ticks.documentReceived, ForwardingStep.documentReceived, r.documentReceivedBy, r.documentReceivedDate),
              _tick('Draft created', ticks.draftCreated, ForwardingStep.draftCreated, r.draftCreatedBy, r.draftCreatedDate),
              if (ticks.draftCreated) _text(cNumber, 'C Number', required: true),
              _tick('Submitted to customs', ticks.submitted, ForwardingStep.submitted, r.submittedBy, r.submittedDate),
              if (ticks.submitted) _text(submittedRef, 'Registration no'),
              _tick('Approved by customs', ticks.approved, ForwardingStep.approved, r.approvedBy, r.approvedDate),
              if (ticks.approved)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: DateField(label: 'Approved on', value: ticks.approvedDate, onChanged: (v) => setState(() => ticks = ticks.copyWith(approvedDate: v))),
                ),
              _tick('Released', ticks.released, ForwardingStep.released, r.releasedBy, r.releasedDate),
              if (ticks.released) _text(releaseNo, 'Release number', required: true),
            ]),
          ),
          const SizedBox(height: 8),
          DetailSection(
            title: 'Seal',
            icon: Icons.lock_outline,
            child: Column(children: [
              PickerField(label: 'Seal by', value: sealByName, hint: 'Select employee', enabled: !r.cancelled, onTap: () => _pickEmployee(seal: true)),
              const SizedBox(height: 12),
              PickerField(label: 'Break seal by', value: breakSealByName, hint: 'Select employee', enabled: !r.cancelled, onTap: () => _pickEmployee(seal: false)),
              if (employees.isEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text('Loading employees…', style: TextStyle(fontSize: 12, color: mc.muted))),
            ]),
          ),
        ]),
        bottomNavigationBar: r.cancelled
            ? null
            : StickyActionBar(actions: [
                OutlinedButton(onPressed: saving ? null : () => Navigator.pop(context), child: const Text('Back')),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: saving ? null : _save,
                  icon: saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_outlined),
                  label: const Text('Save'),
                ),
              ]),
      ),
    );
  }

  Widget _tick(String label, bool value, ForwardingStep step, String by, DateTime? at) => CheckboxListTile(
        value: value,
        onChanged: widget.request.cancelled ? null : (v) => _step(step, v ?? false),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: by.isEmpty ? null : Text('$by · ${forwardingWhen(at)}', style: TextStyle(fontSize: 12, color: context.mc.muted)),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
      );

  Widget _text(TextEditingController c, String label, {bool required = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 8),
        child: TextField(
          controller: c,
          enabled: !widget.request.cancelled,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(labelText: required ? '$label *' : label),
          onChanged: (_) => setState(() {}),
        ),
      );
}
