import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/app_globals.dart';

import '../data/googlereview_repository.dart';
import 'googlereview_event.dart';
import 'googlereview_state.dart';
import 'package:maleva/core/models/shared/review.dart';
import 'package:maleva/core/models/shared/employee_model.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  // ❌ REMOVED: final BuildContext context;
  final GoogleReviewRepository repository; // ✅ Injected Repository

  ReviewBloc({required this.repository}) : super(const ReviewInitial()) {
    on<LoadEmployeeEvent>(_onLoadEmployees);
    on<SelectReviewEvent>(_onSelectReview);
    on<SelectEmployeesEvent>(_onSelectEmployee);
    on<SelectDateEvent>(_onSelectDate);
    on<SaveReviewEvent>(_onSaveReview);
    on<ResetFormEvent>(_onResetForm);
    on<LoadGridEmployeesEvent>(_onLoadGridEmployees);
    on<SelectGridEmployeeEvent>(_onSelectGridEmployee);
    on<SelectDateRangeEvent>(_onSelectDateRange);
    on<LoadReviewsEvent>(_onLoadReviews);
    on<DeleteReviewEvent>(_onDeleteReview);
  }

  // ── 1. Load Employees (Entry Form) ──────────────────────────────────────────
  Future<void> _onLoadEmployees(
      LoadEmployeeEvent event,
      Emitter<ReviewState> emit,
      ) async {
    emit(const ReviewEmployeesLoading());
    try {
      final comId = AppGlobals.storagenew.getInt('Comid') ?? 0;
      final resultData = await repository.fetchEmployees(comId: comId);

      if (resultData != null && resultData is List && resultData.isNotEmpty) {
        final List<EmployeeModel> employees = resultData
            .map<EmployeeModel>((e) => EmployeeModel.fromJson(e))
            .toList();

        emit(ReviewFormState(
          employees: employees,
          selectedDate: DateTime.now(),
        ));
      } else {
        emit(ReviewFormState(employees: [], selectedDate: DateTime.now()));
      }
    } catch (e) {
      emit(ReviewError(e.toString()));
    }
  }

  // ── 2. Select Review Rating ─────────────────────────────────────────────────
  void _onSelectReview(SelectReviewEvent event, Emitter<ReviewState> emit) {
    if (state is ReviewFormState) {
      emit((state as ReviewFormState).copyWith(selectedReview: event.value));
    }
  }

  // ── 3. Select Employee ──────────────────────────────────────────────────────
  void _onSelectEmployee(SelectEmployeesEvent event, Emitter<ReviewState> emit) {
    if (state is ReviewFormState) {
      emit((state as ReviewFormState).copyWith(selectedEmpId: event.empId));
    }
  }

  // ── 4. Select Date ──────────────────────────────────────────────────────────
  void _onSelectDate(SelectDateEvent event, Emitter<ReviewState> emit) {
    if (state is ReviewFormState) {
      emit((state as ReviewFormState).copyWith(selectedDate: event.date));
    }
  }

  // ── 5. Save Review ──────────────────────────────────────────────────────────
  Future<void> _onSaveReview(
      SaveReviewEvent event,
      Emitter<ReviewState> emit,
      ) async {
    if (state is! ReviewFormState) return;
    final current = state as ReviewFormState;

    emit(current.copyWith(saving: true));

    try {
      final List<Map<String, dynamic>> master = [
        {
          "Id": event.existingId ?? 0,
          "ShopName": event.shopName.toUpperCase(),
          "MobileNo": event.mobileNo,
          "GoogleReview": current.selectedReview.toString(),
          "GoogleMsg": event.reviewMsg,
          "RefDate": current.selectedDate.toIso8601String().split('T')[0],
          "EmpReffid": current.selectedEmpId!,
        }
      ];

      final resultData = await repository.saveReview(body: master);

      emit(current.copyWith(saving: false));

      if (resultData != null && resultData.toString().isNotEmpty) {
        String message = '';

        if (resultData is Map) {
          bool isSuccess = resultData['ok'] ?? false;
          message = resultData['message'] ?? 'Something went wrong';
        } else {
          int id = int.tryParse(resultData.toString()) ?? 0;
          message = id > 0 ? 'Updated Successfully' : 'Unexpected response';
        }

        emit(ReviewSaveSuccess(message));
      }
    } catch (e) {
      emit(current.copyWith(saving: false));
      emit(ReviewError(e.toString()));
    }
  }

  // ── 6. Reset Form ───────────────────────────────────────────────────────────
  void _onResetForm(ResetFormEvent event, Emitter<ReviewState> emit) {
    if (state is ReviewFormState) {
      final current = state as ReviewFormState;
      emit(current.copyWith(
        selectedEmpId: null,
        selectedReview: 1,
        selectedDate: DateTime.now(),
      ));
    }
  }

  // ── 7. Load Grid Employees ──────────────────────────────────────────────────
  Future<void> _onLoadGridEmployees(
      LoadGridEmployeesEvent event,
      Emitter<ReviewState> emit,
      ) async {
    try {
      final comId = AppGlobals.storagenew.getInt('Comid') ?? 0;
      final resultData = await repository.fetchEmployees(comId: comId);

      if (resultData != null && resultData is List && resultData.isNotEmpty) {
        final List<EmployeeModel> employees = resultData
            .map<EmployeeModel>((e) => EmployeeModel.fromJson(e))
            .toList();

        emit(ReviewGridState(employees: employees));
      } else {
        emit(const ReviewGridState(employees: []));
      }
    } catch (e) {
      emit(ReviewError(e.toString()));
    }
  }

  // ── 8. Select Grid Employee ─────────────────────────────────────────────────
  void _onSelectGridEmployee(SelectGridEmployeeEvent event, Emitter<ReviewState> emit) {
    if (state is ReviewGridState) {
      final current = state as ReviewGridState;
      emit(current.copyWith(selectedEmpId: event.empId, reviews: []));

      if (current.fromDate != null && current.toDate != null) {
        add(const LoadReviewsEvent());
      }
    }
  }

  // ── 9. Select Date Range ────────────────────────────────────────────────────
  void _onSelectDateRange(SelectDateRangeEvent event, Emitter<ReviewState> emit) {
    if (state is ReviewGridState) {
      final current = state as ReviewGridState;
      emit(current.copyWith(fromDate: event.fromDate, toDate: event.toDate));

      if (current.selectedEmpId != null) {
        add(const LoadReviewsEvent());
      }
    }
  }

  // ── 10. Load Reviews ────────────────────────────────────────────────────────
  Future<void> _onLoadReviews(
      LoadReviewsEvent event,
      Emitter<ReviewState> emit,
      ) async {
    if (state is! ReviewGridState) return;
    final current = state as ReviewGridState;

    if (current.selectedEmpId == null ||
        current.fromDate == null ||
        current.toDate == null) return;

    emit(current.copyWith(loading: true));

    try {
      final from = DateFormat('yyyy-MM-dd').format(current.fromDate!);
      final to = DateFormat('yyyy-MM-dd').format(current.toDate!);

      final resultData = await repository.fetchReviews(
        comId: AppGlobals.Comid,
        fromDate: from,
        toDate: to,
        empId: current.selectedEmpId!,
      );

      if (resultData != null && resultData is List && resultData.isNotEmpty) {
        final List<Review> reviews = resultData
            .map<Review>((e) => Review.fromJson(e))
            .toList();
        emit(current.copyWith(reviews: reviews, loading: false));
      } else {
        emit(current.copyWith(reviews: [], loading: false));
      }
    } catch (e) {
      emit(current.copyWith(loading: false));
      emit(ReviewError(e.toString()));
    }
  }

  // ── 11. Delete Review ───────────────────────────────────────────────────────
  Future<void> _onDeleteReview(
      DeleteReviewEvent event,
      Emitter<ReviewState> emit,
      ) async {
    if (state is! ReviewGridState) return;
    final current = state as ReviewGridState;

    emit(current.copyWith(loading: true));

    try {
      await repository.deleteReview(id: event.id);

      emit(current.copyWith(loading: false));
      add(const LoadReviewsEvent());
    } catch (e) {
      emit(current.copyWith(loading: false));
      emit(ReviewError(e.toString()));
    }
  }
}