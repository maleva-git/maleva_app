import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/widgets/custom_app_bar.dart';

import '../form/bloc/ir_form_bloc.dart';
import '../ir_view_status.dart';
import '../widgets/ir_feedback.dart';
import '../widgets/ir_form_view.dart';

/// New or edit incident report. Pops with `true` after a successful save so
/// the list reloads.
class IrFormPage extends StatelessWidget {
  const IrFormPage({super.key, this.reportId, this.readOnly = false});

  final int? reportId;

  /// The user may view but not edit (no PageEdit on the menu entry).
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<IrFormBloc, IrFormState>(
          listenWhen: (previous, current) =>
              previous.submitStatus != current.submitStatus &&
              current.submitStatus == IrSubmitStatus.success,
          listener: (context, state) => Navigator.of(context).pop(true),
        ),
        BlocListener<IrFormBloc, IrFormState>(
          listenWhen: (previous, current) =>
              current.message != null && previous.message != current.message,
          listener: (context, state) => showIrMessage(context, state.message!),
        ),
      ],
      child: BlocBuilder<IrFormBloc, IrFormState>(
        builder: (context, state) {
          final loaded = state.loadStatus == IrViewStatus.success;
          return Scaffold(
            backgroundColor: AppTokens.surfacePage,
            appBar: CustomGradientAppBar(title: _title(state), showBackButton: true),
            body: switch (state.loadStatus) {
              IrViewStatus.success => IrFormView(state: state, readOnly: readOnly),
              IrViewStatus.failure => IrMessageView(
                  icon: Icons.error_outline_rounded,
                  title: 'Could not open the incident report',
                  message: state.loadError,
                  actionLabel: 'Retry',
                  onAction: () =>
                      context.read<IrFormBloc>().add(IrFormStarted(reportId: reportId)),
                ),
              _ => const Center(child: CircularProgressIndicator()),
            },
            bottomNavigationBar: loaded && !readOnly
                ? _SaveBar(
                    isNew: state.isNew,
                    submitting: state.submitStatus == IrSubmitStatus.submitting,
                  )
                : null,
          );
        },
      ),
    );
  }

  String _title(IrFormState state) {
    if (state.loadStatus != IrViewStatus.success || readOnly) return 'Incident Report';
    return state.isNew ? 'New Incident Report' : 'Edit Incident Report';
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.isNew, required this.submitting});

  final bool isNew;
  final bool submitting;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTokens.surfaceCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTokens.brandPrimary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppTokens.brandPrimary.withValues(alpha: 0.6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: submitting
                  ? null
                  : () => context.read<IrFormBloc>().add(const IrFormSubmitted()),
              child: submitting
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Text('Saving', style: AppTypography.heading3(color: Colors.white)),
                      ],
                    )
                  : Text(
                      isNew ? 'Save report' : 'Update report',
                      style: AppTypography.heading3(color: Colors.white),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
