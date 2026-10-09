import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maleva/core/widgets/ui/ui.dart';

/// Drag-and-drop of board rows from the S.NO handle, like the web grid's S.NO grip
/// (`planningColumns.tsx:54-81`, `usePlanningListPage.ts:892-908`): only the order changes.
///
/// The board's rows are split between a frozen part and a part that scrolls sideways, so a
/// reorderable list cannot hold them; this tracks the dragged row by index instead. While a row is
/// dragged the board shows where it will land ([insertAt]) and scrolls itself near the edges.
class BoardDragController extends ChangeNotifier {
  BoardDragController({required this.rowHeight, required this.scroll, required this.viewportKey, required this.onMove});

  final double rowHeight;
  final ScrollController scroll;

  /// The vertical scroll view of the board body (its top is row 0 when not scrolled).
  final GlobalKey viewportKey;

  /// Called on drop with the row's index and its new index (the web's `moveRow(from, to)`).
  final void Function(int from, int to) onMove;

  int rowCount = 0;
  int? from;

  /// Where the row will be inserted, 0..rowCount (before that row; rowCount = after the last).
  int? insertAt;

  /// The pointer's y inside the viewport, for the floating label.
  double pointerY = 0;
  Timer? _autoScroll;
  double _lastGlobalY = 0;

  bool get dragging => from != null;

  /// The new index the row would get (the web's `toIndex`).
  int? get targetIndex {
    final f = from, t = insertAt;
    if (f == null || t == null) return null;
    return t > f ? t - 1 : t;
  }

  Drag start(int index, Offset global) {
    from = index;
    _lastGlobalY = global.dy;
    _locate();
    HapticFeedback.selectionClick();
    _autoScroll = Timer.periodic(const Duration(milliseconds: 30), (_) => _edgeScroll());
    notifyListeners();
    return _RowDrag(this);
  }

  void _update(Offset global) {
    _lastGlobalY = global.dy;
    final before = insertAt;
    _locate();
    if (before != insertAt) HapticFeedback.selectionClick();
    notifyListeners();
  }

  void _end() {
    final f = from, to = targetIndex;
    _reset();
    if (f != null && to != null && to != f) onMove(f, to);
  }

  void _reset() {
    _autoScroll?.cancel();
    _autoScroll = null;
    from = null;
    insertAt = null;
    notifyListeners();
  }

  RenderBox? get _box => viewportKey.currentContext?.findRenderObject() as RenderBox?;

  void _locate() {
    final box = _box;
    if (box == null || !scroll.hasClients) return;
    final local = box.globalToLocal(Offset(0, _lastGlobalY)).dy;
    pointerY = local.clamp(0, box.size.height);
    final contentY = local + scroll.offset;
    insertAt = (contentY / rowHeight).round().clamp(0, rowCount);
  }

  /// Scrolls when the pointer rests within 48 dp of the top or bottom edge.
  void _edgeScroll() {
    final box = _box;
    if (box == null || !scroll.hasClients) return;
    final local = box.globalToLocal(Offset(0, _lastGlobalY)).dy;
    const edge = 48.0, step = 14.0;
    double? next;
    if (local < edge) next = scroll.offset - step;
    if (local > box.size.height - edge) next = scroll.offset + step;
    if (next == null) return;
    final clamped = next.clamp(0.0, scroll.position.maxScrollExtent);
    if (clamped == scroll.offset) return;
    scroll.jumpTo(clamped);
    _update(Offset(0, _lastGlobalY));
  }

  @override
  void dispose() {
    _autoScroll?.cancel();
    super.dispose();
  }
}

class _RowDrag implements Drag {
  _RowDrag(this._c);

  final BoardDragController _c;

  @override
  void update(DragUpdateDetails details) => _c._update(details.globalPosition);

  @override
  void end(DragEndDetails details) => _c._end();

  @override
  void cancel() => _c._reset();
}

/// The S.NO cell: the row number and a grip. Pressing the grip starts the drag at once (it wins
/// over the board's scrolling), as the web's grip does.
class BoardDragHandle extends StatelessWidget {
  const BoardDragHandle({super.key, required this.index, required this.controller, required this.enabled, required this.width, required this.height, required this.jobNo});

  final int index;
  final BoardDragController controller;
  final bool enabled;
  final double width;
  final double height;
  final String jobNo;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final content = SizedBox(
      width: width,
      height: height,
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('${index + 1}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: mc.muted)),
        if (enabled) ...[const SizedBox(width: 2), Icon(Icons.drag_indicator, size: 22, color: mc.faint)],
      ]),
    );
    if (!enabled) return content;
    return Semantics(
      label: 'Drag $jobNo to reorder, row ${index + 1}',
      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: RawGestureDetector(
          gestures: {
            ImmediateMultiDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<ImmediateMultiDragGestureRecognizer>(
              ImmediateMultiDragGestureRecognizer.new,
              (r) => r
                // The board's scroll view uses the device's touch slop (about 8 dp on Android,
                // under the 18 dp default); a smaller one here lets the grip win the finger.
                ..gestureSettings = const DeviceGestureSettings(touchSlop: 2)
                ..onStart = (pos) => controller.start(index, pos),
            ),
          },
          child: content,
        ),
      ),
    );
  }
}

/// The floating label that follows the pointer while a row is dragged.
class BoardDragGhost extends StatelessWidget {
  const BoardDragGhost({super.key, required this.controller, required this.label, required this.left});

  final BoardDragController controller;
  final String label;
  final double left;

  @override
  Widget build(BuildContext context) {
    final to = controller.targetIndex;
    return Positioned(
      left: left,
      top: (controller.pointerY - 22).clamp(0, double.infinity),
      child: IgnorePointer(
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(12),
          color: context.cs.primary,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Text(to == null ? label : '$label → row ${to + 1}',
                style: TextStyle(color: context.cs.onPrimary, fontWeight: FontWeight.w800, fontSize: 14)),
          ),
        ),
      ),
    );
  }
}
