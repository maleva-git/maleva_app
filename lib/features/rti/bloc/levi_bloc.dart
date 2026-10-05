import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/files/attachments_api.dart';
import 'package:maleva/core/rti/levi_api.dart';
import 'package:maleva/features/rti/bloc/levi_state.dart';
import 'package:maleva/features/rti/models/rti_dates.dart';
import 'package:maleva/features/rti/models/rti_form.dart';

export 'levi_state.dart';

/// The RTI the Levi window files against (`RTILeviEntryModalProps`).
class LeviContext {
  const LeviContext({required this.rtiId, this.rtiNo = '', this.truckRefId = '', this.driverRefId = '', this.eLink = '', this.exLink = '', this.employeeRefId = 0});

  final int rtiId;
  final String rtiNo;
  final String truckRefId;
  final String driverRefId;
  final String eLink;
  final String exLink;
  final int employeeRefId;
}

sealed class LeviEvent {
  const LeviEvent();
}

class LeviOpened extends LeviEvent {
  const LeviOpened();
}

class LeviTypeSelected extends LeviEvent {
  const LeviTypeSelected(this.type);
  final String type;
}

class LeviEntryTypeChanged extends LeviEvent {
  const LeviEntryTypeChanged(this.type);
  final String type;
}

class LeviFormPatched extends LeviEvent {
  const LeviFormPatched(this.change);
  final LeviForm Function(LeviForm) change;
}

class LeviEditTapped extends LeviEvent {
  const LeviEditTapped(this.item);
  final LeviItem item;
}

class LeviSaveRequested extends LeviEvent {
  const LeviSaveRequested();
}

/// Delete, after the screen's confirm "Delete levi entry?" (decision Q-LEVIDEL).
class LeviDeleteRequested extends LeviEvent {
  const LeviDeleteRequested(this.item);
  final LeviItem item;
}

class LeviFilesAdded extends LeviEvent {
  const LeviFilesAdded(this.files);
  final List<File> files;
}

class LeviStagedFileRemoved extends LeviEvent {
  const LeviStagedFileRemoved(this.index);
  final int index;
}

class LeviAttachmentDeletionToggled extends LeviEvent {
  const LeviAttachmentDeletionToggled(this.fileName);
  final String fileName;
}

/// The Levi entry window of the RTI page (`R/components/RTILeviEntryModal.tsx`): the IN and
/// OUT slots, the form, its checks and save through the shared Levi API, and the RTI's list.
class LeviBloc extends Bloc<LeviEvent, LeviState> {
  LeviBloc({required LeviApi api, required AttachmentsApi attachments, required this.context})
      : _api = api,
        _files = attachments,
        super(LeviState(form: LeviForm(saleDate: RtiDates.today()))) {
    on<LeviOpened>(_onOpened);
    on<LeviTypeSelected>((e, emit) async {
      final existing = state.entryOfType(e.type);
      existing != null ? await _apply(existing, emit) : _startNew(e.type, emit);
    });
    on<LeviEntryTypeChanged>((e, emit) {
      _touched = true;
      emit(state.copyWith(form: state.form.copyWith(entryType: e.type, link: state.entryId != 0 ? state.form.link : _linkFor(e.type))));
    });
    on<LeviFormPatched>((e, emit) {
      _touched = true;
      emit(state.copyWith(form: e.change(state.form)));
    });
    on<LeviEditTapped>((e, emit) => _apply(e.item, emit));
    on<LeviSaveRequested>(_onSave);
    on<LeviDeleteRequested>(_onDelete);
    on<LeviFilesAdded>((e, emit) => emit(state.copyWith(staged: [...state.staged, ...e.files])));
    on<LeviStagedFileRemoved>((e, emit) => emit(state.copyWith(staged: [...state.staged]..removeAt(e.index))));
    on<LeviAttachmentDeletionToggled>((e, emit) {
      final next = {...state.stagedDeletions};
      next.contains(e.fileName) ? next.remove(e.fileName) : next.add(e.fileName);
      emit(state.copyWith(stagedDeletions: next));
    });
  }

