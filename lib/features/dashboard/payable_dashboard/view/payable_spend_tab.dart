import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/features/dashboard/ceo_dashboard/bloc/ceo_dashboard_cubit.dart';
import 'package:maleva/features/dashboard/ceo_dashboard/data/ceo_analytics_api.dart';
import 'package:maleva/features/dashboard/ceo_dashboard/view/ceo_report_tabs.dart';

/// Purchase order and payment voucher expense for the accounts and payable team (change `payable-desk-today`):
/// the CEO dashboard's Expenses screens in spend-only mode, from the same Java `/api/ceo-dashboard/analytics/spend`
/// and spend lists, which the server opens to roles 900 and 1100 for their own company (`payable-spend-access`).
/// Counted the owner's way: each payment once, REJECTED vouchers never paid. The CEO overview is never asked.
class PayableSpendTab extends StatelessWidget {
  const PayableSpendTab({super.key, this.cubit});

  /// Tests give their own.
  final CeoDashboardCubit? cubit;

  @override
  Widget build(BuildContext context) {
    final given = cubit;
    const body = Material(color: Colors.transparent, child: CeoExpensesTab(spendOnly: true));
    return given != null
        ? BlocProvider.value(value: given, child: body)
        : BlocProvider(create: (_) => CeoDashboardCubit(sl<CeoAnalyticsApi>()), child: body);
  }
}
