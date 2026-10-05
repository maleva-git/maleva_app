import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/planning/plans/bloc/plans_bloc.dart';

/// The list area: a skeleton while loading, the web's empty and failure texts, else [content].
class PlansStateSwitch extends StatelessWidget {
  const PlansStateSwitch({super.key, required this.state, required this.content});

  final PlansState state;
  final WidgetBuilder content;

  @override
  Widget build(BuildContext context) {
    if (state.status == PlansStatus.initial) return const SizedBox.shrink();
    if (state.loading) return const SkeletonList();
    if (state.status == PlansStatus.failure && state.rows.isEmpty) {
      return ErrorState(
        title: PlansBloc.loadFailed,
        onRetry: () => context.read<PlansBloc>().add(const PlansRefreshed()),
      );
    }
    if (state.rows.isEmpty) {
      return const EmptyState(
        icon: Icons.description_outlined,
        title: 'No planning logs found',
        message: 'Try adjusting the dates, unchecking "Login Employee", or inserting a new plan.',
      );
    }
    return content(context);
  }
}
