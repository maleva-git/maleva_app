import 'api_client.dart';
import 'legacy_api_repository.dart';

/// The existing HTTP contract, separate from legacy Dio response semantics.
abstract interface class JsonTransport {
  Future<dynamic> postRequest(String url, dynamic body,
      {Map<String, String>? headers, bool skipAuth = false});
}

class ExistingHttpTransport implements JsonTransport {
  const ExistingHttpTransport();
  @override
  Future<dynamic> postRequest(String url, dynamic body,
          {Map<String, String>? headers, bool skipAuth = false}) =>
      ApiClient.postRequest(url, body, headers: headers, skipAuth: skipAuth);
}

/// Keeps the legacy helper's language header mutation and null-body handling.
class LegacyArrayTransport {
  final LegacyApiRepository repository;
  const LegacyArrayTransport(this.repository);

  Future<dynamic> select(String url, dynamic body, Map<String, String> headers) =>
      repository.apiAllinoneSelectArray(url, body, headers);
}
