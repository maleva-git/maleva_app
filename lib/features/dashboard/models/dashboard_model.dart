import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class DashboardModel {
  int TodaySales;
  double TodayAmount;
  int YesterdaySales;
  double YesterdayAmount;
  int WeekSales;
  double WeekAmount;
  int MonthSales;
  double MonthAmount;
  DashboardModel(
      this.TodaySales,
      this.TodayAmount,
      this.YesterdaySales,
      this.YesterdayAmount,
      this.WeekSales,
      this.WeekAmount,
      this.MonthSales,
      this.MonthAmount,);
  DashboardModel.fromJson(Map<String, dynamic> json)
      : TodaySales = int.tryParse(json['TodaySales']?.toString() ?? '') ?? 0,
        TodayAmount = double.parse(json['TodayAmount'].toString()),
        YesterdaySales = int.tryParse(json['YesterdaySales']?.toString() ?? '') ?? 0,
        YesterdayAmount = double.parse(json['YesterdayAmount'].toString()),
        WeekSales = int.tryParse(json['WeekSales']?.toString() ?? '') ?? 0,
        WeekAmount = double.parse(json['WeekAmount'].toString()),
        MonthSales = int.tryParse(json['MonthSales']?.toString() ?? '') ?? 0,
        MonthAmount = double.parse(json['MonthAmount'].toString());
}