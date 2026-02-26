part of 'package:maleva/DashBoard/Receivable/ReceivableDashboard.dart';


 mobiledesign(ReceivableDashboardState state, BuildContext context) {

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

  });
  return WillPopScope(
      onWillPop: state._onBackPressed,
      child: DefaultTabController(
          length: 2,
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
                    Text('Receivable ',
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
                    Tab(text: 'SO'),



                  ],
                  controller: state._tabmainController,
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
                    }


                  }

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
