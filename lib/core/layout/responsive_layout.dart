import 'package:flutter/widgets.dart';

/// The three layouts of the phone and tablet screens (change `planning-rti-phone-tablet`):
/// phone below 600 dp, tablet portrait 600–900 dp, tablet landscape above 900 dp.
///
/// The width is the window's own, so iPad split view and Android multi-window pick the
/// layout that fits the space the app really has.
enum FormFactor {
  phone,
  tabletPortrait,
  tabletLandscape;

  static const double tabletMin = 600;
  static const double landscapeMin = 900;

  static FormFactor forWidth(double width) {
    if (width < tabletMin) return FormFactor.phone;
    if (width <= landscapeMin) return FormFactor.tabletPortrait;
    return FormFactor.tabletLandscape;
  }

  static FormFactor of(BuildContext context) => forWidth(MediaQuery.sizeOf(context).width);

  bool get isPhone => this == FormFactor.phone;
  bool get isTablet => this != FormFactor.phone;
}

/// Builds the layout for the space it is given. State belongs in the blocs, never in these
/// widgets, so rotating the device or resizing a split view keeps it.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.phone,
    required this.tabletPortrait,
    WidgetBuilder? tabletLandscape,
  }) : tabletLandscape = tabletLandscape ?? tabletPortrait;

  final WidgetBuilder phone;
  final WidgetBuilder tabletPortrait;
  final WidgetBuilder tabletLandscape;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
        switch (FormFactor.forWidth(constraints.maxWidth)) {
          case FormFactor.phone:
            return phone(context);
          case FormFactor.tabletPortrait:
            return tabletPortrait(context);
          case FormFactor.tabletLandscape:
            return tabletLandscape(context);
        }
      });
}
