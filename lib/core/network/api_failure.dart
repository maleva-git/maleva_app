/// A failed API call. [message] is the server's own reason when it sent one,
/// so a screen can show it ("Status 9 was not found for this company")
/// instead of a status code.
class ApiFailure implements Exception {
  const ApiFailure(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
