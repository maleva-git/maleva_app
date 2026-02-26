part of 'package:maleva/Transport/Fuel/FuelEntry.dart';


mobiledesign(FuelEntryState state, BuildContext context) {
  double width = MediaQuery
      .of(context)
      .size
      .width;
  double height = MediaQuery
      .of(context)
      .size
      .height;
  return WillPopScope(
      onWillPop: state._onBackPressed,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          key: state.appBarKey,
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
                Expanded(
                    flex: 1,
                    child: Text('Fuel Entry',
                        style:GoogleFonts.lato(
                            textStyle: TextStyle(
                              color: colour.topAppBarColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Alatsi',
                              fontSize: objfun.FontMedium,
                            )))),
                Expanded(
                  flex: 1,
                  child: Row(
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
                ),
              ],
            ),
          ),
          iconTheme: const IconThemeData(color: colour.topAppBarColor),
          actions: <Widget>[
            Padding(
              padding:
              const EdgeInsets.only(top: 7.0, bottom: 7.0, left: 7.0),
              child: SizedBox(
                width: 70,
                height: 25,
                child: ElevatedButton(
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
                      MaterialPageRoute(builder: (context) => const FuelEntryView()),
                    ).then((dynamic value) {

                    });
                  },
                  child: Text(
                    'View',
                    style: GoogleFonts.lato(
                        fontSize: objfun.FontMedium,
                        // height: 1.45,
                        fontWeight: FontWeight.bold,
                        color: colour.commonColor),
                  ),
                ),
              ),
            ),

            const SizedBox(
              width: 10,
            )
          ],

        ),
        drawer: const Menulist(),
        body: state.progress == false
            ? const Center(
          child: SpinKitFoldingCube(
            color: colour.spinKitColor,
            size: 35.0,
          ),
        ) : SizedBox(
          height: height * 0.90,
          child:
          Padding(
            padding: EdgeInsets.only(
                top: height * 0.20, left: 15.0, right: 15.0),
            child: ListView(
              children: <Widget>[

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
                  child: Text('Truck Name - ${objfun.DriverTruckName}',
                    style: GoogleFonts
                        .lato(
                      textStyle: TextStyle(
                          color: colour
                              .commonColor,
                          fontWeight:
                          FontWeight
                              .bold,
                          fontSize: objfun
                              .FontLarge,
                          letterSpacing:
                          0.3),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      flex: 4,
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
                        child: Text('Fuel No',
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
                    Expanded(
                        flex: 8,
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
                          decoration: BoxDecoration(
                            borderRadius:
                            BorderRadius.circular(10.0),
                            border: Border.all(
                                width: 1.0,
                                color: colour.commonColorLight),
                            color: colour.ButtonForeColor,
                          ),
                          child: TextField(

                            cursorColor: colour.commonColor,
                            controller: state.txtfuelno,
                            readOnly: true,
                            autofocus: true,
                            showCursor: true,
                            enabled: false,
                            textInputAction: TextInputAction.done,
                            textCapitalization:
                            TextCapitalization.characters,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(

                              textStyle: TextStyle(


                                  color: colour.commonColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: objfun.FontLow - 2,
                                  letterSpacing: 0.3),
                            ),
                          ),
                        )),
                  ],
                ),
                Row(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                    children: <Widget>[
                      Expanded(
                        flex: 4,
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
                          child: Text('Entry Date',
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
                      Expanded(
                          flex: 8,
                          child: InkWell(
                              onTap: () async {
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
                                    state.dtpdate =
                                        DateFormat("yyyy-MM-dd")
                                            .format(datenew);
                                  });
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.zero,
                                margin: EdgeInsets.zero,
                                decoration: BoxDecoration(
                                  borderRadius:
                                  const BorderRadius.all(Radius.circular(10.0)),
                                  border: Border.all(
                                      width: 1.0,
                                      color: colour.commonColorLight),
                                  color: colour.ButtonForeColor,
                                  shape: BoxShape.rectangle,
                                ),
                                child:
                                Row(children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      DateFormat("dd-MM-yy").format(
                                          DateTime.parse(
                                              state.dtpdate.toString())),
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.lato(
                                        textStyle: TextStyle(
                                            color: colour.commonColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: objfun.FontLow,
                                            letterSpacing: 0.3),
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
                                            onPressed: () {}
                                        )),
                                  ),
                                ]),
                              ))
                      ),
                    ]
                ),
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
                  children: <Widget>[
                    Expanded(
                      flex: 4,
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
                        child: Text('Liter',
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
                    Expanded(
                      flex: 8,
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
                          controller: state.txtliter,
                          autofocus: false,
                          showCursor: true,
                          decoration:
                          const InputDecoration(
                            fillColor: colour
                                .commonColor,
                            enabledBorder:
                            OutlineInputBorder(
                              borderRadius:
                              BorderRadius.all(
                                  Radius.circular(
                                      10.0)),
                              borderSide: BorderSide(
                                  color: colour
                                      .commonColor),
                            ),
                            focusedBorder:
                            OutlineInputBorder(
                              borderRadius:
                              BorderRadius.all(
                                  Radius.circular(
                                      10.0)),
                              borderSide: BorderSide(
                                  color: colour
                                      .commonColorred),
                            ),
                            contentPadding:
                            EdgeInsets.only(
                                left: 10,
                                right: 20,
                                top: 10.0),
                          ),
                          keyboardType: TextInputType.number,
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

                  ],
                ),
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
                  children: <Widget>[
                    Expanded(
                      flex: 4,
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
                        child: Text('Amount',
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
                    Expanded(
                      flex: 8,
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
                          controller: state.txtamount,
                          autofocus: false,
                          showCursor: true,
                          decoration:
                          const InputDecoration(
                            fillColor: colour
                                .commonColor,
                            enabledBorder:
                            OutlineInputBorder(
                              borderRadius:
                              BorderRadius.all(
                                  Radius.circular(
                                      10.0)),
                              borderSide: BorderSide(
                                  color: colour
                                      .commonColor),
                            ),
                            focusedBorder:
                            OutlineInputBorder(
                              borderRadius:
                              BorderRadius.all(
                                  Radius.circular(
                                      10.0)),
                              borderSide: BorderSide(
                                  color: colour
                                      .commonColorred),
                            ),
                            contentPadding:
                            EdgeInsets.only(
                                left: 10,
                                right: 20,
                                top: 10.0),
                          ),
                          keyboardType: TextInputType.number,
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
                Padding(
                  padding:
                  const EdgeInsets.only(top: 7.0, bottom: 7.0, left: 7.0),
                  child: SizedBox(
                    width: 70,
                    height: 50,
                    child: ElevatedButton(
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
                        state.savefuel();
                      },
                      child: Text(
                        'Save',
                        style: GoogleFonts.lato(
                            fontSize: objfun.FontMedium,
                            // height: 1.45,
                            fontWeight: FontWeight.bold,
                            color: colour.commonColor),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),),
      ));
}