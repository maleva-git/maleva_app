import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'dart:io';
import 'package:app_version_update/app_version_update.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/menu/menulist.dart';
import '../../../core/theme/tokens.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import 'package:maleva/core/utils/auth_helper.dart';



const double _kTabletBreak = 600.0;



class Homemobile extends StatelessWidget {
  const Homemobile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      HomeDashboardBloc()..add(const HomeDashboardStartupRequested()),
      child: const _HomeDashboardView(),
    );
  }
}


class _HomeDashboardView extends StatefulWidget {
  const _HomeDashboardView();

  @override
  State<_HomeDashboardView> createState() => _HomeDashboardViewState();
}

class _HomeDashboardViewState extends State<_HomeDashboardView> {

  Future<bool> _onBackPressed() async {
    final bool confirmed = await ConfirmationMsgYesNo(
      context,
      'Are you sure you want to Exit?',
    );

    if (confirmed) {
      if (!mounted) return false;
      context.read<HomeDashboardBloc>().add(const HomeDashboardExitConfirmed());

      if (Platform.isAndroid) {
        SystemNavigator.pop();
      } else if (Platform.isIOS) {
        exit(0);
      }
    }

    return confirmed;
  }



  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeDashboardBloc, HomeDashboardState>(
      listener: _handleListener,
      builder: (ctx, state) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            await _onBackPressed();
          },
          child: LayoutBuilder(
            builder: (_, constraints) {
              final bool isTablet = constraints.maxWidth >= _kTabletBreak;

              // Set global font sizes based on screen width so other pages
              // that still read AppGlobals.FontXxx continue to work correctly.
              _setFontSizes(constraints.maxWidth, isTablet);

              return isTablet
                  ? _TabletDashboard(state: state)
                  : _MobileDashboard(state: state);
            },
          ),
        );
      },
    );
  }

  // ── Listener ──────────────────────────────────────────────────────────────

  void _handleListener(BuildContext ctx, HomeDashboardState state) {
    // ── Non-fatal version-check error ─────────────────────────────────────
    if (state.isReady && state.errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          backgroundColor: Palette.amber,
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Version check failed: ${state.errorMessage}',
            style: AppTypography.bodyLarge(color: Palette.white),
          ),
          action: SnackBarAction(
            label: 'OK',
            textColor: Palette.white,
            onPressed: () =>
                ScaffoldMessenger.of(ctx).hideCurrentSnackBar(),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }

    if (state.isReady && state.canUpdate) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {

        final result = await AppVersionUpdate.checkForUpdates(
          appleId: '6738003436',
          playStoreId: 'com.kassapos.maleva',
        );
        if (result.canUpdate == true && ctx.mounted) {
          await AppVersionUpdate.showAlertUpdate(
            appVersionResult: result,
            context: ctx,
            backgroundColor: colour.commonColorLight,
            title: 'New Update Available Now',
            titleTextStyle: AppTypography.bodyLarge(color: AppTokens.textPrimary),
            content:
            'Would you like to update your app to the latest version?',
            contentTextStyle: AppTypography.bodyLarge(color: AppTokens.textPrimary),
            updateButtonText: 'Update',
            cancelButtonText: 'Later',
            mandatory: true,
          );
        }
      });
    }
  }


  void _showForceUpdateDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Update Required',
          style: AppTypography.heading2(color: AppTokens.textPrimary),
        ),
        content: Text(
          'A new version is available. Please update the app to continue.',
          style: AppTypography.bodyLarge(color: AppTokens.textSecondary),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTokens.brandPrimary,
              foregroundColor: Palette.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              // TODO: launch store URL via url_launcher
            },
            child:
            Text('Update Now', style: AppTypography.bodyLarge()),
          ),
        ],
      ),
    );
  }


  void _setFontSizes(double width, bool isTablet) {
    if (isTablet) {
      AppGlobals.FontLarge    = 26;
      AppGlobals.FontMedium   = 22;
      AppGlobals.FontLow      = 20;
      AppGlobals.FontCardText = 16;
    } else if (width <= 370) {
      AppGlobals.FontLarge    = 22;
      AppGlobals.FontMedium   = 18;
      AppGlobals.FontLow      = 16;
      AppGlobals.FontCardText = 12;
    } else {
      AppGlobals.FontLarge    = 24;
      AppGlobals.FontMedium   = 20;
      AppGlobals.FontLow      = 18;
      AppGlobals.FontCardText = 14;
    }
  }
}



