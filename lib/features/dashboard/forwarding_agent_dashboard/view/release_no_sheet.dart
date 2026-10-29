import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/network/api_failure.dart';
import '../../../../core/rti/rti_api.dart';

/// C3 (forwarding clean-up, owner 2026-10-26): the agent gives the release no on the stop card he already uses —
/// one release no per job on the truck. Saved on the job's forwarding leg (the same place the old FW Update wrote).
Future<void> showReleaseNoSheet(BuildContext context, {required int stopId, required String title}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ReleaseNoSheet(stopId: stopId, title: title),
    ),
  );
}

class ReleaseNoSheet extends StatefulWidget {
  const ReleaseNoSheet({super.key, required this.stopId, required this.title, this.api});

  final int stopId;
  final String title;
  final RtiApi? api;

  @override
  State<ReleaseNoSheet> createState() => _ReleaseNoSheetState();
}

class _ReleaseNoSheetState extends State<ReleaseNoSheet> {
  late final RtiApi _api = widget.api ?? GetIt.instance<RtiApi>();
  List<StopJob>? _jobs;
  String? _error;
  int? _saving;
  final Map<int, TextEditingController> _boxes = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in _boxes.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final jobs = await _api.stopJobs(widget.stopId);
      if (!mounted) return;
      setState(() {
        _jobs = jobs;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e is ApiFailure ? e.message : 'Could not load the jobs');
    }
  }

  TextEditingController _box(StopJob job) =>
      _boxes.putIfAbsent(job.jobId, () => TextEditingController(text: job.releaseNo ?? ''));

  Future<void> _save(StopJob job) async {
    final text = _box(job).text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Type the release no')));
      return;
    }
    setState(() => _saving = job.jobId);
    try {
      final jobs = await _api.saveStopRelease(widget.stopId, job.jobId, text);
      if (!mounted) return;
      setState(() => _jobs = jobs);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Release no saved for ${job.jobNo ?? job.jobId}')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e is ApiFailure ? e.message : 'Could not save the release no')));
    } finally {
      if (mounted) setState(() => _saving = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobs = _jobs;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Release no · ${widget.title}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('One release no for each job on this truck.', style: TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 12),
          if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
          if (jobs == null && _error == null) const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
          if (jobs != null && jobs.isEmpty) const Text('No jobs on this RTI.'),
          if (jobs != null && jobs.isNotEmpty)
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: jobs.length,
                separatorBuilder: (_, __) => const Divider(height: 16),
                itemBuilder: (_, i) {
                  final job = jobs[i];
                  final saved = (job.releaseNo ?? '').isNotEmpty;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(saved ? Icons.check_circle : Icons.radio_button_unchecked,
                              size: 18, color: saved ? Colors.green : Colors.grey),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text('${job.jobNo ?? job.jobId}  ·  ${job.formType ?? 'K8'}',
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      if ((job.customer ?? '').isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 24),
                          child: Text(job.customer!, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _box(job),
                              decoration: const InputDecoration(
                                labelText: 'Release no',
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _save(job),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: _saving == null ? () => _save(job) : null,
                            child: _saving == job.jobId
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
