import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/menu/menulist.dart';
import '../bloc/forwardingsmk_bloc.dart';
import '../bloc/forwardingsmk_event.dart';
import '../bloc/forwardingsmk_state.dart';


// ─── Design Tokens ────────────────────────────────────────────────────────────
const kHeaderGradStart = Color(0xFF1A3A8F);
const kHeaderGradEnd   = Color(0xFF4A6FD4);
const kCardBorder      = Color(0xFFC5D0EE);
const kPageBg          = Color(0xFFF4F6FB);
const kTextDark        = Color(0xFF1E2D5E);
const kTextMid         = Color(0xFF4A5A8A);
const kTextMuted       = Color(0xFF8A96BF);
const kDetailBg        = Color(0xFFF0F4FF);
const kChipBg          = Color(0xFFEEF2FF);

const kGradient = LinearGradient(
  colors: [kHeaderGradStart, kHeaderGradEnd],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const double kTabletBreak = 600;

const List<String> kForwardingOptions = ['K1', 'K2', 'K3', 'K8'];

// ─── Root ─────────────────────────────────────────────────────────────────────
class FWSmkUpdate extends StatelessWidget {
  const FWSmkUpdate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FWSmkBloc()..add(FWSmkStarted()),
      child: const _FWSmkPage(),
    );
  }
}

// ─── Page ─────────────────────────────────────────────────────────────────────
class _FWSmkPage extends StatefulWidget {
  const _FWSmkPage();

  @override
  State<_FWSmkPage> createState() => _FWSmkPageState();
}

