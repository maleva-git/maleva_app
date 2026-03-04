import 'package:app_version_update/core/values/consts/consts.dart';
import 'package:flutter/Material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/ExpenseReport/bloc/expensereport_bloc.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/ExpenseReport/bloc/expensereport_event.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/ExpenseReport/bloc/expensereport_state.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;

class ExpenseReportPage extends StatelessWidget {
  const ExpenseReportPage({super.key});

  @override

  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => ExpenseReportBloc(context)
            ..add(LoadExpReportEvent(
              fromDate: DateFormat("YYYY-MM-dd").format(DateTime.now()),
              toDate: DateFormat("YYYY-MM-dd").format(DateTime.now()),
            )),
      child: const ExpenseReportView(),
    );
  }
}

class ExpenseReportView extends StatelessWidget {
  const ExpenseReportView({super.key});

  @override
  Widget build(BuildContext context){
    final height = MediaQuery.of(context).size.height;

    return BlocConsumer<ExpenseReportBloc, ExpReportState>(
      listener: (context, state) {
        if (state.status == ExpStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
            )
          );
        }
      },
      builder: (context, state) {
        if (state.status == ExpStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
          child: ListView(
            children: [
              const SizedBox(height: 7,),

              Center(
                child: Text(
                  'EXPENSE REPORT',
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                      color: colour.commonColorred,
                      fontWeight: FontWeight.bold,
                      fontSize: objfun.FontLarge,
                      letterSpacing: 0.3
                    )
                  ),
                ),
              ),

              SizedBox(
                height:  height * 0.24,
                child: Card(
                  child: Row(
                    children: [
                      // Expanded(
                      //   flex: 2,
                      //   child: _buildLabelColumn(
                      //     labels: ['','Today', 'Yesterday', 'Weekly', 'Monthly'],
                      //   ),
                      // ),
                      // Expanded(
                      //     flex: 1,
                      //     child: _buildDataColumn(
                      //       headers: 'Total',
                      //       values: state.
                      //     )
                      // )
                    ],
                  ),
                ),
              )

            ],
          ),
        );
      },
    );
  }
}