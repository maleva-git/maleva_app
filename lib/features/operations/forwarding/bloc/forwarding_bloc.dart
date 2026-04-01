import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/models/model.dart';
import 'forwarding_event.dart';
import 'forwarding_state.dart';



class FWUpdateBloc extends Bloc<FWUpdateEvent, FWUpdateState> {
  FWUpdateBloc() : super(FWUpdateInitial()) {
    on<FWUpdateStarted>(_onStarted);
    on<FWUpdateTabChanged>(_onTabChanged);
    on<FWUpdateSmkTextChanged>(_onSmkTextChanged);
    on<FWUpdateSmkSuggestionSelected>(_onSmkSuggestionSelected);
    on<FWUpdateOverlayDismissed>(_onOverlayDismissed);
    on<FWUpdateSealEmpChanged>(_onSealEmpChanged);
    on<FWUpdateSealEmpCleared>(_onSealEmpCleared);
    on<FWUpdateBreakEmpChanged>(_onBreakEmpChanged);
    on<FWUpdateBreakEmpCleared>(_onBreakEmpCleared);
    on<FWUpdateExRefChanged>(_onExRefChanged);
    on<FWUpdateImageUploadToggled>(_onImageUploadToggled);
    on<FWUpdateImagePicked>(_onImagePicked);
    on<FWUpdateImageDeleted>(_onImageDeleted);
    on<FWUpdateSaveRequested>(_onSaveRequested);
  }

  // ── Default loaded state ────────────────────────────────────────────────────
  FWUpdateLoaded _defaultLoaded() =>  FWUpdateLoaded(
    currentTab:  0,
    saleOrderId: 0,
    tab1:        FWTabData(smkText: '', exRef: '', sealEmpId: 0, sealEmpName: '', breakEmpId: 0, breakEmpName: '', imageUploadEnabled: false, images: [], suggestions: []),
    tab2:        FWTabData(smkText: '', exRef: '', sealEmpId: 0, sealEmpName: '', breakEmpId: 0, breakEmpName: '', imageUploadEnabled: false, images: [], suggestions: []),
    tab3:        FWTabData(smkText: '', exRef: '', sealEmpId: 0, sealEmpName: '', breakEmpId: 0, breakEmpName: '', imageUploadEnabled: false, images: [], suggestions: []),
  );

  // ── Startup ─────────────────────────────────────────────────────────────────
  Future<void> _onStarted(
      FWUpdateStarted event, Emitter<FWUpdateState> emit) async {
    emit(FWUpdateLoading());
    try {
      await OnlineApi.GetJobNoForwarding(null, 3);
      emit(_defaultLoaded());
    } catch (e) {
      emit(FWUpdateError(e.toString()));
    }
  }

  // ── Tab ──────────────────────────────────────────────────────────────────────
  void _onTabChanged(FWUpdateTabChanged event, Emitter<FWUpdateState> emit) {
    if (state is FWUpdateLoaded) {
      emit((state as FWUpdateLoaded).copyWith(currentTab: event.tabIndex));
    }
  }

  // ── SMK autocomplete ─────────────────────────────────────────────────────────
  void _onSmkTextChanged(
      FWUpdateSmkTextChanged event, Emitter<FWUpdateState> emit) {
    if (state is! FWUpdateLoaded) return;
    final s = state as FWUpdateLoaded;
    final query = event.text.trim();

    List<dynamic> filtered = [];
    if (query.isNotEmpty) {
      final smkKey = event.type == 1
          ? 'ForwardingSMKNo'
          : event.type == 2
          ? 'ForwardingSMKNo2'
          : 'ForwardingSMKNo3';
      filtered = objfun.JobNoList
          .where((e) => e[smkKey].toString().contains(query))
          .toList();
    }

    final updated = s.tabByType(event.type).copyWith(
      smkText:     query,
      suggestions: filtered,
    );
    emit(s.withTab(event.type, updated));
  }

