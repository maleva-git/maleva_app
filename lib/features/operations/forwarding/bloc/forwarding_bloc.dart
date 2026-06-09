import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/fwupdate_repository.dart';
import 'forwarding_event.dart';
import 'forwarding_state.dart';

class FWUpdateBloc extends Bloc<FWUpdateEvent, FWUpdateState> {
  final FWUpdateRepository repository;

  List<dynamic> _jobNoList = [];
  List<dynamic> _employeeList = [];

  FWUpdateBloc({required this.repository}) : super(FWUpdateInitial()) {
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

  FWUpdateLoaded _defaultLoaded() => FWUpdateLoaded(
    currentTab: 0, saleOrderId: 0,
    tab1: FWTabData(smkText: '', exRef: '', sealEmpId: 0, sealEmpName: '', breakEmpId: 0, breakEmpName: '', imageUploadEnabled: false, images: [], suggestions: []),
    tab2: FWTabData(smkText: '', exRef: '', sealEmpId: 0, sealEmpName: '', breakEmpId: 0, breakEmpName: '', imageUploadEnabled: false, images: [], suggestions: []),
    tab3: FWTabData(smkText: '', exRef: '', sealEmpId: 0, sealEmpName: '', breakEmpId: 0, breakEmpName: '', imageUploadEnabled: false, images: [], suggestions: []),
  );

  Future<void> _onStarted(FWUpdateStarted event, Emitter<FWUpdateState> emit) async {
    emit(FWUpdateLoading());
    try {
      _jobNoList = await repository.fetchJobNoList();
      emit(_defaultLoaded());
    } catch (e) {
      emit(FWUpdateError(e.toString()));
    }
  }

  void _onTabChanged(FWUpdateTabChanged event, Emitter<FWUpdateState> emit) {
    if (state is FWUpdateLoaded) emit((state as FWUpdateLoaded).copyWith(currentTab: event.tabIndex));
  }

  // ---------------------------------------------------------
  // FIXED METHOD: SMK Text Changed
  // ---------------------------------------------------------
  void _onSmkTextChanged(FWUpdateSmkTextChanged event, Emitter<FWUpdateState> emit) {
    if (state is! FWUpdateLoaded) return;
    final s = state as FWUpdateLoaded;
    final query = event.text.trim();

    List<dynamic> filtered = [];
    if (query.isNotEmpty) {
      final smkKey = event.type == 1 ? 'ForwardingSMKNo' : event.type == 2 ? 'ForwardingSMKNo2' : 'ForwardingSMKNo3';

      filtered = _jobNoList.where((e) {
        // Safe string conversion for numbers/nulls
        final smkValue = (e[smkKey] ?? '').toString();
        return smkValue.contains(query);
      }).toList();
    }

    // Using event.text instead of query to avoid cursor jumping issues
    final updated = s.tabByType(event.type).copyWith(smkText: event.text, suggestions: filtered);
    emit(s.withTab(event.type, updated));
  }

  Future<void> _onSmkSuggestionSelected(FWUpdateSmkSuggestionSelected event, Emitter<FWUpdateState> emit) async {
    if (state is! FWUpdateLoaded) return;
    final s = state as FWUpdateLoaded;

    emit(FWUpdateLoading());
    try {
      final data = await repository.fetchJobDetailsAndEmployees(event.saleOrderId);
      final master = data['master'];
      _employeeList = data['employees'];

      int newSaleOrderId = event.saleOrderId;

      FWTabData buildTabFromMaster(int type, FWTabData existing) {
        if (master == null) return existing;

        String exRef = '';
        int sealId = 0;
        int breakId = 0;

        if (type == 1) {
          exRef = master['ForwardingExitRef'] ?? '';
          sealId = master['SealbyRefid'] ?? 0;
          breakId = master['SealbreakbyRefid'] ?? 0;
        } else if (type == 2) {
          exRef = master['ForwardingExitRef2'] ?? '';
          sealId = master['SealbyRefid2'] ?? 0;
          breakId = master['SealbreakbyRefid2'] ?? 0;
        } else {
          exRef = master['ForwardingExitRef3'] ?? '';
          sealId = master['SealbyRefid3'] ?? 0;
          breakId = master['SealbreakbyRefid3'] ?? 0;
        }

        String sealName = '';
        String breakName = '';

        if (sealId != 0) {
          final emp = _employeeList.where((e) => e['Id'] == sealId).toList();
          if (emp.isNotEmpty) sealName = emp[0]['AccountName'] ?? '';
        }
        if (breakId != 0) {
          final emp = _employeeList.where((e) => e['Id'] == breakId).toList();
          if (emp.isNotEmpty) breakName = emp[0]['AccountName'] ?? '';
        }

        return existing.copyWith(
          smkText: event.type == type ? event.smkText : existing.smkText,
          exRef: exRef,
          sealEmpId: sealId,
          sealEmpName: sealName,
          breakEmpId: breakId,
          breakEmpName: breakName,
          suggestions: [],
        );
      }

      final fetchedImages = await repository.fetchImages(event.saleOrderId, event.smkText);

      final updatedTab = buildTabFromMaster(event.type, s.tabByType(event.type)).copyWith(
        smkText: event.smkText,
        suggestions: [],
        images: fetchedImages,
      );

      var newState = s.copyWith(saleOrderId: newSaleOrderId);
      newState = newState.withTab(event.type, updatedTab);

      for (int t = 1; t <= 3; t++) {
        if (t != event.type) newState = newState.withTab(t, buildTabFromMaster(t, newState.tabByType(t)));
      }

      emit(newState);
    } catch (e) {
      emit(FWUpdateError(e.toString()));
    }
  }

  void _onOverlayDismissed(FWUpdateOverlayDismissed event, Emitter<FWUpdateState> emit) {
    if (state is! FWUpdateLoaded) return;
    final s = state as FWUpdateLoaded;
    for (int t = 1; t <= 3; t++) {
      final tab = s.tabByType(t);
      if (tab.suggestions.isNotEmpty) {
        emit(s.withTab(t, tab.copyWith(suggestions: [])));
        return;
      }
    }
  }

  void _onSealEmpChanged(FWUpdateSealEmpChanged event, Emitter<FWUpdateState> emit) {
    if (state is FWUpdateLoaded) emit((state as FWUpdateLoaded).withTab(event.type, (state as FWUpdateLoaded).tabByType(event.type).copyWith(sealEmpId: event.empId, sealEmpName: event.empName)));
  }
  void _onSealEmpCleared(FWUpdateSealEmpCleared event, Emitter<FWUpdateState> emit) {
    if (state is FWUpdateLoaded) emit((state as FWUpdateLoaded).withTab(event.type, (state as FWUpdateLoaded).tabByType(event.type).copyWith(sealEmpId: 0, sealEmpName: '')));
  }
  void _onBreakEmpChanged(FWUpdateBreakEmpChanged event, Emitter<FWUpdateState> emit) {
    if (state is FWUpdateLoaded) emit((state as FWUpdateLoaded).withTab(event.type, (state as FWUpdateLoaded).tabByType(event.type).copyWith(breakEmpId: event.empId, breakEmpName: event.empName)));
  }
  void _onBreakEmpCleared(FWUpdateBreakEmpCleared event, Emitter<FWUpdateState> emit) {
    if (state is FWUpdateLoaded) emit((state as FWUpdateLoaded).withTab(event.type, (state as FWUpdateLoaded).tabByType(event.type).copyWith(breakEmpId: 0, breakEmpName: '')));
  }
  void _onExRefChanged(FWUpdateExRefChanged event, Emitter<FWUpdateState> emit) {
    if (state is FWUpdateLoaded) emit((state as FWUpdateLoaded).withTab(event.type, (state as FWUpdateLoaded).tabByType(event.type).copyWith(exRef: event.value)));
  }

  void _onImageUploadToggled(FWUpdateImageUploadToggled event, Emitter<FWUpdateState> emit) {
    if (state is FWUpdateLoaded) emit((state as FWUpdateLoaded).withTab(event.type, (state as FWUpdateLoaded).tabByType(event.type).copyWith(imageUploadEnabled: event.value)));
  }
  void _onImagePicked(FWUpdateImagePicked event, Emitter<FWUpdateState> emit) {
    if (state is! FWUpdateLoaded) return;
    final s = state as FWUpdateLoaded;
    final tab = s.tabByType(event.type);
    emit(s.withTab(event.type, tab.copyWith(images: List<String>.from(tab.images)..add(event.imageUrl))));
  }

  Future<void> _onImageDeleted(FWUpdateImageDeleted event, Emitter<FWUpdateState> emit) async {
    if (state is! FWUpdateLoaded) return;
    final s = state as FWUpdateLoaded;
    final tab = s.tabByType(event.type);

    emit(FWUpdateLoading());
    try {
      final networkImg = tab.images[event.index];
      final result = await repository.deleteImage(s.saleOrderId, tab.smkText, networkImg);

      if (result?.IsSuccess == true) {
        final newImages = List<String>.from(tab.images)..removeAt(event.index);
        emit(s.withTab(event.type, tab.copyWith(images: newImages)));
      } else {
        emit(s); // revert on fail
      }
    } catch (e) {
      emit(FWUpdateError(e.toString()));
    }
  }

  Future<void> _onSaveRequested(FWUpdateSaveRequested event, Emitter<FWUpdateState> emit) async {
    if (state is! FWUpdateLoaded) return;
    final s = state as FWUpdateLoaded;

    final smk1 = s.tab1.smkText.isNotEmpty;
    final smk2 = s.tab2.smkText.isNotEmpty;
    final smk3 = s.tab3.smkText.isNotEmpty;

    if (!smk1 && !smk2 && !smk3) return;
    if ((smk1 && smk2) || (smk1 && smk3) || (smk2 && smk3)) return;

    emit(FWUpdateLoading());
    try {
      final master = {
        'Id': s.saleOrderId,
        'Comid': repository.comid,
        'Jobid': 0,
        'EmployeeRefId': repository.empRefId == 0 ? null : repository.empRefId,
        'SealbyRefid': s.tab1.sealEmpId,
        'SealbreakbyRefid': s.tab1.breakEmpId,
        'SealbyRefid2': s.tab2.sealEmpId,
        'SealbreakbyRefid2': s.tab2.breakEmpId,
        'SealbyRefid3': s.tab3.sealEmpId,
        'SealbreakbyRefid3': s.tab3.breakEmpId,
        'ForwardingEnterRef': '',
        'ForwardingExitRef': s.tab1.exRef,
        'ForwardingEnterRef2': '',
        'ForwardingExitRef2': s.tab2.exRef,
        'ForwardingEnterRef3': '',
        'ForwardingExitRef3': s.tab3.exRef,
      };

      final result = await repository.updateForwarding(master);

      if (result?.IsSuccess == true) {
        emit(FWUpdateSaveSuccess());
        emit(_defaultLoaded());
      } else {
        emit(s); // revert
      }
    } catch (e) {
      emit(FWUpdateError(e.toString()));
    }
  }
}