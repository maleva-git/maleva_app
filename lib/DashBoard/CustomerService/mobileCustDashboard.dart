part of 'package:maleva/DashBoard/CustomerService/CustDashboard.dart';

mobiledesign(CustDashboardState state, BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;

  Column loadgridheader() {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 2,
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
                  "Notify Date",
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
      ],
    );
  }

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
      state.Invoicewiseview = true;
      state._tabController.index = 0;
      state.loadSalesdata();
      //state.loaddata(0);
    } else if (state._tabmainController.index == 1) {
      state.IsToday = true;
      state.Invoicewiseview = true;
      state.loadVesseldata(0);
    } else if (state._tabmainController.index == 2) {
      state.IsPlanToday = true;
      state.Invoicewiseview = true;
      state.loadPlanningdata(0);
    } else if (state._tabmainController.index == 3) {
      state.Invoicewiseview = true;
      state.loadEnqdata();
    }
  });
  return WillPopScope(
      onWillPop: state._onBackPressed,
      child: DefaultTabController(
          length: 5,
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
                  Tab(
                    text: 'SALES',
                  ),
                  Tab(text: 'VSL'),
                  Tab(text: 'TRANSPORT'),
                  Tab(text: 'ENQ'),
                  Tab(text: 'Fuel View'),
                  Tab(text: 'Payment View'),
                ],
                controller: state._tabmainController,
                // currentIndex: state._tabmainController.index,
                onTap: (int index) {
                  state._tabmainController.index = index;
                  if (state._tabmainController.index == 0) {
                    state.Invoicewiseview = true;
                    state._tabController.index = 0;
                    // state.loaddata(0);
                    state.loadSalesdata();
                  } else if (state._tabmainController.index == 1) {
                    state.IsToday = true;
                    state.Invoicewiseview = true;
                    state.loadVesseldata(0);
                  } else if (state._tabmainController.index == 2) {
                    state.IsPlanToday = true;
                    state.Invoicewiseview = true;
                    state.loadPlanningdata(0);
                  } else if (state._tabmainController.index == 3) {
                    state.Invoicewiseview = true;
                    state.loadEnqdata();
                  }

                  else if (state._tabmainController.index == 4) {
                    state.Invoicewiseview = true;
                    state.loadfueldifference();
                  }
                  else if (state._tabmainController.index == 5) {

                    state.loadData();
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
                        Container(
                          padding: const EdgeInsets.only(
                            left: 10.0,
                            right: 10.0,
                          ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: colour.commonColorLight,
                              border: Border.all()),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              isExpanded: true,
                              value: state.dropdownValueEMp,
                              onChanged: (String? value) {
                                state.setState(() {
                                  state.dropdownValueEMp = value!;
                                  state.EmpId = int.parse(value);
                                });
                                state.loadSalesdata();
                              },
                              style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                    color: colour.commonColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: objfun.FontMedium,
                                    letterSpacing: 0.3),
                              ),
                              items: CustDashboardState.RulesTypeEmployee.map<
                                      DropdownMenuItem<String>>(
                                  (Map<String, dynamic> item) {
                                return DropdownMenuItem<String>(
                                  value: item['Id'].toString(),
                                  child: Text(
                                    item['AccountName']!,
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                          color: colour.commonColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: objfun.FontMedium,
                                          letterSpacing: 0.3),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: height * 0.24,
                          child: Card(
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                    flex: 2,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 15,
                                                left: 5,
                                                right: 5,
                                                bottom: 25),
                                            child: Text(
                                              "Without Invoice :",
                                              textAlign: TextAlign.left,
                                              style: GoogleFonts.lato(
                                                textStyle: TextStyle(
                                                    color: colour.commonColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        objfun.FontLow - 2,
                                                    letterSpacing: 0.3),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: Text(
                                              "Total Count :",
                                              textAlign: TextAlign.left,
                                              style: GoogleFonts.lato(
                                                textStyle: TextStyle(
                                                    color: colour.commonColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        objfun.FontLow - 2,
                                                    letterSpacing: 0.3),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 5,
                                                left: 5,
                                                right: 5,
                                                bottom: 5),
                                            child: Text(
                                              "Billed : ",
                                              textAlign: TextAlign.left,
                                              style: GoogleFonts.lato(
                                                textStyle: TextStyle(
                                                    color: colour.commonColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        objfun.FontLow - 2,
                                                    letterSpacing: 0.3),
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5,
                                                    left: 5,
                                                    right: 5,
                                                    bottom: 15),
                                                child: Text(
                                                  "UnBilled :",
                                                  textAlign: TextAlign.left,
                                                  style: GoogleFonts.lato(
                                                    textStyle: TextStyle(
                                                        color:
                                                            colour.commonColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize:
                                                            objfun.FontLow - 2,
                                                        letterSpacing: 0.3),
                                                  ),
                                                ),
                                              ),
                                              onLongPress: () {}),
                                        ])),
                                Expanded(
                                    flex: 2,
                                    child: Column(children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 15,
                                            left: 5,
                                            right: 5,
                                            bottom: 25),
                                        child: Text(
                                          state.withoutInvoiceCount.toString(),
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                color:
                                                    colour.commonColorhighlight,
                                                fontWeight: FontWeight.bold,
                                                fontSize: objfun.FontLow - 2,
                                                letterSpacing: 0.3),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5, bottom: 5),
                                        child: Text(
                                          state.TotalCount.toString(),
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                color:
                                                    colour.commonColorhighlight,
                                                fontWeight: FontWeight.bold,
                                                fontSize: objfun.FontLow - 2,
                                                letterSpacing: 0.3),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5, bottom: 5),
                                        child: Text(
                                          state.TotalBilledCount.toString(),
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                color:
                                                    colour.commonColorhighlight,
                                                fontWeight: FontWeight.bold,
                                                fontSize: objfun.FontLow - 2,
                                                letterSpacing: 0.3),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5,
                                            left: 5,
                                            right: 5,
                                            bottom: 15),
                                        child: Text(
                                          state.TotalUnBilledCount.toString(),
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                color:
                                                    colour.commonColorhighlight,
                                                fontWeight: FontWeight.bold,
                                                fontSize: objfun.FontLow - 2,
                                                letterSpacing: 0.3),
                                          ),
                                        ),
                                      ),
                                    ])),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                            height: height * 0.50,
                            child: ListView.builder(
                                itemCount: state.SalesReport.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return SizedBox(
                                      height: height * 0.05,
                                      child: InkWell(
                                        onLongPress: () {},
                                        child: Card(
                                            child: Row(
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
                                                          state.SalesReport[
                                                                  index]
                                                                  ["JobStatus"]
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
                                                          state.SalesReport[
                                                                  index]
                                                                  ["DayCount"]
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
                            height: height * 0.68,
                            child: ListView.builder(
                                itemCount: state.SaleCustReport.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return SizedBox(
                                      height: height * 0.05,
                                      child: InkWell(
                                        onTap: () {
                                          state._showDialogVessel(
                                              state.SaleCustReport[index]);
                                        },
                                        onLongPress: () async {
                                          //  await OnlineApi.EditSalesOrder(
                                          //      context,  state.SaleCustReport[index]
                                          //  ["Id"], 0);
                                          //
                                          // Navigator.of(context).push(
                                          //     MaterialPageRoute(
                                          //         builder: (context) =>
                                          //             Boardofficerupdate( SaleMaster: objfun
                                          //                       .SaleEditMasterList )));

                                        },
                                        child: Card(
                                            color: state._CardColorVessel(index),
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
                        Center(
                          child: Text(
                            'TRANSPORT REPORT',
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                  color: colour.commonColorred,
                                  fontWeight: FontWeight.bold,
                                  fontSize: objfun.FontLarge,
                                  letterSpacing: 0.3),
                            ),
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
                                state.loadPlanningdata(0);
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
                                state.loadPlanningdata(1);
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
                            height: height * 0.68,
                            child: ListView.builder(
                                itemCount: state.SaleTransReport.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return SizedBox(
                                      height: height * 0.05,
                                      child: InkWell(
                                        onTap: () {
                                          state._showDialogDetails(
                                              state.SaleTransReport[index]);
                                        },
                                        onLongPress: () async {
                                          await OnlineApi.EditSalesOrder(
                                              context,
                                              state.SaleTransReport[index]
                                                  ["Id"],
                                              0);
                                          List<SaleEditDetailModel>
                                              SaleDetailsList =
                                              objfun.SaleEditDetailList;
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      SalesOrderAdd(
                                                        SaleDetails: objfun
                                                            .SaleEditDetailList,
                                                        SaleMaster: objfun
                                                            .SaleEditMasterList,
                                                      )));
                                        },
                                        child: Card(
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
                                                          state.SaleTransReport[
                                                                  index][
                                                                  "CustomerName"]
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
                  padding:
                      const EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
                  child: ListView(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          /* ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: colour.commonColorLight,
                              side: const BorderSide(
                                  color: colour.commonColor,
                                  width: 1,
                                  style: BorderStyle.solid),
                              textStyle: const TextStyle(color: Colors.black),
                              elevation: 20.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              padding: const EdgeInsets.all(4.0),
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AddEnquiry()));
                            },
                            child: Icon(
                              Icons.filter_alt_outlined,
                              color: colour.commonColor,
                            ),
                          ),*/
                          const SizedBox(
                            width: 5,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colour.commonColorLight,
                              side: const BorderSide(
                                  color: colour.commonColor,
                                  width: 1,
                                  style: BorderStyle.solid),
                              textStyle: const TextStyle(color: Colors.black),
                              elevation: 20.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              padding: const EdgeInsets.all(4.0),
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AddEnquiry()));
                            },
                            child: const Icon(
                              Icons.add,
                              color: colour.commonColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        height: height * 0.05,
                        child: Container(
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          // margin: const EdgeInsets.only(left: 10.0, right: 30),
                          color: colour.commonColor,
                          child: loadgridheader(),
                        ),
                      ),
                      SizedBox(
                        height: height * 0.80,
                        child: (objfun.EnquiryMasterList.isNotEmpty

                            ? Container(
                                height: height / 1.4,
                                margin: const EdgeInsets.all(0),
                                padding:
                                    const EdgeInsets.only(left: 1, right: 1),
                                child: ListView.builder(
                                    itemCount: objfun.EnquiryMasterList.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return SizedBox(
                                          height: height * 0.07,
                                          child: InkWell(
                                            onDoubleTap: () {
                                              state._showDialogEnqDetails(objfun
                                                  .EnquiryMasterList[index]);
                                            },
                                            onLongPress: () {
                                              state.setState(() {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            AddEnquiry(
                                                                SaleMaster: objfun
                                                                        .EnquiryMasterList[
                                                                    index])));
                                              });
                                            },
                                            child: Card(
                                              // margin: EdgeInsets.all(10.0),
                                              color: state._CardColor(index),
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
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 2,
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(1),
                                                          child: Text(
                                                            "   ${objfun
                                                                    .EnquiryMasterList[
                                                                        index][
                                                                        "CustomerName"]}",
                                                            textAlign:
                                                                TextAlign.left,
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
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(1),
                                                          child: Text(
                                                            "   ${objfun.EnquiryMasterList[index]
                                                            ["SForwardingDate"]}",
                                                            textAlign:
                                                                TextAlign.left,
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
                                                                  fontSize: objfun
                                                                      .FontCardText,
                                                                  letterSpacing:
                                                                      0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 2,
                                                        child: InkWell(
                                                          onTap: () async {
                                                            bool result = await objfun
                                                                .ConfirmationMsgYesNo(
                                                                context,
                                                                "Do You Want to Push to SalesOrder ?");
                                                            if (result ==
                                                                true) {
                                                              objfun.storagenew.setString('EnquiryOpen', "true");
                                                               List<dynamic> Enquirylist = [];
                                                              Enquirylist.add(objfun.EnquiryMasterList[index]);
                                                              Navigator.of(context).push(
                                                                  MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          SalesOrderAdd(
                                                                            SaleDetails: null,
                                                                            SaleMaster: Enquirylist
                                                                          )));
                                                            }

                                                          },
                                                          child: const Icon(
                                                            Icons
                                                                .fast_forward_sharp,
                                                            color: colour
                                                                .commonColor,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: InkWell(
                                                          onTap: () async {
                                                            bool result = await objfun
                                                                .ConfirmationMsgYesNo(
                                                                    context,
                                                                    "Do You Want to Cancel the Enquiry ?");
                                                            if (result ==
                                                                true) {
                                                              state.CancelEnquiry(objfun.EnquiryMasterList[index]["Id"]);
                                                            }
                                                          },
                                                          child: const Icon(
                                                            Icons.cancel,
                                                            color: colour
                                                                .commonColor,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
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
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text(
                        "Fuel  Different",
                        style: GoogleFonts.lato(
                          fontSize: objfun.FontLarge,
                          fontWeight: FontWeight.bold,
                          color: colour.commonColor,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
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
                                      size: 35,
                                      color: colour.commonColor,
                                    ),
                                    onPressed: () async {
                                      showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(1900),
                                          lastDate: DateTime(2050))
                                          .then((value) {
                                        value ??= DateTime.now();
                                        var datenew =
                                        DateTime.parse(value.toString());
                                        state.setState(() {
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
                                      size: 35,
                                      color: colour.commonColor,
                                    ),
                                    onPressed: () async {
                                      showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(1900),
                                          lastDate: DateTime(2050))
                                          .then((value) {
                                        value ??= DateTime.now();
                                        var datenew =
                                        DateTime.parse(value.toString());
                                        state.setState(() {
                                          state.dtpToDate = DateFormat("yyyy-MM-dd")
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
                            flex: 3,
                            child:    ElevatedButton(
                              onPressed: () {
                                state.loadfueldifference();
                              },
                              child: Text(
                                'View',
                                style:GoogleFonts.lato(
                                    textStyle: TextStyle(fontSize: objfun.FontLow)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.fulerecord.length,
                          itemBuilder: (context, index) {
                            final record = state.fulerecord[index];

                            // Safe value handling
                            final double aAmount = record.aAmount ?? 0.0;
                            final double gAmount = record.gAmount ?? 0.0;
                            final double aliter = record.aliter ?? 0.0;
                            final double gliter = record.gliter ?? 0.0;
                            final double difference = gAmount - aAmount;
                            final String driverName = record.driverName ?? "Unknown Driver";
                            final String truckName = record.truckName ?? "No Truck";

                            // Determine difference color and icon
                            Color diffColor;
                            IconData diffIcon;
                            if (difference > 0) {
                              diffColor = Colors.green;
                              diffIcon = Icons.trending_up;
                            } else if (difference < 0) {
                              diffColor = Colors.red;
                              diffIcon = Icons.trending_down;
                            } else {
                              diffColor = Colors.grey;
                              diffIcon = Icons.remove;
                            }

                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.shade100.withOpacity(0.6),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.orange.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header Row - Driver + Truck
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 26,
                                          backgroundColor: Colors.orange.shade50,
                                          child: const Icon(Icons.local_shipping,
                                              color: Colors.deepOrange, size: 24),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                driverName,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              Text(
                                                truckName,
                                                style: GoogleFonts.lato(
                                                  fontSize: 13,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    // Divider line
                                    Divider(color: Colors.orange.shade100, thickness: 1),

                                    // Fuel details section
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        _infoTile("A Amount", "₹${aAmount.toStringAsFixed(2)}",
                                            Colors.orange.shade700),
                                        _infoTile("G Amount", "₹${gAmount.toStringAsFixed(2)}",
                                            Colors.blue.shade700),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        _infoTile("A Liter", "${aliter.toStringAsFixed(2)} L",
                                            Colors.orange.shade700),
                                        _infoTile("G Liter", "${gliter.toStringAsFixed(2)} L",
                                            Colors.blue.shade700),
                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    // Difference indicator
                                    Container(
                                      padding:
                                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: diffColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(diffIcon, color: diffColor, size: 18),
                                          const SizedBox(width: 6),
                                          Text(
                                            "Difference: ${difference >= 0 ? '+' : ''}${difference.toStringAsFixed(2)}",
                                            style: GoogleFonts.poppins(
                                              color: diffColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),



                    ],
                  ),
                ),
                Padding(
                    padding:  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child:Column(
                      children: [

                        // 🔹 Filter radio strip
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: state.filters.map((f) {
                                final selected = state.selectedFilter == f;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: ChoiceChip(
                                    label: Text(f, style: const TextStyle(fontSize: 13)),
                                    selected: selected,
                                    selectedColor: Colors.indigo,
                                    labelStyle: TextStyle(
                                      color: selected ? Colors.white : Colors.black87,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),

                                    // ✅ FIXED HERE
                                    onSelected: (_) {
                                      state.setState(() {
                                        state.selectedFilter = f;

                                        // Expense SID
                                        if (state.selectedFilter == "All") {
                                          state.sid = 0;
                                          state.loadData();
                                        } else if (state.selectedFilter == "Hire Purchase") {
                                          state.sid = 1;
                                          state.loadData();
                                        } else if (state.selectedFilter == "Vendor") {
                                          state.sid = 2;
                                          state.loadData();
                                        } else if (state.selectedFilter == "Utility") {
                                          state.sid = 3;
                                          state.loadData();
                                        } else if (state.selectedFilter == "Tenancy") {
                                          state.sid = 4;
                                          state.loadData();
                                        } else if (state.selectedFilter == "Monthly Purpose") {
                                          state.sid = 5;
                                          state.loadData();
                                        }


                                      });
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: state.Paidfilters.map((f) {
                                final Paidselected = state.selectedPaidFilter == f;

                                return
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: ChoiceChip(
                                      label: Text(f, style: const TextStyle(fontSize: 13)),
                                      selected: Paidselected,
                                      selectedColor: Colors.indigo,
                                      labelStyle: TextStyle(
                                        color: Paidselected ? Colors.white : Colors.black87,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),

                                      // ✅ FIXED HERE
                                      onSelected: (_) {
                                        state.setState(() {
                                          state.selectedPaidFilter = f;

                                          // Payment SID
                                          if (state.selectedPaidFilter == "All Payments") {
                                            state.PSid = 0;
                                            state.loadData();
                                          } else if (state.selectedPaidFilter == "Paid") {
                                            state.PSid = 1;
                                            state.loadData();
                                          } else if (state.selectedPaidFilter == "Not Paid") {
                                            state.PSid = 2;
                                            state.loadData();
                                          }
                                        });
                                      },
                                    ),
                                  );
                              }).toList(),
                            ),
                          ),
                        ),
// Date filter section
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
                                onPressed: () => state.loadData(isDateSearch: true),
                                child: Text("Search"),
                              ),
                            ],
                          ),
                        ),

                        // 🔹 Search box — Glass style
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 12),
                        //   child: Container(
                        //     decoration: BoxDecoration(
                        //       borderRadius: BorderRadius.circular(12),
                        //       color: Colors.white,
                        //       boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
                        //     ),
                        //     child: TextField(
                        //       decoration: const InputDecoration(
                        //         prefixIcon: Icon(Icons.search),
                        //         hintText: "Search Expense / Bank / Invoice",
                        //         border: InputBorder.none,
                        //       ),
                        //       onChanged: (v) => setState(() => searchText = v),
                        //     ),
                        //   ),
                        // ),

                        const SizedBox(height: 8),

                        // 🔹 Total amount
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Row(
                            children: [
                              const Text("Total:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(width: 6),
                              Text("RM ${state._totalFiltered.toStringAsFixed(2)}",
                                  style: const TextStyle(fontSize: 17, color: Colors.indigo)),
                              const Spacer(),
                              state.loading
                                  ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                                  : const SizedBox.shrink(),
                            ],
                          ),
                        ),

                        const Divider(height: 1),

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
                                    onTap: () => state._openDetailPopup(item),
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
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.ExpenseName ?? "",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold, fontSize: 17),
                                          ),
                                          const SizedBox(height: 6),
                                          Text("Bank: ${item.BankName ?? ""}", style: const TextStyle(color: Colors.black54)),
                                          Text("${item.SubExpenseName ?? ""}", style: const TextStyle(color: Colors.black87)),
                                          Text("Due: ${item.ExpenceDueDate}", style: const TextStyle(color: Colors.black54)),
                                          Text(
                                            "Paiddate: ${item.Paiddate != null ? item.Paiddate!.split('T').first : '-'}",
                                            style: const TextStyle(color: Colors.black54),
                                          ),

                                          Text(
                                            "Paiddamount: RM ${double.tryParse(item.Paiddamount)?.toStringAsFixed(2) ?? '0.00'}",
                                            style: const TextStyle(color: Colors.black54),
                                          ),

                                          const SizedBox(height: 6),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: Colors.indigo.shade50,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text("RM ${((item.Amount ?? 0)).toStringAsFixed(2)}",
                                                    style: const TextStyle(
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.indigo)),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ),


                      ],
                    )

                )
              ],
            ),
          )));
}

Widget _infoTile(String title, String value, Color color) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: GoogleFonts.lato(
          fontSize: 13,
          color: Colors.grey[600],
        ),
      ),
      const SizedBox(height: 2),
      Text(
        value,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}