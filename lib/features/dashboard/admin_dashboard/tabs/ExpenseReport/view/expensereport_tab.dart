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
              fromDate: DateFormat("yyyy-MM-dd").format(DateTime.now()),
              toDate: DateFormat("yyyy-MM-dd").format(DateTime.now()),
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
                            header: ' ',
                            values: state.saleExpReport.isEmpty
                              ? ['0','0','0','0']
                              : [
                              (state.saleExpReport[0]["TodaySales"] ?? 0).toStringAsFixed(0),
                              (state.saleExpReport[0]["YesterdaySales"] ?? 0).toStringAsFixed(0),
                              (state.saleExpReport[0]["WeekSales"] ?? 0).toStringAsFixed(0),
                              (state.saleExpReport[0]["MonthSales"] ?? 0).toStringAsFixed(0),
                            ],
                          ),
                      ),
                      Expanded(
                        flex: 1,
                        child: _buildDataColumn(
                          header: ' ',
                          values: state.saleExpReport.isEmpty
                              ? ['0','0','0','0']
                              : [
                            (state.saleExpReport[0]["TodayAmount"] ?? 0).toStringAsFixed(0),
                            (state.saleExpReport[0]["YesterdayAmount"] ?? 0).toStringAsFixed(0),
                            (state.saleExpReport[0]["WeekAmount"] ?? 0).toStringAsFixed(0),
                            (state.saleExpReport[0]["MonthAmount"] ?? 0).toStringAsFixed(0),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: height * 0.03),
              _DatePickerRow(),

              SizedBox(
                height: height * 0.55,
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.saleExpReport2.length,
                  itemBuilder: (context, index) {
                    final item = state.saleExpReport2[index];

                    final expenseName = item["ExpenseName"] ?? "-";
                    final expAmount = (item["ExpAmount"] ?? 0).toDouble();
                    final expCount = (item["ExpCount"] ?? 0).toDouble();

                    return InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => context.read<ExpenseReportBloc>().add(
                        LoadExpReportEvent(
                          fromDate: state.dtpFromDate,
                          toDate: state.dtpToDate,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                expenseName,
                                style: const TextStyle(
                                  color: colour.commonColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                expCount.toStringAsFixed(0),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: colour.commonColor),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                expAmount.toStringAsFixed(0),
                                textAlign: TextAlign.end,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: colour.commonColor,),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


class _DatePickerRow extends StatelessWidget {
  @override

  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseReportBloc,ExpReportState>(
      builder: (context, state){
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Expanded(
              flex: 1,
              child: SizedBox()
            ),
            Expanded(
              flex: 4,
                child: Text(
                  DateFormat("dd-MM-yy").format(DateTime.parse(state.dtpFromDate)),
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                      color: colour.commonColor,
                      fontWeight: FontWeight.bold,
                      fontSize: objfun.FontLow,
                      letterSpacing: 0.3,
                    )
                  ),
                ),
            ),
            Expanded(
              flex: 2,
              child: InkWell(
                child: Container(
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                    image: DecorationImage(image: objfun.calendar),
                  ),
                ),
                onTap: () async {
                  final value = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2050),
                  );
                  if (value != null) {
                    final formatted = DateFormat("yyyy-MM-dd").format(value);
                    context.read<ExpenseReportBloc>()
                        .add(ChangeFromDateEvent(fromDate: formatted));
                  }
                },
              ),
            ),
            const Expanded(flex: 1, child: SizedBox()),
            Expanded(
              flex: 4,
              child: Text(
                DateFormat("dd-MM-yy").format(DateTime.parse(state.dtpToDate)),
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    color: colour.commonColor,
                    fontWeight: FontWeight.bold,
                    fontSize: objfun.FontLow,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),

            // To Date Calendar Icon
            Expanded(
              flex: 2,
              child: InkWell(
                child: Container(
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                    image: DecorationImage(image: objfun.calendar),
                  ),
                ),
                onTap: () async {
                  final value = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2050),
                  );
                  if (value != null) {
                    final formatted = DateFormat("yyyy-MM-dd").format(value);
                    context.read<ExpenseReportBloc>()
                        .add(ChangeToDateEvent(toDate: formatted));
                  }
                },
              ),
            ),

            const Expanded(flex: 1, child: SizedBox()),
          ],
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
  return Column
    (
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