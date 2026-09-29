import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/session/app_session.dart';
import 'package:maleva/features/ir_report/domain/entities/ir_report.dart';
import 'package:maleva/features/ir_report/presentation/ir_permissions.dart';

class _Session implements AppSession {
  const _Session({required this.roleId, required this.employeeId});

  @override
  final int roleId;

  @override
  final int employeeId;

  @override
  int get companyId => 6;
}

void main() {
  IrReport reportBy(int? reporterId) => IrReport(
        id: 1,
        irDate: DateTime(2026, 9, 10),
        statusId: 1,
        description: 'Truck accident',
        departmentId: 1000,
        departmentName: 'TRANSPORTATION',
        reporterId: reporterId,
      );

  test('an admin may add, edit and delete any report', () {
    final permissions = IrPermissions.forSession(const _Session(roleId: 100, employeeId: 5));

    expect(permissions.canAdd, isTrue);
    expect(permissions.canEdit(reportBy(99)), isTrue);
    expect(permissions.canDelete(reportBy(99)), isTrue);
  });

  test('any other role may add, edit only its own reports, and never delete', () {
    final permissions = IrPermissions.forSession(const _Session(roleId: 1000, employeeId: 5));

    expect(permissions.canAdd, isTrue);
    expect(permissions.canEdit(reportBy(5)), isTrue);
    expect(permissions.canEdit(reportBy(99)), isFalse);
    expect(permissions.canEdit(reportBy(null)), isFalse);
    expect(permissions.canDelete(reportBy(5)), isFalse);
  });

  test('a user with no employee id cannot edit a report that has no author', () {
    final permissions = IrPermissions.forSession(const _Session(roleId: 1000, employeeId: 0));

    expect(permissions.canEdit(reportBy(null)), isFalse);
  });

  test('menu flags can take rights away but never add them', () {
    final admin = IrPermissions.forSession(const _Session(roleId: 200, employeeId: 5))
        .limitedTo(add: true, edit: false, delete: true);
    final staff = IrPermissions.forSession(const _Session(roleId: 1000, employeeId: 5))
        .limitedTo(add: true, edit: true, delete: true);

    expect(admin.canEdit(reportBy(5)), isFalse);
    expect(admin.canDelete(reportBy(5)), isTrue);
    expect(staff.canDelete(reportBy(5)), isFalse);
  });
}
