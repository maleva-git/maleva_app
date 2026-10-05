import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/planning/plans/bloc/plans_bloc.dart';
import 'package:maleva/features/planning/plans/widgets/plans_filter_form.dart';

/// "Filters · n" button.
class PlansFilterButton extends StatelessWidget {
  const PlansFilterButton({super.key, required this.count, required this.onPressed, this.label = false});

  final int count;
  final VoidCallback onPressed;

  /// Shows "Filters · n" as text (tablet) instead of an icon with a badge (phone).
  final bool label;

  @override
  Widget build(BuildContext context) {
    if (label) {
      return OutlinedButton.icon(
        style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
        onPressed: onPressed,
        icon: const Icon(Icons.tune),
        label: Text(count == 0 ? 'Filters' : 'Filters · $count'),
      );
    }
    return IconButton.outlined(
      tooltip: 'Filters',
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      onPressed: onPressed,
      icon: Badge(isLabelVisible: count > 0, label: Text('$count'), child: const Icon(Icons.tune)),
    );
  }
}

/// The filters with their title and Clear / View, for a sheet, a drawer or a side panel.
class PlansFilterPanel extends StatelessWidget {
  const PlansFilterPanel({super.key, this.onDone, this.showClose = false});

  final VoidCallback? onDone;
  final bool showClose;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 8, 4),
          child: Row(children: [
            const Expanded(child: Text('Filter plans', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
            if (showClose) IconButton(tooltip: 'Close', onPressed: onDone, icon: const Icon(Icons.close)),
          ]),
        ),
        const Expanded(child: SingleChildScrollView(padding: EdgeInsets.fromLTRB(16, 8, 16, 12), child: PlansFilterForm())),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          decoration: BoxDecoration(border: Border(top: BorderSide(color: context.mc.outline))),
          child: SafeArea(top: false, child: PlansFilterActions(onDone: onDone)),
        ),
      ]);
}

/// The filters in a bottom sheet (phone) or a side sheet (tablet portrait).
Future<void> showPlansFilterSheet(BuildContext context) {
  final bloc = context.read<PlansBloc>();
  Widget body(BuildContext ctx) => BlocProvider.value(
        value: bloc,
        child: MalevaThemeScope(child: PlansFilterPanel(showClose: true, onDone: () => Navigator.of(ctx).pop())),
      );
  if (FormFactor.of(context).isTablet) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close filters',
      pageBuilder: (ctx, _, __) => Align(
        alignment: Alignment.centerRight,
        child: Material(
          elevation: 8,
          child: SizedBox(width: 380, height: double.infinity, child: SafeArea(child: body(ctx))),
        ),
      ),
    );
  }
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      child: SizedBox(height: MediaQuery.sizeOf(ctx).height * 0.85, child: body(ctx)),
    ),
  );
}
