import 'package:flutter/material.dart';
import 'package:maleva/core/forwarding_request/forwarding_request_models.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/planning/widgets/date_fields.dart';

/// The list's filters: estimated-date window, form types, statuses, job number. Pops the new filter.
class ForwardingRequestFilterPage extends StatefulWidget {
  const ForwardingRequestFilterPage({super.key, required this.initial});

  final ForwardingRequestFilter initial;

  static Future<ForwardingRequestFilter?> open(BuildContext context, ForwardingRequestFilter initial) =>
      Navigator.of(context, rootNavigator: true).push<ForwardingRequestFilter>(
          MaterialPageRoute(builder: (_) => ForwardingRequestFilterPage(initial: initial), fullscreenDialog: true));

  @override
  State<ForwardingRequestFilterPage> createState() => _ForwardingRequestFilterPageState();
}

class _ForwardingRequestFilterPageState extends State<ForwardingRequestFilterPage> {
  late ForwardingRequestFilter f = widget.initial;
  late final TextEditingController jobNo = TextEditingController(text: widget.initial.jobNo);

  @override
  void dispose() {
    jobNo.dispose();
    super.dispose();
  }

  void _toggle(List<String> list, String value, void Function(List<String>) set) {
    final next = [...list];
    next.contains(value) ? next.remove(value) : next.add(value);
    set(next);
  }

  @override
  Widget build(BuildContext context) => MalevaThemeScope(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Filter requests'),
            actions: [
              TextButton(
                onPressed: () => setState(() {
                  f = ForwardingRequestFilter.defaults(mine: widget.initial.mine);
                  jobNo.text = '';
                }),
                child: const Text('Reset'),
              ),
            ],
          ),
          body: ListView(padding: const EdgeInsets.all(16), children: [
            DateField(label: 'Estimated from', value: f.fromDate, onChanged: (v) => setState(() => f = f.copyWith(fromDate: v)), clearable: true),
            const SizedBox(height: 12),
            DateField(label: 'Estimated to', value: f.toDate, onChanged: (v) => setState(() => f = f.copyWith(toDate: v)), clearable: true),
            const SizedBox(height: 16),
            Text('FORM', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: context.mc.muted)),
            const SizedBox(height: 6),
            Wrap(spacing: 8, children: [
              for (final t in forwardingFormTypes)
                FilterChip(label: Text(t), selected: f.formTypes.contains(t), onSelected: (_) => _toggle(f.formTypes, t, (n) => setState(() => f = f.copyWith(formTypes: n)))),
            ]),
            const SizedBox(height: 16),
            Text('STATUS (NONE = ALL EXCEPT CANCELLED)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: context.mc.muted)),
            const SizedBox(height: 6),
            Wrap(spacing: 8, runSpacing: 4, children: [
              for (final s in [...forwardingStatusSteps, 'CANCELLED'])
                FilterChip(label: Text(forwardingStatusLabel(s)), selected: f.statuses.contains(s), onSelected: (_) => _toggle(f.statuses, s, (n) => setState(() => f = f.copyWith(statuses: n)))),
            ]),
            const SizedBox(height: 16),
            TextField(controller: jobNo, decoration: const InputDecoration(labelText: 'Job No', hintText: 'MY0026…'), textCapitalization: TextCapitalization.characters),
          ]),
          bottomNavigationBar: StickyActionBar(actions: [
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, f.copyWith(jobNo: jobNo.text.trim())),
              icon: const Icon(Icons.search),
              label: const Text('Search'),
            ),
          ]),
        ),
      );
}
