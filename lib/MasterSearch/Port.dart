import 'package:flutter/material.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Port extends StatefulWidget {
  final int Searchby;
  final int SearchId;

  const Port({super.key, required this.Searchby, required this.SearchId});

  @override
  _Portstate createState() {
    return _Portstate();
  }
}

class _Portstate extends State<Port> {
  bool progress = false;
  final txtSearch = TextEditingController();
  List<String> PortList = <String>[
    "WESTPORT-B18",
    "NORTHPORT- B10",
    "SOUTHPORT-B11",
    "WESTPORT LBT- B7X",
    "WESTPORT DRY BULK- B7Y",
    "PULAU KETAM JETTY",
    "KAPAR POWERSTATION-B11",
    "WESTPORT CRIUSE TERMINAL-B7S",
    "PTP-J33",
    "PASIRGUDANG PORT- J15",
    "TANJUNG LANGSAT-J76",
    "TANJUNG BIN- J33",
    "PASIR  PUTIH JETTY",
    "PENGERENG PORT-J15",
    "PENDAS JETTY",
    "PARMESWARA JETTY MELAKA- M14",
    "TANJUNG BRUAS MELAKA-M14",
    "SUNGAI UDANG MELAKA-M15",
    "SUNGAI LINGGI-M23",
    "PORT DICKSON- N11",
    "KUANTAN PORT -C13",
    "KEMAMAN PORT (KSB)- T16",
    "LIKIR BULK TERMINAL LUMUT A22",
    "MARITIME TERMINAL  LUMUT A22",
    "VALI PORT A13",
    "KERTEH",
    "MMHE",
    "BWCT -PENANG P15",
    "BUTTERWORTH",
    "PBCT-PENANG P88",
    "NBCT-PENANG P14",
    "SPCT-PENANG  P20",
    "TOK BALI",
    "KSB  WEST KEMAMAN T15",
    "KPK KEMAMAN T16",
    "KEMAMAN PORT (KSB) T16",
    "LUMUT PORT-A22",
    "SAPANGAR BAY CONTAINER PORT",
    "KOTA KINABALU PORT",
    "SAPANGAR BAY OIL TERMINAL",
    "KUDAT PORT",
    "SANDAKAN PORT",
    "LAHAD DATU PORT",
    "KUNAK PORT",
    "TAWAU PORT",
    "LABUAN PORT",
    "MIRI PORT",
    "SAMALAJU PORT",
    "RAJANG PORT",
    "TANJUNG MANIS PORT",
    "KUCHING PORT",
    "SIBU PORT",
    "SARIKEI PORT",
    "BINTULU PORT",
  ];
  List<String> filtersearchlist = <String>[];

  @override
  void initState() {
    startup();
    super.initState();
  }
  @override
  void dispose() {
    txtSearch.dispose();
    super.dispose();
  }
  Future startup() async {
    filtersearchlist = PortList;
    setState(() {
      progress = true;
    });
  }

