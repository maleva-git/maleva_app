import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

class CustomGradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isTablet;
  final List<Widget>? actions;
  final bool showBackButton;

  const CustomGradientAppBar({
    Key? key,
    required this.title,
    this.isTablet = false,
    this.actions,
    this.showBackButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Fetch the logged-in username securely
    final String userName = objfun.storagenew.getString('Username') ?? '';

    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      toolbarHeight: isTablet ? 68 : 62,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Palette.blue700, Palette.blue400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      leading: Builder(
        builder: (context) {
          final scaffold = Scaffold.maybeOf(context);
          final hasDrawer = scaffold?.hasDrawer ?? false;

          if (showBackButton) {
            return IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              color: Colors.white,
              onPressed: () => Navigator.pop(context),
            );
          } else if (hasDrawer) {
            return IconButton(
              icon: const Icon(Icons.menu_rounded, size: 26),
              color: Colors.white,
              onPressed: () => scaffold!.openDrawer(),
            );
          }
          return const SizedBox.shrink(); // No leading widget needed
        },
      ),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.lato(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: isTablet ? 19 : 17,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            userName,
            style: GoogleFonts.lato(
              color: Colors.white.withOpacity(0.65),
              fontWeight: FontWeight.w500,
              fontSize: isTablet ? 13 : 12,
            ),
          ),
        ],
      ),
      actions: [
        ...?actions,
        Builder(
          builder: (context) {
            final scaffold = Scaffold.maybeOf(context);
            final hasDrawer = scaffold?.hasDrawer ?? false;
            
            // If the back button is occupying the leading slot, put the menu icon on the right.
            if (showBackButton && hasDrawer) {
              return IconButton(
                icon: const Icon(Icons.menu_rounded, size: 26),
                color: Colors.white,
                onPressed: () => scaffold!.openDrawer(),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(isTablet ? 68 : 62);
}
