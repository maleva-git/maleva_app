import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import '../data/transportdb_repository.dart';
import 'transportdb_event.dart';
import 'transportdb_state.dart';

class TransportDashboardBloc extends Bloc<TransportDashboardEvent, TransportDashboardState> {
  final TransportDashboardRepository repository;

  TransportDashboardBloc({required this.repository}) : super(TransportDashboardState.initial()) {
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

  Future<void> _onInitialized(TransportDashboardInitialized event, Emitter<TransportDashboardState> emit) async {
    final empId = AppPreferences.getEmpRefId();
    emit(state.copyWith(empId: empId, selectedDate: DateTime.now()));

    add(LoadRulesTypeRequested());
    add(LoadSalesDataRequested(empId: empId));

    final now = DateTime.now();
    final driverId = AppPreferences.getDriverLogin() == 1 ? empId : 0;

    add(LoadRTIDataRequested(
      fromDate: DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 10))),
      toDate: DateFormat('yyyy-MM-dd').format(now),
      driverId: driverId,
      truckId: objfun.DriverTruckRefId,
      search: '',
    ));

    if (event.existingReview != null) add(ReviewFormInitialized(existingReview: event.existingReview));
  }

  Future<void> _onLoadSalesData(LoadSalesDataRequested event, Emitter<TransportDashboardState> emit) async {
    emit(state.copyWith(status: TransportDashboardStatus.loading));
    try {
      final data = await repository.fetchSalesData(event.empId);
      emit(state.copyWith(
        status: TransportDashboardStatus.success,
        withoutInvoiceCount: data['withoutInvoiceCount'],
        totalCount: data['totalCount'],
        totalBilledCount: data['totalBilledCount'],
        totalUnBilledCount: data['totalUnBilledCount'],
        salesReport: data['salesReport'],
      ));
    } catch (e) {
      emit(state.copyWith(status: TransportDashboardStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onEmployeeFilterChanged(EmployeeFilterChanged event, Emitter<TransportDashboardState> emit) async {
    emit(state.copyWith(dropdownValueEmp: event.dropdownValueEmp, empId: event.empId));
    add(LoadSalesDataRequested(empId: event.empId));
  }

  Future<void> _onLoadRulesType(LoadRulesTypeRequested event, Emitter<TransportDashboardState> emit) async {
    try {
      final rules = await repository.fetchRulesType();
      String? dropdownVal;
      final empIdStr = AppPreferences.getEmpRefId().toString();
      if (rules.map((e) => e['Id'].toString()).contains(empIdStr)) dropdownVal = empIdStr;

      emit(state.copyWith(rulesTypeEmployee: rules, dropdownValueEmp: dropdownVal));
    } catch (_) {}
  }

  Future<void> _onLoadPlanningData(LoadPlanningDataRequested event, Emitter<TransportDashboardState> emit) async {
    emit(state.copyWith(status: TransportDashboardStatus.loading, isPlanToday: event.type == 0));
    try {
      final data = await repository.fetchPlanningData(event.type);
      emit(state.copyWith(status: TransportDashboardStatus.success, saleTransReport: data));
    } catch (e) {
      emit(state.copyWith(status: TransportDashboardStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadEnquiryData(LoadEnquiryDataRequested event, Emitter<TransportDashboardState> emit) async {
    emit(state.copyWith(status: TransportDashboardStatus.loading));
    try {
      final list = await repository.fetchEnquiryData();
      emit(state.copyWith(status: TransportDashboardStatus.success, enquiryMasterList: list));
    } catch (e) {
      emit(state.copyWith(status: TransportDashboardStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onCancelEnquiry(CancelEnquiryRequested event, Emitter<TransportDashboardState> emit) async {
    try {
      await repository.cancelEnquiry(event.id);
      add(const LoadEnquiryDataRequested());
    } catch (_) {}
  }

  Future<void> _onLoadEmployees(LoadEmployeesRequested event, Emitter<TransportDashboardState> emit) async {
    try {
      final employees = await repository.fetchEmployees();
      if (employees.isNotEmpty) {
        emit(state.copyWith(employees: employees, selectedEmployee: employees.first));
        add(EmployeeSelectedForEmail(employee: employees.first));
      }
    } catch (_) {}
  }

  Future<void> _onEmployeeSelectedForEmail(EmployeeSelectedForEmail event, Emitter<TransportDashboardState> emit) async {
    emit(state.copyWith(selectedEmployee: event.employee));
    try {
      final emails = await repository.fetchEmailsForEmployee(event.employee.Id ?? 0);
      emit(state.copyWith(emails: emails));
    } catch (e) {
      emit(state.copyWith(emails: []));
    }
  }

  // (Simple toggles omitted for brevity, they remain exactly the same as your original code)
  void _onEmailActiveToggled(EmailActiveToggled event, Emitter<TransportDashboardState> emit) {
    final updated = List<EmailModel>.from(state.emails);
    updated[event.index] = updated[event.index].copyWith(isActive: event.value);
    emit(state.copyWith(emails: updated));
  }
  void _onEmailUnreadToggled(EmailUnreadToggled event, Emitter<TransportDashboardState> emit) {
    final updated = List<EmailModel>.from(state.emails);
    updated[event.index] = updated[event.index].copyWith(isUnread: event.value);
    emit(state.copyWith(emails: updated));
  }
  void _onEmailRepliedToggled(EmailRepliedToggled event, Emitter<TransportDashboardState> emit) {
    final updated = List<EmailModel>.from(state.emails);
    updated[event.index] = updated[event.index].copyWith(isReplied: event.value);
    emit(state.copyWith(emails: updated));
  }

  Future<void> _onSaveEmails(SaveEmailsRequested event, Emitter<TransportDashboardState> emit) async {
    emit(state.copyWith(isSavingEmails: true));
    try {
      final toSave = state.emails.where((e) => e.isActive).toList();
      if (toSave.isEmpty) { emit(state.copyWith(isSavingEmails: false)); return; }

      final comid = AppPreferences.getComid();
      final payload = toSave.map((e) => {
        'Id': 0, 'EmployeeRefId': state.selectedEmployee?.Id, 'EmailID': e.emailId,
        'Subject': e.subject, 'Sender': e.sender, 'MessageId': e.messageId,
        'ReceivedDate': e.receivedDate.toIso8601String(), 'Comid': comid,
        'IsUnread': e.isUnread ? 1 : 0, 'IsReplied': e.isReplied ? 1 : 0, 'Active': 1,
      }).toList();

      await repository.saveEmails(payload);
      emit(state.copyWith(isSavingEmails: false));
    } catch (e) {
      emit(state.copyWith(isSavingEmails: false, errorMessage: e.toString()));
    }
  }

  void _onReviewFormInitialized(ReviewFormInitialized event, Emitter<TransportDashboardState> emit) {
    if (event.existingReview != null) {
      final r = event.existingReview!;
      emit(state.copyWith(selectedReview: int.tryParse(r.googleReview ?? '1') ?? 1, selectedEmpId: r.empReffid, selectedDate: r.supportDate));
    }
  }
  void _onReviewStarChanged(ReviewStarChanged event, Emitter<TransportDashboardState> emit) => emit(state.copyWith(selectedReview: event.star));
  void _onReviewEmployeeChanged(ReviewEmployeeChanged event, Emitter<TransportDashboardState> emit) =>
      event.empId == null ? emit(state.copyWith(clearSelectedEmpId: true)) : emit(state.copyWith(selectedEmpId: event.empId));
  void _onReviewDateChanged(ReviewDateChanged event, Emitter<TransportDashboardState> emit) => emit(state.copyWith(selectedDate: event.date));

  Future<void> _onSaveReview(SaveReviewRequested event, Emitter<TransportDashboardState> emit) async {
    emit(state.copyWith(isSavingReview: true));
    try {
      final payload = {
        'Id': 0, 'ShopName': event.shopName.toUpperCase(), 'MobileNo': event.mobileNo,
        'GoogleReview': state.selectedReview.toString(), 'GoogleMsg': event.reviewMsg,
        'RefDate': DateFormat('yyyy-MM-dd').format(state.selectedDate), 'EmpReffid': state.selectedEmpId,
      };
      await repository.saveGoogleReview(payload);
      emit(state.copyWith(isSavingReview: false, selectedReview: 1, clearSelectedEmpId: true, selectedDate: DateTime.now()));
    } catch (e) {
      emit(state.copyWith(isSavingReview: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadRTIData(LoadRTIDataRequested event, Emitter<TransportDashboardState> emit) async {
    emit(state.copyWith(status: TransportDashboardStatus.loading));
    try {
      final data = await repository.fetchRTIData(event.fromDate, event.toDate, event.driverId, event.truckId, event.search);
      emit(state.copyWith(
        status: TransportDashboardStatus.success,
        allRTIMasterList: data['masterList'],
        filteredRTIMasterList: data['masterList'],
        rtiDetailList: data['detailList'],
      ));
    } catch (e) {
      emit(state.copyWith(status: TransportDashboardStatus.failure, errorMessage: e.toString()));
    }
  }

  void _onRTISearchQueryChanged(RTISearchQueryChanged event, Emitter<TransportDashboardState> emit) {
    final q = event.query.toLowerCase();
    final filtered = q.isEmpty ? state.allRTIMasterList : state.allRTIMasterList.where((m) {
      return m.RTINoDisplay.toLowerCase().contains(q) || m.DriverName.toLowerCase().contains(q) || m.TruckName.toLowerCase().contains(q);
    }).toList();
    emit(state.copyWith(filteredRTIMasterList: filtered));
  }

  void _onRTIDetailCheckToggled(RTIDetailCheckToggled event, Emitter<TransportDashboardState> emit) {
    final updated = state.rtiDetailList.map((d) {
      if (d.Id == event.detailId) { d.isChecked = event.isChecked; d.Active = event.isChecked ? 1 : 0; }
      return d;
    }).toList();
    emit(state.copyWith(rtiDetailList: updated));
  }

  Future<void> _onRTIImagePicked(RTIImagePicked event, Emitter<TransportDashboardState> emit) async {
    final file = await ImagePicker().pickImage(source: event.fromCamera ? ImageSource.camera : ImageSource.gallery, imageQuality: 80);
    if (file != null) {
      final updated = state.rtiDetailList.map((d) {
        if (d.Id == event.detailId) { d.imageFile = file; d.imagePath = file.path; }
        return d;
      }).toList();
      emit(state.copyWith(rtiDetailList: updated));
    }
  }

  Future<void> _onSaveRTIData(SaveRTIDataRequested event, Emitter<TransportDashboardState> emit) async {
    emit(state.copyWith(isSavingRTI: true));
    try {
      final master = state.filteredRTIMasterList.firstWhere((m) => m.Id == event.masterId);
      final comid = AppPreferences.getComid();
      final empRefId = AppPreferences.getEmpRefId();

      final selectedDetails = state.rtiDetailList.where((x) => x.RTIMasterRefId == event.masterId && x.isChecked).map((x) => {
        'Id': x.StatusId, 'CompanyRefId': comid, 'RTIMasterRefId': event.masterId,
        'RTIDetailsRefId': x.Id, 'RTICNumberDisplay': master.RTINoDisplay, 'DriverName': master.DriverName,
        'JobNumber': x.JobNo, 'SaleOrderMasterRefId': x.SaleOrderMasterRefId, 'CustomerMasterRefId': x.CustomerMasterRefId,
        'TruckMasterRefId': master.TruckMasterRefId, 'DriverMasterRefId': empRefId, 'TruckName': master.TruckName,
        'Active': x.isChecked ? 1 : 0, 'ImagePath': x.imagePath,
      }).toList();

      await repository.saveRTIData(selectedDetails, state.rtiDetailList, event.masterId);
      emit(state.copyWith(isSavingRTI: false));
    } catch (e) {
      emit(state.copyWith(isSavingRTI: false, errorMessage: e.toString()));
    }
  }
}