import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/forwarding_request/forwarding_request_api.dart';
import 'package:maleva/core/forwarding_request/forwarding_request_models.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/forwarding_requests/bloc/request_forwarding_cubit.dart';
import 'package:maleva/features/forwarding_requests/view/forwarding_request_card.dart';
import 'package:maleva/features/planning/widgets/date_fields.dart';

/// Customer Service's "Request FW" from the sale order: the form types the job needs (several at
/// once) and the estimated date-time. Bottom sheet on a phone, dialog on a tablet. Resolves to the
/// requests created, or null when closed.
Future<List<ForwardingRequest>?> showRequestForwardingSheet(
  BuildContext context, {
  required int saleOrderId,
  required String jobNo,
  ForwardingRequestApi? api,
}) {
  final body = BlocProvider(
    create: (_) => RequestForwardingCubit(api ?? sl<ForwardingRequestApi>(), saleOrderId: saleOrderId)..load(),
    child: _RequestForwardingForm(jobNo: jobNo),
  );
  if (FormFactor.of(context).isTablet) {
    return showDialog<List<ForwardingRequest>>(
      context: context,
      useRootNavigator: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480, maxHeight: 640), child: MalevaThemeScope(child: body)),
      ),
    );
  }
  return showModalBottomSheet<List<ForwardingRequest>>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      child: SizedBox(height: MediaQuery.sizeOf(ctx).height * 0.9, child: MalevaThemeScope(child: body)),
    ),
  );
}

class _RequestForwardingForm extends StatefulWidget {
  const _RequestForwardingForm({required this.jobNo});

  final String jobNo;

  @override
  State<_RequestForwardingForm> createState() => _RequestForwardingFormState();
}

class _RequestForwardingFormState extends State<_RequestForwardingForm> {
  final Set<String> formTypes = {};
  late String estimate = _tomorrowNine();
  final TextEditingController remarks = TextEditingController();

  static String _tomorrowNine() {
    final t = DateTime.now().add(const Duration(days: 1));
    return toYmdHm(DateTime(t.year, t.month, t.day, 9, 0));
  }

  @override
  void dispose() {
    remarks.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    final when = parseYmdHm(estimate);
    if (formTypes.isEmpty || when == null) return;
    try {
      final created = await context.read<RequestForwardingCubit>().create(
            formTypes: forwardingFormTypes.where(formTypes.contains).toList(),
            estimate: when,
            remarks: remarks.text,
          );
      if (!context.mounted) return;
      showSnack(context, created.length == 1 ? 'Forwarding request created' : '${created.length} forwarding requests created');
      Navigator.of(context, rootNavigator: true).pop(created);
    } catch (e) {
      if (context.mounted) showSnack(context, '$e', kind: SnackKind.error);
    }
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<RequestForwardingCubit, RequestForwardingState>(
        builder: (context, state) {
          final mc = context.mc;
          final repeated = formTypes.where(state.openTypes.contains).toList();
          final canSave = formTypes.isNotEmpty && parseYmdHm(estimate) != null && !state.saving;
          return Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
              child: Row(children: [
                const Icon(Icons.assignment_outlined),
                const SizedBox(width: 8),
                Expanded(child: Text('Request forwarding · ${widget.jobNo}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis)),
                IconButton(onPressed: state.saving ? null : () => Navigator.of(context, rootNavigator: true).pop(), icon: const Icon(Icons.close)),
              ]),
            ),
            Expanded(
              child: ListView(padding: const EdgeInsets.all(16), children: [
                Text('FORMS NEEDED', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: mc.muted)),
                const SizedBox(height: 6),
                Row(children: [
                  for (final t in forwardingFormTypes) ...[
                    Expanded(
                      child: FilterChip(
                        label: Center(child: Text(t, style: const TextStyle(fontWeight: FontWeight.w900))),
                        selected: formTypes.contains(t),
                        selectedColor: formTypeColor(t),
                        labelStyle: TextStyle(color: formTypes.contains(t) ? Colors.white : null),
                        checkmarkColor: Colors.white,
                        onSelected: (_) => setState(() => formTypes.contains(t) ? formTypes.remove(t) : formTypes.add(t)),
                      ),
                    ),
                    if (t != forwardingFormTypes.last) const SizedBox(width: 6),
                  ],
                ]),
                if (repeated.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('${repeated.join(', ')} already requested for this job and still open. Saving adds another.',
                        style: TextStyle(fontSize: 12, color: mc.toneFg(StatusTone.warning))),
                  ),
                const SizedBox(height: 16),
                DateTimeField(label: 'Estimated date and time', value: estimate, onChanged: (v) => setState(() => estimate = v)),
                const SizedBox(height: 12),
                TextField(controller: remarks, maxLength: 500, maxLines: 2, decoration: const InputDecoration(labelText: 'Remarks', hintText: 'Anything the forwarding team should know')),
                const SizedBox(height: 12),
                Text('ALREADY REQUESTED', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: mc.muted)),
                const SizedBox(height: 6),
                if (state.loading)
                  Text('Loading this job\'s requests…', style: TextStyle(fontSize: 12, color: mc.muted))
                else if (state.error != null)
                  Text(state.error!, style: TextStyle(fontSize: 12, color: mc.toneFg(StatusTone.danger)))
                else if (state.existing.isEmpty)
                  Text('No forwarding requested for this job yet.', style: TextStyle(fontSize: 12, color: mc.muted))
                else
                  for (final r in state.existing)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: FormTypeBadge(r.formType),
                      title: Text(forwardingWhen(r.estimatedDate)),
                      subtitle: Text(r.requestedBy),
                      trailing: StatusPill(forwardingStatusLabel(r.status), tone: forwardingTone(r.status)),
                    ),
              ]),
            ),
            StickyActionBar(actions: [
              OutlinedButton(onPressed: state.saving ? null : () => Navigator.of(context, rootNavigator: true).pop(), child: const Text('Cancel')),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: canSave ? () => _submit(context) : null,
                child: Text(state.saving ? 'Saving…' : formTypes.length > 1 ? 'Request ${formTypes.length} forms' : 'Request'),
              ),
            ]),
          ]);
        },
      );
}