  // ── SMK suggestion selected ───────────────────────────────────────────────────
  Future<void> _onSmkSuggestionSelected(
      FWUpdateSmkSuggestionSelected event,
      Emitter<FWUpdateState> emit) async {
    if (state is! FWUpdateLoaded) return;
    final s = state as FWUpdateLoaded;

    emit(FWUpdateLoading());
    try {
      // Load forwarding data for selected job
      await OnlineApi.EditSalesOrder(null, event.saleOrderId, 0);
      await OnlineApi.SelectEmployee(null, '', 'Operation');

      final master = objfun.SaleEditMasterList;
      int newSaleOrderId = event.saleOrderId;

      // ── Tab 1 specific data ────────────────────────────────────────────────
      FWTabData buildTabFromMaster(int type, FWTabData existing) {
        if (master.isEmpty) return existing;
        final m = master[0];

        String exRef = '';
        int sealId = 0;
        String sealName = '';
        int breakId = 0;
        String breakName = '';

        if (type == 1) {
          exRef = m['ForwardingExitRef'] ?? '';
          sealId = m['SealbyRefid'] ?? 0;
          breakId = m['SealbreakbyRefid'] ?? 0;
        } else if (type == 2) {
          exRef = m['ForwardingExitRef2'] ?? '';
          sealId = m['SealbyRefid2'] ?? 0;
          breakId = m['SealbreakbyRefid2'] ?? 0;
        } else {
          exRef = m['ForwardingExitRef3'] ?? '';
          sealId = m['SealbyRefid3'] ?? 0;
          breakId = m['SealbreakbyRefid3'] ?? 0;
        }

        if (sealId != 0) {
          final emp = objfun.EmployeeList
              .where((e) => e.Id == sealId)
              .toList();
          if (emp.isNotEmpty) sealName = emp[0].AccountName;
        }
        if (breakId != 0) {
          final emp = objfun.EmployeeList
              .where((e) => e.Id == breakId)
              .toList();
          if (emp.isNotEmpty) breakName = emp[0].AccountName;
        }

        return existing.copyWith(
          smkText:     event.type == type ? event.smkText : existing.smkText,
          exRef:       exRef,
          sealEmpId:   sealId,
          sealEmpName: sealName,
          breakEmpId:  breakId,
          breakEmpName: breakName,
          suggestions: [],
        );
      }

      // Load images for the selected tab
      final smkKey = event.type == 1
          ? event.smkText
          : event.type == 2
          ? event.smkText
          : event.smkText;

      final imageDir =
          '/Upload/${objfun.Comid}/SalesOrder/${event.saleOrderId}/$smkKey/';
      final header = {'Content-Type': 'application/json; charset=UTF-8'};
      final imgResult = await objfun.apiAllinoneSelectArray(
          '${objfun.apiGetimage}$imageDir', null, header, null);

      List<String> fetchedImages = [];
      if (imgResult != '' && imgResult.length != 0) {
        for (var img in imgResult) {
          fetchedImages.add(img.toString());
        }
      }

      final updatedTab = buildTabFromMaster(event.type,
          s.tabByType(event.type))
          .copyWith(
        smkText:     event.smkText,
        suggestions: [],
        images:      fetchedImages,
      );

      var newState = s.copyWith(saleOrderId: newSaleOrderId);
      newState = newState.withTab(event.type, updatedTab);

      // Also update other tabs with master data (exRef, emp)
      for (int t = 1; t <= 3; t++) {
        if (t != event.type) {
          newState = newState.withTab(
              t, buildTabFromMaster(t, newState.tabByType(t)));
        }
      }

      emit(newState);
    } catch (e) {
      emit(FWUpdateError(e.toString()));
    }
  }

  // ── Overlay dismissed ────────────────────────────────────────────────────────
  void _onOverlayDismissed(
      FWUpdateOverlayDismissed event, Emitter<FWUpdateState> emit) {
    if (state is! FWUpdateLoaded) return;
    final s = state as FWUpdateLoaded;
    for (int t = 1; t <= 3; t++) {
      final tab = s.tabByType(t);
      if (tab.suggestions.isNotEmpty) {
        final newS = s.withTab(t, tab.copyWith(suggestions: []));
        emit(newS);
        return;
      }
    }
  }

  // ── Seal Employee ─────────────────────────────────────────────────────────────
  void _onSealEmpChanged(
      FWUpdateSealEmpChanged event, Emitter<FWUpdateState> emit) {
    if (state is! FWUpdateLoaded) return;
    final s = state as FWUpdateLoaded;
    final updated = s.tabByType(event.type).copyWith(
        sealEmpId: event.empId, sealEmpName: event.empName);
    emit(s.withTab(event.type, updated));
  }

  void _onSealEmpCleared(
      FWUpdateSealEmpCleared event, Emitter<FWUpdateState> emit) {
    if (state is! FWUpdateLoaded) return;
    final s = state as FWUpdateLoaded;
    final updated =
    s.tabByType(event.type).copyWith(sealEmpId: 0, sealEmpName: '');
    emit(s.withTab(event.type, updated));
  }

  // ── Break Employee ────────────────────────────────────────────────────────────
  void _onBreakEmpChanged(
      FWUpdateBreakEmpChanged event, Emitter<FWUpdateState> emit) {
    if (state is! FWUpdateLoaded) return;
    final s = state as FWUpdateLoaded;
    final updated = s.tabByType(event.type).copyWith(
        breakEmpId: event.empId, breakEmpName: event.empName);
    emit(s.withTab(event.type, updated));
  }

  void _onBreakEmpCleared(
      FWUpdateBreakEmpCleared event, Emitter<FWUpdateState> emit) {
    if (state is! FWUpdateLoaded) return;
    final s = state as FWUpdateLoaded;
    final updated =
    s.tabByType(event.type).copyWith(breakEmpId: 0, breakEmpName: '');
    emit(s.withTab(event.type, updated));
  }

