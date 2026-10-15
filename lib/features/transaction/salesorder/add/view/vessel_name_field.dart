import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/vessel_master/vessel_master_models.dart';
import 'package:maleva/features/transaction/salesorder/add/bloc/vessel_suggest_cubit.dart';

/// A vessel name field of the sales form (change vessel-master-and-ptp-schedule): still a plain text
/// field - anything typed is kept - with up to five suggestions listed under it while it has focus.
/// Picking a row calls [onPicked]; leaving the field calls [onLeave] (the close-spelling check).
class VesselNameField extends StatefulWidget {
  const VesselNameField({
    super.key,
    required this.controller,
    required this.suggestions,
    required this.leg,
    required this.port,
    required this.enabled,
    required this.onChanged,
    required this.onPicked,
    required this.onLeave,
    this.decoration = const InputDecoration(),
    this.style,
  });

  final TextEditingController controller;
  final VesselSuggestCubit suggestions;

  /// `LOADING` or `OFF`.
  final String leg;

  /// That leg's port (loading: L port, off: O port), read when asking.
  final String Function() port;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final void Function(VesselSuggestion vessel, PtpCall? call) onPicked;
  final VoidCallback onLeave;
  final InputDecoration decoration;
  final TextStyle? style;

  @override
  State<VesselNameField> createState() => _VesselNameFieldState();
}

class _VesselNameFieldState extends State<VesselNameField> {
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_focusChanged);
  }

  void _focusChanged() {
    if (_focus.hasFocus) return;
    widget.suggestions.clear();
    widget.onLeave();
  }

  @override
  void dispose() {
    _focus.removeListener(_focusChanged);
    _focus.dispose();
    super.dispose();
  }

  void _pick(VesselSuggestionRow row) {
    widget.suggestions.clear();
    widget.onPicked(row.vessel, row.call);
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      TextField(
        controller: widget.controller,
        focusNode: _focus,
        enabled: widget.enabled,
        textCapitalization: TextCapitalization.characters,
        style: widget.style,
        decoration: widget.decoration,
        onChanged: (v) {
          widget.onChanged(v);
          widget.suggestions.query(v, leg: widget.leg, port: widget.port());
        },
      ),
      BlocBuilder<VesselSuggestCubit, List<VesselSuggestionRow>>(
        bloc: widget.suggestions,
        builder: (context, rows) {
          if (rows.isEmpty) return const SizedBox.shrink();
          // taps on the list count as taps on the field, so it keeps focus until a row is picked
          return TextFieldTapRegion(
            child: Card(
              margin: const EdgeInsets.only(top: 4),
              elevation: 3,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                for (var i = 0; i < rows.length; i++)
                  ListTile(
                    key: ValueKey('vessel_suggestion_$i'),
                    dense: true,
                    title: Text(_title(rows[i]), style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: _subtitle(rows[i]) == null ? null : Text(_subtitle(rows[i])!),
                    onTap: () => _pick(rows[i]),
                  ),
              ]),
            ),
          );
        },
      ),
    ]);
  }

  /// "TOCONAO MAERSK 636N"; an MMSW call has no voyage, so its SCN stands there ("XIN XU ZHOU SCN 267DF4").
  static String _title(VesselSuggestionRow r) {
    final voyage = r.call?.voyageText;
    return voyage == null ? r.vessel.vesselName : '${r.vessel.vesselName} $voyage';
  }

  static String? _subtitle(VesselSuggestionRow r) {
    final call = r.call;
    if (call == null) {
      final alias = r.vessel.matchedAlias;
      return alias == null ? null : 'was $alias';
    }
    String at(DateTime? d, bool estimated) =>
        d == null ? '-' : '${DateFormat('dd MMM HH:mm').format(d)}${estimated ? ' est.' : ''}';
    return [
      'ETA ${at(call.arrive, call.arriveEstimated)}',
      'ETD ${at(call.depart, call.departEstimated)}',
      // the SCN is in the title when there is no voyage
      if (call.scn != null && (call.voyage?.trim() ?? '').isNotEmpty) 'SCN ${call.scn}',
      if (call.isMmsw) call.sourceText,
    ].join(' · ');
  }
}
