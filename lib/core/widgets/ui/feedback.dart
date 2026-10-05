import 'package:flutter/material.dart';
import 'package:maleva/core/theme/app_theme.dart';

/// A confirm step in a bottom sheet (phone) or a dialog (tablet), with the web's wording.
/// Answers true when the user confirms.
Future<bool> showConfirm(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Yes',
  String cancelLabel = 'Cancel',
  bool destructive = false,
}) async {
  final cs = context.cs;
  final actions = Row(children: [
    Expanded(child: OutlinedButton(onPressed: () => Navigator.of(context, rootNavigator: true).pop(false), child: Text(cancelLabel))),
    const SizedBox(width: 12),
    Expanded(
      child: FilledButton(
        style: destructive ? FilledButton.styleFrom(backgroundColor: cs.error, foregroundColor: cs.onError) : null,
        onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
        child: Text(confirmLabel),
      ),
    ),
  ]);
  final body = Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
    const SizedBox(height: 8),
    Text(message, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: context.mc.muted)),
    const SizedBox(height: 22),
    actions,
  ]);
  final wide = MediaQuery.sizeOf(context).width >= 600;
  final answer = wide
      ? await showDialog<bool>(
          context: context,
          useRootNavigator: true,
          builder: (_) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480), child: Padding(padding: const EdgeInsets.all(24), child: body)),
          ),
        )
      : await showModalBottomSheet<bool>(
          context: context,
          useRootNavigator: true,
          builder: (_) => SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), child: body)),
        );
  return answer ?? false;
}

enum SnackKind { success, info, error }

/// A short floating message (success / info / error). Replaces the previous one.
void showSnack(BuildContext context, String message, {SnackKind kind = SnackKind.success, Duration? duration}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  final cs = context.cs;
  final icon = switch (kind) { SnackKind.success => Icons.check_circle_outline, SnackKind.info => Icons.info_outline, SnackKind.error => Icons.error_outline };
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      duration: duration ?? Duration(seconds: kind == SnackKind.error ? 5 : 3),
      backgroundColor: kind == SnackKind.error ? cs.error : null,
      content: Row(children: [
        Icon(icon, color: kind == SnackKind.error ? cs.onError : null),
        const SizedBox(width: 12),
        Expanded(child: Text(message)),
      ]),
    ));
}
