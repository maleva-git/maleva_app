import 'package:get_it/get_it.dart';
import 'package:maleva/core/forwarding_request/forwarding_request_api.dart';
import 'package:maleva/core/network/java_api_client.dart';

/// Forwarding requests on the shared Java API (change forwarding-requests-on-shared-java-api).
void registerForwardingRequestsFeature(GetIt sl) {
  if (!sl.isRegistered<ForwardingRequestApi>()) {
    sl.registerLazySingleton<ForwardingRequestApi>(() => ForwardingRequestApi(sl<JavaApiClient>().dio));
  }
}
