import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/theme/tokens.dart';

import '../data/ceo_analytics_models.dart';
import 'ceo_widgets.dart';


/// The expense categories as a donut, the total in the middle. A tap on a slice calls [onTap] with the
/// category index; the slice past the first [CeoAccent.series].length - 1 categories is "Others".
class ExpenseDonut extends StatelessWidget {
  const ExpenseDonut({super.key, required this.categories, required this.total, required this.onTap});

  final List<CeoGroup> categories;
  final double total;
  final ValueChanged<int> onTap;

  static int get slices => CeoAccent.series.length - 1;

  static Color colorOf(int index) => index < slices ? CeoAccent.series[index] : CeoAccent.series.last;

  @override
  Widget build(BuildContext context) {
    final shown = categories.take(slices).toList();
    final others = categories.skip(slices).fold<double>(0, (a, c) => a + c.amount);
    final sum = shown.fold<double>(0, (a, c) => a + (c.amount > 0 ? c.amount : 0)) + (others > 0 ? others : 0);
    // the category index of each slice drawn (zero amounts draw none)
    final drawn = [
      for (var i = 0; i < shown.length; i++)
        if (shown[i].amount > 0) i
    ];
    return SizedBox(
      height: 170,
      child: Stack(alignment: Alignment.center, children: [
        if (sum > 0)
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 52,
              startDegreeOffset: -90,
              pieTouchData: PieTouchData(touchCallback: (event, response) {
                final i = response?.touchedSection?.touchedSectionIndex ?? -1;
                if (event is FlTapUpEvent && i >= 0 && i < drawn.length) onTap(drawn[i]);
              }),
              sections: [
                for (final i in drawn)
                  PieChartSectionData(value: shown[i].amount, color: colorOf(i), radius: 24, showTitle: false),
                if (others > 0)
                  PieChartSectionData(value: others, color: CeoAccent.series.last, radius: 24, showTitle: false),
              ],
            ),
          )
        else
          Container(
            width: 152,
            height: 152,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Palette.grey300, width: 24)),
          ),
        Column(mainAxisSize: MainAxisSize.min, children: [
          Text('TOTAL', style: AppTypography.badgeText(color: AppTokens.textMuted, fontWeight: FontWeight.w800)),
          Text('RM ${ceoCompact(total)}',
              style: AppTypography.heading2(color: AppTokens.textPrimary, fontWeight: FontWeight.w800)),
        ]),
      ]),
    );
  }
}
