import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/rti/rti_api.dart';

void main() {
  group('C3 release no on the stop card', () {
    test('only forwarding stops get the button', () {
      expect(isForwardingStop('SEAL'), isTrue);
      expect(isForwardingStop('BREAK_SEAL'), isTrue);
      expect(isForwardingStop('SEAL,BREAK_SEAL'), isTrue);
      expect(isForwardingStop('K2 Clearance'), isTrue);
      expect(isForwardingStop('PICKUP'), isFalse);
      expect(isForwardingStop(''), isFalse);
    });

    test('reads the Java stop job as it is', () {
      final job = StopJob.fromJava({
        'jobId': 22469,
        'jobNo': 'MY002605950',
        'customer': 'ACS',
        'leg': 2,
        'formType': 'K8',
        'releaseNo': null,
      });
      expect(job.jobId, 22469);
      expect(job.leg, 2);
      expect(job.releaseNo, isNull);
      expect(StopJob.fromJava({}).leg, 1);
    });
  });
}
