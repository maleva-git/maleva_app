import 'package:equatable/equatable.dart';

enum PlansNoticeKind { success, info, error }

/// A one-off message for the page to show (the web's toasts). [id] grows with each new notice,
/// so the same text twice still shows twice.
class PlansNotice extends Equatable {
  const PlansNotice(this.id, this.message, {this.kind = PlansNoticeKind.error});

  final int id;
  final String message;
  final PlansNoticeKind kind;

  @override
  List<Object?> get props => [id, message, kind];
}
