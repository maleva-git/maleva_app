import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/models/shared/employee_details_model.dart';
import 'package:maleva/features/dashboard/common_tabs/employeemaster/bloc/employeemaster_bloc.dart';
import 'package:maleva/features/dashboard/common_tabs/employeemaster/bloc/employeemaster_event.dart';
import 'package:maleva/features/dashboard/common_tabs/employeemaster/bloc/employeemaster_state.dart';
import 'package:maleva/features/dashboard/common_tabs/employeemaster/data/employee_repository.dart';

class _FakeRepository extends EmployeeRepository {
  final saved = <EmployeeDetailsModel>[];

  @override
  Future<List<Map<String, dynamic>>> fetchRoles() async => [{'id': 200, 'name': 'ADMIN'}, {'id': 1000, 'name': 'TRANSPORTATION'}];

  @override
  Future<int> saveEmployee(EmployeeDetailsModel employee) async {
    saved.add(employee);
    return 21;
  }
}

/// A new employee must get a role: Java would otherwise make them SUPERADMIN.
void main() {
  test('the form loads the roles, refuses to save without one, saves with one', () async {
    final repo = _FakeRepository();
    final bloc = EmployeeMasterBloc.form(repository: repo);

    final loaded = await bloc.stream.firstWhere((s) => s is EmployeeFormState && s.roles.isNotEmpty) as EmployeeFormState;
    expect(loaded.roles.map((r) => r['name']), ['ADMIN', 'TRANSPORTATION']);

    bloc.add(const SaveEmployeeMasterEvent());
    final refused = await bloc.stream.firstWhere((s) => s is EmployeeError) as EmployeeError;
    expect(refused.message, 'Select a role');
    expect(repo.saved, isEmpty);

    bloc.add(const SelectRoleEvent(1000));
    await bloc.stream.firstWhere((s) => s is EmployeeFormState && s.employee.RoleId == 1000);
    bloc.add(const SaveEmployeeMasterEvent());
    await bloc.stream.firstWhere((s) => s is EmployeeSaveSuccess);
    expect(repo.saved.single.RoleId, 1000);

    await bloc.close();
  });
}
