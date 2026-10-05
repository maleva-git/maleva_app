import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A text field whose value lives in the bloc: it shows [value] and reports each change.
/// A new [value] from outside (a load, a revise, a clear) replaces the text.
class RtiTextField extends StatefulWidget {
  const RtiTextField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.readOnly = false,
    this.errorText,
    this.textInputAction,
    this.onSubmitted,
    this.dense = false,
    this.focusNode,
    this.textAlign = TextAlign.start,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final String? hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final bool readOnly;
  final String? errorText;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool dense;
  final FocusNode? focusNode;
  final TextAlign textAlign;

  /// Digits and one dot (the web's Salary / PPIC / DPIC cell rule).
  static final decimal = [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))];
  static final digits = [FilteringTextInputFormatter.digitsOnly];

  @override
  State<RtiTextField> createState() => _RtiTextFieldState();
}

class _RtiTextFieldState extends State<RtiTextField> {
  late final TextEditingController _c = TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(covariant RtiTextField old) {
    super.didUpdateWidget(old);
    if (widget.value != _c.text) {
      _c.value = TextEditingValue(text: widget.value, selection: TextSelection.collapsed(offset: widget.value.length));
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: _c,
        focusNode: widget.focusNode,
        readOnly: widget.readOnly,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        maxLength: widget.maxLength,
        textAlign: widget.textAlign,
        textInputAction: widget.textInputAction,
        onSubmitted: widget.onSubmitted,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          labelText: widget.label.isEmpty ? null : widget.label,
          hintText: widget.hint,
          errorText: widget.errorText,
          isDense: widget.dense,
          counterText: widget.maxLength == null ? null : '',
        ),
      );
}
