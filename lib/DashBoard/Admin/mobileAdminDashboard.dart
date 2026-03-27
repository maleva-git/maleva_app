part of 'package:maleva/DashBoard/Admin/AdminDashboard.dart';

mobiledesign(AdminDashboardState state, BuildContext context) {
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
      state.Invoicewiseview = true;
      state.loaddata(1);
    }
    else if (state._tabmainController.index == 2) {
      state.Invoicewiseview = false;
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
      //state.Invoicewiseview = true;
      state._loadEmployee();
    }
    else if (state._tabmainController.index == 7) {
      //state.Invoicewiseview = true;
      state._loadEmployee();
      if(state.widget.existingReview !=null){
        final r = state.widget.existingReview!;
        state._shopCtrl.text = r.shopName;
        state._mobileCtrl.text = r.mobileNo ?? '';

        state._selectedReview = int.tryParse(r.googleReview ?? '1') ?? 1;

        state._reviewMsgCtrl.text = r.googleMsg ?? '';
        state._selectedDate = r.supportDate;
        state._selectedEmpId = r.empReffid;
      }
    }
  });
  return WillPopScope(
      onWillPop: state._onBackPressed,
      child:
      DefaultTabController(
          length: 26,
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
                      Icons.directions_boat_filled,
                      size: 25.0,
                      color: colour.topAppBarColor,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Saleorderview()),
                      );
                    },
                  ),

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
                    Tab(text: 'INV',),
                    Tab(text: 'Receipt View'),
                    Tab(text: 'SO'),
                    Tab(text: 'FW'),
                    Tab(text: 'EXP'),
                    Tab(text: 'VSL'),
                    Tab(text: 'TRANSPORT'),
                    Tab(text: 'BLUE'),
                    Tab(text: 'Truck'),
                    Tab(text: 'Driver'),
                    Tab(text: 'Speeding'),
                    Tab(text: 'Fuelfilling'),
                    Tab(text: 'EngineHours'),
                    Tab(text: 'BOC'),
                    Tab(text: 'EmailInbox'),
                    Tab(text: 'GoogleReview'),
                    Tab(text: 'fuel'),
                    Tab(text: 'EmployeeView'),
                    Tab(text: 'PettyCash'),
                    Tab(text: 'Summon Entry'),
                    Tab(text: 'Spare Parts Entry'),
                    Tab(text: 'Payment View'),
                    Tab(text: 'Spot SaleOrder'),
                    Tab(text: 'InVentory Report'),
                    Tab(text: 'PDO'),
                    Tab(text: 'RTI'),
                  ],
                  controller: state._tabmainController,
                  // currentIndex: state._tabmainController.index,
                  onTap: (int index) {
                    state._tabmainController.index = index;
                    if (index == 0) {
                      state.Invoicewiseview = true;
                      state._tabController.index = 0;
                      state.loaddata(0);
                    }
                    else if (index == 1) {
                      state.Invoicewiseview = false;

                      state.loaddata(1);
                      state.loadReceipt();
                    }
                    else if (index == 2) {
                      state.Invoicewiseview = true;
                      state.loadFWdata(state.dtpFromDate, state.dtpToDate);
                    }
                    else if (index == 3) {
                      state.Invoicewiseview = true;
                      state.loadExpdata(state.dtpEFromDate, state.dtpEToDate);
                    }
                    else if (index == 4) {
                      state.IsToday = true;
                      state.Invoicewiseview = true;
                      state.loadVesseldata(0);
                    }
                    else if (index == 5) {
                      state.IsPlanToday = true;
                      state.Invoicewiseview = true;
                      state.loadPlanningdata(0);
                    }
                    else if (index == 6) {
                      state.IsPlanToday = true;
                      state.Invoicewiseview = true;
                      state.loadTruck();
                    }
                    else if (index == 7) {
                      state.IsPlanToday = true;
                      state.Invoicewiseview = true;
                      state.loadDrive();
                    }
                    else if (index == 8) {
                      state.IsPlanToday = true;
                      state.Invoicewiseview = true;
                      state.loadSpeeding();
                    }
                    else if (index == 9) {
                      state.IsPlanToday = true;
                      state.Invoicewiseview = true;
                      state.loadFuelFilling();
                    }
                    else if (index == 10) {
                      state.IsPlanToday = true;
                      state.Invoicewiseview = true;
                      state.loadEingeHours();
                    }
                    else if (index == 11) {
                      state.IsPlanToday = true;
                      state.Invoicewiseview = true;
                      state.loadEingeHours();
                    }

                    else if (index == 12) {
                      state.IsPlanToday = true;
                      state.Invoicewiseview = true;
                      state.loadfueldifference();
                    }
                    else if (index == 13) {
                      state.IsPlanToday = true;
                      state.Invoicewiseview = true;
                      state.LoadEmployeeViewRecords();
                    }
                    else if (index == 18) {
                      state.IsPlanToday = true;
                      state.Invoicewiseview = true;
                      state.loadpettycash();
                    }
                    else if (index == 14) {

                      state.loadReceipt();
                    }
                    else if (index == 15) {

                      state.loadTruckList();
                    }
                    else if (index == 16) {

                      state.loadTruckList();
                    }

                    else if (index == 20) {

                      state.loadData();
                    }
                    else if (index == 21) {

                      state.loadData();
                    }
                    else if (index == 24) {

                      state.loaddata1();
                    }
                  },
                ),),
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
                          const SizedBox(height: 7,),
                          Center(child: Text(
                            '${state.currentMonthName}   Sales', style:
                          GoogleFonts.lato(
                            textStyle: TextStyle(
                                color: colour.commonColorred,
                                fontWeight:
                                FontWeight.bold,
                                fontSize: objfun.FontLarge,
                                letterSpacing: 0.3),),),
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
                                                  bottom: 5),
                                              child: InkWell(
                                                onTap: () {
                                                  state.loadEmpInvdata(0);
                                                },
                                                child: Text(
                                                  "Today",
                                                  textAlign: TextAlign.left,
                                                  style:
                                                  GoogleFonts.lato(
                                                    textStyle: TextStyle(
                                                        color: colour
                                                            .commonColor,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: objfun
                                                            .FontLow - 2,
                                                        letterSpacing: 0.3),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(5),
                                              child: InkWell(
                                                onTap: () {
                                                  state.loadEmpInvdata(1);
                                                },
                                                child: Text(
                                                  "Yesterday",
                                                  textAlign: TextAlign.left,
                                                  style:
                                                  GoogleFonts.lato(
                                                    textStyle: TextStyle(
                                                        color: colour
                                                            .commonColor,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: objfun
                                                            .FontLow - 2,
                                                        letterSpacing: 0.3),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5,
                                                  left: 5,
                                                  right: 5,
                                                  bottom: 5),
                                              child: InkWell(
                                                onTap: () {
                                                  state.loadEmpInvdata(2);
                                                },
                                                child: Text(
                                                  "Weekly",
                                                  textAlign: TextAlign.left,
                                                  style:
                                                  GoogleFonts.lato(
                                                    textStyle: TextStyle(
                                                        color: colour
                                                            .commonColor,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: objfun
                                                            .FontLow - 2,
                                                        letterSpacing: 0.3),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                                onTap: () {
                                                  state.loadEmpInvdata(4);
                                                },
                                                child: Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                      top: 5,
                                                      left: 5,
                                                      right: 5,
                                                      bottom: 15),
                                                  child: Text(
                                                    "Monthly",
                                                    textAlign: TextAlign.left,
                                                    style: GoogleFonts
                                                        .lato(
                                                      textStyle:
                                                      TextStyle(
                                                          color: colour
                                                              .commonColor,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          fontSize: objfun
                                                              .FontLow - 2,
                                                          letterSpacing:
                                                          0.3),
                                                    ),
                                                  ),
                                                ),
                                                onLongPress: () {


                                                }),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5,
                                                  left: 5,
                                                  right: 5,
                                                  bottom: 5),
                                              child: InkWell(
                                                onTap: () {
                                                  state.showBillingBottomSheet(context, state.SalewaitingbillingAll);
                                                },
                                                child: Text(
                                                  "Waiting for Billing ",
                                                  textAlign: TextAlign.left,
                                                  style:
                                                  GoogleFonts.lato(
                                                    textStyle: TextStyle(
                                                        color: colour
                                                            .commonColor,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: objfun
                                                            .FontLow - 2,
                                                        letterSpacing: 0.3),
                                                  ),
                                                ),
                                              ),
                                            ),

                                          ])),
                                  Expanded(
                                      flex: 1,
                                      child: Column(children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 15,
                                              left: 5,
                                              right: 5,
                                              bottom: 5),
                                          child: InkWell(
                                            onTap: () {
                                              state.loadEmpInvdata(0);
                                            },
                                            child: Text(
                                              state.SaleDataAll.isEmpty
                                                  ? '0'
                                                  : state
                                                  .SaleDataAll[0]["TodaySales"]
                                                  .toStringAsFixed(0),
                                              style: GoogleFonts.lato(
                                                textStyle: TextStyle(
                                                    color: colour.commonColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: objfun.FontLow -
                                                        2,
                                                    letterSpacing: 0.3),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 5, bottom: 5),
                                          child: InkWell(
                                            onTap: () {
                                              state.loadEmpInvdata(1);
                                            },
                                            child: Text(
                                              state.SaleDataAll.isEmpty
                                                  ? '0'
                                                  : state
                                                  .SaleDataAll[0]["YesterdaySales"]
                                                  .toStringAsFixed(0),
                                              style: GoogleFonts.lato(
                                                textStyle: TextStyle(
                                                    color: colour.commonColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: objfun.FontLow -
                                                        2,
                                                    letterSpacing: 0.3),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 5, bottom: 5),
                                          child: InkWell(
                                            onTap: () {
                                              state.loadEmpInvdata(2);
                                            },
                                            child: Text(
                                              state.SaleDataAll.isEmpty
                                                  ? '0'
                                                  : state
                                                  .SaleDataAll[0]["WeekSales"]
                                                  .toStringAsFixed(0),
                                              style: GoogleFonts.lato(
                                                textStyle: TextStyle(
                                                    color: colour.commonColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: objfun.FontLow -
                                                        2,
                                                    letterSpacing: 0.3),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 5,
                                              left: 5,
                                              right: 5,
                                              bottom: 15),
                                          child: InkWell(
                                            onTap: () {
                                              state.loadEmpInvdata(3);
                                            },
                                            child: Text(
                                              state.SaleDataAll.isEmpty
                                                  ? '0'
                                                  : state
                                                  .SaleDataAll[0]["MonthSales"]
                                                  .toStringAsFixed(0),
                                              style: GoogleFonts.lato(
                                                textStyle: TextStyle(
                                                    color: colour.commonColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: objfun.FontLow -
                                                        2,
                                                    letterSpacing: 0.3),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 15),
                                          child: InkWell(
                                              onTap: () {
                                                state.showBillingBottomSheet(context, state.SalewaitingbillingAll);
                                              },

                                              child: Text(
                                              state.SalewaitingbillingAll.length.toString(),
                                              style: GoogleFonts.lato(
                                                textStyle: TextStyle(
                                                  color: colour.commonColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: objfun.FontLow - 2,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),



                                      ])),
                                  Expanded(
                                      flex: 2,
                                      child: Column(children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 15,
                                              left: 5,
                                              right: 5,
                                              bottom: 5),
                                          child: InkWell(
                                            onTap: () {
                                              state.loadEmpInvdata(0);
                                            },
                                            child: Text(
                                              state.SaleDataAll.isEmpty
                                                  ? '0'
                                                  : state
                                                  .SaleDataAll[0]["TodayAmount"]
                                                  .toStringAsFixed(0),
                                              style: GoogleFonts.lato(
                                                textStyle: TextStyle(
                                                    color: colour.commonColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: objfun.FontLow -
                                                        2,
                                                    letterSpacing: 0.3),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 5, bottom: 5),
                                          child: InkWell(
                                            onTap: () {
                                              state.loadEmpInvdata(1);
                                            },
                                            child: Text(
                                              state.SaleDataAll.isEmpty
                                                  ? '0'
                                                  : state
                                                  .SaleDataAll[0]["YesterdayAmount"]
                                                  .toStringAsFixed(0),
                                              style: GoogleFonts.lato(
                                                textStyle: TextStyle(
                                                    color: colour.commonColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: objfun.FontLow -
                                                        2,
                                                    letterSpacing: 0.3),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 5, bottom: 5),
                                          child: InkWell(
                                            onTap: () {
                                              state.loadEmpInvdata(2);
                                            },
                                            child: Text(
                                              state.SaleDataAll.isEmpty
                                                  ? '0'
                                                  : state
                                                  .SaleDataAll[0]["WeekAmount"]
                                                  .toStringAsFixed(0),
                                              style: GoogleFonts.lato(
                                                textStyle: TextStyle(
                                                    color: colour.commonColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: objfun.FontLow -
                                                        2,
                                                    letterSpacing: 0.3),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 5,
                                              left: 5,
                                              right: 5,
                                              bottom: 15),
                                          child: InkWell(
                                            onTap: () {
                                              state.loadEmpInvdata(3);
                                            },
                                            child: Text(
                                              state.SaleDataAll.isEmpty
                                                  ? '0'
                                                  : state
                                                  .SaleDataAll[0]["MonthAmount"]
                                                  .toStringAsFixed(0),
                                              style: GoogleFonts.lato(
                                                textStyle: TextStyle(
                                                    color: colour.commonColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: objfun.FontLow -
                                                        2,
                                                    letterSpacing: 0.3),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ])),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children:
                            [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colour.commonColorLight,
                                  side: BorderSide(
                                      color: state.Is6Months ? colour
                                          .commonColor : colour
                                          .commonColorLight,
                                      width: 1,
                                      style: BorderStyle.solid),
                                  textStyle: const TextStyle(color: Colors
                                      .black),
                                  elevation: state.Is6Months ? 15.0 : 0,

                                  padding: const EdgeInsets.all(4.0),
                                ),
                                onPressed: () {
                                  state.monthdata(6);
                                  state.setState(() {
                                    state.Is6Months = true;
                                  });
                                },
                                child: Text(
                                  '6 Months',
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
                                      color: state.Is6Months ? colour
                                          .commonColorLight : colour
                                          .commonColor,
                                      width: 1,
                                      style: BorderStyle.solid),
                                  textStyle: const TextStyle(color: Colors
                                      .black),
                                  elevation: state.Is6Months ? 0.0 : 15.0,

                                  padding: const EdgeInsets.all(4.0),
                                ),
                                onPressed: () {
                                  state.monthdata(12);
                                  state.setState(() {
                                    state.Is6Months = false;
                                  });
                                },
                                child: Text(
                                  '1 Year',
                                  style: GoogleFonts.lato(
                                      fontSize: objfun.FontMedium,
                                      fontWeight: FontWeight.bold,
                                      color: colour.commonColor),
                                ),
                              ),
                            ],),
                          SizedBox(
                              height: height * 0.50,
                              child: ListView.builder(
                                  itemCount:
                                  state.LoadMonthsList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return SizedBox(
                                        height: height * 0.05,
                                        child: InkWell(
                                          onLongPress: () {

                                          },
                                          onTap: () {
                                            if (index == 0) {
                                              state.loadEmpInvdata(3);
                                            }
                                            else if (index == 1) {
                                              state.loadEmpInvdata(4);
                                            }
                                            else if (index == 2) {
                                              state.loadEmpInvdata(5);
                                            }
                                            else if (index == 3) {
                                              state.loadEmpInvdata(6);
                                            }
                                            else if (index == 4) {
                                              state.loadEmpInvdata(7);
                                            }
                                            else if (index == 5) {
                                              state.loadEmpInvdata(8);
                                            }
                                            else if (index == 6) {
                                              state.loadEmpInvdata(9);
                                            }
                                            else if (index == 7) {
                                              state.loadEmpInvdata(10);
                                            }
                                            else if (index == 8) {
                                              state.loadEmpInvdata(11);
                                            }
                                            else if (index == 9) {
                                              state.loadEmpInvdata(12);
                                            }
                                            else if (index == 10) {
                                              state.loadEmpInvdata(13);
                                            }
                                            else if (index == 11) {
                                              state.loadEmpInvdata(14);
                                            }
                                          },


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
                                                                    .LoadMonthsList[index],
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
                                                                    .ListMonthData[index]["SalesCount"]
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
                                                                    .ListMonthData[index]["SalesAmount"]
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
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        /// 🔹 Date Range + Search
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => state.pickDate(true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Text(
                                    state.fromDate == null
                                        ? 'From Date'
                                        : DateFormat('dd/MM/yyyy').format(state.fromDate!),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                            ),


                            const SizedBox(width: 12),

                            Expanded(
                              child: GestureDetector(
                                onTap: () => state.pickDate(false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Text(
                                    state.toDate == null
                                        ? 'To Date'
                                        : DateFormat('dd/MM/yyyy').format(state.toDate!),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            ElevatedButton.icon(
                              onPressed: () {
                                state.loadReceipt(isDateSearch: true);

                              },
                              icon: const Icon(Icons.search),
                              label: const Text("Search"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.indigo.shade200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              /// TOTAL AMOUNT
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Total Amount",
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                  Text(
                                    "RM ${state.totalAmount}",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green),
                                  ),
                                ],
                              ),

                              /// TOTAL BALANCE
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text("Total Outstanding Amount",
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                  Text(
                                    "RM ${state.totalBalance}",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// 🔹 Data Section
                        Expanded(
                          child: !state.progress
                              ? const Center(child: CircularProgressIndicator())
                              : ListView(
                            children: [
                              /// MASTER TITLE
                              const Text(
                                "Receipt",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),

                              /// 🔥 MASTER LIST WITH TAP
                              ...state.receiptMaster.map(
                                    (m) => Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: ListTile(
                                    title: Text("${m["CustomerName"]} (${m["BillNo"]})"),
                                    subtitle: Text(
                                      "Date: ${m["BillDate"]}\nEmployee: ${m["EmployeeName"]}",
                                    ),

                                    /// ⭐ TRIMMED, NO OVERFLOW TRAILING
                                    trailing: SizedBox(
                                      width: 90,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerRight,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              "${m["BillAmount"].toStringAsFixed(2)}",
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              "Bal: ${m["Balance"].toStringAsFixed(2)}",
                                              style: const TextStyle(color: Colors.red),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    /// ⭐ ON TAP → BOTTOM SHEET FILTERING
                                 /*   onTap: () {
                                      int masterId = m["Id"];

                                      /// filter
                                      List<Map<String, dynamic>> filteredDetails =
                                      state.receiptDetails
                                          .where((d) => d["SaleRefId"] == masterId)
                                          .toList();

                                      /// bottom sheet
                                      showModalBottomSheet(
                                        context: context,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.vertical(top: Radius.circular(16)),
                                        ),
                                        builder: (context) {
                                          return Container(
                                            padding: const EdgeInsets.all(16),
                                            height: 360,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Receipt Details",
                                                  style: TextStyle(
                                                      fontSize: 18, fontWeight: FontWeight.bold),
                                                ),
                                                const SizedBox(height: 10),

                                                Expanded(
                                                  child: filteredDetails.isEmpty
                                                      ? const Center(
                                                      child: Text("No Details Found"))
                                                      : ListView.builder(
                                                    itemCount: filteredDetails.length,
                                                    itemBuilder: (context, i) {
                                                      var d = filteredDetails[i];
                                                      return Card(
                                                        elevation: 1,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius.circular(8),
                                                        ),
                                                        child: ListTile(
                                                          title: Text(d["SaleNo"] ?? ""),
                                                          subtitle: Text(
                                                            "Customer: ${d["DCustomerName"]}\nDate: ${d["SSaleDate"]}",
                                                          ),
                                                          trailing: Text(
                                                            "₹${d["ReceiptAmount"]}",
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                FontWeight.bold),
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
                                    },*/
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),
                              /// 🔹 FULL DETAIL LIST (optional)
                              const Text(
                                "All Receipt Details",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),

                              ...state.receiptDetails.map(
                                    (d) => Card(
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    title: Text(d["SaleNo"] ?? ""),
                                    subtitle: Text(
                                      "Customer: ${d["DCustomerName"]}\nDate: ${d["SSaleDate"]}",
                                    ),
                                    trailing: Text(
                                      "RM${d["ReceiptAmount"]}",
                                      style:
                                      const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  DefaultTabController(
                      length: 3,
                      child: TabBarView(
                          controller: state._tabController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            Padding(
                                padding: const EdgeInsets.only(
                                    top: 15.0, left: 10.0, right: 10.0),
                                child: ListView(
                                  children: [
                                    const SizedBox(height: 7,),
                                    Center(child: Text('${state
                                        .currentMonthName}   Sales', style:
                                    GoogleFonts.lato(
                                      textStyle: TextStyle(
                                          color: colour.commonColorred,
                                          fontWeight:
                                          FontWeight.bold,
                                          fontSize: objfun.FontLarge,
                                          letterSpacing: 0.3),),),
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
                                                        padding: const EdgeInsets
                                                            .only(
                                                            top: 15,
                                                            left: 5,
                                                            right: 5,
                                                            bottom: 5),
                                                        child: InkWell(
                                                          onTap: () {
                                                            state
                                                                .loadEmpSalesdata(
                                                                0);
                                                          },
                                                          child: Text(
                                                            "Today",
                                                            textAlign: TextAlign
                                                                .left,
                                                            style:
                                                            GoogleFonts.lato(
                                                              textStyle: TextStyle(
                                                                  color: colour
                                                                      .commonColor,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                  fontSize: objfun
                                                                      .FontLow -
                                                                      2,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .all(5),
                                                        child: InkWell(
                                                          onTap: () {
                                                            state
                                                                .loadEmpSalesdata(
                                                                1);
                                                          },
                                                          child: Text(
                                                            "Yesterday",
                                                            textAlign: TextAlign
                                                                .left,
                                                            style:
                                                            GoogleFonts.lato(
                                                              textStyle: TextStyle(
                                                                  color: colour
                                                                      .commonColor,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                  fontSize: objfun
                                                                      .FontLow -
                                                                      2,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            top: 5,
                                                            left: 5,
                                                            right: 5,
                                                            bottom: 5),
                                                        child: InkWell(
                                                          onTap: () {
                                                            state
                                                                .loadEmpSalesdata(
                                                                2);
                                                          },
                                                          child: Text(
                                                            "Weekly",
                                                            textAlign: TextAlign
                                                                .left,
                                                            style:
                                                            GoogleFonts.lato(
                                                              textStyle: TextStyle(
                                                                  color: colour
                                                                      .commonColor,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                  fontSize: objfun
                                                                      .FontLow -
                                                                      2,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                          onTap: () {
                                                            state
                                                                .loadEmpSalesdata(
                                                                3);
                                                          },
                                                          child: Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 5,
                                                                left: 5,
                                                                right: 5,
                                                                bottom: 15),
                                                            child: Text(
                                                              "Monthly",
                                                              textAlign: TextAlign
                                                                  .left,
                                                              style: GoogleFonts
                                                                  .lato(
                                                                textStyle:
                                                                TextStyle(
                                                                    color: colour
                                                                        .commonColor,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize: objfun
                                                                        .FontLow -
                                                                        2,
                                                                    letterSpacing:
                                                                    0.3),
                                                              ),
                                                            ),
                                                          ),
                                                          onLongPress: () {


                                                          }),
                                                    ])),
                                            Expanded(
                                                flex: 1,
                                                child: Column(
                                                    children: <Widget>[
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            top: 15,
                                                            left: 5,
                                                            right: 5,
                                                            bottom: 5),
                                                        child: InkWell(
                                                          onTap: () {
                                                            state
                                                                .loadEmpSalesdata(
                                                                0);
                                                          },
                                                          child: Text(
                                                            state.SaleDataAll
                                                                .isEmpty
                                                                ? '0'
                                                                : state
                                                                .SaleDataAll[0]["TodaySales"]
                                                                .toStringAsFixed(
                                                                0),
                                                            style: GoogleFonts
                                                                .lato(
                                                              textStyle: TextStyle(
                                                                  color: colour
                                                                      .commonColor,
                                                                  fontWeight: FontWeight
                                                                      .bold,
                                                                  fontSize: objfun
                                                                      .FontLow -
                                                                      2,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            top: 5, bottom: 5),
                                                        child: InkWell(
                                                          onTap: () {
                                                            state
                                                                .loadEmpSalesdata(
                                                                1);
                                                          },
                                                          child: Text(
                                                            state.SaleDataAll
                                                                .isEmpty
                                                                ? '0'
                                                                : state
                                                                .SaleDataAll[0]["YesterdaySales"]
                                                                .toStringAsFixed(
                                                                0),
                                                            style: GoogleFonts
                                                                .lato(
                                                              textStyle: TextStyle(
                                                                  color: colour
                                                                      .commonColor,
                                                                  fontWeight: FontWeight
                                                                      .bold,
                                                                  fontSize: objfun
                                                                      .FontLow -
                                                                      2,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            top: 5, bottom: 5),
                                                        child: InkWell(
                                                          onTap: () {
                                                            state
                                                                .loadEmpSalesdata(
                                                                2);
                                                          },
                                                          child: Text(
                                                            state.SaleDataAll
                                                                .isEmpty
                                                                ? '0'
                                                                : state
                                                                .SaleDataAll[0]["WeekSales"]
                                                                .toStringAsFixed(
                                                                0),
                                                            style: GoogleFonts
                                                                .lato(
                                                              textStyle: TextStyle(
                                                                  color: colour
                                                                      .commonColor,
                                                                  fontWeight: FontWeight
                                                                      .bold,
                                                                  fontSize: objfun
                                                                      .FontLow -
                                                                      2,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            top: 5,
                                                            left: 5,
                                                            right: 5,
                                                            bottom: 15),
                                                        child: InkWell(
                                                          onTap: () {
                                                            state
                                                                .loadEmpSalesdata(
                                                                3);
                                                          },
                                                          child: Text(
                                                            state.SaleDataAll
                                                                .isEmpty
                                                                ? '0'
                                                                : state
                                                                .SaleDataAll[0]["MonthSales"]
                                                                .toStringAsFixed(
                                                                0),
                                                            style: GoogleFonts
                                                                .lato(
                                                              textStyle: TextStyle(
                                                                  color: colour
                                                                      .commonColor,
                                                                  fontWeight: FontWeight
                                                                      .bold,
                                                                  fontSize: objfun
                                                                      .FontLow -
                                                                      2,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ])),
                                            Expanded(
                                                flex: 2,
                                                child: Column(
                                                    children: <Widget>[
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            top: 15,
                                                            left: 5,
                                                            right: 5,
                                                            bottom: 5),
                                                        child: InkWell(
                                                          onTap: () {
                                                            state
                                                                .loadEmpSalesdata(
                                                                0);
                                                          },
                                                          child: Text(
                                                            state.SaleDataAll
                                                                .isEmpty
                                                                ? '0'
                                                                : state
                                                                .SaleDataAll[0]["TodayAmount"]
                                                                .toStringAsFixed(
                                                                0),
                                                            style: GoogleFonts
                                                                .lato(
                                                              textStyle: TextStyle(
                                                                  color: colour
                                                                      .commonColor,
                                                                  fontWeight: FontWeight
                                                                      .bold,
                                                                  fontSize: objfun
                                                                      .FontLow -
                                                                      2,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            top: 5, bottom: 5),
                                                        child: InkWell(
                                                          onTap: () {
                                                            state
                                                                .loadEmpSalesdata(
                                                                1);
                                                          },
                                                          child: Text(
                                                            state.SaleDataAll
                                                                .isEmpty
                                                                ? '0'
                                                                : state
                                                                .SaleDataAll[0]["YesterdayAmount"]
                                                                .toStringAsFixed(
                                                                0),
                                                            style: GoogleFonts
                                                                .lato(
                                                              textStyle: TextStyle(
                                                                  color: colour
                                                                      .commonColor,
                                                                  fontWeight: FontWeight
                                                                      .bold,
                                                                  fontSize: objfun
                                                                      .FontLow -
                                                                      2,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            top: 5, bottom: 5),
                                                        child: InkWell(
                                                          onTap: () {
                                                            state
                                                                .loadEmpSalesdata(
                                                                2);
                                                          },
                                                          child: Text(
                                                            state.SaleDataAll
                                                                .isEmpty
                                                                ? '0'
                                                                : state
                                                                .SaleDataAll[0]["WeekAmount"]
                                                                .toStringAsFixed(
                                                                0),
                                                            style: GoogleFonts
                                                                .lato(
                                                              textStyle: TextStyle(
                                                                  color: colour
                                                                      .commonColor,
                                                                  fontWeight: FontWeight
                                                                      .bold,
                                                                  fontSize: objfun
                                                                      .FontLow -
                                                                      2,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            top: 5,
                                                            left: 5,
                                                            right: 5,
                                                            bottom: 15),
                                                        child: InkWell(
                                                          onTap: () {
                                                            state
                                                                .loadEmpSalesdata(
                                                                3);
                                                          },
                                                          child: Text(
                                                            state.SaleDataAll
                                                                .isEmpty
                                                                ? '0'
                                                                : state
                                                                .SaleDataAll[0]["MonthAmount"]
                                                                .toStringAsFixed(
                                                                0),
                                                            style: GoogleFonts
                                                                .lato(
                                                              textStyle: TextStyle(
                                                                  color: colour
                                                                      .commonColor,
                                                                  fontWeight: FontWeight
                                                                      .bold,
                                                                  fontSize: objfun
                                                                      .FontLow -
                                                                      2,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ])),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children:
                                      [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: colour
                                                .commonColorLight,
                                            side: BorderSide(
                                                color: state.Is6Months ? colour
                                                    .commonColor : colour
                                                    .commonColorLight,
                                                width: 1,
                                                style: BorderStyle.solid),
                                            textStyle: const TextStyle(
                                                color: Colors.black),
                                            elevation: state.Is6Months
                                                ? 15.0
                                                : 0,

                                            padding: const EdgeInsets.all(4.0),
                                          ),
                                          onPressed: () {
                                            state.monthdata(6);
                                            state.setState(() {
                                              state.Is6Months = true;
                                            });
                                          },
                                          child: Text(
                                            '6 Months',
                                            style: GoogleFonts.lato(
                                                fontSize: objfun.FontMedium,
                                                fontWeight: FontWeight.bold,
                                                color: colour.commonColor),
                                          ),
                                        ),
                                        const SizedBox(width: 5,),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: colour
                                                .commonColorLight,
                                            side: BorderSide(
                                                color: state.Is6Months ? colour
                                                    .commonColorLight : colour
                                                    .commonColor,
                                                width: 1,
                                                style: BorderStyle.solid),
                                            textStyle: const TextStyle(
                                                color: Colors.black),
                                            elevation: state.Is6Months
                                                ? 0.0
                                                : 15.0,

                                            padding: const EdgeInsets.all(4.0),
                                          ),
                                          onPressed: () {
                                            state.monthdata(12);
                                            state.setState(() {
                                              state.Is6Months = false;
                                            });
                                          },
                                          child: Text(
                                            '1 Year',
                                            style: GoogleFonts.lato(
                                                fontSize: objfun.FontMedium,
                                                fontWeight: FontWeight.bold,
                                                color: colour.commonColor),
                                          ),
                                        ),
                                      ],),
                                    SizedBox(
                                        height: height * 0.42,
                                        child: ListView.builder(
                                            itemCount:
                                            state.LoadMonthsList.length,
                                            itemBuilder:
                                                (BuildContext context,
                                                int index) {
                                              return SizedBox(
                                                  height: height * 0.05,
                                                  child: InkWell(
                                                    onLongPress: () {

                                                    },
                                                    onTap: () {
                                                      if (index == 0) {
                                                        state.loadEmpSalesdata(
                                                            3);
                                                      }
                                                      else if (index == 1) {
                                                        state.loadEmpSalesdata(
                                                            4);
                                                      }
                                                      else if (index == 2) {
                                                        state.loadEmpSalesdata(
                                                            5);
                                                      }
                                                      else if (index == 3) {
                                                        state.loadEmpSalesdata(
                                                            6);
                                                      }
                                                      else if (index == 4) {
                                                        state.loadEmpSalesdata(
                                                            7);
                                                      }
                                                      else if (index == 5) {
                                                        state.loadEmpSalesdata(
                                                            8);
                                                      }
                                                      else if (index == 6) {
                                                        state.loadEmpSalesdata(
                                                            9);
                                                      }
                                                      else if (index == 7) {
                                                        state.loadEmpSalesdata(
                                                            10);
                                                      }
                                                      else if (index == 8) {
                                                        state.loadEmpSalesdata(
                                                            11);
                                                      }
                                                      else if (index == 9) {
                                                        state.loadEmpSalesdata(
                                                            12);
                                                      }
                                                      else if (index == 10) {
                                                        state.loadEmpSalesdata(
                                                            13);
                                                      }
                                                      else if (index == 11) {
                                                        state.loadEmpSalesdata(
                                                            14);
                                                      }
                                                    },
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
                                                                  CrossAxisAlignment
                                                                      .center,
                                                                  children: <
                                                                      Widget>[
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child: Container(
                                                                        padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            5),
                                                                        child: Text(
                                                                          state
                                                                              .LoadMonthsList[index],
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
                                                                flex: 2,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                                  crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                                  children: <
                                                                      Widget>[
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child: Container(
                                                                        padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            5),
                                                                        child: Text(
                                                                          state
                                                                              .ListMonthData[index]["SalesCount"]
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
                                                            Expanded(
                                                                flex: 2,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                                  crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                                  children: <
                                                                      Widget>[
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child: Container(
                                                                        padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            5),
                                                                        child: Text(
                                                                          state
                                                                              .ListMonthData[index]["SalesAmount"]
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
                            Padding(
                                padding: const EdgeInsets.only(
                                    top: 15.0, left: 10.0, right: 10.0),
                                child: ListView(
                                  children: [
                                    const SizedBox(height: 7,),
                                    Center(child:
                                    Text('${state.currentMonthName}  Sales',
                                      style:
                                      GoogleFonts.lato(
                                        textStyle: TextStyle(
                                            color: colour.commonColorred,
                                            fontWeight:
                                            FontWeight.bold,
                                            fontSize: objfun.FontLarge,
                                            letterSpacing: 0.3),),),),
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
                                                        padding: const EdgeInsets
                                                            .only(
                                                            top: 15,
                                                            left: 5,
                                                            right: 5,
                                                            bottom: 5),
                                                        child: InkWell(
                                                          onTap: () {
                                                            state
                                                                .loadEmpSalesdata(
                                                                15);
                                                          },
                                                          child: Text(
                                                            "Today",
                                                            textAlign: TextAlign
                                                                .left,
                                                            style:
                                                            GoogleFonts.lato(
                                                              textStyle: TextStyle(
                                                                  color: colour
                                                                      .commonColor,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                  fontSize: objfun
                                                                      .FontLow -
                                                                      2,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .all(5),
                                                        child: InkWell(
                                                          onTap: () {
                                                            state
                                                                .loadEmpSalesdata(
                                                                16);
                                                          },
                                                          child: Text(
                                                            "Yesterday",
                                                            textAlign: TextAlign
                                                                .left,
                                                            style:
                                                            GoogleFonts.lato(
                                                              textStyle: TextStyle(
                                                                  color: colour
                                                                      .commonColor,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                  fontSize: objfun
                                                                      .FontLow -
                                                                      2,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            top: 5,
                                                            left: 5,
                                                            right: 5,
                                                            bottom: 5),
                                                        child: InkWell(
                                                          onTap: () {
                                                            state
                                                                .loadEmpSalesdata(
                                                                17);
                                                          },
                                                          child: Text(
                                                            "Weekly",
                                                            textAlign: TextAlign
                                                                .left,
                                                            style:
                                                            GoogleFonts.lato(
                                                              textStyle: TextStyle(
                                                                  color: colour
                                                                      .commonColor,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                  fontSize: objfun
                                                                      .FontLow -
                                                                      2,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                          child: Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 5,
                                                                left: 5,
                                                                right: 5,
                                                                bottom: 15),
                                                            child: InkWell(
                                                              onTap: () {
                                                                state
                                                                    .loadEmpSalesdata(
                                                                    18);
                                                              },
                                                              child: Text(
                                                                "Monthly",
                                                                textAlign: TextAlign
                                                                    .left,
                                                                style: GoogleFonts
                                                                    .lato(
                                                                  textStyle:
                                                                  TextStyle(
                                                                      color: colour
                                                                          .commonColor,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                      fontSize: objfun
                                                                          .FontLow -
                                                                          2,
                                                                      letterSpacing:
                                                                      0.3),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          onLongPress: () {


                                                          }),
                                                    ])),
                                            Expanded(
                                                flex: 1,
                                                child: Column(
                                                    children: <Widget>[
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            top: 15,
                                                            left: 5,
                                                            right: 5,
                                                            bottom: 5),
                                                        child: InkWell(
                                                          onTap: () {
                                                            state
                                                                .loadEmpSalesdata(
                                                                15);
                                                          },
                                                          child: Text(
                                                            state.SaleDataAll
                                                                .isEmpty
                                                                ? '0'
                                                                : state
                                                                .SaleDataAll[0]["TodaySales"]
                                                                .toStringAsFixed(
                                                                0),
                                                            style: GoogleFonts
                                                                .lato(
                                                              textStyle: TextStyle(
                                                                  color: colour
                                                                      .commonColor,
                                                                  fontWeight: FontWeight
                                                                      .bold,
                                                                  fontSize: objfun
                                                                      .FontLow -
                                                                      2,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            top: 5, bottom: 5),
                                                        child: InkWell(
                                                          onTap: () {
                                                            state
                                                                .loadEmpSalesdata(
                                                                16);
                                                          },
                                                          child: Text(
                                                            state.SaleDataAll
                                                                .isEmpty
                                                                ? '0'
                                                                : state
                                                                .SaleDataAll[0]["YesterdaySales"]
                                                                .toStringAsFixed(
                                                                0),
                                                            style: GoogleFonts
                                                                .lato(
                                                              textStyle: TextStyle(
                                                                  color: colour
                                                                      .commonColor,
                                                                  fontWeight: FontWeight
                                                                      .bold,
                                                                  fontSize: objfun
                                                                      .FontLow -
                                                                      2,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            top: 5, bottom: 5),
                                                        child: InkWell(
                                                          onTap: () {
                                                            state
                                                                .loadEmpSalesdata(
                                                                17);
                                                          },
                                                          child: Text(
                                                            state.SaleDataAll
                                                                .isEmpty
                                                                ? '0'
                                                                : state
                                                                .SaleDataAll[0]["WeekSales"]
                                                                .toStringAsFixed(
                                                                0),
                                                            style: GoogleFonts
                                                                .lato(
                                                              textStyle: TextStyle(
                                                                  color: colour
                                                                      .commonColor,
                                                                  fontWeight: FontWeight
                                                                      .bold,
                                                                  fontSize: objfun
                                                                      .FontLow -
                                                                      2,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            top: 5,
                                                            left: 5,
                                                            right: 5,
                                                            bottom: 15),
                                                        child: InkWell(
                                                          onTap: () {
                                                            state
                                                                .loadEmpSalesdata(
                                                                18);
                                                          },
                                                          child: Text(
                                                            state.SaleDataAll
                                                                .isEmpty
                                                                ? '0'
                                                                : state
                                                                .SaleDataAll[0]["MonthSales"]
                                                                .toStringAsFixed(
                                                                0),
                                                            style: GoogleFonts
                                                                .lato(
                                                              textStyle: TextStyle(
                                                                  color: colour
                                                                      .commonColor,
                                                                  fontWeight: FontWeight
                                                                      .bold,
                                                                  fontSize: objfun
                                                                      .FontLow -
                                                                      2,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ])),
                                            Expanded(
                                                flex: 2,
                                                child: Column(
                                                    children: <Widget>[
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            top: 15,
                                                            left: 5,
                                                            right: 5,
                                                            bottom: 5),
                                                        child: InkWell(
                                                          onTap: () {
                                                            state
                                                                .loadEmpSalesdata(
                                                                15);
                                                          },
                                                          child: Text(
                                                            state.SaleDataAll
                                                                .isEmpty
                                                                ? '0'
                                                                : state
                                                                .SaleDataAll[0]["TodayAmount"]
                                                                .toStringAsFixed(
                                                                0),
                                                            style: GoogleFonts
                                                                .lato(
                                                              textStyle: TextStyle(
                                                                  color: colour
                                                                      .commonColor,
                                                                  fontWeight: FontWeight
                                                                      .bold,
                                                                  fontSize: objfun
                                                                      .FontLow -
                                                                      2,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            top: 5, bottom: 5),
                                                        child: InkWell(
                                                          onTap: () {
                                                            state
                                                                .loadEmpSalesdata(
                                                                16);
                                                          },
                                                          child: Text(
                                                            state.SaleDataAll
                                                                .isEmpty
                                                                ? '0'
                                                                : state
                                                                .SaleDataAll[0]["YesterdayAmount"]
                                                                .toStringAsFixed(
                                                                0),
                                                            style: GoogleFonts
                                                                .lato(
                                                              textStyle: TextStyle(
                                                                  color: colour
                                                                      .commonColor,
                                                                  fontWeight: FontWeight
                                                                      .bold,
                                                                  fontSize: objfun
                                                                      .FontLow -
                                                                      2,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            top: 5, bottom: 5),
                                                        child: InkWell(
                                                          onTap: () {
                                                            state
                                                                .loadEmpSalesdata(
                                                                17);
                                                          },
                                                          child: Text(
                                                            state.SaleDataAll
                                                                .isEmpty
                                                                ? '0'
                                                                : state
                                                                .SaleDataAll[0]["WeekAmount"]
                                                                .toStringAsFixed(
                                                                0),
                                                            style: GoogleFonts
                                                                .lato(
                                                              textStyle: TextStyle(
                                                                  color: colour
                                                                      .commonColor,
                                                                  fontWeight: FontWeight
                                                                      .bold,
                                                                  fontSize: objfun
                                                                      .FontLow -
                                                                      2,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            top: 5,
                                                            left: 5,
                                                            right: 5,
                                                            bottom: 15),
                                                        child: InkWell(
                                                          onTap: () {
                                                            state
                                                                .loadEmpSalesdata(
                                                                18);
                                                          },
                                                          child: Text(
                                                            state.SaleDataAll
                                                                .isEmpty
                                                                ? '0'
                                                                : state
                                                                .SaleDataAll[0]["MonthAmount"]
                                                                .toStringAsFixed(
                                                                0),
                                                            style: GoogleFonts
                                                                .lato(
                                                              textStyle: TextStyle(
                                                                  color: colour
                                                                      .commonColor,
                                                                  fontWeight: FontWeight
                                                                      .bold,
                                                                  fontSize: objfun
                                                                      .FontLow -
                                                                      2,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ])),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children:
                                      [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: colour
                                                .commonColorLight,
                                            side: BorderSide(
                                                color: state.Is6Months2 ? colour
                                                    .commonColor : colour
                                                    .commonColorLight,
                                                width: 1,
                                                style: BorderStyle.solid),
                                            textStyle: const TextStyle(
                                                color: Colors.black),
                                            elevation: state.Is6Months2
                                                ? 15.0
                                                : 0,

                                            padding: const EdgeInsets.all(4.0),
                                          ),
                                          onPressed: () {
                                            state.monthdata(6);
                                            state.setState(() {
                                              state.Is6Months2 = true;
                                            });
                                          },
                                          child: Text(
                                            '6 Months',
                                            style: GoogleFonts.lato(
                                                fontSize: objfun.FontMedium,
                                                fontWeight: FontWeight.bold,
                                                color: colour.commonColor),
                                          ),
                                        ),
                                        const SizedBox(width: 5,),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: colour
                                                .commonColorLight,
                                            side: BorderSide(
                                                color: state.Is6Months2 ? colour
                                                    .commonColorLight : colour
                                                    .commonColor,
                                                width: 1,
                                                style: BorderStyle.solid),
                                            textStyle: const TextStyle(
                                                color: Colors.black),
                                            elevation: state.Is6Months2
                                                ? 0.0
                                                : 15.0,

                                            padding: const EdgeInsets.all(4.0),
                                          ),
                                          onPressed: () {
                                            state.monthdata(12);
                                            state.setState(() {
                                              state.Is6Months2 = false;
                                            });
                                          },
                                          child: Text(
                                            '1 Year',
                                            style: GoogleFonts.lato(
                                                fontSize: objfun.FontMedium,
                                                fontWeight: FontWeight.bold,
                                                color: colour.commonColor),
                                          ),
                                        ),
                                      ],),
                                    SizedBox(
                                        height: height * 0.42,
                                        child: ListView.builder(
                                            itemCount:
                                            state.LoadMonthsList.length,
                                            itemBuilder:
                                                (BuildContext context,
                                                int index) {
                                              return SizedBox(
                                                  height: height * 0.05,
                                                  child: InkWell(
                                                    onLongPress: () {


                                                    },
                                                    onTap: () {
                                                      if (index == 0) {
                                                        state.loadEmpSalesdata(
                                                            18);
                                                      }
                                                      else if (index == 1) {
                                                        state.loadEmpSalesdata(
                                                            19);
                                                      }
                                                      else if (index == 2) {
                                                        state.loadEmpSalesdata(
                                                            20);
                                                      }
                                                      else if (index == 3) {
                                                        state.loadEmpSalesdata(
                                                            21);
                                                      }
                                                      else if (index == 4) {
                                                        state.loadEmpSalesdata(
                                                            22);
                                                      }
                                                      else if (index == 5) {
                                                        state.loadEmpSalesdata(
                                                            23);
                                                      }
                                                      else if (index == 6) {
                                                        state.loadEmpSalesdata(
                                                            24);
                                                      }
                                                      else if (index == 7) {
                                                        state.loadEmpSalesdata(
                                                            25);
                                                      }
                                                      else if (index == 8) {
                                                        state.loadEmpSalesdata(
                                                            26);
                                                      }
                                                      else if (index == 9) {
                                                        state.loadEmpSalesdata(
                                                            27);
                                                      }
                                                      else if (index == 10) {
                                                        state.loadEmpSalesdata(
                                                            28);
                                                      }
                                                      else if (index == 11) {
                                                        state.loadEmpSalesdata(
                                                            29);
                                                      }
                                                    },
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
                                                                  CrossAxisAlignment
                                                                      .center,
                                                                  children: <
                                                                      Widget>[
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child: Container(
                                                                        padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            5),
                                                                        child: Text(
                                                                          state
                                                                              .LoadMonthsList[index],
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
                                                                flex: 2,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                                  crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                                  children: <
                                                                      Widget>[
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child: Container(
                                                                        padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            5),
                                                                        child: Text(
                                                                          state
                                                                              .ListMonthData[index]["SalesCount"]
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
                                                            Expanded(
                                                                flex: 2,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                                  crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                                  children: <
                                                                      Widget>[
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child: Container(
                                                                        padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            5),
                                                                        child: Text(
                                                                          state
                                                                              .ListMonthData[index]["SalesAmount"]
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
                            Padding(
                                padding: const EdgeInsets.only(
                                    top: 15.0, left: 10.0, right: 10.0),
                                child: ListView(
                                  children: [
                                    const SizedBox(height: 7,),
                                    Center(child:
                                    Text('${state.currentMonthName}   Sales',
                                      style:
                                      GoogleFonts.lato(
                                        textStyle: TextStyle(
                                            color: colour.commonColorred,
                                            fontWeight:
                                            FontWeight.bold,
                                            fontSize: objfun.FontLarge,
                                            letterSpacing: 0.3),),),),
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
                                                        padding: const EdgeInsets
                                                            .only(
                                                            top: 15,
                                                            left: 5,
                                                            right: 5,
                                                            bottom: 5),
                                                        child: InkWell(
                                                          onTap: () {
                                                            state
                                                                .loadEmpSalesdata(
                                                                30);
                                                          },
                                                          child: Text(
                                                            "Today",
                                                            textAlign: TextAlign
                                                                .left,
                                                            style:
                                                            GoogleFonts.lato(
                                                              textStyle: TextStyle(
                                                                  color: colour
                                                                      .commonColor,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                  fontSize: objfun
                                                                      .FontLow -
                                                                      2,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .all(5),
                                                        child: InkWell(
                                                          onTap: () {
                                                            state
                                                                .loadEmpSalesdata(
                                                                31);
                                                          },
                                                          child: Text(
                                                            "Yesterday",
                                                            textAlign: TextAlign
                                                                .left,
                                                            style:
                                                            GoogleFonts.lato(
                                                              textStyle: TextStyle(
                                                                  color: colour
                                                                      .commonColor,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                  fontSize: objfun
                                                                      .FontLow -
                                                                      2,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            top: 5,
                                                            left: 5,
                                                            right: 5,
                                                            bottom: 5),
                                                        child: InkWell(
                                                          onTap: () {
                                                            state
                                                                .loadEmpSalesdata(
                                                                32);
                                                          },
                                                          child: Text(
                                                            "Weekly",
                                                            textAlign: TextAlign
                                                                .left,
                                                            style:
                                                            GoogleFonts.lato(
                                                              textStyle: TextStyle(
                                                                  color: colour
                                                                      .commonColor,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                  fontSize: objfun
                                                                      .FontLow -
                                                                      2,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                          onTap: () {
                                                            state
                                                                .loadEmpSalesdata(
                                                                33);
                                                          },
                                                          child: Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 5,
                                                                left: 5,
                                                                right: 5,
                                                                bottom: 15),
                                                            child: Text(
                                                              "Monthly",
                                                              textAlign: TextAlign
                                                                  .left,
                                                              style: GoogleFonts
                                                                  .lato(
                                                                textStyle:
                                                                TextStyle(
                                                                    color: colour
                                                                        .commonColor,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize: objfun
                                                                        .FontLow -
                                                                        2,
                                                                    letterSpacing:
                                                                    0.3),
                                                              ),
                                                            ),
                                                          ),
                                                          onLongPress: () {


                                                          }),
                                                    ])),
                                            Expanded(
                                                flex: 1,
                                                child: Column(
                                                    children: <Widget>[
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            top: 15,
                                                            left: 5,
                                                            right: 5,
                                                            bottom: 5),
                                                        child: InkWell(
                                                          onTap: () {
                                                            state
                                                                .loadEmpSalesdata(
                                                                30);
                                                          },
                                                          child: Text(
                                                            state.SaleDataAll
                                                                .isEmpty
                                                                ? '0'
                                                                : state
                                                                .SaleDataAll[0]["TodaySales"]
                                                                .toStringAsFixed(
                                                                0),
                                                            style: GoogleFonts
                                                                .lato(
                                                              textStyle: TextStyle(
                                                                  color: colour
                                                                      .commonColor,
                                                                  fontWeight: FontWeight
                                                                      .bold,
                                                                  fontSize: objfun
                                                                      .FontLow -
                                                                      2,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            top: 5, bottom: 5),
                                                        child: InkWell(
                                                          onTap: () {
                                                            state
                                                                .loadEmpSalesdata(
                                                                31);
                                                          },
                                                          child: Text(
                                                            state.SaleDataAll
                                                                .isEmpty
                                                                ? '0'
                                                                : state
                                                                .SaleDataAll[0]["YesterdaySales"]
                                                                .toStringAsFixed(
                                                                0),
                                                            style: GoogleFonts
                                                                .lato(
                                                              textStyle: TextStyle(
                                                                  color: colour
                                                                      .commonColor,
                                                                  fontWeight: FontWeight
                                                                      .bold,
                                                                  fontSize: objfun
                                                                      .FontLow -
                                                                      2,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            top: 5, bottom: 5),
                                                        child: InkWell(
                                                          onTap: () {
                                                            state
                                                                .loadEmpSalesdata(
                                                                32);
                                                          },
                                                          child: Text(
                                                            state.SaleDataAll
                                                                .isEmpty
                                                                ? '0'
                                                                : state
                                                                .SaleDataAll[0]["WeekSales"]
                                                                .toStringAsFixed(
                                                                0),
                                                            style: GoogleFonts
                                                                .lato(
                                                              textStyle: TextStyle(
                                                                  color: colour
                                                                      .commonColor,
                                                                  fontWeight: FontWeight
                                                                      .bold,
                                                                  fontSize: objfun
                                                                      .FontLow -
                                                                      2,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            top: 5,
                                                            left: 5,
                                                            right: 5,
                                                            bottom: 15),
                                                        child: InkWell(
                                                          onTap: () {
                                                            state
                                                                .loadEmpSalesdata(
                                                                33);
                                                          },
                                                          child: Text(
                                                            state.SaleDataAll
                                                                .isEmpty
                                                                ? '0'
                                                                : state
                                                                .SaleDataAll[0]["MonthSales"]
                                                                .toStringAsFixed(
                                                                0),
                                                            style: GoogleFonts
                                                                .lato(
                                                              textStyle: TextStyle(
                                                                  color: colour
                                                                      .commonColor,
                                                                  fontWeight: FontWeight
                                                                      .bold,
                                                                  fontSize: objfun
                                                                      .FontLow -
                                                                      2,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ])),
                                            Expanded(
                                                flex: 2,
                                                child: Column(
                                                    children: <Widget>[
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            top: 15,
                                                            left: 5,
                                                            right: 5,
                                                            bottom: 5),
                                                        child: InkWell(
                                                          onTap: () {
                                                            state
                                                                .loadEmpSalesdata(
                                                                30);
                                                          },
                                                          child: Text(
                                                            state.SaleDataAll
                                                                .isEmpty
                                                                ? '0'
                                                                : state
                                                                .SaleDataAll[0]["TodayAmount"]
                                                                .toStringAsFixed(
                                                                0),
                                                            style: GoogleFonts
                                                                .lato(
                                                              textStyle: TextStyle(
                                                                  color: colour
                                                                      .commonColor,
                                                                  fontWeight: FontWeight
                                                                      .bold,
                                                                  fontSize: objfun
                                                                      .FontLow -
                                                                      2,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            top: 5, bottom: 5),
                                                        child: InkWell(
                                                          onTap: () {
                                                            state
                                                                .loadEmpSalesdata(
                                                                31);
                                                          },
                                                          child: Text(
                                                            state.SaleDataAll
                                                                .isEmpty
                                                                ? '0'
                                                                : state
                                                                .SaleDataAll[0]["YesterdayAmount"]
                                                                .toStringAsFixed(
                                                                0),
                                                            style: GoogleFonts
                                                                .lato(
                                                              textStyle: TextStyle(
                                                                  color: colour
                                                                      .commonColor,
                                                                  fontWeight: FontWeight
                                                                      .bold,
                                                                  fontSize: objfun
                                                                      .FontLow -
                                                                      2,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            top: 5, bottom: 5),
                                                        child: InkWell(
                                                          onTap: () {
                                                            state
                                                                .loadEmpSalesdata(
                                                                32);
                                                          },
                                                          child: Text(
                                                            state.SaleDataAll
                                                                .isEmpty
                                                                ? '0'
                                                                : state
                                                                .SaleDataAll[0]["WeekAmount"]
                                                                .toStringAsFixed(
                                                                0),
                                                            style: GoogleFonts
                                                                .lato(
                                                              textStyle: TextStyle(
                                                                  color: colour
                                                                      .commonColor,
                                                                  fontWeight: FontWeight
                                                                      .bold,
                                                                  fontSize: objfun
                                                                      .FontLow -
                                                                      2,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .only(
                                                            top: 5,
                                                            left: 5,
                                                            right: 5,
                                                            bottom: 15),
                                                        child: InkWell(
                                                          onTap: () {
                                                            state
                                                                .loadEmpSalesdata(
                                                                33);
                                                          },
                                                          child: Text(
                                                            state.SaleDataAll
                                                                .isEmpty
                                                                ? '0'
                                                                : state
                                                                .SaleDataAll[0]["MonthAmount"]
                                                                .toStringAsFixed(
                                                                0),
                                                            style: GoogleFonts
                                                                .lato(
                                                              textStyle: TextStyle(
                                                                  color: colour
                                                                      .commonColor,
                                                                  fontWeight: FontWeight
                                                                      .bold,
                                                                  fontSize: objfun
                                                                      .FontLow -
                                                                      2,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ])),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children:
                                      [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: colour
                                                .commonColorLight,
                                            side: BorderSide(
                                                color: state.Is6Months3 ? colour
                                                    .commonColor : colour
                                                    .commonColorLight,
                                                width: 1,
                                                style: BorderStyle.solid),
                                            textStyle: const TextStyle(
                                                color: Colors.black),
                                            elevation: state.Is6Months3
                                                ? 15.0
                                                : 0,

                                            padding: const EdgeInsets.all(4.0),
                                          ),
                                          onPressed: () {
                                            state.monthdata(6);
                                            state.setState(() {
                                              state.Is6Months3 = true;
                                            });
                                          },
                                          child: Text(
                                            '6 Months',
                                            style: GoogleFonts.lato(
                                                fontSize: objfun.FontMedium,
                                                fontWeight: FontWeight.bold,
                                                color: colour.commonColor),
                                          ),
                                        ),
                                        const SizedBox(width: 5,),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: colour
                                                .commonColorLight,
                                            side: BorderSide(
                                                color: state.Is6Months3 ? colour
                                                    .commonColorLight : colour
                                                    .commonColor,
                                                width: 1,
                                                style: BorderStyle.solid),
                                            textStyle: const TextStyle(
                                                color: Colors.black),
                                            elevation: state.Is6Months3
                                                ? 0.0
                                                : 15.0,

                                            padding: const EdgeInsets.all(4.0),
                                          ),
                                          onPressed: () {
                                            state.monthdata(12);
                                            state.setState(() {
                                              state.Is6Months3 = false;
                                            });
                                          },
                                          child: Text(
                                            '1 Year',
                                            style: GoogleFonts.lato(
                                                fontSize: objfun.FontMedium,
                                                fontWeight: FontWeight.bold,
                                                color: colour.commonColor),
                                          ),
                                        ),
                                      ],),
                                    SizedBox(
                                        height: height * 0.42,
                                        child: ListView.builder(
                                            itemCount:
                                            state.LoadMonthsList.length,
                                            itemBuilder:
                                                (BuildContext context,
                                                int index) {
                                              return SizedBox(
                                                  height: height * 0.05,
                                                  child: InkWell(
                                                    onLongPress: () {


                                                    },
                                                    onTap: () {
                                                      if (index == 0) {
                                                        state.loadEmpSalesdata(
                                                            33);
                                                      }
                                                      else if (index == 1) {
                                                        state.loadEmpSalesdata(
                                                            34);
                                                      }
                                                      else if (index == 2) {
                                                        state.loadEmpSalesdata(
                                                            35);
                                                      }
                                                      else if (index == 3) {
                                                        state.loadEmpSalesdata(
                                                            36);
                                                      }
                                                      else if (index == 4) {
                                                        state.loadEmpSalesdata(
                                                            37);
                                                      }
                                                      else if (index == 5) {
                                                        state.loadEmpSalesdata(
                                                            38);
                                                      }
                                                      else if (index == 6) {
                                                        state.loadEmpSalesdata(
                                                            39);
                                                      }
                                                      else if (index == 7) {
                                                        state.loadEmpSalesdata(
                                                            40);
                                                      }
                                                      else if (index == 8) {
                                                        state.loadEmpSalesdata(
                                                            41);
                                                      }
                                                      else if (index == 9) {
                                                        state.loadEmpSalesdata(
                                                            42);
                                                      }
                                                      else if (index == 10) {
                                                        state.loadEmpSalesdata(
                                                            43);
                                                      }
                                                      else if (index == 11) {
                                                        state.loadEmpSalesdata(
                                                            44);
                                                      }
                                                    },
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
                                                                  CrossAxisAlignment
                                                                      .center,
                                                                  children: <
                                                                      Widget>[
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child: Container(
                                                                        padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            5),
                                                                        child: Text(
                                                                          state
                                                                              .LoadMonthsList[index],
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
                                                                flex: 2,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                                  crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                                  children: <
                                                                      Widget>[
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child: Container(
                                                                        padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            5),
                                                                        child: Text(
                                                                          state
                                                                              .ListMonthData[index]["SalesCount"]
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
                                                            Expanded(
                                                                flex: 2,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                                  crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                                  children: <
                                                                      Widget>[
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child: Container(
                                                                        padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            5),
                                                                        child: Text(
                                                                          state
                                                                              .ListMonthData[index]["SalesAmount"]
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
                          ])),
                  Padding(
                      padding: const EdgeInsets.only(
                          top: 15.0, left: 10.0, right: 10.0),
                      child: ListView(
                        children: [
                          const SizedBox(height: 7,),
                          Center(child: Text('FORWARDING REPORT', style:
                          GoogleFonts.lato(
                            textStyle: TextStyle(
                                color: colour.commonColorred,
                                fontWeight:
                                FontWeight.bold,
                                fontSize: objfun.FontLarge,
                                letterSpacing: 0.3),),),
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
                                                  bottom: 5),
                                              child: Text(
                                                "",
                                                textAlign: TextAlign.left,
                                                style:
                                                GoogleFonts.lato(
                                                  textStyle: TextStyle(
                                                      color: colour.commonColor,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      fontSize: objfun.FontLow -
                                                          2,
                                                      letterSpacing: 0.3),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 15,
                                                  left: 5,
                                                  right: 5,
                                                  bottom: 5),
                                              child: Text(
                                                "Today",
                                                textAlign: TextAlign.left,
                                                style:
                                                GoogleFonts.lato(
                                                  textStyle: TextStyle(
                                                      color: colour.commonColor,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      fontSize: objfun.FontLow -
                                                          2,
                                                      letterSpacing: 0.3),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(5),
                                              child: Text(
                                                "Yesterday",
                                                textAlign: TextAlign.left,
                                                style:
                                                GoogleFonts.lato(
                                                  textStyle: TextStyle(
                                                      color: colour.commonColor,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      fontSize: objfun.FontLow -
                                                          2,
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
                                                "Weekly",
                                                textAlign: TextAlign.left,
                                                style:
                                                GoogleFonts.lato(
                                                  textStyle: TextStyle(
                                                      color: colour.commonColor,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      fontSize: objfun.FontLow -
                                                          2,
                                                      letterSpacing: 0.3),
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                                child: Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                      top: 5,
                                                      left: 5,
                                                      right: 5,
                                                      bottom: 15),
                                                  child: Text(
                                                    "Monthly",
                                                    textAlign: TextAlign.left,
                                                    style: GoogleFonts
                                                        .lato(
                                                      textStyle:
                                                      TextStyle(
                                                          color: colour
                                                              .commonColor,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          fontSize: objfun
                                                              .FontLow - 2,
                                                          letterSpacing:
                                                          0.3),
                                                    ),
                                                  ),
                                                ),
                                                onLongPress: () {


                                                }),
                                          ])),
                                  Expanded(
                                      flex: 1,
                                      child: Column(children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 15,
                                              left: 5,
                                              right: 5,
                                              bottom: 5),
                                          child: Text('Total',
                                            style: GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  color: colour.commonColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: objfun.FontLow - 2,
                                                  letterSpacing: 0.3),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 15,
                                              left: 5,
                                              right: 5,
                                              bottom: 5),
                                          child: Text(
                                            state.SaleFWReport.isEmpty
                                                ? '0'
                                                : state
                                                .SaleFWReport[0]["TodayCount"]
                                                .toStringAsFixed(0),
                                            style: GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  color: colour.commonColor,
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
                                            state.SaleFWReport.isEmpty
                                                ? '0'
                                                : state
                                                .SaleFWReport[0]["YesterdayCount"]
                                                .toStringAsFixed(0),
                                            style: GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  color: colour.commonColor,
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
                                            state.SaleFWReport.isEmpty
                                                ? '0'
                                                : state
                                                .SaleFWReport[0]["WeekCount"]
                                                .toStringAsFixed(0),
                                            style: GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  color: colour.commonColor,
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
                                            state.SaleFWReport.isEmpty
                                                ? '0'
                                                : state
                                                .SaleFWReport[0]["MonthCount"]
                                                .toStringAsFixed(0),
                                            style: GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  color: colour.commonColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: objfun.FontLow - 2,
                                                  letterSpacing: 0.3),
                                            ),
                                          ),
                                        ),
                                      ])),
                                  Expanded(
                                      flex: 1,
                                      child: Column(children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 15,
                                              left: 5,
                                              right: 5,
                                              bottom: 5),
                                          child: Text('With',
                                            style: GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  color: colour.commonColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: objfun.FontLow - 2,
                                                  letterSpacing: 0.3),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 15,
                                              left: 5,
                                              right: 5,
                                              bottom: 5),
                                          child: Text(
                                            state.SaleFWReport.isEmpty
                                                ? '0'
                                                : state
                                                .SaleFWReport[0]["TodayWithRelease"]
                                                .toStringAsFixed(0),
                                            style: GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  color: colour.commonColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: objfun.FontLow - 2,
                                                  letterSpacing: 0.3),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 5, bottom: 5),
                                          child: Text(state.SaleFWReport.isEmpty
                                              ? '0'
                                              : state
                                              .SaleFWReport[0]["YesterdayWithRelease"]
                                              .toStringAsFixed(0),
                                            style: GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  color: colour.commonColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: objfun.FontLow - 2,
                                                  letterSpacing: 0.3),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 5, bottom: 5),
                                          child: Text(state.SaleFWReport.isEmpty
                                              ? '0'
                                              : state
                                              .SaleFWReport[0]["WeekWithRelease"]
                                              .toStringAsFixed(0),
                                            style: GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  color: colour.commonColor,
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
                                          child: Text(state.SaleFWReport.isEmpty
                                              ? '0'
                                              : state
                                              .SaleFWReport[0]["MonthWithRelease"]
                                              .toStringAsFixed(0),
                                            style: GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  color: colour.commonColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: objfun.FontLow - 2,
                                                  letterSpacing: 0.3),
                                            ),
                                          ),
                                        ),
                                      ])),
                                  Expanded(
                                      flex: 2,
                                      child: Column(children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 15,
                                              left: 5,
                                              right: 5,
                                              bottom: 5),
                                          child: Text('Without',
                                            style: GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  color: colour.commonColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: objfun.FontLow - 2,
                                                  letterSpacing: 0.3),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 15,
                                              left: 5,
                                              right: 5,
                                              bottom: 5),
                                          child: Text(
                                            state.SaleFWReport.isEmpty
                                                ? '0'
                                                : state
                                                .SaleFWReport[0]["TodayRelease"]
                                                .toStringAsFixed(0),
                                            style: GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  color: colour.commonColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: objfun.FontLow - 2,
                                                  letterSpacing: 0.3),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 5, bottom: 5),
                                          child: Text(state.SaleFWReport.isEmpty
                                              ? '0'
                                              : state
                                              .SaleFWReport[0]["YesterdayRelease"]
                                              .toStringAsFixed(0),
                                            style: GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  color: colour.commonColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: objfun.FontLow - 2,
                                                  letterSpacing: 0.3),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 5, bottom: 5),
                                          child: Text(state.SaleFWReport.isEmpty
                                              ? '0'
                                              : state
                                              .SaleFWReport[0]["WeekRelease"]
                                              .toStringAsFixed(0),
                                            style: GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  color: colour.commonColor,
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
                                          child: Text(state.SaleFWReport.isEmpty
                                              ? '0'
                                              : state
                                              .SaleFWReport[0]["MonthRelease"]
                                              .toStringAsFixed(0),
                                            style: GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  color: colour.commonColor,
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
                            height: height * 0.03,),
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
                                      state.loadFWdata(
                                          state.dtpFromDate, state.dtpToDate);
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
                                      state.loadFWdata(
                                          state.dtpFromDate, state.dtpToDate);
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
                          SizedBox(
                            height: height * 0.30,
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
                                                top: 35,
                                                left: 5,
                                                right: 5,
                                                bottom: 5),
                                            child: Text(
                                              "K1",
                                              textAlign: TextAlign.left,
                                              style:
                                              GoogleFonts.lato(
                                                textStyle: TextStyle(
                                                    color: colour.commonColor,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    fontSize: objfun.FontLow -
                                                        2,
                                                    letterSpacing: 0.3),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 25,
                                                left: 5,
                                                right: 5,
                                                bottom: 5),
                                            child: Text(
                                              "K2",
                                              textAlign: TextAlign.left,
                                              style:
                                              GoogleFonts.lato(
                                                textStyle: TextStyle(
                                                    color: colour.commonColor,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    fontSize: objfun.FontLow -
                                                        2,
                                                    letterSpacing: 0.3),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 25,
                                                left: 5,
                                                right: 5,
                                                bottom: 5),
                                            child: Text(
                                              "K3",
                                              textAlign: TextAlign.left,
                                              style:
                                              GoogleFonts.lato(
                                                textStyle: TextStyle(
                                                    color: colour.commonColor,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    fontSize: objfun.FontLow -
                                                        2,
                                                    letterSpacing: 0.3),
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                              child: Padding(
                                                padding:
                                                const EdgeInsets.only(
                                                    top: 25,
                                                    left: 5,
                                                    right: 5,
                                                    bottom: 15),
                                                child: Text(
                                                  "K8",
                                                  textAlign: TextAlign.left,
                                                  style: GoogleFonts
                                                      .lato(
                                                    textStyle:
                                                    TextStyle(
                                                        color: colour
                                                            .commonColor,
                                                        fontWeight:
                                                        FontWeight
                                                            .bold,
                                                        fontSize: objfun
                                                            .FontLow - 2,
                                                        letterSpacing:
                                                        0.3),
                                                  ),
                                                ),
                                              ),
                                              onLongPress: () {


                                              }),
                                        ])),
                                Expanded(
                                    flex: 1,
                                    child: Column(children: <Widget>[

                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 35,
                                            left: 5,
                                            right: 5,
                                            bottom: 5),
                                        child: Text(
                                          state.SaleFWReport2.isEmpty ? '0' :
                                          state.SaleFWReport2[0]["K1Count"]
                                              .toString(),
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                color: colour.commonColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: objfun.FontLow - 2,
                                                letterSpacing: 0.3),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 25, bottom: 5),
                                        child: Text(
                                          state.SaleFWReport2.isEmpty ? '0' :
                                          state.SaleFWReport2[0]["K2Count"]
                                              .toString(),
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                color: colour.commonColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: objfun.FontLow - 2,
                                                letterSpacing: 0.3),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 25, bottom: 5),
                                        child: Text(
                                          state.SaleFWReport2.isEmpty ? '0' :
                                          state.SaleFWReport2[0]["K3Count"]
                                              .toString(),
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                color: colour.commonColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: objfun.FontLow - 2,
                                                letterSpacing: 0.3),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 25,
                                            left: 5,
                                            right: 5,
                                            bottom: 15),
                                        child: Text(
                                          state.SaleFWReport2.isEmpty ? '0' :
                                          state.SaleFWReport2[0]["K8Count"]
                                              .toString(),
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                color: colour.commonColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: objfun.FontLow - 2,
                                                letterSpacing: 0.3),
                                          ),
                                        ),
                                      ),
                                    ])),
                                Expanded(
                                    flex: 1,
                                    child: Column(children: <Widget>[

                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 35,
                                            left: 5,
                                            right: 5,
                                            bottom: 5),
                                        child: Text(
                                          state.SaleFWReport2.isEmpty ? '0' :
                                          state
                                              .SaleFWReport2[0]["K1WithRelease"]
                                              .toString(),
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                color: colour.commonColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: objfun.FontLow - 2,
                                                letterSpacing: 0.3),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 25, bottom: 5),
                                        child: Text(state.SaleFWReport2.isEmpty
                                            ? '0'
                                            : state
                                            .SaleFWReport2[0]["K2WithRelease"]
                                            .toString(),
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                color: colour.commonColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: objfun.FontLow - 2,
                                                letterSpacing: 0.3),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 25, bottom: 5),
                                        child: Text(state.SaleFWReport2.isEmpty
                                            ? '0'
                                            : state
                                            .SaleFWReport2[0]["K3WithRelease"]
                                            .toString(),
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                color: colour.commonColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: objfun.FontLow - 2,
                                                letterSpacing: 0.3),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 25,
                                            left: 5,
                                            right: 5,
                                            bottom: 15),
                                        child: Text(state.SaleFWReport2.isEmpty
                                            ? '0'
                                            : state
                                            .SaleFWReport2[0]["K8WithRelease"]
                                            .toString(),
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                color: colour.commonColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: objfun.FontLow - 2,
                                                letterSpacing: 0.3),
                                          ),
                                        ),
                                      ),
                                    ])),
                                Expanded(
                                    flex: 2,
                                    child: Column(children: <Widget>[

                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 35,
                                            left: 5,
                                            right: 5,
                                            bottom: 5),
                                        child: Text(
                                          state.SaleFWReport2.isEmpty ? '0' :
                                          state.SaleFWReport2[0]["K1Release"]
                                              .toString(),
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                color: colour.commonColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: objfun.FontLow - 2,
                                                letterSpacing: 0.3),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 25, bottom: 5),
                                        child: Text(state.SaleFWReport2.isEmpty
                                            ? '0'
                                            : state
                                            .SaleFWReport2[0]["K2Release"]
                                            .toString(),
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                color: colour.commonColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: objfun.FontLow - 2,
                                                letterSpacing: 0.3),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 25, bottom: 5),
                                        child: Text(state.SaleFWReport2.isEmpty
                                            ? '0'
                                            : state
                                            .SaleFWReport2[0]["K3Release"]
                                            .toString(),
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                color: colour.commonColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: objfun.FontLow - 2,
                                                letterSpacing: 0.3),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 25,
                                            left: 5,
                                            right: 5,
                                            bottom: 15),
                                        child: Text(state.SaleFWReport2.isEmpty
                                            ? '0'
                                            : state
                                            .SaleFWReport2[0]["K8Release"]
                                            .toString(),
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                color: colour.commonColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: objfun.FontLow - 2,
                                                letterSpacing: 0.3),
                                          ),
                                        ),
                                      ),
                                    ])),
                              ],
                            ),
                          )
                        ],
                      )),
                  Padding(
                      padding: const EdgeInsets.only(
                          top: 15.0, left: 10.0, right: 10.0),
                      child: ListView(
                        children: [
                          const SizedBox(height: 7,),
                          Center(child: Text('EXPENSE REPORT', style:
                          GoogleFonts.lato(
                            textStyle: TextStyle(
                                color: colour.commonColorred,
                                fontWeight:
                                FontWeight.bold,
                                fontSize: objfun.FontLarge,
                                letterSpacing: 0.3),),),),
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
                                                  bottom: 5),
                                              child: Text(
                                                "Today",
                                                textAlign: TextAlign.left,
                                                style:
                                                GoogleFonts.lato(
                                                  textStyle: TextStyle(
                                                      color: colour.commonColor,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      fontSize: objfun.FontLow -
                                                          2,
                                                      letterSpacing: 0.3),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(5),
                                              child: Text(
                                                "Yesterday",
                                                textAlign: TextAlign.left,
                                                style:
                                                GoogleFonts.lato(
                                                  textStyle: TextStyle(
                                                      color: colour.commonColor,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      fontSize: objfun.FontLow -
                                                          2,
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
                                                "Weekly",
                                                textAlign: TextAlign.left,
                                                style:
                                                GoogleFonts.lato(
                                                  textStyle: TextStyle(
                                                      color: colour.commonColor,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      fontSize: objfun.FontLow -
                                                          2,
                                                      letterSpacing: 0.3),
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                                child: Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                      top: 5,
                                                      left: 5,
                                                      right: 5,
                                                      bottom: 15),
                                                  child: Text(
                                                    "Monthly",
                                                    textAlign: TextAlign.left,
                                                    style: GoogleFonts
                                                        .lato(
                                                      textStyle:
                                                      TextStyle(
                                                          color: colour
                                                              .commonColor,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          fontSize: objfun
                                                              .FontLow - 2,
                                                          letterSpacing:
                                                          0.3),
                                                    ),
                                                  ),
                                                ),
                                                onLongPress: () {


                                                }),
                                          ])),
                                  Expanded(
                                      flex: 1,
                                      child: Column(children: <Widget>[

                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 15,
                                              left: 5,
                                              right: 5,
                                              bottom: 5),
                                          child: Text(
                                            state.SaleExpReport.isEmpty
                                                ? '0'
                                                : (state
                                                .SaleExpReport[0]["TodaySales"] ?? 0 )
                                                .toStringAsFixed(0),
                                            style: GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  color: colour.commonColor,
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
                                            state.SaleExpReport.isEmpty
                                                ? '0'
                                                :( state
                                                .SaleExpReport[0]["YesterdaySales"] ?? 0)
                                                .toStringAsFixed(0),
                                            style: GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  color: colour.commonColor,
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
                                            state.SaleExpReport.isEmpty
                                                ? '0'
                                                :( state
                                                .SaleExpReport[0]["WeekSales"] ?? 0 )
                                                .toStringAsFixed(0),
                                            style: GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  color: colour.commonColor,
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
                                            state.SaleExpReport.isEmpty
                                                ? '0'
                                                :( state
                                                .SaleExpReport[0]["MonthSales"] ?? 0)
                                                .toStringAsFixed(0),
                                            style: GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  color: colour.commonColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: objfun.FontLow - 2,
                                                  letterSpacing: 0.3),
                                            ),
                                          ),
                                        ),
                                      ])),
                                  Expanded(
                                      flex: 2,
                                      child: Column(children: <Widget>[

                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 15,
                                              left: 5,
                                              right: 5,
                                              bottom: 5),
                                          child: Text(
                                            state.SaleExpReport.isEmpty
                                                ? '0'
                                                :( state
                                                .SaleExpReport[0]["TodayAmount"]??0)
                                                .toStringAsFixed(0),
                                            style: GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  color: colour.commonColor,
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
                                            state.SaleExpReport.isEmpty
                                                ? '0'
                                                :( state
                                                .SaleExpReport[0]["YesterdayAmount"] ?? 0)
                                                .toStringAsFixed(0),
                                            style: GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  color: colour.commonColor,
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
                                            state.SaleExpReport.isEmpty
                                                ? '0'
                                                : (state
                                                .SaleExpReport[0]["WeekAmount"] ?? 0)
                                                .toStringAsFixed(0),
                                            style: GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  color: colour.commonColor,
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
                                            state.SaleExpReport.isEmpty
                                                ? '0'
                                                :( state
                                                .SaleExpReport[0]["MonthAmount"]?? 0)
                                                .toStringAsFixed(0),
                                            style: GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  color: colour.commonColor,
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
                            height: height * 0.03,),
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
                                            state.dtpEFromDate.toString())),
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
                                        state.dtpEFromDate =
                                            DateFormat("yyyy-MM-dd")
                                                .format(datenew);
                                      });
                                      state.loadExpdata(
                                          state.dtpEFromDate, state.dtpEToDate);
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
                                        state.dtpEToDate.toString())),
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
                                        state.dtpEToDate =
                                            DateFormat("yyyy-MM-dd")
                                                .format(datenew);
                                      });
                                      state.loadExpdata(
                                          state.dtpEFromDate, state.dtpEToDate);
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
                          SizedBox(
                              height: height * 0.50,
                              child: ListView.builder(
                                  itemCount:
                                  state.SaleExpReport2.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                        var item = state.SaleExpReport2[index];
                                    return SizedBox(
                                        height: height * 0.05,
                                        child: InkWell(
                                          onTap: () {
                                            state.loadExpenseDetails(
                                              item["ExpenseName"],
                                              state.dtpEFromDate,
                                              state.dtpEToDate,
                                            );
                                          },
                                          child: Card(

                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      flex: 3,
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
                                                                " ${state
                                                                    .SaleExpReport2[index]["ExpenseName"]}",
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
                                                                    .SaleExpReport2[index]["ExpCount"]
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
                                                                    .SaleExpReport2[index]["ExpAmount"]
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
                          Center(child: Text('TRANSPORT REPORT', style:
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
                  Container(child: Column(children: [
                  /*  SizedBox(
                      height: height * 0.10,
                    ),
                    Container(
                        height: height * 0.15,
                        color: colour.commonColorLight,
                        padding: EdgeInsets.only(
                            left: 10, right: 10, bottom: 5),
                        child: InkWell(
                          child: Center(child: Text('SETUP'),), onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (
                              context) => Bluetoothpage()));
                        },)),
                    SizedBox(
                      height: height * 0.10,
                    ),
                    Container(
                      height: height * 0.15,
                      color: colour.commonColorLight,
                      padding: EdgeInsets.only(
                          left: 10, right: 10, bottom: 5),
                      child: InkWell(
                        child: Center(child: Text('TEST'),), onTap: () async {
                        await objfun.printdata([BarcodePrintModel(
                            "MALEVA", "SHIPNAME", "B0005000", "2025-05-04",
                            "WESTPORT")
                        ]);
                      },),),*/
                  ])),
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
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔍 Search Bar
                        TextField(
                          controller: state.searchController,
                          decoration: InputDecoration(
                            hintText: "Search bills, invoices...",
                            hintStyle: GoogleFonts.lato(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                            ),
                            prefixIcon: const Icon(Icons.search, color: Colors.deepOrange),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.arrow_forward_ios, color: Colors.deepOrange),
                              onPressed: () {
                                String value = state.searchController.text.trim();
                                state.loadBOC(value);
                              },
                            ),
                            filled: true,
                            fillColor: Colors.orange.shade50,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(22),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: GoogleFonts.lato(
                            color: Colors.black87,
                            fontSize: 17,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 📋 Show Results
                        if (state.boDetails.isNotEmpty)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.boDetails.length,
                            itemBuilder: (context, index) {
                              final data = state.boDetails[index];
                              final masters = data.masters;
                              final details = data.details;
                              final uniqueProducts = details.map((d) => d.productName).toSet().toList();
                              return Column(
                                children: masters.map<Widget>((master) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(vertical: 10),
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.white, Colors.orange.shade50],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child:Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // 🔹 Bill No + Status
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.receipt_long,
                                                  color: Colors.deepOrange, size: 26),
                                              const SizedBox(width: 10),
                                              Text(
                                                master.billNoDisplay,
                                                style: GoogleFonts.lato(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding:
                                            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: master.billStatus == "Open"
                                                  ? Colors.green.shade100
                                                  : Colors.red.shade100,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              master.billStatus,
                                              style: GoogleFonts.lato(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: master.billStatus == "Open"
                                                    ? Colors.green.shade700
                                                    : Colors.red.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 20),

                                      // 🔹 Supplier
                                      _buildPremiumRow(
                                        Icons.store,
                                        Colors.deepOrange,
                                        master.supplierName,
                                      ),

                                      const SizedBox(height: 20),

                                      // 🔹 Employee
                                      _buildPremiumRow(
                                        Icons.person,
                                        Colors.blue,
                                        master.employeeName,
                                      ),

                                      const SizedBox(height: 20),

                                      // 🔹 Invoice Info
                                      _buildPremiumRow(
                                        Icons.description,
                                        Colors.indigo,
                                        null,
                                        richText: RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: "Invoice: ",
                                                style: GoogleFonts.lato(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              TextSpan(
                                                text: "${master.invoiceNo}   ",
                                                style: GoogleFonts.lato(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              TextSpan(
                                                text: "(${master.invoiceDate})",
                                                style: GoogleFonts.lato(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      // 🔹 Net Amount
                                      _buildPremiumRow(
                                        Icons.attach_money,
                                        Colors.green,
                                        "Net: ₹${master.netAmt.toStringAsFixed(2)}",
                                        isHighlight: true,
                                      ),

                                      const Divider(color: Colors.black26, thickness: 0.7, height: 32),

                                      // 🔹 Description
                                      _buildPremiumRow(
                                        Icons.description,
                                        Colors.indigo,
                                        "Description: ${master.description}",
                                      ),

                                      const Divider(color: Colors.black26, thickness: 0.7, height: 32),

                                      // 📦 Order Details
                                      if (details.isNotEmpty)
                                        Column(
                                          children: details.map<Widget>((d) {
                                            return Container(
                                              margin: const EdgeInsets.only(bottom: 16),
                                              padding: const EdgeInsets.all(14),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.shade50.withOpacity(0.9),
                                                borderRadius: BorderRadius.circular(14),
                                                border: Border.all(color: Colors.orange.shade200, width: 0.8),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.orange.shade100.withOpacity(0.4),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),

                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    d.productName,
                                                    style: GoogleFonts.lato(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w700,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  if (d.RemarksD != null && d.RemarksD!.isNotEmpty)
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 6),
                                                      child: Text(
                                                        "Remarks: ${d.RemarksD}",
                                                        style: GoogleFonts.lato(
                                                          fontSize: 13,
                                                          color: Colors.grey[700],
                                                          fontStyle: FontStyle.italic,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                    ],
                                  ),

                                  );
                                }).toList(), // ✅ FIXED here
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                  //Email-Inbox
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        // 🔻 Employee Dropdown
                        DropdownButtonFormField<EmployeeModel>(
                          isExpanded: true,
                          value: state._selectedEmployee,
                          decoration: InputDecoration(
                            labelText: "Select Employee",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: state._employees.map((emp) {
                            return DropdownMenuItem(
                              value: emp,
                              child: Text(emp.AccountName, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (value) {
                            state.setState(() =>state._selectedEmployee = value);
                            if (value != null) state.loadEmails(value.Id);
                          },
                        ),
                        const SizedBox(height: 16),

                        // 🔻 Emails List
                        Expanded(
                          child: ListView.builder(
                            itemCount: state.emails.length,
                            itemBuilder: (context, index) {
                              final email = state.emails[index];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 3,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Top row: Name + Date
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            email.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            email.receivedDate.toLocal().toString().split('.').first,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),

                                      Text(
                                        email.subject,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),

                                      Text(
                                        "From: ${email.sender}",
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      // Checkbox row
                                      Wrap(
                                        spacing: 12, // horizontal spacing
                                        runSpacing: 4, // vertical spacing
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Checkbox(
                                                value: email.isActive,
                                                onChanged: (v) {
                                                  state.setState(() {
                                                    state.emails[index] = email.copyWith(isActive: v ?? false);
                                                  });
                                                },
                                              ),
                                              const Text("Active"),
                                            ],
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Checkbox(
                                                value: email.isUnread,
                                                onChanged: (v) {
                                                  state.setState(() {
                                                    state.emails[index] = email.copyWith(isUnread: v ?? false);
                                                  });
                                                },
                                              ),
                                              const Text("read"),
                                            ],
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Checkbox(
                                                value: email.isReplied,
                                                onChanged: (v) {
                                                  state.setState(() {
                                                    state.emails[index] = email.copyWith(isReplied: v ?? false);
                                                  });
                                                },
                                              ),
                                              const Text("Replied"),
                                            ],
                                          ),
                                        ],
                                      )


                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 8),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.save),
                            label: const Text("Save Emails"),
                            onPressed: state.saveEmails,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                  //GoogleReviews
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () => FocusScope.of(context).unfocus(), // dismiss keyboard
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Form(
                              key: state._formKey,
                              child: Column(
                                children: [
                                  // Shop Name
                                  TextFormField(
                                    controller: state._shopCtrl,
                                    decoration: const InputDecoration(labelText: 'Company Name'),
                                    validator: (v) => v!.isEmpty ? 'Enter Company Name' : null,
                                  ),
                                  const SizedBox(height: 10),

                                  // Mobile No
                                  // control this dynamically

                                  Visibility(
                                    visible: state._showMobileField, // true → show, false → hide
                                    child: Column(
                                      children: [
                                        TextFormField(
                                          controller: state._mobileCtrl,
                                          decoration: const InputDecoration(labelText: 'Mobile No'),
                                          keyboardType: TextInputType.phone,
                                        ),
                                        const SizedBox(height: 10),
                                      ],
                                    ),
                                  ),

                                  // Google Review Dropdown (1-5)
                                  DropdownButtonFormField<int>(
                                    value: (state._selectedReview >= 1 && state._selectedReview <= 5) ? state._selectedReview : 1,
                                    isExpanded: true,
                                    items: List.generate(5, (index) => index + 1)
                                        .map((val) => DropdownMenuItem<int>(
                                      value: val,
                                      child: Text(val.toString()),
                                    ))
                                        .toList(),
                                    onChanged: (val) {
                                      state.setState(() {
                                        state._selectedReview = val!;
                                      });
                                    },
                                    decoration: const InputDecoration(labelText: 'Google Review'),
                                    validator: (v) => v == null ? 'Select Review' : null,
                                  ),
                                  const SizedBox(height: 10),

                                  // Google Review Message
                                  TextFormField(
                                    controller: state._reviewMsgCtrl,
                                    decoration: const InputDecoration(labelText: 'Google Review Message'),
                                  ),
                                  const SizedBox(height: 16),

                                  // Employee Dropdown
                                  DropdownButtonFormField<int>(
                                    value: state._employees.any((e) => e.Id == state._selectedEmpId) ? state._selectedEmpId : null,
                                    isExpanded: true,
                                    items: state._employees.map((e) => DropdownMenuItem<int>(
                                      value: e.Id,
                                      child: Text(e.AccountName),
                                    )).toList(),
                                    onChanged: (int? v) => state.setState(() => state._selectedEmpId = v),
                                    decoration: const InputDecoration(labelText: 'Employee'),
                                    validator: (v) => v == null ? 'Select Employee' : null,
                                  ),
                                  const SizedBox(height: 16),

                                  // Date Picker
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Date: ${DateFormat('yyyy-MM-dd').format(state._selectedDate)}',
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.date_range),
                                        onPressed: () async {
                                          final picked = await showDatePicker(
                                            context: context,
                                            initialDate: state._selectedDate,
                                            firstDate: DateTime(2020),
                                            lastDate: DateTime(2100),
                                          );
                                          if (picked != null) {
                                            state.setState(() => state._selectedDate = picked);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  // Buttons: Save + View
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: state._saveReview,
                                          child: const Text('Save'),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            // Navigate to ReviewGridScreen
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (_) => const ReviewGridScreen()),
                                            );
                                            // If reviews were modified, optionally refresh current form
                                            if (result == true) state._loadEmployee(); // reload employees if needed
                                          },
                                          child: const Text('View'),
                                        ),
                                      ),
                                    ],
                                  ),

                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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

                              return InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => Dialog(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // Header
                                                Container(
                                                  padding: EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blueGrey.shade50,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Text(driverName,
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.blueGrey)),
                                                      Text(truckName,
                                                          style:
                                                          TextStyle(fontSize: 16, color: Colors.grey[700])),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 10),
                                                Divider(),

                                                // Info rows with icons
                                                _infoRow(Icons.person, "Driver Name", driverName),
                                                _infoRow(Icons.local_shipping, "Truck Name", truckName),
                                                _infoRow(Icons.calendar_month, "Fuel Date", record.sSaleDate ?? "-"),
                                                _infoRow(Icons.local_gas_station, "P Rate", record.pRate.toString()),
                                                _infoRow(Icons.local_gas_station, "P Litre", record.pliter.toString()),
                                                _infoRow(Icons.currency_rupee, "P Amount", "₹${record.pAmount}"),
                                                _infoRow(Icons.check_circle, "A Amount", "₹${aAmount.toStringAsFixed(2)}"),
                                                _infoRow(Icons.format_list_numbered, "A Liter", "${aliter.toStringAsFixed(2)} L"),
                                                _infoRow(Icons.attach_money, "G Amount", "₹${gAmount.toStringAsFixed(2)}"),
                                                _infoRow(Icons.local_gas_station_rounded, "G Liter", "${gliter.toStringAsFixed(2)} L"),
                                                _infoRow(Icons.balance, "Diff Liter", record.dPliter.toString()),
                                                _infoRow(Icons.money_off, "Diff Amount", record.dPAmount.toString()),
                                                _infoRow(Icons.note, "Remarks", record.remarks.toString()),

                                                SizedBox(height: 15),

                                                // Close button
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: ElevatedButton.icon(
                                                    icon: Icon(Icons.close),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.redAccent,
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    onPressed: () => Navigator.pop(context),
                                                    label: Text("Close"),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },

                                  child: Container(
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
                    child: _buildEmployeeViewTab(state),
                  ),
                  Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              // Header
              Text(
                "Petty Cash",
                style: GoogleFonts.lato(
                  fontSize: objfun.FontLarge,
                  fontWeight: FontWeight.bold,
                  color: colour.commonColor,
                ),
              ),

              const SizedBox(height: 10),

              // Date selectors + View button
              Row(
                children: [
                  Expanded(
                    child: Text(
                      DateFormat("dd-MM-yy").format(state.fromDate!),
                      style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_month_outlined),
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: state.fromDate!,
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2050));
                      if (picked != null) {
                        state.setState(() {
                          state.fromDate = picked;
                        });
                      }
                    },
                  ),
                  Expanded(
                    child: Text(
                      DateFormat("dd-MM-yy").format(state.toDate!),
                      style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_month_outlined),
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: state.toDate!,
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2050));
                      if (picked != null) {
                        state.setState(() {
                          state.toDate = picked;
                        });
                      }
                    },
                  ),
                  ElevatedButton(
                    onPressed: state.loadpettycash,
                    child: const Text("View"),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // List of Petty Cash records
              Expanded(
                child: state.progress
                    ? state.pettycashMaster.isNotEmpty
                    ? ListView.builder(
                  itemCount: state.pettycashMaster.length,
                  itemBuilder: (context, index) {
                    final master = state.pettycashMaster[index];

                    // Get related details for this master record
                    final relatedDetails = state.pettycashDetails
                        .where((d) => d.pettyCashMasterRefId == master.Id)
                        .toList();

                    return InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(master.employeeName ?? "-",
                                        style: GoogleFonts.lato(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                        "C Number: ${master.cNumberDisplay ?? "-"}"),
                                    Text(
                                        "Date: ${DateFormat('dd-MM-yyyy').format(master.pettyCashDate)}"),
                                    Text(
                                        "Payment Status: ${master.paymentStatus ?? "-"}"),
                                    Text("Amount: ₹${master.amount ?? "-"}"),
                                    const SizedBox(height: 10),
                                    Divider(),
                                    Text("Details:",
                                        style: GoogleFonts.lato(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 6),

                                    if (relatedDetails.isNotEmpty)
                                      ...relatedDetails.map(
                                            (detail) => Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text("Item: ${detail.items ?? "-"}"),
                                            Text(
                                                "Notes: ${detail.notes ?? "-"}"),
                                            Text(
                                                "Amount: ₹${detail.amount ?? "-"}"),
                                            const Divider(),
                                          ],
                                        ),
                                      ),

                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.close),
                                        label: const Text("Close"),
                                        onPressed: () =>
                                            Navigator.pop(context),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                            Colors.redAccent),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.shade100.withOpacity(0.6),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                          border: Border.all(
                              color: Colors.orange.shade200, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(master.employeeName ?? "-",
                                style: GoogleFonts.lato(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            Text(master.cNumberDisplay ?? "-"),
                            Text(DateFormat('dd-MM-yyyy')
                                .format(master.pettyCashDate)),
                          ],
                        ),
                      ),
                    );
                  },
                )
                    : const Center(
                  child: Text("No records found"),
                )
                    : const Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Form(
                        key: state._formKey,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Truck Dropdown
                              SizedBox(
                                height: 60,
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: "Truck Name",
                                    border: OutlineInputBorder(),
                                  ),
                                  value: state.selectedTruck,
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

                              // Date Picker
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
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: state.selectedDate ?? DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );

                                    if (pickedDate != null) {
                                      state.setState(() {
                                        state.selectedDate = pickedDate;
                                        state.dateController.text =
                                            DateFormat('yyyy-MM-dd').format(pickedDate);
                                      });
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please select a date";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              // ---------- Country Selection Radio ----------
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Text("Select Country",
                                  //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  // ),
                                  Row(
                                    children: [
                                      Radio<String>(
                                        value: "Malaysia",
                                        groupValue: state.selectedCountry,
                                        onChanged: (value) {
                                          state.setState(() {
                                            state.selectedCountry = value!;
                                            state.selectedSummon = null;
                                          });
                                        },
                                      ),
                                      Text("Malaysia"),
                                      SizedBox(width: 20),
                                      Radio<String>(
                                        value: "Singapore",
                                        groupValue: state.selectedCountry,
                                        onChanged: (value) {
                                          state.setState(() {
                                            state.selectedCountry = value!;
                                            state.selectedSummon = null;
                                          });
                                        },
                                      ),
                                      Text("Singapore"),
                                    ],
                                  ),
                                ],
                              ),

                              SizedBox(height: 16),


                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: "Summon Type",
                                  border: OutlineInputBorder(),
                                ),
                                value: state.selectedSummon,
                                items: (state.selectedCountry == "Malaysia"
                                    ? state.malaysiaList
                                    : state.singaporeList)
                                    .map((item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                ))
                                    .toList(),
                                onChanged: (value) {
                                  state.setState(() {
                                    state.selectedSummon = value!;
                                    state.SummonTypeController.text = value; // store into your text field
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please select summon type";
                                  }
                                  return null;
                                },
                              ),


                              SizedBox(height: 16),
                              buildInputField("Amount", state.amountController,
                                  "Please enter amount",
                                  isNumber: true),
                              SizedBox(height: 16),
                              buildInputField("PortPass", state.PortPassController,
                                  "Please enter PortPass"),
                              SizedBox(height: 16),
                              buildInputField("TruckLcnMnt", state.TruckLcnMntController,
                                  "Please enter TruckLcnMnt"),
                              SizedBox(height: 16),
                              buildInputField("Levy", state.LevyController,
                                  "Please enter Levy"),
                              SizedBox(height: 16),
                              buildInputField("Fuel", state.FuelController,
                                  "Please enter Fuel"),
                              SizedBox(height: 16),




                              // Upload Document
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),


                                onPressed: () async {
                                  final XFile? pickedFile =
                                  await state._picker.pickImage(
                                      source: ImageSource.gallery);

                                  if (pickedFile != null) {
                                    String path = pickedFile.path.toLowerCase();
                                    state.setState(() {
                                      if (path.endsWith(".pdf")) {
                                        state._pickedPDF = File(pickedFile.path);
                                        state._pickedImage = null;
                                      } else {
                                        state._pickedImage = File(pickedFile.path);
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
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              SizedBox(height: 20),

                              // Preview Section
                              if (state._pickedImage != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Preview:",
                                      style: TextStyle(
                                          fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 10),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        state._pickedImage!,
                                        height: 180,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                  ],
                                )
                              else if (state._pickedPDF != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "PDF Selected:",
                                      style: TextStyle(
                                          fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 10),
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
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                  ],
                                ),

                              Row(
                                children: [
                                  // SUBMIT BUTTON
                                  Expanded(
                                    child: state._isLoading
                                        ? Center(child: CircularProgressIndicator())
                                        : ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: Size(double.infinity, 55),
                                        backgroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                      onPressed: () => state.submitData(context),
                                      child: Text(
                                        "Submit",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 12),

                                  // VIEW BUTTON
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: Size(double.infinity, 55),
                                        backgroundColor: Colors.blue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => SummonViewPage(
                                              fromDate: state.fromDate,
                                              toDate: state.toDate,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "View",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )


                            ]
                        ),
                      ),
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

                                    SizedBox(height: 18),

                                    buildInputField(" Amount", state.amountController,
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
                                            onPressed: () => state.submitData1(context),
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
                  Padding(
                      padding:  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child:Column(
                        children: [

                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: state.Inventoryfilters.map((f) {
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
                                : state.masterList1.isEmpty
                                ? const Center(
                              child: Text("No Records Found", style: TextStyle(fontSize: 16)),
                            )
                                : ListView.builder(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                itemCount: state.masterList1.length,
                                itemBuilder: (_, idx) {
                                  final item = state.masterList1[idx];
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
                                                _infoRow1("Off Vessel", item.offVesselName),
                                                _infoRow1("Loading Vessel", item.loadingVesselName),

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
                                                _infoRow1("Employee", item.employeeName),
                                                _infoRow1("ETA", item.eta),

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
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // 🔹 HEADING
                        Text(
                          "RTI Details",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 10),

                        // 🔹 SEARCH
                        TextField(
                          controller: state.searchController,
                          decoration: InputDecoration(
                            hintText: "Search RTI No / Driver / Truck",
                            prefixIcon: Icon(Icons.search),
                            contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) {
                            state.searchRTI(value);
                          },
                        ),

                        SizedBox(height: 12),

                        // 🔹 LIST
                        Expanded(
                          child: ListView.builder(
                            itemCount: state.filteredRTIMasterList.length,
                            itemBuilder: (context, index) {
                              final m = state.filteredRTIMasterList[index];
                              final detailsWithImage = objfun.RTIViewDetailList.where((d) =>
                              d.RTIMasterRefId == m.Id &&
                                  d.imagePath != null &&
                                  d.imagePath!.isNotEmpty
                              ).toList();

                              if (detailsWithImage.isEmpty) {
                                return SizedBox();
                              }
                              return Card(
                                margin: EdgeInsets.only(bottom: 10),
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ExpansionTile(
                                  tilePadding: EdgeInsets.all(12),
                                  childrenPadding:
                                  EdgeInsets.symmetric(horizontal: 12, vertical: 8),

                                  // 🔸 MASTER HEADER
                                  title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            m.RTINoDisplay,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            "RM${m.Amount}",
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        m.RTIDate,
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),

                                  // 🔸 EXPANDED CONTENT
                                  children: [

                                    // MASTER EXTRA INFO
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          infoRow("Driver", m.DriverName),
                                          infoRow("Truck", m.TruckName),
                                          infoRow("Remarks", m.Remarks),
                                          ElevatedButton(
                                              onPressed: (){
                                                state.selectedDetails = objfun.RTIViewDetailList.where((x) =>
                                                x.RTIMasterRefId == m.Id && x.isChecked
                                                ).map((x) => {
                                                  "Id" : x.StatusId,
                                                  "CompanyRefId" : objfun.Comid,
                                                  "RTIMasterRefId" : m.Id,
                                                  "RTIDetailsRefId" : x.Id,
                                                  "RTICNumberDisplay" : m.RTINoDisplay,
                                                  "DriverName" : m.DriverName,
                                                  "JobNumber" : x.JobNo,
                                                  "SaleOrderMasterRefId" : x.SaleOrderMasterRefId,
                                                  "CustomerMasterRefId" : x.CustomerMasterRefId,
                                                  "TruckMasterRefId" : m.TruckMasterRefId,
                                                  "DriverMasterRefId" : objfun.EmpRefId,
                                                  "TruckName" : m.TruckName,
                                                  "Verify": x.isVerified ? 1 : 0,
                                                  "ImagePath": x.imagePath,
                                                }).toList();
                                                state.SaveRTIData(context);

                                              },
                                              child: Text('Verify')
                                          )
                                        ],
                                      ),
                                    ),

                                    // DETAILS LIST
                                    ...objfun.RTIViewDetailList
                                        .where((d) =>
                                    d.RTIMasterRefId == m.Id)
                                        .map(
                                          (d) => Container(
                                        margin: EdgeInsets.only(top: 8),
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                          BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              d.JobNo,
                                              style: TextStyle(
                                                  fontWeight:
                                                  FontWeight.bold),
                                            ),
                                            SizedBox(height: 6),
                                            infoRow("Customer", d.CustomerName),
                                            Checkbox(value: d.isVerified,
                                                onChanged: (value){
                                                  state.setState((){
                                                    d.isVerified = value ?? false;
                                                    d.Verify = d.isVerified ? 1 : 0;
                                                  });
                                                }
                                            ),
                                            Wrap(
                                              spacing: 10,
                                              runSpacing: 10,
                                              children: [
                                                buildImage(d.imagePath, context),
                                              ],
                                            ),
                                            /* ElevatedButton(
                                                onPressed: (){
                                                  state.selectedDetails = objfun.RTIViewDetailList.where((x) =>
                                                  x.RTIMasterRefId == m.Id && x.isChecked
                                                  ).map((x) => {
                                                    "Id" : x.StatusId,
                                                    "CompanyRefId" : objfun.Comid,
                                                    "RTIMasterRefId" : m.Id,
                                                    "RTIDetailsRefId" : x.Id,
                                                    "RTICNumberDisplay" : m.RTINoDisplay,
                                                    "DriverName" : m.DriverName,
                                                    "JobNumber" : x.JobNo,
                                                    "SaleOrderMasterRefId" : x.SaleOrderMasterRefId,
                                                    "CustomerMasterRefId" : x.CustomerMasterRefId,
                                                    "TruckMasterRefId" : m.TruckMasterRefId,
                                                    "DriverMasterRefId" : objfun.EmpRefId,
                                                    "TruckName" : m.TruckName,
                                                    "Verify": x.isVerified ? 1 : 0,
                                                    "ImagePath": x.imagePath,
                                                  }).toList();
                                                  state.SaveRTIData(context);

                                                },
                                                child: Text('Verify')
                                            )*/

                                          ],
                                        ),
                                      ),
                                    )
                                        .toList(),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Column(
                        children: [
                          // ---------------- Filter Row ----------------
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: state.fromDate ?? DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    if (picked != null) state.setState(() => state.fromDate = picked);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      state.fromDate == null
                                          ? 'From Date'
                                          : DateFormat("dd/MM/yyyy").format(state.fromDate!),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: state.toDate ?? DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    if (picked != null) state.setState(() => state.toDate = picked);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      state.toDate == null
                                          ? 'To Date'
                                          : DateFormat("dd/MM/yyyy").format(state.toDate!),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  // Just call your existing function
                                  await state.LoadRTIDetails();
                                },
                                child: const Text('Search'),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // ---------------- ListView ----------------
                          Expanded(
                            child: ListView.builder(
                              itemCount: objfun.RTIViewMasterList.length,
                              itemBuilder: (context, index) {
                                final master = objfun.RTIViewMasterList[index];

                                final List<RTIDetailsViewModel> details =
                                objfun.RTIViewDetailList1
                                    .where((d) => d.RTIMasterRefId == master.Id)
                                    .toList();

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ExpansionTile(
                                    title: Text(master.DriverName),
                                    subtitle: Text(master.RTINoDisplay),
                                    trailing: Text(
                                      " ${master.RTIDate.toString()}",
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: _detailsGrid(details),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              bottomNavigationBar:
              state.Invoicewiseview ?
              Container(child: const Text(""),)
                  :
              Card(
                elevation: 6,
                color: colour.commonColorLight,
                //  margin: EdgeInsets.all(15),
                child: SalomonBottomBar(
                  duration: const Duration(seconds: 1),
                  items: [
                    SalomonBottomBarItem(
                        icon: const Icon(
                          Icons.receipt,
                          color: colour.commonColor,
                        ),
                        title: Text(
                          "All",
                          style: GoogleFonts.lato(textStyle: TextStyle(
                              color: colour.commonColor,
                              fontSize: width <= 370
                                  ? objfun.FontCardText + 2
                                  : objfun.FontLow),
                          ),)
                    ),
                    SalomonBottomBarItem(
                        icon: const Icon(
                          Icons.receipt_long,
                          color: colour.commonColor,
                        ),
                        title: Text(
                          "With",
                          style: GoogleFonts.lato(textStyle: TextStyle(
                              color: colour.commonColor,
                              fontSize: width <= 370
                                  ? objfun.FontCardText + 2
                                  : objfun.FontLow),
                          ),)

                    ),
                    SalomonBottomBarItem(
                      icon: const Icon(
                        Icons.receipt_long_outlined,
                        color: colour.commonColor,
                      ),
                      title: Text(
                          "Without",
                          style: GoogleFonts.lato(textStyle: TextStyle(
                              color: colour.commonColor,
                              fontSize: width <= 370
                                  ? objfun.FontCardText + 2
                                  : objfun.FontLow),)
                      ),

                    ),
                  ],
                  currentIndex: state._tabController.index,
                  onTap: (index) =>
                      state.setState(() {
                        state._tabController.index = index;
                        state.loaddata(index + 1);
                      }),
                ),
              )

          )));
}

Widget  _detailsGrid(List<RTIDetailsViewModel> details) {
  if (details.isEmpty) {
    return const Center(child: Text("No Details Found"));
  }

  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DataTable(
      headingRowColor:
      MaterialStateProperty.all(Colors.indigo.shade50),
      columns: const [
        DataColumn(label: Text("Job No")),
        DataColumn(label: Text("Job Date")),
        DataColumn(label: Text("Customer")),
        DataColumn(label: Text("Salary")),

      ],
      rows: details.map((d) {
        return DataRow(
          cells: [
            DataCell(Text(d.JobNo)),
            DataCell(Text(d.JobDate)),
            DataCell(Text(d.CustomerName)),
            DataCell(Text(d.Salary.toStringAsFixed(2))),

          ],
        );
      }).toList(),
    ),
  );
}
String formatDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) return '—';
  try {
    DateTime parsedDate = DateTime.parse(dateString);
    return DateFormat('dd/MM/yyyy').format(parsedDate);
  } catch (e) {
    return dateString;
  }
}
Widget _smallText(String text) {
  return Text(
    text,
    style: const TextStyle(color: Colors.black54, fontSize: 12),
  );
}
Widget _detailRow(String label, String? value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            "$label:",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text(
            value?.isNotEmpty == true ? value! : '—',
            style: TextStyle(color: Colors.grey.shade800),
          ),
        ),
      ],
    ),
  );
}
/// Info Row With Icon
Widget _infoRow(IconData icon, String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Icon(icon, size: 20, color: Colors.blueGrey),
        SizedBox(width: 10),
        Expanded(
          child: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
        ),
        Text(value, style: TextStyle(color: Colors.black87, fontSize: 15)),
      ],
    ),
  );
}
Widget _buildDetailRow(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Icon(icon, color: const Color(0xFF6A994E), ),
        const SizedBox(width: 8),
        Text(
          "$label:",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color:Color(0xFF2C3E50),),
          ),
        ),
      ],
    ),
  );
}
// 🔹 Helper Widget for bill info rows
Widget _infoChip(
    {required IconData icon, required String label, required String value}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.purple.shade50,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.purple.shade600, size: 16),
        SizedBox(width: 5),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.purple.shade800,
          ),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),
      ],
    ),
  );
}

Widget _buildPremiumRow(
    IconData icon,
    Color iconColor,
    String? text, {
      Widget? richText, // <-- add this optional param
      bool isHighlight = false,
    }) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: iconColor, size: 20),
      const SizedBox(width: 8),
      Expanded(
        child: richText ??
            Text(
              text ?? "",
              style: GoogleFonts.lato(
                fontSize: 15,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                color: isHighlight ? Colors.green.shade800 : Colors.black87,
              ),
            ),
      ),
    ],
  );
}
Widget _infoRow1(String label, String? value) {
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
Widget _buildEmployeeViewTab(AdminDashboardState state) {
  List<EmployeeDetailsModel> allLicenses = state.EmployeeViewRecords;
  List<EmployeeDetailsModel> filteredLicenses = List.from(allLicenses);

  return StatefulBuilder(
    builder: (context, setState) {
      return Container(
        color: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 Search Bar
            Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon:
                    Icon(Icons.search, color: Colors.purple.shade400),
                    hintText: 'Search Employee...',
                    border: InputBorder.none,
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  ),
                  onChanged: (query) {
                    setState(() {
                      if (query.isEmpty) {
                        filteredLicenses = List.from(allLicenses);
                      } else {
                        filteredLicenses = allLicenses
                            .where((license) =>
                        (license.EmployeeName ?? '')
                            .toLowerCase()
                            .contains(query.toLowerCase()) ||
                            (license.MobileNo ?? '')
                                .toLowerCase()
                                .contains(query.toLowerCase()))
                            .toList();
                      }
                    });
                  },
                ),
              ),
            ),

            // 🧾 Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Employee’s List",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.purple,
                      size: 28,
                    ),
                    tooltip: 'Add Employee',
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Addemployee()),
                      );

                      //

                      state.LoadEmployeeViewRecords();


                    },

                  ),

                ],
              ),
            ),

            // 🚗 Filtered List
            Expanded(
              child: filteredLicenses.isEmpty
                  ? Center(
                child: Text(
                  'No Employees found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              )
                  : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: filteredLicenses.length,
                itemBuilder: (context, index) {
                  final record = filteredLicenses[index];
                  final isActive = record.Active != 0;

                  final statusColor =
                  isActive ? Colors.green.shade600 : Colors.red.shade600;
                  final cardGradient = LinearGradient(
                    colors: isActive
                        ? [Colors.green.shade50, Colors.white]
                        : [Colors.red.shade50, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  );

                  return InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: Text(
                            record.EmployeeName ?? 'Employee Details',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _detailRow("Email", record.Email),
                                _detailRow("Employee Type", record.EmployeeType),
                                _detailRow("Currency", record.Employeecurrency),
                                _detailRow("Address 1", record.Address1),
                                _detailRow("Address 2", record.Address2),
                                _detailRow("City", record.City),
                                _detailRow("State", record.State),
                                _detailRow("Country", record.Country),
                                _detailRow("GST No", record.GSTNO),
                                _detailRow("User Name", record.UserName),
                                _detailRow(
                                    "Joining Date", formatDate(record.JoiningDate)),
                                _detailRow(
                                    "Leaving Date", formatDate(record.LeavingDate)),
                                _detailRow("Rules Type", record.RulesType),
                                _detailRow("Bank Name", record.BankName),
                                _detailRow("Account No", record.AccountNo),
                                _detailRow("Account Code", record.AccountCode),
                                _detailRow("Latitude", record.Latitude),
                                _detailRow("Longitude", record.longitude),
                                SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text("Close"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        gradient: cardGradient,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 👤 Header
                            Row(
                              children: [
                                Container(
                                  height: 45,
                                  width: 45,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.purple.shade100,
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.purple.shade700,
                                  ),
                                ),
                                SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        record.EmployeeName ?? 'Unknown Driver',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                      SizedBox(height: 3),
                                      Text(
                                        record.MobileNo ?? 'No phone info',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isActive ? Icons.check_circle : Icons.cancel,
                                        color: statusColor,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        isActive ? 'Active' : 'Inactive',
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 10),
                            Divider(),

                            // 📅 Info
                            // 📅 Info
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _infoChip(
                                  icon: Icons.calendar_today,
                                  label: "Joining Date",
                                  value: formatDate(record.JoiningDate) ?? '—',
                                ),
                                _infoChip(
                                  icon: Icons.event,
                                  label: "Leaving Date",
                                  value: formatDate(record.LeavingDate) ?? '—',
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

// ✏️ Edit & 🗑️ Delete Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // 🟣 Edit Button
                                TextButton.icon(
                                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                  label: const Text(
                                    "Edit",
                                    style: TextStyle(color: Colors.blueAccent),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Addemployee(
                                          existingEmployee: record, // 👈 pass selected employee
                                        ),
                                      ),
                                    );
                                    state.LoadEmployeeViewRecords();

                                  },
                                ),

                                const SizedBox(width: 8),

                                // 🔴 Delete Button
                                TextButton.icon(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  label: const Text(
                                    "Delete",
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text("Confirm Delete"),
                                        content: Text(
                                            "Are you sure you want to delete ${record.EmployeeName}?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context, true);
                                              // 🔥 Call your delete function here
                                              deleteEmployee(context, record.Id);
                                            },
                                            child: const Text(
                                              "Delete",
                                              style: TextStyle(color: Colors.redAccent),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),

                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            )

          ],
        ),
      );
    },
  );
}
Future<void> deleteEmployee(BuildContext context, int Id) async {
  var comid = objfun.storagenew.getInt('Comid') ?? 0;

  Map<String, String> header = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  try {
    final apiUrl = "${objfun.apiDeleteEmployeeType}$Id&Comid=$comid";

    final resultData = await objfun.apiAllinoneSelectArray(
      apiUrl,
      '',
      header,
      context,
    );
    if (resultData != null && resultData is String) {
      if (resultData.contains('Deleted')) {
        objfun.ConfirmationOK(resultData, context);
      } else {
        objfun.ConfirmationOK('Employee deleted successfully', context);
      }
    }



  } catch (e, st) {
    objfun.msgshow(
      e.toString(),
      st.toString(),
      Colors.white,
      Colors.red,
      null,
      18.00 - objfun.reducesize,
      objfun.tll,
      objfun.tgc,
      context,
      2,
    );

  }
}
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
Widget buildImage(String? path, BuildContext context) {
/*  print("IMAGE PATH VALUE => '$path'")*/;

  if (path == null || path.isEmpty) {
    return SizedBox.shrink();
  }

  Widget imageWidget;

  // ✅ 1. FULL URL (server)
  if (path.startsWith("http")) {
    imageWidget = Image.network(
      path,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) =>
          Icon(Icons.broken_image, color: Colors.red),
    );
  }

  // ✅ 2. LOCAL FILE (camera / gallery)
  else if (path.startsWith("/data/")) {
    imageWidget = Image.file(
      File(path),
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) =>
          Icon(Icons.broken_image, color: Colors.red),
    );
  }

  // ✅ 3. SERVER RELATIVE PATH
  else if (path.startsWith("/")) {
    final fullUrl = objfun.port + path;
    print("Loading image: $fullUrl");

    imageWidget = Image.network(
      fullUrl,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) =>
          Icon(Icons.broken_image, color: Colors.red),
    );
  }

  else {
    return SizedBox.shrink();
  }

  // ✅ Clickable thumbnail → popup
  return GestureDetector(
    onTap: () {
      showImagePopup(context, imageWidget);
    },
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 100,
        height: 100,
        child: imageWidget,
      ),
    ),
  );
}

Widget infoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Label
        SizedBox(
          width: 90,
          child: Text(
            "$label :",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),

        // 🔹 Value
        Expanded(
          child: Text(
            value.isEmpty ? "-" : value,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
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
void showImagePopup(BuildContext context, Widget imageWidget) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.all(10),
      child: Stack(
        children: [
          // ✅ Zoom + Pan support
          InteractiveViewer(
            child: Center(child: imageWidget),
          ),

          // ❌ Close button
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    ),
  );
}