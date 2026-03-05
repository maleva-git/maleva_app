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
                      Expanded(
                        flex: 2,
                        child: _buildLabelColumn(
                          labels: ['','Today', 'Yesterday', 'Weekly', 'Monthly'],
                        ),
                      ),
                      Expanded(
                          flex: 1,
                          child: _buildDataColumn(
                            header: 'Total',
                            values: state.saleExpReport.isEmpty
                              ? ['0','0','0','0']
                              : [
                              state.saleExpReport[0]["TodayCount"].toStringAsFixed(0),
                              state.saleExpReport[0]["YesterdayCount"].toStringAsFixed(0),
                              state.saleExpReport[0]["WeekCount"].toStringAsFixed(0),
                              state.saleExpReport[0]["MonthCount"].toStringAsFixed(0),
                            ],
                          ),
                      )
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

Widget _buildLabelColumn({
  required List<String> labels,
  double topPadding = 15,
  double itemPadding = 5,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: labels.map((label) {
      final isFirst = labels.indexOf(label) == 0;
      return Padding(
        padding: EdgeInsets.only(
          top: isFirst ? topPadding : itemPadding,
          left: 5,
          right: 5,
          bottom: 5,
        ),
        child: Text(
          label,
          textAlign: TextAlign.left,
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              color: colour.commonColor,
              fontWeight: FontWeight.bold,
              fontSize: objfun.FontLow - 2,
              letterSpacing: 0.3,
            ),
          ),
        ),
      );
    }).toList(),
  );
}

Widget _buildDataColumn({
  required String header,
  required List<String> values,
  double topPadding = 15,
  double itemPadding = 5,
}) {
  return Column(
    children: [
      if (header.isNotEmpty)
        Padding(
          padding: EdgeInsets.only(top: topPadding,left: 5,right: 5,bottom: 5),
          child: Text(
            header,
            style: GoogleFonts.lato(
              textStyle: TextStyle(
                color: colour.commonColor,
                fontWeight: FontWeight.bold,
                fontSize: objfun.FontLow - 2,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ...values.map((val) => Padding(
   padding: EdgeInsets.only(top: itemPadding,bottom: 5),
  child: Text(
     val,
     style: GoogleFonts.lato(
       textStyle: TextStyle(
         color: colour.commonColor,
         fontWeight: FontWeight.bold,
         fontSize: objfun.FontLow - 2,
         letterSpacing: 0.3,
       )
     )),
  ),
  )
    ],
  );
}