class _FWSmkPageState extends State<_FWSmkPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<FWSmkBloc>().add(FWSmkTabChanged(_tabController.index));
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userName = objfun.storagenew.getString('Username') ?? '';

    return BlocListener<FWSmkBloc, FWSmkState>(
      listener: (context, state) async {
        if (state is FWSmkSaveSuccess) {
          await objfun.ConfirmationOK('Updated Successfully', context);
        }
        if (state is FWSmkError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message,
                  style: GoogleFonts.lato(color: Colors.white)),
              backgroundColor: const Color(0xFFB33040),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return false;
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: kPageBg,
          appBar: _buildAppBar(context, userName),
          drawer: const Menulist(),
          body: BlocBuilder<FWSmkBloc, FWSmkState>(
            builder: (context, state) {
              if (state is FWSmkInitial || state is FWSmkLoading) {
                return const Center(
                  child: SpinKitFoldingCube(color: kHeaderGradEnd, size: 35),
                );
              }
              if (state is FWSmkLoaded) {
                // Sync tab controller index
                if (_tabController.index != state.currentTab) {
                  _tabController.animateTo(state.currentTab);
                }
                return GestureDetector(
                  onTap: () => context
                      .read<FWSmkBloc>()
                      .add(FWSmkOverlayDismissed()),
                  child: _FWSmkBody(
                      state: state, tabController: _tabController),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          bottomNavigationBar: BlocBuilder<FWSmkBloc, FWSmkState>(
            builder: (context, state) {
              final idx = state is FWSmkLoaded ? state.currentTab : 0;
              return _FWBottomNav(
                currentIndex: idx,
                onTap: (i) {
                  _tabController.animateTo(i);
                  context.read<FWSmkBloc>().add(FWSmkTabChanged(i));
                },
              );
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, String userName) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      toolbarHeight: 62,
      flexibleSpace:
      Container(decoration: const BoxDecoration(gradient: kGradient)),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        color: Colors.white,
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SMK Update',
              style: GoogleFonts.lato(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  letterSpacing: 0.3)),
          const SizedBox(height: 2),
          Text(userName,
              style: GoogleFonts.lato(
                  color: Colors.white.withOpacity(0.65),
                  fontWeight: FontWeight.w500,
                  fontSize: 12)),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
          child: _AppBarButton(
            label: 'Update',
            onPressed: () {
              final s = context.read<FWSmkBloc>().state;
              if (s is! FWSmkLoaded) return;

              if (s.tab1.fwDropdown == null &&
                  s.tab2.fwDropdown == null &&
                  s.tab3.fwDropdown == null) {
                objfun.toastMsg('Select FW', '', context);
                return;
              }
              if (s.jobNoText.isEmpty) {
                objfun.toastMsg('Enter Job No', '', context);
                return;
              }
              objfun
                  .ConfirmationMsgYesNo(
                  context, 'Are you sure to Update ?')
                  .then((ok) {
                if (ok == true) {
                  context.read<FWSmkBloc>().add(FWSmkSaveRequested());
                }
              });
            },
          ),
        ),
      ],
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────
class _FWSmkBody extends StatelessWidget {
  final FWSmkLoaded state;
  final TabController tabController;

  const _FWSmkBody({required this.state, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > kTabletBreak;
        final hPad = isTablet ? constraints.maxWidth * 0.06 : 0.0;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: Column(
            children: [
              // ── Job No + BillType shared across tabs ─────────────────
              _JobNoSection(state: state, isTablet: isTablet),

              // ── Tab body ─────────────────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _FWSmkTabContent(
                        tabIndex: 1, tab: state.tab1, isTablet: isTablet),
                    _FWSmkTabContent(
                        tabIndex: 2, tab: state.tab2, isTablet: isTablet),
                    _FWSmkTabContent(
                        tabIndex: 3, tab: state.tab3, isTablet: isTablet),
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

// ─── Shared Job No + BillType section ────────────────────────────────────────
class _JobNoSection extends StatefulWidget {
  final FWSmkLoaded state;
  final bool isTablet;

  const _JobNoSection({required this.state, required this.isTablet});

  @override
  State<_JobNoSection> createState() => _JobNoSectionState();
}

class _JobNoSectionState extends State<_JobNoSection> {
  late TextEditingController _jobNoCtrl;

  @override
  void initState() {
    super.initState();
    _jobNoCtrl = TextEditingController(text: widget.state.jobNoText);
  }

  @override
  void didUpdateWidget(_JobNoSection old) {
    super.didUpdateWidget(old);
    if (widget.state.jobNoText != _jobNoCtrl.text) {
      _jobNoCtrl.text = widget.state.jobNoText;
      _jobNoCtrl.selection = TextSelection.collapsed(
          offset: widget.state.jobNoText.length);
    }
  }

  @override
  void dispose() {
    _jobNoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final isTablet = widget.isTablet;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(14, 12, 14, isTablet ? 0 : 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // BillType radio
          _BillTypeRow(billType: s.billType, isTablet: isTablet),
          const SizedBox(height: 10),

          // Job No field
          TextField(
            controller: _jobNoCtrl,
            keyboardType: TextInputType.number,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            style: GoogleFonts.lato(
                color: kTextDark,
                fontWeight: FontWeight.w600,
                fontSize:
                isTablet ? objfun.FontLow + 1 : objfun.FontLow),
            decoration: InputDecoration(
              hintText: 'Job No',
              hintStyle:
              GoogleFonts.lato(color: kTextMuted, fontSize: objfun.FontLow),
              filled: true,
              fillColor: kDetailBg,
              prefixIcon: const Icon(Icons.tag_rounded,
                  color: kHeaderGradEnd, size: 20),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 13),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                const BorderSide(color: kCardBorder, width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                const BorderSide(color: kHeaderGradEnd, width: 1.5),
              ),
            ),
            onChanged: (v) => context
                .read<FWSmkBloc>()
                .add(FWSmkJobNoTextChanged(v)),
          ),

          // Inline autocomplete
          if (s.jobNoSuggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              constraints: const BoxConstraints(maxHeight: 180),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kCardBorder, width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: kHeaderGradStart.withOpacity(0.10),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: s.jobNoSuggestions.length,
                separatorBuilder: (_, __) =>
                const Divider(height: 1, color: kDetailBg),
                itemBuilder: (ctx, i) {
                  final item = s.jobNoSuggestions[i];
                  final cnum = item['CNumber'].toString();
                  return InkWell(
                    onTap: () => context.read<FWSmkBloc>().add(
                        FWSmkJobNoSelected(
                            saleOrderId: item['Id'], jobNo: cnum)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.work_outline_rounded,
                              size: 16, color: kHeaderGradEnd),
                          const SizedBox(width: 10),
                          Text(cnum,
                              style: GoogleFonts.lato(
                                  color: kTextDark,
                                  fontWeight: FontWeight.w600,
                                  fontSize: isTablet
                                      ? objfun.FontLow + 1
                                      : objfun.FontLow)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Single Tab Content ───────────────────────────────────────────────────────
class _FWSmkTabContent extends StatefulWidget {
  final int tabIndex; // 1,2,3
  final FWSmkTabData tab;
  final bool isTablet;

  const _FWSmkTabContent({
    required this.tabIndex,
    required this.tab,
    required this.isTablet,
  });

  @override
  State<_FWSmkTabContent> createState() => _FWSmkTabContentState();
}

class _FWSmkTabContentState extends State<_FWSmkTabContent> {
  late TextEditingController _smkCtrl;
  late TextEditingController _enRefCtrl;
  late TextEditingController _s1Ctrl;
  late TextEditingController _s2Ctrl;

  @override
  void initState() {
    super.initState();
    _smkCtrl  = TextEditingController(text: widget.tab.smkNo);
    _enRefCtrl = TextEditingController(text: widget.tab.enRef);
    _s1Ctrl   = TextEditingController(text: widget.tab.s1);
    _s2Ctrl   = TextEditingController(text: widget.tab.s2);
  }

  @override
  void didUpdateWidget(_FWSmkTabContent old) {
    super.didUpdateWidget(old);
    _sync(_smkCtrl,   widget.tab.smkNo);
    _sync(_enRefCtrl, widget.tab.enRef);
    _sync(_s1Ctrl,    widget.tab.s1);
    _sync(_s2Ctrl,    widget.tab.s2);
  }

  void _sync(TextEditingController ctrl, String val) {
    if (ctrl.text != val) {
      ctrl.text = val;
      ctrl.selection = TextSelection.collapsed(offset: val.length);
    }
  }

  @override
  void dispose() {
    _smkCtrl.dispose();
    _enRefCtrl.dispose();
    _s1Ctrl.dispose();
    _s2Ctrl.dispose();
    super.dispose();
  }

  void _emit(FWSmkEvent e) => context.read<FWSmkBloc>().add(e);
  int get t => widget.tabIndex;

  @override
  Widget build(BuildContext context) {
    final tab = widget.tab;
    final isTablet = widget.isTablet;

    return ListView(
      padding: EdgeInsets.fromLTRB(14, 14, 14, isTablet ? 24 : 16),
      children: [
        // ── Date + checkbox ──────────────────────────────────────────
        _DateCheckRow(
          tab: tab,
          isTablet: isTablet,
          onDateTap: () async {
            if (!tab.dateEnabled) return;
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.tryParse(tab.date) ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2050),
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: kHeaderGradStart,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: kTextDark,
                  ),
                ),
                child: child!,
              ),
            );
            if (picked != null) {
              _emit(FWSmkDateChanged(
                  tab: t,
                  date: DateFormat('yyyy-MM-dd').format(picked)));
            }
          },
          onCheckChanged: (v) =>
              _emit(FWSmkCheckboxChanged(tab: t, value: v)),
        ),
        const SizedBox(height: 12),

        // ── FW Dropdown ──────────────────────────────────────────────
        _FieldLabel('FW $t', isTablet),
        const SizedBox(height: 6),
        _FWDropdown(
          value: tab.fwDropdown,
          isTablet: isTablet,
          onChanged: (v) =>
              _emit(FWSmkFieldChanged(tab: t, field: 'fwDropdown', value: v)),
        ),
        const SizedBox(height: 12),

        // ── SMK No ───────────────────────────────────────────────────
        _FieldLabel('SMK No $t', isTablet),
        const SizedBox(height: 6),
        _SMKTextField(
          controller: _smkCtrl,
          hint: 'SMK NO $t',
          isTablet: isTablet,
          onChanged: (v) =>
              _emit(FWSmkFieldChanged(tab: t, field: 'smkNo', value: v)),
        ),
        const SizedBox(height: 12),

        // ── R.No ─────────────────────────────────────────────────────
        _FieldLabel('R.No $t', isTablet),
        const SizedBox(height: 6),
        _SMKTextField(
          controller: _enRefCtrl,
          hint: 'R.No $t',
          isTablet: isTablet,
          onChanged: (v) =>
              _emit(FWSmkFieldChanged(tab: t, field: 'enRef', value: v)),
        ),
        const SizedBox(height: 12),

        // ── S1 ───────────────────────────────────────────────────────
        _FieldLabel('S1', isTablet),
        const SizedBox(height: 6),
        _SMKTextField(
          controller: _s1Ctrl,
          hint: 'S1',
          isTablet: isTablet,
          onChanged: (v) =>
              _emit(FWSmkFieldChanged(tab: t, field: 's1', value: v)),
        ),
        const SizedBox(height: 12),

        // ── S2 ───────────────────────────────────────────────────────
        _FieldLabel('S2', isTablet),
        const SizedBox(height: 6),
        _SMKTextField(
          controller: _s2Ctrl,
          hint: 'S2',
          isTablet: isTablet,
          onChanged: (v) =>
              _emit(FWSmkFieldChanged(tab: t, field: 's2', value: v)),
        ),
      ],
    );
  }
}

// ─── Date + Checkbox Row ──────────────────────────────────────────────────────
class _DateCheckRow extends StatelessWidget {
  final FWSmkTabData tab;
  final bool isTablet;
  final VoidCallback onDateTap;
  final void Function(bool) onCheckChanged;

  const _DateCheckRow({
    required this.tab,
    required this.isTablet,
    required this.onDateTap,
    required this.onCheckChanged,
  });

  @override
  Widget build(BuildContext context) {
    String display;
    try {
      display = DateFormat(isTablet ? 'dd-MM-yyyy' : 'dd-MM-yy')
          .format(DateTime.parse(tab.date));
    } catch (_) {
      display = tab.date;
    }

    return Row(
      children: [
        // Date tile
        Expanded(
          flex: 5,
          child: InkWell(
            onTap: onDateTap,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: kDetailBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kCardBorder, width: 0.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      display,
                      style: GoogleFonts.lato(
                        color: tab.dateEnabled ? kTextDark : kTextMuted,
                        fontWeight: FontWeight.w600,
                        fontSize:
                        isTablet ? objfun.FontLow + 1 : objfun.FontLow,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 20,
                    color: tab.dateEnabled ? kHeaderGradEnd : kTextMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Animated checkbox
        InkWell(
          onTap: () => onCheckChanged(!tab.dateEnabled),
          borderRadius: BorderRadius.circular(6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: isTablet ? 24 : 20,
            height: isTablet ? 24 : 20,
            decoration: BoxDecoration(
              gradient: tab.dateEnabled ? kGradient : null,
              border: tab.dateEnabled
                  ? null
                  : Border.all(color: kCardBorder, width: 1.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: tab.dateEnabled
                ? const Icon(Icons.check_rounded,
                size: 14, color: Colors.white)
                : null,
          ),
        ),
      ],
    );
  }
}

// ─── FW Dropdown ─────────────────────────────────────────────────────────────
class _FWDropdown extends StatelessWidget {
  final String? value;
  final bool isTablet;
  final void Function(String) onChanged;

  const _FWDropdown(
      {required this.value,
        required this.isTablet,
        required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: kDetailBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kCardBorder, width: 0.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text('Select FW',
              style: GoogleFonts.lato(
                  color: kTextMuted,
                  fontSize: isTablet ? objfun.FontLow + 1 : objfun.FontLow)),
          style: GoogleFonts.lato(
            color: kTextDark,
            fontWeight: FontWeight.w600,
            fontSize: isTablet ? objfun.FontLow + 1 : objfun.FontLow,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(10),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: kHeaderGradEnd),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          items: kForwardingOptions
              .map((v) => DropdownMenuItem(
            value: v,
            child: Text(v,
                style: GoogleFonts.lato(
                  color: kTextDark,
                  fontWeight: FontWeight.w600,
                  fontSize:
                  isTablet ? objfun.FontLow + 1 : objfun.FontLow,
                )),
          ))
              .toList(),
        ),
      ),
    );
  }
}

// ─── Bill Type Radio Row ──────────────────────────────────────────────────────
class _BillTypeRow extends StatelessWidget {
  final String billType;
  final bool isTablet;

  const _BillTypeRow({required this.billType, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: kDetailBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kCardBorder, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _RadioOption(
            label: 'MY',
            value: '0',
            groupValue: billType,
            isTablet: isTablet,
            onChanged: (v) =>
                context.read<FWSmkBloc>().add(FWSmkBillTypeChanged(v)),
          ),
          SizedBox(width: isTablet ? 32 : 20),
          _RadioOption(
            label: 'TR',
            value: '1',
            groupValue: billType,
            isTablet: isTablet,
            onChanged: (v) =>
                context.read<FWSmkBloc>().add(FWSmkBillTypeChanged(v)),
          ),
        ],
      ),
    );
  }
}

class _RadioOption extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final bool isTablet;
  final void Function(String) onChanged;

  const _RadioOption({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.isTablet,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: isTablet ? 22 : 18,
              height: isTablet ? 22 : 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? kHeaderGradEnd : kCardBorder,
                  width: selected ? 0 : 1.5,
                ),
                gradient: selected ? kGradient : null,
              ),
              child: selected
                  ? const Icon(Icons.circle, size: 10, color: Colors.white)
                  : null,
            ),
            SizedBox(width: isTablet ? 8 : 6),
            Text(
              label,
              style: GoogleFonts.lato(
                color: selected ? kHeaderGradStart : kTextMid,
                fontWeight: FontWeight.w700,
                fontSize:
                isTablet ? objfun.FontMedium + 1 : objfun.FontMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom Navigation ────────────────────────────────────────────────────────
class _FWBottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const _FWBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: kCardBorder, width: 0.5))),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: currentIndex,
        selectedItemColor: kHeaderGradStart,
        unselectedItemColor: kTextMuted,
        selectedLabelStyle: GoogleFonts.lato(
            fontWeight: FontWeight.w700, fontSize: objfun.FontLow),
        unselectedLabelStyle: GoogleFonts.lato(
            fontWeight: FontWeight.w500, fontSize: objfun.FontCardText),
        onTap: onTap,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping_outlined), label: 'FW 1'),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping_outlined), label: 'FW 2'),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping_outlined), label: 'FW 3'),
        ],
      ),
    );
  }
}

