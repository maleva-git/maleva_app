import 'package:flutter/material.dart';
import 'package:maleva/core/theme/app_theme.dart';

/// Skeleton cards shown while a list loads.
class SkeletonList extends StatefulWidget {
  const SkeletonList({super.key, this.count = 5, this.padding = const EdgeInsets.all(16)});

  final int count;
  final EdgeInsets padding;

  @override
  State<SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<SkeletonList> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    Widget bar(double w, double h) => FractionallySizedBox(
        widthFactor: w, alignment: Alignment.centerLeft,
        child: Container(height: h, decoration: BoxDecoration(color: mc.outline, borderRadius: BorderRadius.circular(8))));
    return Semantics(
      label: 'Loading',
      child: FadeTransition(
        opacity: Tween(begin: 0.5, end: 1.0).animate(_c),
        child: ListView.separated(
          padding: widget.padding,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.count,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                bar(0.45, 18), const SizedBox(height: 10), bar(0.7, 14), const SizedBox(height: 8), bar(i.isEven ? 0.85 : 0.6, 14),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// An empty list: an icon, a title, an optional hint and action.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, this.message, this.icon = Icons.inbox_outlined, this.actionLabel, this.onAction});

  final String title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => _StateBox(
        icon: icon, title: title, message: message, bg: context.mc.primarySoft, fg: context.mc.onPrimarySoft,
        action: actionLabel == null ? null : FilledButton.tonal(onPressed: onAction, child: Text(actionLabel!)),
      );
}

/// A failed load: the server's message and Retry.
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.title, this.message, required this.onRetry, this.retryLabel = 'Retry'});

  final String title;
  final String? message;
  final VoidCallback onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) => _StateBox(
        icon: Icons.cloud_off_outlined, title: title, message: message, bg: context.mc.dangerSoft, fg: context.cs.error,
        action: FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: Text(retryLabel)),
      );
}

class _StateBox extends StatelessWidget {
  const _StateBox({required this.icon, required this.title, this.message, required this.bg, required this.fg, this.action});

  final IconData icon;
  final String title;
  final String? message;
  final Color bg;
  final Color fg;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 56, height: 56, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(18)), child: Icon(icon, color: fg, size: 28)),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            if (message != null && message!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(message!, textAlign: TextAlign.center, style: text.bodyMedium?.copyWith(color: context.mc.muted)),
            ],
            if (action != null) ...[const SizedBox(height: 16), action!],
          ]),
        ),
      ),
    );
  }
}
