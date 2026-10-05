import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/theme/status_tone.dart';
import 'package:maleva/core/widgets/ui/formats.dart';

/// Status colours and date display follow the web (planningStatusUtils.ts, planningDateFormat.test.ts).
void main() {
  test('rules in the web order', () {
    expect(statusToneOf(''), StatusTone.neutral);
    expect(statusToneOf(null), StatusTone.neutral);
    expect(statusToneOf('Cancelled'), StatusTone.danger);
    expect(statusToneOf('Delivered'), StatusTone.success);
    expect(statusToneOf('Pending'), StatusTone.warning);
    expect(statusToneOf('In Transit'), StatusTone.info);
    expect(statusToneOf('Assigned'), StatusTone.primary);
    expect(statusToneOf('Revised'), StatusTone.accent);
    expect(statusToneOf('On Hold'), StatusTone.warning);
  });

  test('unknown statuses use the djb2 pool like the web', () {
    // JS: hashText('xyz') = 119193; 119193 % 7 = 4 → accent
    expect(hashText('xyz'), 119193);
    expect(statusToneOf('XYZ'), StatusTone.accent);
  });

  test('planning date display', () {
    expect(Fmt.planningDateTime('2026-10-05 08:30:00'), '05/10/2026 08:30');
    expect(Fmt.planningDateTime('2026-10-05T08:30'), '05/10/2026 08:30');
    expect(Fmt.planningDateTime('2026-10-05'), '05/10/2026');
    expect(Fmt.planningDateTime('2026-10-05 00:00:00'), '05/10/2026 00:00');
    expect(Fmt.planningDateTime(''), '');
    expect(Fmt.planningDateTime(null), '');
    expect(Fmt.planningDateTime('soon'), 'soon');
    expect(Fmt.rm(1245), 'RM 1,245.00');
  });
}
