// ui/add_enquiry_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/colors/colors.dart' as colors;
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/models/model.dart';
import 'package:maleva/menu/menulist.dart';
import '../../../../../../../MasterSearch/Customer.dart';
import '../../../../../../../MasterSearch/JobType.dart';
import '../../../../../../../MasterSearch/Port.dart';
import '../bloc/enquiryadd_bloc.dart';
import '../bloc/enquiryadd_event.dart';
import '../bloc/enquiryadd_state.dart';


class AddEnquiryScreen extends StatelessWidget {
  final Map<String, dynamic>? saleMaster;
  const AddEnquiryScreen({super.key, this.saleMaster});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddEnquiryBloc()
        ..add(InitAddEnquiryEvent(saleMaster)),
      child: _AddEnquiryView(saleMaster: saleMaster),
    );
  }
}

class _AddEnquiryView extends StatefulWidget {
  final Map<String, dynamic>? saleMaster;
  const _AddEnquiryView({this.saleMaster});

  @override
  State<_AddEnquiryView> createState() => _AddEnquiryViewState();
}

class _AddEnquiryViewState extends State<_AddEnquiryView> {
  final _lVesselCtrl = TextEditingController();
  final _oVesselCtrl = TextEditingController();

  @override
  void dispose() {
    _lVesselCtrl.dispose();
    _oVesselCtrl.dispose();
    super.dispose();
  }

