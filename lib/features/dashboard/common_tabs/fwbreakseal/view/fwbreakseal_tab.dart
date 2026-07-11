import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:maleva/menu/menulist.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/models/model.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/palette.dart';
import '../../../../../core/theme/tokens.dart';
import '../../../../mastersearch/Employee.dart';
import '../bloc/fwbreakseal_bloc.dart';
import '../bloc/fwbreakseal_event.dart';
import '../bloc/fwbreakseal_state.dart';



// ════════════════════════════════════════════════════════════════════════════
//  Entry-point widget  (provides the BLoC)
// ════════════════════════════════════════════════════════════════════════════

class FWUpdateBreakSeal extends StatelessWidget {
  const FWUpdateBreakSeal({super.key});

  @override
  Widget build(BuildContext context) {
    return
      BlocProvider(
        create: (_) => sl<FWBreakSealBloc>()
          ..add(const FWBreakSealInitialised()),
        child: const _FWBreakSealView(),
      );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Internal view (consumes the BLoC)
// ════════════════════════════════════════════════════════════════════════════

class _FWBreakSealView extends StatefulWidget {
  const _FWBreakSealView();

  @override
  State<_FWBreakSealView> createState() => _FWBreakSealViewState();
}

class _FWBreakSealViewState extends State<_FWBreakSealView>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Text controllers kept here only for UI synchronisation.
  // The source of truth lives in the BLoC state.
  final _smk1 = TextEditingController();
  final _smk2 = TextEditingController();
  final _smk3 = TextEditingController();
  final _exRef1 = TextEditingController();
  final _exRef2 = TextEditingController();
  final _exRef3 = TextEditingController();
  final _emp1 = TextEditingController();
  final _emp2 = TextEditingController();
  final _emp3 = TextEditingController();

  OverlayEntry? _overlayEntry;
  final GlobalKey _appBarKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in [
      _smk1, _smk2, _smk3,
      _exRef1, _exRef2, _exRef3,
      _emp1, _emp2, _emp3,
    ]) {
      c.dispose();
    }
    _clearOverlay();
    super.dispose();
  }

  // ── Overlay helpers ───────────────────────────────────────────────────────

  void _clearOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay(List<Map<String, dynamic>> suggestions, int smkType) {
    _clearOverlay();
    if (suggestions.isEmpty) return;

    final double height = MediaQuery.of(context).size.height;
    final appBarBox =
    _appBarKey.currentContext?.findRenderObject() as RenderBox?;
    final double topOffset =
        (appBarBox?.size.height ?? 56) + height * 0.12 + 10;

    _overlayEntry = OverlayEntry(
      builder: (_) => Positioned(
        top: topOffset,
        left: AppGlobals.MalevaScreen == 1 ? 10 : 100,
        right: AppGlobals.MalevaScreen == 1 ? 10 : 100,
        child: Material(
          color: AppTokens.brandLight,
          elevation: 1,
          textStyle: GoogleFonts.lato(
            textStyle: TextStyle(
              color: AppTokens.brandPrimary,
              fontWeight: FontWeight.bold,
              fontSize: AppGlobals.FontLow,
              letterSpacing: 0.3,
            ),
          ),
          child: SizedBox(
            height: 350,
            child: ListView(
              shrinkWrap: true,
              children: suggestions.map((pred) {
                final String field = smkType == 1
                    ? 'ForwardingSMKNo'
                    : smkType == 2
                    ? 'ForwardingSMKNo2'
                    : 'ForwardingSMKNo3';
                return InkWell(
                  onTap: () {
                    _clearOverlay();
                    context
                        .read<FWBreakSealBloc>()
                        .add(FWBreakSealSmkSelected(
                      smkType: smkType,
                      prediction: pred,
                    ));
                  },
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Text(pred[field].toString()),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  // ── Back-press ────────────────────────────────────────────────────────────

  Future<bool> _onWillPop() async {
    if (_overlayEntry != null) {
      _clearOverlay();
      context.read<FWBreakSealBloc>().add(const FWBreakSealOverlayClosed());
      return false;
    }
    Navigator.of(context).pop();
    return true;
  }

  // ── Sync controllers from BLoC state ────────────────────────────────────

  void _syncControllers(FWBreakSealState s) {
    _syncCtrl(_smk1, s.slot1.smkNo);
    _syncCtrl(_smk2, s.slot2.smkNo);
    _syncCtrl(_smk3, s.slot3.smkNo);
    _syncCtrl(_exRef1, s.slot1.exRef);
    _syncCtrl(_exRef2, s.slot2.exRef);
    _syncCtrl(_exRef3, s.slot3.exRef);
    _syncCtrl(_emp1, s.slot1.breakByEmpName);
    _syncCtrl(_emp2, s.slot2.breakByEmpName);
    _syncCtrl(_emp3, s.slot3.breakByEmpName);

    if (_tabController.index != s.activeTab) {
      _tabController.index = s.activeTab;
    }
  }

  void _syncCtrl(TextEditingController ctrl, String value) {
    if (ctrl.text != value) {
      ctrl.text = value;
      ctrl.selection =
          TextSelection.collapsed(offset: value.length);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FWBreakSealBloc, FWBreakSealState>(
      listener: (context, state) {
        _syncControllers(state);

        // Show / hide overlay
        if (state.isOverlayVisible) {
          _showOverlay(state.suggestions, state.overlayForType);
        } else {
          _clearOverlay();
        }

        // Success dialog
        if (state.screenStatus == FWScreenStatus.success) {
          ConfirmationOK(state.successMessage ?? 'Updated Successfully',
              context)
              .then((_) {
            context.read<FWBreakSealBloc>().add(const FWBreakSealCleared());
          });
        }

        // Error toast
        if (state.screenStatus == FWScreenStatus.failure &&
            state.errorMessage != null) {
          msgshow(
            state.errorMessage!,
            '',
            Colors.white,
            Colors.red,
            null,
            18.0 - AppGlobals.reducesize,
            AppGlobals.tll,
            AppGlobals.tgc,
            context,
            2,
          );
        }
      },
      builder: (context, state) {
        final bool isMobile = AppGlobals.MalevaScreen == 1;
        return isMobile ? _buildMobile(context, state) : _buildTablet(context, state);
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  //  MOBILE layout
  // ════════════════════════════════════════════════════════════════════════

  Widget _buildMobile(BuildContext context, FWBreakSealState state) {
    final double height = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Palette.white,
        appBar: _buildAppBar(context, state, height),
        drawer: const Menulist(),
        body: state.isLoading
            ? const Center(
          child: SpinKitFoldingCube(
            color: AppTokens.spinKit,
            size: 35.0,
          ),
        )
            : _buildTabBarView(context, state),
        bottomNavigationBar: _buildBottomNav(context, state),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  //  TABLET layout  (wider padding, two-column potential)
  // ════════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context, FWBreakSealState state) {
    final double height = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Palette.white,
        appBar: _buildAppBar(context, state, height),
        drawer: const Menulist(),
        body: state.isLoading
            ? const Center(
          child: SpinKitFoldingCube(
            color: AppTokens.spinKit,
            size: 35.0,
          ),
        )
            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: _buildTabBarView(context, state),
        ),
        bottomNavigationBar: _buildBottomNav(context, state),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  //  Shared sub-widgets
  // ────────────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(
      BuildContext context, FWBreakSealState state, double height) {
    return AppBar(
      key: _appBarKey,
      automaticallyImplyLeading: true,
      backgroundColor: AppTokens.appBarBg,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          if (_overlayEntry != null) {
            _clearOverlay();
            context
                .read<FWBreakSealBloc>()
                .add(const FWBreakSealOverlayClosed());
          } else {
            Navigator.pop(context);
          }
        },
      ),
      title: SizedBox(
        height: height * 0.05,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                'FW Exit Update',
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    color: AppTokens.appBarTitle,
                    fontWeight: FontWeight.bold,
                    fontSize: AppGlobals.FontMedium,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Text(
                state.userName,
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    color: AppTokens.brandLight,
                    fontWeight: FontWeight.bold,
                    fontSize: AppGlobals.FontLow - 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      iconTheme: const IconThemeData(color: AppTokens.appBarIcon),
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 7, bottom: 7, left: 7),
          child: SizedBox(
            width: 70,
            height: 25,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTokens.brandLight,
                side: const BorderSide(
                    color: AppTokens.brandPrimary, width: 1),
                elevation: 20,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(4),
              ),
              onPressed: () => context
                  .read<FWBreakSealBloc>()
                  .add(const FWBreakSealUpdateSubmitted()),
              child: Text(
                'Update',
                style: GoogleFonts.lato(
                  fontSize: AppGlobals.FontMedium,
                  fontWeight: FontWeight.bold,
                  color: AppTokens.brandPrimary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTabBarView(BuildContext context, FWBreakSealState state) {
    return DefaultTabController(
      length: 3,
      child: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildSlotTab(context, state, smkType: 1),
          _buildSlotTab(context, state, smkType: 2),
          _buildSlotTab(context, state, smkType: 3),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, FWBreakSealState state) {
    return BottomNavigationBar(
      backgroundColor: AppTokens.brandLight,
      unselectedItemColor: AppTokens.appBarBg.withOpacity(0.5),
      currentIndex: state.activeTab,
      selectedLabelStyle: GoogleFonts.lato(
        textStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: AppGlobals.FontLow,
          letterSpacing: 0.3,
        ),
      ),
      unselectedLabelStyle: GoogleFonts.lato(
        textStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: AppGlobals.FontCardText,
          letterSpacing: 0.3,
        ),
      ),
      onTap: (index) => context
          .read<FWBreakSealBloc>()
          .add(FWBreakSealTabChanged(index)),
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping_sharp), label: 'FW 1'),
        BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping_sharp), label: 'FW 2'),
        BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping_sharp), label: 'FW 3'),
      ],
    );
  }

  // ── Per-tab form ──────────────────────────────────────────────────────────

  Widget _buildSlotTab(
      BuildContext context,
      FWBreakSealState state, {
        required int smkType,
      }) {
    final TextEditingController smkCtrl =
    smkType == 1 ? _smk1 : smkType == 2 ? _smk2 : _smk3;
    final TextEditingController exRefCtrl =
    smkType == 1 ? _exRef1 : smkType == 2 ? _exRef2 : _exRef3;
    final TextEditingController empCtrl =
    smkType == 1 ? _emp1 : smkType == 2 ? _emp2 : _emp3;

    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
      child: ListView(
        children: [
          // ── SMK number ──────────────────────────────────────────────────
          _styledTextField(
            controller: smkCtrl,
            hint: 'Enter SMK No $smkType',
            onChanged: (v) => context
                .read<FWBreakSealBloc>()
                .add(FWBreakSealSmkChanged(smkType: smkType, value: v)),
          ),
          const SizedBox(height: 7),

          // ── Exit reference ───────────────────────────────────────────────
          _styledTextField(
            controller: exRefCtrl,
            hint: 'EX.Ref $smkType',
            onChanged: (v) => context
                .read<FWBreakSealBloc>()
                .add(FWBreakSealExRefChanged(smkType: smkType, value: v)),
          ),
          const SizedBox(height: 7),

          // ── Break seal by employee ───────────────────────────────────────
          _breakSealByField(
            context: context,
            state: state,
            smkType: smkType,
            controller: empCtrl,
          ),
          const SizedBox(height: 7),
        ],
      ),
    );
  }

  // ── Styled text field (shared) ────────────────────────────────────────────

  Widget _styledTextField({
    required TextEditingController controller,
    required String hint,
    ValueChanged<String>? onChanged,
    bool readOnly = false,
    Widget? suffixIcon,
  }) {
    return Container(
      width: SizeConfig.safeBlockHorizontal * 99,
      height: SizeConfig.safeBlockVertical * 7,
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.only(bottom: 5),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        autofocus: false,
        showCursor: true,
        textInputAction: TextInputAction.done,
        textCapitalization: TextCapitalization.characters,
        cursorColor: AppTokens.brandPrimary,
        style: GoogleFonts.lato(
          textStyle: TextStyle(
            color: AppTokens.brandPrimary,
            fontWeight: FontWeight.bold,
            fontSize: AppGlobals.FontLow,
            letterSpacing: 0.3,
          ),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.lato(
            textStyle: TextStyle(
              fontSize: AppGlobals.FontMedium,
              fontWeight: FontWeight.bold,
              color: AppTokens.brandLight,
            ),
          ),
          suffixIcon: suffixIcon,
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: AppTokens.brandPrimary),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: AppTokens.statusDanger),
          ),
          contentPadding:
          const EdgeInsets.only(left: 10, right: 20, top: 10),
        ),
        onChanged: onChanged,
      ),
    );
  }

  // ── Break-seal-by employee field ──────────────────────────────────────────

  Widget _breakSealByField({
    required BuildContext context,
    required FWBreakSealState state,
    required int smkType,
    required TextEditingController controller,
  }) {
    final bool hasEmp =
        state.slotFor(smkType).breakByEmpName.isNotEmpty;

    return _styledTextField(
      controller: controller,
      hint: 'B.Seal By',
      readOnly: true,
      suffixIcon: InkWell(
        child: Icon(
          hasEmp ? Icons.close : Icons.search_rounded,
          color: AppTokens.statusDanger,
          size: 30,
        ),
        onTap: () async {
          final bloc = context.read<FWBreakSealBloc>();

          if (hasEmp) {
            // Clear
            bloc.add(
                FWBreakSealEmpSearchTapped(smkType: smkType, isClear: true));
          } else {
            // Navigate to picker
            bloc.add(
                FWBreakSealEmpSearchTapped(smkType: smkType, isClear: false));
            final __navResult1 = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                const Employee(Searchby: 1, SearchId: 0),
              ),
            ); if (__navResult1 != null) { AppGlobals.SelectEmployeeList = __navResult1; }
if (__navResult1 != null) { AppGlobals.SelectEmployeeList = __navResult1; }

            // Employee picker sets AppGlobals.SelectEmployeeList
            final emp = AppGlobals.SelectEmployeeList;
            if (emp.Id != 0) {
              bloc.add(FWBreakSealEmpSelected(
                smkType: smkType,
                empId: emp.Id,
                empName: emp.AccountName,
              ));
              AppGlobals.SelectEmployeeList = EmployeeModel.Empty();
            }
          }
        },
      ),
    );
  }
}