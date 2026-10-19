import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/rti/models/fleet_expiry.dart';
import 'package:maleva/core/widgets/ui/picker_sheet.dart';

/// RTI's driver picker warns with every pending / approved leave (leave-approval-rules).
void main() {
  test('RTI lists each leave of the driver, skips rejected, and colours approved first', () {
    final warnings = FleetExpiry.driver({
      'leaves': [
        {'StatusName': 'Pending', 'LeaveTypeName': 'SICK', 'FromDate': '2026-10-21T00:00:00', 'ToDate': '2026-10-21T00:00:00'},
        {'StatusName': 'Rejected', 'FromDate': '2026-10-19T00:00:00', 'ToDate': '2026-10-19T00:00:00'},
        {'StatusName': 'APPROVED', 'LeaveTypeName': 'ANNUAL', 'FromDate': '2026-10-19T00:00:00', 'ToDate': '2026-10-20T00:00:00'},
      ]
    }, now: DateTime(2026, 10, 19, 8));

    expect(warnings.map((w) => w.message), [
      'Leave (APPROVED) - ANNUAL: 19/10/2026 to 20/10/2026, on leave today',
      'Leave (PENDING) - SICK: 21/10/2026 to 21/10/2026, starts in 2 days',
    ]);
    expect(FleetExpiry.severityOf(warnings), PickSeverity.leaveApproved);
  });
}
