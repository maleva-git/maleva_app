part of 'package:maleva/DashBoard/Driver/DriverDashboard.dart';

tabletdesign(OldDriverDashboardState state, BuildContext context) {
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

      state.loadPlanningdata(0);
    }
    else if(state._tabmainController.index == 1){

      state.loadTruckdata();
    }
    else if(state._tabmainController.index == 2){

      state.loadDriverdata();
    }
  });
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
                  Tab(text: 'TRANSPORT'),
                  Tab(text: 'MAINTENANCE'),
                  Tab(text: 'EXPIRY'),

                ],
                controller: state._tabmainController,
                // currentIndex: state._tabmainController.index,
                onTap: (int index) {
                  state._tabmainController.index = index;
                  if (state._tabmainController.index == 0) {
                    state.IsPlanToday = true;

                    state.loadPlanningdata(0);
                  }
                  else if(state._tabmainController.index == 1){
                    state.loadTruckdata();
                  }
                  else if(state._tabmainController.index == 2){

                    state.loadDriverdata();
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


                                          state._shareRTI(state.SaleTransReport[
                                          index]["SortBy"],state.SaleTransReport[
                                          index][
                                          "Remarks"]);
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
                    padding: const EdgeInsets.only(
                        top: 15.0, left: 10.0, right: 10.0),
                    child: ListView(
                      children: [
                        const SizedBox(
                          height: 7,
                        ),
                        Center(
                          child: Text(
                            'TRUCK MAINTENANCE',
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                  color: colour.commonColorred,
                                  fontWeight: FontWeight.bold,
                                  fontSize: objfun.FontLarge,
                                  letterSpacing: 0.3),
                            ),
                          ),
                        ),


                        SizedBox(
                            height: height * 0.75,
                            child: ListView.builder(
                                itemCount:
                                objfun.TruckDetailsList.length,
                                itemBuilder:
                                    (BuildContext context, int index) {
                                  return SizedBox(
                                      height: height * 0.75,
                                      child: InkWell(
                                        onLongPress: () {


                                        },
                                        child: Card(
                                            color: colour.commonColorLight,
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
                                                          flex: 2,
                                                          child: Container(
                                                            color: colour.commonColor,
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "Truck 1 :",
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
                                                                        .commonColorLight,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
                                                                    letterSpacing:
                                                                    0.3),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Container(
                                                            color: colour.commonColor,
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .TruckNumber
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
                                                                        .commonColorLight,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "RotexMy Exp :",
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
                                                                        .FontLow,
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
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .RotexMyExp == "null" ? " " : objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .RotexMyExp,
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
                                                                    color:state._ExpColor(objfun
                                                                        .TruckDetailsList[
                                                                    index]
                                                                        .RotexMyExp),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "RotexSG Exp :",
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
                                                                        .FontLow,
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
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .RotexSGExp == "null" ? " ":objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .RotexSGExp,
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
                                                                    color: state._ExpColor(objfun
                                                                        .TruckDetailsList[
                                                                    index]
                                                                        .RotexSGExp),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "PushpaCom :",
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
                                                                        .FontLow,
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
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .PuspacomExp == "null" ? " ": objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .PuspacomExp,
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
                                                                    color: state._ExpColor(objfun
                                                                        .TruckDetailsList[
                                                                    index]
                                                                        .PuspacomExp),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "Insurance :",
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
                                                                        .FontLow,
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
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .InsuratnceExp =="null" ? " ":objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .InsuratnceExp,
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
                                                                    color: state._ExpColor(objfun
                                                                        .TruckDetailsList[
                                                                    index]
                                                                        .InsuratnceExp),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "Bonam Exp :",
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
                                                                        .FontLow,
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
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .BonamExp == "null" ? "" : objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .BonamExp,
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
                                                                    color: state._ExpApadBonamColor(objfun
                                                                        .TruckDetailsList[
                                                                    index]
                                                                        .BonamExp),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "Apad Exp :",
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
                                                                        .FontLow,
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
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .ApadExp == "null" ? "" : objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .ApadExp,
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
                                                                    color: state._ExpApadBonamColor(objfun
                                                                        .TruckDetailsList[
                                                                    index]
                                                                        .ApadExp),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            color: colour.commonColor,
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "Truck 2 :",
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
                                                                        .commonColorLight,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
                                                                    letterSpacing:
                                                                    0.3),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Container(
                                                            color: colour.commonColor,
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .TruckNumber1 == "null" ? "":objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .TruckNumber1,
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
                                                                        .commonColorLight,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "RotexMy1 :",
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
                                                                        .FontLow,
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
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .RotexMyExp1 == "null" ? "" : objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .RotexMyExp1,
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
                                                                    color: state._ExpColor(objfun
                                                                        .TruckDetailsList[
                                                                    index]
                                                                        .RotexMyExp1),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "RotexSG1 :",
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
                                                                        .FontLow,
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
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .RotexSGExp1 == "null" ? "" : objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .RotexSGExp1,
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
                                                                    color: state._ExpColor(objfun
                                                                        .TruckDetailsList[
                                                                    index]
                                                                        .RotexSGExp1),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "PushpaCom1 :",
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
                                                                        .FontLow,
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
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .PuspacomExp1 == "null" ? "" : objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .PuspacomExp1,
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
                                                                    color: state._ExpColor(objfun
                                                                        .TruckDetailsList[
                                                                    index]
                                                                        .PuspacomExp1),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "Service Exp :",
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
                                                                        .FontLow,
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
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .ServiceExp == "null" ? "" : objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .ServiceExp,
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
                                                                    color: state._ExpServiceAligmentGreece(objfun
                                                                        .TruckDetailsList[
                                                                    index]
                                                                        .ServiceExp),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "Service Last :",
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
                                                                        .FontLow,
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
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .ServiceLast == "null" ? "" : objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .ServiceLast,
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
                                                                    color: colour.commonColor,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "AlignmentExp :",
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
                                                                        .FontLow,
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
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .AlignmentExp == "null" ? "" :objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .AlignmentExp,
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
                                                                    color: state._ExpServiceAligmentGreece(objfun
                                                                        .TruckDetailsList[
                                                                    index]
                                                                        .AlignmentExp),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "Alignment Last :",
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
                                                                        .FontLow,
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
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .AlignmentLast == "null" ? "" : objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .AlignmentLast,
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
                                                                    color: colour.commonColor,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "Greece Exp :",
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
                                                                        .FontLow,
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
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .GreeceExp == "null" ? "" : objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .GreeceExp,
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
                                                                    color: state._ExpServiceAligmentGreece(objfun
                                                                        .TruckDetailsList[
                                                                    index]
                                                                        .GreeceExp),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "Greece Last :",
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
                                                                        .FontLow,
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
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .GreeceLast == "null" ? "" : objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .GreeceLast,
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
                                                                    color: colour.commonColor,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "GearOil Exp :",
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
                                                                        .FontLow,
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
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .GearOilExp == "null" ? "" : objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .GearOilExp,
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
                                                                    color: state._ExpServiceAligmentGreece(objfun
                                                                        .TruckDetailsList[
                                                                    index]
                                                                        .GearOilExp),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "GearOil Last :",
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
                                                                        .FontLow,
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
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .GearOilLast == "null" ? "" : objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .GearOilLast,
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
                                                                    color: colour.commonColor,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "PTPSticker Exp :",
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
                                                                        .FontLow,
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
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .PTPStickerExp == "null" ? "" : objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .PTPStickerExp,
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
                                                                    color: state._ExpServiceAligmentGreece(objfun
                                                                        .TruckDetailsList[
                                                                    index]
                                                                        .PTPStickerExp),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                            'DRIVER LICENSE EXPIRY',
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                  color: colour.commonColorred,
                                  fontWeight: FontWeight.bold,
                                  fontSize: objfun.FontLarge,
                                  letterSpacing: 0.3),
                            ),
                          ),
                        ),


                        SizedBox(
                            height: height * 0.75,
                            child: ListView.builder(
                                itemCount:
                                objfun.TruckDetailsList.length,
                                itemBuilder:
                                    (BuildContext context, int index) {
                                  return SizedBox(
                                      height: height * 0.75,
                                      child: InkWell(
                                        onLongPress: () {


                                        },
                                        child: Card(
                                            color: colour.commonColorLight,
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
                                                          flex: 2,
                                                          child: Container(
                                                            color: colour.commonColor,
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "Truck 1 :",
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
                                                                        .commonColorLight,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
                                                                    letterSpacing:
                                                                    0.3),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Container(
                                                            color: colour.commonColor,
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .TruckNumber
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
                                                                        .commonColorLight,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "RotexMy Exp :",
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
                                                                        .FontLow,
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
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .RotexMyExp == "null" ? " " : objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .RotexMyExp,
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
                                                                    color:state._ExpColor(objfun
                                                                        .TruckDetailsList[
                                                                    index]
                                                                        .RotexMyExp),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "RotexSG Exp :",
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
                                                                        .FontLow,
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
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .RotexSGExp == "null" ? " ":objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .RotexSGExp,
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
                                                                    color: state._ExpColor(objfun
                                                                        .TruckDetailsList[
                                                                    index]
                                                                        .RotexSGExp),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "PushpaCom :",
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
                                                                        .FontLow,
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
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .PuspacomExp == "null" ? " ": objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .PuspacomExp,
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
                                                                    color: state._ExpColor(objfun
                                                                        .TruckDetailsList[
                                                                    index]
                                                                        .PuspacomExp),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "Insurance :",
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
                                                                        .FontLow,
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
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .InsuratnceExp =="null" ? " ":objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .InsuratnceExp,
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
                                                                    color: state._ExpColor(objfun
                                                                        .TruckDetailsList[
                                                                    index]
                                                                        .InsuratnceExp),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "Bonam Exp :",
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
                                                                        .FontLow,
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
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .BonamExp == "null" ? "" : objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .BonamExp,
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
                                                                    color: state._ExpApadBonamColor(objfun
                                                                        .TruckDetailsList[
                                                                    index]
                                                                        .BonamExp),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "Apad Exp :",
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
                                                                        .FontLow,
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
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .ApadExp == "null" ? "" : objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .ApadExp,
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
                                                                    color: state._ExpApadBonamColor(objfun
                                                                        .TruckDetailsList[
                                                                    index]
                                                                        .ApadExp),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            color: colour.commonColor,
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "Truck 2 :",
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
                                                                        .commonColorLight,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
                                                                    letterSpacing:
                                                                    0.3),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Container(
                                                            color: colour.commonColor,
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .TruckNumber1 == "null" ? "":objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .TruckNumber1,
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
                                                                        .commonColorLight,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "RotexMy1 :",
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
                                                                        .FontLow,
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
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .RotexMyExp1 == "null" ? "" : objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .RotexMyExp1,
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
                                                                    color: state._ExpColor(objfun
                                                                        .TruckDetailsList[
                                                                    index]
                                                                        .RotexMyExp1),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "RotexSG1 :",
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
                                                                        .FontLow,
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
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .RotexSGExp1 == "null" ? "" : objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .RotexSGExp1,
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
                                                                    color: state._ExpColor(objfun
                                                                        .TruckDetailsList[
                                                                    index]
                                                                        .RotexSGExp1),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "PushpaCom1 :",
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
                                                                        .FontLow,
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
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .PuspacomExp1 == "null" ? "" : objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .PuspacomExp1,
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
                                                                    color: state._ExpColor(objfun
                                                                        .TruckDetailsList[
                                                                    index]
                                                                        .PuspacomExp1),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "Service Exp :",
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
                                                                        .FontLow,
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
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .ServiceExp == "null" ? "" : objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .ServiceExp,
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
                                                                    color: state._ExpServiceAligmentGreece(objfun
                                                                        .TruckDetailsList[
                                                                    index]
                                                                        .ServiceExp),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "Service Last :",
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
                                                                        .FontLow,
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
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .ServiceLast == "null" ? "" : objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .ServiceLast,
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
                                                                    color: colour.commonColor,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "AlignmentExp :",
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
                                                                        .FontLow,
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
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .AlignmentExp == "null" ? "" :objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .AlignmentExp,
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
                                                                    color: state._ExpServiceAligmentGreece(objfun
                                                                        .TruckDetailsList[
                                                                    index]
                                                                        .AlignmentExp),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "Alignment Last :",
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
                                                                        .FontLow,
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
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .AlignmentLast == "null" ? "" : objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .AlignmentLast,
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
                                                                    color: colour.commonColor,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "Greece Exp :",
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
                                                                        .FontLow,
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
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .GreeceExp == "null" ? "" : objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .GreeceExp,
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
                                                                    color: state._ExpServiceAligmentGreece(objfun
                                                                        .TruckDetailsList[
                                                                    index]
                                                                        .GreeceExp),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "Greece Last :",
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
                                                                        .FontLow,
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
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .GreeceLast == "null" ? "" : objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .GreeceLast,
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
                                                                    color: colour.commonColor,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "GearOil Exp :",
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
                                                                        .FontLow,
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
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .GearOilExp == "null" ? "" : objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .GearOilExp,
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
                                                                    color: state._ExpServiceAligmentGreece(objfun
                                                                        .TruckDetailsList[
                                                                    index]
                                                                        .GearOilExp),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "GearOil Last :",
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
                                                                        .FontLow,
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
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .GearOilLast == "null" ? "" : objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .GearOilLast,
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
                                                                    color: colour.commonColor,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
                                                          flex: 2,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              "PTPSticker Exp :",
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
                                                                        .FontLow,
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
                                                              objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .PTPStickerExp == "null" ? "" : objfun
                                                                  .TruckDetailsList[
                                                              index]
                                                                  .PTPStickerExp,
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
                                                                    color: state._ExpServiceAligmentGreece(objfun
                                                                        .TruckDetailsList[
                                                                    index]
                                                                        .PTPStickerExp),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    objfun
                                                                        .FontLow,
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
              ],
            ),
          )));
}
