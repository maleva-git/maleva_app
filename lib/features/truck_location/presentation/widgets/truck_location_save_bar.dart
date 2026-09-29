import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/tokens.dart';

import '../bloc/truck_location_bloc.dart';

/// The one save for cells and Done ticks, pinned above the keyboard.
class TruckLocationSaveBar extends StatelessWidget {
  const TruckLocationSaveBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TruckLocationBloc, TruckLocationState>(
      buildWhen: (previous, current) =>
          previous.unsavedCount != current.unsavedCount ||
          previous.saving != current.saving,
      builder: (context, state) {
        final count = state.unsavedCount;
        return Material(
          color: AppTokens.surfaceCard,
          elevation: 8,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: count > 0
                        ? Text(
                            '$count not saved',
                            style: AppTypography.bodyMedium(
                              color: AppTokens.statusWarning,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: count > 0 && !state.saving
                          ? () => context
                              .read<TruckLocationBloc>()
                              .add(const TruckLocationSaveAllPressed())
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTokens.brandPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                      child: state.saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Text('Save all'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
