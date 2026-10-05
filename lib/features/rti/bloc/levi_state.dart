import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:maleva/core/utils/json_read.dart';

/// One levi filed against the RTI (`FE/features/pass-entry/types/passEntry.ts` `PassEntryListItem`).
class LeviItem extends Equatable {
  const LeviItem({
    required this.id,
    this.cNumberDisplay = '',
    this.saleDate = '',
    this.truckRefId = 0,
    this.truckName,
    this.driverRefId = 0,
    this.driverName,
    this.enterLink = '',
    this.exitLink = '',
    this.amount,
    this.remarks = '',
  });

  factory LeviItem.fromJava(Map<String, dynamic> r) {
    dynamic f(String k) => JsonRead.field(r, k);
    return LeviItem(
      id: JsonRead.integer(f('id')),
      cNumberDisplay: JsonRead.string(f('cNumberDisplay')),
      saleDate: JsonRead.string(f('saleDate')),
      truckRefId: JsonRead.integer(f('truckRefId')),
      truckName: JsonRead.stringOrNull(f('truckName')),
      driverRefId: JsonRead.integer(f('driverRefId')),
      driverName: JsonRead.stringOrNull(f('driverName')),
      enterLink: JsonRead.string(f('enterLink')),
      exitLink: JsonRead.string(f('exitLink')),
      amount: f('amount') == null ? null : JsonRead.number(f('amount')),
      remarks: JsonRead.string(f('remarks')),
    );
  }

  final int id;
  final String cNumberDisplay;
  final String saleDate;
  final int truckRefId;
  final String? truckName;
  final int driverRefId;
  final String? driverName;

  /// IN / OUT: the leg of the trip (`LeviEntry.EnterLink`).
  final String enterLink;

  /// 1ST / 2ND LINK: the crossing (`LeviEntry.ExitLink`).
  final String exitLink;
  final double? amount;
  final String remarks;

  @override
  List<Object?> get props => [id, cNumberDisplay, saleDate, truckRefId, truckName, driverRefId, driverName, enterLink, exitLink, amount, remarks];
}

/// The Levi form (`RTILeviEntryModal.tsx` `LeviFormState`).
class LeviForm extends Equatable {
  const LeviForm({
    required this.saleDate,
    this.entryType = '',
    this.link = '',
    this.truckRefId = '',
    this.driverRefId = '',
    this.amount = '',
    this.remarks = '',
  });

  final String saleDate;
  final String entryType;
  final String link;
  final String truckRefId;
  final String driverRefId;
  final String amount;
  final String remarks;

  LeviForm copyWith({String? saleDate, String? entryType, String? link, String? truckRefId, String? driverRefId, String? amount, String? remarks}) =>
      LeviForm(
        saleDate: saleDate ?? this.saleDate,
        entryType: entryType ?? this.entryType,
        link: link ?? this.link,
        truckRefId: truckRefId ?? this.truckRefId,
        driverRefId: driverRefId ?? this.driverRefId,
        amount: amount ?? this.amount,
        remarks: remarks ?? this.remarks,
      );

  @override
  List<Object?> get props => [saleDate, entryType, link, truckRefId, driverRefId, amount, remarks];
}

enum LeviListStatus { loading, ready, failed }

class LeviState extends Equatable {
  const LeviState({
    required this.form,
    this.entryId = 0,
    this.entryNumber = '',
    this.nextNumber = '',
    this.items = const [],
    this.entriesTotal,
    this.listStatus = LeviListStatus.loading,
    this.busy = false,
    this.attachments = const [],
    this.staged = const [],
    this.stagedDeletions = const {},
    this.message,
    this.messageSeq = 0,
    this.messageIsError = false,
  });

  final LeviForm form;

  /// The entry being edited; 0 while filing a new one.
  final int entryId;
  final String entryNumber;
  final String nextNumber;
  final List<LeviItem> items;
  final double? entriesTotal;
  final LeviListStatus listStatus;
  final bool busy;

  /// The saved entry's files (`fileName`, `path`).
  final List<Map<String, dynamic>> attachments;
  final List<File> staged;
  final Set<String> stagedDeletions;
  final String? message;
  final int messageSeq;
  final bool messageIsError;

  /// The number shown: the entry's own, or the one a new entry will get.
  String get documentNumber => entryId == 0 ? nextNumber : entryNumber;

  LeviItem? entryOfType(String type) =>
      items.where((i) => i.enterLink.trim().toUpperCase() == type.trim().toUpperCase()).firstOrNull;

  /// "Save IN" / "Update OUT" / "Saving…".
  String get saveLabel {
    if (busy) return 'Saving…';
    final type = form.entryType.isEmpty ? 'levi' : form.entryType;
    return entryId != 0 ? 'Update $type' : 'Save $type';
  }

  bool get hasPendingFiles => staged.isNotEmpty || stagedDeletions.isNotEmpty;

  /// "Total 50.00".
  String get amountTotalText => (entriesTotal ?? 0).toStringAsFixed(2);

  LeviState copyWith({
    LeviForm? form,
    int? entryId,
    String? entryNumber,
    String? nextNumber,
    List<LeviItem>? items,
    double? entriesTotal,
    LeviListStatus? listStatus,
    bool? busy,
    List<Map<String, dynamic>>? attachments,
    List<File>? staged,
    Set<String>? stagedDeletions,
  }) =>
      LeviState(
        form: form ?? this.form,
        entryId: entryId ?? this.entryId,
        entryNumber: entryNumber ?? this.entryNumber,
        nextNumber: nextNumber ?? this.nextNumber,
        items: items ?? this.items,
        entriesTotal: entriesTotal ?? this.entriesTotal,
        listStatus: listStatus ?? this.listStatus,
        busy: busy ?? this.busy,
        attachments: attachments ?? this.attachments,
        staged: staged ?? this.staged,
        stagedDeletions: stagedDeletions ?? this.stagedDeletions,
        message: message,
        messageSeq: messageSeq,
        messageIsError: messageIsError,
      );

  LeviState withMessage(String text, {bool error = false}) => LeviState(
        form: form,
        entryId: entryId,
        entryNumber: entryNumber,
        nextNumber: nextNumber,
        items: items,
        entriesTotal: entriesTotal,
        listStatus: listStatus,
        busy: busy,
        attachments: attachments,
        staged: staged,
        stagedDeletions: stagedDeletions,
        message: text,
        messageSeq: messageSeq + 1,
        messageIsError: error,
      );

  @override
  List<Object?> get props => [
        form, entryId, entryNumber, nextNumber, items, entriesTotal, listStatus, busy, attachments, staged,
        stagedDeletions, message, messageSeq, messageIsError,
      ];
}
