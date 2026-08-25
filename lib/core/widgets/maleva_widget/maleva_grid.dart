import 'package:flutter/material.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/theme/app_typography.dart';

class MalevaGrid extends StatelessWidget {
  final List<String> columns;
  final List<List<Widget>> rows;
  final List<void Function()>? onRowTap;
  final List<void Function()>? onRowLongPress;
  final bool isTablet;

  const MalevaGrid({
    super.key,
    required this.columns,
    required this.rows,
    required this.isTablet,
    this.onRowTap,
    this.onRowLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      physics: const AlwaysScrollableScrollPhysics(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              clipBehavior: Clip.antiAlias,
              child: DataTable(
                showCheckboxColumn: false,
                headingRowColor: WidgetStateProperty.all(Palette.blue700),
                headingTextStyle: AppTypography.bodySmall(color: Colors.white, fontWeight: FontWeight.bold),
                dataRowMinHeight: 40,
                dataRowMaxHeight: 50,
                dataTextStyle: AppTypography.bodySmall(color: AppTokens.textPrimary, fontWeight: FontWeight.w500),
                columnSpacing: 16,
                border: TableBorder(
                  horizontalInside: BorderSide(color: AppTokens.surfaceBorder.withValues(alpha: 0.5), width: 1),
                  verticalInside: BorderSide(color: AppTokens.surfaceBorder.withValues(alpha: 0.5), width: 1),
                ),
                columns: columns.map((text) => DataColumn(
                  label: Text(text),
                )).toList(),
                rows: rows.asMap().entries.map((entry) {
                  final index = entry.key;
                  final rowData = entry.value;
                  return DataRow(
                    color: WidgetStateProperty.all(index % 2 == 0 ? Colors.white : AppTokens.surfaceCard),
                    onSelectChanged: onRowTap != null && index < onRowTap!.length
                        ? (_) => onRowTap![index]()
                        : null,
                    onLongPress: onRowLongPress != null && index < onRowLongPress!.length
                        ? () => onRowLongPress![index]()
                        : null,
                    cells: rowData.map((cellWidget) => DataCell(cellWidget)).toList(),
                  );
                }).toList(),
              ),
            ),
          ),
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

