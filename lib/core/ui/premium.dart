import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/colors/colors.dart';

/// The premium look of the driver screens (owner 2026-10-29: "rich, premium, subtle colours, keep our colours").
/// One place for colours, type and the few building blocks every driver tab uses: soft white cards on a light grey page,
/// a brand hero card, KPI tiles with a tinted icon, pill chips and a pill tab bar. Brand colours are the app's own
/// (AppColors.appBarColor navy and AppColors.primaryGradient).
class Px {
  Px._();

  // page and surfaces
  static const page = Color(0xFFF4F6FB);
  static const card = Colors.white;
  static const line = Color(0xFFE7EBF3);
  static const soft = Color(0xFFF7F9FC);

  // text
  static const ink = Color(0xFF101828);
  static const sub = Color(0xFF667085);
  static const muted = Color(0xFF98A2B3);

  // brand (unchanged app colours)
  static const brand = AppColors.appBarColor;
  static const brandSoft = Color(0xFFEEF2FF);
  static const gradient = AppColors.primaryGradient;

  // tones
  static const green = Color(0xFF079455);
  static const greenSoft = Color(0xFFECFDF3);
  static const amber = Color(0xFFB54708);
  static const amberSoft = Color(0xFFFFFAEB);
  static const red = Color(0xFFD92D20);
  static const redSoft = Color(0xFFFEF3F2);
  static const blue = Color(0xFF175CD3);
  static const blueSoft = Color(0xFFEFF8FF);
  static const orange = Color(0xFFC4320A);
  static const orangeSoft = Color(0xFFFFF6ED);

  static const radius = 20.0;

  static List<BoxShadow> get shadow => [
        BoxShadow(color: const Color(0xFF1A3A8F).withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 3)),
      ];

  /// Inter, as the rest of the app (AppTypography).
  static TextStyle t(double size, {FontWeight weight = FontWeight.w500, Color color = ink, double? height, double? spacing}) =>
      GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color, height: height, letterSpacing: spacing);

  static TextStyle get title => t(17, weight: FontWeight.w700, spacing: -0.2);
  static TextStyle get label => t(13, color: sub);
  static TextStyle get value => t(24, weight: FontWeight.w800, spacing: -0.6, height: 1.1);
  static TextStyle get body => t(14, weight: FontWeight.w500);
  static TextStyle get small => t(12, color: sub);
  static TextStyle get caps => t(11, weight: FontWeight.w700, color: muted, spacing: 0.6);
}

/// The tone of a chip, a dot or a tile icon.
enum Tone { brand, green, amber, red, blue, orange, grey }

extension ToneColors on Tone {
  Color get fg => switch (this) {
        Tone.brand => Px.brand,
        Tone.green => Px.green,
        Tone.amber => Px.amber,
        Tone.red => Px.red,
        Tone.blue => Px.blue,
        Tone.orange => Px.orange,
        Tone.grey => Px.sub,
      };

  Color get bg => switch (this) {
        Tone.brand => Px.brandSoft,
        Tone.green => Px.greenSoft,
        Tone.amber => Px.amberSoft,
        Tone.red => Px.redSoft,
        Tone.blue => Px.blueSoft,
        Tone.orange => Px.orangeSoft,
        Tone.grey => const Color(0xFFF2F4F7),
      };
}

/// A white card with a hairline border and a soft shadow.
class PCard extends StatelessWidget {
  const PCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.margin, this.onTap, this.color});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? Px.card,
        borderRadius: BorderRadius.circular(Px.radius),
        border: Border.all(color: Px.line),
        boxShadow: Px.shadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(Px.radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
      ),
    );
    return box;
  }
}

/// An icon in a soft tinted circle.
class PIcon extends StatelessWidget {
  const PIcon(this.icon, {super.key, this.tone = Tone.brand, this.size = 40, this.onBrand = false});

  final IconData icon;
  final Tone tone;
  final double size;

  /// On the brand hero card: white circle, brand icon.
  final bool onBrand;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: onBrand ? Colors.white : tone.bg, shape: BoxShape.circle),
        child: Icon(icon, size: size * 0.5, color: onBrand ? Px.brand : tone.fg),
      );
}

/// The brand hero tile (the "Total Sales" card of the reference): gradient, big number, icon top right.
class PHero extends StatelessWidget {
  const PHero({super.key, required this.label, required this.value, this.footnote, this.icon, this.trailing});

  final String label;
  final String value;
  final String? footnote;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
        decoration: BoxDecoration(
          gradient: Px.gradient,
          borderRadius: BorderRadius.circular(Px.radius),
          boxShadow: [BoxShadow(color: Px.brand.withValues(alpha: 0.18), blurRadius: 20, offset: const Offset(0, 6))],
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: Px.t(13, color: Colors.white.withValues(alpha: 0.8))),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(value, style: Px.t(30, weight: FontWeight.w800, color: Colors.white, spacing: -0.8, height: 1.05)),
              ),
              if (footnote != null) ...[
                const SizedBox(height: 8),
                Text(footnote!, style: Px.t(12, color: Colors.white.withValues(alpha: 0.75))),
              ],
            ]),
          ),
          if (trailing != null) trailing! else if (icon != null) PIcon(icon!, onBrand: true, size: 44),
        ]),
      );
}

/// A KPI tile: label, big value, tinted icon top right, optional footnote.
class PStat extends StatelessWidget {
  const PStat({super.key, required this.label, required this.value, required this.icon, this.tone = Tone.brand, this.footnote});

  final String label;
  final String value;
  final IconData icon;
  final Tone tone;
  final String? footnote;

