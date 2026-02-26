part of 'package:maleva/DashBoard/Admin2/Admin2Dashboard.dart';

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
      //  state.loadSalesdata();
      state.loaddata(0);
    }
    else if (state._tabmainController.index == 1) {

      state.Invoicewiseview = false;
      state.loaddata(1);
    }
    else if (state._tabmainController.index == 2) {
      state.IsToday = true;
      state.Invoicewiseview = true;
      state.loadSalesdata();
    }
    else if (state._tabmainController.index == 3){
      state.IsToday = true;
      state.Invoicewiseview = true;
      state.loadVesseldata(0);
    } else if (state._tabmainController.index == 4) {
      state.IsPlanToday = true;
      state.Invoicewiseview = true;
      state.loadPlanningdata(0);
    } else if (state._tabmainController.index == 5) {
      state.Invoicewiseview = true;
      state.loadEnqdata();
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
      child: DefaultTabController(
          length: 11,
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
                    Tab(text: 'INV',),
                    Tab(text: 'SO'),
                    Tab(
                      text: 'SALES',
                    ),
                    Tab(text: 'VSL'),
                    Tab(text: 'TRANSPORT'),
                    Tab(text: 'ENQ'),
                    Tab(text: 'EmailInbox'),
                    Tab(text: 'GoogleReview'),
                    Tab(text: 'EmployeeView'),
                    Tab(text: 'Spot SaleOrder'),
                    Tab(text: 'InVentory Report'),
                  ],
                  controller: state._tabmainController,
                  // currentIndex: state._tabmainController.index,
                  onTap: (int index) {
                    state._tabmainController.index = index;
                    if (state._tabmainController.index == 0) {
                      state.Invoicewiseview = true;
                      state._tabController.index = 0;
                      state.loaddata(0);
                      //state.loadSalesdata();
                    }
                    else if (state._tabmainController.index  == 1) {
                      state.Invoicewiseview = false;
                      state.loaddata(1);
                    }
                    else if (state._tabmainController.index == 2) {

                      state.loadSalesdata();
                    }
                    else if (state._tabmainController.index == 3) {
                      state.IsToday = true;
                      state.Invoicewiseview = true;
                      state.loadVesseldata(0);
                    } else if (state._tabmainController.index == 4) {
                      state.IsPlanToday = true;
                      state.Invoicewiseview = true;
                      state.loadPlanningdata(0);
                    } else if (state._tabmainController.index == 5) {
                      state.Invoicewiseview = true;
                      state.loadEnqdata();
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
                    }}

                    else if (index == 8) {
                      state.IsPlanToday = true;
                      state.Invoicewiseview = true;
                      state.LoadEmployeeViewRecords();
                    }
                    else if (index == 9) {
                      state.loadInventory();
                    }
                    else if (index == 10) {
                      state.loadInventory();
                    }
                  },
                ),
              ),
              drawer: const Menulist(),
              body:
              TabBarView(
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
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: CustDashboardState.RulesTypeEmployee.any(
                                        (e) => e['Id'].toString() == state.dropdownValueEMp)
                                    ? state.dropdownValueEMp
                                    : null,
                                hint: const Text("Select Employee"),
                                onChanged: (String? value) {
                                  state.setState(() {
                                    state.dropdownValueEMp = value;
                                    state.EmpId = int.tryParse(value ?? "0") ?? 0;
                                  });
                                  state.loadSalesdata();
                                },
                                items: CustDashboardState.RulesTypeEmployee.map<DropdownMenuItem<String>>(
                                      (Map<String, dynamic> item) {
                                    return DropdownMenuItem<String>(
                                      value: item['Id'].toString(),
                                      child: Text(item['AccountName'] ?? ""),
                                    );
                                  },
                                ).toList(),
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
                  //vessel and transport report
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
                    child: _buildEmployeeViewTab(state),
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

                  )



                ],
              ),

              bottomNavigationBar:
              state.Invoicewiseview ?
              Container(child: const Text(""),)
                  : Card(
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
Widget _buildEmployeeViewTab(CustDashboardState state) {
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
String formatDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) return '—';
  try {
    DateTime parsedDate = DateTime.parse(dateString);
    return DateFormat('dd/MM/yyyy').format(parsedDate);
  } catch (e) {
    return dateString;
  }
}

