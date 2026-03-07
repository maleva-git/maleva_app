import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import '../../../../../../MasterSearch/Port.dart';
import '../bloc/vesselreport_bloc.dart';
import '../bloc/vesselreport_event.dart';
import '../bloc/vesselreport_state.dart';
import 'package:maleva/core/colors/colors.dart' as colour;


// ─── Page ───────────────────────────────────────────────────────────────────────
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

// ─── View ────────────────────────────────────────────────────────────────────────
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
        final bloc       = context.read<VesselBloc>();
        final isLoading  = state is VesselLoadingState;
        final vesselList = state is VesselLoadedState
            ? state.vesselList
            : <Map<String, dynamic>>[];

        return Container(
          color: const Color(0xFFF4F6FF),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            children: [
              // ── Header ─────────────────────────────────────────────────────
              _SectionHeader(title: 'Vessel Report'),
              const SizedBox(height: 16),

              // ── Search Card ────────────────────────────────────────────────
              _SearchCard(
                txtPort:    _txtPort,
                txtRemarks: _txtRemarks,
                bloc:       bloc,
                isPlanToday: _isPlanToday,
              ),
              const SizedBox(height: 14),

              // ── Today / Tomorrow Toggle ─────────────────────────────────────
              _DayToggle(
                isPlanToday: _isPlanToday,
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

              // ── List Header ─────────────────────────────────────────────────
              _ListHeader(),
              const SizedBox(height: 8),

              // ── Vessel List ─────────────────────────────────────────────────
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(
                      child: CircularProgressIndicator(color: colour.kPrimary)),
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
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 26,
          decoration: BoxDecoration(
            color: colour.kPrimary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: colour.kPrimaryDark,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

// ─── Search Card ──────────────────────────────────────────────────────────────
class _SearchCard extends StatelessWidget {
  final TextEditingController txtPort;
  final TextEditingController txtRemarks;
  final VesselBloc bloc;
  final bool isPlanToday;

  const _SearchCard({
    required this.txtPort,
    required this.txtRemarks,
    required this.bloc,
    required this.isPlanToday,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colour.kWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colour.kAccent, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: colour.kPrimary.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Port Row ──────────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _StyledTextField(
                  controller: txtPort,
                  hint: 'Search Port...',
                  readOnly: true,
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
                            bloc.add(
                                UpdatePortEvent(portName: objfun.SelectedPortName));
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
                        color: colour.kAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        txtPort.text.isNotEmpty
                            ? Icons.close_rounded
                            : Icons.search_rounded,
                        color: colour.kPrimary,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Action icon buttons
              _ActionIconButton(
                icon: Icons.add_rounded,
                tooltip: 'Add Port',
                onTap: () => bloc.add(AddPortToSearchEvent(
                  portName:      txtPort.text,
                  currentSearch: txtRemarks.text,
                )),
              ),
              const SizedBox(width: 6),
              _ActionIconButton(
                icon: Icons.refresh_rounded,
                tooltip: 'Reload',
                onTap: () =>
                    bloc.add(LoadVesselDataEvent(type: isPlanToday ? 0 : 1)),
              ),
              const SizedBox(width: 6),
              _ActionIconButton(
                icon: Icons.delete_outline_rounded,
                tooltip: 'Clear',
                onTap: () => bloc.add(const ClearSearchEvent()),
                isDestructive: true,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Remarks / Search TextField ──────────────────────────────────
          _StyledTextField(
            controller: txtRemarks,
            hint: 'Search vessels...',
            maxLines: 3,
            textCapitalization: TextCapitalization.characters,
          ),
        ],
      ),
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

  const _StyledTextField({
    required this.controller,
    required this.hint,
    this.readOnly = false,
    this.suffixIcon,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller:          controller,
      readOnly:            readOnly,
      maxLines:            maxLines,
      textCapitalization:  textCapitalization,
      textInputAction:     TextInputAction.done,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: colour.kPrimaryDark,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: colour.kPrimaryLight.withOpacity(0.6),
        ),
        suffixIcon: suffixIcon != null
            ? Padding(
          padding: const EdgeInsets.only(right: 8),
          child: suffixIcon,
        )
            : null,
        suffixIconConstraints:
        const BoxConstraints(minWidth: 36, minHeight: 36),
        filled: true,
        fillColor: colour.kAccent,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colour.kAccent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: colour.kPrimary, width: 1.5),
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

  const _ActionIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.redAccent : colour.kPrimary;
    final bg    = isDestructive
        ? Colors.red.withOpacity(0.08)
        : colour.kAccent;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}

// ─── Day Toggle ───────────────────────────────────────────────────────────────
class _DayToggle extends StatelessWidget {
  final bool isPlanToday;
  final VoidCallback onToday;
  final VoidCallback onTomorrow;

  const _DayToggle({
    required this.isPlanToday,
    required this.onToday,
    required this.onTomorrow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: colour.kAccent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _ToggleTab(
              label: 'Today',
              isActive: isPlanToday,
              onTap: onToday),
          _ToggleTab(
              label: 'Tomorrow',
              isActive: !isPlanToday,
              onTap: onTomorrow),
        ],
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleTab(
      {required this.label,
        required this.isActive,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive ? colour.kPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
              BoxShadow(
                color: colour.kPrimary.withOpacity(0.3),
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
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? colour.kWhite : colour.kPrimaryLight,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── List Header ──────────────────────────────────────────────────────────────
class _ListHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [colour.kPrimary, colour.kPrimaryDark],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text('#',
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colour.kWhite.withOpacity(0.8))),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text('Vessel Name',
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colour.kWhite)),
          ),
          Expanded(
            flex: 2,
            child: Text('Port',
                textAlign: TextAlign.end,
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colour.kWhite)),
          ),
        ],
      ),
    );
  }
}

// ─── Vessel Card ──────────────────────────────────────────────────────────────
class _VesselCard extends StatelessWidget {
  final int index;
  final String vesselName;
  final String port;

  const _VesselCard({
    required this.index,
    required this.vesselName,
    required this.port,
  });

  @override
  Widget build(BuildContext context) {
    final isEven = index % 2 == 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isEven ? colour.kWhite : colour.kAccent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(14),
          splashColor: colour.kPrimary.withOpacity(0.08),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isEven ? colour.kAccent : colour.kPrimaryLight.withOpacity(0.3),
                width: 1.2,
              ),
              boxShadow: isEven
                  ? [
                BoxShadow(
                  color: colour.kPrimary.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ]
                  : [],
            ),
            child: Row(
              children: [
                // Index badge
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isEven ? colour.kAccent : colour.kPrimary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colour.kPrimary),
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
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colour.kPrimaryDark),
                  ),
                ),

                // Port chip
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colour.kPrimary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: colour.kPrimaryLight.withOpacity(0.3), width: 1),
                  ),
                  child: Text(
                    port,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colour.kPrimary),
                  ),
                ),
              ],
            ),
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
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colour.kAccent,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.directions_boat_outlined,
                size: 40, color: colour.kPrimary),
          ),
          const SizedBox(height: 16),
          Text(
            'No vessels found',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colour.kPrimaryDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try adjusting your search or date filter',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: colour.kPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}