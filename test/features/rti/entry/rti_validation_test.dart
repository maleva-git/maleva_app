import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/rti/models/rti_form.dart';
import 'package:maleva/features/rti/models/rti_job_row.dart';
import 'package:maleva/features/rti/models/rti_rules.dart';

import 'rti_test_data.dart';

// R/model/rti.validation.test.ts, plus the header checks of rti.validation.ts:46-81.
List<String> errorsFor(List<RtiJobRow> grid) => RtiRules.validate(rtiState(), grid);

void main() {
  group('validateForm - job rows', () {
    test('accepts rows whose job was looked up', () => expect(errorsFor([rtiJob('100')]), isEmpty));

    test('refuses a pasted job number (no lookup, so no job id), naming the row and the job', () {
      expect(errorsFor([rtiJob('100'), const RtiJobRow(jobNo: 'TR002699999', salary: '60')]),
          ['Row 2: job TR002699999 was not found. Press Enter in Job No to look it up, or remove the row.']);
    });

    test('refuses a job whose lookup said "Job not found"', () {
      expect(errorsFor([const RtiJobRow(jobNo: ' TR00XXXX ')]),
          ['Row 1: job TR00XXXX was not found. Press Enter in Job No to look it up, or remove the row.']);
    });

    test('allows the same job that is already on other RTIs', () => expect(errorsFor([rtiJob('100')]), isEmpty));

    test('allows one job filling several rows of the same RTI', () => expect(errorsFor([rtiJob('100'), rtiJob('40')]), isEmpty));

    test('still reports an empty Job No the old way', () => expect(errorsFor([const RtiJobRow()]), ['Row 1: Job No is required']));

    test('reports every bad row, not just the first', () {
      expect(errorsFor([rtiJob('100'), const RtiJobRow(jobNo: 'TR1'), const RtiJobRow(jobNo: 'TR2')]), hasLength(2));
    });
  });

  test('every header problem together, in the web order', () {
    expect(RtiRules.validate(const RtiForm(rtiDate: ''), const []), [
      'Please select Driver Name',
      'Please select Vehicle Number',
      'Please select RTI Date',
      'Please add at least one job',
    ]);
  });

  group('vehicle licence check (new RTI only)', () {
    final now = DateTime(2026, 10, 5, 9);
    test('names the licences ending within 5 days', () {
      expect(RtiRules.truckLicenseMessage({'rotexMyExp': '2026-10-08', 'puspacomExp': '2026-10-01', 'serviceExp': '2027-01-01'}, now: now),
          'RotexMy, Puspacom - License expired / Going to be expired !!');
    });
    test('none ending → no message', () => expect(RtiRules.truckLicenseMessage({'rotexMyExp': '2026-12-01'}, now: now), isNull));
  });
}
