import 'package:maleva/core/utils/json_read.dart';

/// A job order status (`/api/job-orders/statuses`); the name is kept from the
/// .NET call it replaced, SelectJoborderType, which answered statuses too.
class JobOrderType {
  final int id;
  final String name;

  JobOrderType({
    required this.id,
    required this.name,
  });

  factory JobOrderType.fromJava(Map<String, dynamic> json) {
    return JobOrderType(
      id: JsonRead.integer(json['id']),
      name: JsonRead.string(json['name']),
    );
  }
}
