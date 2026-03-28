// ui/add_enquiry_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
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
  // TextEditingController — BLoC state sync பண்ண
  final _lVesselCtrl = TextEditingController();
  final _oVesselCtrl = TextEditingController();

  @override
  void dispose() {
    _lVesselCtrl.dispose();
    _oVesselCtrl.dispose();
    super.dispose();
  }

  String _userName = objfun.storagenew.getString('Username') ?? '';

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

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

        // Vessel controllers sync
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
            backgroundColor: Colors.white,
            appBar: AppBar(
              automaticallyImplyLeading: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              title: SizedBox(
                height: height * 0.05,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text('Enquiry Add',
                          style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                color: colour.topAppBarColor,
                                fontWeight: FontWeight.bold,
                                fontSize: objfun.FontMedium,
                              ))),
                    ),
                    Expanded(
                      child: Text(_userName,
                          style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                color: colour.commonColorLight,
                                fontWeight: FontWeight.bold,
                                fontSize: objfun.FontLow - 2,
                              ))),
                    ),
                  ],
                ),
              ),
              iconTheme:
              const IconThemeData(color: colour.topAppBarColor),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 7.0, bottom: 7.0, left: 7.0),
                  child: SizedBox(
                    width: 70,
                    height: 25,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colour.commonColorLight,
                        side: const BorderSide(
                            color: colour.commonColor, width: 1),
                        elevation: 20.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: const EdgeInsets.all(4.0),
                      ),
                      onPressed: state.customerName.isEmpty
                          ? null
                          : () async {
                        bool confirm =
                        await objfun.ConfirmationMsgYesNo(
                            context,
                            'Do You Want to Save ?');
                        if (confirm) bloc.add(SaveEnquiryEvent());
                      },
                      child: Text('Save',
                          style: GoogleFonts.lato(
                              fontSize: objfun.FontMedium,
                              fontWeight: FontWeight.bold,
                              color: colour.commonColor)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
            drawer: const Menulist(),
            body: state.status == AddEnquiryStatus.loading
                ? const Center(
              child: SpinKitFoldingCube(
                color: colour.spinKitColor,
                size: 35.0,
              ),
            )
                : Padding(
              padding: const EdgeInsets.only(
                  top: 15.0, left: 15.0, right: 15.0),
              child: ListView(
                children: [

                  // ── Customer ──
                  _fieldBox(height,
                    child: TextField(
                      controller: TextEditingController(
                          text: state.customerName),
                      readOnly: true,
                      style: _fieldStyle(),
                      decoration: _inputDeco(
                        hint: 'Customer Name',
                        hasValue: state.customerName.isNotEmpty,
                        onTap: () async {
                          if (state.customerName.isEmpty) {
                            await Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (_) => const Customer(
                                      Searchby: 1, SearchId: 0)),
                            );
                            final cust = objfun.SelectCustomerList;
                            bloc.add(CustomerSelectedEvent(
                                cust.AccountName, cust.Id));
                            objfun.SelectCustomerList =
                                CustomerModel.Empty();
                            await OnlineApi.loadCustomerCurrency(
                                context, cust.Id);
                          } else {
                            bloc.add(CustomerClearedEvent());
                          }
                        },
                      ),
                    ),
                  ),

                  // ── Job Type ──
                  _fieldBox(height,
                    child: TextField(
                      controller: TextEditingController(
                          text: state.jobTypeName),
                      readOnly: true,
                      style: _fieldStyle(),
                      decoration: _inputDeco(
                        hint: 'Job Type',
                        hasValue: state.jobTypeName.isNotEmpty,
                        onTap: () async {
                          if (state.jobTypeName.isEmpty) {
                            await Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (_) => const JobType(
                                      Searchby: 1, SearchId: 0)),
                            );
                            final jt = objfun.SelectJobTypeList;
                            await OnlineApi.SelectAllJobStatus(
                                context, jt.Id);
                            bloc.add(JobTypeSelectedEvent(
                                jt.Name, jt.Id));
                            objfun.SelectJobTypeList =
                                JobTypeModel.Empty();
                          } else {
                            bloc.add(JobTypeClearedEvent());
                          }
                        },
                      ),
                    ),
                  ),

                  // ── Notify Date ──
                  _DateRow(
                    label: 'Notify Date',
                    dateStr: state.notifyDate,
                    width: width,
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2050),
                      );
                      if (d != null) {
                        bloc.add(NotifyDateChangedEvent(d));
                      }
                    },
                  ),
                  const SizedBox(height: 5),

                  // ── L Vessel ──
                  _fieldBox(height,
                    child: TextField(
                      controller: _lVesselCtrl,
                      textCapitalization:
                      TextCapitalization.characters,
                      textInputAction: TextInputAction.done,
                      style: _fieldStyle(),
                      onChanged: (v) =>
                          bloc.add(LVesselChangedEvent(v)),
                      decoration: _inputDecoPlain('L Vessel'),
                    ),
                  ),

                  // ── O Vessel ──
                  _fieldBox(height,
                    child: TextField(
                      controller: _oVesselCtrl,
                      textCapitalization:
                      TextCapitalization.characters,
                      textInputAction: TextInputAction.done,
                      style: _fieldStyle(),
                      onChanged: (v) =>
                          bloc.add(OVesselChangedEvent(v)),
                      decoration: _inputDecoPlain('O Vessel'),
                    ),
                  ),

                  // ── Collection Date ──
                  _DateTimeRow(
                    label: 'Collection Date',
                    dateStr: state.collectionDate,
                    isEnabled: state.checkCollection,
                    checkValue: state.checkCollection,
                    onCheckChanged: (v) => bloc.add(
                        CollectionCheckboxChangedEvent(v!)),
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
                  const SizedBox(height: 5),

                  // ── L ETA ──
                  _DateTimeRow(
                    label: 'L ETA',
                    dateStr: state.lETADate,
                    isEnabled: state.checkLETA,
                    checkValue: state.checkLETA,
                    onCheckChanged: (v) =>
                        bloc.add(LETACheckboxChangedEvent(v!)),
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
                  const SizedBox(height: 5),

                  // ── O ETA ──
                  _DateTimeRow(
                    label: 'O ETA',
                    dateStr: state.oETADate,
                    isEnabled: state.checkOETA,
                    checkValue: state.checkOETA,
                    onCheckChanged: (v) =>
                        bloc.add(OETACheckboxChangedEvent(v!)),
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
                  const SizedBox(height: 5),

                  // ── L Port ──
                  _fieldBox(height,
                    child: TextField(
                      controller: TextEditingController(
                          text: state.lPort),
                      readOnly: true,
                      style: _fieldStyle(),
                      decoration: _inputDeco(
                        hint: 'L Port',
                        hasValue: state.lPort.isNotEmpty,
                        onTap: () async {
                          if (state.lPort.isEmpty) {
                            await Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (_) => const Port(
                                      Searchby: 1, SearchId: 0)),
                            );
                            bloc.add(LPortSelectedEvent(
                                objfun.SelectedPortName));
                            objfun.SelectedPortName = '';
                          } else {
                            bloc.add(LPortClearedEvent());
                          }
                        },
                      ),
                    ),
                  ),

                  // ── O Port ──
                  _fieldBox(height,
                    child: TextField(
                      controller: TextEditingController(
                          text: state.oPort),
                      readOnly: true,
                      style: _fieldStyle(),
                      decoration: _inputDeco(
                        hint: 'O Port',
                        hasValue: state.oPort.isNotEmpty,
                        onTap: () async {
                          if (state.oPort.isEmpty) {
                            await Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (_) => const Port(
                                      Searchby: 1, SearchId: 0)),
                            );
                            bloc.add(OPortSelectedEvent(
                                objfun.SelectedPortName));
                            objfun.SelectedPortName = '';
                          } else {
                            bloc.add(OPortClearedEvent());
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
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
        data: MediaQuery.of(ctx)
            .copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
      initialTime: TimeOfDay.now(),
    );
    return t ?? TimeOfDay.now();
  }

  Widget _fieldBox(double height, {required Widget child}) {
    return SizedBox(
      height: height * 0.06,
      child: Row(children: [Expanded(child: child)]),
    );
  }

  TextStyle _fieldStyle() => GoogleFonts.lato(
    textStyle: TextStyle(
      color: colour.commonColor,
      fontWeight: FontWeight.bold,
      fontSize: objfun.FontLow,
      letterSpacing: 0.3,
    ),
  );

  InputDecoration _inputDeco({
    required String hint,
    required bool hasValue,
    required VoidCallback onTap,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.lato(
          textStyle: TextStyle(
              fontSize: objfun.FontMedium,
              fontWeight: FontWeight.bold,
              color: colour.commonColorLight)),
      suffixIcon: InkWell(
        onTap: onTap,
        child: Icon(
          hasValue ? Icons.close : Icons.search_rounded,
          color: colour.commonColorred,
          size: 30.0,
        ),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        borderSide: BorderSide(color: colour.commonColor),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        borderSide: BorderSide(color: colour.commonColorred),
      ),
      contentPadding:
      const EdgeInsets.only(left: 10, right: 20, top: 10.0),
    );
  }

  InputDecoration _inputDecoPlain(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.lato(
          textStyle: TextStyle(
              fontSize: objfun.FontMedium,
              fontWeight: FontWeight.bold,
              color: colour.commonColorLight)),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        borderSide: BorderSide(color: colour.commonColor),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        borderSide: BorderSide(color: colour.commonColorred),
      ),
      contentPadding:
      const EdgeInsets.only(left: 10, right: 20, top: 10.0),
    );
  }
}

