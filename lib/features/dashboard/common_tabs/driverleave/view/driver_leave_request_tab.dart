import 'package:flutter/material.dart';
import 'package:maleva/core/utils/dialog_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/leave_bloc.dart';
import '../bloc/leave_event.dart';
import '../bloc/leave_state.dart';
import 'package:get_it/get_it.dart';
import 'package:maleva/features/dashboard/common_tabs/driverleave/data/leave_request_model.dart';
import 'leave_request_form_sheet.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/ui/premium.dart';

class DriverLeaveRequestTab extends StatelessWidget {
  const DriverLeaveRequestTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<LeaveBloc>(),
      child: const _DriverLeaveRequestTabBody(),
    );
  }
}

class _DriverLeaveRequestTabBody extends StatefulWidget {
  const _DriverLeaveRequestTabBody();

  @override
  State<_DriverLeaveRequestTabBody> createState() => _DriverLeaveRequestTabState();
}

class _DriverLeaveRequestTabState extends State<_DriverLeaveRequestTabBody> {
  DateTime _searchFromDate = DateTime.now().subtract(const Duration(days: 30));
  // a year ahead, so leave applied for coming dates is listed (leave-approval-rules)
  DateTime _searchToDate = DateTime.now().add(const Duration(days: 365));
  int? _selectedId;
  List<LeaveRequestModel> _cachedRequests = [];
  List<LeaveTypeModel> _cachedLeaveTypes = [];
  
  @override
  void initState() {
    super.initState();
    _selectedId = AppGlobals.EmpRefId;
    context.read<LeaveBloc>().add(FetchLeaveData(
      applicantType: 2,
      applicantRefId: _selectedId ?? -1,
      fromDate: DateFormat('yyyy-MM-dd').format(_searchFromDate),
      toDate: DateFormat('yyyy-MM-dd').format(_searchToDate),
    ));
  }

  void _fetchRequests(BuildContext ctx) {
    if (_selectedId != null) {
      ctx.read<LeaveBloc>().add(FetchLeaveData(
        applicantType: 2,
        applicantRefId: _selectedId!,
        fromDate: DateFormat('yyyy-MM-dd').format(_searchFromDate),
        toDate: DateFormat('yyyy-MM-dd').format(_searchToDate),
      ));
    }
  }