  static const folder = 'LeviEntry';

  final LeviApi _api;
  final AttachmentsApi _files;
  final LeviContext context;
  bool _touched = false;
  bool _decided = false;
  Future<List<LeviItem>>? _pendingList;

  static String _norm(String? v) => (v ?? '').trim().toUpperCase();
  static String _asLink(String v) => RtiChoices.leviLinks.contains(_norm(v)) ? _norm(v) : '';
  String _linkFor(String type) => _norm(type) == 'IN' ? _asLink(context.eLink) : _asLink(context.exLink);

  LeviForm _blank(String type) => LeviForm(
        saleDate: RtiDates.today(),
        entryType: _norm(type),
        link: _linkFor(type),
        truckRefId: context.truckRefId,
        driverRefId: context.driverRefId,
      );

  Future<void> _apply(LeviItem item, Emitter<LeviState> emit) async {
    _touched = false;
    emit(state.copyWith(
      entryId: item.id,
      entryNumber: item.cNumberDisplay,
      form: LeviForm(
        saleDate: item.saleDate.length >= 10 ? item.saleDate.substring(0, 10) : (item.saleDate.isEmpty ? RtiDates.today() : item.saleDate),
        entryType: _norm(item.enterLink),
        link: _norm(item.exitLink),
        truckRefId: item.truckRefId != 0 ? '${item.truckRefId}' : '',
        driverRefId: item.driverRefId != 0 ? '${item.driverRefId}' : '',
        amount: item.amount == null ? '' : _amountText(item.amount!),
        remarks: item.remarks,
      ),
      staged: const [],
      stagedDeletions: const {},
      attachments: const [],
    ));
    await _loadFiles(item.id, emit);
  }

  static String _amountText(double v) => v == v.truncateToDouble() ? '${v.toInt()}' : '$v';

  void _startNew(String type, Emitter<LeviState> emit) {
    _touched = false;
    emit(state.copyWith(entryId: 0, entryNumber: '', form: _blank(type), staged: const [], stagedDeletions: const {}, attachments: const []));
  }

  Future<void> _loadFiles(int id, Emitter<LeviState> emit) async {
    try {
      final files = await _files.list(folder: folder, recordId: id);
      if (!emit.isDone && state.entryId == id) emit(state.copyWith(attachments: files));
    } catch (_) {}
  }

  Future<void> _refresh(Emitter<LeviState> emit) async {
    final future = _api.byRti(context.rtiId);
    final items = future.then((r) => [for (final i in r.items) LeviItem.fromJava(i)]);
    items.ignore();
    _pendingList = items;
    try {
      final r = await future;
      emit(state.copyWith(items: [for (final i in r.items) LeviItem.fromJava(i)], entriesTotal: r.entriesTotal, listStatus: LeviListStatus.ready));
    } catch (_) {
      emit(state.copyWith(listStatus: LeviListStatus.failed));
    }
  }

  Future<void> _onOpened(LeviOpened e, Emitter<LeviState> emit) async {
    _touched = false;
    _decided = false;
    emit(LeviState(form: _blank('IN'), listStatus: LeviListStatus.loading));
    unawaited(_api.nextNumber().then((n) {
      if (!emit.isDone) emit(state.copyWith(nextNumber: n));
    }).catchError((_) {}));
    if (context.rtiId == 0) {
      emit(state.copyWith(listStatus: LeviListStatus.ready));
      return;
    }
    await _refresh(emit);
    if (_decided || state.listStatus != LeviListStatus.ready) return;
    _decided = true;
    // what is on screen belongs to the user once they have typed
    if (_touched || state.items.isEmpty) return;
    final first = state.entryOfType('IN') ?? state.entryOfType('OUT') ?? state.items.first;
    await _apply(first, emit);
  }

