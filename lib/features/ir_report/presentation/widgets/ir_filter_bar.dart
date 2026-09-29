import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/widgets/app_form_fields.dart';

import '../../domain/entities/ir_filter.dart';
import '../list/bloc/ir_list_bloc.dart';
import 'ir_format.dart';

/// Search, date range and status filters above the IR list.
class IrFilterBar extends StatelessWidget {
  const IrFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IrListBloc, IrListState>(
      buildWhen: (previous, current) =>
          previous.filter != current.filter || previous.statuses != current.statuses,
      builder: (context, state) {
        final bloc = context.read<IrListBloc>();
        final filter = state.filter;
        void apply(IrFilter next) => bloc.add(IrListFilterChanged(next));

        return Container(
          color: AppTokens.surfaceCard,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _SearchBox(
                      initialText: filter.search,
                      onChanged: (text) => bloc.add(IrListSearchChanged(text)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _DateRangeButton(filter: filter, onChanged: apply),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 32,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FilterChip(
                      label: 'Open only',
                      selected: filter.openOnly,
                      onTap: () => apply(filter.copyWith(openOnly: !filter.openOnly)),
                    ),
                    _FilterChip(
                      label: 'All statuses',
                      selected: filter.statusId == 0,
                      onTap: () => apply(filter.copyWith(statusId: 0)),
                    ),
                    for (final status in state.statuses)
                      _FilterChip(
                        label: status.name,
                        color: IrFormat.statusColor(status.colorCode),
                        selected: filter.statusId == status.id,
                        onTap: () => apply(filter.copyWith(
                          statusId: filter.statusId == status.id ? 0 : status.id,
                        )),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Holds its own text: the bloc's copy of the search is debounced and trimmed,
/// so feeding it back into the box would undo what the user just typed.
class _SearchBox extends StatefulWidget {
  const _SearchBox({required this.initialText, required this.onChanged});

  final String initialText;
  final ValueChanged<String> onChanged;

  @override
  State<_SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<_SearchBox> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialText);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _changed(String text) {
    setState(() {});
    widget.onChanged(text);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _changed,
      textInputAction: TextInputAction.search,
      style: AppTypography.bodyLarge(color: AppTokens.textPrimary),
      decoration: appInputDecoration(
        hint: 'Search description, truck, driver',
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: () {
                  _controller.clear();
                  _changed('');
                },
              ),
      ),
    );
  }
}

class _DateRangeButton extends StatelessWidget {
  const _DateRangeButton({required this.filter, required this.onChanged});

  final IrFilter filter;
  final ValueChanged<IrFilter> onChanged;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final lastDate = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final from = filter.fromDate;
    final to = filter.toDate;
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: lastDate,
      initialDateRange: from != null && to != null && !to.isAfter(lastDate)
          ? DateTimeRange(start: from, end: to)
          : null,
    );
    if (range == null) return;
    onChanged(filter.copyWith(fromDate: () => range.start, toDate: () => range.end));
  }

  @override
  Widget build(BuildContext context) {
    final from = filter.fromDate;
    final to = filter.toDate;
    final hasRange = from != null && to != null;
    final label = hasRange
        ? '${IrFormat.shortDate(from)} - ${IrFormat.shortDate(to)}'
        : 'Any date';

    return Material(
      color: AppTokens.brandLight,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _pick(context),
        child: SizedBox(
          height: 44,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 10),
              const Icon(Icons.date_range_rounded, size: 16, color: AppTokens.brandPrimary),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.bodySmall(
                  color: AppTokens.brandDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (hasRange)
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onChanged(filter.copyWith(fromDate: () => null, toDate: () => null)),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.close_rounded, size: 14, color: AppTokens.brandDark),
                  ),
                )
              else
                const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppTokens.brandPrimary;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected ? accent.withValues(alpha: 0.14) : AppTokens.surfacePage,
        shape: StadiumBorder(
          side: BorderSide(color: selected ? accent : AppTokens.surfaceBorder),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Text(
                label,
                style: AppTypography.bodySmall(
                  color: selected ? accent : AppTokens.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
