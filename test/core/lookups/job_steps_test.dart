import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/lookups/job_steps.dart';

void main() {
  test('the statuses and steps come out of the one-element answer', () {
    final answer = [
      {
        'JobTypeDetails': [{'ID': 1, 'Description': 'Gate in'}],
        'JobStatusDetails': [{'ID': 9, 'Status': 3, 'StatusName': 'ARRIVED'}],
      }
    ];

    expect(JobSteps.statuses(answer).single['StatusName'], 'ARRIVED');
    expect(JobSteps.details(answer).single['Description'], 'Gate in');
  });

  test('anything else is empty', () {
    expect(JobSteps.statuses(null), isEmpty);
    expect(JobSteps.statuses(const []), isEmpty);
    expect(JobSteps.details({'Message': 'error'}), isEmpty);
  });
}
