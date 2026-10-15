import 'package:flutter/material.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/core/theme/app_typography.dart';

import '../../../../../core/theme/tokens.dart';

/// The comma-separated port list ("WESTPORT-B18,NORTHPORT- B10") the vessel plan searches by,
/// and what a pick from the dropdown does to it.
abstract final class PortSearchText {
  static List<String> _parts(String text) => text.split(',').map((e) => e.trim()).toList();

  /// The ports already in [text], except the part being typed.
  static List<String> chosen(String text, List<String> ports) {
    final parts = _parts(text);
    final typing = query(text, ports);
    return [for (final p in typing.isEmpty ? parts : parts.sublist(0, parts.length - 1)) if (p.isNotEmpty) p];
  }

  /// What is being typed: the text after the last comma; empty when that part is already a
  /// whole port (just picked), so the dropdown offers the next one.
  static String query(String text, List<String> ports) {
    final last = _parts(text).last;
    final whole = ports.any((p) => p.toLowerCase() == last.toLowerCase());
    return whole ? '' : last;
  }

  /// The ports matching what is typed (anywhere in the name, any case), without those already chosen.
  static List<String> matches(String text, List<String> ports) {
    final q = query(text, ports).toLowerCase();
    final taken = chosen(text, ports).map((e) => e.toLowerCase()).toSet();
    return [for (final p in ports) if (!taken.contains(p.toLowerCase()) && p.toLowerCase().contains(q)) p];
  }

  /// [text] with [port] in place of the part being typed (or added after the chosen ones).
  static String pick(String text, String port, List<String> ports) => [...chosen(text, ports), port].join(',');
}

/// "Search Port": type and the matching ports drop down under the field; a tap adds the port to
/// the comma-separated list in [controller]. The text can still be typed or edited by hand.
class PortSearchField extends StatefulWidget {
  const PortSearchField({super.key, required this.controller, required this.ports});

  final TextEditingController controller;
  final List<String> ports;

  @override
  State<PortSearchField> createState() => _PortSearchFieldState();
}

class _PortSearchFieldState extends State<PortSearchField> {
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) => RawAutocomplete<String>(
          textEditingController: widget.controller,
          focusNode: _focus,
          // an option is the field's whole new text; the list shows just its port
          optionsBuilder: (v) => [for (final p in PortSearchText.matches(v.text, widget.ports)) PortSearchText.pick(v.text, p, widget.ports)],
          fieldViewBuilder: (context, controller, focus, onSubmitted) => Container(
            height: 48,
            decoration: BoxDecoration(
              color: colour.kCardBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTokens.maintCardBorder),
            ),
            child: TextField(
              controller: controller,
              focusNode: focus,
              style: AppTypography.heading2(),
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Type to search ports',
                hintStyle: AppTypography.bodyMedium(color: AppTokens.textMuted),
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (_, v, __) => v.text.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(tooltip: 'Clear ports', icon: const Icon(Icons.close_rounded, size: 18), onPressed: controller.clear),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
            ),
          ),
          optionsViewBuilder: (context, onSelected, options) => Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(8),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 280, maxWidth: box.maxWidth),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, i) {
                    final option = options.elementAt(i);
                    return InkWell(
                      onTap: () => onSelected(option),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(children: [
                          const Icon(Icons.anchor_rounded, size: 18, color: colour.commonColor),
                          const SizedBox(width: 10),
                          Expanded(child: Text(option.split(',').last, style: AppTypography.heading2())),
                        ]),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
}
