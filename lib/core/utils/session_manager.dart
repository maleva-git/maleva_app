import 'local_storage_service.dart';

class SessionManager {
  final LocalStorageService _storage;

  SessionManager(this._storage);

  // Constants for keys
  static const String _keyToken = 'Tokenkey';
  static const String _keyEmpRefId = 'EmpRefId';
  static const String _keyCompanyId = 'Comid';
  static const String _keyCompanyName = 'CompanyName';
  static const String _keyDriverId = 'DriverId';
  static const String _keyRulesType = 'RulesType';
  static const String _keyTruckRefId = 'TruckRefId';
  static const String _keyTruckName = 'TruckName';

  // Token
  String get mobileToken => _storage.getString(_keyToken) ?? "";
  Future<void> setMobileToken(String token) => _storage.setString(_keyToken, token);

  // Employee Reference ID
  int get empRefId => _storage.getInt(_keyEmpRefId) ?? 0;
  Future<void> setEmpRefId(int id) => _storage.setInt(_keyEmpRefId, id);

  // Company ID
  int get companyId => _storage.getInt(_keyCompanyId) ?? 0;
  Future<void> setCompanyId(int id) => _storage.setInt(_keyCompanyId, id);

  // Company Name
  String get companyName => _storage.getString(_keyCompanyName) ?? "";
  Future<void> setCompanyName(String name) => _storage.setString(_keyCompanyName, name);

  // Driver ID
  int get driverId => _storage.getInt(_keyDriverId) ?? 0;
  Future<void> setDriverId(int id) => _storage.setInt(_keyDriverId, id);

  // Rules Type
  String get rulesType => _storage.getString(_keyRulesType) ?? "";
  Future<void> setRulesType(String type) => _storage.setString(_keyRulesType, type);

  // Truck Ref ID
  int get driverTruckRefId => _storage.getInt(_keyTruckRefId) ?? 0;
  Future<void> setDriverTruckRefId(int id) => _storage.setInt(_keyTruckRefId, id);

  // Truck Name
  String get driverTruckName => _storage.getString(_keyTruckName) ?? "";
  Future<void> setDriverTruckName(String name) => _storage.setString(_keyTruckName, name);

  // Clear Session
  Future<void> clearSession() async {
    await _storage.remove(_keyToken);
    await _storage.remove(_keyEmpRefId);
    await _storage.remove(_keyCompanyId);
    await _storage.remove(_keyCompanyName);
    await _storage.remove(_keyDriverId);
    await _storage.remove(_keyRulesType);
    await _storage.remove(_keyTruckRefId);
    await _storage.remove(_keyTruckName);
  }
}
