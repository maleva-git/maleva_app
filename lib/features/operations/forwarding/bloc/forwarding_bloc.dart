import 'package:maleva/core/network/api_legacy_helper.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/utils/app_globals.dart';
import '../data/fwupdate_repository.dart';
import 'forwarding_event.dart';
import 'forwarding_state.dart';

class FWUpdateBloc extends Bloc<FWUpdateEvent, FWUpdateState> {
  final FWUpdateRepository repository; // Pass your repo interface

  final List<dynamic> _employeeList = [];

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

    // Fixed: Search using global job no list loaded in InitState
    final query = event.text.trim().replaceAll(" ", "+");

    List<dynamic> filtered = [];
    if (query.isNotEmpty) {
      final smkKey = event.type == 1 ? 'ForwardingSMKNo' : event.type == 2 ? 'ForwardingSMKNo2' : 'ForwardingSMKNo3';
      filtered = AppGlobals.JobNoList.where((e) {
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

    // 1. Exact Old Code API Calls (Direct-a OnlineApi use panrom)

    try {
      await OnlineApi.EditSalesOrder(event.saleOrderId, 0);
      if (!event.context.mounted) return;
      await OnlineApi.SelectEmployee(event.context, '', 'Operation');
    } catch (e) {
      print("Master/Employee API Error (Ignored): $e");
    }







    // 2. Exact Old Code Image Fetching Logic
    try {
      String imgDir = "/Upload/${AppGlobals.Comid}/SalesOrder/${event.saleOrderId}/${event.smkText}/";
      Map<String, String> header = {'Content-Type': 'application/json; charset=UTF-8'};

      var resultData = await ApiLegacyHelper.apiAllinoneSelectArray(
          "${ApiConstants.apiGetImage}$imgDir", null, header, event.context
      );

      if (resultData != "" && resultData != null && resultData is List) {
        for(var i=0; i < resultData.length; i++) {
          fetchedImages.add(resultData[i].toString());
        }
      }
    } catch (e) {
      print("Image API Error (Ignored 404): $e");
    }

    // 3. Extract Data from objfun globals
    FWTabData buildTabFromMaster(int type, FWTabData existing) {
      // Check pannrom data iruka illaya nu
      if (AppGlobals.SaleEditMasterList.isEmpty) {
        return existing.copyWith(
          smkText: event.type == type ? event.smkText : existing.smkText,
          suggestions: [],
        );
      }

      var master = AppGlobals.SaleEditMasterList[0];

      String enRef = '';
      String exRef = '';
      int sealId = 0;
      int breakId = 0;

      if (type == 1) {
        enRef = master['ForwardingEnterRef']?.toString() ?? '';
        exRef = master['ForwardingExitRef']?.toString() ?? '';
        sealId = int.tryParse(master['SealbyRefid']?.toString() ?? '0') ?? 0;
        breakId = int.tryParse(master['SealbreakbyRefid']?.toString() ?? '0') ?? 0;
      } else if (type == 2) {
        enRef = master['ForwardingEnterRef2']?.toString() ?? '';
        exRef = master['ForwardingExitRef2']?.toString() ?? '';
        sealId = int.tryParse(master['SealbyRefid2']?.toString() ?? '0') ?? 0;
        breakId = int.tryParse(master['SealbreakbyRefid2']?.toString() ?? '0') ?? 0;
      } else {
        enRef = master['ForwardingEnterRef3']?.toString() ?? '';
        exRef = master['ForwardingExitRef3']?.toString() ?? '';
        sealId = int.tryParse(master['SealbyRefid3']?.toString() ?? '0') ?? 0;
        breakId = int.tryParse(master['SealbreakbyRefid3']?.toString() ?? '0') ?? 0;
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

    final updatedTab = buildTabFromMaster(event.type, s.tabByType(event.type)).copyWith(
      images: fetchedImages,
    );

    final newState = s.copyWith(saleOrderId: newSaleOrderId).withTab(event.type, updatedTab);
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
      final result = await repository.deleteImage(s.saleOrderId, tab.smkText, networkImg);

      if (result?.IsSuccess == true) {
        final newImages = List<String>.from(tab.images)..removeAt(event.index);
        emit(s.withTab(event.type, tab.copyWith(images: newImages)));
      } else {
        emit(s);
      }
    } catch (e) {
      emit(FWUpdateError(e.toString()));
    }
  }

  Future<void> _onSaveRequested(FWUpdateSaveRequested event, Emitter<FWUpdateState> emit) async {
    if (state is! FWUpdateLoaded) return;
    final s = state as FWUpdateLoaded;

    emit(FWUpdateLoading());
    try {
      final master = {
        'Id': s.saleOrderId,
        'Comid': AppGlobals.Comid,
        'Jobid': 0,
        'EmployeeRefId': AppGlobals.EmpRefId == 0 ? null : AppGlobals.EmpRefId,
        'SealbyRefid': s.tab1.sealEmpId,
        'SealbreakbyRefid': s.tab1.breakEmpId,
        'SealbyRefid2': s.tab2.sealEmpId,
        'SealbreakbyRefid2': s.tab2.breakEmpId,
        'SealbyRefid3': s.tab3.sealEmpId,
        'SealbreakbyRefid3': s.tab3.breakEmpId,
        'ForwardingEnterRef': s.tab1.enRef,
        'ForwardingExitRef': s.tab1.exRef,
        'ForwardingEnterRef2': s.tab2.enRef,
        'ForwardingExitRef2': s.tab2.exRef,
        'ForwardingEnterRef3': s.tab3.enRef,
        'ForwardingExitRef3': s.tab3.exRef,
      };

      final result = await repository.updateForwarding(master);

      if (result?.IsSuccess == true) {
        emit(FWUpdateSaveSuccess());
        emit(_defaultLoaded()); // Form clears automatically
      } else {
        emit(s);
      }
    } catch (e) {
      emit(FWUpdateError(e.toString()));
    }
  }
}