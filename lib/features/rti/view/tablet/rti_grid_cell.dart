import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maleva/features/rti/models/rti_job_row.dart';

/// What a grid cell asks its grid to do (`R/components/RTIGridCell.tsx:98-182`).
abstract class RtiGridCellHost {
  FocusNode focusOf(int row, String column);
  int get rowCount;
  void commit(int row, String column, String value);
  void lookup(int row, String jobNo);
  void addRowAndFocus(int focusRow);
  void deleteRow(int row);
  void paste(int row, String column, String text);
}

/// One editable cell of the job grid with the web's keys: Enter next (Job No looks the job
/// up), Shift+Enter previous, Enter on the last cell adds a row, Insert adds a row,
/// Ctrl/Cmd+Delete deletes the row, Esc undoes the cell, Ctrl+Home/End, the arrows; a
/// multi-cell paste fills the grid.
class RtiGridCell extends StatefulWidget {
  const RtiGridCell({super.key, required this.host, required this.row, required this.column, required this.value});

  final RtiGridCellHost host;
  final int row;
  final String column;
  final String value;

  @override
  State<RtiGridCell> createState() => _RtiGridCellState();
}

class _RtiGridCellState extends State<RtiGridCell> {
  late final TextEditingController _c = TextEditingController(text: widget.value);
  late FocusNode _focus;

  bool get _numeric => RtiJobColumns.numeric.contains(widget.column);

  @override
  void initState() {
    super.initState();
    _bindFocus();
  }

  void _bindFocus() {
    _focus = widget.host.focusOf(widget.row, widget.column);
    _focus.addListener(_onFocus);
    _focus.onKeyEvent = _onKey;
  }

  @override
  void didUpdateWidget(covariant RtiGridCell old) {
    super.didUpdateWidget(old);
    if (old.row != widget.row || old.column != widget.column) {
      _focus.removeListener(_onFocus);
      _bindFocus();
    }
    if (old.value != widget.value && widget.value != _c.text) _c.text = widget.value;
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    _c.dispose();
    super.dispose();
  }

  void _onFocus() {
    if (_focus.hasFocus) {
      _c.selection = TextSelection(baseOffset: 0, extentOffset: _c.text.length);
    } else {
      _commit();
    }
  }

  void _commit() {
    if (_c.text != widget.value) widget.host.commit(widget.row, widget.column, _c.text);
  }

  void _focusCell(int row, String column) {
    if (row < 0 || row >= widget.host.rowCount) return;
    widget.host.focusOf(row, column).requestFocus();
  }

  void _next() {
    const cols = RtiJobColumns.editable;
    final i = cols.indexOf(widget.column);
    final lastCol = i == cols.length - 1;
    if (lastCol && widget.row == widget.host.rowCount - 1) return widget.host.addRowAndFocus(widget.row + 1);
    if (lastCol) return _focusCell(widget.row + 1, cols.first);
    _focusCell(widget.row, cols[i + 1]);
  }

  void _previous() {
    const cols = RtiJobColumns.editable;
    final i = cols.indexOf(widget.column);
    if (i > 0) return _focusCell(widget.row, cols[i - 1]);
    if (widget.row > 0) _focusCell(widget.row - 1, cols.last);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent && e is! KeyRepeatEvent) return KeyEventResult.ignored;
    final keys = HardwareKeyboard.instance;
    final ctrl = keys.isControlPressed || keys.isMetaPressed;
    final k = e.logicalKey;
    const cols = RtiJobColumns.editable;
    final at = _c.selection.baseOffset;
    if (k == LogicalKeyboardKey.insert) {
      _commit();
      widget.host.addRowAndFocus(widget.host.rowCount);
    } else if (ctrl && k == LogicalKeyboardKey.delete) {
      _commit();
      widget.host.deleteRow(widget.row);
    } else if (k == LogicalKeyboardKey.escape) {
      _c.text = widget.value;
      _c.selection = TextSelection(baseOffset: 0, extentOffset: _c.text.length);
    } else if (k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.numpadEnter) {
      final draft = _c.text;
      if (widget.column == RtiJobColumns.jobNo && draft.isNotEmpty) {
        widget.host.lookup(widget.row, draft);
      } else {
        _commit();
      }
      keys.isShiftPressed ? _previous() : _next();
    } else if (ctrl && k == LogicalKeyboardKey.home) {
      _focusCell(0, cols.first);
    } else if (ctrl && k == LogicalKeyboardKey.end) {
      _focusCell(widget.host.rowCount - 1, cols.last);
    } else if (k == LogicalKeyboardKey.arrowRight && at == _c.text.length && _c.selection.isCollapsed) {
      final i = cols.indexOf(widget.column);
      if (i < cols.length - 1) _focusCell(widget.row, cols[i + 1]);
    } else if (k == LogicalKeyboardKey.arrowLeft && at == 0 && _c.selection.isCollapsed) {
      final i = cols.indexOf(widget.column);
      if (i > 0) _focusCell(widget.row, cols[i - 1]);
    } else if (k == LogicalKeyboardKey.arrowDown && widget.row < widget.host.rowCount - 1) {
      _focusCell(widget.row + 1, widget.column);
    } else if (k == LogicalKeyboardKey.arrowUp && widget.row > 0) {
      _focusCell(widget.row - 1, widget.column);
    } else if (ctrl && k == LogicalKeyboardKey.keyV) {
      _paste();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  Future<void> _paste() async {
    final text = (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
    if (text.contains('\n') || text.contains('\t')) {
      widget.host.paste(widget.row, widget.column, text);
      return;
    }
    final sel = _c.selection.isValid ? _c.selection : TextSelection.collapsed(offset: _c.text.length);
    final next = _c.text.replaceRange(sel.start, sel.end, text);
    _c.value = TextEditingValue(text: next, selection: TextSelection.collapsed(offset: sel.start + text.length));
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: _c,
        focusNode: _focus,
        textAlign: _numeric ? TextAlign.right : TextAlign.start,
        keyboardType: _numeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12)),
      );
}
