part of 'package:maleva/Transport/RTI/UpdateRTIDetails.dart';


mobiledesign(UpdateRTIState state, BuildContext context) {
  double width = MediaQuery
      .of(context)
      .size
      .width;
  double height = MediaQuery
      .of(context)
      .size
      .height;
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
              ),
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
        ),
        Expanded(
          flex: 1,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Text(
                  "Driver Name",
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
        Expanded(
          flex: 1,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Text(
                  "Truck Name",
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
                flex: 3,
                child: Text(
                  "Remarks",
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
  Future<void> showDialogFilter(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      //isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(55.0),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.only(
                    top: 16.0,
                    left: 16.0,
                    right: 16.0,
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      // mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
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
                                          setState(() {
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
                                          setState(() {
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
                          ],
                        ),
                        Visibility(
                            visible: state.VisibleDriverTruck,
                            child: Column(
                              children: [
                                Container(
                                  width: objfun.SizeConfig.safeBlockHorizontal * 99,
                                  height: objfun.SizeConfig.safeBlockVertical * 6,
                                  alignment: Alignment.topCenter,
                                  margin: const EdgeInsets.only(right: 5.0, left: 5.0),
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: TextField(
                                    textCapitalization: TextCapitalization.characters,
                                    controller: state.txtDriver,
                                    textInputAction: TextInputAction.done,
                                    keyboardType: TextInputType.name,
                                    readOnly: true,
                                    maxLines: null,
                                    expands: true,
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                          color: colour.commonColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: objfun.FontLow,
                                          letterSpacing: 0.3),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Select Driver",
                                      hintStyle: GoogleFonts.lato(
                                          textStyle:TextStyle(
                                              fontSize: objfun.FontLow,
                                              fontWeight: FontWeight.bold,
                                              color: colour.commonColorLight)),
                                      suffixIcon: InkWell(
                                          child: Icon(
                                              (state.txtDriver.text.isNotEmpty)
                                                  ? Icons.close
                                                  : Icons.search_rounded,
                                              color: colour.commonColorred,
                                              size: 30.0),
                                          onTap: () {
                                            if (state.txtDriver.text == "") {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => const Driver(
                                                        Searchby: 1, SearchId: 0)),
                                              ).then((dynamic value) async {
                                                setState(() {
                                                  state.txtDriver.text =
                                                      objfun.SelectDriverList.AccountName;
                                                  state.DriverId = objfun.SelectDriverList.Id;
                                                  objfun.SelectDriverList =
                                                      GetTruckModel.Empty();
                                                });
                                              });
                                            } else {
                                              setState(() {
                                                state.txtDriver.text = "";
                                                state.DriverId = 0;
                                                objfun.SelectDriverList =
                                                    GetTruckModel.Empty();
                                              });
                                            }
                                          }),
                                      fillColor: Colors.black,
                                      enabledBorder: const OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                        borderSide: BorderSide(color: colour.commonColor),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                        borderSide:
                                        BorderSide(color: colour.commonColorred),
                                      ),
                                      contentPadding:
                                      const EdgeInsets.only(left: 10, right: 20, top: 10.0),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: objfun.SizeConfig
                                      .safeBlockHorizontal *
                                      99,
                                  height: objfun
                                      .SizeConfig.safeBlockVertical *
                                      6,
                                  alignment: Alignment.topCenter,
                                  margin: const EdgeInsets.only(right: 5.0, left: 5.0),
                                  padding:
                                  const EdgeInsets.only(bottom: 5),
                                  child: TextField(
                                    textCapitalization:
                                    TextCapitalization.characters,
                                    controller: state.txtTruckNo,
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
                                      hintText: "Select Truck",
                                      hintStyle: GoogleFonts.lato(
                                          textStyle:TextStyle(
                                              fontSize: objfun.FontLow,
                                              fontWeight: FontWeight.bold,
                                              color: colour.commonColorLight)),
                                      suffixIcon: InkWell(
                                          child: Icon(
                                              (state.txtTruckNo
                                                  .text.isNotEmpty)
                                                  ? Icons.close
                                                  : Icons.search_rounded,
                                              color:
                                              colour.commonColorred,
                                              size: 30.0),
                                          onTap: () async {

                                            if (state.txtTruckNo.text == "" ) {

                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const Truck(
                                                            Searchby: 1,
                                                            SearchId: 0)),
                                              ).then(
                                                      (dynamic value) async {
                                                    setState(() {
                                                      state.txtTruckNo.text = objfun
                                                          .SelectTruckList
                                                          .AccountName;
                                                      state.TruckId = objfun
                                                          .SelectTruckList
                                                          .Id;
                                                      objfun.SelectTruckList =
                                                          GetTruckModel
                                                              .Empty();
                                                    });
                                                    state.loaddata();
                                                  });
                                            } else {
                                              setState(() {
                                                state.txtTruckNo.text = "";
                                                state.TruckId = 0;
                                                objfun.TruckDetailsList = [];
                                                objfun.SelectTruckList =
                                                    GetTruckModel
                                                        .Empty();
                                              });
                                            }
                                          }),
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
                              ],
                            )),

                        Container(
                          width: objfun.SizeConfig.safeBlockHorizontal * 99,
                          height: objfun.SizeConfig.safeBlockVertical * 6,
                          alignment: Alignment.topCenter,
                          margin: const EdgeInsets.only(right: 5.0, left: 5.0),
                          padding: const EdgeInsets.only(bottom: 5),
                          child: TextField(
                            cursorColor: colour.commonColor,
                            controller: state.txtRTINo,
                            autofocus: false,
                            showCursor: true,
                            decoration: InputDecoration(
                              hintText: ('RTI No'),
                              hintStyle:GoogleFonts.lato(
                                  textStyle: TextStyle(
                                      fontSize: objfun.FontLow,
                                      fontWeight: FontWeight.bold,
                                      color: colour.commonColorLight)),
                              fillColor: colour.commonColor,
                              enabledBorder: const OutlineInputBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide(color: colour.commonColor),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                                borderSide:
                                BorderSide(color: colour.commonColorred),
                              ),
                              contentPadding:
                              const EdgeInsets.only(left: 10, right: 20, top: 10.0),
                            ),
                            textInputAction: TextInputAction.done,
                            textCapitalization: TextCapitalization.characters,
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                  color: colour.commonColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: objfun.FontLow,
                                  letterSpacing: 0.3),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  state.loaddata();
                                });
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'View',
                                style:GoogleFonts.lato(
                                    textStyle: TextStyle(fontSize: objfun.FontMedium)),
                              ),
                            ),
                            const SizedBox(width: 7),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Close',
                                style: GoogleFonts.lato(
                                    textStyle:TextStyle(fontSize: objfun.FontMedium)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10,)
                      ],
                    ),
                  ));
            });
      },
    );
  }
  return WillPopScope(
      onWillPop: state._onBackPressed,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
                Text('Update RTI',
                    style:GoogleFonts.lato(
                        textStyle: TextStyle(
                          color: colour.topAppBarColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Alatsi',
                          fontSize: objfun.FontMedium,
                        ))),
                Expanded(
                  flex: 1,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(state.UserName,
                            style:GoogleFonts.lato(
                                textStyle: TextStyle(
                                  color: colour.commonColorLight,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Alatsi',
                                  fontSize: objfun.FontLow - 2,
                                ))),
                      ]),
                ),
              ],
            ),
          ),
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
            : (Padding(
          padding: const EdgeInsets.all(5.0),
          child: ListView(
            children: <Widget>[
              const SizedBox(
                height: 5,
              ),
              SizedBox(
                height: height * 0.10,
                child: Container(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  // margin: const EdgeInsets.only(left: 10.0, right: 30),

                  color: colour.commonColor,
                  child: loadgridheader(),
                ),
              ),
              SizedBox(
                height: height * 0.80,
                child: (objfun.RTIViewMasterList.isNotEmpty
                    ? Container(
                    height: height / 1.4,
                    margin: const EdgeInsets.all(0),
                    padding:
                    const EdgeInsets.only(left: 1, right: 1),
                    child: ListView.builder(
                        itemCount:
                        objfun.RTIViewMasterList.length,
                        itemBuilder:
                            (BuildContext context, int indexMaster) {
                          return SizedBox(
                              height:
                              state._currentlyVisibleIndex == indexMaster
                                  ? height * 0.55
                                  : height * 0.18,
                              child: InkWell(
                                onLongPress: () {
                                  state.setState(() {
                                    state.EditId = objfun
                                        .RTIViewMasterList[indexMaster]
                                        .Id;

                                  });
                                },
                                child: Card(
                                  // margin: EdgeInsets.all(10.0),

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
                                                const SizedBox(width: 5,),
                                                Expanded(
                                                  flex: 2,
                                                  child: Container(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(1),
                                                    child: Text(
                                                      objfun
                                                          .RTIViewMasterList[
                                                      indexMaster]
                                                          .RTINoDisplay
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
                                                Expanded(
                                                  flex: 2,
                                                  child: Container(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(5),
                                                    child: Text(
                                                      objfun
                                                          .RTIViewMasterList[
                                                      indexMaster]
                                                          .RTIDate
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
                                                Expanded(
                                                  flex: 2,
                                                  child: Container(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(5),
                                                    child: Text(
                                                      objfun
                                                          .RTIViewMasterList[
                                                      indexMaster]
                                                          .Amount
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
                                            flex: 1,
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .center,
                                              children: <Widget>[
                                                const SizedBox(width: 5,),
                                                Expanded(
                                                  flex: 3,
                                                  child: Container(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(1),
                                                    child: Text(
                                                      objfun
                                                          .RTIViewMasterList[
                                                      indexMaster]
                                                          .DriverName
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
                                            flex: 1,
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .center,
                                              children: <Widget>[
                                                const SizedBox(width: 5,),
                                                Expanded(
                                                  flex: 3,
                                                  child: Container(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(1),
                                                    child: Text(
                                                      objfun
                                                          .RTIViewMasterList[
                                                      indexMaster]
                                                          .TruckName
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
                                                Expanded(
                                                  flex: 3,
                                                  child: Container(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(1),
                                                    child: Text(
                                                      objfun
                                                          .RTIViewMasterList[
                                                      indexMaster]
                                                          .Remarks
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
                                                      child:
                                                      IconButton(
                                                          onPressed:
                                                              () {
                                                            state.setState(() {
                                                              state.RTIDetailsList = objfun.RTIViewDetailList.where((item) => item.RTIMasterRefId == objfun.RTIViewMasterList[indexMaster].Id).toList();
                                                              state.VisibleRTIDetails[indexMaster] = !state.VisibleRTIDetails[indexMaster];
                                                              if (state._currentlyVisibleIndex == indexMaster) {
                                                                state._currentlyVisibleIndex = -1;
                                                              } else {
                                                                state._currentlyVisibleIndex = indexMaster;
                                                              }
                                                            });
                                                          },
                                                          icon:
                                                          const Icon(
                                                            Icons.expand_circle_down,
                                                            color:
                                                            colour.commonColor,
                                                          ))),
                                                ),

                                                Expanded(
                                                  flex: 2,
                                                  child: Container(
                                                    child:
                                                    IconButton(
                                                        onPressed:
                                                            () {

                                                          state._shareRTI(objfun
                                                              .RTIViewMasterList[
                                                          indexMaster]
                                                              .Id,objfun
                                                              .RTIViewMasterList[
                                                          indexMaster]
                                                              .RTINoDisplay);
                                                        },
                                                        icon:
                                                        const Icon(
                                                          Icons
                                                              .picture_as_pdf_outlined,
                                                          color:
                                                          colour.commonColor,
                                                        )),
                                                  ),
                                                ),

                                              ],
                                            )),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Visibility(
                                            visible:
                                            state._currentlyVisibleIndex ==
                                                indexMaster,
                                            child: Expanded(
                                              flex: 8,
                                              child: ListView(
                                                children: <Widget>[
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  SizedBox(
                                                    height: height *
                                                        0.06,
                                                    child:
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .only(
                                                          left: 5,
                                                          right: 5),
                                                      margin: const EdgeInsets
                                                          .only(
                                                          left: 5,
                                                          right: 5),
                                                      // margin: const EdgeInsets.only(left: 10.0, right: 30),

                                                      color: colour
                                                          .commonColor,
                                                      child: Column(
                                                        children: [
                                                          Expanded(
                                                            flex: 1,
                                                            child:
                                                            Row(
                                                              children: <
                                                                  Widget>[
                                                                Expanded(
                                                                  flex: 2,
                                                                  child: Text(
                                                                    "JobNo",
                                                                    textAlign: TextAlign.left,
                                                                    style: GoogleFonts.lato(
                                                                      textStyle: TextStyle(color: colour.ButtonForeColor, fontWeight: FontWeight.bold, fontSize: objfun.FontCardText, letterSpacing: 0.3),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 2,
                                                                  child: Text(
                                                                    "JobDate",
                                                                    textAlign: TextAlign.left,
                                                                    style: GoogleFonts.lato(
                                                                      textStyle: TextStyle(color: colour.ButtonForeColor, fontWeight: FontWeight.bold, fontSize: objfun.FontCardText, letterSpacing: 0.3),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 2,
                                                                  child: Text(
                                                                    "Salary",
                                                                    textAlign: TextAlign.left,
                                                                    style: GoogleFonts.lato(
                                                                      textStyle: TextStyle(color: colour.ButtonForeColor, fontWeight: FontWeight.bold, fontSize: objfun.FontCardText, letterSpacing: 0.3),
                                                                    ),
                                                                  ),
                                                                ),

                                                              ],
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child:
                                                            Row(
                                                              children: <Widget>[
                                                                Expanded(
                                                                  flex: 3,
                                                                  child: Text(
                                                                    "Customer Name",
                                                                    textAlign: TextAlign.left,
                                                                    style: GoogleFonts.lato(
                                                                      textStyle: TextStyle(color: colour.ButtonForeColor, fontWeight: FontWeight.bold, fontSize: objfun.FontCardText, letterSpacing: 0.3),
                                                                    ),
                                                                  ),
                                                                ),

                                                              ],
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child:
                                                            Row(
                                                              children: <
                                                                  Widget>[
                                                                Expanded(
                                                                  flex: 2,
                                                                  child: Text(
                                                                    "PPic",
                                                                    textAlign: TextAlign.left,
                                                                    style: GoogleFonts.lato(
                                                                      textStyle: TextStyle(color: colour.ButtonForeColor, fontWeight: FontWeight.bold, fontSize: objfun.FontCardText, letterSpacing: 0.3),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 2,
                                                                  child: Text(
                                                                    "DPic",
                                                                    textAlign: TextAlign.left,
                                                                    style: GoogleFonts.lato(
                                                                      textStyle: TextStyle(color: colour.ButtonForeColor, fontWeight: FontWeight.bold, fontSize: objfun.FontCardText, letterSpacing: 0.3),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(height: 5,),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: height *
                                                        0.28,
                                                    child: (objfun
                                                        .RTIViewDetailList
                                                        .isNotEmpty
                                                        ? Container(
                                                        height: height /
                                                            1.4,
                                                        margin:
                                                        const EdgeInsets.all(
                                                            0),
                                                        padding: const EdgeInsets.only(
                                                            left:
                                                            0,
                                                            right:
                                                            0),
                                                        child: ListView.builder(
                                                            itemCount: state.RTIDetailsList.length,
                                                            itemBuilder: (BuildContext context, int index) {
                                                              return SizedBox(
                                                                  height: 75,
                                                                  child: InkWell(
                                                                    onLongPress: (){
                                                                      List<dynamic> RTIDetails = [{
                                                                        'RtiId' :state.RTIDetailsList[index]. RTIMasterRefId,
                                                                        'RTINo' :objfun.RTIViewMasterList[indexMaster].RTINoDisplay ,
                                                                        'JobId' :state.RTIDetailsList[index].SaleOrderMasterRefId.toString() ,
                                                                        'JobNo' : state.RTIDetailsList[index].JobNo.toString(),
                                                                      }];
                                                                      Navigator.push(context,MaterialPageRoute(builder:(context) =>  RTIStatus(RTIDetails : RTIDetails)));
                                                                    },
                                                                    child: Card(
                                                                      //margin: EdgeInsets.all(10.0),
                                                                        elevation: 10.0,
                                                                        borderOnForeground: true,
                                                                        semanticContainer: true,
                                                                        shape: RoundedRectangleBorder(
                                                                          side: const BorderSide(color: colour.commonColor, width: 1),
                                                                          borderRadius: BorderRadius.circular(10),
                                                                        ),
                                                                        child: Column(
                                                                          children: [
                                                                            Expanded(
                                                                              flex: 1,
                                                                              child: Row(
                                                                                children: [
                                                                                  Expanded(
                                                                                    flex: 2,
                                                                                    child: Text(
                                                                                      "  ${state.RTIDetailsList[index].JobNo}",
                                                                                      textAlign: TextAlign.left,
                                                                                      style: GoogleFonts.lato(
                                                                                        textStyle: TextStyle(color: colour.commonColor, fontWeight: FontWeight.bold, fontSize: objfun.FontCardText, letterSpacing: 0.3),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  Expanded(
                                                                                    flex: 2,
                                                                                    child: Text(
                                                                                      state.RTIDetailsList[index].JobDate.toString(),
                                                                                      textAlign: TextAlign.left,
                                                                                      style: GoogleFonts.lato(
                                                                                        textStyle: TextStyle(color: colour.commonColor, fontWeight: FontWeight.bold, fontSize: objfun.FontCardText, letterSpacing: 0.3),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  Expanded(
                                                                                    flex: 2,
                                                                                    child: Text(
                                                                                      state.RTIDetailsList[index].Salary.toString(),
                                                                                      textAlign: TextAlign.left,
                                                                                      style: GoogleFonts.lato(
                                                                                        textStyle: TextStyle(color: colour.commonColor, fontWeight: FontWeight.bold, fontSize: objfun.FontCardText, letterSpacing: 0.3),
                                                                                      ),
                                                                                    ),
                                                                                  ),

                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 1,
                                                                              child: Row(
                                                                                children: [
                                                                                  Expanded(
                                                                                    flex: 2,
                                                                                    child: Text(
                                                                                      "  ${state.RTIDetailsList[index].CustomerName}",
                                                                                      textAlign: TextAlign.left,
                                                                                      style: GoogleFonts.lato(
                                                                                        textStyle: TextStyle(color: colour.commonColor, fontWeight: FontWeight.bold, fontSize: objfun.FontCardText, letterSpacing: 0.3),
                                                                                      ),
                                                                                    ),
                                                                                  ),


                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 1,
                                                                              child: Row(
                                                                                children: [
                                                                                  Expanded(
                                                                                    flex: 2,
                                                                                    child: Text(
                                                                                      "  ${state.RTIDetailsList[index].PPIC}",
                                                                                      textAlign: TextAlign.left,
                                                                                      style: GoogleFonts.lato(
                                                                                        textStyle: TextStyle(color: colour.commonColor, fontWeight: FontWeight.bold, fontSize: objfun.FontCardText, letterSpacing: 0.3),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  Expanded(
                                                                                    flex: 2,
                                                                                    child: Text(
                                                                                      state.RTIDetailsList[index].DPIC.toString(),
                                                                                      textAlign: TextAlign.left,
                                                                                      style: GoogleFonts.lato(
                                                                                        textStyle: TextStyle(color: colour.commonColor, fontWeight: FontWeight.bold, fontSize: objfun.FontCardText, letterSpacing: 0.3),
                                                                                      ),
                                                                                    ),
                                                                                  ),

                                                                                ],
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 10,
                                                                            )
                                                                          ],
                                                                        )),
                                                                  )
                                                              );
                                                            }))
                                                        : Container(
                                                        width: width - 40.0,
                                                        height: height / 1.4,
                                                        padding: const EdgeInsets.all(20),
                                                        child: const Center(
                                                          child:
                                                          Text('No Record'),
                                                        ))),
                                                  ),
                                                ],
                                              ),
                                            ))
                                      ],
                                    )),
                              ));
                        }))
                    : Container(
                    width: width - 40.0,
                    height: height / 1.4,
                    padding: const EdgeInsets.all(20),
                    child:  Center(
                      child: Text('No Record',
                        style:GoogleFonts.lato(
                            textStyle:
                            TextStyle(
                                color: colour.commonColorLight,
                                fontWeight: FontWeight.bold,
                                fontSize: objfun.FontLow,
                                letterSpacing: 0.3)),
                      ),

                    ))),
              ),

            ],
          ),
        )),

        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialogFilter(context);
          },
          tooltip: 'Open filter',
          child: const Icon(Icons.filter_alt_outlined),
        ),
      ));
}