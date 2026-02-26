part of 'package:maleva/DashBoard/Maintenance/MaintenanceDashboard.dart';


mobiledesign(MaintenanceDashboardState state, BuildContext context) {
  int breakdownCount = 0;
  double breakdownAmount = 0.0;

  int repairCount = 0;
  double repairAmount = 0.0;

  int serviceCount = 0;
  double serviceAmount = 0.0;

  int sparePartsCount = 0;
  double sparePartsAmount = 0.0;

  List<MaintenanceModel> Maintenancedata2 = [];



  double width = MediaQuery
      .of(context)
      .size
      .width;
  double height = MediaQuery
      .of(context)
      .size
      .height;
  if (width <= 370) {
    objfun.FontLarge = 22;
    objfun.FontMedium = 18;
    objfun.FontLow = 16;
    objfun.FontCardText = 12;
  }
  else {
    objfun.FontLarge = 24;
    objfun.FontMedium = 20;
    objfun.FontLow = 18;
    objfun.FontCardText = 14;
  }
  state._tabmainController.addListener(() {
    if (state._tabmainController.index == 0) {
      state.Invoicewiseview = true;
      state._tabController.index = 0;
      state.loaddata(0);
    }
    else if (state._tabmainController.index == 1) {
      state.Invoicewiseview = false;
      state.loaddata(1);
    }
    else if (state._tabmainController.index == 2) {
      state.Invoicewiseview = true;
      state.loadFWdata(state.dtpFromDate, state.dtpToDate);
    }
    else if (state._tabmainController.index == 3) {
      state.Invoicewiseview = true;
      state.loadExpdata(state.dtpEFromDate, state.dtpEToDate);
    }
    else if (state._tabmainController.index == 4) {
      state.IsToday = true;
      state.Invoicewiseview = true;
      state.loadVesseldata(0);

    }
    else if (state._tabmainController.index == 5) {
      state.IsPlanToday = true;
      state.Invoicewiseview = true;
      state.loadPlanningdata(0);
    }
    else if (state._tabmainController.index == 6) {
      state.IsPlanToday = true;
      state.Invoicewiseview = true;
       state.loadTruckList();
    }
  });
  return WillPopScope(
      onWillPop: state._onBackPressed,
      child: DefaultTabController(
          length: 9,
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
                    Text('Maintenance ',
                        style: GoogleFonts.lato(textStyle: TextStyle(
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
                    Icons.print,
                    size: 25.0,
                    color: colour.topAppBarColor,
                  ),
                  onPressed: ()async {

                    await objfun.printdata([BarcodePrintModel(
                        "MALEVA", "SHIPNAME", "SHIPNAME", "B0005000", "2025-05-04",
                        "WESTPORT", "WESTPORT","(1/3)")
                    ]);
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
                    Tab(text: 'Maintenance',),
                    Tab(text: 'Today Pickup'),
                    Tab(text: 'Vessel'),
                    Tab(text: 'Truck'),
                    Tab(text: 'Driver'),
                    Tab(text: 'Speeding'),
                    Tab(text: 'FuelFilling'),
                    Tab(text: 'EngineHours'),
                    Tab(text: 'Fuel View'),
                    Tab(text: 'Spare Parts Entry'),

                  ],
                  controller: state._tabmainController,
                  // currentIndex: state._tabmainController.index,
                  onTap: (int index) {
                    state._tabmainController.index = index;

                    if (index == 0) {
                      state.Invoicewiseview = true;
                      state._tabController.index = 0;
                      state.loadMaintenance();
                      String fromDate = DateFormat("yyyy-MM-dd").format(DateTime.now().subtract(Duration(days: 365)));
                      String toDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
                      state.loadMaintenance2(fromDate, toDate);


                    }

                    else if (index == 1) {
                      state.Invoicewiseview = false;
                      state.loaddata(1); // Today Pickup
                    }

                    else if (index == 2) {
                      state.IsToday = true;
                      state.Invoicewiseview = true;
                      state.loadVesseldata(0); // Vessel
                    }

                    else if (index == 3) {
                      state.Invoicewiseview = true;
                      String fromDate = DateFormat("yyyy-MM-dd").format(DateTime.now().subtract(Duration(days: 7)));
                      String toDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
                      state.loadTruck(); // ✅ Truck
                    }

                    else if (index == 4) {
                      state.Invoicewiseview = true;
                      String fromDate = DateFormat("yyyy-MM-dd").format(DateTime.now().subtract(Duration(days: 7)));
                      String toDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
                      state.loadDrive(); // ✅ Driver
                    }
                    else if (index == 5) {
                      state.Invoicewiseview = true;
                      String fromDate = DateFormat("yyyy-MM-dd").format(DateTime.now().subtract(Duration(days: 7)));
                      String toDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
                      state.loadSpeeding(); // ✅ Speeding
                    }
                    else if (index == 6) {
                      state.Invoicewiseview = true;
                      String fromDate = DateFormat("yyyy-MM-dd").format(DateTime.now().subtract(Duration(days: 7)));
                      String toDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
                      state.loadFuelFilling(); // ✅ Driver
                    }
                    else if (index == 7) {
                      state.Invoicewiseview = true;
                      String fromDate = DateFormat("yyyy-MM-dd").format(DateTime.now().subtract(Duration(days: 7)));
                      String toDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
                      state.loadEingeHours();
                    }

                    else if (index == 8) {
                      state.Invoicewiseview = true;
                      String fromDate = DateFormat("yyyy-MM-dd").format(DateTime.now().subtract(Duration(days: 7)));
                      String toDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
                      state.loadfueldifference();
                    }
                    else if (index == 9) {
                      state.Invoicewiseview = true;
                      // String fromDate = DateFormat("yyyy-MM-dd").format(DateTime.now().subtract(Duration(days: 7)));
                      // String toDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
                       state.loadTruckList();
                    }
                  }

              ),),
            drawer: const Menulist(),
            body: TabBarView(
              controller: state._tabmainController,
              // physics: NeverScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 7),
                      Center(
                        child: Text(
                          '${state.currentMonthName} Sales',
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


                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _maintenanceRow("BREAKDOWN", state.breakdownCount, state.breakdownAmount),
                          const SizedBox(height: 8),
                          _maintenanceRow("REPAIR", state.repairCount, state.repairAmount),
                          const SizedBox(height: 8),
                          _maintenanceRow("SERVICE", state.serviceCount, state.serviceAmount),
                          const SizedBox(height: 8),
                          _maintenanceRow("SPARE PARTS", state.sparePartsCount, state.sparePartsAmount),
                        ],
                      ),


                      /// Pending & Summary Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // 🔵 Pending Button (6 Months)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colour.commonColorLight,
                              side: BorderSide(
                                color: state.Is6Months ? colour.commonColor : colour.commonColorLight,
                                width: 1,
                              ),
                              elevation: state.Is6Months ? 15.0 : 0,
                              padding: const EdgeInsets.all(4.0),
                            ),
                            onPressed: () {
                              state.loadMaintenance(); // Load 6-month supplier data
                              state.setState(() {
                                state.Is6Months = true;
                              });
                            },
                            child: Text(
                              'Pending',
                              style: GoogleFonts.lato(
                                fontSize: objfun.FontMedium,
                                fontWeight: FontWeight.bold,
                                color: colour.commonColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),

                          // 🔶 Summary Button (1 Year)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colour.commonColorLight,
                              side: BorderSide(
                                color: state.Is6Months ? colour.commonColorLight : colour.commonColor,
                                width: 1,
                              ),
                              elevation: state.Is6Months ? 0.0 : 15.0,
                              padding: const EdgeInsets.all(4.0),
                            ),
                            onPressed: () {
                              String fromDate = DateFormat("yyyy-MM-dd").format(DateTime.now().subtract(Duration(days: 365)));
                              String toDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
                              state.loadMaintenance1(fromDate, toDate); // Load 1-year summary data
                              state.setState(() {
                                state.Is6Months = false;
                              });
                            },
                            child: Text(
                              'Summary',
                              style: GoogleFonts.lato(
                                fontSize: objfun.FontMedium,
                                fontWeight: FontWeight.bold,
                                color: colour.commonColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      /// Maintenance List
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.Is6Months
                              ? state.Maintenancedata.length
                              : state.Maintenancedata1.length,
                          itemBuilder: (context, index) {
                            final data = state.Is6Months
                                ? state.Maintenancedata[index]
                                : state.Maintenancedata1[index];

                            // Safely read keys from map or model
                            final supplierName = state.Is6Months ? data.SupplierName : "";
                            final dueDate = state.Is6Months ? data.SDueDate : "";
                            final description = state.Is6Months ? "" : data.Description;
                            final amount = data.Amount ?? 0.0;


                            return Card(
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                title: Text(
                                  state.Is6Months ? supplierName : description,
                                  style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                                ),
                                subtitle: state.Is6Months
                                    ? Text("Due Date: $dueDate")
                                    : null,
                                trailing: Text(
                                  "RM ${amount.toStringAsFixed(2)}",
                                  style: GoogleFonts.lato(fontWeight: FontWeight.w600),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
                /// Inside TabBarView children: [ ... add this as second tab ]
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
                            'TODAY PICKUP REPORT',
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
                        const SizedBox(height: 7,),
                        Center(child: Text('VESSEL REPORT', style:
                        GoogleFonts.lato(
                          textStyle: TextStyle(
                              color: colour.commonColorred,
                              fontWeight:
                              FontWeight.bold,
                              fontSize: objfun.FontLarge,
                              letterSpacing: 0.3),),),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:
                          [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colour.commonColorLight,
                                side: BorderSide(
                                    color: state.IsPlanToday ? colour
                                        .commonColor : colour
                                        .commonColorLight,
                                    width: 1,
                                    style: BorderStyle.solid),
                                textStyle: const TextStyle(color: Colors
                                    .black),
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
                            const SizedBox(width: 5,),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colour.commonColorLight,
                                side: BorderSide(
                                    color: state.IsPlanToday ? colour
                                        .commonColorLight : colour
                                        .commonColor,
                                    width: 1,
                                    style: BorderStyle.solid),
                                textStyle: const TextStyle(color: Colors
                                    .black),
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
                          ],),
                        SizedBox(
                            height: height * 0.68,
                            child: ListView.builder(
                                itemCount:
                                state.SaleTransReport.length,
                                itemBuilder:
                                    (BuildContext context, int index) {
                                  return SizedBox(
                                      height: height * 0.05,
                                      child: InkWell(
                                        onTap: () {
                                          state._showDialogDetails(
                                              state.SaleTransReport[index]);
                                        },
                                        onLongPress: () async {
                                          await OnlineApi.EditSalesOrder(
                                              context, state
                                              .SaleTransReport[index]["Id"],
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
                                                    const EdgeInsets
                                                        .all(5),
                                                    child: Text(
                                                      (index + 1)
                                                          .toString(),
                                                      textAlign:
                                                      TextAlign
                                                          .center,
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
                                                                  .SaleTransReport[index]["CustomerName"]
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

                                                      ],
                                                    )),

                                              ],
                                            )),
                                      ));
                                })
                        )
                      ],
                    )),

                /// Inside TabBarView, example for 4th tab
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text(
                        "Truck Details",
                        style: GoogleFonts.lato(
                          fontSize: objfun.FontLarge,
                          fontWeight: FontWeight.bold,
                          color: colour.commonColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.truckData.length,
                          itemBuilder: (context, index) {
                            final truck = state.truckData[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: const Icon(Icons.local_shipping, color: Colors.green),
                                title: Text(
                                  truck.TruckNumber.isNotEmpty ? truck.TruckNumber : "-",
                                  style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                                ),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      backgroundColor: Colors.grey[50],
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      title: Row(
                                        children: [
                                          Icon(Icons.local_shipping, color: Colors.blueAccent),
                                          const SizedBox(width: 8),
                                          const Text(
                                            "Truck Info",
                                            style: TextStyle(
                                              color: Colors.blueAccent,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Truck Number
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  const TextSpan(
                                                    text: "Truck Number: ",
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: truck.TruckNumber,
                                                    style: const TextStyle(color: Colors.deepPurple),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 12),

                                            // Function to build each expiry row
                                            state.buildExpiryRow("Apad Expiry", state.formatTruckDate(truck.ApadExp), Colors.orange),
                                            state.buildExpiryRow("RotexMy Expiry", state.formatTruckDate(truck.RotexMyExp), Colors.teal),
                                            state.buildExpiryRow("RotexSGExp Expiry", state.formatTruckDate(truck.RotexSGExp), Colors.green),
                                            state.buildExpiryRow("PuspacomExp Expiry", state.formatTruckDate(truck.PuspacomExp), Colors.purple),
                                            state.buildExpiryRow("Insurance Expiry", state.formatTruckDate(truck.InsuratnceExp), Colors.redAccent),
                                            state.buildExpiryRow("BonamExp Expiry", state.formatTruckDate(truck.BonamExp), Colors.blue),
                                            state.buildExpiryRow("PTPStickerExp Expiry", state.formatTruckDate(truck.PTPStickerExp), Colors.brown),
                                            state.buildExpiryRow("SIDExp Expiry", state.formatTruckDate(truck.SIDExp), Colors.brown),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors.blueAccent,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          child: const Text(
                                            "Close",
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },

                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                /// Inside TabBarView, example for 5th tab
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text(
                        "Driver Details",
                        style: GoogleFonts.lato(
                          fontSize: objfun.FontLarge,
                          fontWeight: FontWeight.bold,
                          color: colour.commonColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.driverData.length,
                          itemBuilder: (context, index) {
                            final driver = state.driverData[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: const Icon(Icons.person, color: Colors.deepOrange),
                                title: Text(
                                  driver.DriverName ?? "-",
                                  style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                /// inside TabarView Example for  show the  speeding report of truck the  6th tab
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text(
                        "Speeding Details",
                        style: GoogleFonts.lato(
                          fontSize: objfun.FontLarge,
                          fontWeight: FontWeight.bold,
                          color: colour.commonColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.speedingRecords.length,
                          itemBuilder: (context, index) {
                            final record = state.speedingRecords[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.white, Colors.orange.shade50],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.deepOrange.shade100,
                                  child: const Icon(Icons.local_shipping, color: Colors.deepOrange, size: 20),
                                ),
                                title: Text(
                                  record.vehicle ?? "-",
                                  style: GoogleFonts.lato(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                                subtitle: Text(
                                  "Driver: ${record.driver.isNotEmpty ? record.driver : 'Not Available'}",
                                  style: GoogleFonts.lato(fontSize: 14, color: Colors.grey[600]),
                                ),
                                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade500),
                                onTap: () {
                                  showGeneralDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    barrierLabel: '',
                                    barrierColor: Colors.black54,
                                    transitionDuration: const Duration(milliseconds: 250),
                                    pageBuilder: (_, __, ___) => Center(
                                      child: Material(
                                        color: Colors.transparent,
                                        child: Container(
                                          width: MediaQuery.of(context).size.width * 0.85,
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(18),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 18,
                                                offset: const Offset(0, 6),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Center(
                                                child: Text(
                                                  "🚚 Truck Info",
                                                  style: GoogleFonts.lato(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.deepOrange,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 24),
                                              _buildInfoRow("🚛 Truck Name", record.vehicle),
                                              const SizedBox(height: 14),
                                              _buildInfoRow("⚠️ Limit", record.count.isNotEmpty ? record.count : "Not Available"),
                                              const SizedBox(height: 14),
                                              _buildInfoRow("💨 Speed", record.filled.isNotEmpty ? record.filled : "Not Available"),
                                              const SizedBox(height: 14),
                                              _buildInfoRow("👨‍✈️ Driver", record.driver.isNotEmpty ? record.driver : "Not Available"),
                                              const SizedBox(height: 14),
                                              _buildInfoRow("⏰ Time", record.time.isNotEmpty ? record.time : "Not Available"),
                                              const SizedBox(height: 26),
                                              Align(
                                                alignment: Alignment.centerRight,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                    backgroundColor: Colors.deepOrange,
                                                  ),
                                                  onPressed: () => Navigator.of(context).pop(),
                                                  child: const Text(
                                                    "Close",
                                                    style: TextStyle(color: Colors.white, fontSize: 16),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    transitionBuilder: (_, anim, __, child) {
                                      return FadeTransition(opacity: anim, child: child);
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                /// inside TabarView  i load the  data  for  fuel filling on this tab
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text(
                        "Fuel Filling",
                        style: GoogleFonts.lato(
                          fontSize: objfun.FontLarge,
                          fontWeight: FontWeight.bold,
                          color: colour.commonColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.fuelFillingRecords.length,
                          itemBuilder: (context, index) {
                            final record = state.fuelFillingRecords[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.white, Colors.orange.shade50],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.deepOrange.shade100,
                                  child: const Icon(Icons.local_shipping, color: Colors.deepOrange, size: 20),
                                ),
                                title: Text(
                                  record.vehicle ?? "-",
                                  style: GoogleFonts.lato(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                                subtitle: Text(
                                  "Driver: ${record.driver.isNotEmpty ? record.driver : 'Not Available'}",
                                  style: GoogleFonts.lato(fontSize: 14, color: Colors.grey[600]),
                                ),
                                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade500),
                                onTap: () {
                                  showGeneralDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    barrierLabel: '',
                                    barrierColor: Colors.black54,
                                    transitionDuration: const Duration(milliseconds: 250),
                                    pageBuilder: (_, __, ___) => Center(
                                      child: Material(
                                        color: Colors.transparent,
                                        child: Container(
                                          width: MediaQuery.of(context).size.width * 0.85,
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(18),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 18,
                                                offset: const Offset(0, 6),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Center(
                                                child: Text(
                                                  "⛽ Fuel Filling Details",
                                                  style: GoogleFonts.lato(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.deepOrange,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 20),

                                              _buildDetailTile(Icons.local_shipping, Colors.blue, "Truck Name", record.vehicle, bgColor: Colors.blue.shade50),
                                              _buildDetailTile(Icons.place, Colors.green, "Location", record.location.isNotEmpty ? record.location : "Not Available", bgColor: Colors.green.shade50),
                                              _buildDetailTile(Icons.format_list_numbered, Colors.orange, "Count", record.count.isNotEmpty ? record.count : "Not Available", bgColor: Colors.orange.shade50),
                                              _buildDetailTile(Icons.local_gas_station, Colors.red, "Filled", record.filled.isNotEmpty ? record.filled : "Not Available", valueColor: Colors.red.shade800, boldValue: true, bgColor: Colors.red.shade50),
                                              _buildDetailTile(Icons.person, Colors.teal, "Driver", record.driver.isNotEmpty ? record.driver : "Not Available", bgColor: Colors.teal.shade50),
                                              _buildDetailTile(Icons.access_time, Colors.indigo, "Time", record.time.isNotEmpty ? record.time : "Not Available", bgColor: Colors.indigo.shade50),

                                              const SizedBox(height: 20),
                                              Align(
                                                alignment: Alignment.centerRight,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                    backgroundColor: Colors.deepOrange,
                                                  ),
                                                  onPressed: () => Navigator.of(context).pop(),
                                                  child: const Text(
                                                    "Close",
                                                    style: TextStyle(color: Colors.white, fontSize: 16),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    transitionBuilder: (_, anim, __, child) {
                                      return FadeTransition(opacity: anim, child: child);
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                /// inside TabarView data  for  Engein  hours  for   the  8th tab
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text(
                        "Engine Hours",
                        style: GoogleFonts.lato(
                          fontSize: objfun.FontLarge,
                          fontWeight: FontWeight.bold,
                          color: colour.commonColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.EngineHoursRecords.length,
                          itemBuilder: (context, index) {
                            final record = state.EngineHoursRecords[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.white, Colors.orange.shade50],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.deepOrange.shade100,
                                  child: const Icon(Icons.local_shipping,
                                      color: Colors.deepOrange, size: 20),
                                ),
                                title: Text(
                                  record.TruckName ?? "-",
                                  style: GoogleFonts.lato(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                                subtitle: Text(
                                  "Mileage: ${record.mileage.isNotEmpty ? record.mileage : 'Not Available'}",
                                  style: GoogleFonts.lato(fontSize: 14, color: Colors.grey[600]),
                                ),
                                trailing: Icon(Icons.arrow_forward_ios,
                                    size: 16, color: Colors.grey.shade500),
                                onTap: () {
                                  showGeneralDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    barrierLabel: '',
                                    barrierColor: Colors.black54,
                                    transitionDuration: const Duration(milliseconds: 250),
                                    pageBuilder: (_, __, ___) => Center(
                                      child: Material(
                                        color: Colors.transparent,
                                        child: Container(
                                          width: MediaQuery.of(context).size.width * 0.85,
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(18),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 18,
                                                offset: const Offset(0, 6),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Center(
                                                child: Text(
                                                  "⏱ Engine Hours Details",
                                                  style: GoogleFonts.lato(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.deepOrange,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 20),

                                              _buildDetailTile(Icons.local_shipping,
                                                  Colors.blue, "Truck Name",
                                                  record.TruckName ?? "Not Available",
                                                  bgColor: Colors.blue.shade50),
                                              _buildDetailTile(Icons.play_arrow, Colors.green,
                                                  "Begin Time",
                                                  record.beginTime.isNotEmpty
                                                      ? record.beginTime
                                                      : "Not Available",
                                                  bgColor: Colors.green.shade50),
                                              _buildDetailTile(Icons.stop, Colors.red,
                                                  "End Time",
                                                  record.endTime.isNotEmpty
                                                      ? record.endTime
                                                      : "Not Available",
                                                  bgColor: Colors.red.shade50),
                                              _buildDetailTile(Icons.place, Colors.purple,
                                                  "Begin Location",
                                                  record.beginLocation.isNotEmpty
                                                      ? record.beginLocation
                                                      : "Not Available",
                                                  bgColor: Colors.purple.shade50),
                                              _buildDetailTile(Icons.flag, Colors.orange,
                                                  "End Location",
                                                  record.endLocation.isNotEmpty
                                                      ? record.endLocation
                                                      : "Not Available",
                                                  bgColor: Colors.orange.shade50),
                                              _buildDetailTile(Icons.timer, Colors.teal,
                                                  "Total Time",
                                                  record.totalTime.isNotEmpty
                                                      ? record.totalTime
                                                      : "Not Available",
                                                  bgColor: Colors.teal.shade50),

                                              _buildDetailTile(Icons.pause_circle_filled,
                                                  Colors.brown, "Idling",
                                                  record.idling.isNotEmpty
                                                      ? record.idling
                                                      : "Not Available",
                                                  bgColor: Colors.brown.shade50),



                                              const SizedBox(height: 20),
                                              Align(
                                                alignment: Alignment.centerRight,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 24, vertical: 12),
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(10)),
                                                    backgroundColor: Colors.deepOrange,
                                                  ),
                                                  onPressed: () => Navigator.of(context).pop(),
                                                  child: const Text(
                                                    "Close",
                                                    style: TextStyle(
                                                        color: Colors.white, fontSize: 16),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    transitionBuilder: (_, anim, __, child) {
                                      return FadeTransition(opacity: anim, child: child);
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        ),
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
                            final double difference = gliter - aliter;
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
                  padding: EdgeInsets.all(16),
                  child: SingleChildScrollView(
                  child: Form(
                    key: state.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // 🔹 Title
                        Text(
                          "Enter Spare Entry Details",
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
                                      labelText: "Truck Name",
                                      border: OutlineInputBorder(),
                                    ),
                                    value: state.selectedTruck,
                                    isExpanded: true,
                                    items: objfun.GetTruckList.map((truck) {
                                      return DropdownMenuItem<String>(
                                        value: truck.Id.toString(),
                                        child: Text(truck.AccountName ?? ""),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      state.setState(() {
                                        state.selectedTruck = value;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please select a truck";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(height: 16),

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
                                ),
                                SizedBox(height: 16),

                                buildInputField(" Spare Parts", state.sparePartsController, "Please enter spare parts", height: 110.0),

                                SizedBox(height: 16),

                                buildInputField("Amount", state.amountController,
                                    "Please enter amount",
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
                                        Icon(Icons.picture_as_pdf,
                                            color: Colors.red, size: 40),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            state._pickedPDF!.path.split('/').last,
                                            style: TextStyle(
                                                fontSize: 16, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                SizedBox(height: 20),

                                // 🔹 Submit + View Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: state._isLoading
                                          ? Center(child: CircularProgressIndicator())
                                          : ElevatedButton(
                                        onPressed: () => state.submitData(context),
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
                                              builder: (context) => SparePartsViewPage(
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
                )




              ],

            ),


          )));
}
Widget _maintenanceRow(String title, int count, double amount) {
  return Row(
    children: [
      Expanded(
        flex: 5,
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      Expanded(
        flex: 2,
        child: Text(" $count"),
      ),
      Expanded(
        flex: 3,
        child: Text("${amount.toStringAsFixed(2)}"),
      ),
    ],
  );
}

// Updated Helper for Bigger Font
Widget _buildInfoRow(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Expanded(
          child: Text(
            "$title:",
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
      ],
    ),
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

Widget _buildDetailTile(IconData icon, Color iconColor, String label, String value,
    {Color? valueColor, bool boldValue = false, Color? bgColor}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 6),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: bgColor ?? Colors.grey.shade100,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.lato(
                      fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700])),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: boldValue ? FontWeight.bold : FontWeight.normal,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
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