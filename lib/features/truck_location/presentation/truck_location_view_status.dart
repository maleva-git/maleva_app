import 'package:equatable/equatable.dart';
import 'package:maleva/core/network/legacy_api_exception.dart';

enum TruckLocationStatus { initial, loading, success, failure }

/// How the day list is ordered. [shared] is the drag order every planner
/// shares; the other two are local views and disable dragging.
enum TruckLocationSort { shared, byLocation, byTruck }

/// A one-off message for the screen to show (a snackbar).
class TruckLocationUiMessage extends Equatable {
  TruckLocationUiMessage(this.text, {this.isError = false}) : serial = _nextSerial++;

  static int _nextSerial = 0;

  final String text;
  final bool isError;

  /// Makes the same text raised twice two different states, so a listener
  /// fires both times.
  final int serial;

  @override
  List<Object?> get props => [text, isError, serial];
}

/// A readable reason for a failed call: the server's own message when it sent
/// one (a 400 comes back as typed), otherwise the error text without Dart's
/// "Exception: " prefix.
String describeTruckLocationError(Object error) {
  if (error is LegacyApiException) return error.message;
  final text = error.toString().replaceFirst('Exception: ', '').trim();
  return text.isEmpty ? 'Something went wrong. Please try again.' : text;
}
