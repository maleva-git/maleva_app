class JobOrderType {
  final int id;
  final String name;

  JobOrderType({
    required this.id,
    required this.name,
  });

  factory JobOrderType.fromJson(Map<String, dynamic> json) {
    return JobOrderType(
      id: json['Id'] ?? 0,
      name: json['Name'] ?? '',
    );
  }
}
