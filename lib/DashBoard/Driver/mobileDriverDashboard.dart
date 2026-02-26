part of 'package:maleva/DashBoard/Driver/DriverDashboard.dart';

mobiledesign(DriverDashboardState state, BuildContext context) {
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
    else if(state._tabmainController.index == 3){

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
                  "RTI Date",
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
                  "RTI No",
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
              ),
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
                  Tab(text: 'SALARY'),
                  Tab(text: 'Summon Entry'),
                  Tab(text: 'PDO'),

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
                  else if(state._tabmainController.index == 3){

                    state.loadSalaryData();
                  }
                  else if (index == 4) {

                    state.loadTruckList();
                  }
                  else if (state._tabmainController.index == 5) {

                    state.loaddata();
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
                                state.DriverExpiryList.length,
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
                                                          flex: 4,
                                                          child: Container(
                                                            color: colour.commonColor,
                                                            padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                            child: Text(
                                                              state.
                                                                  DriverExpiryList[
                                                              index]["DriverName"].toString(),
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
                                                              "License Exp :",
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
                                                              state.DriverExpiryList[
                                                              index]["licenseExp"]== null ? " " : state.DriverExpiryList[
                                                              index]["licenseExp"],
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
                                                                    color:colour.commonColor,
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
                                                              "GDL Exp :",
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
                                                              state.DriverExpiryList[
                                                              index]["GDLExp"] == null ? " ": state.DriverExpiryList[
                                                              index]["GDLExp"],
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
                                                              "KuantanPort :",
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
                                                              state.DriverExpiryList[
                                                              index]["KuantanPort"] == null ? " ": state.DriverExpiryList[
                                                              index]["KuantanPort"],
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
                                                                    color:colour.commonColor,
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
                                                              "NorthportPort :",
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
                                                              state.DriverExpiryList[
                                                              index]["NorthportPort"] ==null ? " ":state.DriverExpiryList[
                                                              index]["NorthportPort"],
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
                                                              "PkfzPort :",
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
                                                              state.DriverExpiryList[
                                                              index]["PkfzPort"] == null ? "" : state.DriverExpiryList[
                                                              index]["PkfzPort"],
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
                                                              "KliaPort :",
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
                                                              state.DriverExpiryList[
                                                              index]["KliaPort"] == null ? "" : state.DriverExpiryList[
                                                              index]["KliaPort"],
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
                                                              "PguPort :",
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
                                                              state.DriverExpiryList[
                                                              index]["PguPort"] == null ? "" : state.DriverExpiryList[
                                                              index]["PguPort"],
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
                                                                    color:colour.commonColor,
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
                                                              "TanjungPort :",
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
                                                              state.DriverExpiryList[
                                                              index]["TanjungPort"] == null ? "" : state.DriverExpiryList[
                                                              index]["TanjungPort"],
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
                                                              "PenangPort :",
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
                                                              state.DriverExpiryList[
                                                              index]["PenangPort"] == null ? "" : state.DriverExpiryList[
                                                              index]["PenangPort"],
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
                                                              "PtpPort :",
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
                                                              state.DriverExpiryList[
                                                              index]["PtpPort"] == null ? "" : state.DriverExpiryList[
                                                              index]["PtpPort"],
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
                                                              "WestportPort :",
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
                                                        Expanded(
                                                          flex: 3,
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(1),
                                                            child: Text(
                                                              state.DriverExpiryList[
                                                              index]["WestportPort"] == null ? "" : state.DriverExpiryList[
                                                              index]["WestportPort"],
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
                                                                  "SSaleDate"]
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
                                                                    "CNumberDisplay"]
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
                                                                  "JobNo"]
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
                                                                    "Amount"]
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

// ---------- Summon Dropdown ----------
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
                                        state.RdtpFromDate.toString())),
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
                                    state.RdtpFromDate =
                                        DateFormat("yyyy-MM-dd")
                                            .format(datenew);
                                  });
                                  state.loaddata();

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
                                    state.RdtpToDate.toString())),
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
                                    state.RdtpToDate =
                                        DateFormat("yyyy-MM-dd")
                                            .format(datenew);
                                  });
                                  state.loaddata();
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
                      SizedBox(height: 12),
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

                      // 🔹 LIST
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.filteredRTIMasterList.length,
                          itemBuilder: (context, index) {
                            final m = state.filteredRTIMasterList[index];

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
                                          Checkbox(value: d.isChecked,
                                          onChanged: (value){
                                                    state.setState((){
                                                      d.isChecked = value ?? false;
                                                      d.Active = d.isChecked ? 1 : 0;
                                                    });
                                              }
                                          ),
                                          Wrap(
                                            spacing: 10,
                                            runSpacing: 10,
                                            children: [
                                              ElevatedButton.icon(
                                                onPressed: () async {
                                                  await state.pickImage(d, true);
                                                  state.setState(() {});
                                                },
                                                icon: Icon(Icons.camera_alt),
                                                label: Text("Camera"),
                                              ),
                                              ElevatedButton.icon(
                                                onPressed: () async {
                                                  await state.pickImage(d, false);
                                                  state.setState(() {});
                                                },
                                                icon: Icon(Icons.photo_library),
                                                label: Text("Gallery"),
                                              ),
                                              buildImage(d.imagePath, context),

                                            ],
                                          ),

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
                                                  "Active": x.isChecked ? 1 : 0,
                                                  "ImagePath": x.imagePath,
                                                }).toList();
                                                state.SaveRTIData(context);
                                                for(var item in state.selectedDetails){
                                                  print("Saving JobNo: ${item}");
                                                }
                                              },
                                              child: Text('Save')
                                          )

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
                )


        ],
            ),
          )));
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

Widget buildInputField(String label, TextEditingController controller,
    String errorMessage,
    {bool isNumber = false}) {
  return TextFormField(
    controller: controller,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey[50],
    ),
    validator: (value) => value!.isEmpty ? errorMessage : null,
  );
}

const String BASE_URL = "https://maleva.my";

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
