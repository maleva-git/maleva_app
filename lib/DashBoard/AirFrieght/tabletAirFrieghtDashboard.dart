part of 'package:maleva/DashBoard/AirFrieght/AirFrieghtDashboard.dart';


tabletdesign(AirFrieghtDashboardState state, BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;
  // objfun.FontMedium = 26;
  // objfun.FontLow = 22;
  // objfun.FontLarge = 30;
  // objfun.FontCardText = 20;
  objfun.FontMedium = 22;
  objfun.FontLow = 18;
  objfun.FontLarge = 24;
  objfun.FontCardText = 16;
  return WillPopScope(
      onWillPop: state._onBackPressed,
      child: DefaultTabController(
          length: 3,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: SizedBox(
                height: height * 0.05,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Dash Board',
                        style: GoogleFonts.lato(
                            textStyle: TextStyle(
                              color: colour.topAppBarColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Alatsi',
                              fontSize: objfun.FontLarge,
                            ))),
                  ],
                ),
              ),
              iconTheme: const IconThemeData(color: colour.topAppBarColor),
              actions: <Widget>[
                // IconButton(
                //   icon: const Icon(
                //     Icons.refresh,
                //     size: 30.0,
                //     color: colour.topAppBarColor,
                //   ),
                //   onPressed: () {
                //     Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
                //   },
                // ),
                IconButton(
                  icon: const Icon(
                    Icons.bluetooth_audio,
                    size: 25.0,
                    color: colour.topAppBarColor,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Bluetoothpage()));
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.exit_to_app,
                    size: 30.0,
                    color: colour.topAppBarColor,
                  ),
                  onPressed: () {
                    objfun.logout(context);
                  },
                ),
              ],
              bottom: TabBar(
                isScrollable: true,
                tabs: const [
                  Tab(text: 'VESSEL'),
                ],
                controller: state._tabmainController,
                // currentIndex: state._tabmainController.index,
                onTap: (int index) {
                  state._tabmainController.index = index;
                  if (state._tabmainController.index == 0) {
                    state.IsPlanToday = true;
                    state.Invoicewiseview = true;
                    state.loadVesseldata(0);
                  } else if (state._tabmainController.index == 1) {
                    state.Invoicewiseview = true;
                    //  state.loadFWdata(state.dtpFromDate,state.dtpToDate);
                  }
                },
              ),
            ),
            drawer: const Menulist(),
            body: TabBarView(
              controller: state._tabmainController,
              // physics: NeverScrollableScrollPhysics(),
              children: [
                Padding(
                    padding: const EdgeInsets.only(
                        top: 15.0, left: 10.0, right: 10.0),
                    child: ListView(
                      children: [
                        const SizedBox(
                          height: 7,
                        ),
                        Center(
                          child: Text(
                            'VESSEL REPORT',
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                  color: colour.commonColorred,
                                  fontWeight: FontWeight.bold,
                                  fontSize: objfun.FontLarge,
                                  letterSpacing: 0.3),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Container(
                          width: objfun.SizeConfig.safeBlockHorizontal * 99,
                          height: objfun.SizeConfig.safeBlockVertical * 5,
                          alignment: Alignment.topCenter,
                          //   margin: const EdgeInsets.only(right: 5.0, left: 5.0),
                          padding: const EdgeInsets.only(bottom: 5),
                          child: TextField(
                            textCapitalization: TextCapitalization.characters,
                            controller: state.txtStatus,
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
                              hintText: "Select Status",
                              hintStyle: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                      fontSize: objfun.FontLow,
                                      fontWeight: FontWeight.bold,
                                      color: colour.commonColorLight)),
                              suffixIcon: InkWell(
                                  child: Icon(
                                      (state.txtStatus.text.isNotEmpty)
                                          ? Icons.close
                                          : Icons.search_rounded,
                                      color: colour.commonColorred,
                                      size: 30.0),
                                  onTap: () {
                                    if (state.txtStatus.text == "") {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                            const JobStatus(
                                                Searchby: 1, SearchId: 0)),
                                      ).then((dynamic value) async {
                                        state.setState(() {
                                          state.txtStatus.text =
                                              objfun.SelectJobStatusList.Name;
                                          state.StatusId =
                                              objfun.SelectJobStatusList.Id;
                                          objfun.SelectJobStatusList =
                                              JobStatusModel.Empty();
                                        });
                                      });
                                    } else {
                                      state.setState(() {
                                        state.txtStatus.text = "";
                                        state.StatusId = 0;
                                        objfun.SelectJobStatusList =
                                            JobStatusModel.Empty();
                                      });
                                    }
                                  }),
                              fillColor: Colors.black,
                              enabledBorder: const OutlineInputBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                                borderSide:
                                BorderSide(color: colour.commonColor),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                                borderSide:
                                BorderSide(color: colour.commonColorred),
                              ),
                              contentPadding: const EdgeInsets.only(
                                  left: 10, right: 20, top: 10.0),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 5,
                              child: Container(
                                width:
                                objfun.SizeConfig.safeBlockHorizontal * 99,
                                height: objfun.SizeConfig.safeBlockVertical * 5,
                                alignment: Alignment.topCenter,
                                padding: const EdgeInsets.only(bottom: 5),
                                child: TextField(
                                  textCapitalization:
                                  TextCapitalization.characters,
                                  controller: state.txtPort,
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
                                    hintText: "Port",
                                    hintStyle: GoogleFonts.lato(
                                        textStyle: TextStyle(
                                            fontSize: objfun.FontMedium,
                                            fontWeight: FontWeight.bold,
                                            color: colour.commonColorLight)),
                                    suffixIcon: InkWell(
                                        child: Icon(
                                            (state.txtPort.text.isNotEmpty)
                                                ? Icons.close
                                                : Icons.search_rounded,
                                            color: colour.commonColorred,
                                            size: 30.0),
                                        onTap: () {
                                          state.setState(() {
                                            if (state.txtPort.text == "") {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                    const Port(
                                                        Searchby: 1,
                                                        SearchId: 0)),
                                              ).then((dynamic value) async {
                                                state.setState(() {
                                                  state.txtPort.text =
                                                      objfun.SelectedPortName;
                                                  objfun.SelectedPortName = "";
                                                  // state.IsPlanToday ?
                                                  // state.loadVesseldata(0) :  state.loadVesseldata(1);
                                                });
                                              });
                                            } else {
                                              state.setState(() {
                                                state.txtPort.text = "";
                                                objfun.SelectedPortName = "";
                                                // state.IsPlanToday ?
                                                // state.loadVesseldata(0) :  state.loadVesseldata(1);
                                              });
                                            }
                                          });
                                        }),
                                    fillColor: Colors.black,
                                    enabledBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide:
                                      BorderSide(color: colour.commonColor),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide: BorderSide(
                                          color: colour.commonColorred),
                                    ),
                                    contentPadding: const EdgeInsets.only(
                                        left: 10, right: 20, top: 10.0),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.add_sharp,
                                  size: 30.0,
                                  color: colour.commonColor,
                                ),
                                onPressed: () {
                                  state.setState(() {
                                    if (state.txtRemarks.text != "") {
                                      state.txtRemarks.text +=
                                          "," + state.txtPort.text;
                                    } else {
                                      state.txtRemarks.text =
                                          state.txtPort.text;
                                    }
                                    state.txtPort.text = "";
                                    state.IsPlanToday
                                        ? state.loadVesseldata(0)
                                        : state.loadVesseldata(1);
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.find_replace,
                                  size: 30.0,
                                  color: colour.commonColor,
                                ),
                                onPressed: () {
                                  state.setState(() {
                                    state.IsPlanToday
                                        ? state.loadVesseldata(0)
                                        : state.loadVesseldata(1);
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 30.0,
                                  color: colour.commonColor,
                                ),
                                onPressed: () {
                                  state.setState(() {
                                    state.txtRemarks.text = "";
                                    state.IsPlanToday
                                        ? state.loadVesseldata(0)
                                        : state.loadVesseldata(1);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: height * 0.08,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: TextField(
                                  cursorColor: colour.commonColor,
                                  controller: state.txtRemarks,
                                  maxLines: null,
                                  // Set this
                                  expands: true,
                                  // and this
                                  keyboardType: TextInputType.text,
                                  autofocus: false,
                                  showCursor: true,
                                  decoration: InputDecoration(
                                    hintText: (''),
                                    hintStyle: GoogleFonts.lato(
                                        textStyle: TextStyle(
                                            fontSize: objfun.FontMedium,
                                            fontWeight: FontWeight.bold,
                                            color: colour.commonColorLight)),
                                    fillColor: colour.commonColor,
                                    enabledBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide:
                                      BorderSide(color: colour.commonColor),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide: BorderSide(
                                          color: colour.commonColorred),
                                    ),
                                    contentPadding: const EdgeInsets.only(
                                        left: 10, right: 20, top: 10.0),
                                  ),

                                  textInputAction: TextInputAction.done,
                                  textCapitalization:
                                  TextCapitalization.characters,
                                  style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                        color: colour.commonColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: objfun.FontLow,
                                        letterSpacing: 0.3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: height * 0.03,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 3.0, right: 3.0),
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
                                padding: const EdgeInsets.only(
                                    left: 3.0, right: 3.0),
                                child: Text(
                                  DateFormat("dd-MM-yy").format(DateTime.parse(
                                      state.dtpAFromDate.toString())),
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
                              flex: 2,
                              child: InkWell(
                                child: Container(
                                  height: 35,
                                  width: 35,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: objfun.calendar,
                                      // fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime(2050))
                                      .then((value) {
                                    state.setState(() {
                                      var datenew =
                                      DateTime.parse(value.toString());
                                      state.dtpAFromDate =
                                          DateFormat("yyyy-MM-dd")
                                              .format(datenew);
                                    });
                                    state.loadVesseldata(0);
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 3.0, right: 3.0),
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
                                padding: const EdgeInsets.only(
                                    left: 3.0, right: 3.0),
                                child: Text(
                                  DateFormat("dd-MM-yy").format(DateTime.parse(
                                      state.dtpAToDate.toString())),
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
                              flex: 2,
                              child: InkWell(
                                child: Container(
                                  height: 35,
                                  width: 35,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: objfun.calendar,
                                      // fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime(2050))
                                      .then((value) {
                                    state.setState(() {
                                      var datenew =
                                      DateTime.parse(value.toString());
                                      state.dtpAToDate =
                                          DateFormat("yyyy-MM-dd")
                                              .format(datenew);
                                    });
                                    state.loadVesseldata(0);
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 3.0, right: 3.0),
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

                        SizedBox(
                            height: height * 0.45,
                            child: ListView.builder(
                                itemCount: state.SaleCustReport.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return SizedBox(
                                      height: height * 0.07,
                                      child: InkWell(
                                        onTap: () {
                                          state._showDialogDetails(
                                              state.SaleCustReport[index]);
                                        },
                                        onLongPress: () async {
                                          // await OnlineApi.EditSalesOrder(
                                          //     context,  state.SaleCustReport[index]
                                          // ["Id"], 0);

                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Stockinentry(
                                                          JobNo: state
                                                              .SaleCustReport[
                                                          index]
                                                          ["JobNo"]
                                                              .toString(),
                                                          JobId: state
                                                              .SaleCustReport[
                                                          index]["Id"])));
                                        },
                                        child: Card(
                                            color: state._CardColor(index),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                        padding:
                                                        const EdgeInsets
                                                            .all(5),
                                                        child: Text(
                                                          (index + 1)
                                                              .toString(),
                                                          textAlign:
                                                          TextAlign.center,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                          style:
                                                          GoogleFonts.lato(
                                                            textStyle: TextStyle(
                                                                color: colour
                                                                    .commonColor,
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                                fontSize: objfun
                                                                    .FontCardText,
                                                                letterSpacing:
                                                                0.3),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                        flex: 2,
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
                                                                padding:
                                                                const EdgeInsets
                                                                    .all(5),
                                                                child: Text(
                                                                  state
                                                                      .SaleCustReport[
                                                                  index]
                                                                  [
                                                                  "Loadingvesselname"]
                                                                      .toString(),
                                                                  textAlign:
                                                                  TextAlign
                                                                      .left,
                                                                  overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                                  maxLines: 1,
                                                                  style:
                                                                  GoogleFonts
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
                                                        flex: 2,
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
                                                                padding:
                                                                const EdgeInsets
                                                                    .all(5),
                                                                child: Text(
                                                                  state
                                                                      .SaleCustReport[
                                                                  index]
                                                                  [
                                                                  "Port"]
                                                                      .toString(),
                                                                  textAlign:
                                                                  TextAlign
                                                                      .left,
                                                                  overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                                  maxLines: 1,
                                                                  style:
                                                                  GoogleFonts
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
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                        flex: 1,
                                                        child: Text("")),
                                                    Expanded(
                                                        flex: 2,
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
                                                                padding:
                                                                const EdgeInsets
                                                                    .all(5),
                                                                child: Text(
                                                                  state
                                                                      .SaleCustReport[
                                                                  index]
                                                                  [
                                                                  "AWBNo"]
                                                                      .toString(),
                                                                  textAlign:
                                                                  TextAlign
                                                                      .left,
                                                                  overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                                  maxLines: 1,
                                                                  style:
                                                                  GoogleFonts
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
                                                        flex: 2,
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
                                                                padding:
                                                                const EdgeInsets
                                                                    .all(5),
                                                                child: Text(
                                                                  state
                                                                      .SaleCustReport[
                                                                  index]
                                                                  [
                                                                  "JobStatus"]
                                                                      .toString(),
                                                                  textAlign:
                                                                  TextAlign
                                                                      .left,
                                                                  overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                                  maxLines: 1,
                                                                  style:
                                                                  GoogleFonts
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
                                                  ],
                                                ),
                                              ],
                                            )),
                                      ));
                                }))
                      ],
                    )),
              ],
            ),
          )));
}