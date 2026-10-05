import 'package:equatable/equatable.dart';
import 'package:maleva/features/rti/models/rti_dates.dart';

/// The RTI form's own values (`R/types/rti.ts` `RTIFormState`, `R/model/rti.initialState.ts`),
/// with the web's text values: `sleeping` YES/NO, `exitYN` / `emptyDeliveryYN`
/// NO / EMPTY 80 / EMPTY 50, `manpw` NO / 1 / 2, links '' / 1ST LINK / 2ND LINK. Driver
/// and truck ids are text, as the web's selects hold them. The agent fields are left out:
/// React loads them but never shows or saves them (K19).
class RtiForm extends Equatable {
  const RtiForm({
    this.rtiNo = '',
    required this.rtiDate,
    this.driverRefId = '',
    this.outsideDriver = '',
    this.truckRefId = '',
    this.outsideTruck = '',
    this.eLink = '',
    this.exLink = '',
    this.sleeping = 'NO',
    this.exitYN = 'NO',
    this.emptyDeliveryYN = 'NO',
    this.pickup = 'NO',
    this.addDrop = 'NO',
    this.manpw = 'NO',
    this.pickupCount = '',
    this.dropCount = '',
    this.destination = '',
    this.sealBy = '',
    this.breakSealBy = '',
    this.remarks = '',
    this.comments = '',
    this.punctuality = false,
    this.documentSub = false,
    this.pckHandling = false,
    this.editId = 0,
  });

  /// `createInitialRTIState`: today, every charge off.
  factory RtiForm.initial() => RtiForm(rtiDate: RtiDates.today());

  final String rtiNo;
  final String rtiDate;
  final String driverRefId;
  final String outsideDriver;
  final String truckRefId;
  final String outsideTruck;
  final String eLink;
  final String exLink;
  final String sleeping;
  final String exitYN;
  final String emptyDeliveryYN;
  final String pickup;
  final String addDrop;
  final String manpw;
  final String pickupCount;
  final String dropCount;
  final String destination;
  final String sealBy;
  final String breakSealBy;
  final String remarks;
  final String comments;
  final bool punctuality;
  final bool documentSub;
  final bool pckHandling;

  /// The saved RTI's id; 0 for a new one.
  final int editId;

  bool get isEdit => editId > 0;

  RtiForm copyWith({
    String? rtiNo,
    String? rtiDate,
    String? driverRefId,
    String? outsideDriver,
    String? truckRefId,
    String? outsideTruck,
    String? eLink,
    String? exLink,
    String? sleeping,
    String? exitYN,
    String? emptyDeliveryYN,
    String? pickup,
    String? addDrop,
    String? manpw,
    String? pickupCount,
    String? dropCount,
    String? destination,
    String? sealBy,
    String? breakSealBy,
    String? remarks,
    String? comments,
    bool? punctuality,
    bool? documentSub,
    bool? pckHandling,
    int? editId,
  }) =>
      RtiForm(
        rtiNo: rtiNo ?? this.rtiNo,
        rtiDate: rtiDate ?? this.rtiDate,
        driverRefId: driverRefId ?? this.driverRefId,
        outsideDriver: outsideDriver ?? this.outsideDriver,
        truckRefId: truckRefId ?? this.truckRefId,
        outsideTruck: outsideTruck ?? this.outsideTruck,
        eLink: eLink ?? this.eLink,
        exLink: exLink ?? this.exLink,
        sleeping: sleeping ?? this.sleeping,
        exitYN: exitYN ?? this.exitYN,
        emptyDeliveryYN: emptyDeliveryYN ?? this.emptyDeliveryYN,
        pickup: pickup ?? this.pickup,
        addDrop: addDrop ?? this.addDrop,
        manpw: manpw ?? this.manpw,
        pickupCount: pickupCount ?? this.pickupCount,
        dropCount: dropCount ?? this.dropCount,
        destination: destination ?? this.destination,
        sealBy: sealBy ?? this.sealBy,
        breakSealBy: breakSealBy ?? this.breakSealBy,
        remarks: remarks ?? this.remarks,
        comments: comments ?? this.comments,
        punctuality: punctuality ?? this.punctuality,
        documentSub: documentSub ?? this.documentSub,
        pckHandling: pckHandling ?? this.pckHandling,
        editId: editId ?? this.editId,
      );

  @override
  List<Object?> get props => [
        rtiNo, rtiDate, driverRefId, outsideDriver, truckRefId, outsideTruck, eLink, exLink, sleeping, exitYN,
        emptyDeliveryYN, pickup, addDrop, manpw, pickupCount, dropCount, destination, sealBy, breakSealBy,
        remarks, comments, punctuality, documentSub, pckHandling, editId,
      ];
}

/// The fixed choices of the RTI form (`R/model/rti.schema.ts:15-25`, `R/constants/*.ts`,
/// `FE/features/pass-entry/model/passLinkOptions.ts`).
abstract final class RtiChoices {
  static const links = ['', '1ST LINK', '2ND LINK'];
  static const yesNo = ['YES', 'NO'];
  static const exit = ['NO', 'EMPTY 80', 'EMPTY 50'];
  static const manpower = ['NO', '1', '2'];

  /// Route activity job types: (value, label).
  static const jobTypes = [
    ('SEAL', 'SEAL'),
    ('BREAK_SEAL', 'BREAK SEAL'),
    ('SEAL_AND_BREAK', 'SEAL AND BREAK'),
    ('K1 Clearance', 'K1 Clearance'),
    ('K2 Clearance', 'K2 Clearance'),
    ('K3 Clearance', 'K3 Clearance'),
    ('K8 Clearance', 'K8 Clearance'),
  ];

  static const routeLocations = [
    'BANGI', 'JOHOR', 'KLANG', 'KLIA', 'MALACCA', 'NEW ASIA', 'NILAI', 'NORTHPORT', 'PASIR GUDANG', 'PKFZ', 'PTP',
    'SELANGOR', 'SHAH ALAM', 'SINGAPORE', 'SOUTHPORT', 'WESTPORT',
  ];

  /// Levi: the leg of the trip (`EnterLink`) and the crossing it used (`ExitLink`).
  static const leviEntryTypes = ['IN', 'OUT'];
  static const leviLinks = ['1ST LINK', '2ND LINK'];

  static String jobTypeLabel(String value) =>
      jobTypes.firstWhere((t) => t.$1 == value, orElse: () => (value, value)).$2;
}
