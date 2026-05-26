import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/features/dashboard/admin_dashboard/tabs/transportDB/bloc/transportdb_event.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/transportDB/bloc/transportdb_state.dart';

import '../../../../../../core/network/api_client.dart';


class TransportDashboardBloc
    extends Bloc<TransportDashboardEvent, TransportDashboardState> {
  TransportDashboardBloc() : super(TransportDashboardState.initial()) {
    on<TransportDashboardInitialized>(_onInitialized);
    on<LoadSalesDataRequested>(_onLoadSalesData);
    on<EmployeeFilterChanged>(_onEmployeeFilterChanged);
    on<LoadRulesTypeRequested>(_onLoadRulesType);
    on<LoadPlanningDataRequested>(_onLoadPlanningData);
    on<LoadEnquiryDataRequested>(_onLoadEnquiryData);
    on<CancelEnquiryRequested>(_onCancelEnquiry);
    on<LoadEmployeesRequested>(_onLoadEmployees);
    on<EmployeeSelectedForEmail>(_onEmployeeSelectedForEmail);
    on<EmailActiveToggled>(_onEmailActiveToggled);
    on<EmailUnreadToggled>(_onEmailUnreadToggled);
    on<EmailRepliedToggled>(_onEmailRepliedToggled);
    on<SaveEmailsRequested>(_onSaveEmails);
    on<ReviewFormInitialized>(_onReviewFormInitialized);
    on<ReviewStarChanged>(_onReviewStarChanged);
    on<ReviewEmployeeChanged>(_onReviewEmployeeChanged);
    on<ReviewDateChanged>(_onReviewDateChanged);
    on<SaveReviewRequested>(_onSaveReview);
    on<LoadRTIDataRequested>(_onLoadRTIData);
    on<RTISearchQueryChanged>(_onRTISearchQueryChanged);
    on<RTIDetailCheckToggled>(_onRTIDetailCheckToggled);
    on<RTIImagePicked>(_onRTIImagePicked);
    on<SaveRTIDataRequested>(_onSaveRTIData);
  }

  // ─── Initialization ────────────────────────────────────────────────────────

  Future<void> _onInitialized(
      TransportDashboardInitialized event,
      Emitter<TransportDashboardState> emit,
      ) async {
    final empId = objfun.EmpRefId;
    emit(state.copyWith(empId: empId, selectedDate: DateTime.now()));

    add(LoadRulesTypeRequested());
    add(LoadSalesDataRequested(empId: empId));

    // RTI initial load
    final now = DateTime.now();
    final fromDate = DateFormat('yyyy-MM-dd')
        .format(now.subtract(const Duration(days: 10)));
    final toDate = DateFormat('yyyy-MM-dd').format(now);
    final driverId = objfun.DriverLogin == 1 ? objfun.EmpRefId : 0;

    add(LoadRTIDataRequested(
      fromDate: fromDate,
      toDate: toDate,
      driverId: driverId,
      truckId: objfun.DriverTruckRefId,
      search: '',
    ));

    // Pre-fill review form if editing
    if (event.existingReview != null) {
      add(ReviewFormInitialized(existingReview: event.existingReview));
    }
  }

  // ─── Sales ─────────────────────────────────────────────────────────────────

  Future<void> _onLoadSalesData(
      LoadSalesDataRequested event,
      Emitter<TransportDashboardState> emit,
      ) async {
    emit(state.copyWith(status: TransportDashboardStatus.loading));

    try {
      final Map<String, String> header = {
        'Content-Type': 'application/json; charset=UTF-8',
      };

      final now = DateTime.now();
      final toDate = DateFormat('yyyy-MM-dd').format(now);
      final fromDate =
      DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, 1));
      final comid = objfun.storagenew.getInt('Comid') ?? 0;

      // Without-invoice count (from 2024-10-01)
      final r1 = await objfun.apiAllinoneSelectArray(
        objfun.SaleInvoiceCountDB,
        {
          'Comid': comid,
          'Fromdate': '2024-10-01',
          'Todate': toDate,
          'Statusid': 0,
          'Employeeid': event.empId,
          'Remarks': 2,
          'Search': '0',
          'completestatusnotshow': false,
          'Invoice': false,
        },
        header,
        null,
      );

      // Total count (current month)
      final r2 = await objfun.apiAllinoneSelectArray(
        objfun.SaleInvoiceCountDB,
        {
          'Comid': comid,
          'Fromdate': fromDate,
          'Todate': toDate,
          'Statusid': 0,
          'Employeeid': event.empId,
          'Remarks': 0,
          'Search': '0',
          'completestatusnotshow': false,
          'Invoice': false,
        },
        header,
        null,
      );

      // Billed count
      final r3 = await objfun.apiAllinoneSelectArray(
        objfun.SaleInvoiceCountDB,
        {
          'Comid': comid,
          'Fromdate': fromDate,
          'Todate': toDate,
          'Statusid': 0,
          'Employeeid': event.empId,
          'Remarks': 1,
          'Search': '0',
          'completestatusnotshow': false,
          'Invoice': false,
        },
        header,
        null,
      );

      // Unbilled count
      final r4 = await objfun.apiAllinoneSelectArray(
        objfun.SaleInvoiceCountDB,
        {
          'Comid': comid,
          'Fromdate': fromDate,
          'Todate': toDate,
          'Statusid': 0,
          'Employeeid': event.empId,
          'Remarks': 2,
          'Search': '0',
          'completestatusnotshow': false,
          'Invoice': false,
        },
        header,
        null,
      );

      // Sales order status
      final r5 = await objfun.apiAllinoneSelectArray(
        objfun.SelectSalesOrderStatus,
        {'Comid': comid, 'Employeeid': event.empId},
        header,
        null,
      );

      emit(state.copyWith(
        status: TransportDashboardStatus.success,
        withoutInvoiceCount: (r1 as List).length,
        totalCount: (r2 as List).length,
        totalBilledCount: (r3 as List).length,
        totalUnBilledCount: (r4 as List).length,
        salesReport: r5 is List ? r5 : [],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransportDashboardStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onEmployeeFilterChanged(
      EmployeeFilterChanged event,
      Emitter<TransportDashboardState> emit,
      ) async {
    emit(state.copyWith(
      dropdownValueEmp: event.dropdownValueEmp,
      empId: event.empId,
    ));
    add(LoadSalesDataRequested(empId: event.empId));
  }

  Future<void> _onLoadRulesType(
      LoadRulesTypeRequested event,
      Emitter<TransportDashboardState> emit,
      ) async {
    try {
      final comid = objfun.storagenew.getInt('Comid') ?? 0;
      final result = await objfun.apiAllinoneSelectArray(
        objfun.LoadRulesType,
        {'Comid': comid, 'Employeeid': objfun.EmpRefId},
        {'Content-Type': 'application/json; charset=UTF-8'},
        null,
      );

      final rules = <Map<String, dynamic>>[];
      if (result is List) {
        for (var item in result) {
          rules.add(item as Map<String, dynamic>);
        }
      }

      String? dropdownVal;
      final ids = rules.map((e) => e['Id'].toString()).toList();
      if (ids.contains(objfun.EmpRefId.toString())) {
        dropdownVal = objfun.EmpRefId.toString();
      }

      emit(state.copyWith(
        rulesTypeEmployee: rules,
        dropdownValueEmp: dropdownVal,
      ));
    } catch (_) {}
  }

  // ─── Transport ─────────────────────────────────────────────────────────────

  Future<void> _onLoadPlanningData(
      LoadPlanningDataRequested event,
      Emitter<TransportDashboardState> emit,
      ) async {
    emit(state.copyWith(
      status: TransportDashboardStatus.loading,
      isPlanToday: event.type == 0,
    ));

    try {
      final now = DateTime.now();
      final date = DateFormat('yyyy-MM-dd')
          .format(now.add(Duration(days: event.type)));
      final comid = objfun.storagenew.getInt('Comid') ?? 0;

      final url = event.type == 0 ? objfun.PLANINGSearchDB : objfun.PLANINGSearch;

      final result = await objfun.apiAllinoneSelectArray(
        url,
        {
          'Comid': comid,
          'Fromdate': date,
          'Todate': date,
          'Search': '',
          'Employeeid': null,
          'ETAType': 0,
        },
        {'Content-Type': 'application/json; charset=UTF-8'},
        null,
      );

      emit(state.copyWith(
        status: TransportDashboardStatus.success,
        saleTransReport: result is List ? result : [],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransportDashboardStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  // ─── Enquiry ───────────────────────────────────────────────────────────────

  Future<void> _onLoadEnquiryData(
      LoadEnquiryDataRequested event,
      Emitter<TransportDashboardState> emit,
      ) async {
    emit(state.copyWith(status: TransportDashboardStatus.loading));

    try {
      final comid = objfun.storagenew.getInt('Comid') ?? 0;
      final result = await objfun.apiAllinoneSelectArray(
        objfun.apiSelectEnquiryMaster,
        {
          'Comid': comid,
          'Fromdate': null,
          'Todate': null,
          'Employeeid': objfun.EmpRefId,
          'Invoice': false,
          'Id': 0,
          'JId': 0,
          'DashboardStatus': 2,
        },
        {'Content-Type': 'application/json; charset=UTF-8'},
        null,
      );

      List<dynamic> list = result is List ? List.from(result) : [];

      for (var i = 0; i < list.length; i++) {
        if (list[i]['ForwardingDate'] == null) {
          list[i]['SForwardingDate'] = '';
        } else {
          list[i]['SForwardingDate'] = DateFormat('dd-MM-yyyy HH:mm')
              .format(DateTime.parse(list[i]['ForwardingDate']));
        }
      }

      objfun.EnquiryMasterList = list;

      emit(state.copyWith(
        status: TransportDashboardStatus.success,
        enquiryMasterList: list,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransportDashboardStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCancelEnquiry(
      CancelEnquiryRequested event,
      Emitter<TransportDashboardState> emit,
      ) async {
    try {
      final comid = objfun.storagenew.getInt('Comid') ?? 0;
      await objfun.apiAllinoneSelectArray(
        '${objfun.apiUpdateEnquiryMaster}${event.id}&Comid=$comid&StatusName=CANCEL',
        null,
        {'Content-Type': 'application/json; charset=UTF-8'},
        null,
      );
      add(const LoadEnquiryDataRequested());
    } catch (_) {}
  }

  // ─── Email ─────────────────────────────────────────────────────────────────

  Future<void> _onLoadEmployees(
      LoadEmployeesRequested event,
      Emitter<TransportDashboardState> emit,
      ) async {
    try {
      final comid = objfun.storagenew.getInt('Comid') ?? 0;
      final result = await objfun.apiAllinoneSelect(
        '${objfun.apiSelectEmployee}$comid&type=&type1=',
        null,
        null,
        null,
      );

      if (result.isNotEmpty) {
        final employees =
        result.map<EmployeeModel>((e) => EmployeeModel.fromJson(e)).toList();
        final first = employees.first;

        emit(state.copyWith(
          employees: employees,
          selectedEmployee: first,
        ));

        add(EmployeeSelectedForEmail(employee: first));
      }
    } catch (_) {}
  }

  Future<void> _onEmployeeSelectedForEmail(
      EmployeeSelectedForEmail event,
      Emitter<TransportDashboardState> emit,
      ) async {
    emit(state.copyWith(selectedEmployee: event.employee));

    try {
      final comid = objfun.storagenew.getInt('Comid') ?? 0;

      // Use ApiClient.postRequest
      final result = await ApiClient.postRequest(
        objfun.apiSelectEmailData,
        [{'Id': event.employee.Id}],
        headers: {'Comid': comid.toString()},
      );

      List<dynamic> emailsJson = [];

      // ApiClient already decodes the JSON, so we check the Map directly
      if (result is Map<String, dynamic> && result['unread_unreplied_emails'] is List) {
        emailsJson = result['unread_unreplied_emails'] as List;
      }

      final emails = emailsJson
          .map((e) => EmailModel.fromJson(e as Map<String, dynamic>))
          .toList();

      emit(state.copyWith(emails: emails));
    } catch (e) {
      debugPrint("Email Load Error: $e");
      emit(state.copyWith(emails: []));
    }
  }

  void _onEmailActiveToggled(
      EmailActiveToggled event,
      Emitter<TransportDashboardState> emit,
      ) {
    final updated = List<EmailModel>.from(state.emails);
    updated[event.index] = updated[event.index].copyWith(isActive: event.value);
    emit(state.copyWith(emails: updated));
  }

  void _onEmailUnreadToggled(
      EmailUnreadToggled event,
      Emitter<TransportDashboardState> emit,
      ) {
    final updated = List<EmailModel>.from(state.emails);
    updated[event.index] =
        updated[event.index].copyWith(isUnread: event.value);
    emit(state.copyWith(emails: updated));
  }

  void _onEmailRepliedToggled(
      EmailRepliedToggled event,
      Emitter<TransportDashboardState> emit,
      ) {
    final updated = List<EmailModel>.from(state.emails);
    updated[event.index] =
        updated[event.index].copyWith(isReplied: event.value);
    emit(state.copyWith(emails: updated));
  }

  Future<void> _onSaveEmails(
      SaveEmailsRequested event,
      Emitter<TransportDashboardState> emit,
      ) async {
    emit(state.copyWith(isSavingEmails: true));

    try {
      final comid = objfun.storagenew.getInt('Comid') ?? 0;
      final toSave = state.emails.where((e) => e.isActive).toList();

      if (toSave.isEmpty) {
        emit(state.copyWith(isSavingEmails: false));
        return;
      }

      final payload = toSave
          .map((e) => {
        'Id': 0,
        'EmployeeRefId': state.selectedEmployee?.Id,
        'EmailID': e.emailId,
        'Subject': e.subject,
        'Sender': e.sender,
        'MessageId': e.messageId,
        'ReceivedDate': e.receivedDate.toIso8601String(),
        'Comid': comid,
        'IsUnread': e.isUnread ? 1 : 0,
        'IsReplied': e.isReplied ? 1 : 0,
        'Active': 1,
      })
          .toList();

      // Use ApiClient.postRequest
      await ApiClient.postRequest(
        objfun.apiInsertMailMaster,
        payload,
        headers: {'Comid': comid.toString()},
      );

      emit(state.copyWith(isSavingEmails: false));
    } catch (e) {
      emit(state.copyWith(
        isSavingEmails: false,
        errorMessage: e.toString(),
      ));
    }
  }

  // ─── Google Review ─────────────────────────────────────────────────────────

  void _onReviewFormInitialized(
      ReviewFormInitialized event,
      Emitter<TransportDashboardState> emit,
      ) {
    if (event.existingReview != null) {
      final r = event.existingReview!;
      emit(state.copyWith(
        selectedReview: int.tryParse(r.googleReview ?? '1') ?? 1,
        selectedEmpId: r.empReffid,
        selectedDate: r.supportDate,
      ));
    }
  }

  void _onReviewStarChanged(
      ReviewStarChanged event,
      Emitter<TransportDashboardState> emit,
      ) {
    emit(state.copyWith(selectedReview: event.star));
  }

  void _onReviewEmployeeChanged(
      ReviewEmployeeChanged event,
      Emitter<TransportDashboardState> emit,
      ) {
    if (event.empId == null) {
      emit(state.copyWith(clearSelectedEmpId: true));
    } else {
      emit(state.copyWith(selectedEmpId: event.empId));
    }
  }

  void _onReviewDateChanged(
      ReviewDateChanged event,
      Emitter<TransportDashboardState> emit,
      ) {
    emit(state.copyWith(selectedDate: event.date));
  }

  Future<void> _onSaveReview(
      SaveReviewRequested event,
      Emitter<TransportDashboardState> emit,
      ) async {
    emit(state.copyWith(isSavingReview: true));

    try {
      await objfun.apiAllinoneSelectArray(
        objfun.apiGoogleReviewInsert,
        [
          {
            'Id': 0,
            'ShopName': event.shopName.toUpperCase(),
            'MobileNo': event.mobileNo,
            'GoogleReview': state.selectedReview.toString(),
            'GoogleMsg': event.reviewMsg,
            'RefDate': DateFormat('yyyy-MM-dd').format(state.selectedDate),
            'EmpReffid': state.selectedEmpId,
          }
        ],
        {'Content-Type': 'application/json; charset=UTF-8'},
        null,
      );

      emit(state.copyWith(
        isSavingReview: false,
        selectedReview: 1,
        clearSelectedEmpId: true,
        selectedDate: DateTime.now(),
      ));
    } catch (e) {
      emit(state.copyWith(
        isSavingReview: false,
        errorMessage: e.toString(),
      ));
    }
  }

  // ─── RTI / PDO ─────────────────────────────────────────────────────────────

  Future<void> _onLoadRTIData(
      LoadRTIDataRequested event,
      Emitter<TransportDashboardState> emit,
      ) async {
    emit(state.copyWith(status: TransportDashboardStatus.loading));

    try {
      final comid = objfun.storagenew.getInt('Comid') ?? 0;
      final result = await objfun.apiAllinoneSelect(
        '${objfun.apiSelectRTIView}$comid&Fromdate=${event.fromDate}&Todate=${event.toDate}'
            '&DId=${event.driverId}&TId=${event.truckId}&Employeeid=0&Search=${event.search}',
        null,
        null,
        null,
      );

      List<RTIMasterViewModel> masterList = [];
      List<RTIDetailsViewModel> detailList = [];

      if (result.isNotEmpty) {
        masterList = (result[0]['salemaster'] as List)
            .map((e) => RTIMasterViewModel.fromJson(e))
            .toList();
        detailList = (result[0]['saledetails'] as List)
            .map((e) => RTIDetailsViewModel.fromJson(e))
            .toList();
        objfun.RTIViewMasterList = masterList;
        objfun.RTIViewDetailList = detailList;
      }

      emit(state.copyWith(
        status: TransportDashboardStatus.success,
        allRTIMasterList: masterList,
        filteredRTIMasterList: masterList,
        rtiDetailList: detailList,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransportDashboardStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onRTISearchQueryChanged(
      RTISearchQueryChanged event,
      Emitter<TransportDashboardState> emit,
      ) {
    final q = event.query.toLowerCase();
    final filtered = q.isEmpty
        ? state.allRTIMasterList
        : state.allRTIMasterList.where((m) {
      return m.RTINoDisplay.toLowerCase().contains(q) ||
          m.DriverName.toLowerCase().contains(q) ||
          m.TruckName.toLowerCase().contains(q);
    }).toList();

    emit(state.copyWith(filteredRTIMasterList: filtered));
  }

  void _onRTIDetailCheckToggled(
      RTIDetailCheckToggled event,
      Emitter<TransportDashboardState> emit,
      ) {
    final updated = state.rtiDetailList.map((d) {
      if (d.Id == event.detailId) {
        d.isChecked = event.isChecked;
        d.Active = event.isChecked ? 1 : 0;
      }
      return d;
    }).toList();

    emit(state.copyWith(rtiDetailList: updated));
  }

  Future<void> _onRTIImagePicked(
      RTIImagePicked event,
      Emitter<TransportDashboardState> emit,
      ) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: event.fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 80,
    );

    if (file != null) {
      final updated = state.rtiDetailList.map((d) {
        if (d.Id == event.detailId) {
          d.imageFile = file;
          d.imagePath = file.path;
        }
        return d;
      }).toList();

      emit(state.copyWith(rtiDetailList: updated));
    }
  }

  Future<void> _onSaveRTIData(
      SaveRTIDataRequested event,
      Emitter<TransportDashboardState> emit,
      ) async {
    emit(state.copyWith(isSavingRTI: true));

    try {
      final comid = objfun.storagenew.getInt('Comid') ?? 0;
      final master = state.filteredRTIMasterList
          .firstWhere((m) => m.Id == event.masterId);

      final selectedDetails = state.rtiDetailList
          .where((x) => x.RTIMasterRefId == event.masterId && x.isChecked)
          .map((x) => {
        'Id': x.StatusId,
        'CompanyRefId': comid,
        'RTIMasterRefId': event.masterId,
        'RTIDetailsRefId': x.Id,
        'RTICNumberDisplay': master.RTINoDisplay,
        'DriverName': master.DriverName,
        'JobNumber': x.JobNo,
        'SaleOrderMasterRefId': x.SaleOrderMasterRefId,
        'CustomerMasterRefId': x.CustomerMasterRefId,
        'TruckMasterRefId': master.TruckMasterRefId,
        'DriverMasterRefId': objfun.EmpRefId,
        'TruckName': master.TruckName,
        'Active': x.isChecked ? 1 : 0,
        'ImagePath': x.imagePath,
      })
          .toList();

      final uri = Uri.parse('${objfun.apiRTIDetailsInsert}$comid');
      final request = http.MultipartRequest('POST', uri);
      request.fields['objReceipt'] = jsonEncode(selectedDetails);
      request.fields['Comid'] = comid.toString();

      for (var d in state.rtiDetailList) {
        if (d.RTIMasterRefId == event.masterId &&
            d.isChecked &&
            d.imageFile != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'Files_${d.Id}',
            d.imageFile!.path,
            filename: d.imageFile!.name,
          ));
        }
      }

      await request.send();
      emit(state.copyWith(isSavingRTI: false));
    } catch (e) {
      emit(state.copyWith(
        isSavingRTI: false,
        errorMessage: e.toString(),
      ));
    }
  }
}