// ── Date Row (Notify Date — date only) ──
class _DateRow extends StatelessWidget {
  final String label;
  final String dateStr;
  final double width;
  final VoidCallback onTap;

  const _DateRow({
    required this.label,
    required this.dateStr,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                  textStyle: TextStyle(
                      fontSize: objfun.FontMedium,
                      fontWeight: FontWeight.bold,
                      color: colour.commonColor))),
        ),
        Expanded(
          flex: 4,
          child: Container(
            height: 50,
            padding: const EdgeInsets.only(left: 10.0, right: 5.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: colour.commonColorLight,
                border: Border.all()),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    width <= 370
                        ? DateFormat('dd-MM-yy')
                        .format(DateTime.parse(dateStr))
                        : DateFormat('dd-MM-yyyy')
                        .format(DateTime.parse(dateStr)),
                    style: GoogleFonts.lato(
                        textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: objfun.FontLow,
                            color: colour.commonColor)),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: onTap,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: objfun.calendar),
                      ),
                    ),
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

// ── DateTime Row (Collection/ETA — date + time + checkbox) ──
class _DateTimeRow extends StatelessWidget {
  final String label;
  final String dateStr;
  final bool isEnabled;
  final bool checkValue;
  final ValueChanged<bool?> onCheckChanged;
  final VoidCallback onTap;

  const _DateTimeRow({
    required this.label,
    required this.dateStr,
    required this.isEnabled,
    required this.checkValue,
    required this.onCheckChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                  textStyle: TextStyle(
                      fontSize: objfun.FontMedium,
                      fontWeight: FontWeight.bold,
                      color: colour.commonColor))),
        ),
        Expanded(
          flex: 4,
          child: Container(
            height: 50,
            padding: const EdgeInsets.only(left: 10.0, right: 5.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: colour.commonColorLight,
                border: Border.all()),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    DateFormat('dd-MM-yyyy HH:mm:ss')
                        .format(DateTime.parse(dateStr)),
                    style: GoogleFonts.lato(
                        textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: objfun.FontLow,
                            color: isEnabled
                                ? colour.commonColor
                                : colour.commonColorDisabled)),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: onTap,
                    child: Container(
                      width: 25,
                      height: 35,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: objfun.calendar),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Transform.scale(
            scale: 1.3,
            child: Checkbox(
              value: checkValue,
              side:
              const BorderSide(color: colour.commonColor),
              activeColor: colour.commonColorred,
              onChanged: onCheckChanged,
            ),
          ),
        ),
      ],
    );
  }
}