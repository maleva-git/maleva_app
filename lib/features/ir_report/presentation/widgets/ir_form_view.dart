import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/app_form_fields.dart';
import 'package:maleva/core/widgets/searchable_picker_field.dart';

import '../../domain/entities/ir_draft.dart';
import '../../domain/entities/ir_lookup.dart';
import '../form/bloc/ir_form_bloc.dart';
import 'ir_date_time_field.dart';
import 'ir_party_field.dart';
import 'ir_section_card.dart';

/// The fields of the IR form. Holds nothing itself: every value comes from
/// [state] and every change goes back to the bloc as an event.
class IrFormView extends StatelessWidget {
  const IrFormView({super.key, required this.state, this.readOnly = false});

  final IrFormState state;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<IrFormBloc>();
    final draft = state.draft;
    final lookups = state.lookups;
    final enabled = !readOnly && state.submitStatus != IrSubmitStatus.submitting;
    bool hasError(IrField field) => state.errorFor(field) != null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        IrSectionCard(
          title: 'Incident',
          icon: Icons.event_note_rounded,
          children: [
            AppFormField(
              label: 'Date and time',
              required: true,
              errorText: state.errorFor(IrField.irDate),
              child: IrDateTimeField(
                value: draft.irDate,
                enabled: enabled,
                hasError: hasError(IrField.irDate),
                onChanged: (value) => bloc.add(IrFormDateChanged(value)),
              ),
            ),
            AppFormField(
              label: 'Status',
              required: true,
              errorText: state.errorFor(IrField.status),
              child: SearchablePickerField<IrStatus>(
                items: lookups.statuses,
                value: draft.status,
                itemLabel: (status) => status.name,
                hint: 'Select status',
                clearable: false,
                enabled: enabled,
                hasError: hasError(IrField.status),
                onChanged: (status) => bloc.add(IrFormStatusChanged(status)),
              ),
            ),
            AppFormField(
              label: 'Department',
              required: true,
              errorText: state.errorFor(IrField.department),
              child: SearchablePickerField<LookupOption>(
                items: lookups.departments,
                value: draft.department,
                itemLabel: (department) => department.name,
                hint: 'Select department',
                enabled: enabled,
                hasError: hasError(IrField.department),
                onChanged: (department) => bloc.add(IrFormDepartmentChanged(department)),
              ),
            ),
          ],
        ),
        IrSectionCard(
          title: 'What happened',
          icon: Icons.description_outlined,
          children: [
            AppFormField(
              label: 'Description',
              required: true,
              errorText: state.errorFor(IrField.description),
              child: AppTextInput(
                value: draft.description,
                hint: 'What happened?',
                minLines: 3,
                maxLines: 6,
                enabled: enabled,
                hasError: hasError(IrField.description),
                textCapitalization: TextCapitalization.sentences,
                onChanged: (text) => bloc.add(IrFormTextChanged(IrField.description, text)),
              ),
            ),
            AppFormField(
              label: 'Reason',
              errorText: state.errorFor(IrField.reason),
              child: AppTextInput(
                value: draft.reason,
                hint: 'Why did it happen? (optional)',
                minLines: 2,
                maxLines: 4,
                maxLength: IrDraft.maxReasonLength,
                enabled: enabled,
                hasError: hasError(IrField.reason),
                textCapitalization: TextCapitalization.sentences,
                onChanged: (text) => bloc.add(IrFormTextChanged(IrField.reason, text)),
              ),
            ),
          ],
        ),
        IrSectionCard(
          title: 'Involved',
          icon: Icons.groups_outlined,
          children: [
            AppFormField(
              label: 'Vessel',
              errorText: state.errorFor(IrField.vesselName),
              child: AppTextInput(
                value: draft.vesselName,
                hint: 'Vessel name (optional)',
                maxLength: IrDraft.maxTextLength,
                enabled: enabled,
                hasError: hasError(IrField.vesselName),
                textCapitalization: TextCapitalization.characters,
                onChanged: (text) => bloc.add(IrFormTextChanged(IrField.vesselName, text)),
              ),
            ),
            IrPartyField(
              label: 'Truck',
              party: draft.truck,
              options: lookups.trucks,
              listHint: 'Select truck',
              manualHint: 'Type the lorry plate',
              manualToggleLabel: 'Hired lorry?',
              enabled: enabled,
              errorText: state.errorFor(IrField.truck),
              onChanged: (party) => bloc.add(IrFormPartyChanged(IrField.truck, party)),
            ),
            IrPartyField(
              label: 'Driver',
              party: draft.driver,
              options: lookups.drivers,
              listHint: 'Select driver',
              manualHint: 'Type the driver name',
              manualToggleLabel: 'Not our driver?',
              enabled: enabled,
              errorText: state.errorFor(IrField.driver),
              onChanged: (party) => bloc.add(IrFormPartyChanged(IrField.driver, party)),
            ),
            IrPartyField(
              label: 'Employee',
              party: draft.employee,
              options: lookups.employees,
              listHint: 'Select employee',
              manualHint: 'Type the employee name',
              manualToggleLabel: 'Not in list?',
              enabled: enabled,
              errorText: state.errorFor(IrField.employee),
              onChanged: (party) => bloc.add(IrFormPartyChanged(IrField.employee, party)),
            ),
          ],
        ),
        IrSectionCard(
          title: 'Cost',
          icon: Icons.payments_outlined,
          children: [
            AppFormField(
              label: 'Actual amount (RM, whole ringgit)',
              errorText: state.errorFor(IrField.amount),
              child: AppTextInput(
                value: draft.amountText,
                hint: '0',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  // IRMaster.ActualAmount is an int.
                  LengthLimitingTextInputFormatter(9),
                ],
                enabled: enabled,
                hasError: hasError(IrField.amount),
                onChanged: (text) => bloc.add(IrFormTextChanged(IrField.amount, text)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
