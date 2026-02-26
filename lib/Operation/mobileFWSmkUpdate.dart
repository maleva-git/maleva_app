part of 'package:maleva/Operation/FWSmkUpdate.dart';


mobiledesign(FWSmkUpdateState state, BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;
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
              if(state.overlayEntry != null){
                state.clearOverlay();
              }
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
                    child: Text('SMK Update',
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
                    state.UpdateForwarding();
                  },
                  child: Text(
                    'Update',
                    style: GoogleFonts.lato(
                        fontSize: objfun.FontMedium,
                        // height: 1.45,
                        fontWeight: FontWeight.bold,
                        color: colour.commonColor),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8,)
          ],

        ),
        drawer: const Menulist(),
        body: state.progress == false
            ? const Center(
          child: SpinKitFoldingCube(
            color: colour.spinKitColor,
            size: 35.0,
          ),
        )
            :  DefaultTabController(
          length: 3,
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
                          children: [
                            Expanded(
                              // width: 250,
                              flex: 1,
                              child: Radio(
                                value: "0",
                                groupValue: state.BillType,
                                onChanged: (value) {
                                  state.setState(() {
                                    state.BillType = value.toString();
                                  });
                                  OnlineApi.GetJobNoForwarding(context,int.parse(state.BillType));
                                },
                              ),
                            ),
                            Expanded(
                              // width: 250,
                              flex: 1,
                              child: Text(
                                "MY",
                                style: GoogleFonts.lato(
                                    textStyle:TextStyle(
                                        color: colour.commonColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: objfun.FontMedium,
                                        letterSpacing: 0.3)),
                              ),
                            ),
                            Expanded(
                              // width: 250,
                              flex: 1,
                              child: Radio(
                                value: "1",
                                groupValue: state.BillType,
                                onChanged: (value) {

                                  state.setState(() {
                                    state.BillType = value.toString();
                                  });
                                  OnlineApi.GetJobNoForwarding(context,int.parse(state.BillType));
                                },
                              ),
                            ),
                            Expanded(
                              // width: 250,
                              flex: 1,
                              child: Text(
                                "TR",
                                style:GoogleFonts.lato(
                                    textStyle: TextStyle(
                                        color: colour.commonColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: objfun.FontMedium,
                                        letterSpacing: 0.3)),
                              ),
                            ),


                          ]),
                      Container(
                        width: objfun.SizeConfig.safeBlockHorizontal * 99,
                        height: objfun.SizeConfig.safeBlockVertical * 6,
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.only(bottom: 5),
                        child: TextField(
                          cursorColor: colour.commonColor,
                          controller: state.txtJobNo,
                          autofocus: false,
                          showCursor: true,
                          decoration: InputDecoration(
                            hintText: ('Job No'),
                            hintStyle:GoogleFonts.lato(
                                textStyle: TextStyle(
                                    fontSize: objfun.FontMedium,
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
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                                color: colour.commonColor,
                                fontWeight: FontWeight.bold,
                                fontSize: objfun.FontLow,
                                letterSpacing: 0.3),
                          ),
                          onChanged: (value) {
                            Future.delayed(const Duration(milliseconds: 500));
                            state.setState(() {
                              state.autoCompleteSearch(value, false);
                            });
                          },
                        ),
                      ),

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child:  Container(
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
                                          state.dtpFW1date
                                              .toString()))
                                          : DateFormat("dd-MM-yyyy")
                                          .format(DateTime.parse(
                                          state.dtpFW1date
                                              .toString())),
                                      style: GoogleFonts.lato(
                                          textStyle:TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: objfun.FontLow,
                                            color: state.checkBoxValueFW1 ==
                                                true
                                                ? colour.commonColor
                                                : colour
                                                .commonColorDisabled,)),
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
                                        if (state.checkBoxValueFW1) {
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
                                              state.dtpFW1date =
                                                  DateFormat("yyyy-MM-dd")
                                                      .format(datenew);
                                            });
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 1,
                              child: Text("")

                          ),
                          Expanded(
                              flex: 1,
                              child: Transform.scale(
                                scale: 1.3,
                                child: Checkbox(
                                  value: state.checkBoxValueFW1,
                                  side: const BorderSide(
                                      color:
                                      colour.commonColor),
                                  activeColor:
                                  colour.commonColorred,
                                  onChanged: (bool? value) {
                                    state.setState(() {
                                      state.checkBoxValueFW1 =
                                      value!;
                                      if (state.checkBoxValueFW1 ==
                                          false) {
                                        // state.dtpFW1date = DateFormat(
                                        //     "yyyy-MM-dd HH:mm:ss ")
                                        //     .format(
                                        //     DateTime.now());
                                      }
                                    });

                                    // else{
                                    //   buildDropDownMenuItemsCash();
                                    // }
                                  },
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(
                        height: 7,
                      ),
                      Row(
                        children: [
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
                                  onChanged: (String? value) {
                                    state.setState(() {
                                      state.dropdownValueFW1 = value!;
                                    });
                                  },
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
                                  items: FWSmkUpdateState.ForwardingNo.map<
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
                        height: 7,
                      ),
                      Row(
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
                                controller: state.txtSmkNo,
                                autofocus: false,
                                showCursor: true,
                                decoration:
                                InputDecoration(
                                  hintText:
                                  ('SMK NO 1'),
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

                        ],
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Row(
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
                                showCursor: true,
                                decoration:
                                InputDecoration(
                                  hintText:
                                  ('R.No 1'),
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

                        ],
                      ),
                      Container(
                        width: objfun.SizeConfig.safeBlockHorizontal * 99,
                        height: objfun.SizeConfig.safeBlockVertical * 6,
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.only(bottom: 5),
                        child: TextField(
                          cursorColor: colour.commonColor,
                          controller: state.txtForwarding1S1,
                          autofocus: false,
                          showCursor: true,
                          decoration: InputDecoration(
                            hintText: ('S1'),
                            hintStyle:GoogleFonts.lato(
                                textStyle: TextStyle(
                                    fontSize: objfun.FontMedium,
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
                          keyboardType: TextInputType.text,
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                                color: colour.commonColor,
                                fontWeight: FontWeight.bold,
                                fontSize: objfun.FontLow,
                                letterSpacing: 0.3),
                          ),
                          onChanged: (value) {
                           // Future.delayed(const Duration(milliseconds: 500));
                           //  state.setState(() {
                           //    state.autoCompleteSearchS1(value, false,1);
                           //  });
                          },
                        ),
                      ),
                      Container(
                        width: objfun.SizeConfig.safeBlockHorizontal * 99,
                        height: objfun.SizeConfig.safeBlockVertical * 6,
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.only(bottom: 5),
                        child: TextField(
                          cursorColor: colour.commonColor,
                          controller: state.txtForwarding1S2,
                          autofocus: false,
                          showCursor: true,
                          decoration: InputDecoration(
                            hintText: ('S2'),
                            hintStyle:GoogleFonts.lato(
                                textStyle: TextStyle(
                                    fontSize: objfun.FontMedium,
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
                          keyboardType: TextInputType.text,
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                                color: colour.commonColor,
                                fontWeight: FontWeight.bold,
                                fontSize: objfun.FontLow,
                                letterSpacing: 0.3),
                          ),
                          onChanged: (value) {
                            // Future.delayed(const Duration(milliseconds: 500));
                            // state.setState(() {
                            //   state.autoCompleteSearchS1(value, false,2);
                            // });
                          },
                        ),
                      ),

                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 15.0, left: 15.0, right: 15.0),
                  child: ListView(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child:  Container(
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
                                          state.dtpFW2date
                                              .toString()))
                                          : DateFormat("dd-MM-yyyy")
                                          .format(DateTime.parse(
                                          state.dtpFW2date
                                              .toString())),
                                      style: GoogleFonts.lato(
                                          textStyle:TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: objfun.FontLow,
                                            color: state.checkBoxValueFW2 ==
                                                true
                                                ? colour.commonColor
                                                : colour
                                                .commonColorDisabled,)),
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
                                        if (state.checkBoxValueFW2) {
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
                                              state.dtpFW2date =
                                                  DateFormat("yyyy-MM-dd")
                                                      .format(datenew);
                                            });
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Expanded(
                              flex: 1,
                              child: Text("")

                          ),
                          Expanded(
                              flex: 1,
                              child: Transform.scale(
                                scale: 1.3,
                                child: Checkbox(
                                  value: state.checkBoxValueFW2,
                                  side: const BorderSide(
                                      color:
                                      colour.commonColor),
                                  activeColor:
                                  colour.commonColorred,
                                  onChanged: (bool? value) {
                                    state.setState(() {
                                      state.checkBoxValueFW2 =
                                      value!;
                                      if (state.checkBoxValueFW2 ==
                                          false) {
                                        // state.dtpFW1date = DateFormat(
                                        //     "yyyy-MM-dd HH:mm:ss ")
                                        //     .format(
                                        //     DateTime.now());
                                      }
                                    });

                                    // else{
                                    //   buildDropDownMenuItemsCash();
                                    // }
                                  },
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(
                        height: 7,
                      ),
                      Row(
                        children: [
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
                                  onChanged: (String? value) {
                                    state.setState(() {
                                      state.dropdownValueFW2 = value!;
                                    });
                                  },
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
                                  items: FWSmkUpdateState.ForwardingNo.map<
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
                        height: 7,
                      ),
                      Row(
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
                                controller: state.txtSmkNo2,
                                autofocus: false,
                                showCursor: true,
                                decoration:
                                InputDecoration(
                                  hintText:
                                  ('SMK NO 2'),
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

                        ],
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Row(
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
                                showCursor: true,
                                decoration:
                                InputDecoration(
                                  hintText:
                                  ('R.No 2'),
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

                        ],
                      ),
                      Container(
                        width: objfun.SizeConfig.safeBlockHorizontal * 99,
                        height: objfun.SizeConfig.safeBlockVertical * 6,
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.only(bottom: 5),
                        child: TextField(
                          cursorColor: colour.commonColor,
                          controller: state.txtForwarding2S1,
                          autofocus: false,
                          showCursor: true,
                          decoration: InputDecoration(
                            hintText: ('S1'),
                            hintStyle:GoogleFonts.lato(
                                textStyle: TextStyle(
                                    fontSize: objfun.FontMedium,
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
                          keyboardType: TextInputType.text,
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                                color: colour.commonColor,
                                fontWeight: FontWeight.bold,
                                fontSize: objfun.FontLow,
                                letterSpacing: 0.3),
                          ),
                          onChanged: (value) {
                            // Future.delayed(const Duration(milliseconds: 500));
                            // state.setState(() {
                            //   state.autoCompleteSearchS1(value, false,3);
                            // });
                          },
                        ),
                      ),
                      Container(
                        width: objfun.SizeConfig.safeBlockHorizontal * 99,
                        height: objfun.SizeConfig.safeBlockVertical * 6,
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.only(bottom: 5),
                        child: TextField(
                          cursorColor: colour.commonColor,
                          controller: state.txtForwarding2S2,
                          autofocus: false,
                          showCursor: true,
                          decoration: InputDecoration(
                            hintText: ('S2'),
                            hintStyle:GoogleFonts.lato(
                                textStyle: TextStyle(
                                    fontSize: objfun.FontMedium,
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
                          keyboardType: TextInputType.text,
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                                color: colour.commonColor,
                                fontWeight: FontWeight.bold,
                                fontSize: objfun.FontLow,
                                letterSpacing: 0.3),
                          ),
                          onChanged: (value) {
                            // Future.delayed(const Duration(milliseconds: 500));
                            // state.setState(() {
                            //   state.autoCompleteSearchS1(value, false,4);
                            // });
                          },
                        ),
                      ),

                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 15.0, left: 15.0, right: 15.0),
                  child: ListView(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child:  Container(
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
                                          state.dtpFW3date
                                              .toString()))
                                          : DateFormat("dd-MM-yyyy")
                                          .format(DateTime.parse(
                                          state.dtpFW3date
                                              .toString())),
                                      style: GoogleFonts.lato(
                                          textStyle:TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: objfun.FontLow,
                                            color: state.checkBoxValueFW3 ==
                                                true
                                                ? colour.commonColor
                                                : colour
                                                .commonColorDisabled,)),
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
                                        if (state.checkBoxValueFW3) {
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
                                              state.dtpFW3date =
                                                  DateFormat("yyyy-MM-dd")
                                                      .format(datenew);
                                            });
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Expanded(
                              flex: 1,
                              child: Text("")

                          ),
                          Expanded(
                              flex: 1,
                              child: Transform.scale(
                                scale: 1.3,
                                child: Checkbox(
                                  value: state.checkBoxValueFW3,
                                  side: const BorderSide(
                                      color:
                                      colour.commonColor),
                                  activeColor:
                                  colour.commonColorred,
                                  onChanged: (bool? value) {
                                    state.setState(() {
                                      state.checkBoxValueFW3 =
                                      value!;
                                      if (state.checkBoxValueFW3 ==
                                          false) {
                                        // state.dtpFW1date = DateFormat(
                                        //     "yyyy-MM-dd HH:mm:ss ")
                                        //     .format(
                                        //     DateTime.now());
                                      }
                                    });

                                    // else{
                                    //   buildDropDownMenuItemsCash();
                                    // }
                                  },
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(
                        height: 7,
                      ),
                      Row(
                        children: [
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
                                  onChanged: (String? value) {
                                    state.setState(() {
                                      state.dropdownValueFW3 = value!;
                                    });
                                  },
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
                                  items: FWSmkUpdateState.ForwardingNo.map<
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
                        height: 7,
                      ),
                      Row(
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
                                controller: state.txtSmkNo3,
                                autofocus: false,
                                showCursor: true,
                                decoration:
                                InputDecoration(
                                  hintText:
                                  ('SMK NO 3'),
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

                        ],
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Row(
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
                                showCursor: true,
                                decoration:
                                InputDecoration(
                                  hintText:
                                  ('R.No 3'),
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

                        ],
                      ),
                      Container(
                        width: objfun.SizeConfig.safeBlockHorizontal * 99,
                        height: objfun.SizeConfig.safeBlockVertical * 6,
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.only(bottom: 5),
                        child: TextField(
                          cursorColor: colour.commonColor,
                          controller: state.txtForwarding3S1,
                          autofocus: false,
                          showCursor: true,
                          decoration: InputDecoration(
                            hintText: ('S1'),
                            hintStyle:GoogleFonts.lato(
                                textStyle: TextStyle(
                                    fontSize: objfun.FontMedium,
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
                          keyboardType: TextInputType.text,
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                                color: colour.commonColor,
                                fontWeight: FontWeight.bold,
                                fontSize: objfun.FontLow,
                                letterSpacing: 0.3),
                          ),
                          onChanged: (value) {
                            // Future.delayed(const Duration(milliseconds: 500));
                            // state.setState(() {
                            //   state.autoCompleteSearchS1(value, false,5);
                            // });
                          },
                        ),
                      ),
                      Container(
                        width: objfun.SizeConfig.safeBlockHorizontal * 99,
                        height: objfun.SizeConfig.safeBlockVertical * 6,
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.only(bottom: 5),
                        child: TextField(
                          cursorColor: colour.commonColor,
                          controller: state.txtForwarding3S2,
                          autofocus: false,
                          showCursor: true,
                          decoration: InputDecoration(
                            hintText: ('S2'),
                            hintStyle:GoogleFonts.lato(
                                textStyle: TextStyle(
                                    fontSize: objfun.FontMedium,
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
                          keyboardType: TextInputType.text,
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                                color: colour.commonColor,
                                fontWeight: FontWeight.bold,
                                fontSize: objfun.FontLow,
                                letterSpacing: 0.3),
                          ),
                          onChanged: (value) {
                            // Future.delayed(const Duration(milliseconds: 500));
                            // state.setState(() {
                            //   state.autoCompleteSearchS1(value, false,6);
                            // });
                          },
                        ),
                      ),

                    ],
                  ),
                ),
              ]),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: colour.commonColorLight,
          unselectedItemColor: colour.commonHeadingColor.withOpacity(0.5),
          currentIndex: state._tabController.index,
          selectedLabelStyle: GoogleFonts.lato(
            textStyle: TextStyle(

                fontWeight: FontWeight.bold,
                fontSize: objfun.FontLow,
                letterSpacing: 0.3),
          ),
          unselectedLabelStyle:GoogleFonts.lato(
            textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: objfun.FontCardText,
                letterSpacing: 0.3),
          ) ,
          onTap:(index) => state.setState(() {
            state._tabController.index = index;
          }),
          items: const [
            BottomNavigationBarItem(icon: Icon(
              Icons.local_shipping_sharp,
            ),
              label: "FW 1",
            ),
            BottomNavigationBarItem(icon: Icon(
              Icons.local_shipping_sharp,
            ),
              label: "FW 2",
            ),
            BottomNavigationBarItem(icon: Icon(
              Icons.local_shipping_sharp,
            ), label: "FW 3"),
          ],
        ),
      ));
}