  Future<void> _pickSearchDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _searchFromDate : _searchToDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _searchFromDate = picked;
        } else {
          _searchToDate = picked;
        }
      });
    }
  }


  void _openLeaveForm(BuildContext context, List<LeaveTypeModel> leaveTypes) {
    final bloc = context.read<LeaveBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return BlocProvider.value(
          value: bloc,
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: LeaveRequestFormSheet(
              applicantType: 2,
              applicantRefId: _selectedId ?? -1,
              leaveTypes: leaveTypes,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LeaveBloc, LeaveState>(
      listener: (context, state) {
        if (state is LeaveActionSuccess) {
          Future.delayed(const Duration(milliseconds: 200), () {
            if (context.mounted) {
              ConfirmationOK(state.message, context);
              _fetchRequests(context);
            }
          });
        } else if (state is LeaveActionError) {
          ConfirmationOK(state.message, context);
        }
      },
      builder: (context, state) {
        bool isLoading = state is LeaveLoading || state is LeaveInitial;
        if (state is LeaveLoaded) {
          if (state.requests.isNotEmpty) _cachedRequests = state.requests;
          if (state.leaveTypes.isNotEmpty) _cachedLeaveTypes = state.leaveTypes;
        }
        
        List<LeaveRequestModel> requests = (state is LeaveLoaded) ? state.requests : _cachedRequests;
        List<LeaveTypeModel> leaveTypes = (state is LeaveLoaded) ? state.leaveTypes : _cachedLeaveTypes;

        final pending = requests.where((r) => r.status != LeaveDecision.approved && r.status != LeaveDecision.rejected).length;
        final approved = requests.where((r) => r.status == LeaveDecision.approved).length;
        final rejected = requests.where((r) => r.status == LeaveDecision.rejected).length;
        return Scaffold(
          backgroundColor: Px.page,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openLeaveForm(context, leaveTypes),
            backgroundColor: Px.brand,
            elevation: 3,
            shape: const StadiumBorder(),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text('Request leave', style: Px.t(15, weight: FontWeight.w800, color: Colors.white)),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              _fetchRequests(context);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 100),
              children: [
                PStatRow(children: [
                  PStat(label: 'Pending', value: '$pending', icon: Icons.hourglass_top_rounded, tone: Tone.amber),
                  PStat(label: 'Approved', value: '$approved', icon: Icons.check_circle_rounded, tone: Tone.green),
                  PStat(label: 'Rejected', value: '$rejected', icon: Icons.cancel_rounded, tone: Tone.red),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: PPill(
                      caption: 'FROM',
                      label: DateFormat('dd MMM yyyy').format(_searchFromDate),
                      icon: Icons.calendar_month_rounded,
                      onTap: () => _pickSearchDate(true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: PPill(
                      caption: 'TO',
                      label: DateFormat('dd MMM yyyy').format(_searchToDate),
                      icon: Icons.calendar_month_rounded,
                      onTap: () => _pickSearchDate(false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: Px.brand,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => _fetchRequests(context),
                      child: const SizedBox(width: 48, height: 48, child: Icon(Icons.search_rounded, color: Colors.white)),
                    ),
                  ),
                ]),
                const PSection('Your leave', subtitle: 'Pull down to refresh'),
                if (isLoading && requests.isEmpty)
                  const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator(color: Px.brand)))
                else if (requests.isEmpty)
                  const PCard(
                    child: PEmpty(icon: Icons.beach_access_rounded, title: 'No leave in these dates', subtitle: 'Tap Request leave to apply.'),
                  )
                else
                  for (final req in requests) _LeaveCard(req: req),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// One leave request: status chip, the dates, how long, the reason, the office's remark.
class _LeaveCard extends StatelessWidget {
  const _LeaveCard({required this.req});

  final LeaveRequestModel req;

  @override
  Widget build(BuildContext context) {
    final tone = req.status == LeaveDecision.approved
        ? Tone.green
        : req.status == LeaveDecision.rejected
            ? Tone.red
            : Tone.amber;
    final day = DateFormat('dd MMM');
    final time = DateFormat('hh:mm a');
    return PCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          PIcon(Icons.event_note_rounded, tone: tone, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${day.format(req.fromDate)} → ${day.format(req.toDate)}', style: Px.t(16, weight: FontWeight.w800)),
              Text('${time.format(req.fromDate)} – ${time.format(req.toDate)}', style: Px.small),
            ]),
          ),
          PChip(req.statusName.isEmpty ? 'Pending' : req.statusName, tone: tone, dot: true),
        ]),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Px.soft, borderRadius: BorderRadius.circular(14), border: Border.all(color: Px.line)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('REASON', style: Px.caps),
                const SizedBox(height: 3),
                Text(req.reason.isEmpty ? '—' : req.reason, style: Px.t(14, weight: FontWeight.w600)),
              ]),
            ),
            const SizedBox(width: 8),
            PChip(req.lengthLabel, tone: Tone.brand),
          ]),
        ),
        if (req.reviewRemark.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.chat_bubble_outline_rounded, size: 16, color: tone.fg),
              const SizedBox(width: 6),
              Expanded(child: Text(req.reviewRemark, style: Px.t(13, weight: FontWeight.w600, color: tone.fg))),
            ]),
          ),
        if (req.reviewedByName.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(children: [
              const Icon(Icons.verified_user_rounded, size: 15, color: Px.muted),
              const SizedBox(width: 6),
              Text('Reviewed by ${req.reviewedByName}', style: Px.small),
            ]),
          ),
      ]),
    );
  }
}
