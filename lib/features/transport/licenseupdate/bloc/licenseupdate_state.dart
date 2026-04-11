

import 'package:intl/intl.dart';

abstract class LicenseUpdateState {}

class LicenseUpdateInitial extends LicenseUpdateState {}

class LicenseUpdateLoading extends LicenseUpdateState {}

class LicenseUpdateLoaded extends LicenseUpdateState {
  // ── Truck selector ────────────────────────────────────────────────────────
  final int    truckId;
  final String truckName; // display name in search field

  // ── Admin flag ────────────────────────────────────────────────────────────
  final bool admin; // true = DriverTruckRefId == 0

  // ── Truck text fields ─────────────────────────────────────────────────────
  final String truckNo;
  final String truckNo2;
  final String truckNameField;
  final String longitude;
  final String latitude;
  final String truckType;

  // ── Internal IDs ─────────────────────────────────────────────────────────
  final String cNumberDisplay;
  final int    cNumber;
  final int    active;

  // ── 12 expiry date + checkbox pairs ──────────────────────────────────────
  final String rotexMyExp;     final bool cbRotexMyExp;
  final String rotexSGExp;     final bool cbRotexSGExp;
  final String puspacomExp;    final bool cbPuspacomExp;
  final String rotexMyExp1;    final bool cbRotexMyExp1;
  final String rotexSGExp1;    final bool cbRotexSGExp1;
  final String puspacomExp1;   final bool cbPuspacomExp1;
  final String insuratnceExp;  final bool cbInsuratnceExp;
  final String bonamExp;       final bool cbBonamExp;
  final String apadExp;        final bool cbApadExp;
  final String serviceExp;     final bool cbServiceExp;
  final String alignmentExp;   final bool cbAlignmentExp;
  final String greeceExp;      final bool cbGreeceExp;

   LicenseUpdateLoaded({
    required this.truckId,
    required this.truckName,
    required this.admin,
    required this.truckNo,
    required this.truckNo2,
    required this.truckNameField,
    required this.longitude,
    required this.latitude,
    required this.truckType,
    required this.cNumberDisplay,
    required this.cNumber,
    required this.active,
    required this.rotexMyExp,    required this.cbRotexMyExp,
    required this.rotexSGExp,    required this.cbRotexSGExp,
    required this.puspacomExp,   required this.cbPuspacomExp,
    required this.rotexMyExp1,   required this.cbRotexMyExp1,
    required this.rotexSGExp1,   required this.cbRotexSGExp1,
    required this.puspacomExp1,  required this.cbPuspacomExp1,
    required this.insuratnceExp, required this.cbInsuratnceExp,
    required this.bonamExp,      required this.cbBonamExp,
    required this.apadExp,       required this.cbApadExp,
    required this.serviceExp,    required this.cbServiceExp,
    required this.alignmentExp,  required this.cbAlignmentExp,
    required this.greeceExp,     required this.cbGreeceExp,
  });

  static String _today() =>
      DateFormat('yyyy-MM-dd').format(DateTime.now());

  factory LicenseUpdateLoaded.empty({bool admin = false}) =>
      LicenseUpdateLoaded(
        truckId:       0,
        truckName:     '',
        admin:         admin,
        truckNo:       '',
        truckNo2:      '',
        truckNameField:'',
        longitude:     '',
        latitude:      '',
        truckType:     '',
        cNumberDisplay:'',
        cNumber:       0,
        active:        0,
        rotexMyExp:    _today(), cbRotexMyExp:    false,
        rotexSGExp:    _today(), cbRotexSGExp:    false,
        puspacomExp:   _today(), cbPuspacomExp:   false,
        rotexMyExp1:   _today(), cbRotexMyExp1:   false,
        rotexSGExp1:   _today(), cbRotexSGExp1:   false,
        puspacomExp1:  _today(), cbPuspacomExp1:  false,
        insuratnceExp: _today(), cbInsuratnceExp: false,
        bonamExp:      _today(), cbBonamExp:      false,
        apadExp:       _today(), cbApadExp:       false,
        serviceExp:    _today(), cbServiceExp:    false,
        alignmentExp:  _today(), cbAlignmentExp:  false,
        greeceExp:     _today(), cbGreeceExp:     false,
      );