  final String _userName = objfun.storagenew.getString('Username') ?? '';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddEnquiryBloc, AddEnquiryState>(
      listenWhen: (prev, curr) =>
      curr.status == AddEnquiryStatus.success ||
          curr.status == AddEnquiryStatus.error,
      listener: (context, state) async {
        if (state.status == AddEnquiryStatus.success) {
          await objfun.ConfirmationOK(state.successMessage!, context);
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => const AddEnquiryScreen()),
            );
          }
        } else if (state.status == AddEnquiryStatus.error) {
          objfun.msgshow(
            state.errorMessage!,
            '',
            Colors.white,
            Colors.red,
            null,
            18.00 - objfun.reducesize,
            objfun.tll,
            objfun.tgc,
            context,
            2,
          );
        }
      },
      builder: (context, state) {
        final bloc = context.read<AddEnquiryBloc>();

        if (_lVesselCtrl.text != state.lVessel) {
          _lVesselCtrl.text = state.lVessel;
        }
        if (_oVesselCtrl.text != state.oVessel) {
          _oVesselCtrl.text = state.oVessel;
        }

        return WillPopScope(
          onWillPop: () async {
            Navigator.of(context).pop();
            return true;
          },
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: colors.kPageBg,
            appBar: AppBar(
              backgroundColor: Palette.blue700, // Top bar background blue
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white), // Drawer/back icons white
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add Enquiry',
                      style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                            color: Colors.white, // Text color white
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ))),
                  Text(_userName,
                      style: GoogleFonts.lato(
                          textStyle: const TextStyle(
                            color: Colors.white70, // Subtitle text slightly transparent white
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ))),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Palette.blue600, // Save button background blue
                      foregroundColor: Colors.white, // Save button text white
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        side: const BorderSide(color: Colors.white, width: 1.5), // White border to pop against blue appbar
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    onPressed: state.customerName.isEmpty
                        ? null
                        : () async {
                      bool confirm = await objfun.ConfirmationMsgYesNo(
                          context, 'Do You Want to Save ?');
                      if (confirm) bloc.add(SaveEnquiryEvent());
                    },
                    icon: const Icon(Icons.check, size: 18, color: Colors.white),
                    label: Text('Save',
                        style: GoogleFonts.lato(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
            drawer: const Menulist(),
            body: state.status == AddEnquiryStatus.loading
                ? const Center(
              child: SpinKitFoldingCube(
                color: Palette.blue700,
                size: 35.0,
              ),
            )
                : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // ── General Details Card ──
                  _buildCard(
                    title: 'General Details',
                    icon: Icons.assignment_ind_rounded,
                    children: [
                      _buildTextField(
                        controller: TextEditingController(text: state.customerName),
                        hint: 'Customer Name',
                        icon: Icons.person_rounded,
                        readOnly: true,
                        hasValue: state.customerName.isNotEmpty,
                        onTapSuffix: () async {
                          if (state.customerName.isEmpty) {
                            await Navigator.push(context, MaterialPageRoute(builder: (_) => const Customer(Searchby: 1, SearchId: 0)));
                            final cust = objfun.SelectCustomerList;
                            bloc.add(CustomerSelectedEvent(cust.AccountName, cust.Id));
                            objfun.SelectCustomerList = CustomerModel.Empty();
                            await OnlineApi.loadCustomerCurrency(context, cust.Id);
                          } else {
                            bloc.add(CustomerClearedEvent());
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: TextEditingController(text: state.jobTypeName),
                        hint: 'Job Type',
                        icon: Icons.work_rounded,
                        readOnly: true,
                        hasValue: state.jobTypeName.isNotEmpty,
                        onTapSuffix: () async {
                          if (state.jobTypeName.isEmpty) {
                            await Navigator.push(context, MaterialPageRoute(builder: (_) => const JobType(Searchby: 1, SearchId: 0)));
                            final jt = objfun.SelectJobTypeList;
                            await OnlineApi.SelectAllJobStatus(context, jt.Id);
                            bloc.add(JobTypeSelectedEvent(jt.Name, jt.Id));
                            objfun.SelectJobTypeList = JobTypeModel.Empty();
                          } else {
                            bloc.add(JobTypeClearedEvent());
                          }
                        },
                      ),
                    ],
                  ),

                  // ── Schedule Card ──
                  _buildCard(
                    title: 'Schedule',
                    icon: Icons.calendar_today_rounded,
                    children: [
                      _DateRowModern(
                        label: 'Notify Date',
                        dateStr: state.notifyDate,
                        onTap: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2050),
                            builder: (context, child) => Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: const ColorScheme.light(primary: Palette.blue600),
                              ),
                              child: child!,
                            ),
                          );
                          if (d != null) bloc.add(NotifyDateChangedEvent(d));
                        },
                      ),
                      const SizedBox(height: 12),
                      _DateTimeRowModern(
                        label: 'Collection Date',
                        dateStr: state.collectionDate,
                        isEnabled: state.checkCollection,
                        checkValue: state.checkCollection,
                        onCheckChanged: (v) => bloc.add(CollectionCheckboxChangedEvent(v!)),
                        onTap: () async {
                          if (!state.checkCollection) return;
                          final d = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100));
                          if (d != null) {
                            final t = await _pickTime(context);
                            bloc.add(CollectionDateChangedEvent(d, t));
                          }
                        },
                      ),
                    ],
                  ),

                  // ── Voyage Details Card ──
                  _buildCard(
                    title: 'Voyage Details',
                    icon: Icons.directions_boat_rounded,
                    children: [
                      _buildTextField(
                        controller: _lVesselCtrl,
                        hint: 'L Vessel',
                        icon: Icons.sailing_rounded,
                        textCapitalization: TextCapitalization.characters,
                        onChanged: (v) => bloc.add(LVesselChangedEvent(v)),
                      ),
                      const SizedBox(height: 12),
                      _DateTimeRowModern(
                        label: 'L ETA',
                        dateStr: state.lETADate,
                        isEnabled: state.checkLETA,
                        checkValue: state.checkLETA,
                        onCheckChanged: (v) => bloc.add(LETACheckboxChangedEvent(v!)),
                        onTap: () async {
                          if (!state.checkLETA) return;
                          final d = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100));
                          if (d != null) {
                            final t = await _pickTime(context);
                            bloc.add(LETADateChangedEvent(d, t));
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: TextEditingController(text: state.lPort),
                        hint: 'L Port',
                        icon: Icons.anchor_rounded,
                        readOnly: true,
                        hasValue: state.lPort.isNotEmpty,
                        onTapSuffix: () async {
                          if (state.lPort.isEmpty) {
                            await Navigator.push(context, MaterialPageRoute(builder: (_) => const Port(Searchby: 1, SearchId: 0)));
                            bloc.add(LPortSelectedEvent(objfun.SelectedPortName));
                            objfun.SelectedPortName = '';
                          } else {
                            bloc.add(LPortClearedEvent());
                          }
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Divider(color: Palette.grey200, thickness: 1.5),
                      ),
                      _buildTextField(
                        controller: _oVesselCtrl,
                        hint: 'O Vessel',
                        icon: Icons.directions_boat_outlined,
                        textCapitalization: TextCapitalization.characters,
                        onChanged: (v) => bloc.add(OVesselChangedEvent(v)),
                      ),
                      const SizedBox(height: 12),
                      _DateTimeRowModern(
                        label: 'O ETA',
                        dateStr: state.oETADate,
                        isEnabled: state.checkOETA,
                        checkValue: state.checkOETA,
                        onCheckChanged: (v) => bloc.add(OETACheckboxChangedEvent(v!)),
                        onTap: () async {
                          if (!state.checkOETA) return;
                          final d = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100));
                          if (d != null) {
                            final t = await _pickTime(context);
                            bloc.add(OETADateChangedEvent(d, t));
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: TextEditingController(text: state.oPort),
                        hint: 'O Port',
                        icon: Icons.anchor_outlined,
                        readOnly: true,
                        hasValue: state.oPort.isNotEmpty,
                        onTapSuffix: () async {
                          if (state.oPort.isEmpty) {
                            await Navigator.push(context, MaterialPageRoute(builder: (_) => const Port(Searchby: 1, SearchId: 0)));
                            bloc.add(OPortSelectedEvent(objfun.SelectedPortName));
                            objfun.SelectedPortName = '';
                          } else {
                            bloc.add(OPortClearedEvent());
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<TimeOfDay> _pickTime(BuildContext context) async {
    final t = await showTimePicker(
      context: context,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Palette.blue600),
          ),
          child: child!,
        ),
      ),
      initialTime: TimeOfDay.now(),
    );
    return t ?? TimeOfDay.now();
  }

  // ── UI Helper Methods ──

  Widget _buildCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Palette.grey200, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Palette.blue600),
              const SizedBox(width: 8),
              Text(title, style: GoogleFonts.lato(fontSize: 15, fontWeight: FontWeight.w800, color: Palette.textDark)),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool readOnly = false,
    bool hasValue = false,
    VoidCallback? onTapSuffix,
    ValueChanged<String>? onChanged,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onChanged: onChanged,
      textCapitalization: textCapitalization,
      style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w700, color: Palette.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w600, color: Palette.grey500),
        prefixIcon: Icon(icon, color: Palette.blue400, size: 20),
        suffixIcon: onTapSuffix != null
            ? InkWell(
          onTap: onTapSuffix,
          borderRadius: BorderRadius.circular(20),
          child: Icon(
            hasValue ? Icons.close_rounded : Icons.search_rounded,
            color: hasValue ? Palette.redError : Palette.blue600,
            size: 22.0,
          ),
        )
            : null,
        filled: true,
        fillColor: Palette.grey50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Palette.blue400, width: 1.5)),
      ),
    );
  }
}

