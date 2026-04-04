import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import '../../../../../../MasterSearch/Port.dart';
import '../../../../../../core/theme/tokens.dart';
import '../bloc/vesselreport_bloc.dart';
import '../bloc/vesselreport_event.dart';
import '../bloc/vesselreport_state.dart';
import 'package:maleva/core/colors/colors.dart' as colour;

// ─── Page ──────────────────────────────────────────────────────────────────────
class VesselReportPage extends StatelessWidget {
  const VesselReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VesselBloc(context: context)
        ..add(const LoadVesselDataEvent(type: 0)),
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
                  _SectionHeader(title: 'Vessel Report', isTablet: true),
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
                _ListHeader(isTablet: true),
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
                        port: item["Port"].toString(),
                        isTablet: true,
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
        _SectionHeader(title: 'Vessel Report', isTablet: false),
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

        _ListHeader(isTablet: false),
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
              port:       item["Port"].toString(),
              isTablet:   false,
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
            color: AppTokens.brandGradientStart.withOpacity(0.08),
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
                    ).then((_) {
                      if (objfun.SelectedPortName.isNotEmpty) {
                        bloc.add(UpdatePortEvent(
                            portName: objfun.SelectedPortName));
                        objfun.SelectedPortName = "";
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
          color:    AppTokens.brandMid.withOpacity(0.6),
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
          borderSide: BorderSide(color: AppTokens.brandLight),
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
        ? Colors.red.withOpacity(0.08)
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
                color:  AppTokens.brandGradientStart.withOpacity(0.3),
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
                  color:      colour.kWhite.withOpacity(0.8))),
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
          child: Text('Port',
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
  final String port;
  final bool isTablet;

  const _VesselCard({
    required this.index,
    required this.vesselName,
    required this.port,
    required this.isTablet,
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
          onTap: () {},
          borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
          splashColor: AppTokens.brandGradientStart.withOpacity(0.08),
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
                    : AppTokens.brandMid.withOpacity(0.3),
                width: 1.2,
              ),
              boxShadow: isEven
                  ? [
                BoxShadow(
                  color:  AppTokens.brandGradientStart.withOpacity(0.05),
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
                      : AppTokens.brandGradientStart.withOpacity(0.12),
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
                  color: AppTokens.brandGradientStart.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppTokens.brandMid.withOpacity(0.3),
                      width: 1),
                ),
                child: Text(
                  port,
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
          decoration: BoxDecoration(
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