  LicenseUpdateLoaded copyWith({
    int?    truckId,
    String? truckName,
    bool?   admin,
    String? truckNo,
    String? truckNo2,
    String? truckNameField,
    String? longitude,
    String? latitude,
    String? truckType,
    String? cNumberDisplay,
    int?    cNumber,
    int?    active,
    String? rotexMyExp,    bool? cbRotexMyExp,
    String? rotexSGExp,    bool? cbRotexSGExp,
    String? puspacomExp,   bool? cbPuspacomExp,
    String? rotexMyExp1,   bool? cbRotexMyExp1,
    String? rotexSGExp1,   bool? cbRotexSGExp1,
    String? puspacomExp1,  bool? cbPuspacomExp1,
    String? insuratnceExp, bool? cbInsuratnceExp,
    String? bonamExp,      bool? cbBonamExp,
    String? apadExp,       bool? cbApadExp,
    String? serviceExp,    bool? cbServiceExp,
    String? alignmentExp,  bool? cbAlignmentExp,
    String? greeceExp,     bool? cbGreeceExp,
  }) {
    return LicenseUpdateLoaded(
      truckId:        truckId        ?? this.truckId,
      truckName:      truckName      ?? this.truckName,
      admin:          admin          ?? this.admin,
      truckNo:        truckNo        ?? this.truckNo,
      truckNo2:       truckNo2       ?? this.truckNo2,
      truckNameField: truckNameField ?? this.truckNameField,
      longitude:      longitude      ?? this.longitude,
      latitude:       latitude       ?? this.latitude,
      truckType:      truckType      ?? this.truckType,
      cNumberDisplay: cNumberDisplay ?? this.cNumberDisplay,
      cNumber:        cNumber        ?? this.cNumber,
      active:         active         ?? this.active,
      rotexMyExp:    rotexMyExp    ?? this.rotexMyExp,
      cbRotexMyExp:  cbRotexMyExp  ?? this.cbRotexMyExp,
      rotexSGExp:    rotexSGExp    ?? this.rotexSGExp,
      cbRotexSGExp:  cbRotexSGExp  ?? this.cbRotexSGExp,
      puspacomExp:   puspacomExp   ?? this.puspacomExp,
      cbPuspacomExp: cbPuspacomExp ?? this.cbPuspacomExp,
      rotexMyExp1:   rotexMyExp1   ?? this.rotexMyExp1,
      cbRotexMyExp1: cbRotexMyExp1 ?? this.cbRotexMyExp1,
      rotexSGExp1:   rotexSGExp1   ?? this.rotexSGExp1,
      cbRotexSGExp1: cbRotexSGExp1 ?? this.cbRotexSGExp1,
      puspacomExp1:  puspacomExp1  ?? this.puspacomExp1,
      cbPuspacomExp1:cbPuspacomExp1?? this.cbPuspacomExp1,
      insuratnceExp: insuratnceExp ?? this.insuratnceExp,
      cbInsuratnceExp:cbInsuratnceExp??this.cbInsuratnceExp,
      bonamExp:      bonamExp      ?? this.bonamExp,
      cbBonamExp:    cbBonamExp    ?? this.cbBonamExp,
      apadExp:       apadExp       ?? this.apadExp,
      cbApadExp:     cbApadExp     ?? this.cbApadExp,
      serviceExp:    serviceExp    ?? this.serviceExp,
      cbServiceExp:  cbServiceExp  ?? this.cbServiceExp,
      alignmentExp:  alignmentExp  ?? this.alignmentExp,
      cbAlignmentExp:cbAlignmentExp?? this.cbAlignmentExp,
      greeceExp:     greeceExp     ?? this.greeceExp,
      cbGreeceExp:   cbGreeceExp   ?? this.cbGreeceExp,
    );
  }

