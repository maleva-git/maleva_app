import 'package:maleva/core/mailmonitor/response_report_models.dart';

/// The booking speed page's small rules, as the web's `model/bookingSpeed.ts` (change booking-speed-employee).

/// The server's group for bookings whose sale order names no employee; never ranked.
const noEmployee = 'No employee on the sale order';

/// "SH" for "SHALINI", "SS" for "SANTHIA SARAVANAN".
String initials(String name) {
  final words = name.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).take(2);
  final s = words.map((w) => w[0].toUpperCase()).join();
  return s.isEmpty ? '?' : s;
}

/// A bar's share of the slowest (0..1); at least 0.04 so a fast one still shows.
double barShare(double? value, double max) {
  if (value == null || max <= 0) return 0;
  return (value / max).clamp(0.04, 1.0);
}

/// Jobs of one status (null = all) whose job number, employee or mailbox contains [query].
List<BookingJob> filterJobs(List<BookingJob> jobs, BookingStatus? status, String query) {
  final q = query.trim().toLowerCase();
  return [
    for (final j in jobs)
      if ((status == null || j.status == status) &&
          (q.isEmpty ||
              j.jobNumber.toLowerCase().contains(q) ||
              j.employee.toLowerCase().contains(q) ||
              (j.mailbox ?? '').toLowerCase().contains(q)))
        j,
  ];
}
