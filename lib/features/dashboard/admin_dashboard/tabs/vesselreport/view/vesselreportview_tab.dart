import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import '../../../../../../MasterSearch/Port.dart';
import '../bloc/vesselreport_bloc.dart';
import '../bloc/vesselreport_event.dart';
import '../bloc/vesselreport_state.dart';



class VesselReportPage extends StatelessWidget {
  const VesselReportPage({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VesselBloc(
        context: context,
      )..add(const LoadVesselDataEvent(type: 0)),
      child: const _VesselReportView(),
    );
  }
}

class _VesselReportView extends StatefulWidget {
  const _VesselReportView();

  @override
  State<_VesselReportView> createState() => _VesselReportViewState();
}

class _VesselReportViewState extends State<_VesselReportView> {

  final TextEditingController _txtPort = TextEditingController();
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
      if (_txtPort.text != state.portName) _txtPort.text = state.portName;
      if (_txtRemarks.text != state.searchText) _txtRemarks.text = state.searchText;
      _isPlanToday = state.isPlanToday;
    } else if (state is VesselFieldUpdatedState) {
      if (_txtPort.text != state.portName) _txtPort.text = state.portName;
      if (_txtRemarks.text != state.searchText) _txtRemarks.text = state.searchText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;

    return BlocConsumer<VesselBloc, VesselState>(
      listener: (context, state) {
        _syncControllersFromState(state);


        if (state is VesselErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }


        if (state is VesselFieldUpdatedState) {
          context.read<VesselBloc>().add(
            LoadVesselDataEvent(type: _isPlanToday ? 0 : 1),
          );
        }
      },
      builder: (context, state) {
        final bloc = context.read<VesselBloc>();
        final isLoading = state is VesselLoadingState;
        final vesselList = state is VesselLoadedState ? state.vesselList : <Map<String, dynamic>>[];

        return Padding(
          padding: const EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
          child: ListView(
            children: [

              const SizedBox(height: 7),
              Center(
                child: Text(
                  'VESSEL REPORT',
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                      color: colour.commonColorred,
                      fontWeight: FontWeight.bold,
                      fontSize: objfun.FontLarge,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // ── Port Search Row ───────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 5,
                    child: SizedBox(
                      height: objfun.SizeConfig.safeBlockVertical * 5,
                      child: TextField(
                        textCapitalization: TextCapitalization.characters,
                        controller: _txtPort,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.name,
                        readOnly: true,
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                            color: colour.commonColor,
                            fontWeight: FontWeight.bold,
                            fontSize: objfun.FontLow,
                            letterSpacing: 0.3,
                          ),
                        ),
                        decoration: InputDecoration(
                          hintText: "Port",
                          hintStyle: GoogleFonts.lato(
                            textStyle: TextStyle(
                              fontSize: objfun.FontMedium,
                              fontWeight: FontWeight.bold,
                              color: colour.commonColorLight,
                            ),
                          ),
                          suffixIcon: InkWell(
                            child: Icon(
                              _txtPort.text.isNotEmpty
                                  ? Icons.close
                                  : Icons.search_rounded,
                              color: colour.commonColorred,
                              size: 30.0,
                            ),
                            onTap: () {
                              if (_txtPort.text.isEmpty) {
                                // Open port search screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                    const Port(Searchby: 1, SearchId: 0),
                                  ),
                                ).then((value) {
                                  if (objfun.SelectedPortName.isNotEmpty) {
                                    bloc.add(UpdatePortEvent(
                                        portName: objfun.SelectedPortName));
                                    objfun.SelectedPortName = "";
                                  }
                                });
                              } else {
                                // Clear port
                                bloc.add(const ClearPortEvent());
                              }
                            },
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: colour.commonColor),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: colour.commonColorred),
                          ),
                          contentPadding:
                          const EdgeInsets.only(left: 10, right: 20, top: 10.0),
                        ),
                      ),
                    ),
                  ),

                  // "+" button — add port to search
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      icon: const Icon(Icons.add_sharp,
                          size: 30.0, color: colour.commonColor),
                      onPressed: () {
                        bloc.add(AddPortToSearchEvent(
                          portName: _txtPort.text,
                          currentSearch: _txtRemarks.text,
                        ));
                      },
                    ),
                  ),

                  // Find/Replace (reload) button
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      icon: const Icon(Icons.find_replace,
                          size: 30.0, color: colour.commonColor),
                      onPressed: () {
                        bloc.add(LoadVesselDataEvent(type: _isPlanToday ? 0 : 1));
                      },
                    ),
                  ),

                  // Delete — clear search
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline,
                          size: 30.0, color: colour.commonColor),
                      onPressed: () {
                        bloc.add(const ClearSearchEvent());
                      },
                    ),
                  ),
                ],
              ),

              // ── Search/Remarks text field ─────────────────────────────────
              SizedBox(
                height: height * 0.08,
                child: TextField(
                  cursorColor: colour.commonColor,
                  controller: _txtRemarks,
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.text,
                  autofocus: false,
                  showCursor: true,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.characters,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                      color: colour.commonColor,
                      fontWeight: FontWeight.bold,
                      fontSize: objfun.FontLow,
                      letterSpacing: 0.3,
                    ),
                  ),
                  decoration: InputDecoration(
                    hintStyle: GoogleFonts.lato(
                      textStyle: TextStyle(
                        fontSize: objfun.FontMedium,
                        fontWeight: FontWeight.bold,
                        color: colour.commonColorLight,
                      ),
                    ),
                    fillColor: colour.commonColor,
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: colour.commonColor),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: colour.commonColorred),
                    ),
                    contentPadding:
                    const EdgeInsets.only(left: 10, right: 20, top: 10.0),
                  ),
                ),
              ),

              // ── Today / Tomorrow Buttons ──────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colour.commonColorLight,
                      side: BorderSide(
                        color: _isPlanToday
                            ? colour.commonColor
                            : colour.commonColorLight,
                        width: 1,
                      ),
                      elevation: _isPlanToday ? 15.0 : 0,
                      padding: const EdgeInsets.all(4.0),
                    ),
                    onPressed: () {
                      _isPlanToday = true;
                      bloc.add(const LoadVesselDataEvent(type: 0));
                    },
                    child: Text(
                      'Today',
                      style: GoogleFonts.lato(
                        fontSize: objfun.FontMedium,
                        fontWeight: FontWeight.bold,
                        color: colour.commonColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colour.commonColorLight,
                      side: BorderSide(
                        color: _isPlanToday
                            ? colour.commonColorLight
                            : colour.commonColor,
                        width: 1,
                      ),
                      elevation: _isPlanToday ? 0.0 : 15.0,
                      padding: const EdgeInsets.all(4.0),
                    ),
                    onPressed: () {
                      _isPlanToday = false;
                      bloc.add(const LoadVesselDataEvent(type: 1));
                    },
                    child: Text(
                      'Tomorrow',
                      style: GoogleFonts.lato(
                        fontSize: objfun.FontMedium,
                        fontWeight: FontWeight.bold,
                        color: colour.commonColor,
                      ),
                    ),
                  ),
                ],
              ),

              // ── Vessel List ───────────────────────────────────────────────
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  height: height * 0.68,
                  child: ListView.builder(
                    itemCount: vesselList.length,
                    itemBuilder: (context, index) {
                      final item = vesselList[index];
                      return SizedBox(
                        height: height * 0.05,
                        child: InkWell(
                          onTap: () {
                            // _showDialogVessel(item) — keep dialog logic here or move to bloc
                          },
                          child: Card(
                            color: _cardColor(index),
                            child: Row(
                              children: [
                                // Index number
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Text(
                                      (index + 1).toString(),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: GoogleFonts.lato(
                                        textStyle: TextStyle(
                                          color: colour.commonColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: objfun.FontCardText,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Vessel Name
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Text(
                                      item["Loadingvesselname"].toString(),
                                      textAlign: TextAlign.left,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: GoogleFonts.lato(
                                        textStyle: TextStyle(
                                          color: colour.commonColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: objfun.FontCardText,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Port
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Text(
                                      ' - ${item["Port"]}',
                                      textAlign: TextAlign.left,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: GoogleFonts.lato(
                                        textStyle: TextStyle(
                                          color: colour.commonColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: objfun.FontCardText,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // Card color logic (same as your original _CardColor)
  Color _cardColor(int index) {
    return index % 2 == 0 ? colour.commonColorLight : Colors.white;
  }
}