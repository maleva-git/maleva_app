import '../entities/ir_draft.dart';
import '../entities/ir_filter.dart';
import '../entities/ir_list_result.dart';
import '../entities/ir_lookup.dart';
import '../entities/ir_report.dart';

/// Everything the IR screens need from the backend. Blocs depend on this
/// interface only, so the transport (today the .NET IRApp API) can change
/// without touching them, and tests replace it with a mock.
///
/// Every method throws on failure; the message of the thrown error is fit to
/// show the user.
abstract interface class IrRepository {
  Future<IrListResult> search(IrFilter filter);

  Future<IrReport> getById(int id);

  /// Inserts when the draft is new, updates otherwise. Returns the saved row.
  Future<IrReport> save(IrDraft draft);

  /// Soft delete.
  Future<void> delete(int id);

  Future<List<IrStatus>> statuses();

  /// Statuses, departments, trucks, drivers and employees for the form.
  Future<IrLookups> lookups();
}
