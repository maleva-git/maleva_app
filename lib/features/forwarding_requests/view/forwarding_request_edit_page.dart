import 'package:flutter/material.dart';
import 'package:maleva/core/forwarding_request/forwarding_request_models.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/forwarding_requests/view/forwarding_request_card.dart';

/// The forwarding team works one request: Documents received, Draft created and its C Number, saved
/// together by the Save button (nothing is sent before). Submitted, Approved, Released and the seal
/// people are no longer shown (owner, 2026-10-15); Save passes their saved values through unchanged,
/// except that unticking Draft or Documents unticks every step above it, as the server ladder does.
class ForwardingRequestEditPage extends StatefulWidget {
  const ForwardingRequestEditPage({super.key, required this.request, required this.onSave, required this.onCancelRequest});

  final ForwardingRequest request;

  /// Sends the ticks; throws the server's message when refused.
  final Future<ForwardingRequest> Function(ForwardingRequestTicks ticks) onSave;
  final Future<ForwardingRequest> Function() onCancelRequest;

  @override
  State<ForwardingRequestEditPage> createState() => _ForwardingRequestEditPageState();
}

class _ForwardingRequestEditPageState extends State<ForwardingRequestEditPage> {
  late ForwardingRequestTicks ticks = ForwardingRequestTicks.fromRequest(widget.request);
  late final TextEditingController cNumber = TextEditingController(text: ticks.cNumber);
  bool saving = false;

  @override
  void dispose() {
    cNumber.dispose();
    super.dispose();
  }

  ForwardingRequestTicks get _current => ticks.copyWith(cNumber: cNumber.text);

  void _step(ForwardingStep step, bool on) => setState(() {
        ticks = _current.step(step, on);
        cNumber.text = ticks.cNumber;
      });

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
