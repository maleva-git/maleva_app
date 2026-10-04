import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:maleva/core/config/app_config.dart';
import 'package:maleva/core/lookups/shared_lookups.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_api_client.dart';

typedef _Handler = Future<dynamic> Function(SharedLookups lookups, _Call call);

/// Answers the app's old .NET lookup calls from the shared Java
/// APIs (change `use-shared-lookup-apis`; fuel moved to `FuelEntryApi`), in the JSON the callers already
/// read, so the ~60 call sites, their models and screens stay unchanged.
///
/// The shared HTTP helpers (`ApiClient`, `LegacyApiRepository`, the legacy
/// `DioClient`) ask [handles] before sending; a handled call never reaches
/// the network as a .NET call. A failure looks like the .NET one: HTTP 500
/// with `{IsSuccess: false, Message}`.
class LegacyCallAdapter {
  LegacyCallAdapter._();

  static final Map<String, _Handler> _handlers = {
    'truckapp/gettruck': (l, c) => l.trucks(c.comid, type: c.query('type')),
    'truckapp/selecttruck': (l, c) {
      if ((c.query('Column') ?? '').toLowerCase() != 'id') {
        throw const ApiFailure('Only a truck by Id can be read here');
      }
      return l.truckDetails(c.comid, int.tryParse(c.query('Keyword') ?? '') ?? 0);
    },
    'truckapp/inserttruck': (l, c) => l.saveTruck(c.comid, c.firstRow),
    'driverapp/getdriver': (l, c) => l.drivers(c.comid, type: c.query('type')),
    'customerapp/getcustomer': (l, c) => l.customers(c.comid),
    'addressapp/selectdistinctaddress': (l, c) => l.addressNames(c.comid),
    'addressapp/selectaddress': (l, c) => l.addresses(c.comid, keyword: c.query('KeyWord') ?? ''),
    'jobtypeapp/selectjobtype': (l, c) => l.jobTypes(c.comid),
    'jobtypeapp/selectjoballdata': (l, c) =>
        l.jobSteps(c.comid, c.intQuery('Jobid') ?? c.intQuery('JobMasterRefId') ?? 0),
    'jobstatusapp/selectjobstatus': (l, c) => l.jobStatuses(c.comid),
    'agentapp/selectagentall': (l, c) =>
        l.agents(c.comid, agentCompanyId: c.intQuery('Jobid') ?? c.intQuery('AgentCompanyRefId') ?? 0),
    'agentcompanyapp/selectagentcompany': (l, c) => l.agentCompanies(c.comid),
    'itemapp/getproductlist': (l, c) => l.products(c.comid),
  };

  static final RegExp _path = RegExp(r'^/+api/([^/?]+)/([^/?]+)');

  /// True when [url] is an old call the shared APIs answer.
  static bool handles(String url) => _keyOf(url) != null;

  /// The old JSON for the call; throws [ApiFailure] with the server's message.
  static Future<dynamic> answer(String url, {dynamic body, Map<String, dynamic>? headers}) {
    final key = _keyOf(url)!;
    return _handlers[key]!(_lookups(), _Call(Uri.parse(url), body, headers ?? const {}));
  }

  /// [answer] as a Dio response; a failure is a DioException carrying the
  /// .NET-style 500 envelope, so callers' error handling stays the same.
  static Future<Response<dynamic>> asResponse(String url, {dynamic body, Map<String, dynamic>? headers}) async {
    final options = RequestOptions(path: url, method: 'POST');
    try {
      return Response<dynamic>(requestOptions: options, statusCode: 200, data: await answer(url, body: body, headers: headers));
    } on ApiFailure catch (e) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        message: e.message,
        response: Response<dynamic>(
            requestOptions: options, statusCode: 500, data: {'IsSuccess': false, 'StatusCode': 0, 'Message': e.message}),
      );
    }
  }

  static String? _keyOf(String url) {
    if (!url.startsWith(AppConfig.baseUrl)) return null;
    final match = _path.firstMatch(url.substring(AppConfig.baseUrl.length));
    if (match == null) return null;
    final key = '${match.group(1)}/${match.group(2)}'.toLowerCase();
    return _handlers.containsKey(key) ? key : null;
  }

  static SharedLookups _lookups() {
    final sl = GetIt.instance;
    return sl.isRegistered<SharedLookups>() ? sl<SharedLookups>() : SharedLookups(sl<JavaApiClient>().dio);
  }
}

/// One old call: its query (names matched without case, as .NET did), body and headers.
class _Call {
  _Call(Uri uri, this.body, Map<String, dynamic> headers)
      : _query = {for (final e in uri.queryParameters.entries) e.key.toLowerCase(): e.value},
        _headers = {for (final e in headers.entries) e.key.toLowerCase(): e.value};

  final dynamic body;
  final Map<String, String> _query;
  final Map<String, dynamic> _headers;

  String? query(String name) => _query[name.toLowerCase()];

  int? intQuery(String name) => int.tryParse(query(name) ?? '');

  int? intHeader(String name) => int.tryParse('${_headers[name.toLowerCase()] ?? ''}');

  int get comid => intQuery('Comid') ?? 0;

  Map<String, dynamic> get bodyMap => body is Map ? Map<String, dynamic>.from(body as Map) : const {};

  Map<String, dynamic> get firstRow {
    final b = body;
    if (b is List && b.isNotEmpty && b.first is Map) return Map<String, dynamic>.from(b.first as Map);
    return b is Map ? Map<String, dynamic>.from(b) : const {};
  }
}