  void search(value) {
    setState(() {
      if (value.isEmpty) {
        filtersearchlist = PortList;
      } else {
        filtersearchlist = PortList.where(
                (item) => item.toLowerCase().contains(value.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return objfun.MalevaScreen == 1
        ? Scaffold(
      appBar: AppBar(
        backgroundColor: colour.commonColor,
        centerTitle: false,
        title: Text(
          'Port',
          style: GoogleFonts.lato(
            textStyle:  TextStyle(
                color: colour.topAppBarColor,
                fontWeight: FontWeight.bold,
                fontSize: objfun.FontLarge,
                letterSpacing: 0.3),
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: colour.topAppBarColor,
            size: 35.0,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: progress == true
          ? Container(
          padding: const EdgeInsets.all(1),
          child: ListView(
            children: [
              Column(
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    height: height * 0.06,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(3),
                    child: TextField(
                      // autofocus: true,
                      controller: txtSearch,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.characters,
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(
                            color: colour.commonColor,
                            fontWeight: FontWeight.bold,
                            fontSize: objfun.FontLow,
                            letterSpacing: 0.3),
                      ),
                      decoration: InputDecoration(
                        fillColor: Colors.black,
                        enabledBorder: const OutlineInputBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(color: colour.commonColor),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(10.0)),
                          borderSide:
                          BorderSide(color: colour.commonColorred),
                        ),
                        hintText: 'Search Port',
                        hintStyle: GoogleFonts.lato(
                            textStyle: TextStyle(
                              letterSpacing: 2,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontSize: objfun.FontLow,
                              fontFamily: 'Alatsi',
                            )),
                        labelStyle: GoogleFonts.lato(
                          textStyle:  TextStyle(
                              color: colour.commonColor,
                              fontWeight: FontWeight.bold,
                              fontSize: objfun.FontLow -2 ,
                              letterSpacing: 1.3),
                        ),
                      ),
                      onChanged: (String value) {
                        setState(() {
                          search(value);
                        });
                      },
                      onSubmitted: (String value) {
                        setState(() {
                          search(value);
                        });
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Divider(
                    color: colour.commonColor,
                    thickness: 1,
                    height: 1,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  if (filtersearchlist.isNotEmpty)
                    Container(
                      // width: width - 20.0,
                        height: height * 0.82,
                        padding: const EdgeInsets.all(10),
                        child: ListView.builder(
                            itemCount: filtersearchlist.length,
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (widget.Searchby == 1) {
                                        objfun.SelectedPortName =
                                            filtersearchlist[index]
                                                .toString();

                                        Navigator.of(context,
                                            rootNavigator: true)
                                            .pop(context);
                                      }
                                    });
                                  },
                                  child: SizedBox(
                                    height: 55,
                                    child: Card(
                                        margin: const EdgeInsets.only(
                                            right: 5.0,
                                            left: 5.0,
                                            top: 1,
                                            bottom: 1),
                                        elevation: 10.0,
                                        borderOnForeground: true,
                                        semanticContainer: true,
                                        shape: RoundedRectangleBorder(
                                          side: const BorderSide(
                                              color: colour.commonColor,
                                              width: 1),
                                          borderRadius:
                                          BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          children: [
                                            Expanded(
                                                flex: 1,
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .center,
                                                  children: <Widget>[
                                                    Expanded(
                                                      flex: 10,
                                                      child: Container(
                                                        padding:
                                                        const EdgeInsets
                                                            .only(
                                                            left: 5),
                                                        child: Text(
                                                          filtersearchlist[
                                                          index]
                                                              .toString(),
                                                          overflow:
                                                          TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                          textAlign:
                                                          TextAlign
                                                              .left,
                                                          style: GoogleFonts
                                                              .lato(
                                                            textStyle:  TextStyle(
                                                                color: colour
                                                                    .commonColor,
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                                fontSize:
                                                                objfun.FontCardText,
                                                                letterSpacing:
                                                                0.3),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )),
                                          ],
                                        )),
                                  ));
                            }))
                  else
                    Container(
                        width: width - 40.0,
                        height: height * 0.66,
                        padding: const EdgeInsets.all(20),
                        child: const Center(
                          child: Text('No Record'),
                        )),
                ],
              )
            ],
          ))
          : const Center(
        child: SpinKitFoldingCube(
          color: colour.spinKitColor,
          size: 35.0,
        ),
      ),
    )
        : Scaffold(
      appBar: AppBar(
        backgroundColor: colour.commonColor,
        centerTitle: false,
        title: Center(
          child: Text(
            'Port',
            style: GoogleFonts.lato(
              textStyle:  TextStyle(
                  color: colour.topAppBarColor,
                  fontWeight: FontWeight.bold,
                  fontSize: objfun.FontLarge,
                  letterSpacing: 0.3),
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: colour.topAppBarColor,
            size: 35.0,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: progress == true
          ? Container(
          padding: const EdgeInsets.only(left: 100,right: 100,top: 50,bottom: 40),
          child: Card(
            elevation: 12,
            child: ListView(
              children: [
                Column(
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: height * 0.07,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.all(10),
                      child: TextField(
                        // autofocus: true,
                        controller: txtSearch,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.characters,
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                              color: colour.commonColor,
                              fontWeight: FontWeight.bold,
                              fontSize: objfun.FontLow,
                              letterSpacing: 0.3),
                        ),
                        decoration: InputDecoration(
                          fillColor: Colors.black,
                          enabledBorder: const OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: colour.commonColor),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                            BorderSide(color: colour.commonColorred),
                          ),
                          hintText: 'Search Port',
                          hintStyle: GoogleFonts.lato(
                              textStyle: TextStyle(
                                letterSpacing: 2,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                                fontSize: objfun.FontLow,
                                fontFamily: 'Alatsi',
                              )),
                          labelStyle: GoogleFonts.lato(
                            textStyle:  TextStyle(
                                color: colour.commonColor,
                                fontWeight: FontWeight.bold,
                                fontSize: objfun.FontLow -2 ,
                                letterSpacing: 1.3),
                          ),
                        ),
                        onChanged: (String value) {
                          setState(() {
                            search(value);
                          });
                        },
                        onSubmitted: (String value) {
                          setState(() {
                            search(value);
                          });
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Divider(
                      color: colour.commonColor,
                      thickness: 1,
                      height: 1,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    if (filtersearchlist.isNotEmpty)
                      Container(
                        // width: width - 20.0,
                          height: height * 0.82,
                          padding: const EdgeInsets.all(10),
                          child: ListView.builder(
                              itemCount: filtersearchlist.length,
                              itemBuilder: (BuildContext context, int index) {
                                return InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (widget.Searchby == 1) {
                                          objfun.SelectedPortName =
                                              filtersearchlist[index]
                                                  .toString();

                                          Navigator.of(context,
                                              rootNavigator: true)
                                              .pop(context);
                                        }
                                      });
                                    },
                                    child: SizedBox(
                                      height: 55,
                                      child: Card(
                                          margin: const EdgeInsets.only(
                                              right: 5.0,
                                              left: 5.0,
                                              top: 1,
                                              bottom: 1),
                                          elevation: 10.0,
                                          borderOnForeground: true,
                                          semanticContainer: true,
                                          shape: RoundedRectangleBorder(
                                            side: const BorderSide(
                                                color: colour.commonColor,
                                                width: 1),
                                            borderRadius:
                                            BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            children: [
                                              Expanded(
                                                  flex: 1,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .center,
                                                    children: <Widget>[
                                                      Expanded(
                                                        flex: 10,
                                                        child: Container(
                                                          padding:
                                                          const EdgeInsets
                                                              .only(
                                                              left: 5),
                                                          child: Text(
                                                            filtersearchlist[
                                                            index]
                                                                .toString(),
                                                            overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                            maxLines: 1,
                                                            textAlign:
                                                            TextAlign
                                                                .left,
                                                            style: GoogleFonts
                                                                .lato(
                                                              textStyle:  TextStyle(
                                                                  color: colour
                                                                      .commonColor,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                  fontSize:
                                                                  objfun.FontCardText,
                                                                  letterSpacing:
                                                                  0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                            ],
                                          )),
                                    ));
                              }))
                    else
                      Container(
                          width: width - 40.0,
                          height: height * 0.66,
                          padding: const EdgeInsets.all(20),
                          child: const Center(
                            child: Text('No Record'),
                          )),
                  ],
                )
              ],
            ),
          )
      )
          : const Center(
        child: SpinKitFoldingCube(
          color: colour.spinKitColor,
          size: 35.0,
        ),
      ),
    );

  }
}
