import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import '../../../../../core/theme/tokens.dart';
import '../../../../mastersearch/Port.dart';
import '../bloc/vesselreport_bloc.dart';
import '../bloc/vesselreport_event.dart';
import '../bloc/vesselreport_state.dart';
import 'package:maleva/core/colors/colors.dart' as colour;

// VesselReportPage — REMOVE BlocProvider from here
class VesselReportPage extends StatelessWidget {
  const VesselReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<VesselBloc, VesselState>( // ✅ No BlocProvider here
      listener: (context, state) {
        if (state is VesselErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: const _VesselReportView(),
    );
  }
}

// ─── View ──────────────────────────────────────────────────────────────────────
class _VesselReportView extends StatefulWidget {
  const _VesselReportView();

  @override
  State<_VesselReportView> createState() => _VesselReportViewState();
}

class _VesselReportViewState extends State<_VesselReportView> {
  final TextEditingController _txtPort    = TextEditingController();
  final TextEditingController _txtRemarks = TextEditingController();
  bool _isPlanToday = true;

  @override
  void dispose() {
    _txtPort.dispose();
    _txtRemarks.dispose();
    super.dispose();
  }

  void _syncControllersFromState(VesselState state) {
    if (state is VesselLoadedState) {
      if (_txtPort.text    != state.portName)   _txtPort.text    = state.portName;
      if (_txtRemarks.text != state.searchText) _txtRemarks.text = state.searchText;
      _isPlanToday = state.isPlanToday;
    } else if (state is VesselFieldUpdatedState) {
      if (_txtPort.text    != state.portName)   _txtPort.text    = state.portName;
      if (_txtRemarks.text != state.searchText) _txtRemarks.text = state.searchText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return BlocConsumer<VesselBloc, VesselState>(
      listener: (context, state) {
        _syncControllersFromState(state);

        if (state is VesselErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage,
                  style: GoogleFonts.poppins(color: colour.kWhite)),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }

        if (state is VesselUpdateActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message,
                  style: GoogleFonts.poppins(color: colour.kWhite)),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }

        if (state is VesselUpdateActionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message,
                  style: GoogleFonts.poppins(color: colour.kWhite)),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }

        if (state is VesselFieldUpdatedState) {
          context
              .read<VesselBloc>()
              .add(LoadVesselDataEvent(type: _isPlanToday ? 0 : 1));
        }
      },
      builder: (context, state) {
        final bloc      = context.read<VesselBloc>();
        final isLoading = state is VesselLoadingState;
        final vesselList = state is VesselLoadedState
            ? state.vesselList
            : <Map<String, dynamic>>[];

        return Container(
          color: const Color(0xFFF4F6FF),
          child: isTablet
              ? _buildTabletLayout(
              context, bloc, isLoading, vesselList)
              : _buildMobileLayout(
              context, bloc, isLoading, vesselList),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════
  // TABLET — Two Column
  // ══════════════════════════════════════════════════════
  Widget _buildTabletLayout(
      BuildContext context,
      VesselBloc bloc,
      bool isLoading,
      List<Map<String, dynamic>> vesselList,
      ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── LEFT (45%) — Header + Search + Toggle
          Expanded(
            flex: 45,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionHeader(title: 'Vessel Report', isTablet: true),
                  const SizedBox(height: 20),
                  _SearchCard(
                    txtPort:     _txtPort,
                    txtRemarks:  _txtRemarks,
                    bloc:        bloc,
                    isPlanToday: _isPlanToday,
                    isTablet:    true,
                  ),
                  const SizedBox(height: 16),
                  _DayToggle(
                    isPlanToday: _isPlanToday,
                    isTablet:    true,
                    onToday: () {
                      setState(() => _isPlanToday = true);
                      bloc.add(const LoadVesselDataEvent(type: 0));
                    },
                    onTomorrow: () {
                      setState(() => _isPlanToday = false);
                      bloc.add(const LoadVesselDataEvent(type: 1));
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          const SizedBox(width: 16),

          // ── RIGHT (55%) — List Header + Vessel List
          Expanded(
            flex: 55,
            child: Column(
              children: [
                const _ListHeader(isTablet: true),
                const SizedBox(height: 10),
                Expanded(
                  child: isLoading
                      ? const Center(
                    child: CircularProgressIndicator(
                        color: AppTokens.brandGradientStart),
                  )
                      : vesselList.isEmpty
                      ? _EmptyState()
                      : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: vesselList.length,
                    itemBuilder: (context, index) {
                      final item = vesselList[index];
                      return _VesselCard(
                        index:      index,
                        vesselName: item["Loadingvesselname"]
                            .toString(),
                        jobNo: item["JobNo"]?.toString() ?? '',
                        isTablet: true,
                        itemData: item,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // MOBILE — Single Column
  // ══════════════════════════════════════════════════════
  Widget _buildMobileLayout(
      BuildContext context,
      VesselBloc bloc,
      bool isLoading,
      List<Map<String, dynamic>> vesselList,
      ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      children: [
        const _SectionHeader(title: 'Vessel Report', isTablet: false),
        const SizedBox(height: 16),

        _SearchCard(
          txtPort:     _txtPort,
          txtRemarks:  _txtRemarks,
          bloc:        bloc,
          isPlanToday: _isPlanToday,
          isTablet:    false,
        ),
        const SizedBox(height: 14),

        _DayToggle(
          isPlanToday: _isPlanToday,
          isTablet:    false,
          onToday: () {
            setState(() => _isPlanToday = true);
            bloc.add(const LoadVesselDataEvent(type: 0));
          },
          onTomorrow: () {
            setState(() => _isPlanToday = false);
            bloc.add(const LoadVesselDataEvent(type: 1));
          },
        ),
        const SizedBox(height: 16),

        const _ListHeader(isTablet: false),
        const SizedBox(height: 8),

        if (isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Center(
                child: CircularProgressIndicator(
                    color: AppTokens.brandGradientStart)),
          )
        else if (vesselList.isEmpty)
          _EmptyState()
        else
          ...List.generate(vesselList.length, (index) {
            final item = vesselList[index];
            return _VesselCard(
              index:      index,
              vesselName: item["Loadingvesselname"].toString(),
              jobNo:      item["JobNo"]?.toString() ?? '',
              isTablet:   false,
              itemData:   item,
            );
          }),
      ],
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isTablet;
  const _SectionHeader(
      {required this.title, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 4,
        height: isTablet ? 30 : 26,
        decoration: BoxDecoration(
          color: AppTokens.brandGradientStart,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      const SizedBox(width: 10),
      Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize:      isTablet ? 20 : 17,
          fontWeight:    FontWeight.w700,
          color:         AppTokens.brandDark,
          letterSpacing: 1.2,
        ),
      ),
    ]);
  }
}

// ─── Search Card ──────────────────────────────────────────────────────────────
class _SearchCard extends StatelessWidget {
  final TextEditingController txtPort;
  final TextEditingController txtRemarks;
  final VesselBloc bloc;
  final bool isPlanToday;
  final bool isTablet;

  const _SearchCard({
    required this.txtPort,
    required this.txtRemarks,
    required this.bloc,
    required this.isPlanToday,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: colour.kWhite,
        borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
        border: Border.all(color: AppTokens.brandLight, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTokens.brandGradientStart.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: [
        // ── Port Row
        Row(children: [
          Expanded(
            child: _StyledTextField(
              controller: txtPort,
              hint:       'Search Port...',
              readOnly:   true,
              isTablet:   isTablet,
              suffixIcon: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  if (txtPort.text.isEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const Port(Searchby: 1, SearchId: 0),
                      ),
                    ).then((navRes) {
                      if (AppGlobals.SelectedPortName.isNotEmpty) {
                        bloc.add(UpdatePortEvent(
                            portName: AppGlobals.SelectedPortName));
                        AppGlobals.SelectedPortName = "";
                      }
                    });
                  } else {
                    bloc.add(const ClearPortEvent());
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTokens.brandLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    txtPort.text.isNotEmpty
                        ? Icons.close_rounded
                        : Icons.search_rounded,
                    color: AppTokens.brandGradientStart,
                    size: isTablet ? 20 : 18,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          _ActionIconButton(
            icon:    Icons.add_rounded,
            tooltip: 'Add Port',
            isTablet: isTablet,
            onTap: () => bloc.add(AddPortToSearchEvent(
              portName:      txtPort.text,
              currentSearch: txtRemarks.text,
            )),
          ),
          const SizedBox(width: 6),
          _ActionIconButton(
            icon:    Icons.refresh_rounded,
            tooltip: 'Reload',
            isTablet: isTablet,
            onTap: () => bloc.add(
                LoadVesselDataEvent(type: isPlanToday ? 0 : 1)),
          ),
          const SizedBox(width: 6),
          _ActionIconButton(
            icon:          Icons.delete_outline_rounded,
            tooltip:       'Clear',
            isTablet:      isTablet,
            onTap:         () => bloc.add(const ClearSearchEvent()),
            isDestructive: true,
          ),
        ]),

        SizedBox(height: isTablet ? 14 : 12),

        // ── Remarks TextField
        _StyledTextField(
          controller:        txtRemarks,
          hint:              'Search vessels...',
          maxLines:          3,
          isTablet:          isTablet,
          textCapitalization: TextCapitalization.characters,
        ),
      ]),
    );
  }
}

// ─── Styled TextField ─────────────────────────────────────────────────────────
class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool readOnly;
  final Widget? suffixIcon;
  final int maxLines;
  final TextCapitalization textCapitalization;
  final bool isTablet;

  const _StyledTextField({
    required this.controller,
    required this.hint,
    required this.isTablet,
    this.readOnly           = false,
    this.suffixIcon,
    this.maxLines           = 1,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller:         controller,
      readOnly:           readOnly,
      maxLines:           maxLines,
      textCapitalization: textCapitalization,
      textInputAction:    TextInputAction.done,
      style: GoogleFonts.poppins(
        fontSize:   isTablet ? 14 : 13,
        fontWeight: FontWeight.w600,
        color:      AppTokens.brandDark,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: isTablet ? 14 : 13,
          color:    AppTokens.brandMid.withValues(alpha: 0.6),
        ),
        suffixIcon: suffixIcon != null
            ? Padding(
          padding: const EdgeInsets.only(right: 8),
          child: suffixIcon,
        )
            : null,
        suffixIconConstraints:
        const BoxConstraints(minWidth: 36, minHeight: 36),
        filled:         true,
        fillColor:      AppTokens.brandLight,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 16 : 14,
          vertical:   isTablet ? 14 : 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
          borderSide: const BorderSide(color: AppTokens.brandLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
          borderSide:
          const BorderSide(color: AppTokens.brandGradientStart, width: 1.5),
        ),
      ),
    );
  }
}

// ─── Action Icon Button ───────────────────────────────────────────────────────
class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isTablet;

  const _ActionIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.isTablet,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.redAccent : AppTokens.brandGradientStart;
    final bg    = isDestructive
        ? Colors.red.withValues(alpha: 0.08)
        : AppTokens.brandLight;
    final size  = isTablet ? 44.0 : 38.0;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width:  size,
          height: size,
          decoration: BoxDecoration(
            color:         bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: isTablet ? 22 : 20),
        ),
      ),
    );
  }
}

// ─── Day Toggle ───────────────────────────────────────────────────────────────
class _DayToggle extends StatelessWidget {
  final bool isPlanToday;
  final bool isTablet;
  final VoidCallback onToday;
  final VoidCallback onTomorrow;

  const _DayToggle({
    required this.isPlanToday,
    required this.isTablet,
    required this.onToday,
    required this.onTomorrow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isTablet ? 52 : 44,
      decoration: BoxDecoration(
        color:         AppTokens.brandLight,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
      ),
      child: Row(children: [
        _ToggleTab(
            label:    'Today',
            isActive: isPlanToday,
            isTablet: isTablet,
            onTap:    onToday),
        _ToggleTab(
            label:    'Tomorrow',
            isActive: !isPlanToday,
            isTablet: isTablet,
            onTap:    onTomorrow),
      ]),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isTablet;
  final VoidCallback onTap;

  const _ToggleTab({
    required this.label,
    required this.isActive,
    required this.isTablet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive ? AppTokens.brandGradientStart : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
              BoxShadow(
                color:  AppTokens.brandGradientStart.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
            ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize:   isTablet ? 14 : 13,
              fontWeight: FontWeight.w600,
              color:      isActive ? colour.kWhite : AppTokens.brandMid,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── List Header ──────────────────────────────────────────────────────────────
class _ListHeader extends StatelessWidget {
  final bool isTablet;
  const _ListHeader({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 16,
        vertical:   isTablet ? 13 : 10,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTokens.brandGradientStart, AppTokens.brandDark],
          begin: Alignment.centerLeft,
          end:   Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      ),
      child: Row(children: [
        SizedBox(
          width: isTablet ? 36 : 32,
          child: Text('#',
              style: GoogleFonts.poppins(
                  fontSize:   isTablet ? 13 : 12,
                  fontWeight: FontWeight.w700,
                  color:      colour.kWhite.withValues(alpha: 0.8))),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text('Vessel Name',
              style: GoogleFonts.poppins(
                  fontSize:   isTablet ? 13 : 12,
                  fontWeight: FontWeight.w700,
                  color:      colour.kWhite)),
        ),
        Expanded(
          flex: 2,
          child: Text('Job No.',
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                  fontSize:   isTablet ? 13 : 12,
                  fontWeight: FontWeight.w700,
                  color:      colour.kWhite)),
        ),
      ]),
    );
  }
}

// ─── Vessel Card ──────────────────────────────────────────────────────────────
class _VesselCard extends StatelessWidget {
  final int index;
  final String vesselName;
  final String jobNo;
  final bool isTablet;
  final Map<String, dynamic> itemData;

  const _VesselCard({
    required this.index,
    required this.vesselName,
    required this.jobNo,
    required this.isTablet,
    required this.itemData,
  });

  @override
  Widget build(BuildContext context) {
    final isEven = index % 2 == 0;

    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 10 : 8),
      child: Material(
        color: isEven ? colour.kWhite : AppTokens.brandLight,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
        child: InkWell(
          onTap: () => _showVesselDetails(context),
          onLongPress: () {
            if (AppPreferences.getRoleId() != 500) {
              _showVesselEditSheet(context);
            }
          },
          borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
          splashColor: AppTokens.brandGradientStart.withValues(alpha: 0.08),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 18 : 14,
              vertical:   isTablet ? 14 : 12,
            ),
            decoration: BoxDecoration(
              borderRadius:
              BorderRadius.circular(isTablet ? 16 : 14),
              border: Border.all(
                color: isEven
                    ? AppTokens.brandLight
                    : AppTokens.brandMid.withValues(alpha: 0.3),
                width: 1.2,
              ),
              boxShadow: isEven
                  ? [
                BoxShadow(
                  color:  AppTokens.brandGradientStart.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ]
                  : [],
            ),
            child: Row(children: [
              // Index badge
              Container(
                width:  isTablet ? 32 : 28,
                height: isTablet ? 32 : 28,
                decoration: BoxDecoration(
                  color: isEven
                      ? AppTokens.brandLight
                      : AppTokens.brandGradientStart.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: GoogleFonts.poppins(
                      fontSize:   isTablet ? 12 : 11,
                      fontWeight: FontWeight.w700,
                      color:      AppTokens.brandGradientStart),
                ),
              ),
              const SizedBox(width: 10),

              // Vessel name
              Expanded(
                flex: 3,
                child: Text(
                  vesselName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: GoogleFonts.poppins(
                      fontSize:   isTablet ? 14 : 13,
                      fontWeight: FontWeight.w600,
                      color:      AppTokens.brandDark),
                ),
              ),

              // Port chip
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 14 : 10,
                  vertical:   isTablet ? 6  : 4,
                ),
                decoration: BoxDecoration(
                  color: AppTokens.brandGradientStart.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppTokens.brandMid.withValues(alpha: 0.3),
                      width: 1),
                ),
                child: Text(
                  jobNo,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: GoogleFonts.poppins(
                      fontSize:   isTablet ? 12 : 11,
                      fontWeight: FontWeight.w600,
                      color:      AppTokens.brandGradientStart),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  void _showVesselDetails(BuildContext context) {
    final isTab = MediaQuery.of(context).size.width >= 600;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: AppTokens.brandGradientStart.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTokens.brandMid.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding: EdgeInsets.fromLTRB(
                    isTab ? 24 : 20, 16, isTab ? 24 : 20, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTokens.brandGradientStart.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.directions_boat_filled,
                          color: AppTokens.brandGradientStart,
                          size: isTab ? 24 : 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vesselName,
                            style: GoogleFonts.poppins(
                              fontSize: isTab ? 18 : 16,
                              fontWeight: FontWeight.w700,
                              color: AppTokens.brandDark,
                            ),
                          ),
                          Text(
                            itemData["Port"]?.toString() ?? '',
                            style: GoogleFonts.poppins(
                              fontSize: isTab ? 13 : 12,
                              color: AppTokens.brandMid,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close_rounded,
                          color: AppTokens.brandMid, size: isTab ? 24 : 22),
                    ),
                  ],
                ),
              ),

              const Divider(color: AppTokens.brandLight, thickness: 1.5),

              // Detail rows
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                      isTab ? 24 : 20, 8, isTab ? 24 : 20, 24),
                  child: Column(
                    children: [
                      _detailRow('Job No', itemData['JobNo'], isTab),
                      _detailRow('Job Date', itemData['JobDate'], isTab),
                      _detailRow('Job Status', itemData['JobStatus'], isTab),
                      _detailRow('Vessel Type', itemData['VesselType'], isTab),
                      _detailRow('Vessel Name', itemData['Loadingvesselname'], isTab),
                      _detailRow('Off Vessel', itemData['Offvesselname'], isTab),
                      _detailRow('PKG', itemData['pkg'], isTab),
                      _detailRow('SCN', itemData['SCN'], isTab),
                      _detailRow('OSCN', itemData['OSCN'], isTab),
                      _detailRow('LSCN', itemData['LSCN'], isTab),
                      _detailRow('ETA', itemData['SETA'], isTab),
                      _detailRow('ETB', itemData['SETB'], isTab),
                      _detailRow('ETD', itemData['SETD'], isTab),
                      _detailRow('OETA', itemData['SOETA'], isTab),
                      _detailRow('OETB', itemData['SOETB'], isTab),
                      _detailRow('OETD', itemData['SOETD'], isTab),
                      _detailRow('Origin', itemData['Origin'], isTab),
                      _detailRow('Destination', itemData['Destination'], isTab),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, dynamic value, bool isTab) {
    final displayValue = (value == null || value.toString().trim().isEmpty)
        ? '-'
        : value.toString().trim();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isTab ? 130 : 110,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: isTab ? 13 : 12,
                fontWeight: FontWeight.w500,
                color: AppTokens.brandMid,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              displayValue,
              style: GoogleFonts.poppins(
                fontSize: isTab ? 14 : 13,
                fontWeight: FontWeight.w600,
                color: AppTokens.brandDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showVesselEditSheet(BuildContext context) {
    // We capture the bloc here so we can pass its value into the new route
    final vesselBloc = context.read<VesselBloc>();
    final isTab = MediaQuery.of(context).size.width >= 600;
    
    // Initial data parsing
    String parseDate(dynamic val) {
      if (val == null) return '';
      final s = val.toString().trim();
      if (s.isEmpty || s.startsWith('0001-01-01') || s.startsWith('1900-')) return '';
      // Ensure we display correctly, but the API might expect a specific format
      return s; 
    }

    String eta = parseDate(itemData['SETA']);
    String etb = parseDate(itemData['SETB']);
    String oeta = parseDate(itemData['SOETA']);
    String oetb = parseDate(itemData['SOETB']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        // We use BlocProvider.value to properly inject the BLoC into the BottomSheet's widget tree
        // This is the correct standard architectural pattern for BLoC and new routes
        return BlocProvider.value(
          value: vesselBloc,
          child: StatefulBuilder(
            builder: (BuildContext sheetContext, StateSetter setState) {
            
            Widget buildEditField(String label, String value, Function(String) onChanged) {
              final controller = TextEditingController(text: value);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: isTab ? 90 : 80,
                      child: Text(
                        label,
                        style: GoogleFonts.poppins(
                          fontSize: isTab ? 13 : 12,
                          fontWeight: FontWeight.w600,
                          color: AppTokens.brandMid,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        readOnly: true,
                        style: GoogleFonts.poppins(
                          fontSize: isTab ? 14 : 13,
                          fontWeight: FontWeight.w500,
                          color: AppTokens.brandDark,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppTokens.brandMid.withValues(alpha: 0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppTokens.brandMid.withValues(alpha: 0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppTokens.brandGradientStart),
                          ),
                          suffixIcon: const Icon(Icons.calendar_month_outlined, size: 20, color: AppTokens.brandMid),
                        ),
                        onTap: () async {
                          DateTime initial = DateTime.now();
                          if (value.isNotEmpty) {
                            try {
                              initial = DateFormat('yyyy-MM-dd HH:mm:ss').parse(value.replaceAll('T', ' '));
                            } catch (e) {
                              // ignore
                            }
                          }
                          final date = await showDatePicker(
                            context: context,
                            initialDate: initial,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            if (!context.mounted) return;
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(initial),
                              initialEntryMode: TimePickerEntryMode.input,
                              builder: (BuildContext context, Widget? child) {
                                return MediaQuery(
                                  data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: AppTokens.brandGradientStart, // matches your button color
                                      ),
                                    ),
                                    child: child!,
                                  ),
                                );
                              },
                            );
                            if (time != null) {
                              final combined = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                              final formatted = DateFormat('yyyy-MM-dd HH:mm:ss').format(combined);
                              controller.text = formatted;
                              onChanged(formatted);
                              setState(() {});
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            }

            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(isTab ? 24 : 20, 16, isTab ? 24 : 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTokens.brandMid.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Update Vessel Dates',
                      style: GoogleFonts.poppins(
                        fontSize: isTab ? 18 : 16,
                        fontWeight: FontWeight.w700,
                        color: AppTokens.brandDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vesselName,
                      style: GoogleFonts.poppins(
                        fontSize: isTab ? 14 : 13,
                        color: AppTokens.brandMid,
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (eta.isNotEmpty) buildEditField('ETA', eta, (v) => eta = v),
                    if (etb.isNotEmpty) buildEditField('ETB', etb, (v) => etb = v),
                    if (oeta.isNotEmpty) buildEditField('OETA', oeta, (v) => oeta = v),
                    if (oetb.isNotEmpty) buildEditField('OETB', oetb, (v) => oetb = v),


                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTokens.brandGradientStart,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // Hide keyboard
                          FocusScope.of(context).unfocus();

                          // Format for API: "yyyy-MM-dd HH:mm:ss"
                          String formatForApi(String dt, String originalKey) {
                            if (dt.isEmpty) {
                              // If empty (hidden from UI), send the original value so we don't send "" to a DateTime field
                              return itemData[originalKey]?.toString() ?? "";
                            }
                            return dt.replaceAll('T', ' ');
                          }

                          final updateData = {
                            "Jobid": itemData['SaleOrderMasterRefId'],
                            "ETA": formatForApi(eta, 'SETA'),
                            "ETB": formatForApi(etb, 'SETB'),
                            "OETA": formatForApi(oeta, 'SOETA'),
                            "OETB": formatForApi(oetb, 'SOETB'),
                            "Comid": AppGlobals.Comid,
                            "Type": 100, // SAVE ALL
                          };

                          vesselBloc.add(
                            UpdateVesselDateEvent(
                              updateData: updateData,
                              onSuccess: () {
                                Navigator.pop(ctx);
                                // The BLoC listener will show success and we can refresh
                                vesselBloc.add(const LoadVesselDataEvent(type: 0));
                              },
                            ),
                          );
                        },
                        child: Text(
                          'Save Updates',
                          style: GoogleFonts.poppins(
                            fontSize: isTab ? 15 : 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        );
      },
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    return Padding(
      padding: EdgeInsets.only(top: isTablet ? 60 : 48),
      child: Column(children: [
        Container(
          padding: EdgeInsets.all(isTablet ? 24 : 20),
          decoration: const BoxDecoration(
            color: AppTokens.brandLight,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.directions_boat_outlined,
              size: isTablet ? 48 : 40,
              color: AppTokens.brandGradientStart),
        ),
        SizedBox(height: isTablet ? 20 : 16),
        Text('No vessels found',
            style: GoogleFonts.poppins(
              fontSize:   isTablet ? 17 : 15,
              fontWeight: FontWeight.w600,
              color:      AppTokens.brandDark,
            )),
        SizedBox(height: isTablet ? 8 : 6),
        Text('Try adjusting your search or date filter',
            style: GoogleFonts.poppins(
              fontSize: isTablet ? 13 : 12,
              color:    AppTokens.brandMid,
            )),
      ]),
    );
  }
}