import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/widgets/maleva_inputs.dart';

import '../bloc/leave_bloc.dart';
import '../bloc/leave_event.dart';
import '../bloc/leave_state.dart';
import '../data/leave_calendar.dart';
import '../data/leave_form.dart';
import '../data/leave_repository.dart';
import '../data/leave_request_model.dart';

/// Request Leave for a driver (applicant type 2) or an employee (type 1): Whole days (default), half day
/// morning / afternoon, or Hours on one day (staff only). One form for both tabs (openspec changes
/// `leave-dates-and-decisions`, `hr-leave-working-days`). Half days and the working-day count show only
/// when the server counts working days (its switch); otherwise the form is as before.
class LeaveRequestFormSheet extends StatefulWidget {
  const LeaveRequestFormSheet({
    super.key,
    required this.applicantType,
    required this.applicantRefId,
    required this.leaveTypes,
    this.loadCalendar,
  });

  final int applicantType;
  final int applicantRefId;
  final List<LeaveTypeModel> leaveTypes;

  /// The company calendar (tests pass their own); by default from the shared `/api/hr` reads.
  final Future<LeaveCalendar> Function(bool driver, Iterable<int> years)? loadCalendar;

  @override
  State<LeaveRequestFormSheet> createState() => _LeaveRequestFormSheetState();
}

class _LeaveRequestFormSheetState extends State<LeaveRequestFormSheet> {
  LeaveForm _form = LeaveForm.start(DateTime.now());
  int? _leaveTypeId;
  final TextEditingController _reason = TextEditingController();
  LeaveCalendar _calendar = LeaveCalendar.off;

  static final _day = DateFormat('dd-MM-yyyy');

