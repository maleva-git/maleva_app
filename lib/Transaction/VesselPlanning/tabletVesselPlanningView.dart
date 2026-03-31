part of 'package:maleva/Transaction/VesselPlanning/VesselPlanningView.dart';


tabletdesign(OldVesselPlanningViewState state, BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;
  Future<bool> onBackPressed() async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const Homemobile()));
    return true;
  }

  Future<void> showDialogFilter(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      //isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(55.0),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(

            builder: (BuildContext context, StateSetter setState) {
              return Container(
                // height: 700,
                /*padding:
              EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 10),*/
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.only(
                    top: 16.0,
                    left: 16.0,
                    right: 16.0,
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      // mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding:
                                const EdgeInsets.only(left: 3.0, right: 3.0),
                                child: Text(
                                  "",
                                  style: GoogleFonts.lato(
                                    textStyle: const TextStyle(
                                        color: colour.commonColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.0,
                                        letterSpacing: 0.3),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding:
                                const EdgeInsets.only(left: 3.0, right: 3.0),
                                child: Text(
                                  DateFormat("dd-MM-yy").format(
                                      DateTime.parse(state.dtpFromDate.toString())),
                                  style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                        color: colour.commonColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: objfun.FontLow,
                                        letterSpacing: 0.3),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                  child: IconButton(
                                      icon: const Icon(
                                        Icons.calendar_month_outlined,
                                        size: 40,
                                        color: colour.commonColor,
                                      ),
                                      onPressed: () async {
                                        showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(1900),
                                            lastDate: DateTime(2050))
                                            .then((value) {
                                          var datenew =
                                          DateTime.parse(value.toString());
                                          setState(() {
                                            state.dtpFromDate = DateFormat("yyyy-MM-dd")
                                                .format(datenew);
                                          });
                                        });
                                      })),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding:
                                const EdgeInsets.only(left: 3.0, right: 3.0),
                                child: Text(
                                  "",
                                  style: GoogleFonts.lato(
                                    textStyle: const TextStyle(
                                        color: colour.commonColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.0,
                                        letterSpacing: 0.3),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding:
                                const EdgeInsets.only(left: 3.0, right: 3.0),
                                child: Text(
                                  DateFormat("dd-MM-yy")
                                      .format(DateTime.parse(state.dtpToDate.toString())),
                                  style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                        color: colour.commonColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: objfun.FontLow,
                                        letterSpacing: 0.3),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                  child: IconButton(
                                      icon: const Icon(
                                        Icons.calendar_month_outlined,
                                        size: 40,
                                        color: colour.commonColor,
                                      ),
                                      onPressed: () async {
                                        showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(1900),
                                            lastDate: DateTime(2050))
                                            .then((value) {
                                          var datenew =
                                          DateTime.parse(value.toString());
                                          setState(() {
                                            state.dtpToDate = DateFormat("yyyy-MM-dd")
                                                .format(datenew);
                                          });
                                        });
                                      })),
                            ),
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding:
                                const EdgeInsets.only(left: 3.0, right: 3.0),
                                child: Text(
                                  "",
                                  style: GoogleFonts.lato(
                                    textStyle: const TextStyle(
                                        color: colour.commonColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.0,
                                        letterSpacing: 0.3),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: objfun.SizeConfig.safeBlockHorizontal * 99,
                          height: objfun.SizeConfig.safeBlockVertical * 8,
                          alignment: Alignment.topCenter,
                          margin: const EdgeInsets.only(right: 35.0, left: 35.0),
                          padding: const EdgeInsets.only(bottom: 5),
                          child: TextField(
                            textCapitalization: TextCapitalization.characters,
                            controller: state.txtEmployee,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.name,
                            readOnly: true,
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                  color: colour.commonColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: objfun.FontLow,
                                  letterSpacing: 0.3),
                            ),
                            decoration: InputDecoration(
                              hintText: "Select Employee",
                              hintStyle:GoogleFonts
                                  .lato(
                                  textStyle: TextStyle(
                                      fontSize: objfun.FontLow,
                                      fontWeight: FontWeight.bold,
                                      color: colour.commonColorLight)),
                              suffixIcon: InkWell(
                                  child: Icon(
                                      (state.txtEmployee.text.isNotEmpty)
                                          ? Icons.close
                                          : Icons.search_rounded,
                                      color: state.checkBoxValueLEmp
                                          ? colour.commonColorDisabled
                                          : colour.commonColorred,
                                      size: 35.0),
                                  onTap: () async {
                                    await OnlineApi.SelectEmployee(
                                        context, 'sales', 'admin');
                                    if (state.txtEmployee.text == "" &&
                                        state.checkBoxValueLEmp != true) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const Employee(
                                                Searchby: 1, SearchId: 0)),
                                      ).then((dynamic value) async {
                                        setState(() {
                                          state.txtEmployee.text =
                                              objfun.SelectEmployeeList.AccountName;
                                          state.EmpId = objfun.SelectEmployeeList.Id;
                                          objfun.SelectEmployeeList =
                                              EmployeeModel.Empty();
                                        });
                                      });
                                    } else {
                                      setState(() {
                                        state.txtEmployee.text = "";
                                        state.EmpId = 0;
                                        objfun.SelectEmployeeList =
                                            EmployeeModel.Empty();
                                      });
                                    }
                                  }),
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
                              contentPadding:
                              const EdgeInsets.only(left: 10, right: 20, top: 10.0),
                            ),
                          ),
                        ),
                        Container(
                          width: objfun.SizeConfig.safeBlockHorizontal * 99,
                          height: objfun.SizeConfig.safeBlockVertical * 8,
                          alignment: Alignment.topCenter,
                          margin: const EdgeInsets.only(right: 35.0, left: 35.0),
                          padding: const EdgeInsets.only(bottom: 5),
                          child: TextField(
                            cursorColor: colour.commonColor,
                            controller: state.txtPlanningNo,
                            autofocus: false,
                            showCursor: true,
                            decoration: InputDecoration(
                              hintText: ('Planning No'),
                              hintStyle:GoogleFonts
                                  .lato(
                                  textStyle: TextStyle(
                                      fontSize: objfun.FontLow,
                                      fontWeight: FontWeight.bold,
                                      color: colour.commonColorLight)),
                              fillColor: colour.commonColor,
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
                              contentPadding:
                              const EdgeInsets.only(left: 10, right: 20, top: 10.0),
                            ),
                            textInputAction: TextInputAction.done,
                            textCapitalization: TextCapitalization.characters,
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                  color: colour.commonColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: objfun.FontLow,
                                  letterSpacing: 0.3),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Transform.scale(
                                scale: 1.5,
                                child: Checkbox(
                                  value: state.checkBoxValueLEmp,
                                  activeColor: colour.commonColorred,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      state.checkBoxValueLEmp = value!;
                                    });
                                  },
                                ),
                              )
                            ),
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                  width: 120,
                                  // flex: 1,
                                  child: Text(
                                    'L.Emp',
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                          color: colour.commonColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: objfun.FontMedium,
                                          letterSpacing: 0.3),
                                    ),
                                    textAlign: TextAlign.left,
                                  )),
                            ),
                            const Expanded(
                              flex: 6,
                              child: Text(""),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  state.loaddata();
                                });
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'View',
                                style:GoogleFonts
                                    .lato(
                                    textStyle: TextStyle(fontSize: objfun.FontMedium)),
                              ),
                            ),
                            const SizedBox(width: 7),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Close',
                                style: GoogleFonts
                                    .lato(
                                    textStyle:TextStyle(fontSize: objfun.FontMedium)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        )
                      ],
                    ),
                  ));
            });
      },
    );
  }

  Column loadgridheader() {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Text(
                  "Planning No",
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
                  "Planning Date",
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
                flex: 6,
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
            ],
          ),
        ),

        Expanded(
          flex: 1,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Text(
                  "",
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
                flex: 1,
                child: Text(
                  "Export",
                  textAlign: TextAlign.center,
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
      ],
    );
  }

  return WillPopScope(
      onWillPop: onBackPressed,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
            automaticallyImplyLeading: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back,size: 35,),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: SizedBox(
              height: height * 0.05,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Vessel Planning',
                      style: GoogleFonts
                          .lato(
                          textStyle:TextStyle(
                            color: colour.topAppBarColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Alatsi',
                            fontSize: objfun.FontMedium,
                          ))),
                  Text(" - ${state.UserName}",
                              style: GoogleFonts
                                  .lato(
                                  textStyle:TextStyle(
                                    color: colour.commonColorLight,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Alatsi',
                                    fontSize: objfun.FontLow - 2,
                                  ))),

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
                height: height * 0.11,
                child: Container(
                  padding: const EdgeInsets.all( 5),
                  margin: const EdgeInsets.only(left: 35.0, right: 35),

                  color: colour.commonColor,
                  child: loadgridheader(),
                ),
              ),
              SizedBox(
                height: height * 0.80,
                child: (objfun.VesselPlanningMasterList.isNotEmpty
                    ? Container(
                    height: height / 1.4,
                   // margin:const EdgeInsets.only(left: 20.0, right: 20),
                    padding:
                    const EdgeInsets.only(left: 35.0, right: 35),
                    child: ListView.builder(
                        itemCount:
                        objfun.VesselPlanningMasterList.length,
                        itemBuilder:
                            (BuildContext context, int index) {
                          return SizedBox(
                              height:
                              state._currentlyVisibleIndex == index
                                  ? height * 0.55
                                  : height * 0.14,
                              child: InkWell(
                                onLongPress: () {
                                  state.setState(() {
                                    state.EditId = objfun.VesselPlanningMasterList[index]
                                        .Id;
                                    state._showDialogPassword(
                                        1,
                                        objfun.VesselPlanningMasterList[
                                        index]
                                            .Id,
                                        objfun
                                            .VesselPlanningMasterList[
                                        index]
                                            .VESSELPLANINGNo);
                                  });
                                },
                                child: Card(
                                  // margin: EdgeInsets.all(10.0),

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
                                                  flex: 3,
                                                  child: Container(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(1),
                                                    child: Text("   ${objfun.VesselPlanningMasterList[
                                                        index]
                                                            .VESSELPLANINGNoDisplay}",
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
                                                        .all(5),
                                                    child: Text(
                                                      objfun.VesselPlanningMasterList[
                                                      index]
                                                          .VESSELPLANINGDate
                                                          .toString(),
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
                                                  flex: 6,
                                                  child: Container(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(1),
                                                    child: Text("  ${objfun.VesselPlanningMasterList[
                                                        index]
                                                            .Remarks}",
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
                                                  flex: 1,
                                                  child: Container(
                                                      child:
                                                      IconButton(
                                                          onPressed:
                                                              () {
                                                            state.setState(() {
                                                              state.VesselPlanningDetailedList = objfun.VesselPlanningDetailsList.where((item) => item["VESSELPLANINGMasterRefId"] == objfun.VesselPlanningMasterList[index].Id).toList();
                                                              state.VisiblePlanningDetails[index] = !state.VisiblePlanningDetails[index];
                                                              if (state._currentlyVisibleIndex == index) {
                                                                state._currentlyVisibleIndex = -1;
                                                              } else {
                                                                state._currentlyVisibleIndex = index;
                                                              }
                                                            });
                                                          },
                                                          icon:
                                                          const Icon(
                                                            Icons.expand_circle_down,
                                                            color:
                                                            colour.commonColor,
                                                            size: 30,
                                                          ))),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Container(
                                                    child:
                                                    IconButton(
                                                        onPressed:
                                                            () {
                                                          state._shareVesselPlanning(objfun
                                                              .VesselPlanningMasterList[
                                                          index]
                                                              .Id,objfun
                                                              .VesselPlanningMasterList[
                                                          index]
                                                              .VESSELPLANINGNoDisplay);
                                                        },
                                                        icon:
                                                        const Icon(
                                                          Icons
                                                              .picture_as_pdf_outlined,
                                                          color:
                                                          colour.commonColor,
                                                          size: 30,
                                                        )),
                                                  ),
                                                ),
                                              ],
                                            )),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Visibility(
                                            visible:
                                            state._currentlyVisibleIndex ==
                                                index,
                                            child: Expanded(
                                              flex: 8,
                                              child: ListView(
                                                children: <Widget>[
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  SizedBox(
                                                    height: height *
                                                        0.04,
                                                    child:
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .only(
                                                          left: 5,
                                                          right: 5),
                                                      margin: const EdgeInsets
                                                          .only(
                                                          left: 35,
                                                          right: 35),
                                                      // margin: const EdgeInsets.only(left: 10.0, right: 30),

                                                      color: colour
                                                          .commonColor,
                                                      child: Column(
                                                        children: [
                                                          Expanded(
                                                            flex: 1,
                                                            child:
                                                            Row(
                                                              children: <
                                                                  Widget>[
                                                                Expanded(
                                                                  flex: 2,
                                                                  child: Text(
                                                                    "Job No",
                                                                    textAlign: TextAlign.left,
                                                                    style: GoogleFonts.lato(
                                                                      textStyle: TextStyle(color: colour.ButtonForeColor, fontWeight: FontWeight.bold, fontSize: objfun.FontCardText, letterSpacing: 0.3),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 2,
                                                                  child: Text(
                                                                    "Job Date",
                                                                    textAlign: TextAlign.left,
                                                                    style: GoogleFonts.lato(
                                                                      textStyle: TextStyle(color: colour.ButtonForeColor, fontWeight: FontWeight.bold, fontSize: objfun.FontCardText, letterSpacing: 0.3),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 3,
                                                                  child: Text(
                                                                    "Remarks",
                                                                    textAlign: TextAlign.left,
                                                                    style: GoogleFonts.lato(
                                                                      textStyle: TextStyle(color: colour.ButtonForeColor, fontWeight: FontWeight.bold, fontSize: objfun.FontCardText, letterSpacing: 0.3),
                                                                    ),
                                                                  ),
                                                                ),

                                                              ],
                                                            ),
                                                          ),

                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: height *
                                                        0.32,
                                                    child: (objfun
                                                        .VesselPlanningDetailsList
                                                        .isNotEmpty
                                                        ? Container(
                                                        height: height /
                                                            1.4,
                                                        margin:
                                                        const EdgeInsets.all(
                                                            0),
                                                        padding: const EdgeInsets.only(
                                                            left:
                                                            35,
                                                            right:
                                                            35),
                                                        child: ListView.builder(
                                                            itemCount: state.VesselPlanningDetailedList.length,
                                                            itemBuilder: (BuildContext context, int index) {
                                                              return SizedBox(
                                                                height: 45,
                                                                child: Card(
                                                                  //margin: EdgeInsets.all(10.0),
                                                                    elevation: 10.0,
                                                                    borderOnForeground: true,
                                                                    semanticContainer: true,
                                                                    shape: RoundedRectangleBorder(
                                                                      side: const BorderSide(color: colour.commonColor, width: 1),
                                                                      borderRadius: BorderRadius.circular(10),
                                                                    ),
                                                                    child: Column(
                                                                      children: [
                                                                        const SizedBox(
                                                                          height: 10,
                                                                        ),
                                                                        Expanded(
                                                                          flex: 1,
                                                                          child: Row(
                                                                            children: [

                                                                              Expanded(
                                                                                flex: 2,
                                                                                child: Text("  ${state.VesselPlanningDetailedList[index]["JobNo"]}",
                                                                                  textAlign: TextAlign.left,
                                                                                  style: GoogleFonts.lato(
                                                                                    textStyle: TextStyle(color: colour.commonColor, fontWeight: FontWeight.bold, fontSize: objfun.FontCardText, letterSpacing: 0.3),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                flex: 2,
                                                                                child: Text(
                                                                                  state.VesselPlanningDetailedList[index]["JobDate"].toString(),
                                                                                  textAlign: TextAlign.left,
                                                                                  style: GoogleFonts.lato(
                                                                                    textStyle: TextStyle(color: colour.commonColor, fontWeight: FontWeight.bold, fontSize: objfun.FontCardText, letterSpacing: 0.3),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                flex: 3,
                                                                                child: Text( state.VesselPlanningDetailedList[index]["Remarks"].toString(),
                                                                                  textAlign: TextAlign.left,
                                                                                  style: GoogleFonts.lato(
                                                                                    textStyle: TextStyle(color: colour.commonColor, fontWeight: FontWeight.bold, fontSize: objfun.FontCardText, letterSpacing: 0.3),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          height: 10,
                                                                        )
                                                                      ],
                                                                    )),
                                                              );
                                                            }))
                                                        : Container(
                                                        width: width - 40.0,
                                                        height: height / 1.4,
                                                        padding: const EdgeInsets.all(20),
                                                        child: const Center(
                                                          child:
                                                          Text('No Record'),
                                                        ))),
                                                  ),
                                                ],
                                              ),
                                            ))
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialogFilter(context);
          },
          tooltip: 'Open filter',
          child: const Icon(Icons.filter_alt_outlined),
        ),
      ));

}