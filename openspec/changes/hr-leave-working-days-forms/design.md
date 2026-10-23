# Design

Files: `driverleave/data/leave_form.dart` (`LeaveKind`), `leave_calendar.dart` (counter + `dayCount`), `leave_request_model.dart` (`part`, `workingDays`, `lengthLabel`), `leave_repository.dart` (`getCalendar`), `core/employee/leave_api.dart` (`part`, `workWeek`, `holidays`), the bloc event, `leave_request_form_sheet.dart`, the four tabs.

The preview repeats the backend rules (`LeaveLength`): whole days = each date's calendar value (1 / ½ / 0); morning
= ½ on a worked day; afternoon = ½ only on a full day; hours = hours ÷ 9 up to the day's value. The server's count
is the one stored. Half days are stored as the date 00:00–12:00 (morning) or 12:00–23:59 (afternoon).