  Future<void> _onSave(LeviSaveRequested e, Emitter<LeviState> emit) async {
    if (state.busy) return;
    final f = state.form;
    String? refuse;
    if (_api.companyId == 0) {
      refuse = 'Company not found';
    } else if (context.rtiId == 0) {
      refuse = 'Save the RTI first';
    } else if (f.entryType.isEmpty) {
      refuse = 'Choose IN or OUT';
    } else if (f.truckRefId.isEmpty) {
      refuse = 'Select a truck';
    } else if (f.driverRefId.isEmpty) {
      refuse = 'Select a driver';
    } else if (f.amount.trim().isEmpty || num.tryParse(f.amount.trim()) == null) {
      refuse = 'Enter an amount';
    } else if (num.parse(f.amount.trim()) < 0) {
      refuse = 'Amount must not be negative';
    }
    if (refuse != null) return emit(state.withMessage(refuse, error: true));

    var filed = state.items;
    if (state.listStatus == LeviListStatus.loading) {
      try {
        filed = await (_pendingList ?? Future.value(const <LeviItem>[]));
      } catch (_) {
        filed = const [];
      }
    }
    final clash = filed.where((i) => _norm(i.enterLink) == _norm(f.entryType)).firstOrNull;
    if (state.entryId == 0 && clash != null) {
      emit(state.copyWith(entryId: clash.id, entryNumber: clash.cNumberDisplay)
          .withMessage('This RTI already has an ${f.entryType} levi (${clash.cNumberDisplay}). Press Save again to update it.', error: true));
      return;
    }

    final request = <String, dynamic>{
      if (state.entryId != 0) 'id': state.entryId,
      'companyRefId': _api.companyId,
      'truckRefId': int.tryParse(f.truckRefId) ?? num.tryParse(f.truckRefId),
      'driverRefId': int.tryParse(f.driverRefId) ?? num.tryParse(f.driverRefId),
      'rtiRefId': context.rtiId,
      if (context.employeeRefId != 0) 'employeeRefId': context.employeeRefId,
      'saleDate': f.saleDate,
      'amount': num.parse(f.amount.trim()),
      if (f.remarks.trim().isNotEmpty) 'remarks': f.remarks.trim(),
      if (f.entryType.isNotEmpty) 'enterLink': f.entryType,
      if (f.link.isNotEmpty) 'exitLink': f.link,
    };
    emit(state.copyWith(busy: true));
    final Map<String, dynamic> saved;
    try {
      saved = await _api.save(request);
    } catch (err) {
      final text = '$err'.trim();
      return emit(state.copyWith(busy: false).withMessage(text.isEmpty ? 'Could not save the levi entry' : text, error: true));
    }
    final savedId = LeviItem.fromJava(saved).id;
    final savedNo = LeviItem.fromJava(saved).cNumberDisplay;
    emit(state.withMessage('Levi entries $savedNo saved'.trim()));
    var files = state.attachments;
    try {
      if (state.stagedDeletions.isNotEmpty) {
        files = await _files.delete(state.stagedDeletions.toList(), folder: folder, recordId: savedId);
      }
      if (state.staged.isNotEmpty) files = await _files.add(state.staged, folder: folder, recordId: savedId);
    } catch (err) {
      emit(state.withMessage('$err', error: true));
    }
    emit(state.copyWith(busy: false, entryId: savedId, entryNumber: savedNo, staged: const [], stagedDeletions: const {}, attachments: files));
    await _refresh(emit);
  }

  Future<void> _onDelete(LeviDeleteRequested e, Emitter<LeviState> emit) async {
    if (_api.companyId == 0 || state.busy) return;
    emit(state.copyWith(busy: true));
    try {
      await _api.delete(e.item.id);
      emit(state.copyWith(busy: false).withMessage('levi entry deleted'));
      if (e.item.id == state.entryId) _startNew(state.form.entryType.isEmpty ? 'IN' : state.form.entryType, emit);
    } catch (err) {
      final text = '$err'.trim();
      emit(state.copyWith(busy: false).withMessage(text.isEmpty ? 'Could not delete the levi entry' : text, error: true));
    }
    await _refresh(emit);
  }
}