  @override
  Widget build(BuildContext context) => PCard(
        padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          PIcon(icon, tone: tone, size: 32),
          const SizedBox(height: 12),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: Px.value),
          const SizedBox(height: 2),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: Px.t(13, weight: FontWeight.w600)),
          if (footnote != null) Text(footnote!, maxLines: 1, overflow: TextOverflow.ellipsis, style: Px.small),
        ]),
      );
}

/// Tiles side by side with even gaps (2 or 3 on a phone).
class PStatRow extends StatelessWidget {
  const PStatRow({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: children[i]),
        ],
      ]);
}

/// A small pill: soft tone background, tone text.
class PChip extends StatelessWidget {
  const PChip(this.label, {super.key, this.tone = Tone.brand, this.icon, this.dot = false});

  final String label;
  final Tone tone;
  final IconData? icon;
  final bool dot;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: tone.bg, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (dot) ...[
            Container(width: 6, height: 6, decoration: BoxDecoration(color: tone.fg, shape: BoxShape.circle)),
            const SizedBox(width: 6),
          ],
          if (icon != null) ...[Icon(icon, size: 14, color: tone.fg), const SizedBox(width: 4)],
          Flexible(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: Px.t(12, weight: FontWeight.w600, color: tone.fg)),
          ),
        ]),
      );
}

/// A section heading with an optional line below and something on the right.
class PSection extends StatelessWidget {
  const PSection(this.title, {super.key, this.subtitle, this.trailing, this.padding = const EdgeInsets.fromLTRB(2, 18, 2, 10)});

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Padding(
        padding: padding,
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: Px.title),
              if (subtitle != null) ...[const SizedBox(height: 2), Text(subtitle!, style: Px.small)],
            ]),
          ),
          if (trailing != null) trailing!,
        ]),
      );
}

/// One label / value line inside a card.
class PRow extends StatelessWidget {
  const PRow(this.label, this.value, {super.key, this.trailing, this.strong = false});

  final String label;
  final String value;
  final Widget? trailing;
  final bool strong;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(children: [
          Expanded(flex: 5, child: Text(label, style: Px.t(14, color: Px.sub))),
          Expanded(
            flex: 6,
            child: Text(value.isEmpty ? '—' : value,
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Px.t(14, weight: strong ? FontWeight.w800 : FontWeight.w600)),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ]),
      );
}

/// A hairline between rows.
class PDivider extends StatelessWidget {
  const PDivider({super.key});

  @override
  Widget build(BuildContext context) => const Divider(height: 1, thickness: 1, color: Px.line);
}

/// Nothing to show: icon, title, one line.
class PEmpty extends StatelessWidget {
  const PEmpty({super.key, required this.icon, required this.title, this.subtitle});

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
        child: Column(children: [
          PIcon(icon, size: 64),
          const SizedBox(height: 14),
          Text(title, textAlign: TextAlign.center, style: Px.title),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, textAlign: TextAlign.center, style: Px.t(14, color: Px.sub)),
          ],
        ]),
      );
}

/// A white pill button (date, month, language) with an icon.
class PPill extends StatelessWidget {
  const PPill({super.key, required this.label, this.icon, this.onTap, this.caption});

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final String? caption;

  @override
  Widget build(BuildContext context) => Material(
        color: Px.card,
        shape: const StadiumBorder(side: BorderSide(color: Px.line)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (icon != null) ...[Icon(icon, size: 18, color: Px.brand), const SizedBox(width: 8)],
              Flexible(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  if (caption != null) Text(caption!, style: Px.t(10, weight: FontWeight.w700, color: Px.muted, spacing: 0.5)),
                  Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: Px.t(14, weight: FontWeight.w700)),
                ]),
              ),
            ]),
          ),
        ),
      );
}

/// Segmented choice: a soft track with the chosen pill in brand navy (Yesterday · Today · Tomorrow).
class PSegments extends StatelessWidget {
  const PSegments({super.key, required this.labels, required this.selected, required this.onSelect});

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: Px.card, borderRadius: BorderRadius.circular(999), border: Border.all(color: Px.line)),
        child: Row(children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == selected ? Px.brand : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(labels[i],
                        maxLines: 1, style: Px.t(13, weight: FontWeight.w700, color: i == selected ? Colors.white : Px.sub)),
                    ),
                  ),
                ),
              ),
            ),
        ]),
      );
}

/// How close a date is: expired, due within [soonDays], valid, or no date. Pure (tested).
enum Expiry { expired, soon, valid, none }

Expiry expiryOf(DateTime? date, DateTime today, {int soonDays = 30}) {
  if (date == null) return Expiry.none;
  final d = DateTime(date.year, date.month, date.day);
  final t = DateTime(today.year, today.month, today.day);
  if (d.isBefore(t)) return Expiry.expired;
  if (d.difference(t).inDays <= soonDays) return Expiry.soon;
  return Expiry.valid;
}

extension ExpiryLook on Expiry {
  Tone get tone => switch (this) {
        Expiry.expired => Tone.red,
        Expiry.soon => Tone.amber,
        Expiry.valid => Tone.green,
        Expiry.none => Tone.grey,
      };

  /// "Expired", "12 days" (left), "Valid", "No date".
  String label(DateTime? date, DateTime today) {
    if (this == Expiry.soon && date != null) {
      final days = DateTime(date.year, date.month, date.day).difference(DateTime(today.year, today.month, today.day)).inDays;
      return days == 0 ? 'Today' : '$days day${days == 1 ? '' : 's'}';
    }
    return switch (this) {
      Expiry.expired => 'Expired',
      Expiry.soon => 'Soon',
      Expiry.valid => 'Valid',
      Expiry.none => 'No date',
    };
  }
}