// ── Date Row (Modern) ──
class _DateRowModern extends StatelessWidget {
  final String label;
  final String dateStr;
  final VoidCallback onTap;

  const _DateRowModern({
    required this.label,
    required this.dateStr,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(label, style: GoogleFonts.lato(fontSize: 13, fontWeight: FontWeight.w700, color: Palette.grey600)),
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Palette.grey50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month_rounded, color: Palette.blue400, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    DateFormat('dd MMM yyyy').format(DateTime.parse(dateStr)),
                    style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w700, color: Palette.textDark),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── DateTime Row (Modern + Checkbox) ──
class _DateTimeRowModern extends StatelessWidget {
  final String label;
  final String dateStr;
  final bool isEnabled;
  final bool checkValue;
  final ValueChanged<bool?> onCheckChanged;
  final VoidCallback onTap;

  const _DateTimeRowModern({
    required this.label,
    required this.dateStr,
    required this.isEnabled,
    required this.checkValue,
    required this.onCheckChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(label, style: GoogleFonts.lato(fontSize: 13, fontWeight: FontWeight.w700, color: Palette.grey600)),
        ),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isEnabled ? Palette.grey50 : Palette.grey200.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.date_range_rounded, color: isEnabled ? Palette.blue400 : Palette.grey400, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          DateFormat('dd MMM yyyy • HH:mm').format(DateTime.parse(dateStr)),
                          style: GoogleFonts.lato(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isEnabled ? Palette.textDark : Palette.grey500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: checkValue ? Palette.blue600.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Checkbox(
                value: checkValue,
                activeColor: Palette.blue600,
                side: const BorderSide(color: Palette.grey400, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                onChanged: onCheckChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}