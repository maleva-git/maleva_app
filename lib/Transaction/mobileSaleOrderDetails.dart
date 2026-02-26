part of 'package:maleva/Transaction/SaleOrderDetails.dart';

mobiledesign(SaleOrderDetailsState state, BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;

  Future<void> showDialogPickUpAddress() async {
    // flutter defined function
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Dialog(
                    elevation: 40.0,
                    child: Container(
                        width: width * 0.65,
                        height: height * 0.65,
                        alignment: Alignment.center,
                        margin:
                        const EdgeInsets.only(right: 15.0, left: 15.0, top: 7),
                        child: Column(children: [
                          ListView(shrinkWrap: true, children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 8,
                                  child: Container(),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: FloatingActionButton(
                                    backgroundColor: colour.commonColor,
                                    onPressed: () => setState(() {

                                      Navigator.of(context, rootNavigator: true)
                                          .pop(context);
                                    }),
                                    heroTag: "btn5",
                                    tooltip: 'Close',
                                    child: const Icon(
                                      Icons.close,
                                      color: colour.ButtonForeColor,
                                      size: 25.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Center(
                                child: Container(
                                  color: colour.commonColor,
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  child: Text(
                                    "PickUp Address List",
                                    maxLines: 1,
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                          color: colour.ButtonForeColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: objfun.FontMedium,
                                          overflow: TextOverflow.ellipsis,
                                          letterSpacing: 1.3),
                                    ),
                                  ),
                                )),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: height * 0.50,
                              child: (state.PickUpAddressList.isNotEmpty
                                  ? Container(
                                  height: 70,
                                  margin: const EdgeInsets.all(0),
                                  padding:
                                  const EdgeInsets.only(left: 0, right: 0),
                                  child: ListView.builder(
                                      itemCount: state.PickUpAddressList.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return InkWell(
                                            onLongPress: () async {
                                              bool result = await objfun
                                                  .ConfirmationMsgYesNo(context,
                                                  "Are you sure to delete ?");
                                              if (result == true) {
                                                setState(() {
                                                  state.PickUpAddressList.removeAt(
                                                      index);
                                                });
                                              }
                                            },
                                            onTap: () {
                                              state.txtPickUpAddress.text =
                                              state.PickUpAddressList[index];
                                              Navigator.of(context,
                                                  rootNavigator: true)
                                                  .pop(context);
                                            },
                                            child: SizedBox(
                                              height: 85,
                                              child: Card(
                                                //margin: EdgeInsets.all(10.0),
                                                  elevation: 10.0,
                                                  borderOnForeground: true,
                                                  semanticContainer: true,
                                                  shape: RoundedRectangleBorder(
                                                    side: const BorderSide(
                                                        color:
                                                        colour.commonColor,
                                                        width: 1),
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        10),
                                                  ),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .center,
                                                    children: [
                                                      Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                          padding:
                                                          const EdgeInsets.all(5),
                                                          child: Text(
                                                            state.PickUpAddressList[
                                                            index]
                                                                .toString(),
                                                            textAlign: TextAlign
                                                                .justify,
                                                            /*overflow:
                                                          TextOverflow.ellipsis,*/
                                                            style: GoogleFonts
                                                                .lato(
                                                              textStyle: TextStyle(
                                                                  color: colour
                                                                      .commonColor,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                  fontSize: objfun
                                                                      .FontLow,
                                                                  letterSpacing:
                                                                  0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                            ));
                                      }))
                                  : Container(
                                  width: 40.0,
                                  height: 60,
                                  padding: const EdgeInsets.all(20),
                                  child: const Center(
                                    child: Text('No Record'),
                                  ))),
                            ),
                          ]),
                        ])));
              });
        });
  }
  Future<void> showDialogDeliveryAddress() async {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    // flutter defined function
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Dialog(
                    elevation: 40.0,
                    child: Container(
                        width: width * 0.65,
                        height: height * 0.65,
                        alignment: Alignment.center,
                        margin:
                        const EdgeInsets.only(right: 15.0, left: 15.0, top: 7),
                        child: Column(children: [
                          ListView(shrinkWrap: true, children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 8,
                                  child: Container(),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: FloatingActionButton(
                                    backgroundColor: colour.commonColor,
                                    onPressed: () => setState(() {

                                      Navigator.of(context, rootNavigator: true)
                                          .pop(context);
                                    }),
                                    heroTag: "btn5",
                                    tooltip: 'Close',
                                    child: const Icon(
                                      Icons.close,
                                      color: colour.ButtonForeColor,
                                      size: 25.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Center(
                                child: Container(
                                  color: colour.commonColor,
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                  child: Text(
                                    "Delivery Address List",
                                    maxLines: 1,
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                          color: colour.ButtonForeColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: objfun.FontMedium,
                                          overflow: TextOverflow.ellipsis,
                                          letterSpacing: 1.3),
                                    ),
                                  ),
                                )),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: height * 0.50,
                              child: (state.DeliveryAddressList.isNotEmpty
                                  ? Container(
                                  height: 70,
                                  margin: const EdgeInsets.all(0),
                                  padding:
                                  const EdgeInsets.only(left: 0, right: 0),
                                  child: ListView.builder(
                                      itemCount: state.DeliveryAddressList.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return InkWell(
                                            onLongPress: () async {
                                              bool result = await objfun
                                                  .ConfirmationMsgYesNo(context,
                                                  "Are you sure to delete ?");
                                              if (result == true) {
                                                setState(() {
                                                  state.DeliveryAddressList.removeAt(
                                                      index);
                                                });
                                              }
                                            },
                                            onTap: () {
                                              state.txtDeliveryAddress.text =
                                              state.DeliveryAddressList[index];
                                              Navigator.of(context,
                                                  rootNavigator: true)
                                                  .pop(context);
                                            },
                                            child: SizedBox(
                                              height: 85,
                                              child: Card(
                                                //margin: EdgeInsets.all(10.0),
                                                  elevation: 10.0,
                                                  borderOnForeground: true,
                                                  semanticContainer: true,
                                                  shape: RoundedRectangleBorder(
                                                    side: const BorderSide(
                                                        color:
                                                        colour.commonColor,
                                                        width: 1),
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        10),
                                                  ),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .center,
                                                    children: [
                                                      Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                          padding:
                                                          const EdgeInsets.all(5),
                                                          child: Text(
                                                            state.DeliveryAddressList[
                                                            index]
                                                                .toString(),
                                                            textAlign: TextAlign
                                                                .justify,
                                                            /*overflow:
                                                          TextOverflow.ellipsis,*/
                                                            style: GoogleFonts
                                                                .lato(
                                                              textStyle: TextStyle(
                                                                  color: colour
                                                                      .commonColor,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                  fontSize: objfun
                                                                      .FontLow,
                                                                  letterSpacing:
                                                                  0.3),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                            ));
                                      }))
                                  : Container(
                                  width: 40.0,
                                  height: 60,
                                  padding: const EdgeInsets.all(20),
                                  child: const Center(
                                    child: Text('No Record'),
                                  ))),
                            ),
                          ]),
                        ])));
              });
        });
  }
  Future<bool> onBackPressed() async {
    Navigator.of(context).pop();
    return true;
  }
  return WillPopScope(
      onWillPop: onBackPressed,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: SizedBox(
            height: height * 0.05,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sales Order',
                    style: GoogleFonts.lato(
                        textStyle:TextStyle(
                          color: colour.topAppBarColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Alatsi',
                          fontSize: objfun.FontLow,
                        ))),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(state.UserName,
                          style: GoogleFonts.lato(
                              textStyle:TextStyle(
                                color: colour.commonColorLight,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Alatsi',
                                fontSize: objfun.FontLow - 2,
                              ))),
                    ]),

              ],
            ),
          ),
          actions: const [

          ],
          iconTheme: const IconThemeData(color: colour.topAppBarColor),

        ),
        drawer: const Menulist(),
        body: state.progress == false
            ? const Center(
          child: SpinKitFoldingCube(
            color: colour.spinKitColor,
            size: 35.0,
          ),
        )
            : DefaultTabController(
          length: 5,
          child: TabBarView(
              controller: state._tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 15.0, left: 15.0, right: 15.0),
                  child: ListView(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const SizedBox(
                            width: 7,
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              "Job No :",
                              style: GoogleFonts.lato(
                                  textStyle:TextStyle(
                                      fontSize: objfun.FontLow,
                                      fontWeight: FontWeight.bold,
                                      color: colour.commonColor)),
                            ),
                          ),
                          Expanded(
                              flex: 2,
                              child: Container(
                                height: 50,
                                padding: const EdgeInsets.only(left: 8),
                                margin: const EdgeInsets.only(
                                    left: 5, right: 5.0),
                                decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(10.0),
                                    color: colour.commonColorLight,
                                    border: Border.all()),
                                child: TextField(
                                  cursorColor: colour.commonColor,
                                  controller: state.txtJobNo,
                                  autofocus: true,
                                  showCursor: true,
                                  enabled: false,
                                  textInputAction: TextInputAction.done,
                                  textCapitalization:
                                  TextCapitalization.characters,
                                  style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                        color: colour.commonColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: objfun.FontLow - 2,
                                        letterSpacing: 0.3),
                                  ),
                                ),
                              )),
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 50,
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 5.0),
                              decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(10.0),
                                  color: colour.commonColorLight,
                                  border: Border.all()),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Text(
                                      width <= 370
                                          ? DateFormat("dd-MM-yy")
                                          .format(DateTime.parse(
                                          state.dtpSaleOrderdate
                                              .toString()))
                                          : DateFormat("dd-MM-yyyy")
                                          .format(DateTime.parse(
                                          state.dtpSaleOrderdate
                                              .toString())),
                                      style: GoogleFonts.lato(
                                          textStyle:TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: objfun.FontLow,
                                              color: colour.commonColor)),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: InkWell(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: objfun.calendar
                                            // fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        /*      showDatePicker(
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
                                                    state.dtpSaleOrderdate =
                                                        DateFormat("yyyy-MM-dd")
                                                            .format(datenew);
                                                  });
                                                });*/
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 7,
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [

                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.only(
                                left: 10.0,
                                right: 10.0,
                              ),
                              decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(10.0),
                                  color: colour.commonColorLight,
                                  border: Border.all()),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton(
                                  isExpanded: true,
                                  value: state.dropdownValue,
                                  onChanged: state.DisabledBillType
                                      ? null
                                      : (String? value) async {
                                    await OnlineApi
                                        .MaxSaleOrderNo(
                                        context, value!);
                                    state.setState(() {
                                      state.dropdownValue = value;
                                      state.txtJobNo.text =
                                          objfun.MaxSaleOrderNum;
                                      // loaddata();
                                    });
                                  },
                                  style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                        color: colour.commonColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: objfun.FontMedium,
                                        letterSpacing: 0.3),
                                  ),
                                  items: SaleOrderDetailsState.BillType.map<
                                      DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style:
                                            GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  color: colour.commonColor,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  fontSize:
                                                  objfun.FontMedium,
                                                  letterSpacing: 0.3),
                                            ),
                                          ),
                                        );
                                      }).toList(),
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
                        height: height * 0.06,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                width: objfun.SizeConfig
                                    .safeBlockHorizontal *
                                    99,
                                height: objfun
                                    .SizeConfig.safeBlockVertical *
                                    7,
                                alignment: Alignment.topCenter,
                                padding:
                                const EdgeInsets.only(bottom: 5),
                                child: TextField(
                                  textCapitalization:
                                  TextCapitalization.characters,
                                  controller: state.txtCustomer,
                                  textInputAction: TextInputAction.done,
                                  keyboardType: TextInputType.name,
                                  readOnly: true,

                                  style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                        color: colour.commonColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: objfun.FontLow,
                                        letterSpacing: 0.3),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Customer Name",
                                    hintStyle: GoogleFonts.lato(
                                        textStyle:TextStyle(
                                            fontSize: objfun.FontMedium,
                                            fontWeight: FontWeight.bold,
                                            color: colour.commonColorLight)),

                                    fillColor: Colors.black,
                                    enabledBorder:
                                    const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide: BorderSide(
                                          color: colour.commonColor),
                                    ),
                                    focusedBorder:
                                    const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide: BorderSide(
                                          color: colour.commonColorred),
                                    ),
                                    contentPadding:
                                    const EdgeInsets.only(
                                        left: 10,
                                        right: 20,
                                        top: 10.0),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      SizedBox(
                        height: height * 0.06,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                width: objfun.SizeConfig
                                    .safeBlockHorizontal *
                                    99,
                                height: objfun
                                    .SizeConfig.safeBlockVertical *
                                    7,
                                alignment: Alignment.topCenter,
                                padding:
                                const EdgeInsets.only(bottom: 5),
                                child: TextField(
                                  textCapitalization:
                                  TextCapitalization.characters,
                                  controller: state.txtJobType,
                                  textInputAction: TextInputAction.done,
                                  keyboardType: TextInputType.name,
                                  readOnly: true,
                                  style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                        color: colour.commonColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: objfun.FontLow,
                                        letterSpacing: 0.3),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Job Type",
                                    hintStyle: GoogleFonts.lato(
                                        textStyle:TextStyle(
                                            fontSize: objfun.FontMedium,
                                            fontWeight: FontWeight.bold,
                                            color: colour.commonColorLight)),

                                    fillColor: Colors.black,
                                    enabledBorder:
                                    const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide: BorderSide(
                                          color: colour.commonColor),
                                    ),
                                    focusedBorder:
                                    const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide: BorderSide(
                                          color: colour.commonColorred),
                                    ),
                                    contentPadding:
                                    const EdgeInsets.only(
                                        left: 10,
                                        right: 20,
                                        top: 10.0),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      SizedBox(
                        height: height * 0.06,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                width: objfun.SizeConfig
                                    .safeBlockHorizontal *
                                    99,
                                height: objfun
                                    .SizeConfig.safeBlockVertical *
                                    7,
                                alignment: Alignment.topCenter,
                                padding:
                                const EdgeInsets.only(bottom: 5),
                                child: TextField(
                                  textCapitalization:
                                  TextCapitalization.characters,
                                  controller: state.txtJobStatus,
                                  textInputAction: TextInputAction.done,
                                  keyboardType: TextInputType.name,
                                  readOnly: true,
                                  style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                        color: colour.commonColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: objfun.FontLow,
                                        letterSpacing: 0.3),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Job Status",
                                    hintStyle:GoogleFonts.lato(
                                        textStyle: TextStyle(
                                            fontSize: objfun.FontMedium,
                                            fontWeight: FontWeight.bold,
                                            color: colour.commonColorLight)),

                                    fillColor: Colors.black,
                                    enabledBorder:
                                    const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide: BorderSide(
                                          color: colour.commonColor),
                                    ),
                                    focusedBorder:
                                    const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide: BorderSide(
                                          color: colour.commonColorred),
                                    ),
                                    contentPadding:
                                    const EdgeInsets.only(
                                        left: 10,
                                        right: 20,
                                        top: 10.0),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 3,
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
                                showCursor: false,
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: ('Remarks'),
                                  hintStyle:GoogleFonts.lato(
                                      textStyle: TextStyle(
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
                      const SizedBox(
                        height: 3,
                      ),
                      SizedBox(
                        height: height * 0.10,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: TextField(
                                cursorColor: colour.commonColor,
                                controller: state.txtDoDescription,
                                maxLines: null, // Set this
                                expands: true, // and this
                                keyboardType: TextInputType.multiline,
                                autofocus: false,
                                showCursor: false,
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: ('Do Description'),
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

                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 20.0, left: 15.0, right: 15.0),
                  child: ListView(
                    children: <Widget>[
                      SizedBox(
                        height: height * 0.06,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                width: objfun.SizeConfig
                                    .safeBlockHorizontal *
                                    99,
                                height: objfun
                                    .SizeConfig.safeBlockVertical *
                                    7,
                                alignment: Alignment.topCenter,
                                padding:
                                const EdgeInsets.only(bottom: 5),
                                child: TextField(
                                  textCapitalization:
                                  TextCapitalization.characters,
                                  controller: state.txtCommodityType,
                                  textInputAction: TextInputAction.done,
                                  keyboardType: TextInputType.name,
                                  readOnly: true,
                                  style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                        color: colour.commonColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: objfun.FontLow,
                                        letterSpacing: 0.3),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Commodity Type",
                                    hintStyle:GoogleFonts.lato(
                                        textStyle: TextStyle(
                                            fontSize: objfun.FontMedium,
                                            fontWeight: FontWeight.bold,
                                            color: colour.commonColorLight)),

                                    fillColor: Colors.black,
                                    enabledBorder:
                                    const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide: BorderSide(
                                          color: colour.commonColor),
                                    ),
                                    focusedBorder:
                                    const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide: BorderSide(
                                          color: colour.commonColorred),
                                    ),
                                    contentPadding:
                                    const EdgeInsets.only(
                                        left: 10,
                                        right: 20,
                                        top: 10.0),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      SizedBox(
                        height: height * 0.06,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: TextField(
                                cursorColor: colour.commonColor,
                                controller: state.txtWeight,
                                autofocus: false,
                                showCursor: false,
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: ('Weight'),
                                  hintStyle:GoogleFonts.lato(
                                      textStyle: TextStyle(
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
                      const SizedBox(
                        height: 3,
                      ),
                      SizedBox(
                        height: height * 0.06,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: TextField(
                                cursorColor: colour.commonColor,
                                controller: state.txtQuantity,
                                autofocus: false,
                                showCursor: false,
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: ('Quantity'),
                                  hintStyle:GoogleFonts.lato(
                                      textStyle: TextStyle(
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
                                keyboardType: TextInputType.text,
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
                      const SizedBox(
                        height: 3,
                      ),
                      SizedBox(
                        height: height * 0.06,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: TextField(
                                cursorColor: colour.commonColor,
                                controller: state.txtTruckSize,
                                autofocus: false,
                                showCursor: false,
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: ('Truck Size'),
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
                                keyboardType: TextInputType.text,
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
                      const SizedBox(
                        height: 3,
                      ),
                      Visibility(
                          visible: state.VisibleAWBNo,
                          child: Column(
                            children: [
                              SizedBox(
                                height: height * 0.06,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: TextField(
                                        cursorColor: colour.commonColor,
                                        controller: state.txtAWBNo,
                                        autofocus: false,
                                        showCursor:false,
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          hintText: ('AWB NO'),
                                          hintStyle:GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  fontSize:
                                                  objfun.FontMedium,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  color: colour
                                                      .commonColorLight)),
                                          fillColor: colour.commonColor,
                                          enabledBorder:
                                          const OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.all(
                                                Radius.circular(
                                                    10.0)),
                                            borderSide: BorderSide(
                                                color:
                                                colour.commonColor),
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
                                        textInputAction:
                                        TextInputAction.done,
                                        textCapitalization:
                                        TextCapitalization
                                            .characters,
                                        style:
                                        GoogleFonts.lato(
                                          textStyle: TextStyle(
                                              color: colour.commonColor,
                                              fontWeight:
                                              FontWeight.bold,
                                              fontSize: objfun.FontLow,
                                              letterSpacing: 0.3),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                            ],
                          )),
                      Visibility(
                          visible: state.VisibleBLCopy,
                          child: Column(
                            children: [
                              SizedBox(
                                height: height * 0.06,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: TextField(
                                        cursorColor: colour.commonColor,
                                        controller: state.txtBLCopy,
                                        autofocus: false,
                                        showCursor: false,
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          hintText: ('BL Copy'),
                                          hintStyle: GoogleFonts.lato(
                                              textStyle:TextStyle(
                                                  fontSize:
                                                  objfun.FontMedium,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  color: colour
                                                      .commonColorLight)),
                                          fillColor: colour.commonColor,
                                          enabledBorder:
                                          const OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.all(
                                                Radius.circular(
                                                    10.0)),
                                            borderSide: BorderSide(
                                                color:
                                                colour.commonColor),
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
                                        keyboardType:
                                        TextInputType.text,
                                        textInputAction:
                                        TextInputAction.done,
                                        textCapitalization:
                                        TextCapitalization
                                            .characters,
                                        style:
                                        GoogleFonts.lato(
                                          textStyle: TextStyle(
                                              color: colour.commonColor,
                                              fontWeight:
                                              FontWeight.bold,
                                              fontSize: objfun.FontLow,
                                              letterSpacing: 0.3),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                            ],
                          )),
                      SizedBox(
                        height: height * 0.06,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                width: objfun.SizeConfig
                                    .safeBlockHorizontal *
                                    99,
                                height: objfun
                                    .SizeConfig.safeBlockVertical *
                                    7,
                                alignment: Alignment.topCenter,
                                padding:
                                const EdgeInsets.only(bottom: 5),
                                child: TextField(
                                  textCapitalization:
                                  TextCapitalization.characters,
                                  controller: state.txtCargo,
                                  textInputAction: TextInputAction.done,
                                  keyboardType: TextInputType.name,
                                  readOnly: true,
                                  style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                        color: colour.commonColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: objfun.FontLow,
                                        letterSpacing: 0.3),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Cargo",
                                    hintStyle: GoogleFonts.lato(
                                        textStyle:TextStyle(
                                            fontSize: objfun.FontMedium,
                                            fontWeight: FontWeight.bold,
                                            color: colour.commonColorLight)),

                                    fillColor: Colors.black,
                                    enabledBorder:
                                    const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide: BorderSide(
                                          color: colour.commonColor),
                                    ),
                                    focusedBorder:
                                    const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide: BorderSide(
                                          color: colour.commonColorred),
                                    ),
                                    contentPadding:
                                    const EdgeInsets.only(
                                        left: 10,
                                        right: 20,
                                        top: 10.0),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      SizedBox(
                        height: height * 0.06,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: TextField(
                                cursorColor: colour.commonColor,
                                controller: state.txtPTWNo,
                                autofocus: false,
                                showCursor: false,
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: ('PTW No'),
                                  hintStyle:GoogleFonts.lato(
                                      textStyle: TextStyle(
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
                                keyboardType: TextInputType.text,
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
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 20.0, left: 15.0, right: 15.0),
                  child: ListView(
                    children: <Widget>[
                      Visibility(
                          visible: state.VisibleLETA,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  const SizedBox(
                                    width: 7,
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: Text(
                                        "ETA ",
                                        style:GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                fontSize: objfun.FontMedium,
                                                color: colour.commonColor,
                                                fontWeight:
                                                FontWeight.bold)),
                                        textAlign: TextAlign.center,
                                      )),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Container(
                                      height: 50,
                                      padding: const EdgeInsets.only(
                                          left: 10.0, right: 5.0),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(
                                              10.0),
                                          color: state.checkBoxValueLETA ==
                                              true
                                              ? colour.commonColorLight
                                              : colour
                                              .commonColorDisabled,
                                          border: Border.all()),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            child: Text(
                                              DateFormat(
                                                  "dd-MM-yyyy HH:mm:ss")
                                                  .format(DateTime
                                                  .parse(state.dtpLETAdate
                                                  .toString())),
                                              style:GoogleFonts.lato(
                                                  textStyle: TextStyle(
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    fontSize:
                                                    objfun.FontMedium,
                                                    color: state.checkBoxValueLETA ==
                                                        true
                                                        ? colour.commonColor
                                                        : colour
                                                        .commonColorDisabled,
                                                  )),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: InkWell(
                                              child: Container(
                                                width: 25,
                                                height: 35,
                                                decoration:
                                                BoxDecoration(
                                                  image:
                                                  DecorationImage(
                                                    image:
                                                    objfun.calendar,
                                                    //fit: BoxFit.fill,
                                                  ),
                                                ),
                                              ),
                                              onTap: () async {

                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: Transform.scale(
                                        scale: 1.3,
                                        child: Checkbox(
                                            value: state.checkBoxValueLETA,
                                            side: const BorderSide(
                                                color:
                                                colour.commonColor),
                                            activeColor:
                                            colour.commonColorred,
                                            onChanged: null
                                        ),
                                      )),
                                ],
                              ),
                              const SizedBox(height: 5),
                            ],
                          )),
                      Visibility(
                          visible: state.VisibleLETB,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  const SizedBox(
                                    width: 7,
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: Text(
                                        "ETB ",
                                        style: GoogleFonts.lato(
                                            textStyle:TextStyle(
                                                fontSize: objfun.FontMedium,
                                                color: colour.commonColor,
                                                fontWeight:
                                                FontWeight.bold)),
                                        textAlign: TextAlign.center,
                                      )),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Container(
                                      height: 50,
                                      padding: const EdgeInsets.only(
                                          left: 10.0, right: 5.0),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(
                                              10.0),
                                          color: state.checkBoxValueLETB ==
                                              true
                                              ? colour.commonColorLight
                                              : colour
                                              .commonColorDisabled,
                                          border: Border.all()),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            child: Text(
                                              DateFormat(
                                                  "dd-MM-yyyy HH:mm:ss")
                                                  .format(DateTime
                                                  .parse(state.dtpLETBdate
                                                  .toString())),
                                              style: GoogleFonts.lato(
                                                  textStyle:TextStyle(
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    fontSize:
                                                    objfun.FontMedium,
                                                    color: state.checkBoxValueLETB ==
                                                        true
                                                        ? colour.commonColor
                                                        : colour
                                                        .commonColorDisabled,
                                                  )),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: InkWell(
                                              child: Container(
                                                width: 25,
                                                height: 35,
                                                decoration:
                                                BoxDecoration(
                                                  image:
                                                  DecorationImage(
                                                    image:
                                                    objfun.calendar,
                                                    //fit: BoxFit.fill,
                                                  ),
                                                ),
                                              ),
                                              onTap: () async {

                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: Transform.scale(
                                        scale: 1.3,
                                        child: Checkbox(
                                            value: state.checkBoxValueLETB,
                                            side: const BorderSide(
                                                color:
                                                colour.commonColor),
                                            activeColor:
                                            colour.commonColorred,
                                            onChanged: null
                                        ),
                                      )),
                                ],
                              ),
                              const SizedBox(height: 5),
                            ],
                          )),
                      Visibility(
                        visible: state.VisibleLETD,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const SizedBox(
                                  width: 7,
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                      "ETD ",
                                      style: GoogleFonts.lato(
                                          textStyle:TextStyle(
                                              fontSize: objfun.FontMedium,
                                              color: colour.commonColor,
                                              fontWeight: FontWeight.bold)),
                                      textAlign: TextAlign.center,
                                    )),
                                const SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    height: 50,
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 5.0),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(10.0),
                                        color: state.checkBoxValueLETD == true
                                            ? colour.commonColorLight
                                            : colour
                                            .commonColorDisabled,
                                        border: Border.all()),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: Text(
                                            DateFormat(
                                                "dd-MM-yyyy HH:mm:ss")
                                                .format(DateTime.parse(
                                                state.dtpLETDdate
                                                    .toString())),
                                            style:GoogleFonts.lato(
                                                textStyle: TextStyle(
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  fontSize:
                                                  objfun.FontMedium,
                                                  color: state.checkBoxValueLETD ==
                                                      true
                                                      ? colour.commonColor
                                                      : colour
                                                      .commonColorDisabled,
                                                )),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: InkWell(
                                            child: Container(
                                              width: 25,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image:
                                                  objfun.calendar,
                                                  //fit: BoxFit.fill,
                                                ),
                                              ),
                                            ),
                                            onTap: () async {

                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Transform.scale(
                                      scale: 1.3,
                                      child: Checkbox(
                                          value: state.checkBoxValueLETD,
                                          side: const BorderSide(
                                              color: colour.commonColor),
                                          activeColor:
                                          colour.commonColorred,
                                          onChanged: null
                                      ),
                                    )),
                              ],
                            ),
                            const SizedBox(
                              height: 7,
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                          visible: state.VisibleLShippingAgent,
                          child: Column(
                            children: [
                              SizedBox(
                                height: height * 0.06,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        width: objfun.SizeConfig
                                            .safeBlockHorizontal *
                                            99,
                                        height: objfun.SizeConfig
                                            .safeBlockVertical *
                                            7,
                                        alignment: Alignment.topCenter,
                                        padding: const EdgeInsets.only(
                                            bottom: 5),
                                        child: TextField(
                                          textCapitalization:
                                          TextCapitalization
                                              .characters,
                                          controller: state.txtLAgentCompany,
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
                                            hintText: "Shipping Agent",
                                            hintStyle:GoogleFonts.lato(
                                                textStyle: TextStyle(
                                                    fontSize:
                                                    objfun.FontMedium,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color: colour
                                                        .commonColorLight)),

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
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                            ],
                          )),
                      Visibility(
                          visible: state.VisibleLAgentName,
                          child: Column(
                            children: [
                              SizedBox(
                                height: height * 0.06,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        width: objfun.SizeConfig
                                            .safeBlockHorizontal *
                                            99,
                                        height: objfun.SizeConfig
                                            .safeBlockVertical *
                                            7,
                                        alignment: Alignment.topCenter,
                                        padding: const EdgeInsets.only(
                                            bottom: 5),
                                        child: TextField(
                                          textCapitalization:
                                          TextCapitalization
                                              .characters,
                                          controller: state.txtLAgentName,
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
                                            hintText: "Agent Name",
                                            hintStyle:GoogleFonts.lato(
                                                textStyle: TextStyle(
                                                    fontSize:
                                                    objfun.FontMedium,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color: colour
                                                        .commonColorLight)),

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
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                            ],
                          )),
                      Visibility(
                          visible: state.VisibleLScn,
                          child: SizedBox(
                            height: height * 0.06,
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: TextField(
                                    cursorColor: colour.commonColor,
                                    controller: state.txtLSCN,
                                    autofocus: false,
                                    showCursor: false,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      hintText: ('SCN'),
                                      hintStyle: GoogleFonts.lato(
                                          textStyle:TextStyle(
                                              fontSize: objfun.FontMedium,
                                              fontWeight: FontWeight.bold,
                                              color:
                                              colour.commonColorLight)),
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
                                            color:
                                            colour.commonColorred),
                                      ),
                                      contentPadding: const EdgeInsets.only(
                                          left: 10,
                                          right: 20,
                                          top: 10.0),
                                    ),
                                    textInputAction:
                                    TextInputAction.done,
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
                          )),
                      Visibility(
                          visible: state.VisibleLoadingVessel,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 3,
                              ),
                              SizedBox(
                                height: height * 0.06,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: TextField(
                                        cursorColor: colour.commonColor,
                                        controller: state.txtLoadingVessel,
                                        autofocus: false,
                                        showCursor: false,
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          hintText:
                                          ('Loading Vessel Name'),
                                          hintStyle:GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  fontSize:
                                                  objfun.FontMedium,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  color: colour
                                                      .commonColorLight)),
                                          fillColor: colour.commonColor,
                                          enabledBorder:
                                          const OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.all(
                                                Radius.circular(
                                                    10.0)),
                                            borderSide: BorderSide(
                                                color:
                                                colour.commonColor),
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
                                        keyboardType:
                                        TextInputType.text,
                                        textInputAction:
                                        TextInputAction.done,
                                        textCapitalization:
                                        TextCapitalization
                                            .characters,
                                        style:
                                        GoogleFonts.lato(
                                          textStyle: TextStyle(
                                              color: colour.commonColor,
                                              fontWeight:
                                              FontWeight.bold,
                                              fontSize: objfun.FontLow,
                                              letterSpacing: 0.3),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                      const SizedBox(height: 5),
                      Visibility(
                          visible: state.VisibleLPort,
                          child: Column(
                            children: [
                              SizedBox(
                                height: height * 0.06,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        width: objfun.SizeConfig
                                            .safeBlockHorizontal *
                                            99,
                                        height: objfun.SizeConfig
                                            .safeBlockVertical *
                                            7,
                                        alignment: Alignment.topCenter,
                                        padding: const EdgeInsets.only(
                                            bottom: 5),
                                        child: TextField(
                                          textCapitalization:
                                          TextCapitalization
                                              .characters,
                                          controller: state.txtLPort,
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
                                            hintStyle: GoogleFonts.lato(
                                                textStyle:TextStyle(
                                                    fontSize:
                                                    objfun.FontMedium,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color: colour
                                                        .commonColorLight)),

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
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                            ],
                          )),
                      Visibility(
                          visible: state.VisibleLVesselType,
                          child: SizedBox(
                            height: height * 0.06,
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    width: objfun.SizeConfig
                                        .safeBlockHorizontal *
                                        99,
                                    height: objfun.SizeConfig
                                        .safeBlockVertical *
                                        7,
                                    alignment: Alignment.topCenter,
                                    padding: const EdgeInsets.only(
                                        bottom: 5),
                                    child: TextField(
                                      textCapitalization:
                                      TextCapitalization.characters,
                                      controller: state.txtLVesselType,
                                      textInputAction:
                                      TextInputAction.done,
                                      keyboardType: TextInputType.name,
                                      readOnly: true,
                                      style: GoogleFonts.lato(
                                        textStyle: TextStyle(
                                            color: colour.commonColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: objfun.FontLow,
                                            letterSpacing: 0.3),
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "Vessel Type",
                                        hintStyle: GoogleFonts.lato(
                                            textStyle:TextStyle(
                                                fontSize: objfun.FontMedium,
                                                fontWeight: FontWeight.bold,
                                                color: colour
                                                    .commonColorLight)),

                                        fillColor: Colors.black,
                                        enabledBorder:
                                        const OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.all(
                                              Radius.circular(
                                                  10.0)),
                                          borderSide: BorderSide(
                                              color:
                                              colour.commonColor),
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
                                )
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 20.0, left: 15.0, right: 15.0),
                  child: ListView(
                    children: <Widget>[
                      Visibility(
                          visible: state.VisibleOETA,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  const SizedBox(
                                    width: 7,
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: Text(
                                        "ETA ",
                                        style: GoogleFonts.lato(
                                            textStyle:TextStyle(
                                                fontSize: objfun.FontMedium,
                                                color: colour.commonColor,
                                                fontWeight:
                                                FontWeight.bold)),
                                        textAlign: TextAlign.center,
                                      )),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Container(
                                      height: 50,
                                      padding: const EdgeInsets.only(
                                          left: 10.0, right: 5.0),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(
                                              10.0),
                                          color: state.checkBoxValueOETA ==
                                              true
                                              ? colour.commonColorLight
                                              : colour
                                              .commonColorDisabled,
                                          border: Border.all()),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            child: Text(
                                              DateFormat(
                                                  "dd-MM-yyyy HH:mm:ss")
                                                  .format(DateTime
                                                  .parse(state.dtpOETAdate
                                                  .toString())),
                                              style:GoogleFonts.lato(
                                                  textStyle: TextStyle(
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    fontSize:
                                                    objfun.FontMedium,
                                                    color: state.checkBoxValueOETA ==
                                                        true
                                                        ? colour.commonColor
                                                        : colour
                                                        .commonColorDisabled,
                                                  )),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: InkWell(
                                              child: Container(
                                                width: 25,
                                                height: 35,
                                                decoration:
                                                BoxDecoration(
                                                  image:
                                                  DecorationImage(
                                                    image:
                                                    objfun.calendar,
                                                    //fit: BoxFit.fill,
                                                  ),
                                                ),
                                              ),
                                              onTap: () async {

                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: Transform.scale(
                                        scale: 1.3,
                                        child: Checkbox(
                                            value: state.checkBoxValueOETA,
                                            side: const BorderSide(
                                                color:
                                                colour.commonColor),
                                            activeColor:
                                            colour.commonColorred,
                                            onChanged: null
                                        ),
                                      )),
                                ],
                              ),
                              const SizedBox(height: 5),
                            ],
                          )),
                      Visibility(
                          visible: state.VisibleOETB,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  const SizedBox(
                                    width: 7,
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: Text(
                                        "ETB ",
                                        style: GoogleFonts.lato(
                                            textStyle:TextStyle(
                                                fontSize: objfun.FontMedium,
                                                color: colour.commonColor,
                                                fontWeight:
                                                FontWeight.bold)),
                                        textAlign: TextAlign.center,
                                      )),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Container(
                                      height: 50,
                                      padding: const EdgeInsets.only(
                                          left: 10.0, right: 5.0),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(
                                              10.0),
                                          color: state.checkBoxValueOETB ==
                                              true
                                              ? colour.commonColorLight
                                              : colour
                                              .commonColorDisabled,
                                          border: Border.all()),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            child: Text(
                                              DateFormat(
                                                  "dd-MM-yyyy HH:mm:ss")
                                                  .format(DateTime
                                                  .parse(state.dtpOETBdate
                                                  .toString())),
                                              style:GoogleFonts.lato(
                                                  textStyle: TextStyle(
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    fontSize:
                                                    objfun.FontMedium,
                                                    color: state.checkBoxValueOETB ==
                                                        true
                                                        ? colour.commonColor
                                                        : colour
                                                        .commonColorDisabled,
                                                  )),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: InkWell(
                                              child: Container(
                                                width: 25,
                                                height: 35,
                                                decoration:
                                                BoxDecoration(
                                                  image:
                                                  DecorationImage(
                                                    image:
                                                    objfun.calendar,
                                                    //fit: BoxFit.fill,
                                                  ),
                                                ),
                                              ),
                                              onTap: () async {

                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: Transform.scale(
                                        scale: 1.3,
                                        child: Checkbox(
                                            value: state.checkBoxValueOETB,
                                            side: const BorderSide(
                                                color:
                                                colour.commonColor),
                                            activeColor:
                                            colour.commonColorred,
                                            onChanged: null
                                        ),
                                      )),
                                ],
                              ),
                              const SizedBox(height: 5),
                            ],
                          )),
                      Visibility(
                        visible: state.VisibleOETD,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const SizedBox(
                                  width: 7,
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                      "ETD ",
                                      style: GoogleFonts.lato(
                                          textStyle:TextStyle(
                                              fontSize: objfun.FontMedium,
                                              color: colour.commonColor,
                                              fontWeight: FontWeight.bold)),
                                      textAlign: TextAlign.center,
                                    )),
                                const SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    height: 50,
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 5.0),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(10.0),
                                        color: state.checkBoxValueOETD == true
                                            ? colour.commonColorLight
                                            : colour
                                            .commonColorDisabled,
                                        border: Border.all()),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: Text(
                                              DateFormat(
                                                  "dd-MM-yyyy HH:mm:ss")
                                                  .format(DateTime.parse(
                                                  state.dtpOETDdate
                                                      .toString())),
                                              style:GoogleFonts.lato(
                                                textStyle: TextStyle(
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  fontSize:
                                                  objfun.FontMedium,
                                                  color: state.checkBoxValueOETD ==
                                                      true
                                                      ? colour.commonColor
                                                      : colour
                                                      .commonColorDisabled,
                                                ),)
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: InkWell(
                                            child: Container(
                                              width: 25,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image:
                                                  objfun.calendar,
                                                  //fit: BoxFit.fill,
                                                ),
                                              ),
                                            ),
                                            onTap: () async {

                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Transform.scale(
                                      scale: 1.3,
                                      child: Checkbox(
                                          value: state.checkBoxValueOETD,
                                          side: const BorderSide(
                                              color: colour.commonColor),
                                          activeColor:
                                          colour.commonColorred,
                                          onChanged: null
                                      ),
                                    )),
                              ],
                            ),
                            const SizedBox(
                              height: 7,
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                          visible: state.VisibleOShippingAgent,
                          child: Column(
                            children: [
                              SizedBox(
                                height: height * 0.06,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        width: objfun.SizeConfig
                                            .safeBlockHorizontal *
                                            99,
                                        height: objfun.SizeConfig
                                            .safeBlockVertical *
                                            7,
                                        alignment: Alignment.topCenter,
                                        padding: const EdgeInsets.only(
                                            bottom: 5),
                                        child: TextField(
                                          textCapitalization:
                                          TextCapitalization
                                              .characters,
                                          controller: state.txtOAgentCompany,
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
                                            hintText: "Shipping Agent",
                                            hintStyle: GoogleFonts.lato(
                                                textStyle:TextStyle(
                                                    fontSize:
                                                    objfun.FontMedium,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color: colour
                                                        .commonColorLight)),

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
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                            ],
                          )),
                      Visibility(
                          visible: state.VisibleOAgentName,
                          child: Column(
                            children: [
                              SizedBox(
                                height: height * 0.06,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        width: objfun.SizeConfig
                                            .safeBlockHorizontal *
                                            99,
                                        height: objfun.SizeConfig
                                            .safeBlockVertical *
                                            7,
                                        alignment: Alignment.topCenter,
                                        padding: const EdgeInsets.only(
                                            bottom: 5),
                                        child: TextField(
                                          textCapitalization:
                                          TextCapitalization
                                              .characters,
                                          controller: state.txtOAgentName,
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
                                            hintText: "Agent Name",
                                            hintStyle: GoogleFonts.lato(
                                                textStyle:TextStyle(
                                                    fontSize:
                                                    objfun.FontMedium,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color: colour
                                                        .commonColorLight)),

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
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                            ],
                          )),
                      Visibility(
                          visible: state.VisibleOScn,
                          child: SizedBox(
                            height: height * 0.06,
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: TextField(
                                    cursorColor: colour.commonColor,
                                    controller: state.txtOSCN,
                                    autofocus: false,
                                    showCursor: false,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      hintText: ('SCN'),
                                      hintStyle:GoogleFonts.lato(
                                          textStyle: TextStyle(
                                              fontSize: objfun.FontMedium,
                                              fontWeight: FontWeight.bold,
                                              color:
                                              colour.commonColorLight)),
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
                                            color:
                                            colour.commonColorred),
                                      ),
                                      contentPadding: const EdgeInsets.only(
                                          left: 10,
                                          right: 20,
                                          top: 10.0),
                                    ),
                                    textInputAction:
                                    TextInputAction.done,
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
                          )),
                      Visibility(
                          visible: state.VisibleOffVessel,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 3,
                              ),
                              SizedBox(
                                height: height * 0.06,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: TextField(
                                        cursorColor: colour.commonColor,
                                        controller: state.txtOffVessel,
                                        autofocus: false,
                                        showCursor: false,
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          hintText: ('Off Vessel Name'),
                                          hintStyle: GoogleFonts.lato(
                                              textStyle:TextStyle(
                                                  fontSize:
                                                  objfun.FontMedium,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  color: colour
                                                      .commonColorLight)),
                                          fillColor: colour.commonColor,
                                          enabledBorder:
                                          const OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.all(
                                                Radius.circular(
                                                    10.0)),
                                            borderSide: BorderSide(
                                                color:
                                                colour.commonColor),
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
                                        textInputAction:
                                        TextInputAction.done,
                                        textCapitalization:
                                        TextCapitalization
                                            .characters,
                                        style:
                                        GoogleFonts.lato(
                                          textStyle: TextStyle(
                                              color: colour.commonColor,
                                              fontWeight:
                                              FontWeight.bold,
                                              fontSize: objfun.FontLow,
                                              letterSpacing: 0.3),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                      const SizedBox(height: 5),
                      Visibility(
                          visible: state.VisibleOPort,
                          child: Column(
                            children: [
                              SizedBox(
                                height: height * 0.06,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        width: objfun.SizeConfig
                                            .safeBlockHorizontal *
                                            99,
                                        height: objfun.SizeConfig
                                            .safeBlockVertical *
                                            7,
                                        alignment: Alignment.topCenter,
                                        padding: const EdgeInsets.only(
                                            bottom: 5),
                                        child: TextField(
                                          textCapitalization:
                                          TextCapitalization
                                              .characters,
                                          controller: state.txtOPort,
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
                                            hintStyle: GoogleFonts.lato(
                                                textStyle:TextStyle(
                                                    fontSize:
                                                    objfun.FontMedium,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color: colour
                                                        .commonColorLight)),

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
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                            ],
                          )),
                      Visibility(
                          visible: state.VisibleOVesselType,
                          child: SizedBox(
                            height: height * 0.06,
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    width: objfun.SizeConfig
                                        .safeBlockHorizontal *
                                        99,
                                    height: objfun.SizeConfig
                                        .safeBlockVertical *
                                        7,
                                    alignment: Alignment.topCenter,
                                    padding: const EdgeInsets.only(
                                        bottom: 5),
                                    child: TextField(
                                      textCapitalization:
                                      TextCapitalization.characters,
                                      controller: state.txtOVesselType,
                                      textInputAction:
                                      TextInputAction.done,
                                      keyboardType: TextInputType.name,
                                      readOnly: true,
                                      style: GoogleFonts.lato(
                                        textStyle: TextStyle(
                                            color: colour.commonColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: objfun.FontLow,
                                            letterSpacing: 0.3),
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "Vessel Type",
                                        hintStyle: GoogleFonts.lato(
                                            textStyle:TextStyle(
                                                fontSize: objfun.FontMedium,
                                                fontWeight: FontWeight.bold,
                                                color: colour
                                                    .commonColorLight)),

                                        fillColor: Colors.black,
                                        enabledBorder:
                                        const OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.all(
                                              Radius.circular(
                                                  10.0)),
                                          borderSide: BorderSide(
                                              color:
                                              colour.commonColor),
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
                                )
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 20.0, left: 15.0, right: 15.0),
                  child: ListView(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                              flex: 2,
                              child: Text(
                                "PickUp Date",
                                style: GoogleFonts.lato(
                                    textStyle:TextStyle(
                                        fontSize: objfun.FontMedium,
                                        color: colour.commonColor,
                                        fontWeight: FontWeight.bold)),
                                textAlign: TextAlign.left,
                              )),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            flex: 4,
                            child: Container(
                              height: 50,
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 5.0),
                              decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(10.0),
                                  color: state.checkBoxValuePickUp == true
                                      ? colour.commonColorLight
                                      : colour.commonColorDisabled,
                                  border: Border.all()),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      DateFormat("dd-MM-yyyy HH:mm:ss")
                                          .format(DateTime.parse(
                                          state.dtpPickUpdate
                                              .toString())),
                                      style: GoogleFonts.lato(
                                          textStyle:TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: objfun.FontLow,
                                            color: state.checkBoxValuePickUp ==
                                                true
                                                ? colour.commonColor
                                                : colour
                                                .commonColorDisabled,
                                          )),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: InkWell(
                                      child: Container(
                                        width: 25,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: objfun.calendar,
                                            //fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      onTap: () async {

                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                              flex: 1,
                              child: Transform.scale(
                                scale: 1.3,
                                child: Checkbox(
                                    value: state.checkBoxValuePickUp,
                                    side: const BorderSide(
                                        color: colour.commonColor),
                                    activeColor: colour.commonColorred,
                                    onChanged: null
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                              flex: 2,
                              child: Text(
                                "Delivery Date",
                                style: GoogleFonts.lato(
                                    textStyle:TextStyle(
                                        fontSize: objfun.FontMedium,
                                        color: colour.commonColor,
                                        fontWeight: FontWeight.bold)),
                                textAlign: TextAlign.left,
                              )),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            flex: 4,
                            child: Container(
                              height: 50,
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 5.0),
                              decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(10.0),
                                  color: state.checkBoxValueDelivery == true
                                      ? colour.commonColorLight
                                      : colour.commonColorDisabled,
                                  border: Border.all()),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      DateFormat("dd-MM-yyyy HH:mm:ss")
                                          .format(DateTime.parse(
                                          state.dtpDeliverydate
                                              .toString())),
                                      style: GoogleFonts.lato(
                                          textStyle:TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: objfun.FontLow,
                                            color: state.checkBoxValueDelivery ==
                                                true
                                                ? colour.commonColor
                                                : colour
                                                .commonColorDisabled,
                                          )),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: InkWell(
                                      child: Container(
                                        width: 25,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: objfun.calendar,
                                            //fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      onTap: () async {

                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                              flex: 1,
                              child: Transform.scale(
                                scale: 1.3,
                                child: Checkbox(
                                    value: state.checkBoxValueDelivery,
                                    side: const BorderSide(
                                        color: colour.commonColor),
                                    activeColor: colour.commonColorred,
                                    onChanged: null
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                              flex: 2,
                              child: Text(
                                "WareHouse Entry Date",
                                style: GoogleFonts.lato(
                                    textStyle:TextStyle(
                                        fontSize: objfun.FontMedium,
                                        color: colour.commonColor,
                                        fontWeight: FontWeight.bold)),
                                textAlign: TextAlign.left,
                              )),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            flex: 4,
                            child: Container(
                              height: 50,
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 5.0),
                              decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(10.0),
                                  color: state.checkBoxValueWHEntry == true
                                      ? colour.commonColorLight
                                      : colour.commonColorDisabled,
                                  border: Border.all()),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      DateFormat("dd-MM-yyyy HH:mm:ss")
                                          .format(DateTime.parse(
                                          state.dtpWHEntrydate
                                              .toString())),
                                      style: GoogleFonts.lato(
                                          textStyle:TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: objfun.FontLow,
                                            color: state.checkBoxValueWHEntry ==
                                                true
                                                ? colour.commonColor
                                                : colour
                                                .commonColorDisabled,
                                          )),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: InkWell(
                                      child: Container(
                                        width: 25,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: objfun.calendar,
                                            //fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      onTap: () async {

                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                              flex: 1,
                              child: Transform.scale(
                                scale: 1.3,
                                child: Checkbox(
                                    value: state.checkBoxValueWHEntry,
                                    side: const BorderSide(
                                        color: colour.commonColor),
                                    activeColor: colour.commonColorred,
                                    onChanged: null
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                              flex: 2,
                              child: Text(
                                "Warehouse Exit Date",
                                style: GoogleFonts.lato(
                                    textStyle:TextStyle(
                                        fontSize: objfun.FontMedium,
                                        color: colour.commonColor,
                                        fontWeight: FontWeight.bold)),
                                textAlign: TextAlign.left,
                              )),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            flex: 4,
                            child: Container(
                              height: 50,
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 5.0),
                              decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(10.0),
                                  color: state.checkBoxValueWHExit == true
                                      ? colour.commonColorLight
                                      : colour.commonColorDisabled,
                                  border: Border.all()),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      DateFormat("dd-MM-yyyy HH:mm:ss")
                                          .format(DateTime.parse(
                                          state.dtpWHExitdate
                                              .toString())),
                                      style: GoogleFonts.lato(
                                          textStyle:TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: objfun.FontLow,
                                            color: state.checkBoxValueWHExit ==
                                                true
                                                ? colour.commonColor
                                                : colour
                                                .commonColorDisabled,
                                          )),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: InkWell(
                                      child: Container(
                                        width: 25,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: objfun.calendar,
                                            //fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      onTap: () async {

                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                              flex: 1,
                              child: Transform.scale(
                                scale: 1.3,
                                child: Checkbox(
                                    value: state.checkBoxValueWHExit,
                                    side: const BorderSide(
                                        color: colour.commonColor),
                                    activeColor: colour.commonColorred,
                                    onChanged: null
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(
                        height: 7,
                      ),
                      Visibility(
                          visible: state.VisibleOrigin,
                          child: Column(
                            children: [
                              SizedBox(
                                height: height * 0.06,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: TextField(
                                        cursorColor: colour.commonColor,
                                        controller: state.txtOrigin,
                                        autofocus: false,
                                        showCursor: false,
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          hintText: ('Origin'),
                                          hintStyle: GoogleFonts.lato(
                                              textStyle:TextStyle(
                                                  fontSize:
                                                  objfun.FontMedium,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  color: colour
                                                      .commonColorLight)),
                                          fillColor: colour.commonColor,
                                          enabledBorder:
                                          const OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.all(
                                                Radius.circular(
                                                    10.0)),
                                            borderSide: BorderSide(
                                                color:
                                                colour.commonColor),
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
                                        textInputAction:
                                        TextInputAction.done,
                                        textCapitalization:
                                        TextCapitalization
                                            .characters,
                                        style:
                                        GoogleFonts.lato(
                                          textStyle: TextStyle(
                                              color: colour.commonColor,
                                              fontWeight:
                                              FontWeight.bold,
                                              fontSize: objfun.FontLow,
                                              letterSpacing: 0.3),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                            ],
                          )),
                      Visibility(
                          visible: state.VisibleDestination,
                          child: Column(children: [
                            SizedBox(
                              height: height * 0.06,
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                    flex: 1,
                                    child: TextField(
                                      cursorColor: colour.commonColor,
                                      controller: state.txtDestination,
                                      autofocus: false,
                                      showCursor: false,
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        hintText: ('Destination'),
                                        hintStyle:GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                fontSize: objfun.FontMedium,
                                                fontWeight: FontWeight.bold,
                                                color: colour
                                                    .commonColorLight)),
                                        fillColor: colour.commonColor,
                                        enabledBorder:
                                        const OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.all(
                                              Radius.circular(
                                                  10.0)),
                                          borderSide: BorderSide(
                                              color:
                                              colour.commonColor),
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
                                        contentPadding: const EdgeInsets.only(
                                            left: 10,
                                            right: 20,
                                            top: 10.0),
                                      ),
                                      keyboardType: TextInputType.text,
                                      textInputAction:
                                      TextInputAction.done,
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
                            const SizedBox(
                              height: 5,
                            )
                          ])),
                      SizedBox(
                          height: height * 0.15,
                          child: Column(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                        flex: 6,
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                textCapitalization:
                                                TextCapitalization
                                                    .characters,
                                                controller:
                                                state.txtPickUpAddress,
                                                textInputAction:
                                                TextInputAction
                                                    .done,
                                                keyboardType:
                                                TextInputType.name,
                                                showCursor: false,
                                                readOnly: true,
                                                maxLines: null,
                                                expands: true,
                                                style: GoogleFonts
                                                    .lato(
                                                  textStyle: TextStyle(
                                                      color: colour
                                                          .commonColor,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                      fontSize: objfun
                                                          .FontLow,
                                                      letterSpacing:
                                                      0.3),
                                                ),
                                                decoration:
                                                InputDecoration(
                                                  hintText:
                                                  "PickUp Address",
                                                  hintStyle: GoogleFonts.lato(
                                                      textStyle:TextStyle(
                                                          fontSize: objfun
                                                              .FontMedium,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          color: colour
                                                              .commonColorLight)),

                                                  fillColor:
                                                  Colors.black,
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
                                                  const EdgeInsets
                                                      .only(
                                                      left: 20,
                                                      right: 20,
                                                      top: 10.0),
                                                ),
                                              ),
                                            )
                                          ],
                                        )),
                                    Expanded(
                                        flex: 1,
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                                onPressed: () {
                                                  showDialogPickUpAddress();
                                                },
                                                icon: const Icon(
                                                  Icons.list,
                                                  size: 35,
                                                  color: colour
                                                      .commonColor,
                                                )),

                                          ],
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          )),
                      const SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        height: height * 0.15,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 6,
                              child: TextField(
                                textCapitalization:
                                TextCapitalization.characters,
                                controller: state.txtDeliveryAddress,
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.name,
                                maxLines: null,
                                expands: true,
                                readOnly: true,
                                showCursor: false,
                                style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                      color: colour.commonColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: objfun.FontLow,
                                      letterSpacing: 0.3),
                                ),
                                decoration: InputDecoration(
                                  hintText: "Delivery Address",
                                  hintStyle:GoogleFonts.lato(
                                      textStyle: TextStyle(
                                          fontSize: objfun.FontMedium,
                                          fontWeight: FontWeight.bold,
                                          color: colour.commonColorLight)),

                                  fillColor: Colors.black,
                                  enabledBorder:
                                  const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10.0)),
                                    borderSide: BorderSide(
                                        color: colour.commonColor),
                                  ),
                                  focusedBorder:
                                  const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10.0)),
                                    borderSide: BorderSide(
                                        color: colour.commonColorred),
                                  ),
                                  contentPadding: const EdgeInsets.only(
                                      left: 20, right: 20, top: 10.0),
                                ),
                              ),
                            ),
                            Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          showDialogDeliveryAddress();
                                        },
                                        icon: const Icon(
                                          Icons.list,
                                          size: 35,
                                          color: colour.commonColor,
                                        )),

                                  ],
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      SizedBox(
                        height: height * 0.15,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: TextField(
                                textCapitalization:
                                TextCapitalization.characters,
                                controller: state.txtWarehouseAddress,
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.name,
                                maxLines: null,
                                expands: true,
                                showCursor: false,
                                readOnly: true,
                                style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                      color: colour.commonColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: objfun.FontLow,
                                      letterSpacing: 0.3),
                                ),
                                decoration: InputDecoration(
                                  hintText: "Warehouse Address",
                                  hintStyle:GoogleFonts.lato(
                                      textStyle: TextStyle(
                                          fontSize: objfun.FontMedium,
                                          fontWeight: FontWeight.bold,
                                          color: colour.commonColorLight)),

                                  fillColor: Colors.black,
                                  enabledBorder:
                                  const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10.0)),
                                    borderSide: BorderSide(
                                        color: colour.commonColor),
                                  ),
                                  focusedBorder:
                                  const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10.0)),
                                    borderSide: BorderSide(
                                        color: colour.commonColorred),
                                  ),
                                  contentPadding: const EdgeInsets.only(
                                      left: 20, right: 20, top: 10.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 15.0, left: 15.0, right: 15.0),
                  child: ListView(
                    children: <Widget>[
                      Visibility(
                          visible: state.VisibleFORWARDING,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      flex: 1,
                                      child: IconButton(
                                          onPressed: () {
                                            state.setState(() {
                                              state.VisibleFW1 =
                                              state.VisibleFW1 == false
                                                  ? true
                                                  : false;
                                            });
                                          },
                                          icon: Icon(
                                            state.VisibleFW1 == false
                                                ? Icons
                                                .arrow_right_sharp
                                                : Icons.arrow_drop_down,
                                            size: 35,
                                            color: colour.commonColor,
                                          ))),
                                  Expanded(
                                      flex: 3,
                                      child: Text(
                                        "FW 1 ",
                                        style:GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                fontSize: objfun.FontMedium,
                                                fontWeight: FontWeight.bold,
                                                color: colour.commonColor)),
                                        textAlign: TextAlign.center,
                                      )),
                                  Expanded(
                                    flex: 5,
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                        left: 10.0,
                                        right: 10.0,
                                      ),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(
                                              10.0),
                                          color:
                                          colour.commonColorLight,
                                          border: Border.all()),
                                      child:
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton(
                                          isExpanded: true,
                                          value: state.dropdownValueFW1,
                                          onChanged: null,
                                          style: GoogleFonts
                                              .lato(
                                            textStyle: TextStyle(
                                                color:
                                                colour.commonColor,
                                                fontWeight:
                                                FontWeight.bold,
                                                fontSize:
                                                objfun.FontMedium,
                                                letterSpacing: 0.3),
                                          ),
                                          items: SaleOrderDetailsState.ForwardingNo.map<
                                              DropdownMenuItem<
                                                  String>>(
                                                  (String value) {
                                                return DropdownMenuItem<
                                                    String>(
                                                  value: value,
                                                  child: Text(
                                                    value,
                                                    style: GoogleFonts
                                                        .lato(
                                                      textStyle: TextStyle(
                                                          color: colour
                                                              .commonColor,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          fontSize: objfun
                                                              .FontMedium,
                                                          letterSpacing:
                                                          0.3),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              Visibility(
                                  visible: state.VisibleFW1,
                                  child: Column(children: [
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Container(
                                      width: objfun.SizeConfig
                                          .safeBlockHorizontal *
                                          99,
                                      height: objfun.SizeConfig
                                          .safeBlockVertical *
                                          7,
                                      alignment:
                                      Alignment.topCenter,
                                      padding:
                                      const EdgeInsets.only(
                                          bottom: 5),
                                      child: TextField(
                                        cursorColor:
                                        colour.commonColor,
                                        controller: state.txtSmk1,
                                        autofocus: false,
                                        showCursor: false,
                                        readOnly: true,
                                        decoration:
                                        InputDecoration(
                                          hintText:
                                          ('SMK NO 1'),
                                          hintStyle: GoogleFonts.lato(
                                              textStyle:TextStyle(
                                                  fontSize: objfun
                                                      .FontMedium,
                                                  fontWeight:
                                                  FontWeight
                                                      .bold,
                                                  color: colour
                                                      .commonColorLight)),
                                          fillColor: colour
                                              .commonColor,
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
                                        textInputAction:
                                        TextInputAction
                                            .done,
                                        textCapitalization:
                                        TextCapitalization
                                            .characters,
                                        style: GoogleFonts
                                            .lato(
                                          textStyle: TextStyle(
                                              color: colour
                                                  .commonColor,
                                              fontWeight:
                                              FontWeight
                                                  .bold,
                                              fontSize: objfun
                                                  .FontLow,
                                              letterSpacing:
                                              0.3),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * 0.06,
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                        children: <Widget>[
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              width: objfun.SizeConfig
                                                  .safeBlockHorizontal *
                                                  99,
                                              height: objfun.SizeConfig
                                                  .safeBlockVertical *
                                                  7,
                                              alignment:
                                              Alignment.topCenter,
                                              padding:
                                              const EdgeInsets.only(
                                                  bottom: 5),
                                              child: TextField(
                                                cursorColor:
                                                colour.commonColor,
                                                controller: state.txtENRef1,
                                                autofocus: false,
                                                showCursor: false,
                                                readOnly: true,
                                                decoration:
                                                InputDecoration(
                                                  hintText:
                                                  ('EN.Ref 1'),
                                                  hintStyle: GoogleFonts.lato(
                                                      textStyle:TextStyle(
                                                          fontSize: objfun
                                                              .FontMedium,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          color: colour
                                                              .commonColorLight)),
                                                  fillColor: colour
                                                      .commonColor,
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
                                                textInputAction:
                                                TextInputAction
                                                    .done,
                                                textCapitalization:
                                                TextCapitalization
                                                    .characters,
                                                style: GoogleFonts
                                                    .lato(
                                                  textStyle: TextStyle(
                                                      color: colour
                                                          .commonColor,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                      fontSize: objfun
                                                          .FontLow,
                                                      letterSpacing:
                                                      0.3),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              width: objfun.SizeConfig
                                                  .safeBlockHorizontal *
                                                  99,
                                              height: objfun.SizeConfig
                                                  .safeBlockVertical *
                                                  7,
                                              alignment:
                                              Alignment.topCenter,
                                              padding:
                                              const EdgeInsets.only(
                                                  bottom: 5),
                                              child: TextField(
                                                cursorColor:
                                                colour.commonColor,
                                                controller: state.txtExRef1,
                                                autofocus: false,
                                                showCursor: false,
                                                readOnly: true,
                                                decoration:
                                                InputDecoration(
                                                  hintText:
                                                  ('EX.Ref 1'),
                                                  hintStyle:GoogleFonts.lato(
                                                      textStyle: TextStyle(
                                                          fontSize: objfun
                                                              .FontMedium,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          color: colour
                                                              .commonColorLight)),
                                                  fillColor: colour
                                                      .commonColor,
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
                                                textInputAction:
                                                TextInputAction
                                                    .done,
                                                textCapitalization:
                                                TextCapitalization
                                                    .characters,
                                                style: GoogleFonts
                                                    .lato(
                                                  textStyle: TextStyle(
                                                      color: colour
                                                          .commonColor,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                      fontSize: objfun
                                                          .FontLow,
                                                      letterSpacing:
                                                      0.3),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Container(
                                      width: objfun.SizeConfig
                                          .safeBlockHorizontal *
                                          99,
                                      height: objfun.SizeConfig
                                          .safeBlockVertical *
                                          7,
                                      alignment: Alignment.topCenter,
                                      padding: const EdgeInsets.only(
                                          bottom: 5),
                                      child: TextField(
                                        textCapitalization:
                                        TextCapitalization
                                            .characters,
                                        controller: state.txtSealByEmp1,
                                        textInputAction:
                                        TextInputAction.done,
                                        keyboardType:
                                        TextInputType.name,
                                        readOnly: true,
                                        style:
                                        GoogleFonts.lato(
                                          textStyle: TextStyle(
                                              color: colour.commonColor,
                                              fontWeight:
                                              FontWeight.bold,
                                              fontSize: objfun.FontLow,
                                              letterSpacing: 0.3),
                                        ),
                                        decoration: InputDecoration(
                                          hintText: "Seal By",
                                          hintStyle: GoogleFonts.lato(
                                              textStyle:TextStyle(
                                                  fontSize:
                                                  objfun.FontMedium,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  color: colour
                                                      .commonColorLight)),

                                          fillColor: Colors.black,
                                          enabledBorder:
                                          const OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.all(
                                                Radius.circular(
                                                    10.0)),
                                            borderSide: BorderSide(
                                                color:
                                                colour.commonColor),
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
                                    Container(
                                      width: objfun.SizeConfig
                                          .safeBlockHorizontal *
                                          99,
                                      height: objfun.SizeConfig
                                          .safeBlockVertical *
                                          7,
                                      alignment: Alignment.topCenter,
                                      padding: const EdgeInsets.only(
                                          bottom: 5),
                                      child: TextField(
                                        textCapitalization:
                                        TextCapitalization
                                            .characters,
                                        controller: state.txtBreakByEmp1,
                                        textInputAction:
                                        TextInputAction.done,
                                        keyboardType:
                                        TextInputType.name,
                                        readOnly: true,
                                        style:
                                        GoogleFonts.lato(
                                          textStyle: TextStyle(
                                              color: colour.commonColor,
                                              fontWeight:
                                              FontWeight.bold,
                                              fontSize: objfun.FontLow,
                                              letterSpacing: 0.3),
                                        ),
                                        decoration: InputDecoration(
                                          hintText: "B.Seal By",
                                          hintStyle:GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  fontSize:
                                                  objfun.FontMedium,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  color: colour
                                                      .commonColorLight)),

                                          fillColor: Colors.black,
                                          enabledBorder:
                                          const OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.all(
                                                Radius.circular(
                                                    10.0)),
                                            borderSide: BorderSide(
                                                color:
                                                colour.commonColor),
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
                                  ])),
                              const Divider(
                                color: colour.commonColorLight,
                                thickness: 1,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                      flex: 1,
                                      child: IconButton(
                                          onPressed: () {
                                            state.setState(() {
                                              state.VisibleFW2 =
                                              state.VisibleFW2 == false
                                                  ? true
                                                  : false;
                                            });
                                          },
                                          icon: Icon(
                                            state.VisibleFW2 == false
                                                ? Icons
                                                .arrow_right_sharp
                                                : Icons.arrow_drop_down,
                                            size: 35,
                                            color: colour.commonColor,
                                          ))),
                                  Expanded(
                                      flex: 3,
                                      child: Text(
                                        "FW 2 ",
                                        style:GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                fontSize: objfun.FontMedium,
                                                fontWeight: FontWeight.bold,
                                                color: colour.commonColor)),
                                        textAlign: TextAlign.center,
                                      )),
                                  Expanded(
                                    flex: 5,
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                        left: 10.0,
                                        right: 10.0,
                                      ),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(
                                              10.0),
                                          color:
                                          colour.commonColorLight,
                                          border: Border.all()),
                                      child:
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton(
                                          isExpanded: true,
                                          value: state.dropdownValueFW2,
                                          onChanged: null,
                                          style: GoogleFonts
                                              .lato(
                                            textStyle: TextStyle(
                                                color:
                                                colour.commonColor,
                                                fontWeight:
                                                FontWeight.bold,
                                                fontSize:
                                                objfun.FontMedium,
                                                letterSpacing: 0.3),
                                          ),
                                          items: SaleOrderDetailsState.ForwardingNo.map<
                                              DropdownMenuItem<
                                                  String>>(
                                                  (String value) {
                                                return DropdownMenuItem<
                                                    String>(
                                                  value: value,
                                                  child: Text(
                                                    value,
                                                    style: GoogleFonts
                                                        .lato(
                                                      textStyle: TextStyle(
                                                          color: colour
                                                              .commonColor,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          fontSize: objfun
                                                              .FontMedium,
                                                          letterSpacing:
                                                          0.3),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              Visibility(
                                  visible: state.VisibleFW2,
                                  child: Column(children: [
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Container(
                                      width: objfun.SizeConfig
                                          .safeBlockHorizontal *
                                          99,
                                      height: objfun.SizeConfig
                                          .safeBlockVertical *
                                          7,
                                      alignment:
                                      Alignment.topCenter,
                                      padding:
                                      const EdgeInsets.only(
                                          bottom: 5),
                                      child: TextField(
                                        cursorColor:
                                        colour.commonColor,
                                        controller: state.txtSmk2,
                                        autofocus: false,
                                        showCursor: false,
                                        readOnly: true,
                                        decoration:
                                        InputDecoration(
                                          hintText:
                                          ('SMK NO 2'),
                                          hintStyle:GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  fontSize: objfun
                                                      .FontMedium,
                                                  fontWeight:
                                                  FontWeight
                                                      .bold,
                                                  color: colour
                                                      .commonColorLight)),
                                          fillColor: colour
                                              .commonColor,
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
                                        textInputAction:
                                        TextInputAction
                                            .done,
                                        textCapitalization:
                                        TextCapitalization
                                            .characters,
                                        style: GoogleFonts
                                            .lato(
                                          textStyle: TextStyle(
                                              color: colour
                                                  .commonColor,
                                              fontWeight:
                                              FontWeight
                                                  .bold,
                                              fontSize: objfun
                                                  .FontLow,
                                              letterSpacing:
                                              0.3),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * 0.06,
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                        children: <Widget>[
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              width: objfun.SizeConfig
                                                  .safeBlockHorizontal *
                                                  99,
                                              height: objfun.SizeConfig
                                                  .safeBlockVertical *
                                                  7,
                                              alignment:
                                              Alignment.topCenter,
                                              padding:
                                              const EdgeInsets.only(
                                                  bottom: 5),
                                              child: TextField(
                                                cursorColor:
                                                colour.commonColor,
                                                controller: state.txtENRef2,
                                                autofocus: false,
                                                showCursor: false,
                                                readOnly: true,
                                                decoration:
                                                InputDecoration(
                                                  hintText:
                                                  ('EN.Ref 2'),
                                                  hintStyle:GoogleFonts.lato(
                                                      textStyle: TextStyle(
                                                          fontSize: objfun
                                                              .FontMedium,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          color: colour
                                                              .commonColorLight)),
                                                  fillColor: colour
                                                      .commonColor,
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
                                                textInputAction:
                                                TextInputAction
                                                    .done,
                                                textCapitalization:
                                                TextCapitalization
                                                    .characters,
                                                style: GoogleFonts
                                                    .lato(
                                                  textStyle: TextStyle(
                                                      color: colour
                                                          .commonColor,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                      fontSize: objfun
                                                          .FontLow,
                                                      letterSpacing:
                                                      0.3),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              width: objfun.SizeConfig
                                                  .safeBlockHorizontal *
                                                  99,
                                              height: objfun.SizeConfig
                                                  .safeBlockVertical *
                                                  7,
                                              alignment:
                                              Alignment.topCenter,
                                              padding:
                                              const EdgeInsets.only(
                                                  bottom: 5),
                                              child: TextField(
                                                cursorColor:
                                                colour.commonColor,
                                                controller: state.txtExRef2,
                                                autofocus: false,
                                                showCursor: false,
                                                readOnly: true,
                                                decoration:
                                                InputDecoration(
                                                  hintText:
                                                  ('EX.Ref 2'),
                                                  hintStyle: GoogleFonts.lato(
                                                      textStyle:TextStyle(
                                                          fontSize: objfun
                                                              .FontMedium,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          color: colour
                                                              .commonColorLight)),
                                                  fillColor: colour
                                                      .commonColor,
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
                                                textInputAction:
                                                TextInputAction
                                                    .done,
                                                textCapitalization:
                                                TextCapitalization
                                                    .characters,
                                                style: GoogleFonts
                                                    .lato(
                                                  textStyle: TextStyle(
                                                      color: colour
                                                          .commonColor,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                      fontSize: objfun
                                                          .FontLow,
                                                      letterSpacing:
                                                      0.3),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Container(
                                      width: objfun.SizeConfig
                                          .safeBlockHorizontal *
                                          99,
                                      height: objfun.SizeConfig
                                          .safeBlockVertical *
                                          7,
                                      alignment: Alignment.topCenter,
                                      padding: const EdgeInsets.only(
                                          bottom: 5),
                                      child: TextField(
                                        textCapitalization:
                                        TextCapitalization
                                            .characters,
                                        controller: state.txtSealByEmp2,
                                        textInputAction:
                                        TextInputAction.done,
                                        keyboardType:
                                        TextInputType.name,
                                        readOnly: true,
                                        style:
                                        GoogleFonts.lato(
                                          textStyle: TextStyle(
                                              color: colour.commonColor,
                                              fontWeight:
                                              FontWeight.bold,
                                              fontSize: objfun.FontLow,
                                              letterSpacing: 0.3),
                                        ),
                                        decoration: InputDecoration(
                                          hintText: "Seal By",
                                          hintStyle: GoogleFonts.lato(
                                              textStyle:TextStyle(
                                                  fontSize:
                                                  objfun.FontMedium,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  color: colour
                                                      .commonColorLight)),

                                          fillColor: Colors.black,
                                          enabledBorder:
                                          const OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.all(
                                                Radius.circular(
                                                    10.0)),
                                            borderSide: BorderSide(
                                                color:
                                                colour.commonColor),
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
                                    Container(
                                      width: objfun.SizeConfig
                                          .safeBlockHorizontal *
                                          99,
                                      height: objfun.SizeConfig
                                          .safeBlockVertical *
                                          7,
                                      alignment: Alignment.topCenter,
                                      padding: const EdgeInsets.only(
                                          bottom: 5),
                                      child: TextField(
                                        textCapitalization:
                                        TextCapitalization
                                            .characters,
                                        controller: state.txtBreakByEmp2,
                                        textInputAction:
                                        TextInputAction.done,
                                        keyboardType:
                                        TextInputType.name,
                                        readOnly: true,
                                        style:
                                        GoogleFonts.lato(
                                          textStyle: TextStyle(
                                              color: colour.commonColor,
                                              fontWeight:
                                              FontWeight.bold,
                                              fontSize: objfun.FontLow,
                                              letterSpacing: 0.3),
                                        ),
                                        decoration: InputDecoration(
                                          hintText: "B.Seal By",
                                          hintStyle:GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  fontSize:
                                                  objfun.FontMedium,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  color: colour
                                                      .commonColorLight)),

                                          fillColor: Colors.black,
                                          enabledBorder:
                                          const OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.all(
                                                Radius.circular(
                                                    10.0)),
                                            borderSide: BorderSide(
                                                color:
                                                colour.commonColor),
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
                                  ])),
                              const Divider(
                                color: colour.commonColorLight,
                                thickness: 1,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                      flex: 1,
                                      child: IconButton(
                                          onPressed: () {
                                            state.setState(() {
                                              state.VisibleFW3 =
                                              state.VisibleFW3 == false
                                                  ? true
                                                  : false;
                                            });
                                          },
                                          icon: Icon(
                                            state.VisibleFW3 == false
                                                ? Icons
                                                .arrow_right_sharp
                                                : Icons.arrow_drop_down,
                                            size: 35,
                                            color: colour.commonColor,
                                          ))),
                                  Expanded(
                                      flex: 3,
                                      child: Text(
                                        "FW 3 ",
                                        style: GoogleFonts.lato(
                                            textStyle:TextStyle(
                                                fontSize: objfun.FontMedium,
                                                fontWeight: FontWeight.bold,
                                                color: colour.commonColor)),
                                        textAlign: TextAlign.center,
                                      )),
                                  Expanded(
                                    flex: 5,
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                        left: 10.0,
                                        right: 10.0,
                                      ),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(
                                              10.0),
                                          color:
                                          colour.commonColorLight,
                                          border: Border.all()),
                                      child:
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton(
                                          isExpanded: true,
                                          value: state.dropdownValueFW3,
                                          onChanged:null,
                                          style: GoogleFonts
                                              .lato(
                                            textStyle: TextStyle(
                                                color:
                                                colour.commonColor,
                                                fontWeight:
                                                FontWeight.bold,
                                                fontSize:
                                                objfun.FontMedium,
                                                letterSpacing: 0.3),
                                          ),
                                          items: SaleOrderDetailsState.ForwardingNo.map<
                                              DropdownMenuItem<
                                                  String>>(
                                                  (String value) {
                                                return DropdownMenuItem<
                                                    String>(
                                                  value: value,
                                                  child: Text(
                                                    value,
                                                    style: GoogleFonts
                                                        .lato(
                                                      textStyle: TextStyle(
                                                          color: colour
                                                              .commonColor,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          fontSize: objfun
                                                              .FontMedium,
                                                          letterSpacing:
                                                          0.3),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              Visibility(
                                  visible: state.VisibleFW3,
                                  child: Column(children: [
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Container(
                                      width: objfun.SizeConfig
                                          .safeBlockHorizontal *
                                          99,
                                      height: objfun.SizeConfig
                                          .safeBlockVertical *
                                          7,
                                      alignment:
                                      Alignment.topCenter,
                                      padding:
                                      const EdgeInsets.only(
                                          bottom: 5),
                                      child: TextField(
                                        cursorColor:
                                        colour.commonColor,
                                        controller: state.txtSmk3,
                                        autofocus: false,
                                        showCursor: false,
                                        readOnly: true,
                                        decoration:
                                        InputDecoration(
                                          hintText:
                                          ('SMK NO 3'),
                                          hintStyle: GoogleFonts.lato(
                                              textStyle:TextStyle(
                                                  fontSize: objfun
                                                      .FontMedium,
                                                  fontWeight:
                                                  FontWeight
                                                      .bold,
                                                  color: colour
                                                      .commonColorLight)),
                                          fillColor: colour
                                              .commonColor,
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
                                        textInputAction:
                                        TextInputAction
                                            .done,
                                        textCapitalization:
                                        TextCapitalization
                                            .characters,
                                        style: GoogleFonts
                                            .lato(
                                          textStyle: TextStyle(
                                              color: colour
                                                  .commonColor,
                                              fontWeight:
                                              FontWeight
                                                  .bold,
                                              fontSize: objfun
                                                  .FontLow,
                                              letterSpacing:
                                              0.3),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * 0.06,
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                        children: <Widget>[
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              width: objfun.SizeConfig
                                                  .safeBlockHorizontal *
                                                  99,
                                              height: objfun.SizeConfig
                                                  .safeBlockVertical *
                                                  7,
                                              alignment:
                                              Alignment.topCenter,
                                              padding:
                                              const EdgeInsets.only(
                                                  bottom: 5),
                                              child: TextField(
                                                cursorColor:
                                                colour.commonColor,
                                                controller: state.txtENRef3,
                                                autofocus: false,
                                                showCursor: false,
                                                readOnly: true,
                                                decoration:
                                                InputDecoration(
                                                  hintText:
                                                  ('EN.Ref 3'),
                                                  hintStyle :GoogleFonts.lato(
                                                      textStyle: TextStyle(
                                                          fontSize: objfun
                                                              .FontMedium,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          color: colour
                                                              .commonColorLight)),
                                                  fillColor: colour
                                                      .commonColor,
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
                                                textInputAction:
                                                TextInputAction
                                                    .done,
                                                textCapitalization:
                                                TextCapitalization
                                                    .characters,
                                                style: GoogleFonts
                                                    .lato(
                                                  textStyle: TextStyle(
                                                      color: colour
                                                          .commonColor,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                      fontSize: objfun
                                                          .FontLow,
                                                      letterSpacing:
                                                      0.3),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              width: objfun.SizeConfig
                                                  .safeBlockHorizontal *
                                                  99,
                                              height: objfun.SizeConfig
                                                  .safeBlockVertical *
                                                  7,
                                              alignment:
                                              Alignment.topCenter,
                                              padding:
                                              const EdgeInsets.only(
                                                  bottom: 5),
                                              child: TextField(
                                                cursorColor:
                                                colour.commonColor,
                                                controller: state.txtExRef3,
                                                autofocus: false,
                                                showCursor: false,
                                                readOnly: true,
                                                decoration:
                                                InputDecoration(
                                                  hintText:
                                                  ('EX.Ref 3'),
                                                  hintStyle:GoogleFonts.lato(
                                                      textStyle: TextStyle(
                                                          fontSize: objfun
                                                              .FontMedium,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          color: colour
                                                              .commonColorLight)),
                                                  fillColor: colour
                                                      .commonColor,
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
                                                textInputAction:
                                                TextInputAction
                                                    .done,
                                                textCapitalization:
                                                TextCapitalization
                                                    .characters,
                                                style: GoogleFonts
                                                    .lato(
                                                  textStyle: TextStyle(
                                                      color: colour
                                                          .commonColor,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                      fontSize: objfun
                                                          .FontLow,
                                                      letterSpacing:
                                                      0.3),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Container(
                                      width: objfun.SizeConfig
                                          .safeBlockHorizontal *
                                          99,
                                      height: objfun.SizeConfig
                                          .safeBlockVertical *
                                          7,
                                      alignment: Alignment.topCenter,
                                      padding: const EdgeInsets.only(
                                          bottom: 5),
                                      child: TextField(
                                        textCapitalization:
                                        TextCapitalization
                                            .characters,
                                        controller: state.txtSealByEmp3,
                                        textInputAction:
                                        TextInputAction.done,
                                        keyboardType:
                                        TextInputType.name,
                                        readOnly: true,
                                        style:
                                        GoogleFonts.lato(
                                          textStyle: TextStyle(
                                              color: colour.commonColor,
                                              fontWeight:
                                              FontWeight.bold,
                                              fontSize: objfun.FontLow,
                                              letterSpacing: 0.3),
                                        ),
                                        decoration: InputDecoration(
                                          hintText: "Seal By",
                                          hintStyle:GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  fontSize:
                                                  objfun.FontMedium,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  color: colour
                                                      .commonColorLight)),

                                          fillColor: Colors.black,
                                          enabledBorder:
                                          const OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.all(
                                                Radius.circular(
                                                    10.0)),
                                            borderSide: BorderSide(
                                                color:
                                                colour.commonColor),
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
                                    Container(
                                      width: objfun.SizeConfig
                                          .safeBlockHorizontal *
                                          99,
                                      height: objfun.SizeConfig
                                          .safeBlockVertical *
                                          7,
                                      alignment: Alignment.topCenter,
                                      padding: const EdgeInsets.only(
                                          bottom: 5),
                                      child: TextField(
                                        textCapitalization:
                                        TextCapitalization
                                            .characters,
                                        controller: state.txtBreakByEmp3,
                                        textInputAction:
                                        TextInputAction.done,
                                        keyboardType:
                                        TextInputType.name,
                                        readOnly: true,
                                        style:
                                        GoogleFonts.lato(
                                          textStyle: TextStyle(
                                              color: colour.commonColor,
                                              fontWeight:
                                              FontWeight.bold,
                                              fontSize: objfun.FontLow,
                                              letterSpacing: 0.3),
                                        ),
                                        decoration: InputDecoration(
                                          hintText: "B.Seal By",
                                          hintStyle: GoogleFonts.lato(
                                              textStyle:TextStyle(
                                                  fontSize:
                                                  objfun.FontMedium,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  color: colour
                                                      .commonColorLight)),

                                          fillColor: Colors.black,
                                          enabledBorder:
                                          const OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.all(
                                                Radius.circular(
                                                    10.0)),
                                            borderSide: BorderSide(
                                                color:
                                                colour.commonColor),
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
                                  ])),
                              const Divider(
                                color: colour.commonColorLight,
                                thickness: 1,
                              ),
                            ],
                          )),
                      Visibility(
                          visible: state.VisibleZB,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      flex: 2,
                                      child: Text(
                                        "ZB 1",
                                        style:GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                fontSize: objfun.FontMedium,
                                                fontWeight: FontWeight.bold,
                                                color: colour.commonColor)),
                                        textAlign: TextAlign.center,
                                      )),
                                  Expanded(
                                    flex: 5,
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                        left: 10.0,
                                        right: 10.0,
                                      ),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(
                                              10.0),
                                          color:
                                          colour.commonColorLight,
                                          border: Border.all()),
                                      child:
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton(
                                          isExpanded: true,
                                          value: state.dropdownValueZB1,
                                          onChanged: null,
                                          style: GoogleFonts
                                              .lato(
                                            textStyle: TextStyle(
                                                color:
                                                colour.commonColor,
                                                fontWeight:
                                                FontWeight.bold,
                                                fontSize:
                                                objfun.FontMedium,
                                                letterSpacing: 0.3),
                                          ),
                                          items: SaleOrderDetailsState.ZBNo.map<
                                              DropdownMenuItem<
                                                  String>>(
                                                  (String value) {
                                                return DropdownMenuItem<
                                                    String>(
                                                  value: value,
                                                  child: Text(
                                                    value,
                                                    style: GoogleFonts
                                                        .lato(
                                                      textStyle: TextStyle(
                                                          color: colour
                                                              .commonColor,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          fontSize: objfun
                                                              .FontMedium,
                                                          letterSpacing:
                                                          0.3),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              SizedBox(
                                height: height * 0.06,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        width: objfun.SizeConfig
                                            .safeBlockHorizontal *
                                            99,
                                        height: objfun.SizeConfig
                                            .safeBlockVertical *
                                            7,
                                        alignment: Alignment.topCenter,
                                        padding: const EdgeInsets.only(
                                            bottom: 5),
                                        child: TextField(
                                          cursorColor:
                                          colour.commonColor,
                                          controller: state.txtZBRef1,
                                          autofocus: false,
                                          showCursor: false,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            hintText: ('ZB Ref 1'),
                                            hintStyle:GoogleFonts.lato(
                                                textStyle: TextStyle(
                                                    fontSize:
                                                    objfun.FontMedium,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color: colour
                                                        .commonColorLight)),
                                            fillColor:
                                            colour.commonColor,
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
                                          textInputAction:
                                          TextInputAction.done,
                                          textCapitalization:
                                          TextCapitalization
                                              .characters,
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
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                      Visibility(
                          visible: state.VisibleZB,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      flex: 2,
                                      child: Text(
                                        "ZB 2",
                                        style:GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                fontSize: objfun.FontMedium,
                                                fontWeight: FontWeight.bold,
                                                color: colour.commonColor)),
                                        textAlign: TextAlign.center,
                                      )),
                                  Expanded(
                                    flex: 5,
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                        left: 10.0,
                                        right: 10.0,
                                      ),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(
                                              10.0),
                                          color:
                                          colour.commonColorLight,
                                          border: Border.all()),
                                      child:
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton(
                                          isExpanded: true,
                                          value: state.dropdownValueZB2,
                                          onChanged: null,
                                          style: GoogleFonts
                                              .lato(
                                            textStyle: TextStyle(
                                                color:
                                                colour.commonColor,
                                                fontWeight:
                                                FontWeight.bold,
                                                fontSize:
                                                objfun.FontMedium,
                                                letterSpacing: 0.3),
                                          ),
                                          items: SaleOrderDetailsState.ZBNo.map<
                                              DropdownMenuItem<
                                                  String>>(
                                                  (String value) {
                                                return DropdownMenuItem<
                                                    String>(
                                                  value: value,
                                                  child: Text(
                                                    value,
                                                    style: GoogleFonts
                                                        .lato(
                                                      textStyle: TextStyle(
                                                          color: colour
                                                              .commonColor,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          fontSize: objfun
                                                              .FontMedium,
                                                          letterSpacing:
                                                          0.3),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              SizedBox(
                                height: height * 0.06,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        width: objfun.SizeConfig
                                            .safeBlockHorizontal *
                                            99,
                                        height: objfun.SizeConfig
                                            .safeBlockVertical *
                                            7,
                                        alignment: Alignment.topCenter,
                                        padding: const EdgeInsets.only(
                                            bottom: 5),
                                        child: TextField(
                                          cursorColor:
                                          colour.commonColor,
                                          controller: state.txtZBRef2,
                                          autofocus: false,
                                          showCursor: false,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            hintText: ('ZB Ref 2'),
                                            hintStyle:GoogleFonts.lato(
                                                textStyle: TextStyle(
                                                    fontSize:
                                                    objfun.FontMedium,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color: colour
                                                        .commonColorLight)),
                                            fillColor:
                                            colour.commonColor,
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
                                          textInputAction:
                                          TextInputAction.done,
                                          textCapitalization:
                                          TextCapitalization
                                              .characters,
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
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                color: colour.commonColorLight,
                                thickness: 1,
                              ),
                            ],
                          )),
                      Container(
                        width:
                        objfun.SizeConfig.safeBlockHorizontal * 99,
                        height: objfun.SizeConfig.safeBlockVertical * 7,
                        alignment: Alignment.topCenter,
                        //padding: const EdgeInsets.only(bottom: 5),
                        child: TextField(
                          textCapitalization:
                          TextCapitalization.characters,
                          controller: state.txtBoardingOfficer1,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.name,
                          readOnly: true,
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                                color: colour.commonColor,
                                fontWeight: FontWeight.bold,
                                fontSize: objfun.FontLow,
                                letterSpacing: 0.3),
                          ),
                          decoration: InputDecoration(
                            hintText: "Boarding Officer 1",
                            hintStyle:GoogleFonts.lato(
                                textStyle: TextStyle(
                                    fontSize: objfun.FontMedium,
                                    fontWeight: FontWeight.bold,
                                    color: colour.commonColorLight)),

                            fillColor: Colors.black,
                            enabledBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10.0)),
                              borderSide:
                              BorderSide(color: colour.commonColor),
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
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      SizedBox(
                        height: height * 0.06,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Container(
                                width: objfun.SizeConfig
                                    .safeBlockHorizontal *
                                    99,
                                height: objfun
                                    .SizeConfig.safeBlockVertical *
                                    7,
                                alignment: Alignment.topCenter,
                                padding:
                                const EdgeInsets.only(bottom: 5),
                                child: TextField(
                                  cursorColor: colour.commonColor,
                                  controller: state.txtAmount1,
                                  autofocus: false,
                                  showCursor:
                                  state.DisabledAmount1 ? false : true,
                                  readOnly:
                                  state.DisabledAmount1 ? true : false,
                                  decoration: InputDecoration(
                                    hintText: ('Amount 1'),
                                    hintStyle:GoogleFonts.lato(
                                        textStyle: TextStyle(
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
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      SizedBox(
                        height: height * 0.06,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Container(
                                width: objfun.SizeConfig
                                    .safeBlockHorizontal *
                                    99,
                                height: objfun
                                    .SizeConfig.safeBlockVertical *
                                    7,
                                alignment: Alignment.topCenter,
                                padding:
                                const EdgeInsets.only(bottom: 5),
                                child: TextField(
                                  cursorColor: colour.commonColor,
                                  controller: state.txtPortChargeRef1,
                                  autofocus: false,
                                  showCursor: false,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    hintText: ('Port Charges Ref'),
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
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        color: colour.commonColorLight,
                        thickness: 1,
                      ),
                      Container(
                        width:
                        objfun.SizeConfig.safeBlockHorizontal * 99,
                        height: objfun.SizeConfig.safeBlockVertical * 7,
                        alignment: Alignment.topCenter,
                        // padding: const EdgeInsets.only(bottom: 5),
                        child: TextField(
                          textCapitalization:
                          TextCapitalization.characters,
                          controller: state.txtBoardingOfficer2,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.name,
                          readOnly: true,
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                                color: colour.commonColor,
                                fontWeight: FontWeight.bold,
                                fontSize: objfun.FontLow,
                                letterSpacing: 0.3),
                          ),
                          decoration: InputDecoration(
                            hintText: "Boarding Officer 2",
                            hintStyle: GoogleFonts.lato(
                                textStyle:TextStyle(
                                    fontSize: objfun.FontMedium,
                                    fontWeight: FontWeight.bold,
                                    color: colour.commonColorLight)),

                            fillColor: Colors.black,
                            enabledBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10.0)),
                              borderSide:
                              BorderSide(color: colour.commonColor),
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
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      SizedBox(
                        height: height * 0.06,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Container(
                                width: objfun.SizeConfig
                                    .safeBlockHorizontal *
                                    99,
                                height: objfun
                                    .SizeConfig.safeBlockVertical *
                                    7,
                                alignment: Alignment.topCenter,
                                padding:
                                const EdgeInsets.only(bottom: 5),
                                child: TextField(
                                  cursorColor: colour.commonColor,
                                  controller: state.txtAmount2,
                                  autofocus: false,
                                  showCursor:
                                  state.DisabledAmount2 ? false : true,
                                  readOnly:
                                  state.DisabledAmount2 ? true : false,
                                  decoration: InputDecoration(
                                    hintText: ('Amount 2'),
                                    hintStyle:GoogleFonts.lato(
                                        textStyle: TextStyle(
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
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      SizedBox(
                        height: height * 0.06,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Container(
                                width: objfun.SizeConfig
                                    .safeBlockHorizontal *
                                    99,
                                height: objfun
                                    .SizeConfig.safeBlockVertical *
                                    7,
                                alignment: Alignment.topCenter,
                                padding:
                                const EdgeInsets.only(bottom: 5),
                                child: TextField(
                                  cursorColor: colour.commonColor,
                                  controller: state.txtPortCharges,
                                  autofocus: false,
                                  showCursor: false,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    hintText: ('Port Charges'),
                                    hintStyle:GoogleFonts.lato(
                                        textStyle: TextStyle(
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
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
        ),
        bottomNavigationBar: Card(
          elevation: 6,
          color: colour.commonColorLight,
          //  margin: EdgeInsets.all(15),
          child: SalomonBottomBar(
            duration: const Duration(seconds: 1),
            items: [
              SalomonBottomBarItem(
                icon: const Icon(
                  Icons.info_outline,
                  color: colour.commonColor,
                ),
                title: Text(
                  "",
                  style: TextStyle(
                      color: colour.commonColor,
                      fontSize: width <= 370
                          ? objfun.FontCardText + 2
                          : objfun.FontLow),
                ),
              ),
              SalomonBottomBarItem(
                icon: const Icon(
                  Icons.comment_outlined,
                  color: colour.commonColor,
                ),
                title: Text(
                  "",
                  style: TextStyle(
                      color: colour.commonColor,
                      fontSize: width <= 370
                          ? objfun.FontCardText + 2
                          : objfun.FontLow),
                ),
              ),
              SalomonBottomBarItem(
                icon: const Icon(
                  Icons.directions_boat_filled,
                  color: colour.commonColor,
                ),
                title: Text(
                  "",
                  style: TextStyle(
                      color: colour.commonColor,
                      fontSize: width <= 370
                          ? objfun.FontCardText + 2
                          : objfun.FontLow),
                ),

              ),
              SalomonBottomBarItem(
                icon: const Icon(
                  Icons.directions_boat_filled_outlined,
                  color: colour.commonColor,
                ),
                title: Text(
                  "",
                  style: TextStyle(
                      color: colour.commonColor,
                      fontSize: width <= 370
                          ? objfun.FontCardText + 2
                          : objfun.FontLow),
                ),

              ),
              SalomonBottomBarItem(
                icon: const Icon(
                  Icons.rate_review_outlined,
                  color: colour.commonColor,
                ),
                title: Text(
                  "",
                  style: TextStyle(
                      color: colour.commonColor,
                      fontSize: width <= 370
                          ? objfun.FontCardText + 2
                          : objfun.FontLow),
                ),
              ),
              SalomonBottomBarItem(
                icon: const Icon(
                  Icons.local_shipping_sharp,
                  color: colour.commonColor,
                ),
                title: Text(
                  "",
                  style: TextStyle(
                      color: colour.commonColor,
                      fontSize: width <= 370
                          ? objfun.FontCardText + 2
                          : objfun.FontLow),
                ),
              ),
            ],
            currentIndex: state._tabController.index,
            onTap: (index) => state.setState(() {
              state._tabController.index = index;
            }),
          ),
        ),
      ));
}