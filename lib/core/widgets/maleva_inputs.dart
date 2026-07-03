import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/colors/colors.dart' as colour;

class MalevaTextField extends StatelessWidget {
  final String hint;
  final String uniqueId;
  final String value;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final int minLines;
  final int? maxLines;
  final TextInputType keyboardType;

  const MalevaTextField({
    Key? key,
    required this.hint,
    required this.uniqueId,
    required this.value,
    required this.enabled,
    required this.onChanged,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey('${uniqueId}_${enabled}_$value'),
      initialValue: value,
      enabled: enabled,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(
        color: colour.textMain,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: colour.textSub.withOpacity(0.45),
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: enabled ? Colors.white : colour.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colour.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colour.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: colour.brand),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colour.border),
        ),
      ),
      onChanged: onChanged,
    );
  }
}

class MalevaSearchField extends StatelessWidget {
  final String hint;
  final String uniqueId;
  final String value;
  final bool enabled;
  final VoidCallback onSearch;
  final VoidCallback onClear;

  const MalevaSearchField({
    Key? key,
    required this.hint,
    required this.uniqueId,
    required this.value,
    required this.enabled,
    required this.onSearch,
    required this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: ValueKey('${uniqueId}_${enabled}_$value'),
      onTap: (enabled && value.isEmpty) ? onSearch : null,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: enabled ? Colors.white : colour.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colour.border),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value.isEmpty ? hint : value,
                style: GoogleFonts.poppins(
                  color: value.isEmpty
                      ? colour.textSub.withOpacity(0.45)
                      : colour.textMain,
                  fontSize: 13,
                  fontWeight: value.isEmpty ? FontWeight.w400 : FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (enabled)
              GestureDetector(
                onTap: value.isEmpty ? onSearch : onClear,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    value.isEmpty ? Icons.search_rounded : Icons.close_rounded,
                    color: colour.brand,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MalevaDateField extends StatelessWidget {
  final String date;
  final VoidCallback? onTap;

  const MalevaDateField({
    Key? key,
    required this.date,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: colour.brandLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colour.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, color: colour.brand, size: 15),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                date,
                style: GoogleFonts.poppins(
                  color: colour.brandDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
