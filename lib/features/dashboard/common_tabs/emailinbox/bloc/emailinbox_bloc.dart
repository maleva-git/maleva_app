import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'dart:convert';
import '../data/emailinbox_repository.dart';
import 'emailinbox_event.dart';
import 'emailinbox_state.dart';

class EmailBloc extends Bloc<EmailEvent, EmailState> {
  // ❌ REMOVED: final BuildContext context;
  final EmailInboxRepository repository; // ✅ Injected Repository

  EmailBloc({required this.repository}) : super(const EmailInitial()) {
    on<LoadEmployeesEvent>(_onLoadEmployees);
    on<SelectEmployeeEvent>(_onSelectEmployee);
    on<LoadEmailsEvent>(_onLoadEmails);
    on<ToggleEmailActiveEvent>(_onToggleActive);
    on<ToggleEmailUnreadEvent>(_onToggleUnread);
    on<ToggleEmailRepliedEvent>(_onToggleReplied);
    on<SaveEmailsEvent>(_onSaveEmails);
  }

  // ── 1. Load Employees ───────────────────────────────────────────────────────
  Future<void> _onLoadEmployees(
      LoadEmployeesEvent event,
      Emitter<EmailState> emit,
      ) async {
    emit(const EmployeesLoading());

    try {
      final comId = AppGlobals.storagenew.getInt('Comid') ?? 0;

      // ✅ REFACTORED: Call repository
      final resultData = await repository.fetchEmployees(comId: comId);

      if (resultData != null && resultData is List && resultData.isNotEmpty) {
        final List<EmployeeModel> employees = resultData
            .map<EmployeeModel>((e) => EmployeeModel.fromJson(e))
            .toList();

        final selected = employees.isNotEmpty ? employees.first : null;

        emit(EmployeesLoaded(
          employees: employees,
          selectedEmployee: selected,
        ));

        // Auto load emails for first employee
        if (selected != null) {
          add(LoadEmailsEvent(selected.Id));
        }
      } else {
        emit(const EmployeesLoaded(employees: []));
      }
    } catch (e) {
      emit(EmailError(e.toString()));
    }
  }

  // ── 2. Select Employee → Load Emails ───────────────────────────────────────
  void _onSelectEmployee(
      SelectEmployeeEvent event,
      Emitter<EmailState> emit,
      ) {
    if (state is EmployeesLoaded) {
      final current = state as EmployeesLoaded;
      emit(current.copyWith(
        selectedEmployee: event.employee,
        emails: [],
      ));
      add(LoadEmailsEvent(event.employee.Id));
    }
  }

  // ── 3. Load Emails ──────────────────────────────────────────────────────────
  // ── 3. Load Emails ──────────────────────────────────────────────────────────
  Future<void> _onLoadEmails(
      LoadEmailsEvent event,
      Emitter<EmailState> emit,
      ) async {
    if (state is EmployeesLoaded) {
      final current = state as EmployeesLoaded;
      emit(current.copyWith(emailsLoading: true));

      try {
        final master = [
          {"Id": event.empId}
        ];

        final result = await repository.fetchEmails(body: master);
        List<EmailModel> emails = [];

        // ✅ FIX: result null illama irukka nu check pandrom
        if (result != null) {
          Map<String, dynamic> parsedData;

          // ✅ FIX: String-a vantha atha Map-ku decode pandrom
          if (result is String) {
            parsedData = jsonDecode(result);
          } else if (result is Map<String, dynamic>) {
            parsedData = result;
          } else {
            throw Exception("Unknown API response format");
          }

          // List extract pandrom
          if (parsedData["unread_unreplied_emails"] != null &&
              parsedData["unread_unreplied_emails"] is List) {

            final emailsJson = parsedData["unread_unreplied_emails"] as List;
            emails = emailsJson
                .map((e) => EmailModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
        }

        emit(current.copyWith(
          emails: emails,
          emailsLoading: false,
        ));
      } catch (e) {
        print("Parsing Error: $e"); // Debugging-ku use aagum
        emit(current.copyWith(emails: [], emailsLoading: false));
      }
    }
  }
  // ── 4. Toggle Active ────────────────────────────────────────────────────────
  void _onToggleActive(ToggleEmailActiveEvent event, Emitter<EmailState> emit) {
    if (state is EmployeesLoaded) {
      final current = state as EmployeesLoaded;
      final updated = List<EmailModel>.from(current.emails);
      updated[event.index] = updated[event.index].copyWith(isActive: event.value);
      emit(current.copyWith(emails: updated));
    }
  }

  // ── 5. Toggle Unread ────────────────────────────────────────────────────────
  void _onToggleUnread(ToggleEmailUnreadEvent event, Emitter<EmailState> emit) {
    if (state is EmployeesLoaded) {
      final current = state as EmployeesLoaded;
      final updated = List<EmailModel>.from(current.emails);
      updated[event.index] = updated[event.index].copyWith(isUnread: event.value);
      emit(current.copyWith(emails: updated));
    }
  }

  // ── 6. Toggle Replied ───────────────────────────────────────────────────────
  void _onToggleReplied(ToggleEmailRepliedEvent event, Emitter<EmailState> emit) {
    if (state is EmployeesLoaded) {
      final current = state as EmployeesLoaded;
      final updated = List<EmailModel>.from(current.emails);
      updated[event.index] = updated[event.index].copyWith(isReplied: event.value);
      emit(current.copyWith(emails: updated));
    }
  }

  // ── 7. Save Emails ──────────────────────────────────────────────────────────
  Future<void> _onSaveEmails(
      SaveEmailsEvent event,
      Emitter<EmailState> emit,
      ) async {
    if (state is! EmployeesLoaded) return;
    final current = state as EmployeesLoaded;

    final toSave = current.emails.where((e) => e.isActive).toList();
    if (toSave.isEmpty) return;

    emit(current.copyWith(saving: true));

    try {
      final payload = toSave
          .map((e) => {
        'Id': 0,
        'EmployeeRefId': current.selectedEmployee?.Id,
        'EmailID': e.emailId,
        'Subject': e.subject,
        'Sender': e.sender,
        'MessageId': e.messageId,
        'ReceivedDate': e.receivedDate.toIso8601String(),
        'Comid': AppGlobals.storagenew.getInt('Comid') ?? 0,
        'IsUnread': e.isUnread ? 1 : 0,
        'IsReplied': e.isReplied ? 1 : 0,
        'Active': 1,
      })
          .toList();

      // ✅ REFACTORED: Call repository
      final result = await repository.saveEmails(body: payload);

      emit(current.copyWith(saving: false));

      if (result != null && result.toString().isNotEmpty) {
        emit(EmailSaveSuccess(result.toString()));
      } else {
        emit(const EmailError("Failed to save emails"));
      }
    } catch (e) {
      emit(current.copyWith(saving: false));
      emit(EmailError(e.toString()));
    }
  }
}