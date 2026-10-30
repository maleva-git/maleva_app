import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/features/dashboard/admin_dashboard/overview/view/overview_widgets.dart';

import '../bloc/ceo_dashboard_cubit.dart';
import '../data/ceo_analytics_models.dart';
import '../data/ceo_period.dart';
import 'ceo_widgets.dart';

/// The pieces every CEO report tab shares (change `ceo-analytics-dashboard`, app tabs 2026-10-17): the
/// scrolling page with pull-to-refresh, the period bar, the coloured hero card, the option chips and the
/// loading / error / empty states of a list.

/// Asks for a list after the frame when it has not been asked yet (also after a reload clears it).
void ceoEnsure(BuildContext context, String kind, String? key,
    {required (String, String) range, String? invoice, int? customer}) {
  final cubit = context.read<CeoDashboardCubit>();
  if (cubit.hasDetails(kind, key, range: range, invoice: invoice, customer: customer)) return;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!cubit.isClosed) cubit.loadDetails(kind, key, range: range, invoice: invoice, customer: customer);
  });
}

/// `16 Oct – 31 Oct 2026` (the year once when both days share it).
String ceoSpan((String, String) range) {
  final f = DateTime.tryParse(range.$1);
  final t = DateTime.tryParse(range.$2);
  if (f == null || t == null) return '${range.$1} – ${range.$2}';
  if (f == t) return DateFormat('d MMM yyyy').format(f);
  return '${DateFormat(f.year == t.year ? 'd MMM' : 'd MMM yyyy').format(f)} – ${DateFormat('d MMM yyyy').format(t)}';
}

/// A report tab's page: pull to refresh (fresh numbers and lists), [children] with the page gutter.
class CeoTabScroll extends StatelessWidget {
  const CeoTabScroll({super.key, required this.children, this.spendOnly = false});

  final List<Widget> children;

  /// Spend-only screens: a pull asks the spend flow and lists again, never the CEO overview.
  final bool spendOnly;

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    return RefreshIndicator(
      color: AppTokens.brandGradientStart,
      onRefresh: spendOnly
          ? () async => context.read<CeoDashboardCubit>().clearSpend()
          : context.read<CeoDashboardCubit>().reload,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(isTablet ? 20 : 12, 10, isTablet ? 20 : 12, 28),
        children: children,
      ),
    );
  }
}

/// The CEO period (This month, Last month, This quarter, This year) as chips with its days; the
/// Overview header has the same switch, so all tabs show one period.
class CeoPeriodBar extends StatelessWidget {
  const CeoPeriodBar({super.key, this.spendOnly = false});

  /// Spend-only screens (accounts / payable): a new period never loads the CEO overview.
  final bool spendOnly;

  @override
  Widget build(BuildContext context) => BlocBuilder<CeoDashboardCubit, CeoDashboardState>(
        buildWhen: (a, b) => a.period != b.period || a.loading != b.loading,
        builder: (context, s) {
          final cubit = context.read<CeoDashboardCubit>();
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              CeoChips(
                key: const Key('ceo_period_bar'),
                options: [for (final p in CeoPeriod.values) p.label],
                selected: s.period.index,
                color: AppTokens.brandGradientStart,
                onChanged: (i) {
                  if (CeoPeriod.values[i] == s.period) return;
                  if (spendOnly) {
                    cubit.choosePeriod(CeoPeriod.values[i]);
                  } else {
                    cubit.load(CeoPeriod.values[i]);
                  }
                },
              ),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.calendar_today_rounded, size: 12, color: AppTokens.textMuted),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(ceoSpan(cubit.range),
                      style: AppTypography.badgeText(color: AppTokens.textMuted, fontWeight: FontWeight.w600)),
                ),
                if (s.loading)
                  const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 1.6, color: AppTokens.brandGradientStart)),
              ]),
            ]),
          );
        },
      );
}

/// Options as rounded chips in one scrolling row; the chosen one is filled with [color].
class CeoChips extends StatelessWidget {
  const CeoChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.color = AppTokens.brandGradientStart,
    this.icons,
  });

  final List<String> options;
  final int selected;
  final ValueChanged<int> onChanged;
  final Color color;
  final List<IconData>? icons;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (var i = 0; i < options.length; i++)
            Padding(
              padding: EdgeInsets.only(right: i == options.length - 1 ? 0 : 6),
              child: _Chip(
                label: options[i],
                icon: icons == null || i >= icons!.length ? null : icons![i],
                selected: i == selected,
                color: color,
                onTap: () => onChanged(i),
              ),
            ),
        ]),
      );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.color, required this.onTap, this.icon});

  final String label;
  final IconData? icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : const Color(0xFF1A2E5A);
    return Material(
      color: selected ? color : AppTokens.surfaceCard,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? color : AppTokens.surfaceBorder),
            boxShadow: selected
                ? [BoxShadow(color: color.withValues(alpha: 0.28), blurRadius: 8, offset: const Offset(0, 3))]
                : null,
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: 5)],
            Text(label, style: AppTypography.bodySmall(color: fg, fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }
}