// ─── Shared Reusable Widgets ──────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  final bool isTablet;
  const _FieldLabel(this.text, this.isTablet);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.lato(
        color: kTextMid,
        fontWeight: FontWeight.w600,
        fontSize: isTablet ? objfun.FontLow + 1 : objfun.FontLow,
      ),
    );
  }
}

class _SMKTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isTablet;
  final void Function(String) onChanged;

  const _SMKTextField({
    required this.controller,
    required this.hint,
    required this.isTablet,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.characters,
      textInputAction: TextInputAction.done,
      onChanged: onChanged,
      style: GoogleFonts.lato(
        color: kTextDark,
        fontWeight: FontWeight.w600,
        fontSize: isTablet ? objfun.FontLow + 1 : objfun.FontLow,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.lato(
            color: kTextMuted,
            fontSize: isTablet ? objfun.FontLow + 1 : objfun.FontLow),
        filled: true,
        fillColor: kDetailBg,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kCardBorder, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kHeaderGradEnd, width: 1.5),
        ),
      ),
    );
  }
}

class _AppBarButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _AppBarButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border:
        Border.all(color: Colors.white.withOpacity(0.4), width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(label,
                style: GoogleFonts.lato(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: objfun.FontMedium)),
          ),
        ),
      ),
    );
  }
}