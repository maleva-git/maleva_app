import 'package:maleva/core/network/legacy_api_repository.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/utils/app_globals.dart';
import '../data/fwupdate_repository.dart';
import 'forwarding_event.dart';
import 'forwarding_state.dart';

class FWUpdateBloc extends Bloc<FWUpdateEvent, FWUpdateState> {
  final FWUpdateRepository repository;

  List<Map<String, dynamic>> _jobs = const [];

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
    on<FWUpdateEnRefChanged>(_onEnRefChanged);
    on<FWUpdateExRefChanged>(_onExRefChanged);
    on<FWUpdateImageUploadToggled>(_onImageUploadToggled);
    on<FWUpdateImagePicked>(_onImagePicked);
    on<FWUpdateImageDeleted>(_onImageDeleted);
    on<FWUpdateSaveRequested>(_onSaveRequested);
  }

  FWUpdateLoaded _defaultLoaded() => FWUpdateLoaded(
    currentTab: 0, saleOrderId: 0,
    tab1: FWTabData.empty(), tab2: FWTabData.empty(), tab3: FWTabData.empty(),
  );

  Future<void> _onStarted(FWUpdateStarted event, Emitter<FWUpdateState> emit) async {
    emit(FWUpdateLoading());
    try {
      _jobs = await repository.fetchJobNoList();
      emit(_defaultLoaded());
    } catch (e) {
      emit(FWUpdateError(e.toString()));
    }
  }

  void _onTabChanged(FWUpdateTabChanged event, Emitter<FWUpdateState> emit) {
    if (state is FWUpdateLoaded) emit((state as FWUpdateLoaded).copyWith(currentTab: event.tabIndex));
  }

  void _onSmkTextChanged(FWUpdateSmkTextChanged event, Emitter<FWUpdateState> emit) {
    if (state is! FWUpdateLoaded) return;
    final s = state as FWUpdateLoaded;

    final query = event.text.trim().replaceAll(" ", "+");

    List<dynamic> filtered = [];
    if (query.isNotEmpty) {
      final smkKey = event.type == 1 ? 'forwardingSMKNo' : event.type == 2 ? 'forwardingSMKNo2' : 'forwardingSMKNo3';
      filtered = _jobs.where((e) {
        final smkValue = (e[smkKey] ?? '').toString();
        return smkValue.contains(query);
      }).toList();
    }

    final updated = s.tabByType(event.type).copyWith(smkText: event.text, suggestions: filtered);
    emit(s.withTab(event.type, updated));
  }

  Future<void> _onSmkSuggestionSelected(FWUpdateSmkSuggestionSelected event, Emitter<FWUpdateState> emit) async {
    if (state is! FWUpdateLoaded) return;
    final s = state as FWUpdateLoaded;

    emit(FWUpdateLoading());

    int newSaleOrderId = event.saleOrderId;
    List<String> fetchedImages = [];

    Map<String, dynamic> master = const {};
    try {
      master = await repository.fetchJob(event.saleOrderId);
      if (!event.context.mounted) return;
      await sl<LegacyApiRepository>().SelectEmployee(event.context, '', 'Operation');
    } catch (e) {
      print("Master/Employee API Error (Ignored): $e");
    }

    // 2. Exact Old Code Image Fetching Logic
    try {
      if (!event.context.mounted) return;
      // the shared Java GET /api/attachments
      fetchedImages.addAll(await repository.fetchImages(event.saleOrderId, event.smkText));
    } catch (e) {
      print("Image API Error (Ignored 404): $e");
    }

    // 3. The tabs from the job (Java names)
    FWTabData buildTabFromMaster(int type, FWTabData existing) {
      if (master.isEmpty) {
        return existing.copyWith(
          smkText: event.type == type ? event.smkText : existing.smkText,
          suggestions: [],
        );
      }

      String enRef = '';
      String exRef = '';
      int sealId = 0;
      int breakId = 0;

      if (type == 1) {
        enRef = master['forwardingEnterRef']?.toString() ?? '';
        exRef = master['forwardingExitRef']?.toString() ?? '';
        sealId = int.tryParse(master['sealbyRefid']?.toString() ?? '0') ?? 0;
        breakId = int.tryParse(master['sealbreakbyRefid']?.toString() ?? '0') ?? 0;
      } else if (type == 2) {
        enRef = master['forwardingEnterRef2']?.toString() ?? '';
        exRef = master['forwardingExitRef2']?.toString() ?? '';
        sealId = int.tryParse(master['sealbyRefid2']?.toString() ?? '0') ?? 0;
        breakId = int.tryParse(master['sealbreakbyRefid2']?.toString() ?? '0') ?? 0;
      } else {
        enRef = master['forwardingEnterRef3']?.toString() ?? '';
        exRef = master['forwardingExitRef3']?.toString() ?? '';
        sealId = int.tryParse(master['sealbyRefid3']?.toString() ?? '0') ?? 0;
        breakId = int.tryParse(master['sealbreakbyRefid3']?.toString() ?? '0') ?? 0;
      }

      String sealName = '';
      String breakName = '';

      // Employee Object access using .Id and .AccountName (Fix for Map vs Object issue)
      if (sealId != 0 && AppGlobals.EmployeeList.isNotEmpty) {
        var emp = AppGlobals.EmployeeList.where((item) => item.Id == sealId).toList();
        if (emp.isNotEmpty) sealName = emp[0].AccountName ?? '';
      }
      if (breakId != 0 && AppGlobals.EmployeeList.isNotEmpty) {
        var emp = AppGlobals.EmployeeList.where((item) => item.Id == breakId).toList();
        if (emp.isNotEmpty) breakName = emp[0].AccountName ?? '';
      }

      return existing.copyWith(
        smkText: event.type == type ? event.smkText : existing.smkText,
        enRef: enRef,
        exRef: exRef,
        sealEmpId: sealId,
        sealEmpName: sealName,
        breakEmpId: breakId,
        breakEmpName: breakName,
        suggestions: [], // Clear suggestions
      );
    }

    final tab1 = buildTabFromMaster(1, s.tab1);
    final tab2 = buildTabFromMaster(2, s.tab2);
    final tab3 = buildTabFromMaster(3, s.tab3);

    final updatedTab1 = event.type == 1 ? tab1.copyWith(images: fetchedImages) : tab1;
    final updatedTab2 = event.type == 2 ? tab2.copyWith(images: fetchedImages) : tab2;
    final updatedTab3 = event.type == 3 ? tab3.copyWith(images: fetchedImages) : tab3;

    final newState = s.copyWith(saleOrderId: newSaleOrderId, tab1: updatedTab1, tab2: updatedTab2, tab3: updatedTab3);
    emit(newState);
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
  void _onEnRefChanged(FWUpdateEnRefChanged event, Emitter<FWUpdateState> emit) {
    if (state is FWUpdateLoaded) emit((state as FWUpdateLoaded).withTab(event.type, (state as FWUpdateLoaded).tabByType(event.type).copyWith(enRef: event.value)));
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
      await repository.deleteImage(s.saleOrderId, tab.smkText, networkImg);
      final newImages = List<String>.from(tab.images)..removeAt(event.index);
      emit(s.withTab(event.type, tab.copyWith(images: newImages)));
    } catch (e) {
      emit(FWUpdateError(e.toString()));
    }
  }

  Future<void> _onSaveRequested(FWUpdateSaveRequested event, Emitter<FWUpdateState> emit) async {
    if (state is! FWUpdateLoaded) return;
    final s = state as FWUpdateLoaded;

    emit(FWUpdateLoading());
    try {
      await repository.updateForwarding(s.saleOrderId, {
        'sealbyRefid': s.tab1.sealEmpId,
        'sealbreakbyRefid': s.tab1.breakEmpId,
        'sealbyRefid2': s.tab2.sealEmpId,
        'sealbreakbyRefid2': s.tab2.breakEmpId,
        'sealbyRefid3': s.tab3.sealEmpId,
        'sealbreakbyRefid3': s.tab3.breakEmpId,
        'forwardingEnterRef': s.tab1.enRef,
        'forwardingExitRef': s.tab1.exRef,
        'forwardingEnterRef2': s.tab2.enRef,
        'forwardingExitRef2': s.tab2.exRef,
        'forwardingEnterRef3': s.tab3.enRef,
        'forwardingExitRef3': s.tab3.exRef,
        'forwardingSMKNo': s.tab1.smkText.isEmpty ? null : s.tab1.smkText,
        'forwardingSMKNo2': s.tab2.smkText.isEmpty ? null : s.tab2.smkText,
        'forwardingSMKNo3': s.tab3.smkText.isEmpty ? null : s.tab3.smkText,
      });
      emit(FWUpdateSaveSuccess());
      emit(_defaultLoaded()); // Form clears automatically
    } catch (e) {
      emit(FWUpdateError(e.toString()));
    }
  }
}