/// The coloured card on top of a report tab: icon, title and line, the big number and up to three
/// small facts.
class CeoHero extends StatelessWidget {
  const CeoHero({
    super.key,
    required this.title,
    required this.icon,
    required this.accent,
    required this.value,
    this.subtitle,
    this.sub,
    this.facts = const [],
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final PanelAccent accent;
  final String value;
  final String? sub;
  final List<(String, String)> facts;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [accent.start, accent.strong], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: accent.end.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 7))],
        ),
        child: Stack(children: [
          Positioned(
            right: -30,
            top: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.09)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration:
                      BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, size: 19, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(title.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall(color: Colors.white, fontWeight: FontWeight.w800)),
                    if (subtitle != null)
                      Text(subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.badgeText(
                              color: Colors.white.withValues(alpha: 0.85), fontWeight: FontWeight.w500)),
                  ]),
                ),
                if (trailing != null) trailing!,
              ]),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(value,
                    maxLines: 1, style: AppTypography.display(color: Colors.white, fontWeight: FontWeight.w800)),
              ),
              if (sub != null)
                Text(sub!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall(color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w600)),
              if (facts.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(children: [
                  for (var i = 0; i < facts.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(child: _HeroFact(label: facts[i].$1, value: facts[i].$2)),
                  ],
                ]),
              ],
            ]),
          ),
        ]),
      );
}

class _HeroFact extends StatelessWidget {
  const _HeroFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.badgeText(color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w700)),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                maxLines: 1, style: AppTypography.bodyLarge(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ]),
      );
}

/// A card that is also a choice (the sale order periods): count, amount, and a coloured ring when chosen.
class CeoSelectCard extends StatelessWidget {
  const CeoSelectCard({
    super.key,
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String value;
  final String sub;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: selected ? color : AppTokens.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: selected ? color : color.withValues(alpha: 0.22)),
              boxShadow: [
                BoxShadow(
                    color: (selected ? color : Colors.black).withValues(alpha: selected ? 0.3 : 0.04),
                    blurRadius: selected ? 12 : 6,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(icon, size: 15, color: selected ? Colors.white : color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(label.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.badgeText(color: selected ? Colors.white : color, fontWeight: FontWeight.w800)),
                ),
                if (selected) const Icon(Icons.check_circle_rounded, size: 15, color: Colors.white),
              ]),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(value,
                    maxLines: 1,
                    style: AppTypography.heading1(
                        color: selected ? Colors.white : AppTokens.textPrimary, fontWeight: FontWeight.w800)),
              ),
              Text(sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.badgeText(
                      color: selected ? Colors.white.withValues(alpha: 0.9) : AppTokens.textMuted,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      );
}

/// A details list inside a tab: a spinner while loading, the message with Retry, [empty] when there are
/// no rows, else [builder].
class CeoListState extends StatelessWidget {
  const CeoListState({
    super.key,
    required this.state,
    required this.onRetry,
    required this.builder,
    this.empty = 'Nothing to show for this period',
  });

  final CeoDetailsState state;
  final VoidCallback onRetry;
  final Widget Function(CeoDetails d) builder;
  final String empty;

  @override
  Widget build(BuildContext context) {
    final d = state.data;
    if (d != null && state.error == null) {
      if (d.rows.isEmpty) return CeoEmpty(text: empty);
      return builder(d);
    }
    if (state.error != null) return CeoErrorBox(message: state.error!, onRetry: onRetry);
    return const CeoSpinner();
  }
}

class CeoSpinner extends StatelessWidget {
  const CeoSpinner({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Center(
          child: SizedBox(
              width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTokens.brandGradientStart)),
        ),
      );
}

class CeoEmpty extends StatelessWidget {
  const CeoEmpty({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Column(children: [
          const Icon(Icons.inbox_outlined, size: 30, color: Palette.textDim),
          const SizedBox(height: 6),
          Text(text, textAlign: TextAlign.center, style: AppTypography.bodySmall(color: AppTokens.textMuted)),
        ]),
      );
}

class CeoErrorBox extends StatelessWidget {
  const CeoErrorBox({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(children: [
          const Icon(Icons.error_outline, color: Palette.rose, size: 26),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center, style: AppTypography.bodySmall(color: Palette.rose)),
          const SizedBox(height: 6),
          FilledButton.tonal(onPressed: onRetry, child: const Text('Retry')),
        ]),
      );
}

/// "Showing 100 of 240" under a list the server cut.
class CeoShowing extends StatelessWidget {
  const CeoShowing({super.key, required this.details, this.noun = ''});

  final CeoDetails details;
  final String noun;

  @override
  Widget build(BuildContext context) {
    final d = details;
    if (!d.truncated && d.count <= d.rows.length) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text('Showing ${ceoCount(d.rows.length)} of ${ceoCount(d.count)}${noun.isEmpty ? '' : ' $noun'}',
          textAlign: TextAlign.center, style: AppTypography.badgeText(color: AppTokens.textMuted)),
    );
  }
}
