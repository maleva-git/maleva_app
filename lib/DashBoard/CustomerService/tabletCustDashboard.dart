part of 'package:maleva/DashBoard/CustomerService/CustDashboard.dart';


tabletdesign(CustDashboardState state, BuildContext context) {
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
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
            title: SizedBox(
              height: height * 0.06,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children:  [
                  Text('Dash Board',
                      style:GoogleFonts.lato(textStyle: TextStyle(
                        color: colour.topAppBarColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Alatsi',
                        fontSize: objfun.FontLarge,
                      ))),
                ],
              ),
            ),
  leading: IconTheme(
  data: const IconThemeData(size: 35.0), // Change size here
  child: Builder(
  builder: (context) => IconButton(
  icon: const Icon(Icons.menu,color: colour.commonHeadingColor,),
  onPressed: () {
  Scaffold.of(context).openDrawer();
  },
  ),
  ),),
            iconTheme: const IconThemeData(color: colour.topAppBarColor),
            actions: <Widget>[
              SizedBox(
                height: height * 0.009,
                child: Row(
                  children:  [
                    Text('INV',
                        style:GoogleFonts.lato(textStyle: TextStyle(
                          color: colour.topAppBarColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Alatsi',
                          fontSize: objfun.FontCardText,
                        ))),
                    Switch(
                      value: state.Invoicewiseview,
                      activeColor: Colors.green,
                      inactiveThumbColor: colour.noItemFoundColor,
                      onChanged: (bool newValue) {
                        state.setState(() {
                          state.Invoicewiseview =newValue;
                          state._tabController.index = 0;
                        });
                        if(state.Invoicewiseview){

                          state.loaddata(0);
                        }
                        else{
                          state.loaddata(1);
                        }
                      },
                    ),

                  ],
                ),
              ),

              IconButton(
                icon: const Icon(
                  Icons.refresh,
                  size: 35.0,
                  color: colour.topAppBarColor,
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CustDashboard()));
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.exit_to_app,
                  size: 35.0,
                  color: colour.topAppBarColor,
                ),
                onPressed: () {
                  objfun.logout(context);
                },
              ),
            ]),
        drawer: SizedBox(
          width: width*0.30,
          child: const Menulist() ,
        ),
        body: state.progress == true
            ? state.Invoicewiseview ? Padding(
            padding: const EdgeInsets.only(
                top: 25.0, left: 10.0, right: 10.0),
            child:ListView(
              children: [
                const SizedBox(height: 7,),
                Center(child: Text('${state.currentMonthName}   Sales',style:
                GoogleFonts.lato(
                  textStyle:  TextStyle(
                      color: colour.commonColorred,
                      fontWeight:
                      FontWeight.bold,
                      fontSize: objfun.FontLarge,
                      letterSpacing: 0.3),),),
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Expanded(
                        flex : 1,
                        child:Column(
                          children: [
                            SizedBox(
                              height: height * 0.40,
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
                                                    top: 5,
                                                    left: 5,
                                                    right: 5,
                                                    bottom: 5),
                                                child: Text(
                                                  "Today",
                                                  textAlign: TextAlign.left,
                                                  style:
                                                  GoogleFonts.lato(
                                                    textStyle:  TextStyle(
                                                        color: colour.commonColor,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: objfun.FontLow,
                                                        letterSpacing: 0.3),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 15,),
                                              Padding(
                                                padding: const EdgeInsets.all(5),
                                                child: Text(
                                                  "Yesterday",
                                                  textAlign: TextAlign.left,
                                                  style:
                                                  GoogleFonts.lato(
                                                    textStyle:  TextStyle(
                                                        color: colour.commonColor,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: objfun.FontLow,
                                                        letterSpacing: 0.3),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 15,),
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
                                                    textStyle:  TextStyle(
                                                        color: colour.commonColor,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize:objfun.FontLow,
                                                        letterSpacing: 0.3),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 15,),
                                              Padding(
                                                padding:
                                                const EdgeInsets.only(
                                                    top: 5,
                                                    left: 5,
                                                    right: 5,
                                                    bottom: 5),
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
                                                        fontSize: objfun.FontLow,
                                                        letterSpacing:
                                                        0.3),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 15,),

                                            ])),
                                    Expanded(
                                        flex: 1,
                                        child: Column(children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top:5,
                                                left: 5,
                                                right: 5,
                                                bottom: 5),
                                            child: Text(
                                              state.SaleDataAll.isEmpty?'0':state.SaleDataAll[0]["TodaySales"]
                                                  .toStringAsFixed(0) ,
                                              style: GoogleFonts.lato(
                                                textStyle:  TextStyle(
                                                    color: colour.commonColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: objfun.FontLow,
                                                    letterSpacing: 0.3),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 15,),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 5, bottom: 5),
                                            child: Text(
                                              state.SaleDataAll.isEmpty?'0':state.SaleDataAll[0]["YesterdaySales"]
                                                  .toStringAsFixed(0) ,
                                              style: GoogleFonts.lato(
                                                textStyle:  TextStyle(
                                                    color: colour.commonColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: objfun.FontLow,
                                                    letterSpacing: 0.3),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 15,),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 5, bottom: 5),
                                            child: Text(
                                              state.SaleDataAll.isEmpty?'0':state.SaleDataAll[0]["WeekSales"]
                                                  .toStringAsFixed(0) ,
                                              style: GoogleFonts.lato(
                                                textStyle:  TextStyle(
                                                    color: colour.commonColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: objfun.FontLow,
                                                    letterSpacing: 0.3),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 15,),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 5,
                                                left: 5,
                                                right: 5,
                                                bottom: 5),
                                            child: Text(
                                              state.SaleDataAll.isEmpty?'0':state.SaleDataAll[0]["MonthSales"]
                                                  .toStringAsFixed(0) ,
                                              style: GoogleFonts.lato(
                                                textStyle:  TextStyle(
                                                    color: colour.commonColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: objfun.FontLow,
                                                    letterSpacing: 0.3),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 15,),
                                        ])),
                                    Expanded(
                                        flex: 2,
                                        child: Column(children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 5,
                                                left: 5,
                                                right: 5,
                                                bottom: 5),
                                            child: Text(
                                              state.SaleDataAll.isEmpty?'0':state.SaleDataAll[0]["TodayAmount"]
                                                  .toStringAsFixed(0),
                                              style: GoogleFonts.lato(
                                                textStyle:  TextStyle(
                                                    color: colour.commonColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: objfun.FontLow,
                                                    letterSpacing: 0.3),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 15,),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 5, bottom: 5),
                                            child: Text( state.SaleDataAll.isEmpty?'0':state.SaleDataAll[0]["YesterdayAmount"]
                                                .toStringAsFixed(0),
                                              style: GoogleFonts.lato(
                                                textStyle:  TextStyle(
                                                    color: colour.commonColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: objfun.FontLow,
                                                    letterSpacing: 0.3),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 15,),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 5, bottom: 5),
                                            child: Text( state.SaleDataAll.isEmpty?'0':state.SaleDataAll[0]["WeekAmount"]
                                                .toStringAsFixed(0),
                                              style: GoogleFonts.lato(
                                                textStyle:  TextStyle(
                                                    color: colour.commonColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: objfun.FontLow,
                                                    letterSpacing: 0.3),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 15,),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 5,
                                                left: 5,
                                                right: 5,
                                                bottom: 5),
                                            child: Text( state.SaleDataAll.isEmpty?'0':state.SaleDataAll[0]["MonthAmount"]
                                                .toStringAsFixed(0),
                                              style: GoogleFonts.lato(
                                                textStyle:  TextStyle(
                                                    color: colour.commonColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: objfun.FontLow,
                                                    letterSpacing: 0.3),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 15,),
                                        ])),
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:
                              [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colour.commonColorLight,
                                    side:  BorderSide(
                                        color: state.Is6Months  ?colour.commonColor : colour.commonColorLight,
                                        width: 1,
                                        style: BorderStyle.solid),
                                    textStyle: const TextStyle(color: Colors.black),
                                    elevation: state.Is6Months ? 15.0 : 0,

                                    padding: const EdgeInsets.all(4.0),
                                  ),
                                  onPressed: () {
                                    state.monthdata(6);
                                    state.setState((){
                                      state.Is6Months=true;
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
                                const SizedBox(width: 15,),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colour.commonColorLight,
                                    side:  BorderSide(
                                        color:state.Is6Months  ?colour.commonColorLight : colour.commonColor,
                                        width: 1,
                                        style: BorderStyle.solid),
                                    textStyle: const TextStyle(color: Colors.black),
                                    elevation:state.Is6Months ? 0.0 : 15.0,

                                    padding: const EdgeInsets.all(4.0),
                                  ),
                                  onPressed: () {
                                    state.monthdata(12);
                                    state.setState((){
                                      state.Is6Months=false;
                                    });

                                  },
                                  child: Text(
                                    '1 Year',
                                    style: GoogleFonts.lato(
                                        fontSize: objfun.FontMedium,
                                        fontWeight: FontWeight.bold,
                                        color: colour.commonColor),
                                  ),
                                ),],),
                          ],
                        )
                    ),
                    Expanded(
                        flex : 1,
                        child:Column(
                          children: [
                            SizedBox(
                                height: height * 0.65,
                                child:  ListView.builder(
                                    itemCount:
                                    state.LoadMonthsList.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return SizedBox(
                                          height:height * 0.07,
                                          child: InkWell(
                                            onLongPress: () {


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
                                                                  state.LoadMonthsList[index] ,
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
                                                                  state.ListMonthData[index]["SalesCount"].toString() ,
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
                                                                  state.ListMonthData[index]["SalesAmount"].toString() ,
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
                        )
                    )
                  ],
                )
              ],
            )):
        DefaultTabController(
            length: 3,
            child: TabBarView(
                controller: state._tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Padding(
                      padding: const EdgeInsets.only(
                          top: 15.0, left: 10.0, right: 10.0),
                      child:ListView(
                        children: [
                          const SizedBox(height: 7,),
                          Center(child: Text('${state.currentMonthName}   Sales',style:
                          GoogleFonts.lato(
                            textStyle:  TextStyle(
                                color: colour.commonColorred,
                                fontWeight:
                                FontWeight.bold,
                                fontSize: objfun.FontLarge,
                                letterSpacing: 0.3),),),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  flex : 1,
                                  child:Column(
                                    children: [
                                      SizedBox(
                                        height: height * 0.40,
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
                                                              top: 5,
                                                              left: 5,
                                                              right: 5,
                                                              bottom: 5),
                                                          child: Text(
                                                            "Today",
                                                            textAlign: TextAlign.left,
                                                            style:
                                                            GoogleFonts.lato(
                                                              textStyle:  TextStyle(
                                                                  color: colour.commonColor,
                                                                  fontWeight:
                                                                  FontWeight.bold,
                                                                  fontSize: objfun.FontLow,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(height: 15,),
                                                        Padding(
                                                          padding: const EdgeInsets.all(5),
                                                          child: Text(
                                                            "Yesterday",
                                                            textAlign: TextAlign.left,
                                                            style:
                                                            GoogleFonts.lato(
                                                              textStyle:  TextStyle(
                                                                  color: colour.commonColor,
                                                                  fontWeight:
                                                                  FontWeight.bold,
                                                                  fontSize: objfun.FontLow,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(height: 15,),
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
                                                              textStyle:  TextStyle(
                                                                  color: colour.commonColor,
                                                                  fontWeight:
                                                                  FontWeight.bold,
                                                                  fontSize:objfun.FontLow,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(height: 15,),
                                                        Padding(
                                                          padding:
                                                          const EdgeInsets.only(
                                                              top: 5,
                                                              left: 5,
                                                              right: 5,
                                                              bottom: 5),
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
                                                                  fontSize: objfun.FontLow,
                                                                  letterSpacing:
                                                                  0.3),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(height: 15,),

                                                      ])),
                                              Expanded(
                                                  flex: 1,
                                                  child: Column(children: <Widget>[
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          top:5,
                                                          left: 5,
                                                          right: 5,
                                                          bottom: 5),
                                                      child: Text(
                                                        state.SaleDataAll.isEmpty?'0':state.SaleDataAll[0]["TodaySales"]
                                                            .toStringAsFixed(0) ,
                                                        style: GoogleFonts.lato(
                                                          textStyle:  TextStyle(
                                                              color: colour.commonColor,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: objfun.FontLow,
                                                              letterSpacing: 0.3),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 15,),
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          top: 5, bottom: 5),
                                                      child: Text(
                                                        state.SaleDataAll.isEmpty?'0':state.SaleDataAll[0]["YesterdaySales"]
                                                            .toStringAsFixed(0) ,
                                                        style: GoogleFonts.lato(
                                                          textStyle:  TextStyle(
                                                              color: colour.commonColor,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: objfun.FontLow,
                                                              letterSpacing: 0.3),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 15,),
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          top: 5, bottom: 5),
                                                      child: Text(
                                                        state.SaleDataAll.isEmpty?'0':state.SaleDataAll[0]["WeekSales"]
                                                            .toStringAsFixed(0) ,
                                                        style: GoogleFonts.lato(
                                                          textStyle:  TextStyle(
                                                              color: colour.commonColor,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: objfun.FontLow,
                                                              letterSpacing: 0.3),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 15,),
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          top: 5,
                                                          left: 5,
                                                          right: 5,
                                                          bottom: 5),
                                                      child: Text(
                                                        state.SaleDataAll.isEmpty?'0':state.SaleDataAll[0]["MonthSales"]
                                                            .toStringAsFixed(0) ,
                                                        style: GoogleFonts.lato(
                                                          textStyle:  TextStyle(
                                                              color: colour.commonColor,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: objfun.FontLow,
                                                              letterSpacing: 0.3),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 15,),
                                                  ])),
                                              Expanded(
                                                  flex: 2,
                                                  child: Column(children: <Widget>[
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          top: 5,
                                                          left: 5,
                                                          right: 5,
                                                          bottom: 5),
                                                      child: Text(
                                                        state.SaleDataAll.isEmpty?'0':state.SaleDataAll[0]["TodayAmount"]
                                                            .toStringAsFixed(0),
                                                        style: GoogleFonts.lato(
                                                          textStyle:  TextStyle(
                                                              color: colour.commonColor,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: objfun.FontLow,
                                                              letterSpacing: 0.3),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 15,),
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          top: 5, bottom: 5),
                                                      child: Text( state.SaleDataAll.isEmpty?'0':state.SaleDataAll[0]["YesterdayAmount"]
                                                          .toStringAsFixed(0),
                                                        style: GoogleFonts.lato(
                                                          textStyle:  TextStyle(
                                                              color: colour.commonColor,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: objfun.FontLow,
                                                              letterSpacing: 0.3),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 15,),
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          top: 5, bottom: 5),
                                                      child: Text( state.SaleDataAll.isEmpty?'0':state.SaleDataAll[0]["WeekAmount"]
                                                          .toStringAsFixed(0),
                                                        style: GoogleFonts.lato(
                                                          textStyle:  TextStyle(
                                                              color: colour.commonColor,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: objfun.FontLow,
                                                              letterSpacing: 0.3),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 15,),
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          top: 5,
                                                          left: 5,
                                                          right: 5,
                                                          bottom: 5),
                                                      child: Text( state.SaleDataAll.isEmpty?'0':state.SaleDataAll[0]["MonthAmount"]
                                                          .toStringAsFixed(0),
                                                        style: GoogleFonts.lato(
                                                          textStyle:  TextStyle(
                                                              color: colour.commonColor,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: objfun.FontLow,
                                                              letterSpacing: 0.3),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 15,),
                                                  ])),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children:
                                        [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: colour.commonColorLight,
                                              side:  BorderSide(
                                                  color: state.Is6Months  ?colour.commonColor : colour.commonColorLight,
                                                  width: 1,
                                                  style: BorderStyle.solid),
                                              textStyle: const TextStyle(color: Colors.black),
                                              elevation: state.Is6Months ? 15.0 : 0,

                                              padding: const EdgeInsets.all(4.0),
                                            ),
                                            onPressed: () {
                                              state.monthdata(6);
                                              state.setState((){
                                                state.Is6Months=true;
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
                                          const SizedBox(width: 15,),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: colour.commonColorLight,
                                              side:  BorderSide(
                                                  color:state.Is6Months  ?colour.commonColorLight : colour.commonColor,
                                                  width: 1,
                                                  style: BorderStyle.solid),
                                              textStyle: const TextStyle(color: Colors.black),
                                              elevation:state.Is6Months ? 0.0 : 15.0,

                                              padding: const EdgeInsets.all(4.0),
                                            ),
                                            onPressed: () {
                                              state.monthdata(12);
                                              state.setState((){
                                                state.Is6Months=false;
                                              });

                                            },
                                            child: Text(
                                              '1 Year',
                                              style: GoogleFonts.lato(
                                                  fontSize: objfun.FontMedium,
                                                  fontWeight: FontWeight.bold,
                                                  color: colour.commonColor),
                                            ),
                                          ),],),
                                    ],
                                  )
                              ),
                              Expanded(
                                  flex : 1,
                                  child:Column(
                                    children: [
                                      SizedBox(
                                          height: height * 0.62,
                                          child:  ListView.builder(
                                              itemCount:
                                              state.LoadMonthsList.length,
                                              itemBuilder:
                                                  (BuildContext context, int index) {
                                                return SizedBox(
                                                    height:height * 0.07,
                                                    child: InkWell(
                                                      onLongPress: () {


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
                                                                            state.LoadMonthsList[index] ,
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
                                                                            state.ListMonthData[index]["SalesCount"].toString() ,
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
                                                                            state.ListMonthData[index]["SalesAmount"].toString() ,
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
                                  )
                              )
                            ],
                          )
                        ],
                      )),
                  Padding(
                      padding: const EdgeInsets.only(
                          top: 15.0, left: 10.0, right: 10.0),
                      child:ListView(
                        children: [
                          const SizedBox(height: 7,),
                          Center(child:
                          Text('${state.currentMonthName}  Sales',style:
                          GoogleFonts.lato(
                            textStyle:  TextStyle(
                                color: colour.commonColorred,
                                fontWeight:
                                FontWeight.bold,
                                fontSize: objfun.FontLarge,
                                letterSpacing: 0.3),),),),
                          const SizedBox(
                            height:30,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  flex : 1,
                                  child:Column(
                                    children: [
                                      SizedBox(
                                        height: height * 0.40,
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
                                                              top: 5,
                                                              left: 5,
                                                              right: 5,
                                                              bottom: 5),
                                                          child: Text(
                                                            "Today",
                                                            textAlign: TextAlign.left,
                                                            style:
                                                            GoogleFonts.lato(
                                                              textStyle:  TextStyle(
                                                                  color: colour.commonColor,
                                                                  fontWeight:
                                                                  FontWeight.bold,
                                                                  fontSize: objfun.FontLow,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(height: 15,),
                                                        Padding(
                                                          padding: const EdgeInsets.all(5),
                                                          child: Text(
                                                            "Yesterday",
                                                            textAlign: TextAlign.left,
                                                            style:
                                                            GoogleFonts.lato(
                                                              textStyle:  TextStyle(
                                                                  color: colour.commonColor,
                                                                  fontWeight:
                                                                  FontWeight.bold,
                                                                  fontSize: objfun.FontLow,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 15,),
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
                                                              textStyle:  TextStyle(
                                                                  color: colour.commonColor,
                                                                  fontWeight:
                                                                  FontWeight.bold,
                                                                  fontSize: objfun.FontLow,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 15,),
                                                        Padding(
                                                          padding:
                                                          const EdgeInsets.only(
                                                              top: 5,
                                                              left: 5,
                                                              right: 5,
                                                              bottom: 5),
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
                                                                  fontSize: objfun.FontLow,
                                                                  letterSpacing:
                                                                  0.3),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 15,),

                                                      ])),
                                              Expanded(
                                                  flex: 1,
                                                  child: Column(children: <Widget>[
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          top: 5,
                                                          left: 5,
                                                          right: 5,
                                                          bottom: 5),
                                                      child: Text(
                                                        state.SaleDataAll.isEmpty?'0':state.SaleDataAll[0]["TodaySales"]
                                                            .toStringAsFixed(0) ,
                                                        style: GoogleFonts.lato(
                                                          textStyle:  TextStyle(
                                                              color: colour.commonColor,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: objfun.FontLow,
                                                              letterSpacing: 0.3),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 15,),
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          top: 5, bottom: 5),
                                                      child: Text(
                                                        state.SaleDataAll.isEmpty?'0':state.SaleDataAll[0]["YesterdaySales"]
                                                            .toStringAsFixed(0) ,
                                                        style: GoogleFonts.lato(
                                                          textStyle:  TextStyle(
                                                              color: colour.commonColor,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: objfun.FontLow,
                                                              letterSpacing: 0.3),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 15,),
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          top: 5, bottom: 5),
                                                      child: Text(
                                                        state.SaleDataAll.isEmpty?'0':state.SaleDataAll[0]["WeekSales"]
                                                            .toStringAsFixed(0) ,
                                                        style: GoogleFonts.lato(
                                                          textStyle:  TextStyle(
                                                              color: colour.commonColor,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: objfun.FontLow,
                                                              letterSpacing: 0.3),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 15,),
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          top: 5,
                                                          left: 5,
                                                          right: 5,
                                                          bottom: 5),
                                                      child: Text(
                                                        state.SaleDataAll.isEmpty?'0':state.SaleDataAll[0]["MonthSales"]
                                                            .toStringAsFixed(0) ,
                                                        style: GoogleFonts.lato(
                                                          textStyle:  TextStyle(
                                                              color: colour.commonColor,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: objfun.FontLow,
                                                              letterSpacing: 0.3),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 15,),
                                                  ])),
                                              Expanded(
                                                  flex: 2,
                                                  child: Column(children: <Widget>[
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          top: 5,
                                                          left: 5,
                                                          right: 5,
                                                          bottom: 5),
                                                      child: Text(
                                                        state.SaleDataAll.isEmpty?'0':state.SaleDataAll[0]["TodayAmount"]
                                                            .toStringAsFixed(0),
                                                        style: GoogleFonts.lato(
                                                          textStyle:  TextStyle(
                                                              color: colour.commonColor,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: objfun.FontLow,
                                                              letterSpacing: 0.3),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 15,),
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          top: 5, bottom: 5),
                                                      child: Text(  state.SaleDataAll.isEmpty?'0':state.SaleDataAll[0]["YesterdayAmount"]
                                                          .toStringAsFixed(0),
                                                        style: GoogleFonts.lato(
                                                          textStyle:  TextStyle(
                                                              color: colour.commonColor,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: objfun.FontLow,
                                                              letterSpacing: 0.3),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 15,),
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          top: 5, bottom: 5),
                                                      child: Text(  state.SaleDataAll.isEmpty?'0':state.SaleDataAll[0]["WeekAmount"]
                                                          .toStringAsFixed(0),
                                                        style: GoogleFonts.lato(
                                                          textStyle:  TextStyle(
                                                              color: colour.commonColor,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: objfun.FontLow,
                                                              letterSpacing: 0.3),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 15,),
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          top: 5,
                                                          left: 5,
                                                          right: 5,
                                                          bottom: 5),
                                                      child: Text(  state.SaleDataAll.isEmpty?'0':state.SaleDataAll[0]["MonthAmount"]
                                                          .toStringAsFixed(0),
                                                        style: GoogleFonts.lato(
                                                          textStyle:  TextStyle(
                                                              color: colour.commonColor,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: objfun.FontLow,
                                                              letterSpacing: 0.3),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 15,),
                                                  ])),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children:
                                        [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: colour.commonColorLight,
                                              side:  BorderSide(
                                                  color: state.Is6Months2  ?colour.commonColor : colour.commonColorLight,
                                                  width: 1,
                                                  style: BorderStyle.solid),
                                              textStyle: const TextStyle(color: Colors.black),
                                              elevation: state.Is6Months2 ? 15.0 : 0,

                                              padding: const EdgeInsets.all(4.0),
                                            ),
                                            onPressed: () {
                                              state.monthdata(6);
                                              state.setState((){
                                                state.Is6Months2=true;
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
                                          const SizedBox(width: 15,),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: colour.commonColorLight,
                                              side:  BorderSide(
                                                  color:state.Is6Months2  ?colour.commonColorLight : colour.commonColor,
                                                  width: 1,
                                                  style: BorderStyle.solid),
                                              textStyle: const TextStyle(color: Colors.black),
                                              elevation:state.Is6Months2 ? 0.0 : 15.0,

                                              padding: const EdgeInsets.all(4.0),
                                            ),
                                            onPressed: () {
                                              state.monthdata(12);
                                              state.setState((){
                                                state.Is6Months2=false;
                                              });

                                            },
                                            child: Text(
                                              '1 Year',
                                              style: GoogleFonts.lato(
                                                  fontSize: objfun.FontMedium,
                                                  fontWeight: FontWeight.bold,
                                                  color: colour.commonColor),
                                            ),
                                          ),],),
                                    ],
                                  )
                              ),
                              Expanded(
                                  flex : 1,
                                  child:Column(
                                    children: [
                                      SizedBox(
                                          height: height * 0.62,
                                          child:  ListView.builder(
                                              itemCount:
                                              state.LoadMonthsList.length,
                                              itemBuilder:
                                                  (BuildContext context, int index) {
                                                return SizedBox(
                                                    height:height * 0.07,
                                                    child: InkWell(
                                                      onLongPress: () {


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
                                                                            state.LoadMonthsList[index] ,
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
                                                                            state.ListMonthData[index]["SalesCount"].toString() ,
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
                                                                            state.ListMonthData[index]["SalesAmount"].toString() ,
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
                                  )
                              )
                            ],
                          )
                        ],
                      )),
                  Padding(
                      padding: const EdgeInsets.only(
                          top: 15.0, left: 10.0, right: 10.0),
                      child:ListView(
                        children: [
                          const SizedBox(height: 7,),
                          Center(child:
                          Text('${state.currentMonthName}   Sales',style:
                          GoogleFonts.lato(
                            textStyle:  TextStyle(
                                color: colour.commonColorred,
                                fontWeight:
                                FontWeight.bold,
                                fontSize: objfun.FontLarge,
                                letterSpacing: 0.3),),),),
                          const SizedBox(
                            height: 30,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  flex : 1,
                                  child:Column(
                                    children: [
                                      SizedBox(
                                        height: height * 0.40,
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
                                                              top: 5,
                                                              left: 5,
                                                              right: 5,
                                                              bottom: 5),
                                                          child: Text(
                                                            "Today",
                                                            textAlign: TextAlign.left,
                                                            style:
                                                            GoogleFonts.lato(
                                                              textStyle:  TextStyle(
                                                                  color: colour.commonColor,
                                                                  fontWeight:
                                                                  FontWeight.bold,
                                                                  fontSize: objfun.FontLow,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(height: 15,),
                                                        Padding(
                                                          padding: const EdgeInsets.all(5),
                                                          child: Text(
                                                            "Yesterday",
                                                            textAlign: TextAlign.left,
                                                            style:
                                                            GoogleFonts.lato(
                                                              textStyle:  TextStyle(
                                                                  color: colour.commonColor,
                                                                  fontWeight:
                                                                  FontWeight.bold,
                                                                  fontSize: objfun.FontLow,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(height: 15,),
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
                                                              textStyle:  TextStyle(
                                                                  color: colour.commonColor,
                                                                  fontWeight:
                                                                  FontWeight.bold,
                                                                  fontSize: objfun.FontLow,
                                                                  letterSpacing: 0.3),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(height: 15,),
                                                        Padding(
                                                          padding:
                                                          const EdgeInsets.only(
                                                              top: 5,
                                                              left: 5,
                                                              right: 5,
                                                              bottom: 5),
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
                                                                  fontSize:objfun.FontLow,
                                                                  letterSpacing:
                                                                  0.3),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(height: 15,),
                                                      ])),
                                              Expanded(
                                                  flex: 1,
                                                  child: Column(children: <Widget>[
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          top: 5,
                                                          left: 5,
                                                          right: 5,
                                                          bottom: 5),
                                                      child: Text(
                                                        state.SaleDataAll.isEmpty?'0':state.SaleDataAll[0]["TodaySales"]
                                                            .toStringAsFixed(0) ,
                                                        style: GoogleFonts.lato(
                                                          textStyle:  TextStyle(
                                                              color: colour.commonColor,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: objfun.FontLow,
                                                              letterSpacing: 0.3),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 15,),
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          top: 5, bottom: 5),
                                                      child: Text(
                                                        state.SaleDataAll.isEmpty?'0':state.SaleDataAll[0]["YesterdaySales"]
                                                            .toStringAsFixed(0) ,
                                                        style: GoogleFonts.lato(
                                                          textStyle:  TextStyle(
                                                              color: colour.commonColor,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: objfun.FontLow,
                                                              letterSpacing: 0.3),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 15,),
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          top: 5, bottom: 5),
                                                      child: Text(
                                                        state.SaleDataAll.isEmpty?'0':  state.SaleDataAll[0]["WeekSales"]
                                                            .toStringAsFixed(0) ,
                                                        style: GoogleFonts.lato(
                                                          textStyle:  TextStyle(
                                                              color: colour.commonColor,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: objfun.FontLow,
                                                              letterSpacing: 0.3),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 15,),
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          top: 5,
                                                          left: 5,
                                                          right: 5,
                                                          bottom: 5),
                                                      child: Text(
                                                        state.SaleDataAll.isEmpty?'0': state.SaleDataAll[0]["MonthSales"]
                                                            .toStringAsFixed(0) ,
                                                        style: GoogleFonts.lato(
                                                          textStyle:  TextStyle(
                                                              color: colour.commonColor,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: objfun.FontLow,
                                                              letterSpacing: 0.3),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 15,),
                                                  ])),
                                              Expanded(
                                                  flex: 2,
                                                  child: Column(children: <Widget>[
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          top: 5,
                                                          left: 5,
                                                          right: 5,
                                                          bottom: 5),
                                                      child: Text(
                                                        state.SaleDataAll.isEmpty?'0':state.SaleDataAll[0]["TodayAmount"]
                                                            .toStringAsFixed(0),
                                                        style: GoogleFonts.lato(
                                                          textStyle:  TextStyle(
                                                              color: colour.commonColor,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: objfun.FontLow,
                                                              letterSpacing: 0.3),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 15,),
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          top: 5, bottom: 5),
                                                      child: Text( state.SaleDataAll.isEmpty?'0': state.SaleDataAll[0]["YesterdayAmount"]
                                                          .toStringAsFixed(0),
                                                        style: GoogleFonts.lato(
                                                          textStyle:  TextStyle(
                                                              color: colour.commonColor,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: objfun.FontLow,
                                                              letterSpacing: 0.3),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 15,),
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          top: 5, bottom: 5),
                                                      child: Text(  state.SaleDataAll.isEmpty?'0':state.SaleDataAll[0]["WeekAmount"]
                                                          .toStringAsFixed(0),
                                                        style: GoogleFonts.lato(
                                                          textStyle:  TextStyle(
                                                              color: colour.commonColor,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: objfun.FontLow,
                                                              letterSpacing: 0.3),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 15,),
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          top: 5,
                                                          left: 5,
                                                          right: 5,
                                                          bottom: 5),
                                                      child: Text(  state.SaleDataAll.isEmpty?'0':state.SaleDataAll[0]["MonthAmount"]
                                                          .toStringAsFixed(0),
                                                        style: GoogleFonts.lato(
                                                          textStyle:  TextStyle(
                                                              color: colour.commonColor,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: objfun.FontLow,
                                                              letterSpacing: 0.3),
                                                        ),
                                                      ),
                                                    ),
                                                  ])),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children:
                                        [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: colour.commonColorLight,
                                              side:  BorderSide(
                                                  color: state.Is6Months3  ?colour.commonColor : colour.commonColorLight,
                                                  width: 1,
                                                  style: BorderStyle.solid),
                                              textStyle: const TextStyle(color: Colors.black),
                                              elevation: state.Is6Months3 ? 15.0 : 0,

                                              padding: const EdgeInsets.all(4.0),
                                            ),
                                            onPressed: () {
                                              state.monthdata(6);
                                              state.setState((){
                                                state.Is6Months3=true;
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
                                          const SizedBox(width: 15,),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: colour.commonColorLight,
                                              side:  BorderSide(
                                                  color:state.Is6Months3  ?colour.commonColorLight : colour.commonColor,
                                                  width: 1,
                                                  style: BorderStyle.solid),
                                              textStyle: const TextStyle(color: Colors.black),
                                              elevation:state.Is6Months3 ? 0.0 : 15.0,

                                              padding: const EdgeInsets.all(4.0),
                                            ),
                                            onPressed: () {
                                              state.monthdata(12);
                                              state.setState((){
                                                state.Is6Months3=false;
                                              });

                                            },
                                            child: Text(
                                              '1 Year',
                                              style: GoogleFonts.lato(
                                                  fontSize: objfun.FontMedium,
                                                  fontWeight: FontWeight.bold,
                                                  color: colour.commonColor),
                                            ),
                                          ),],),
                                    ],
                                  )
                              ),
                              Expanded(
                                  flex : 1,
                                  child:Column(
                                    children: [
                                      SizedBox(
                                          height: height * 0.62,
                                          child:  ListView.builder(
                                              itemCount:
                                              state.LoadMonthsList.length,
                                              itemBuilder:
                                                  (BuildContext context, int index) {
                                                return SizedBox(
                                                    height:height * 0.07,
                                                    child: InkWell(
                                                      onLongPress: () {


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
                                                                            state.LoadMonthsList[index] ,
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
                                                                            state.ListMonthData[index]["SalesCount"].toString() ,
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
                                                                            state.ListMonthData[index]["SalesAmount"].toString() ,
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
                                  )
                              )
                            ],


                          )


                        ],
                      )),
                ]))
            : Container(),
        bottomNavigationBar:state.Invoicewiseview ?   Container(child: const Text(""),):
        Card(

          elevation: 6,
          color: colour.commonColorLight,
          child: SalomonBottomBar(
            duration: const Duration(seconds: 1),
            items: [
              SalomonBottomBarItem(
                  icon: const Icon(
                    Icons.receipt,
                    color: colour.commonColor,
                    size: 30,
                  ),
                  title: Text(
                    "All Record",
                    style: GoogleFonts.lato(textStyle:TextStyle(
                        color: colour.commonColor,
                        fontSize:objfun.FontCardText),
                    ),)
              ),
              SalomonBottomBarItem(
                  icon: const Icon(
                    Icons.receipt_long,
                    color: colour.commonColor,
                    size: 30,
                  ),
                  title: Text(
                    "With Invoice",
                    style:GoogleFonts.lato(textStyle: TextStyle(
                        color: colour.commonColor,
                        fontSize: objfun.FontCardText),
                    ),)

              ),
              SalomonBottomBarItem(
                icon: const Icon(
                  Icons.receipt_long_outlined,
                  color: colour.commonColor,
                  size: 30,
                ),
                title: Text(
                    "Without Invoice",
                    style:GoogleFonts.lato(textStyle: TextStyle(
                        color: colour.commonColor,
                        fontSize:objfun.FontCardText),)
                ),

              ),
            ],
            currentIndex: state._tabController.index,
            onTap:(index) => state.setState(() {
              state._tabController.index = index;
              state.loaddata(index+1);
            }),
          ),
        )
      ));
}