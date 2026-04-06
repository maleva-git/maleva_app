part of 'package:maleva/Transport/Maintenance.dart';


tabletdesign(OldMaintenanceState state, BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;
  return WillPopScope(
      onWillPop: state._onBackPressed,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back,size: 35,),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title:  SizedBox(
            height: height * 0.05,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
               Text('Truck Maintenance',
                        style:GoogleFonts.lato(
                            textStyle: TextStyle(
                              color: colour.topAppBarColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Alatsi',
                              fontSize: objfun.FontMedium,
                            ))),

                        Text(" - ${state.UserName}",
                            style:GoogleFonts.lato(
                                textStyle: TextStyle(
                                  color: colour.commonColorLight,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Alatsi',
                                  fontSize: objfun.FontLow - 2,
                                ))),

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
            :      Container(
  padding: const EdgeInsets.only(
  top: 25.0, left: 50.0, right: 50.0),
  child: Card(
  elevation: 15,
  child: Padding(
  padding: const EdgeInsets.only(
  top: 15.0, left: 80.0, right: 80.0),
  child: ListView(
          children: <Widget>[
            const SizedBox(height: 7,),
            Visibility(
                visible: state.VisibleTruck,
                child: SizedBox(
                  height: height * 0.07,
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
                              hintText: "Select Truck No",
                              hintStyle: GoogleFonts.lato(
                                  textStyle:TextStyle(
                                      fontSize: objfun.FontMedium,
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
                                            state.setState(() {
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

                                            if( state.txtTruckNo.text != ""){
                                              state.loaddata();
                                            }
                                          });
                                    }
                                    else {
                                      state.setState(() {
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
                      )
                    ],
                  ),
                )),
            const SizedBox(height: 5,),
            (objfun.TruckDetailsList.isNotEmpty
                ? Container(
                height: height / 1.2,
                margin: const EdgeInsets.all(0),
                padding:
                const EdgeInsets.only(left: 20, right: 20),
                child: ListView.builder(
                    itemCount:
                    objfun.TruckDetailsList.length,
                    itemBuilder:
                        (BuildContext context, int index) {
                      return SizedBox(
                          height: height * 0.65,
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
                                    Expanded(child:Center(
                                      child: Text("Expiry till the date ${state.ExpDate}",style:GoogleFonts.lato(
                                        textStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: objfun.FontMedium
                                        ),)),
                                    ) ),
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
                                              flex: 3,
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
                                            Expanded(
                                              flex: 3,
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
                                              flex: 3,
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
                                            Expanded(
                                              flex: 3,
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
                                              flex: 3,
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
                                            Expanded(
                                              flex: 3,
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
                                              flex: 3,
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
                                            Expanded(
                                              flex: 3,
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
                                              flex: 3,
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
                                            Expanded(
                                              flex: 3,
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
                                              flex: 3,
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
                                            Expanded(
                                              flex: 3,
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
                                              flex: 3,
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
                                            Expanded(
                                              flex: 3,
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
          ],
        ),))
        ), ));
}