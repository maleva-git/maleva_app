import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

import '../bloc/employeemaster_bloc.dart';
import '../bloc/employeemaster_event.dart';
import '../bloc/employeemaster_state.dart';
import 'package:maleva/core/colors/colors.dart' as colour;





// ── Dropdown Data ─────────────────────────────────────────────────────────────
const List<String> kCurrencyList = ["INR", "RM", "USD", "EUR"];

const List<String> kRulesTypeList = [
  "SALES", "HR", "ADMIN", "OPERATION", "BOARDING",
  "FORWARDING", "AIR FRIEGHT", "ACCOUNTS", "TRANSPORTATION",
  "MAINTENANCE", "OPERATIONADMIN", "HRADMIN", "SECONDADMIN",
];

const List<String> kEmployeeTypeList = [
  "ADMIN", "ACCOUNTS", "HR", "BILLING", "OPERATION",
  "SALES", "MAINTENANCE", "TRANSPORTATION", "FORWARDING",
  "RECEIVABLE", "PAYABLE", "BOARDING", "OPERATIONADMIN",
  "CustomerServiceAdmin", "HRADMIN",
];

// ── Entry Point ───────────────────────────────────────────────────────────────
class EmployeeAddPage extends StatelessWidget {
  final EmployeeDetailsModel? existingEmployee;
  const EmployeeAddPage({super.key, this.existingEmployee});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => EmployeeMasterBloc.form(ctx, existing: existingEmployee),
      child: const _EmployeeAddBody(),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────
class _EmployeeAddBody extends StatelessWidget {
  const _EmployeeAddBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EmployeeMasterBloc, EmployeeState>(
      listener: (context, state) async {
        if (state is EmployeeSaveSuccess) {
          await objfun.ConfirmationOK(state.message, context);
          Navigator.pop(context, true);
        }
        if (state is EmployeeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is! EmployeeFormState) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: colour.kPrimary)),
          );
        }

        final s = state;
        final bloc = context.read<EmployeeMasterBloc>();
        final isEdit = s.employee.Id != 0;

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            backgroundColor: colour.kPrimary,
            foregroundColor: colour.kWhite,
            elevation: 0,
            title: Text(isEdit ? "Edit Employee" : "Add Employee",
                style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: colour.kWhite)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Stepper(
              type: StepperType.vertical,
              currentStep: s.currentStep,
              onStepContinue: () async {
                if (s.currentStep < 3) {
                  bloc.add(const NextStepEvent());
                } else {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      title: const Text("Confirm Save",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      content: const Text("Do you want to save this employee's details?"),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancel")),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text("Yes, Save"),
                          style: ElevatedButton.styleFrom(backgroundColor: colour.kPrimary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          onPressed: () => Navigator.pop(context, true),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) bloc.add(const SaveEmployeeMasterEvent());
                }
              },
              onStepCancel: () {
                if (s.currentStep > 0) bloc.add(const PreviousStepEvent());
                else Navigator.pop(context);
              },
              controlsBuilder: (context, details) {
                return Row(children: [
                  ElevatedButton(
                    onPressed: s.isSaving ? null : details.onStepContinue,
                    style: ElevatedButton.styleFrom(backgroundColor: colour.kPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: s.isSaving
                        ? const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(color: colour.kWhite, strokeWidth: 2))
                        : Text(s.currentStep == 3 ? "Save" : "Next",
                        style: const TextStyle(color: colour.kWhite)),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: details.onStepCancel,
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        side: const BorderSide(color: colour.kPrimary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text("Back", style: TextStyle(color: colour.kPrimaryDark)),
                  ),
                ]);
              },
              steps: [
                // ── Step 1: Basic Info ──
                Step(
                  title: Text("Basic Info", style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold, color: colour.kPrimaryDark)),
                  content: _section([
                    _field("Employee Name", s.employee.EmployeeName,
                            (v) => bloc.add(UpdateFieldEvent('EmployeeName', v))),
                    _dropdown("Select Currency", s.selectedCurrency, kCurrencyList,
                            (v) => bloc.add(SelectCurrencyEvent(v))),
                    _dropdown("Employee Type", s.selectedEmployeeType, kEmployeeTypeList,
                            (v) => bloc.add(SelectEmployeeTypeEvent(v))),
                    _field("Email", s.employee.Email,
                            (v) => bloc.add(UpdateFieldEvent('Email', v))),
                    _field("Mobile No", s.employee.MobileNo,
                            (v) => bloc.add(UpdateFieldEvent('MobileNo', v)),
                        keyboard: TextInputType.phone),
                    _field("Emergency No", s.employee.EmergencyNo,
                            (v) => bloc.add(UpdateFieldEvent('EmergencyNo', v)),
                        keyboard: TextInputType.phone),
                  ]),
                ),

                // ── Step 2: Address Info ──
                Step(
                  title: Text("Address Info", style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold, color: colour.kPrimaryDark)),
                  content: _section([
                    _field("Address 1", s.employee.Address1,
                            (v) => bloc.add(UpdateFieldEvent('Address1', v))),
                    _field("Address 2", s.employee.Address2,
                            (v) => bloc.add(UpdateFieldEvent('Address2', v))),
                    _field("City", s.employee.City,
                            (v) => bloc.add(UpdateFieldEvent('City', v))),
                    _field("State", s.employee.State,
                            (v) => bloc.add(UpdateFieldEvent('State', v))),
                    _field("Zipcode", s.employee.Zipcode,
                            (v) => bloc.add(UpdateFieldEvent('Zipcode', v)),
                        keyboard: TextInputType.number),
                    _field("Country", s.employee.Country,
                            (v) => bloc.add(UpdateFieldEvent('Country', v))),
                    _field("GST No", s.employee.GSTNO,
                            (v) => bloc.add(UpdateFieldEvent('GSTNO', v))),
                  ]),
                ),

                // ── Step 3: Job Info ──
                Step(
                  title: Text("Job Info", style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold, color: colour.kPrimaryDark)),
                  content: _section([
                    _field("User Name", s.employee.UserName,
                            (v) => bloc.add(UpdateFieldEvent('UserName', v))),
                    _datePicker(context, "Joining Date", s.employee.JoiningDate,
                            (d) => bloc.add(SelectJoiningDateEvent(d))),
                    _datePicker(context, "Leaving Date", s.employee.LeavingDate,
                            (d) => bloc.add(SelectLeavingDateEvent(d))),
                    _field("Password", s.employee.Password,
                            (v) => bloc.add(UpdateFieldEvent('Password', v)),
                        obscure: true),
                    _dropdown("Rules Type", s.selectedRulesType, kRulesTypeList,
                            (v) => bloc.add(SelectRulesTypeEvent(v))),
                    _field("Latitude", s.employee.Latitude,
                            (v) => bloc.add(UpdateFieldEvent('Latitude', v)),
                        keyboard: TextInputType.number),
                    _field("Longitude", s.employee.longitude,
                            (v) => bloc.add(UpdateFieldEvent('longitude', v)),
                        keyboard: TextInputType.number),
                  ]),
                ),

                // ── Step 4: Bank Info ──
                Step(
                  title: Text("Bank Details", style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold, color: colour.kPrimaryDark)),
                  content: _section([
                    _field("Bank Name", s.employee.BankName,
                            (v) => bloc.add(UpdateFieldEvent('BankName', v))),
                    _field("Account No", s.employee.AccountNo,
                            (v) => bloc.add(UpdateFieldEvent('AccountNo', v)),
                        keyboard: TextInputType.number),
                    _field("Account Code", s.employee.AccountCode,
                            (v) => bloc.add(UpdateFieldEvent('AccountCode', v))),
                  ]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Reusable Widget Builders ──────────────────────────────────────────────────

Widget _section(List<Widget> children) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: colour.kWhite,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: colour.kAccent),
      boxShadow: [BoxShadow(color: colour.kPrimary.withOpacity(0.05),
          blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
  );
}

Widget _field(
    String label,
    String initial,
    ValueChanged<String> onChanged, {
      TextInputType keyboard = TextInputType.text,
      bool obscure = false,
    }) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      initialValue: initial,
      obscureText: obscure,
      keyboardType: keyboard,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: colour.kPrimaryDark),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: colour.kPrimary, width: 1.5)),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    ),
  );
}

Widget _dropdown(
    String label,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
    ) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: DropdownButtonFormField<String>(
      value: items.contains(value) ? value : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: colour.kPrimaryDark),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: colour.kPrimary, width: 1.5)),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      onChanged: onChanged,
    ),
  );
}

Widget _datePicker(
    BuildContext context,
    String label,
    String value,
    ValueChanged<String> onDateSelected,
    ) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: GestureDetector(
      onTap: () async {
        final initial = value.isNotEmpty
            ? (DateTime.tryParse(value) ?? DateTime.now())
            : DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
                colorScheme: const ColorScheme.light(primary: colour.kPrimary)),
            child: child!,
          ),
        );
        if (picked != null) {
          onDateSelected(
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}",
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Row(children: [
          const Icon(Icons.calendar_today_rounded, color: colour.kPrimary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: GoogleFonts.lato(fontSize: 11, color: Colors.grey[600])),
              const SizedBox(height: 2),
              Text(
                value.isNotEmpty ? value : 'Select Date',
                style: GoogleFonts.lato(fontSize: 14,
                    color: value.isNotEmpty ? colour.kPrimaryDark : Colors.grey,
                    fontWeight: FontWeight.w600),
              ),
            ]),
          ),
        ]),
      ),
    ),
  );
}