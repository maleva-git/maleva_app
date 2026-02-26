part of 'package:maleva/Transaction/VesselPlanning/VesselPlanningDetails.dart';


mobiledesign(VesselPlanningDetailsState state, BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;
  Column loadgridheader() {
    return Column(
      children: [
        const SizedBox(
          height: 5,
        ),
        Expanded(
          flex: 1,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Text(
                  "S.No",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: colour.ButtonForeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: objfun.FontLow,
                        letterSpacing: 0.3),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  "Remarks",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: colour.ButtonForeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: objfun.FontLow,
                        letterSpacing: 0.3),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  "Job Type",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: colour.ButtonForeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: objfun.FontLow,
                        letterSpacing: 0.3),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Text(
                  "Off Vessel",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: colour.ButtonForeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: objfun.FontLow,
                        letterSpacing: 0.3),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  "Load Vessel",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: colour.ButtonForeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: objfun.FontLow,
                        letterSpacing: 0.3),
                  ),
                ),
              ),

            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Text(
                  "Origin",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: colour.ButtonForeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: objfun.FontLow,
                        letterSpacing: 0.3),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  "Destination",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: colour.ButtonForeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: objfun.FontLow,
                        letterSpacing: 0.3),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  "Package",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: colour.ButtonForeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: objfun.FontLow,
                        letterSpacing: 0.3),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 4,
                child: Text(
                  "Customer Name",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: colour.ButtonForeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: objfun.FontLow,
                        letterSpacing: 0.3),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "Job No",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: colour.ButtonForeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: objfun.FontLow,
                        letterSpacing: 0.3),
                  ),
                ),
              ),

            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Text(
                  "Cargo Loc",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: colour.ButtonForeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: objfun.FontLow,
                        letterSpacing: 0.3),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "Status",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: colour.ButtonForeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: objfun.FontLow,
                        letterSpacing: 0.3),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  "PIC",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: colour.ButtonForeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: objfun.FontLow,
                        letterSpacing: 0.3),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 5,
        ),

      ],
    );
  }
  return WillPopScope(
      onWillPop: state._onBackPressed,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
            automaticallyImplyLeading: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: SizedBox(
              height: height * 0.05,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vessel Details',
                      style:GoogleFonts
                          .lato(
                          textStyle: TextStyle(
                            color: colour.topAppBarColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Alatsi',
                            fontSize: objfun.FontMedium,
                          ))),
                  Expanded(
                    flex: 1,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(state.UserName,
                              style: GoogleFonts
                                  .lato(
                                  textStyle:TextStyle(
                                    color: colour.commonColorLight,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Alatsi',
                                    fontSize: objfun.FontLow - 2,
                                  ))),
                        ]),
                  ),
                ],
              ),
            ),
            iconTheme: const IconThemeData(color: colour.topAppBarColor),
            actions: const <Widget>[

            ]),
        drawer: const Menulist(),
        body: state.progress == false
            ? const Center(
          child: SpinKitFoldingCube(
            color: colour.spinKitColor,
            size: 35.0,
          ),
        )
            : (Padding(
          padding: const EdgeInsets.all(5.0),
          child: ListView(
            children: <Widget>[
              const SizedBox(
                height: 5,
              ),
              SizedBox(
                height: height * 0.12,
                child: Container(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  color: colour.commonColor,
                  child: loadgridheader(),
                ),
              ),
              SizedBox(
                height: height * 0.75,
                child: (objfun.VesselPlanningEditList.isNotEmpty
                    ? Container(
                    height: height / 1.4,
                    margin: const EdgeInsets.all(0),
                    padding:
                    const EdgeInsets.only(left: 1, right: 1),
                    child: ListView.builder(
                        itemCount:
                        objfun.VesselPlanningEditList.length,
                        itemBuilder:
                            (BuildContext context, int index) {
                          return SizedBox(
                              height:height * 0.20,
                              child: InkWell(

                                child: Card(
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
                                                  flex: 1,
                                                  child: Text(
                                                    "   ${index + 1}",
                                                    textAlign: TextAlign.left,
                                                    style: GoogleFonts.lato(
                                                      textStyle: TextStyle(color: colour.commonColor, fontWeight: FontWeight.bold, fontSize: objfun.FontCardText, letterSpacing: 0.3),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Container(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(1),
                                                    child: Text("   ${objfun.VesselPlanningEditList[
                                                        index]["Remarks"]}",
                                                      textAlign:
                                                      TextAlign
                                                          .left,
                                                      overflow:
                                                      TextOverflow
                                                          .ellipsis,
                                                      maxLines: 1,
                                                      style: GoogleFonts
                                                          .lato(
                                                        textStyle: TextStyle(
                                                            color: colour
                                                                .commonColor,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            fontSize:
                                                            objfun
                                                                .FontCardText,
                                                            letterSpacing:
                                                            0.3),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 4,
                                                  child: Container(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(5),
                                                    child: Text(
                                                      objfun.VesselPlanningEditList[
                                                      index]["JobName"].toString(),
                                                      textAlign:
                                                      TextAlign
                                                          .left,
                                                      overflow:
                                                      TextOverflow
                                                          .ellipsis,
                                                      maxLines: 1,
                                                      style: GoogleFonts
                                                          .lato(
                                                        textStyle: TextStyle(
                                                            color: colour
                                                                .commonColor,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            fontSize:
                                                            objfun
                                                                .FontCardText,
                                                            letterSpacing:
                                                            0.3),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )),
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
                                                  flex: 3,
                                                  child: Container(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(1),
                                                    child: Text("  ${objfun.VesselPlanningEditList[
                                                        index]["Offvesselname"]}",
                                                      textAlign:
                                                      TextAlign
                                                          .left,
                                                      overflow:
                                                      TextOverflow
                                                          .ellipsis,
                                                      maxLines: 1,
                                                      style: GoogleFonts
                                                          .lato(
                                                        textStyle: TextStyle(
                                                            color: colour
                                                                .commonColor,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            fontSize:
                                                            objfun
                                                                .FontCardText,
                                                            letterSpacing:
                                                            0.3),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Container(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(1),
                                                    child: Text("  ${objfun.VesselPlanningEditList[
                                                        index]["Loadingvesselname"]}",
                                                      textAlign:
                                                      TextAlign
                                                          .left,
                                                      overflow:
                                                      TextOverflow
                                                          .ellipsis,
                                                      maxLines: 1,
                                                      style: GoogleFonts
                                                          .lato(
                                                        textStyle: TextStyle(
                                                            color: colour
                                                                .commonColor,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            fontSize:
                                                            objfun
                                                                .FontCardText,
                                                            letterSpacing:
                                                            0.3),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )),
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
                                                  flex: 3,
                                                  child: Container(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(1),
                                                    child: Text("  ${objfun.VesselPlanningEditList[
                                                        index]["Origin"]}",
                                                      textAlign:
                                                      TextAlign
                                                          .left,
                                                      overflow:
                                                      TextOverflow
                                                          .ellipsis,
                                                      maxLines: 1,
                                                      style: GoogleFonts
                                                          .lato(
                                                        textStyle: TextStyle(
                                                            color: colour
                                                                .commonColor,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            fontSize:
                                                            objfun
                                                                .FontCardText,
                                                            letterSpacing:
                                                            0.3),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Container(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(1),
                                                    child: Text("  ${objfun.VesselPlanningEditList[
                                                        index]["Destination"]}",
                                                      textAlign:
                                                      TextAlign
                                                          .left,
                                                      overflow:
                                                      TextOverflow
                                                          .ellipsis,
                                                      maxLines: 1,
                                                      style: GoogleFonts
                                                          .lato(
                                                        textStyle: TextStyle(
                                                            color: colour
                                                                .commonColor,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            fontSize:
                                                            objfun
                                                                .FontCardText,
                                                            letterSpacing:
                                                            0.3),
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                Expanded(
                                                  flex: 4,
                                                  child: Container(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(1),
                                                    child: Text("  ${objfun.VesselPlanningEditList[
                                                        index]["pkg"]}",
                                                      textAlign:
                                                      TextAlign
                                                          .left,
                                                      overflow:
                                                      TextOverflow
                                                          .ellipsis,
                                                      maxLines: 1,
                                                      style: GoogleFonts
                                                          .lato(
                                                        textStyle: TextStyle(
                                                            color: colour
                                                                .commonColor,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            fontSize:
                                                            objfun
                                                                .FontCardText,
                                                            letterSpacing:
                                                            0.3),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )),
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
                                                  flex: 4,
                                                  child: Container(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(1),
                                                    child: Text("  ${objfun.VesselPlanningEditList[
                                                        index]["CustomerName"]}",
                                                      textAlign:
                                                      TextAlign
                                                          .left,
                                                      overflow:
                                                      TextOverflow
                                                          .ellipsis,
                                                      maxLines: 1,
                                                      style: GoogleFonts
                                                          .lato(
                                                        textStyle: TextStyle(
                                                            color: colour
                                                                .commonColor,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            fontSize:
                                                            objfun
                                                                .FontCardText,
                                                            letterSpacing:
                                                            0.3),
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                Expanded(
                                                  flex: 2,
                                                  child: Container(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(1),
                                                    child: Text(
                                                      objfun.VesselPlanningEditList[
                                                      index]["JobNo"].toString(),
                                                      textAlign:
                                                      TextAlign
                                                          .left,
                                                      overflow:
                                                      TextOverflow
                                                          .ellipsis,
                                                      maxLines: 1,
                                                      style: GoogleFonts
                                                          .lato(
                                                        textStyle: TextStyle(
                                                            color: colour
                                                                .commonColor,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            fontSize:
                                                            objfun
                                                                .FontCardText,
                                                            letterSpacing:
                                                            0.3),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )),
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
                                                  flex: 3,
                                                  child: Container(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(1),
                                                    child: Text("  ${objfun.VesselPlanningEditList[
                                                        index]["Cargo"]}",
                                                      textAlign:
                                                      TextAlign
                                                          .left,
                                                      overflow:
                                                      TextOverflow
                                                          .ellipsis,
                                                      maxLines: 1,
                                                      style: GoogleFonts
                                                          .lato(
                                                        textStyle: TextStyle(
                                                            color: colour
                                                                .commonColor,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            fontSize:
                                                            objfun
                                                                .FontCardText,
                                                            letterSpacing:
                                                            0.3),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Container(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(1),
                                                    child: Text(
                                                      objfun.VesselPlanningEditList[
                                                      index]["JobStatus"].toString(),
                                                      textAlign:
                                                      TextAlign
                                                          .left,
                                                      overflow:
                                                      TextOverflow
                                                          .ellipsis,
                                                      maxLines: 1,
                                                      style: GoogleFonts
                                                          .lato(
                                                        textStyle: TextStyle(
                                                            color: colour
                                                                .commonColor,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            fontSize:
                                                            objfun
                                                                .FontCardText,
                                                            letterSpacing:
                                                            0.3),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Container(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(1),
                                                    child: Text(
                                                      objfun.VesselPlanningEditList[
                                                      index]["EmployeeName"].toString(),
                                                      textAlign:
                                                      TextAlign
                                                          .left,
                                                      overflow:
                                                      TextOverflow
                                                          .ellipsis,
                                                      maxLines: 1,
                                                      style: GoogleFonts
                                                          .lato(
                                                        textStyle: TextStyle(
                                                            color: colour
                                                                .commonColor,
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            fontSize:
                                                            objfun
                                                                .FontCardText,
                                                            letterSpacing:
                                                            0.3),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )),
                                        const SizedBox(
                                          height: 10,
                                        ),

                                      ],
                                    )),
                              ));
                        }))
                    : Container(
                    width: width - 40.0,
                    height: height / 1.4,
                    padding: const EdgeInsets.all(20),
                    child: const Center(
                      child: Text('No Record'),
                    ))),
              ),
            ],
          ),
        )),

      ));

}