  bool get _driver => widget.applicantType == 2;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final years = [if (now.month == 1) now.year - 1, now.year, now.year + 1];
    final load = widget.loadCalendar ??
        (bool driver, Iterable<int> ys) => sl<LeaveRepository>().getCalendar(driver: driver, years: ys);
    load(_driver, years).then((cal) {
      if (mounted) setState(() => _calendar = cal);
    });
  }

  /// The kinds offered: with working days on, whole days / morning / afternoon (+ hours for staff);
  /// otherwise whole days / hours as before.
  List<LeaveKind> get _kinds => _calendar.enabled
      ? [LeaveKind.full, LeaveKind.am, LeaveKind.pm, if (!_driver) LeaveKind.hours]
      : [LeaveKind.full, LeaveKind.hours];

  /// "2½ working days", "½ day", or the old length when working days are off.
  String get _length {
    if (!_calendar.enabled) return _form.durationLabel;
    final days = _calendar.workingDays(_form);
    if (_form.hours) return '${_form.durationLabel} = ${dayCount(days)} day';
    if (days == 0) return _driver ? 'Rest day (0 days)' : 'Not a working day';
    return '${dayCount(days)} working ${days == 1 ? "day" : "days"}';
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _submit(BuildContext ctx) {
    final messenger = ScaffoldMessenger.of(context);
    if (_leaveTypeId == null) {
      messenger.showSnackBar(const SnackBar(content: Text('Please select Leave Reason')));
      return;
    }
    final error = _form.error;
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    if (_calendar.enabled && !_driver && _form.kind == LeaveKind.full && _calendar.workingDays(_form) == 0) {
      messenger.showSnackBar(const SnackBar(content: Text('All chosen days are Sundays or holidays')));
      return;
    }
    final typed = _reason.text.trim();
    ctx.read<LeaveBloc>().add(SubmitLeaveRequest(
          leaveTypeRefId: _leaveTypeId!,
          fromDate: _form.from,
          toDate: _form.to,
          totalDays: _form.totalDays,
          applicantRefId: widget.applicantRefId,
          applicantType: widget.applicantType,
          part: _calendar.enabled ? _form.kind.part : null,
          reason: typed.isNotEmpty ? typed : widget.leaveTypes.firstWhere((e) => e.id == _leaveTypeId).name,
        ));
  }

  Future<void> _pickDay({required bool from}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: from ? _form.fromDay : _form.toDay,
      firstDate: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) return;
    setState(() => _form = from ? _form.copyWith(fromDay: picked) : _form.copyWith(toDay: picked));
  }

  Future<void> _pickTime({required bool from}) async {
    final picked = await showTimePicker(context: context, initialTime: from ? _form.fromTime : _form.toTime);
    if (picked == null || !mounted) return;
    setState(() => _form = from ? _form.copyWith(fromTime: picked) : _form.copyWith(toTime: picked));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LeaveBloc, LeaveState>(
      listener: (context, state) {
        if (state is LeaveActionSuccess && ModalRoute.of(context)?.isCurrent == true) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final submitting = state is LeaveLoaded && state.isSubmitting;
        final error = _form.error;
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                Text('Request Leave',
                    style: AppTypography.heading1(color: AppTokens.brandDark, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                SegmentedButton<LeaveKind>(
                  key: const Key('leave_kind'),
                  showSelectedIcon: false,
                  segments: [
                    for (final k in _kinds)
                      ButtonSegment(
                        value: k,
                        label: Text(k.label),
                        icon: Icon(switch (k) {
                          LeaveKind.full => Icons.calendar_month_rounded,
                          LeaveKind.am => Icons.wb_twilight_rounded,
                          LeaveKind.pm => Icons.wb_sunny_rounded,
                          LeaveKind.hours => Icons.schedule_rounded,
                        }),
                      ),
                  ],
                  selected: {_kinds.contains(_form.kind) ? _form.kind : LeaveKind.full},
                  onSelectionChanged: (s) => setState(() => _form = _form.copyWith(kind: s.first)),
                ),
                const SizedBox(height: 16),
                if (_form.kind == LeaveKind.am || _form.kind == LeaveKind.pm)
                  _labelled('Date', MalevaDateField(date: _day.format(_form.fromDay), onTap: () => _pickDay(from: true)))
                else if (!_form.hours)
                  Row(children: [
                    Expanded(
                      child: _labelled('From date',
                          MalevaDateField(date: _day.format(_form.fromDay), onTap: () => _pickDay(from: true))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _labelled('To date',
                          MalevaDateField(date: _day.format(_form.toDay), onTap: () => _pickDay(from: false))),
                    ),
                  ])
                else ...[
                  _labelled('Date', MalevaDateField(date: _day.format(_form.fromDay), onTap: () => _pickDay(from: true))),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: _labelled('From time',
                          MalevaDateField(date: _form.fromTime.format(context), onTap: () => _pickTime(from: true))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _labelled('To time',
                          MalevaDateField(date: _form.toTime.format(context), onTap: () => _pickTime(from: false))),
                    ),
                  ]),
                ],
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTokens.brandLight.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Duration:', style: AppTypography.bodyMedium(color: AppTokens.textMuted)),
                      Text(error ?? _length,
                          key: const Key('leave_duration'),
                          style: AppTypography.heading2(color: error == null ? AppTokens.brandDark : Colors.red.shade700)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(color: AppTokens.surfacePage, borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: _leaveTypeId,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTokens.textMuted),
                      hint: Text('Select Leave Reason', style: AppTypography.bodyLarge(color: AppTokens.textMuted)),
                      items: widget.leaveTypes
                          .map((e) => DropdownMenuItem<int>(
                                value: e.id,
                                child: Text(e.name, style: AppTypography.bodyLarge(color: AppTokens.textPrimary)),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _leaveTypeId = val),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(color: AppTokens.surfacePage, borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextField(
                    controller: _reason,
                    maxLength: 500,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      counterText: '',
                      hintText: 'Enter specific reason/remark (optional)',
                      hintStyle: AppTypography.bodyLarge(color: AppTokens.textMuted),
                    ),
                    style: AppTypography.bodyLarge(color: AppTokens.textPrimary),
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTokens.brandPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: submitting ? null : () => _submit(context),
                    child: submitting
                        ? const SizedBox(
                            width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text('Submit Request',
                                  style: AppTypography.heading2(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _labelled(String label, Widget field) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.bodySmall(color: AppTokens.textMuted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          field,
        ],
      );
}
