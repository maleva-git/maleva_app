import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../bloc/forwardingreport_bloc.dart';
import '../bloc/forwardingreport_event.dart';
import '../bloc/forwardingreport_state.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;

class ForwardingReportPage extends StatelessWidget {
  const ForwardingReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForwardingReportBloc(context)
        ..add(LoadFWDataEvent(
          fromDate: DateFormat("yyyy-MM-dd").format(DateTime.now()),
          toDate: DateFormat("yyyy-MM-dd").format(DateTime.now()),
        )),
      child: const ForwardingReportView(),
    );
  }
}

class ForwardingReportView extends StatelessWidget {
  const ForwardingReportView({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return BlocConsumer<ForwardingReportBloc, ForwardingReportState>(
      listener: (context, state) {
        if (state.status == FWStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == FWStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
          child: ListView(
            children: [
              const SizedBox(height: 7),

              // ── Title ──
              Center(
                child: Text(
                  'FORWARDING REPORT',
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                      color: colour.commonColorred,
                      fontWeight: FontWeight.bold,
                      fontSize: objfun.FontLarge,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),

              // ── Summary Card (Today/Yesterday/Weekly/Monthly) ──
              SizedBox(
                height: height * 0.24,
                child: Card(
                  child: Row(
                    children: [
                      // Labels column
                      Expanded(
                        flex: 2,
                        child: _buildLabelColumn(
                          labels: ['', 'Today', 'Yesterday', 'Weekly', 'Monthly'],
                        ),
                      ),
                      // Total column
                      Expanded(
                        flex: 1,
                        child: _buildDataColumn(
                          header: 'Total',
                          values: state.saleFWReport.isEmpty
                              ? ['0', '0', '0', '0']
                              : [
                            state.saleFWReport[0]["TodayCount"].toStringAsFixed(0),
                            state.saleFWReport[0]["YesterdayCount"].toStringAsFixed(0),
                            state.saleFWReport[0]["WeekCount"].toStringAsFixed(0),
                            state.saleFWReport[0]["MonthCount"].toStringAsFixed(0),
                          ],
                        ),
                      ),
                      // With Release column
                      Expanded(
                        flex: 1,
                        child: _buildDataColumn(
                          header: 'With',
                          values: state.saleFWReport.isEmpty
                              ? ['0', '0', '0', '0']
                              : [
                            state.saleFWReport[0]["TodayWithRelease"].toStringAsFixed(0),
                            state.saleFWReport[0]["YesterdayWithRelease"].toStringAsFixed(0),
                            state.saleFWReport[0]["WeekWithRelease"].toStringAsFixed(0),
                            state.saleFWReport[0]["MonthWithRelease"].toStringAsFixed(0),
                          ],
                        ),
                      ),
                      // Without Release column
                      Expanded(
                        flex: 2,
                        child: _buildDataColumn(
                          header: 'Without',
                          values: state.saleFWReport.isEmpty
                              ? ['0', '0', '0', '0']
                              : [
                            state.saleFWReport[0]["TodayRelease"].toStringAsFixed(0),
                            state.saleFWReport[0]["YesterdayRelease"].toStringAsFixed(0),
                            state.saleFWReport[0]["WeekRelease"].toStringAsFixed(0),
                            state.saleFWReport[0]["MonthRelease"].toStringAsFixed(0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: height * 0.03),

              // ── Date Picker Row ──
              _DatePickerRow(),

              // ── K1/K2/K3/K8 Section ──
              SizedBox(
                height: height * 0.30,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildLabelColumn(
                        labels: ['K1', 'K2', 'K3', 'K8'],
                        topPadding: 35,
                        itemPadding: 25,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: _buildDataColumn(
                        header: '',
                        values: state.saleFWReport2.isEmpty
                            ? ['0', '0', '0', '0']
                            : [
                          state.saleFWReport2[0]["K1Count"].toString(),
                          state.saleFWReport2[0]["K2Count"].toString(),
                          state.saleFWReport2[0]["K3Count"].toString(),
                          state.saleFWReport2[0]["K8Count"].toString(),
                        ],
                        topPadding: 35,
                        itemPadding: 25,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: _buildDataColumn(
                        header: '',
                        values: state.saleFWReport2.isEmpty
                            ? ['0', '0', '0', '0']
                            : [
                          state.saleFWReport2[0]["K1WithRelease"].toString(),
                          state.saleFWReport2[0]["K2WithRelease"].toString(),
                          state.saleFWReport2[0]["K3WithRelease"].toString(),
                          state.saleFWReport2[0]["K8WithRelease"].toString(),
                        ],
                        topPadding: 35,
                        itemPadding: 25,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: _buildDataColumn(
                        header: '',
                        values: state.saleFWReport2.isEmpty
                            ? ['0', '0', '0', '0']
                            : [
                          state.saleFWReport2[0]["K1Release"].toString(),
                          state.saleFWReport2[0]["K2Release"].toString(),
                          state.saleFWReport2[0]["K3Release"].toString(),
                          state.saleFWReport2[0]["K8Release"].toString(),
                        ],
                        topPadding: 35,
                        itemPadding: 25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Helper: Label Column ──
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

  // ── Helper: Data Column ──
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
            padding: EdgeInsets.only(top: topPadding, left: 5, right: 5, bottom: 5),
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
          padding: EdgeInsets.only(top: itemPadding, bottom: 5),
          child: Text(
            val,
            style: GoogleFonts.lato(
              textStyle: TextStyle(
                color: colour.commonColor,
                fontWeight: FontWeight.bold,
                fontSize: objfun.FontLow - 2,
                letterSpacing: 0.3,
              ),
            ),
          ),
        )),
      ],
    );
  }
}

// ── Date Picker Row Widget ──
class _DatePickerRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForwardingReportBloc, ForwardingReportState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Expanded(flex: 1, child: SizedBox()),

            // From Date Text
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
                  ),
                ),
              ),
            ),

            // From Date Calendar Icon
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
                    context.read<ForwardingReportBloc>()
                        .add(ChangFromDateEvent(fromDate: formatted));
                  }
                },
              ),
            ),

            const Expanded(flex: 1, child: SizedBox()),

            // To Date Text
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
                    context.read<ForwardingReportBloc>()
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
