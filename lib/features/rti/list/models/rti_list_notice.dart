import 'package:equatable/equatable.dart';

enum RtiNoticeKind { success, info, error }

/// A one-off message for the page (the web's toasts). [id] grows with each notice. A
/// [followUp] is shown after this one (the share's "report not attached" note).
class RtiListNotice extends Equatable {
  const RtiListNotice(this.id, this.message, {this.kind = RtiNoticeKind.error, this.duration, this.followUp});

  final int id;
  final String message;
  final RtiNoticeKind kind;
  final Duration? duration;
  final RtiListNotice? followUp;

  @override
  List<Object?> get props => [id, message, kind, duration, followUp];
}