  // ── Generic date getter by key ─────────────────────────────────────────────
  String dateByKey(String key) {
    switch (key) {
      case 'rotexMyExp':    return rotexMyExp;
      case 'rotexSGExp':    return rotexSGExp;
      case 'puspacomExp':   return puspacomExp;
      case 'rotexMyExp1':   return rotexMyExp1;
      case 'rotexSGExp1':   return rotexSGExp1;
      case 'puspacomExp1':  return puspacomExp1;
      case 'insuratnceExp': return insuratnceExp;
      case 'bonamExp':      return bonamExp;
      case 'apadExp':       return apadExp;
      case 'serviceExp':    return serviceExp;
      case 'alignmentExp':  return alignmentExp;
      case 'greeceExp':     return greeceExp;
      default:              return DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
  }

  bool cbByKey(String key) {
    switch (key) {
      case 'rotexMyExp':    return cbRotexMyExp;
      case 'rotexSGExp':    return cbRotexSGExp;
      case 'puspacomExp':   return cbPuspacomExp;
      case 'rotexMyExp1':   return cbRotexMyExp1;
      case 'rotexSGExp1':   return cbRotexSGExp1;
      case 'puspacomExp1':  return cbPuspacomExp1;
      case 'insuratnceExp': return cbInsuratnceExp;
      case 'bonamExp':      return cbBonamExp;
      case 'apadExp':       return cbApadExp;
      case 'serviceExp':    return cbServiceExp;
      case 'alignmentExp':  return cbAlignmentExp;
      case 'greeceExp':     return cbGreeceExp;
      default:              return false;
    }
  }

  // ── Update date/checkbox by key — returns updated state ───────────────────
  LicenseUpdateLoaded withDate(String key, String date) {
    switch (key) {
      case 'rotexMyExp':    return copyWith(rotexMyExp:    date);
      case 'rotexSGExp':    return copyWith(rotexSGExp:    date);
      case 'puspacomExp':   return copyWith(puspacomExp:   date);
      case 'rotexMyExp1':   return copyWith(rotexMyExp1:   date);
      case 'rotexSGExp1':   return copyWith(rotexSGExp1:   date);
      case 'puspacomExp1':  return copyWith(puspacomExp1:  date);
      case 'insuratnceExp': return copyWith(insuratnceExp: date);
      case 'bonamExp':      return copyWith(bonamExp:      date);
      case 'apadExp':       return copyWith(apadExp:       date);
      case 'serviceExp':    return copyWith(serviceExp:    date);
      case 'alignmentExp':  return copyWith(alignmentExp:  date);
      case 'greeceExp':     return copyWith(greeceExp:     date);
      default:              return this;
    }
  }

  LicenseUpdateLoaded withCb(String key, bool val) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    switch (key) {
      case 'rotexMyExp':    return copyWith(cbRotexMyExp:    val, rotexMyExp:    val ? rotexMyExp    : today);
      case 'rotexSGExp':    return copyWith(cbRotexSGExp:    val, rotexSGExp:    val ? rotexSGExp    : today);
      case 'puspacomExp':   return copyWith(cbPuspacomExp:   val, puspacomExp:   val ? puspacomExp   : today);
      case 'rotexMyExp1':   return copyWith(cbRotexMyExp1:   val, rotexMyExp1:   val ? rotexMyExp1   : today);
      case 'rotexSGExp1':   return copyWith(cbRotexSGExp1:   val, rotexSGExp1:   val ? rotexSGExp1   : today);
      case 'puspacomExp1':  return copyWith(cbPuspacomExp1:  val, puspacomExp1:  val ? puspacomExp1  : today);
      case 'insuratnceExp': return copyWith(cbInsuratnceExp: val, insuratnceExp: val ? insuratnceExp : today);
      case 'bonamExp':      return copyWith(cbBonamExp:      val, bonamExp:      val ? bonamExp      : today);
      case 'apadExp':       return copyWith(cbApadExp:       val, apadExp:       val ? apadExp       : today);
      case 'serviceExp':    return copyWith(cbServiceExp:    val, serviceExp:    val ? serviceExp    : today);
      case 'alignmentExp':  return copyWith(cbAlignmentExp:  val, alignmentExp:  val ? alignmentExp  : today);
      case 'greeceExp':     return copyWith(cbGreeceExp:     val, greeceExp:     val ? greeceExp     : today);
      default:              return this;
    }
  }
}

class LicenseUpdateError extends LicenseUpdateState {
  final String message;
  LicenseUpdateError(this.message);
}

class LicenseUpdateSaveSuccess extends LicenseUpdateState {}