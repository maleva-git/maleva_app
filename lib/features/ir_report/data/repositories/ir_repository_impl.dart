import 'package:maleva/core/session/app_session.dart';
import 'package:maleva/core/utils/json_read.dart';

import '../../domain/entities/ir_draft.dart';
import '../../domain/entities/ir_filter.dart';
import '../../domain/entities/ir_list_result.dart';
import '../../domain/entities/ir_lookup.dart';
import '../../domain/entities/ir_report.dart';
import '../../domain/repositories/ir_repository.dart';
import '../datasources/ir_remote_data_source.dart';
import '../models/ir_json.dart';

class IrRepositoryImpl implements IrRepository {
  IrRepositoryImpl({required IrRemoteDataSource remote, required AppSession session})
      : _remote = remote,
        _session = session;

  final IrRemoteDataSource _remote;
  final AppSession _session;

  @override
  Future<IrListResult> search(IrFilter filter) async {
    final data = await _remote.search(IrJson.searchQuery(filter, companyId: _session.companyId));
    final items = JsonRead.listOfMaps(data['items']).map(IrJson.report).toList();
    return IrListResult(
      items: items,
      totalAmount: JsonRead.integer(data['totalAmount']),
      count: JsonRead.integer(data['count'], fallback: items.length),
    );
  }

  @override
  Future<IrReport> getById(int id) async => IrJson.report(await _remote.getById(id, _session.companyId));

  @override
  Future<IrReport> save(IrDraft draft) async =>
      IrJson.report(await _remote.save(IrJson.saveRequest(draft, companyId: _session.companyId)));

  @override
  Future<void> delete(int id) => _remote.delete(id, _session.companyId);

  @override
  Future<List<IrStatus>> statuses() async {
    final rows = await _remote.statuses(_session.companyId);
    return rows.map(IrJson.status).toList();
  }

  @override
  Future<IrLookups> lookups() async {
    final companyId = _session.companyId;
    // In parallel; Future.wait rethrows the first failure as it was thrown.
    final results = await Future.wait<List<Map<String, dynamic>>>([
      _remote.statuses(companyId),
      _remote.departments(),
      _remote.trucks(companyId),
      _remote.drivers(companyId),
      _remote.employees(companyId),
    ]);
    return IrLookups(
      statuses: results[0].map(IrJson.status).toList(),
      departments: results[1].map(IrJson.department).toList(),
      trucks: _sorted(results[2].map(IrJson.masterRow)),
      drivers: _sorted(results[3].map(IrJson.masterRow)),
      employees: _sorted(results[4].map(IrJson.employee)),
    );
  }

  static List<LookupOption> _sorted(Iterable<LookupOption> options) {
    return options.where((option) => option.id != 0).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }
}
