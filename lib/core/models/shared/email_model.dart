import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class EmailModel {
  final String subject;
  final String messageId;
  final String name;
  final int employeeRefId;
  final String emailId;
  final String sender;
  final DateTime receivedDate;
  final bool isUnread;
  final bool isReplied;
  final String debugInfo;
  bool isActive;

  EmailModel({
    required this.subject,
    required this.messageId,
    required this.name,
    required this.employeeRefId,
    required this.emailId,
    required this.sender,
    required this.receivedDate,
    required this.isUnread,
    required this.isReplied,
    required this.debugInfo,
    this.isActive = false,
  });

  factory EmailModel.fromJson(Map<String, dynamic> json) {
    return EmailModel(
      subject: json["Subject"] ?? "",
      messageId: json["MessageId"] ?? "",
      name: json["Name"] ?? "",
      employeeRefId: json["EmployeeRefId"] ?? 0,
      emailId: json["EmailID"] ?? "",
      sender: json["Sender"] ?? "",
      receivedDate:
      DateTime.tryParse(json["ReceivedDate"] ?? "") ?? DateTime.now(),
      isUnread: json["IsUnread"] ?? false,
      isReplied: json["IsReplied"] ?? false,
      isActive: json["isActive"] ?? false,
      debugInfo: json["DebugInfo"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "Subject": subject,
    "MessageId": messageId,
    "Name": name,
    "EmployeeRefId": employeeRefId,
    "EmailID": emailId,
    "Sender": sender,
    "ReceivedDate": receivedDate.toIso8601String(),
    "IsUnread": isUnread,
    "IsReplied": isReplied,
    "isActive": isActive,
    "DebugInfo": debugInfo,
  };

  EmailModel.empty()
      : subject = '',
        messageId = '',
        name = '',
        employeeRefId = 0,
        emailId = '',
        sender = '',
        receivedDate = DateTime.now(),
        isUnread = false,
        isReplied = false,
        isActive = false,
        debugInfo = '';


  /// ✅ Add this
  EmailModel copyWith({
    String? subject,
    String? messageId,
    String? name,
    int? employeeRefId,
    String? emailId,
    String? sender,
    DateTime? receivedDate,
    bool? isUnread,
    bool? isReplied,
    String? debugInfo,
    bool? isActive,
  }) {
    return EmailModel(
      subject: subject ?? this.subject,
      messageId: messageId ?? this.messageId,
      name: name ?? this.name,
      employeeRefId: employeeRefId ?? this.employeeRefId,
      emailId: emailId ?? this.emailId,
      sender: sender ?? this.sender,
      receivedDate: receivedDate ?? this.receivedDate,
      isUnread: isUnread ?? this.isUnread,
      isReplied: isReplied ?? this.isReplied,
      isActive: isActive ?? this.isActive,
      debugInfo: debugInfo ?? this.debugInfo,
    );
  }
}