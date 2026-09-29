import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/theme/tokens.dart';

/// The one input look every form field shares, so text boxes, pickers and date
/// fields line up and change together.
InputDecoration appInputDecoration({
  String? hint,
  bool enabled = true,
  bool hasError = false,
  Widget? suffixIcon,
  Widget? prefixIcon,
}) {
  OutlineInputBorder outline(Color color, [double width = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: width),
      );

  final idle = hasError ? AppTokens.statusDanger : Palette.cardBorder;
  return InputDecoration(
    enabled: enabled,
    hintText: hint,
    hintStyle: AppTypography.bodyMedium(color: AppTokens.textDim),
    isDense: true,
    filled: true,
    fillColor: enabled ? AppTokens.surfaceCard : AppTokens.surfacePage,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
    counterText: '',
    suffixIcon: suffixIcon,
    prefixIcon: prefixIcon,
    border: outline(idle),
    enabledBorder: outline(idle),
    disabledBorder: outline(AppTokens.surfaceBorder),
    focusedBorder: outline(hasError ? AppTokens.statusDanger : AppTokens.brandPrimary, 1.4),
  );
}

/// A label, the field under it, and the field's error line.
class AppFormField extends StatelessWidget {
  const AppFormField({
    super.key,
    required this.label,
    this.required = false,
    this.errorText,
    this.trailing,
    required this.child,
  });

  final String label;
  final bool required;
  final String? errorText;

  /// Shown at the right of the label, e.g. a "type instead" toggle.
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: label,
                  children: [
                    if (required)
                      TextSpan(
                        text: ' *',
                        style: AppTypography.bodySmall(color: AppTokens.statusDanger),
                      ),
                  ],
                ),
                style: AppTypography.bodySmall(
                  color: AppTokens.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: 6),
        child,
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 2),
            child: Text(
              errorText!,
              style: AppTypography.bodySmall(color: AppTokens.statusDanger),
            ),
          ),
      ],
    );
  }
}

/// A text field driven by a value held elsewhere (a bloc state).
///
/// Owns its controller and only rewrites the text when [value] changes from
/// outside - a loaded record, a reset - so the user's cursor never jumps while
/// typing. (Keying a TextFormField on its value recreates it on every
/// keystroke and throws the cursor to the end.)
class AppTextInput extends StatefulWidget {
  const AppTextInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.hint,
    this.enabled = true,
    this.hasError = false,
    this.minLines = 1,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String? hint;
  final bool enabled;
  final bool hasError;
  final int minLines;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;

  @override
  State<AppTextInput> createState() => _AppTextInputState();
}

class _AppTextInputState extends State<AppTextInput> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(covariant AppTextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      minLines: widget.minLines,
      maxLines: widget.maxLines < widget.minLines ? widget.minLines : widget.maxLines,
      maxLength: widget.maxLength,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      textCapitalization: widget.textCapitalization,
      textInputAction: widget.textInputAction,
      style: AppTypography.bodyLarge(color: AppTokens.textPrimary),
      decoration: appInputDecoration(
        hint: widget.hint,
        enabled: widget.enabled,
        hasError: widget.hasError,
      ),
    );
  }
}
