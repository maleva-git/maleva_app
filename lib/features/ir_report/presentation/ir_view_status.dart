import 'package:equatable/equatable.dart';
import 'package:maleva/core/network/legacy_api_exception.dart';

enum IrViewStatus { initial, loading, success, failure }

/// A one-off message for the screen to show (a snackbar).
class IrUiMessage extends Equatable {
  IrUiMessage(this.text, {this.isError = false}) : serial = _nextSerial++;

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
/// one, otherwise the error text without Dart's "Exception: " prefix.
String describeError(Object error) {
  if (error is LegacyApiException) return error.message;
  final text = error.toString().replaceFirst('Exception: ', '').trim();
  return text.isEmpty ? 'Something went wrong. Please try again.' : text;
}
