import 'package:flutter/material.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/widgets/app_form_fields.dart';
import 'package:maleva/core/widgets/searchable_picker_field.dart';

import '../../domain/entities/ir_draft.dart';
import '../../domain/entities/ir_lookup.dart';

/// A truck, driver or employee: a searchable dropdown of the master list, with
/// a toggle to type a name instead for someone who is not in it.
class IrPartyField extends StatelessWidget {
  const IrPartyField({
    super.key,
    required this.label,
    required this.party,
    required this.options,
    required this.onChanged,
    required this.listHint,
    required this.manualHint,
    required this.manualToggleLabel,
    this.errorText,
    this.enabled = true,
  });

  final String label;
  final IrParty party;
  final List<LookupOption> options;
  final ValueChanged<IrParty> onChanged;
  final String listHint;
  final String manualHint;

  /// e.g. "Hired lorry?" - switches to typing.
  final String manualToggleLabel;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    return AppFormField(
      label: label,
      errorText: errorText,
      trailing: enabled ? _modeToggle() : null,
      child: party.manual
          ? AppTextInput(
              value: party.typedName,
              hint: manualHint,
              enabled: enabled,
              hasError: hasError,
              maxLength: IrDraft.maxTextLength,
              textCapitalization: TextCapitalization.words,
              onChanged: (text) => onChanged(party.typed(text)),
            )
          : SearchablePickerField<LookupOption>(
              items: options,
              value: party.selected,
              itemLabel: (option) => option.name,
              hint: listHint,
              sheetTitle: label,
              enabled: enabled,
              hasError: hasError,
              onChanged: (option) => onChanged(party.picked(option)),
            ),
    );
  }

  Widget _modeToggle() {
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        minimumSize: const Size(0, 24),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () => onChanged(party.withManual(!party.manual)),
      child: Text(
        party.manual ? 'Pick from list' : manualToggleLabel,
        style: AppTypography.bodySmall(
          color: AppTokens.brandPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
