part of 'package:maleva/DashBoard/Boarding/BoardingDashboard.dart';

mobiledesign(BoardingDashboardState state, BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;


  if (width <= 370) {
    objfun.FontLarge = 22;
    objfun.FontMedium = 18;
    objfun.FontLow = 16;
    objfun.FontCardText = 12;
  } else {
    objfun.FontLarge = 24;
    objfun.FontMedium = 20;
    objfun.FontLow = 18;
    objfun.FontCardText = 14;
  }
  state._tabmainController.addListener(() {
    if (state._tabmainController.index == 0) {
      state.IsPlanToday = true;
      state.Invoicewiseview = true;
      state.loadVesseldata(0);
    }
    else if(state._tabmainController.index == 1){
      state.loadSalaryData();
    }
  });
  Column loadgridheader() {
    return Column(
      children: [
        Row(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Text(
                  "Job Date",
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
              ),]
        ),
        Row(
          children: <Widget>[

            Expanded(
              flex: 2,
              child: Text(
                "Amount",
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

      ],
    );
  }
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
                    Navigator.push(context, MaterialPageRoute(builder: (
                        context) => Bluetoothpage()));
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
                  Tab(text: 'SALARY'),
                  Tab(text: 'SPOT SaleOrder'),
                  Tab(text: 'InVentory Report'),

                ],
                controller: state._tabmainController,
                // currentIndex: state._tabmainController.index,
                onTap: (int index) {
                  state._tabmainController.index = index;
                  if (state._tabmainController.index == 0) {
                    state.IsPlanToday = true;
                    state.Invoicewiseview = true;
                    state.loadVesseldata(0);
                  }
                  else if(state._tabmainController.index == 1){
                    state.loadSalaryData();
                  }
                  else if(state._tabmainController.index == 2){
                    state.loadSalaryData();
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
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex:5,
                              child: Container(
                                width: objfun.SizeConfig
                                    .safeBlockHorizontal *
                                    99,
                                height: objfun.SizeConfig
                                    .safeBlockVertical *
                                    5,
                                alignment: Alignment.topCenter,
                                padding: const EdgeInsets.only(
                                    bottom: 5),
                                child: TextField(
                                  textCapitalization:
                                  TextCapitalization
                                      .characters,
                                  controller: state.txtPort,
                                  textInputAction:
                                  TextInputAction.done,
                                  keyboardType:
                                  TextInputType.name,
                                  readOnly: true,
                                  style: GoogleFonts
                                      .lato(
                                    textStyle: TextStyle(
                                        color:
                                        colour.commonColor,
                                        fontWeight:
                                        FontWeight.bold,
                                        fontSize:
                                        objfun.FontLow,
                                        letterSpacing: 0.3),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Port",
                                    hintStyle:GoogleFonts.lato(
                                        textStyle: TextStyle(
                                            fontSize:
                                            objfun.FontMedium,
                                            fontWeight:
                                            FontWeight.bold,
                                            color: colour
                                                .commonColorLight)),
                                    suffixIcon: InkWell(
                                        child: Icon(
                                            (state.txtPort.text
                                                .isNotEmpty)
                                                ? Icons.close
                                                : Icons
                                                .search_rounded,
                                            color: colour
                                                .commonColorred,
                                            size: 30.0),
                                        onTap: () {
                                          state.setState(() {
                                            if (state.txtPort.text ==
                                                "") {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => const Port(
                                                        Searchby:
                                                        1,
                                                        SearchId:
                                                        0)),
                                              ).then((dynamic
                                              value) async {
                                                state.setState(() {
                                                  state.txtPort.text =
                                                      objfun
                                                          .SelectedPortName;
                                                  objfun.SelectedPortName =
                                                  "";
                                                 // state.IsPlanToday ?
                                                 // state.loadVesseldata(0) :  state.loadVesseldata(1);

                                                });
                                              });
                                            } else {
                                              state.setState(() {
                                                state.txtPort.text =
                                                "";
                                                objfun.SelectedPortName =
                                                "";
                                               // state.IsPlanToday ?
                                               // state.loadVesseldata(0) :  state.loadVesseldata(1);
                                              });
                                            }
                                          });
                                        }),
                                    fillColor: Colors.black,
                                    enabledBorder:
                                    const OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.all(
                                          Radius.circular(
                                              10.0)),
                                      borderSide: BorderSide(
                                          color: colour
                                              .commonColor),
                                    ),
                                    focusedBorder:
                                    const OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.all(
                                          Radius.circular(
                                              10.0)),
                                      borderSide: BorderSide(
                                          color: colour
                                              .commonColorred),
                                    ),
                                    contentPadding:
                                    const EdgeInsets.only(
                                        left: 10,
                                        right: 20,
                                        top: 10.0),
                                  ),
                                ),
                              ),
                            ),

                            Expanded(
                              flex:1,
                            child:
                            IconButton(
                              icon: const Icon(
                                Icons.add_sharp,
                                size: 30.0,
                                color: colour.commonColor,
                              ),
                              onPressed: () {
                                state.setState(() {
                                  if(state.txtRemarks.text != ""){
                                    state.txtRemarks.text += "," + state.txtPort.text;
                                  }
                                  else{
                                    state.txtRemarks.text =  state.txtPort.text;
                                  }
                                  state.txtPort.text = "";
                                  state.IsPlanToday ?
                                  state.loadVesseldata(0) :  state.loadVesseldata(1);
                                });

                              },
                            ),),
                            Expanded(
                              flex:1,
                            child:
                            IconButton(
                              icon: const Icon(
                                Icons.find_replace,
                                size: 30.0,
                                color: colour.commonColor,
                              ),
                              onPressed: () {
                                state.setState(() {

                                  state.IsPlanToday ?
                                  state.loadVesseldata(0) :  state.loadVesseldata(1);
                                });

                              },
                            ),),
                            Expanded(
                              flex:1,
                              child:
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 30.0,
                                  color: colour.commonColor,
                                ),
                                onPressed: () {
                                  state.setState(() {

                                      state.txtRemarks.text =  "";
                                      state.IsPlanToday ?
                                      state.loadVesseldata(0) :  state.loadVesseldata(1);

                                  });

                                },
                              ),),
                          ],
                        ),
                        SizedBox(
                          height: height * 0.08,
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: TextField(
                                  cursorColor: colour.commonColor,
                                  controller: state.txtRemarks,
                                  maxLines: null, // Set this
                                  expands: true, // and this
                                  keyboardType: TextInputType.text,
                                  autofocus: false,
                                  showCursor: true,
                                  decoration: InputDecoration(
                                    hintText: (''),
                                    hintStyle: GoogleFonts.lato(
                                        textStyle:TextStyle(
                                            fontSize: objfun.FontMedium,
                                            fontWeight: FontWeight.bold,
                                            color: colour.commonColorLight)),
                                    fillColor: colour.commonColor,
                                    enabledBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide: BorderSide(
                                          color: colour.commonColor),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colour.commonColorLight,
                                side: BorderSide(
                                    color: state.IsPlanToday
                                        ? colour.commonColor
                                        : colour.commonColorLight,
                                    width: 1,
                                    style: BorderStyle.solid),
                                textStyle: const TextStyle(color: Colors.black),
                                elevation: state.IsPlanToday ? 15.0 : 0,
                                padding: const EdgeInsets.all(4.0),
                              ),
                              onPressed: () {
                                state.loadVesseldata(0);
                                state.setState(() {
                                  state.IsPlanToday = true;
                                });
                              },
                              child: Text(
                                'Today',
                                style: GoogleFonts.lato(
                                    fontSize: objfun.FontMedium,
                                    fontWeight: FontWeight.bold,
                                    color: colour.commonColor),
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colour.commonColorLight,
                                side: BorderSide(
                                    color: state.IsPlanToday
                                        ? colour.commonColorLight
                                        : colour.commonColor,
                                    width: 1,
                                    style: BorderStyle.solid),
                                textStyle: const TextStyle(color: Colors.black),
                                elevation: state.IsPlanToday ? 0.0 : 15.0,
                                padding: const EdgeInsets.all(4.0),
                              ),
                              onPressed: () {
                                state.loadVesseldata(1);
                                state.setState(() {
                                  state.IsPlanToday = false;
                                });
                              },
                              child: Text(
                                'Tomorrow',
                                style: GoogleFonts.lato(
                                    fontSize: objfun.FontMedium,
                                    fontWeight: FontWeight.bold,
                                    color: colour.commonColor),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height: height * 0.52,
                            child: ListView.builder(
                                itemCount: state.SaleCustReport.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return SizedBox(
                                      height: height * 0.05,
                                      child: InkWell(
                                        onTap: () {
                                          state._showDialogDetails(
                                              state.SaleCustReport[index]);
                                        },
                                        onLongPress: () async {

                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      OldStockUpdate()));

                                        },
                                        child: Card(
                                          color: state._CardColor(index),
                                            child: Row(
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(5),
                                                child: Text(
                                                  (index + 1).toString(),
                                                  textAlign: TextAlign.center,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: GoogleFonts.lato(
                                                    textStyle: TextStyle(
                                                        color:
                                                            colour.commonColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize:
                                                            objfun.FontCardText,
                                                        letterSpacing: 0.3),
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
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                        child: Text(
                                                          state.SaleCustReport[
                                                                  index][
                                                                  "Loadingvesselname"]
                                                              .toString(),
                                                          textAlign:
                                                              TextAlign.left,
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
                                                  ],
                                                )),
                                            Expanded(
                                                flex: 2,
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                        padding:
                                                        const EdgeInsets
                                                            .all(5),
                                                        child: Text( " - " +
                                                          state.SaleCustReport[
                                                          index][
                                                          "Port"]
                                                              .toString(),
                                                          textAlign:
                                                          TextAlign.left,
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
                                                  ],
                                                )),
                                          ],
                                        )),
                                      ));
                                }))
                      ],
                    )),
                Padding(
                    padding: const EdgeInsets.only(
                        top: 15.0, left: 10.0, right: 10.0),
                    child: ListView(
                      children: [
                        const SizedBox(
                          height: 7,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'SALARY',
                              style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                    color: colour.commonColorred,
                                    fontWeight: FontWeight.bold,
                                    fontSize: objfun.FontLarge,
                                    letterSpacing: 0.3),
                              ),

                            ),
                            Text(
                              ' - '+state.SalaryAmount.toString(),
                              style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: objfun.FontLarge,
                                    letterSpacing: 0.3),
                              ),

                            ),

                          ],
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
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
                                  DateFormat("dd-MM-yy").format(
                                      DateTime.parse(
                                          state.dtpFromDate.toString())),
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
                                      initialDate:
                                      DateTime.now(),
                                      firstDate:
                                      DateTime(1900),
                                      lastDate:
                                      DateTime(2050))
                                      .then((value) {
                                    state.setState(() {
                                      var datenew =
                                      DateTime.parse(
                                          value.toString());
                                      state.dtpFromDate =
                                          DateFormat("yyyy-MM-dd")
                                              .format(datenew);
                                    });
                                    state.loadSalaryData();

                                  });
                                },
                              ),),

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
                                      .format(DateTime.parse(
                                      state.dtpToDate.toString())),
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
                                      initialDate:
                                      DateTime.now(),
                                      firstDate:
                                      DateTime(1900),
                                      lastDate:
                                      DateTime(2050))
                                      .then((value) {
                                    state.setState(() {
                                      var datenew =
                                      DateTime.parse(
                                          value.toString());
                                      state.dtpToDate =
                                          DateFormat("yyyy-MM-dd")
                                              .format(datenew);
                                    });
                                    state.loadSalaryData();
                                  });
                                },
                              ),),

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
                          ],
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        SizedBox(
                          height: height * 0.07,
                          child: Container(
                            padding: const EdgeInsets.only(left: 5, right: 5,top: 5),
                            color: colour.commonColor,
                            child: loadgridheader(),
                          ),
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        SizedBox(
                            height: height * 0.62,
                            child: ListView.builder(
                                itemCount: state.DriverSalaryList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return SizedBox(
                                      height: height * 0.075,
                                      child: InkWell(
                                        onTap: () {
                                          state._showSalaryDetails(
                                              state.DriverSalaryList[index]);
                                        },
                                        child: Card(
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                        flex: 2,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment.center,
                                                          children: <Widget>[
                                                            Expanded(
                                                              flex: 1,
                                                              child: Container(
                                                                padding:
                                                                const EdgeInsets
                                                                    .all(5),
                                                                child: Text(
                                                                  state.DriverSalaryList[
                                                                  index][
                                                                  "BillDate"]
                                                                      .toString(),
                                                                  textAlign:
                                                                  TextAlign.left,
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
                                                          ],
                                                        )),
                                                    Expanded(
                                                        flex: 2,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment.center,
                                                          children: <Widget>[
                                                            Expanded(
                                                              flex: 1,
                                                              child: Container(
                                                                padding:
                                                                const EdgeInsets
                                                                    .all(5),
                                                                child: Text(
                                                                  state.DriverSalaryList[
                                                                  index][
                                                                  "BillNoDisplay"]
                                                                      .toString(),
                                                                  textAlign:
                                                                  TextAlign.left,
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
                                                          ],
                                                        )),
                                                  ],
                                                ),
                                                Row(
                                                  children: [

                                                    Expanded(
                                                        flex: 2,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment.center,
                                                          children: <Widget>[
                                                            Expanded(
                                                              flex: 1,
                                                              child: Container(
                                                                padding:
                                                                const EdgeInsets
                                                                    .all(5),
                                                                child: Text(
                                                                  state.DriverSalaryList[
                                                                  index][
                                                                  "NetAmt"]
                                                                      .toString(),
                                                                  textAlign:
                                                                  TextAlign.left,
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
                                                          ],
                                                        )),
                                                  ],
                                                ),
                                              ],
                                            )
                                        ),
                                      ));
                                }))
                      ],
                    )),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Form(
                      key: state.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // 🔹 Title
                          Text(
                            " Spot Sale Entry ",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 20),

                          // 🔹 Main Card
                          Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(18),
                              child: Column(
                                children: [

                                  // 🔹 Truck Dropdown
                                  SizedBox(
                                    height: 60,
                                    child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        labelText: "Job Type",
                                        border: OutlineInputBorder(),
                                      ),
                                      value: state.selectedJobType,
                                      isExpanded: true,
                                      items: objfun.JobTypeList.map((JobType) {
                                        return DropdownMenuItem<String>(
                                          value: JobType.Id.toString(),
                                          child: Text(JobType.Name ?? ""),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        state.setState(() {
                                          state.selectedJobType = value;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please select a Job Type";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 16),

                                  SizedBox(
                                    height: 60,
                                    child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        labelText: "Status",
                                        border: OutlineInputBorder(),
                                      ),
                                      value: state.selectedJobStatus,
                                      isExpanded: true,
                                      items: objfun.JobStatusList.map((JobStatus) {
                                        return DropdownMenuItem<String>(
                                          value: JobStatus.Id.toString(),
                                          child: Text(JobStatus.Name ?? ""),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        state.setState(() {
                                          state.selectedJobStatus = value;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please select a Status";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 16),

                                  SizedBox(
                                    height: 60,
                                    child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        labelText: "Port",
                                        border: OutlineInputBorder(),
                                      ),
                                      value: state.selectedPort,
                                      isExpanded: true,
                                      items: objfun.Portlist.map((truck) {
                                        return DropdownMenuItem<String>(
                                          value: truck.name.toString(),
                                          child: Text(truck.name ?? ""),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        state.setState(() {
                                          state.selectedPort = value;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please select a Port";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                             /*     SizedBox(height: 16),
                                  // 🔹 Date Picker
                                  SizedBox(
                                    height: 60,
                                    child: TextFormField(
                                      controller: state.dateController,
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        labelText: "Select Date",
                                        border: OutlineInputBorder(),
                                        suffixIcon: Icon(Icons.calendar_today),
                                      ),
                                      onTap: () async {
                                        DateTime? picked = await showDatePicker(
                                          context: context,
                                          initialDate: state.selectedDate ?? DateTime.now(),
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2100),
                                        );
                                        if (picked != null) {
                                          state.setState(() {
                                            state.selectedDate = picked;
                                            state.dateController.text =
                                                DateFormat('yyyy-MM-dd').format(picked);
                                          });
                                        }
                                      },
                                      validator: (value) =>
                                      value!.isEmpty ? "Please select a date" : null,
                                    ),
                                  ),*/
                                  SizedBox(height: 15),

                                  buildInputField("Cargo Qty", state.QuantityController, "Please enter Cargo Qty", height: 60.0),

                                  SizedBox(height: 15),

                                  buildInputField("Vechicle Name", state.VehicleNameController, "Please enter Vechicle Name", height: 60.0),

                                  SizedBox(height: 15),

                                  buildInputField("AirWaybillNumber", state.AWBNoController, "Please enter AirWaybillNumber", height: 60.0),

                                  SizedBox(height: 15),

                                  buildInputField("Cargo Weight", state.TotalWeightController,
                                      "Please enter Cargo Weight",
                                      isNumber: true),
                                  SizedBox(height: 20),

                                  // 🔹 Upload File Button
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: Size(double.infinity, 50),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onPressed: () async {
                                      final XFile? picked =
                                      await state._picker.pickImage(source: ImageSource.gallery);

                                      if (picked != null) {
                                        String path = picked.path.toLowerCase();
                                        state.setState(() {
                                          if (path.endsWith(".pdf")) {
                                            state._pickedPDF = File(picked.path);
                                            state._pickedImage = null;
                                          } else {
                                            state._pickedImage = File(picked.path);
                                            state._pickedPDF = null;
                                          }
                                        });
                                      }
                                    },
                                    icon: Icon(Icons.cloud_upload),
                                    label: Text(
                                      (state._pickedImage == null && state._pickedPDF == null)
                                          ? "Upload Document"
                                          : "Change Document",
                                    ),
                                  ),
                                  SizedBox(height: 20),

                                // 🔹 Preview Section
                                if (state._pickedImage != null)
                              ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        state._pickedImage!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                      else if (state._pickedPDF != null)
                    Container(
                    padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                state._pickedPDF!.path.split('/').last,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      )
      else if (state._NetworkImageUrl != null)
  ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Image.network(
      state._NetworkImageUrl!,
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Text("Unable to load image");
      },
    ),
  )
  else
  Text("No document uploaded"),


  SizedBox(height: 20),

                                  // 🔹 Submit + View Buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        child: state._isLoading
                                            ? Center(child: CircularProgressIndicator())
                                            : ElevatedButton(
                                          onPressed: () => state.submitSpotSaleOrder(context),
                                          style: ElevatedButton.styleFrom(
                                            minimumSize: Size(double.infinity, 55),
                                            backgroundColor: Colors.green,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                          ),
                                          child: Text(
                                            "Submit",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),

                                      SizedBox(width: 12),

                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => SpotSaleEntryView(
                                                  fromDate: state.fromDate,
                                                  toDate: state.toDate,
                                                ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            minimumSize: Size(double.infinity, 55),
                                            backgroundColor: Colors.blue,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                          ),
                                          child: Text(
                                            "View",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),

                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding
                  (
                    padding:  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child:Column(
                      children: [

                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: state.filters.map((f) {
                                final bool selected = state.selectedFilterId == f["id"];

                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: ChoiceChip(
                                    label: Text(f["name"], style: const TextStyle(fontSize: 13)),
                                    selected: selected,
                                    selectedColor: Colors.indigo,
                                    labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
                                    onSelected: (bool value) {
                                      if (value) {
                                        state.setState(() {
                                          state.selectedFilterId = f["id"];
                                        });

                                        state.loadInventory(id: f["id"]); // 👈 int pass
                                      }
                                    },
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: state.fromCtrl,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: "From Date",
                                    border: OutlineInputBorder(),
                                    suffixIcon: Icon(Icons.calendar_today),
                                  ),
                                  onTap: () async {
                                    DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2035),
                                    );
                                    if (picked != null) {
                                      state.setState(() {
                                        state.fromDate = picked;
                                        state.fromCtrl.text = DateFormat("yyyy-MM-dd").format(picked);
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: TextField(
                                  controller: state.toCtrl,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: "To Date",
                                    border: OutlineInputBorder(),
                                    suffixIcon: Icon(Icons.calendar_today),
                                  ),
                                  onTap: () async {
                                    DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2035),
                                    );
                                    if (picked != null) {
                                      state.setState(() {
                                        state.toDate = picked;
                                        state.toCtrl.text = DateFormat("yyyy-MM-dd").format(picked);
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 6),
                              ElevatedButton(
                                onPressed: () => state.loadInventory(isDateSearch: true),
                                child: Text("Search"),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                        padding: const EdgeInsets.all(6),
                        child: Row(
                          children: [

                            /// LEFT – Customer Dropdown
                            /// LEFT – Customer Dropdown
                            SizedBox(
                              width: 300,
                              child: DropdownButtonFormField<CustomerModel>(
                                value: state.selectedCustomerView,
                                hint: const Text("Select Customer"),
                                isExpanded: true,
                                items: objfun.CustomerList.map((CustomerModel c) {
                                  return DropdownMenuItem<CustomerModel>(
                                    value: c,  // 👈 full object
                                    child: Text(c.AccountName ?? ""),
                                  );
                                }).toList(),
                                onChanged: (CustomerModel? value) {
                                  state.setState(() {
                                    state.selectedCustomerView = value;
                                    state.CustomerVId = value?.Id; // 👈 Id save pannrathu
                                  });
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                ),
                              ),
                            ),



                            const SizedBox(width: 8),

                            /// RIGHT – Checkbox
                            Checkbox(
                              value: state.isChecked,
                              onChanged: (value) {
                                state.setState(() {
                                  state.isChecked = value ?? false;
                                  if(state.isChecked) {  // boolean check
                                    state.Status = 1;
                                  } else {
                                    state.Status = 0;
                                  }

                                });
                              },
                            ),
                          ],
                        ),
                      ),




                        const Divider(height: 2),

                        // 🔹 Master list
                        Expanded(
                          child: state.loading
                              ? const Center(child: CircularProgressIndicator())
                              : state.masterList.isEmpty
                              ? const Center(
                            child: Text("No Records Found", style: TextStyle(fontSize: 16)),
                          )
                              : ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              itemCount: state.masterList.length,
                              itemBuilder: (_, idx) {
                                final item = state.masterList[idx];
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeIn,
                                  child: GestureDetector(
                                    // onTap: () => state._openDetailPopup(item),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(18),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black.withOpacity(0.08),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3)
                                          ),
                                        ],
                                      ),
                                      child: Card(
                                        elevation: 3,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(14),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [

                                              /// Job Type (Title)
                                              Text(
                                                item.jobType ?? "",
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),

                                              const SizedBox(height: 8),

                                              /// Vessel info
                                              _infoRow("Off Vessel", item.offVesselName),
                                              _infoRow("Loading Vessel", item.loadingVesselName),

                                              const Divider(height: 18),

                                              /// Cargo details
                                              Wrap(
                                                spacing: 12,
                                                runSpacing: 6,
                                                children: [
                                                  _chip("Qty", item.cargoQTY),
                                                  _chip("Weight", item.cargoWeight),
                                                  _chip("Status", item.jobStatus),
                                                ],
                                              ),

                                              const SizedBox(height: 10),

                                              /// Employee & ETA
                                              _infoRow("Employee", item.employeeName),
                                              _infoRow("ETA", item.eta),

                                              const SizedBox(height: 6),

                                              /// Remarks
                                              if ((item.remarks ?? "").isNotEmpty)
                                                Text(
                                                  item.remarks!,
                                                  style: const TextStyle(color: Colors.black87),
                                                ),

                                              const Divider(height: 18),

                                              /// Dates & AWB
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  _smallText("In: ${item.oiDateIn ?? "-"}"),
                                                  _smallText("Out: ${item.odiDateOut ?? "-"}"),
                                                ],
                                              ),

                                              const SizedBox(height: 6),

                                              _smallText("AWB No: ${item.awbNo ?? "-"}"),
                                            ],
                                          ),
                                        ),
                                      ),

                                    ),
                                  ),
                                );
                              }),
                        ),


                      ],
                    )

                ),
              ],
            ),
          )));
}

Widget _infoRow(String label, String? value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black87),
        children: [
          TextSpan(
            text: "$label: ",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          TextSpan(text: value ?? "-"),
        ],
      ),
    ),
  );
}

Widget _chip(String label, String? value) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.indigo.shade50,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      "$label: ${value ?? "-"}",
      style: const TextStyle(fontSize: 13),
    ),
  );
}

Widget _smallText(String text) {
  return Text(
    text,
    style: const TextStyle(color: Colors.black54, fontSize: 12),
  );
}


Widget buildInputField(
    String label,
    TextEditingController controller,
    String errorMessage,
    {bool isNumber = false, double? height}) {

  // If height is provided, wrap the TextFormField in a SizedBox with that height.
  return SizedBox(
    height: height ?? 60.0,  // Default height is 60.0 if no height is passed
    child: TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
        // height adjustment
        contentPadding: height != null
            ? EdgeInsets.symmetric(vertical: height)   // apply custom height
            : EdgeInsets.symmetric(vertical: 14),
      ),
      validator: (value) => value!.isEmpty ? errorMessage : null,
    ),
  );
}