  // ── EX Ref ────────────────────────────────────────────────────────────────────
  void _onExRefChanged(
      FWUpdateExRefChanged event, Emitter<FWUpdateState> emit) {
    if (state is! FWUpdateLoaded) return;
    final s = state as FWUpdateLoaded;
    final updated = s.tabByType(event.type).copyWith(exRef: event.value);
    emit(s.withTab(event.type, updated));
  }

  // ── Image upload toggle ───────────────────────────────────────────────────────
  void _onImageUploadToggled(
      FWUpdateImageUploadToggled event, Emitter<FWUpdateState> emit) {
    if (state is! FWUpdateLoaded) return;
    final s = state as FWUpdateLoaded;
    final updated = s
        .tabByType(event.type)
        .copyWith(imageUploadEnabled: event.value);
    emit(s.withTab(event.type, updated));
  }

  // ── Image picked ──────────────────────────────────────────────────────────────
  void _onImagePicked(FWUpdateImagePicked event, Emitter<FWUpdateState> emit) {
    if (state is! FWUpdateLoaded) return;
    final s = state as FWUpdateLoaded;
    final tab = s.tabByType(event.type);
    final newImages = List<String>.from(tab.images)..add(event.imageUrl);
    emit(s.withTab(event.type, tab.copyWith(images: newImages)));
  }

  // ── Image deleted ─────────────────────────────────────────────────────────────
  Future<void> _onImageDeleted(
      FWUpdateImageDeleted event, Emitter<FWUpdateState> emit) async {
    if (state is! FWUpdateLoaded) return;
    final s = state as FWUpdateLoaded;
    final tab = s.tabByType(event.type);

    emit(FWUpdateLoading());
    try {
      final smkUpload = tab.smkText;
      final networkImg = tab.images[event.index];
      final header = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Comid': objfun.Comid.toString(),
        'Id': s.saleOrderId.toString(),
        'FolderName': 'SalesOrder',
        'FileName':
        '/Upload/${objfun.Comid}/SalesOrder/${s.saleOrderId}/$smkUpload/$networkImg',
        'SubFolderName': smkUpload,
      };

      final resultData = await objfun.apiAllinoneSelectArray(
          objfun.apiDeleteimage, null, header, null);

      if (resultData != '') {
        final value = ResponseViewModel.fromJson(resultData);
        if (value.IsSuccess == true) {
          final newImages = List<String>.from(tab.images)
            ..removeAt(event.index);
          emit(s.withTab(event.type, tab.copyWith(images: newImages)));
          return;
        }
      }
      emit(s); // revert on fail
    } catch (e) {
      emit(FWUpdateError(e.toString()));
    }
  }

  // ── Save / Update ─────────────────────────────────────────────────────────────
  Future<void> _onSaveRequested(
      FWUpdateSaveRequested event, Emitter<FWUpdateState> emit) async {
    if (state is! FWUpdateLoaded) return;
    final s = state as FWUpdateLoaded;

    // Validation: only one SMK should be filled
    final smk1 = s.tab1.smkText.isNotEmpty;
    final smk2 = s.tab2.smkText.isNotEmpty;
    final smk3 = s.tab3.smkText.isNotEmpty;

    if (!smk1 && !smk2 && !smk3) return; // toast handled by UI
    if ((smk1 && smk2) || (smk1 && smk3) || (smk2 && smk3)) return;

    emit(FWUpdateLoading());
    try {
      final master = {
        'Id':                 s.saleOrderId,
        'Comid':              objfun.Comid,
        'Jobid':              0,
        'EmployeeRefId':      objfun.EmpRefId == 0 ? null : objfun.EmpRefId,
        'SealbyRefid':        s.tab1.sealEmpId,
        'SealbreakbyRefid':   s.tab1.breakEmpId,
        'SealbyRefid2':       s.tab2.sealEmpId,
        'SealbreakbyRefid2':  s.tab2.breakEmpId,
        'SealbyRefid3':       s.tab3.sealEmpId,
        'SealbreakbyRefid3':  s.tab3.breakEmpId,
        'ForwardingEnterRef':  '',
        'ForwardingExitRef':  s.tab1.exRef,
        'ForwardingEnterRef2': '',
        'ForwardingExitRef2': s.tab2.exRef,
        'ForwardingEnterRef3': '',
        'ForwardingExitRef3': s.tab3.exRef,
      };
      final header = {'Content-Type': 'application/json; charset=UTF-8'};

      final resultData = await objfun.apiAllinoneSelectArray(
          objfun.apiUpdateForwarding, master, header, null);

      if (resultData != '') {
        final value = ResponseViewModel.fromJson(resultData);
        if (value.IsSuccess == true) {
          emit(FWUpdateSaveSuccess());
          emit(_defaultLoaded()); // reset after success
          return;
        }
      }
      emit(s); // revert
    } catch (e) {
      emit(FWUpdateError(e.toString()));
    }
  }
}