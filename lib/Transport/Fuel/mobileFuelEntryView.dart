part of 'package:maleva/Transport/Fuel/FuelEntryView.dart';


mobiledesign(OldFuelEntryViewState state, BuildContext context) {
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
                    child: Text('Fuel Entry View',
                        style:GoogleFonts.lato(
                            textStyle: TextStyle(
                              color: colour.topAppBarColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Alatsi',
                              fontSize: objfun.FontMedium,
                            ))
                    )),
                Expanded(
                  flex: 1,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
        ) : SizedBox(
          height: height * 0.90,
          child:
          Padding(
            padding: const EdgeInsets.only(
                top: 15, left: 15.0, right: 15.0),
            child: ListView(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
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
                                  state.setState(() {
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
                                  state.setState(() {
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
                    Expanded(
                      flex: 3,
                      child:    ElevatedButton(
                        onPressed: () {
                          state.loaddata();
                        },
                        child: Text(
                          'View',
                          style:GoogleFonts.lato(
                              textStyle: TextStyle(fontSize: objfun.FontLow)),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: height * 0.06,
                  margin: const EdgeInsets.all(0),
                  padding:
                  const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(10.0),
                    border: Border.all(
                        width: 1.0,
                        color: colour.commonColorLight),
                    color: colour.commonColor,
                  ),
                  child: state.loadgridheader(),
                ),

                SizedBox(
                  height: height * 0.66,
                  child: (state.showdetails.isNotEmpty
                      ? Container(
                      height: height / 1.4,
                      margin: const EdgeInsets.all(0),
                      padding: const EdgeInsets.all(0),
                      child: ListView.builder(
                          itemCount:
                          state.showdetails.length,
                          itemBuilder:
                              (BuildContext context, int index) {
                            return SizedBox(
                                height: height * 0.10,
                                child: InkWell(

                                  child: Card(
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
                                                (index + 1)
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
                                                state.showdetails[index]['SSaleDate'],
                                                textAlign:
                                                TextAlign
                                                    .center,
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
                                                state.showdetails[index]['Aliter']
                                                    .toStringAsFixed(2),
                                                textAlign:
                                                TextAlign
                                                    .right,
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
                                                  .all(5),
                                              child: Text(
                                                state.showdetails[index]['AAmount']
                                                    .toStringAsFixed(2),
                                                textAlign:
                                                TextAlign
                                                    .right,
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
                                            flex: 1,
                                            child: IconButton(
                                              onPressed:
                                                  () {
                                                    state.deletedata(state.showdetails[index]);
                                              },
                                              icon:
                                              const Icon(Icons.delete_outline_rounded),
                                              color:
                                              colour.commonColorhighlight,
                                            ),
                                          ),
                                        ],
                                      )),
                                ));
                          }))
                      : Container(
                      width: width - 40.0,
                      height: height / 1.4,
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Text('No Record',
                          style:
                          GoogleFonts.lato(
                              textStyle:TextStyle(
                                  color: colour.commonColorLight,
                                  fontWeight: FontWeight.bold,
                                  fontSize: objfun.FontLow,
                                  letterSpacing: 0.3)),
                        ),

                      ))),
                ),
              ],
            ),
          ),),
      ));
}