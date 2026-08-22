import 'package:flutter/material.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/core/theme/tokens.dart';

class MalevaGrid extends StatelessWidget {
  final List<String> columns;
  final List<List<Widget>> rows;
  final bool isTablet;

  const MalevaGrid({
    super.key,
    required this.columns,
    required this.rows,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: colour.kBorder, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(colour.kCobalt.withValues(alpha: 0.05)),
          columnSpacing: 20,
          dataRowMinHeight: 40,
          dataRowMaxHeight: 60,
          headingRowHeight: 40,
          columns: columns.map((text) => DataColumn(
            label: Text(
              text,
              style: TextStyle(
                fontSize: isTablet ? 12 : 11,
                color: AppTokens.planTextMuted,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter', // assuming GoogleFonts was used similarly
              ),
            ),
          )).toList(),
          rows: rows.map((rowData) {
            return DataRow(
              cells: rowData.map((cellWidget) => DataCell(cellWidget)).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class MalevaGridCell extends StatelessWidget {
  final String text;
  final Color? color;
  final FontWeight? fw;
  final bool isTablet;

  const MalevaGridCell(this.text, {super.key, required this.isTablet, this.color, this.fw});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.isEmpty || text == 'null' ? '-' : text,
      style: TextStyle(
        fontSize: isTablet ? 12 : 11,
        color: color ?? colour.kText,
        fontWeight: fw ?? FontWeight.normal,
        fontFamily: 'Inter',
      ),
    );
  }
}
