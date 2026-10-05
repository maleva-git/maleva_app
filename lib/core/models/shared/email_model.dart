import 'package:intl/intl.dart';
import 'package:maleva/core/utils/json_read.dart';


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

  /// One unanswered mail of the shared Java inbox (`/api/email-inboxes/unanswered`).
  /// The received time is UTC, as the mailbox gives it.
  factory EmailModel.fromJava(Map<String, dynamic> json) {
    final received = JsonRead.string(json['receivedDate']);
    return EmailModel(
      subject: JsonRead.string(json['subject']),
      messageId: JsonRead.string(json['messageId']),
      name: JsonRead.string(json['name']),
      employeeRefId: JsonRead.integer(json['employeeRefId']),
      emailId: JsonRead.string(json['emailId']),
      sender: JsonRead.string(json['sender']),
      receivedDate: DateTime.tryParse(received.isEmpty || received.endsWith('Z') ? received : '${received}Z') ?? DateTime.now().toUtc(),
      isUnread: json['isUnread'] == true,
      isReplied: json['isReplied'] == true,
      debugInfo: '',
    );
  }

  /// The Java inbox entry to keep (SP_EmailInbox), as an active entry of [employeeId].
  Map<String, dynamic> toJava(int employeeId) => {
    'id': 0,
    'employeeRefId': employeeId,
    'emailId': emailId,
    'subject': subject,
    'sender': sender,
    'receivedDate': DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(receivedDate.toUtc()),
    'isUnread': isUnread ? 1 : 0,
    'isReplied': isReplied ? 1 : 0,
    'active': 1,
  };

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