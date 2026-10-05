import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/models/shared/employee_details_model.dart';

/// Employee Master reads and writes the Java employee (change employee-lookups-on-shared-java-api).
void main() {
  test('a Java row reads into the form model; the password starts blank', () {
    final m = EmployeeDetailsModel.fromJava({
      'id': 15, 'employeeName': 'ANNA', 'employeeType': 'ADMIN', 'gstNo': 'G1', 'mobileNo': '6012',
      'joiningDate': '2026-01-05', 'roleId': 200, 'active': 1, 'accountCode': 'EMP-3', 'employeecurrency': 'RM',
    });
    expect([m.Id, m.EmployeeName, m.EmployeeType, m.GSTNO, m.MobileNo, m.JoiningDate, m.RoleId, m.AccountCode, m.Employeecurrency],
        [15, 'ANNA', 'ADMIN', 'G1', '6012', '2026-01-05', 200, 'EMP-3', 'RM']);
    expect(m.Password, '');
  });

  test('the save row is the Java DTO: role sent, blanks as null, no account code or capabilities', () {
    final m = EmployeeDetailsModel(0, 'BEN', 'RM', 'SALES', MobileNo: '6019', JoiningDate: '2026-10-05', RoleId: 1000);
    final row = m.toJava();
    expect(row['id'], 0);
    expect(row['employeeName'], 'BEN');
    expect(row['employeeType'], 'SALES');
    expect(row['roleId'], 1000);
    expect(row['joiningDate'], '2026-10-05');
    expect(row['leavingDate'], isNull);
    expect(row['password'], '', reason: 'blank on an edit keeps the current password');
    expect(row.containsKey('accountCode'), isFalse);
    expect(row.containsKey('capabilityIds'), isFalse);
  });

  test('no role chosen is sent as no role', () {
    expect(EmployeeDetailsModel(0, 'BEN', 'RM', 'SALES').toJava()['roleId'], isNull);
  });
}