class _MobileDashboard extends StatelessWidget {
  const _MobileDashboard({required this.state});

  final HomeDashboardState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Palette.white,
      appBar: const _DashboardAppBar(isTablet: false),
      drawer: const Menulist(),
      body: state.isLoading
          ? const _LoadingBody(isTablet: false)
          : const _ReadyBody(isTablet: false),
    );
  }
}



class _TabletDashboard extends StatelessWidget {
  const _TabletDashboard({required this.state});

  final HomeDashboardState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Palette.grey50,

      body: Row(
        children: [

          _TabletSideRail(),

          const VerticalDivider(width: 1, thickness: 1),

          Expanded(
            child: Column(
              children: [
                const _DashboardAppBar(isTablet: true),
                Expanded(
                  child: state.isLoading
                      ? const _LoadingBody(isTablet: true)
                      : const _ReadyBody(isTablet: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _DashboardAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _DashboardAppBar({required this.isTablet});

  final bool isTablet;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration:
        const BoxDecoration(gradient: AppTokens.headerGradient),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme:
      const IconThemeData(color: AppTokens.appBarIcon),
      centerTitle: true,
      title: Text(
        'Dash Board',
        style: AppTypography.heading1(color: AppTokens.appBarTitle),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.exit_to_app,
            size: 26,
            color: AppTokens.appBarIcon,
          ),
          tooltip: 'Logout',
          onPressed: () => AuthHelper.logout(context),
        ),
      ],
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody({required this.isTablet});

  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitFoldingCube(
        color: AppTokens.spinKit,
        size: 38.0,
      ),
    );
  }
}


class _ReadyBody extends StatelessWidget {
  const _ReadyBody({required this.isTablet});

  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final double logoSize = isTablet ? 380 : 280;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Container(
            width: logoSize,
            height: logoSize * 0.8,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(isTablet ? 24 : 16),
              image: DecorationImage(
                image: AppGlobals.logo,
                colorFilter: ColorFilter.mode(
                  Colors.white.withValues(alpha: 0.5),
                  BlendMode.dstATop,
                ),
              ),
            ),
          ),

          SizedBox(height: isTablet ? 32 : 20),

          Text(
            AppGlobals.selectedCompanyName.isNotEmpty
                ? AppGlobals.selectedCompanyName
                : 'Welcome',
            style: AppTypography.heading1(color: AppTokens.textPrimary),
          ),

          const SizedBox(height: 8),

          Text(
            'Dashboard',
            style: AppTypography.heading2(color: AppTokens.textSecondary),
          ),
        ],
      ),
    );
  }
}


class _TabletSideRail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: AppTokens.appBarBg,
      child: Column(
        children: [

          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 20),
            decoration: const BoxDecoration(
              gradient: AppTokens.headerGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Palette.white.withValues(alpha: 0.2),
                  child: const Icon(Icons.person_outline,
                      color: Palette.white, size: 28),
                ),
                const SizedBox(height: 10),
                Text(
                  AppGlobals.selectedCompanyName.isNotEmpty
                      ? AppGlobals.selectedCompanyName
                      : 'Maleva',
                  style: AppTypography.heading2(color: Palette.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),


          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: AppGlobals.parentclass.map((menu) {
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.chevron_right,
                      color: Palette.white, size: 18),
                  title: Text(
                    menu.FormText ?? '',
                    style: AppTypography.bodyLarge(color: Palette.white),
                  ),
                  onTap: () {
                    // TODO: navigate using menu.FormLink or equivalent
                  },
                );
              }).toList(),
            ),
          ),


          const Divider(color: Palette.pillBg, height: 1),
          ListTile(
            leading: const Icon(Icons.exit_to_app,
                color: Palette.white, size: 20),
            title: Text(
              'Logout',
              style: AppTypography.bodyLarge(color: Palette.white),
            ),
            onTap: () => AuthHelper.logout(context),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}