part of 'package:maleva/DashBoard/TransportDB/TransportDashboard.dart';


tabletdesign(TransportDashboardState state, BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;
  // objfun.FontMedium = 26;s
  // objfun.FontLow = 22;
  // objfun.FontLarge = 30;
  // objfun.FontCardText = 20;
  objfun.FontMedium = 22;
  objfun.FontLow = 18;
  objfun.FontLarge = 24;
  objfun.FontCardText = 16;

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
  return WillPopScope(
      onWillPop: state._onBackPressed,
      child: DefaultTabController(
          length: 4,
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

                  Tab(text: 'TRANSPORT'),
                  Tab(text: 'ENQ'),
                  Tab(text: 'EmailInbox'),
                  Tab(text: 'GoogleReview'),
                  Tab(text: 'PDO'),

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
                    state.IsPlanToday = true;
                    state.Invoicewiseview = true;
                    state.loadPlanningdata(0);
                  } else if (state._tabmainController.index == 2) {
                    state.Invoicewiseview = true;
                    state.loadEnqdata();
                  }
                  else if (state._tabmainController.index == 3) {
                    //state.Invoicewiseview = true;
                    state._loadEmployee();
                  }
                  else if (state._tabmainController.index == 4) {
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
                              value: TransportDashboardState.RulesTypeEmployee.any(
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
                              items: TransportDashboardState.RulesTypeEmployee.map<DropdownMenuItem<String>>(
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
                                      const AddEnquiryTR()));
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
                                                        AddEnquiryTR(
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