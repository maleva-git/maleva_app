import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/theme/tokens.dart';

/// How the IR screens print dates, money and status colours.
class IrFormat {
  IrFormat._();

  static final DateFormat _date = DateFormat('dd MMM yyyy');
  static final DateFormat _dateTime = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat _shortDate = DateFormat('dd MMM');
  static final NumberFormat _amount = NumberFormat('#,##0');

  static String date(DateTime value) => _date.format(value);

  static String dateTime(DateTime value) => _dateTime.format(value);

  static String shortDate(DateTime value) => _shortDate.format(value);

  static String amount(int value) => 'RM ${_amount.format(value)}';

  /// IRStatusMaster.ColorCode is "#RRGGBB"; anything else is a neutral grey.
  static Color statusColor(String? hex) {
    final digits = hex?.replaceFirst('#', '').trim() ?? '';
    final value = digits.length == 6 ? int.tryParse(digits, radix: 16) : null;
    return value == null ? AppTokens.textMuted : Color(0xFF000000 | value);
  }
}
