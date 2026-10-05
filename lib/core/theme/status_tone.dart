/// Status colours with the same meaning everywhere, in the order of the web's
/// `planningStatusUtils.getStatusTone` (`maleva-front-end/src/features/Planning/components/planningStatusUtils.ts:48-73`).
enum StatusTone { success, warning, danger, info, primary, accent, neutral }

/// The web's fallback pool for statuses no rule matches (`planningStatusUtils.ts:19-27`).
const List<StatusTone> _fallbackPool = [
  StatusTone.primary,
  StatusTone.info,
  StatusTone.success,
  StatusTone.warning,
  StatusTone.accent,
  StatusTone.danger,
  StatusTone.neutral,
];

final RegExp _danger = RegExp(r'(cancel|reject|fail|error|void|close|stop|holded)');
final RegExp _success = RegExp(r'(complete|completed|deliver|delivered|done|success|finish|finished)');
final RegExp _warning = RegExp(r'(pending|await|wait|queue|queued|hold|draft|new)');
final RegExp _info = RegExp(r'(progress|processing|active|ongoing|transit|loading|running|moving)');
final RegExp _primary = RegExp(r'(ready|booked|assigned|confirm|confirmed|approve|approved|plan|planned|schedule|scheduled)');
final RegExp _accent = RegExp(r'(partial|amend|rework|review|revise|revised|update|updated)');

StatusTone statusToneOf(String? status) {
  final s = (status ?? '').trim().toLowerCase();
  if (s.isEmpty) return StatusTone.neutral;
  if (_danger.hasMatch(s)) return StatusTone.danger;
  if (_success.hasMatch(s)) return StatusTone.success;
  if (_warning.hasMatch(s)) return StatusTone.warning;
  if (_info.hasMatch(s)) return StatusTone.info;
  if (_primary.hasMatch(s)) return StatusTone.primary;
  if (_accent.hasMatch(s)) return StatusTone.accent;
  return _fallbackPool[hashText(s) % _fallbackPool.length];
}

/// djb2 as the web computes it (`planningStatusUtils.ts:33-40`): 32-bit signed arithmetic, then abs.
int hashText(String value) {
  var hash = 0;
  for (final unit in value.codeUnits) {
    hash = ((hash << 5) - hash + unit).toSigned(32);
  }
  return hash.abs();
}
