part of 'package:maleva/Operation/FWUpdate.dart';

tabletdesign(FWUpdateState state, BuildContext context) {
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
               Text('FW Entry Update',
                        style: GoogleFonts.lato(
                            textStyle:TextStyle(
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
          actions: <Widget>[
            Padding(
              padding:
              const EdgeInsets.only(top: 7.0, bottom: 7.0, left: 7.0),
              child: SizedBox(
                width: 125,
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
        )
            :  DefaultTabController(
          length: 3,
             child: TabBarView(
              controller: state._tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
               Padding(
          padding: const EdgeInsets.only(
              top: 25.0, left: 100.0, right: 100.0),
          child: Card(
              elevation: 15,
              child: Container(
                padding: const EdgeInsets.only(
                    top: 15.0, left: 50.0, right: 50.0),
                child:  ListView(
                    children: <Widget>[

                      Container(
                        width: objfun.SizeConfig.safeBlockHorizontal * 99,
                        height: objfun.SizeConfig.safeBlockVertical * 7,
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.only(bottom: 5),
                        child: TextField(
                          cursorColor: colour.commonColor,
                          controller: state.txtSmk1,
                          autofocus: false,
                          showCursor: true,
                          decoration: InputDecoration(
                            hintText: ('SMK No 1'),
                            hintStyle: GoogleFonts.lato(
                                textStyle:TextStyle(
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
                              state.autoCompleteSearch(value, false,1);
                            });
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 7,
                      ),
                   /*   Row(
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
                                  ('EN.Ref 1'),
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
                      SizedBox(
                        height: 7,
                      ),*/
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
                            suffixIcon: InkWell(
                                child: Icon(
                                    (state.txtSealByEmp1.text
                                        .isNotEmpty)
                                        ? Icons.close
                                        : Icons
                                        .search_rounded,
                                    color: colour
                                        .commonColorred,
                                    size: 35.0),
                                onTap: () async {
                                  if (state.txtSealByEmp1
                                      .text ==
                                      "") {
                                    await OnlineApi
                                        .SelectEmployee(
                                        context,
                                        '',
                                        'Operation');
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                          const Employee(
                                              Searchby:
                                              1,
                                              SearchId:
                                              0)),
                                    ).then((dynamic
                                    value) async {
                                      state.setState(() {
                                        state.txtSealByEmp1
                                            .text =
                                            objfun
                                                .SelectEmployeeList
                                                .AccountName;
                                        state.SealEmpId1 = objfun
                                            .SelectEmployeeList
                                            .Id;
                                        objfun.SelectEmployeeList =
                                            EmployeeModel
                                                .Empty();
                                      });
                                    });
                                  } else {
                                    state.setState(() {
                                      state.txtSealByEmp1.text =
                                      "";
                                      state.SealEmpId1 = 0;
                                      objfun.SelectEmployeeList =
                                          EmployeeModel
                                              .Empty();
                                    });
                                  }
                                }),
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
                                controller: state.txtExRef1,
                                autofocus: false,
                                showCursor: true,
                                decoration:
                                InputDecoration(
                                  hintText:
                                  ('EX.Ref 1'),
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
                      const SizedBox(
                        height: 7,
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
                            suffixIcon: InkWell(
                                child: Icon(
                                    (state.txtBreakByEmp1.text
                                        .isNotEmpty)
                                        ? Icons.close
                                        : Icons
                                        .search_rounded,
                                    color: colour
                                        .commonColorred,
                                    size: 35.0),
                                onTap: () async {
                                  await OnlineApi
                                      .SelectEmployee(
                                      context,
                                      '',
                                      'Operation');
                                  if (state.txtBreakByEmp1
                                      .text ==
                                      "") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                          const Employee(
                                              Searchby:
                                              1,
                                              SearchId:
                                              0)),
                                    ).then((dynamic
                                    value) async {
                                      state.setState(() {
                                        state.txtBreakByEmp1
                                            .text =
                                            objfun
                                                .SelectEmployeeList
                                                .AccountName;
                                        state.BreakEmpId1 = objfun
                                            .SelectEmployeeList
                                            .Id;
                                        objfun.SelectEmployeeList =
                                            EmployeeModel
                                                .Empty();
                                      });
                                    });
                                  } else {
                                    state.setState(() {
                                      state.txtBreakByEmp1
                                          .text = "";
                                      state.BreakEmpId1 = 0;
                                      objfun.SelectEmployeeList =
                                          EmployeeModel
                                              .Empty();
                                    });
                                  }
                                }),
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
                      const SizedBox(height: 7,),


                    ],
                  ),
                ))),
               Padding(
          padding: const EdgeInsets.only(
              top: 25.0, left: 100.0, right: 100.0),
          child: Card(
              elevation: 15,
              child: Container(
                padding: const EdgeInsets.only(
                    top: 15.0, left: 50.0, right: 50.0),
                child:  ListView(
                    children: <Widget>[
                      const SizedBox(
                        height: 7,
                      ),
                      Container(
                        width: objfun.SizeConfig.safeBlockHorizontal * 99,
                        height: objfun.SizeConfig.safeBlockVertical * 7,
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.only(bottom: 5),
                        child: TextField(
                          cursorColor: colour.commonColor,
                          controller: state.txtSmk2,
                          autofocus: false,
                          showCursor: true,
                          decoration: InputDecoration(
                            hintText: ('SMK No 2'),
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
                              state.autoCompleteSearch(value, false,2);
                            });
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 7,
                      ),
                   /*   Row(
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
                      SizedBox(
                        height: 7,
                      ),*/
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
                            suffixIcon: InkWell(
                                child: Icon(
                                    (state.txtSealByEmp2.text
                                        .isNotEmpty)
                                        ? Icons.close
                                        : Icons
                                        .search_rounded,
                                    color: colour
                                        .commonColorred,
                                    size: 35.0),
                                onTap: () async {
                                  if (state.txtSealByEmp2
                                      .text ==
                                      "") {
                                    await OnlineApi
                                        .SelectEmployee(
                                        context,
                                        '',
                                        'Operation');
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                          const Employee(
                                              Searchby:
                                              1,
                                              SearchId:
                                              0)),
                                    ).then((dynamic
                                    value) async {
                                      state.setState(() {
                                        state.txtSealByEmp2
                                            .text =
                                            objfun
                                                .SelectEmployeeList
                                                .AccountName;
                                        state.SealEmpId2 = objfun
                                            .SelectEmployeeList
                                            .Id;
                                        objfun.SelectEmployeeList =
                                            EmployeeModel
                                                .Empty();
                                      });
                                    });
                                  } else {
                                    state.setState(() {
                                      state.txtSealByEmp2.text =
                                      "";
                                      state.SealEmpId2 = 0;
                                      objfun.SelectEmployeeList =
                                          EmployeeModel
                                              .Empty();
                                    });
                                  }
                                }),
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
                                controller: state.txtExRef2,
                                autofocus: false,
                                showCursor: true,
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
                      const SizedBox(
                        height: 7,
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
                            suffixIcon: InkWell(
                                child: Icon(
                                    (state.txtBreakByEmp2.text
                                        .isNotEmpty)
                                        ? Icons.close
                                        : Icons
                                        .search_rounded,
                                    color: colour
                                        .commonColorred,
                                    size: 35.0),
                                onTap: () async {
                                  await OnlineApi
                                      .SelectEmployee(
                                      context,
                                      '',
                                      'Operation');
                                  if (state.txtBreakByEmp2
                                      .text ==
                                      "") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                          const Employee(
                                              Searchby:
                                              1,
                                              SearchId:
                                              0)),
                                    ).then((dynamic
                                    value) async {
                                      state.setState(() {
                                        state.txtBreakByEmp2
                                            .text =
                                            objfun
                                                .SelectEmployeeList
                                                .AccountName;
                                        state.BreakEmpId2 = objfun
                                            .SelectEmployeeList
                                            .Id;
                                        objfun.SelectEmployeeList =
                                            EmployeeModel
                                                .Empty();
                                      });
                                    });
                                  } else {
                                    state.setState(() {
                                      state.txtBreakByEmp2
                                          .text = "";
                                      state.BreakEmpId2 = 0;
                                      objfun.SelectEmployeeList =
                                          EmployeeModel
                                              .Empty();
                                    });
                                  }
                                }),
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

                    ],
                  ),
              ))),
               Padding(
          padding: const EdgeInsets.only(
              top: 25.0, left: 100.0, right: 100.0),
          child: Card(
              elevation: 15,
              child: Container(
                padding: const EdgeInsets.only(
                    top: 15.0, left: 50.0, right: 50.0),
                child:  ListView(
                    children: <Widget>[
                      Container(
                        width: objfun.SizeConfig.safeBlockHorizontal * 99,
                        height: objfun.SizeConfig.safeBlockVertical * 7,
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.only(bottom: 5),
                        child: TextField(
                          cursorColor: colour.commonColor,
                          controller: state.txtSmk3,
                          autofocus: false,
                          showCursor: true,
                          decoration: InputDecoration(
                            hintText: ('SMK No 3'),
                            hintStyle: GoogleFonts.lato(
                                textStyle:TextStyle(
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
                              state.autoCompleteSearch(value, false,3);
                            });
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 7,
                      ),
                    /*  Row(
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
                                  ('EN.Ref 3'),
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
                      SizedBox(
                        height: 7,
                      ),*/
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
                            suffixIcon: InkWell(
                                child: Icon(
                                    (state.txtSealByEmp3.text
                                        .isNotEmpty)
                                        ? Icons.close
                                        : Icons
                                        .search_rounded,
                                    color: colour
                                        .commonColorred,
                                    size: 30.0),
                                onTap: () async {
                                  if (state.txtSealByEmp3
                                      .text ==
                                      "") {
                                    await OnlineApi
                                        .SelectEmployee(
                                        context,
                                        '',
                                        'Operation');
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                          const Employee(
                                              Searchby:
                                              1,
                                              SearchId:
                                              0)),
                                    ).then((dynamic
                                    value) async {
                                      state.setState(() {
                                        state.txtSealByEmp3
                                            .text =
                                            objfun
                                                .SelectEmployeeList
                                                .AccountName;
                                        state.SealEmpId3 = objfun
                                            .SelectEmployeeList
                                            .Id;
                                        objfun.SelectEmployeeList =
                                            EmployeeModel
                                                .Empty();
                                      });
                                    });
                                  } else {
                                    state.setState(() {
                                      state.txtSealByEmp3.text =
                                      "";
                                      state.SealEmpId3 = 0;
                                      objfun.SelectEmployeeList =
                                          EmployeeModel
                                              .Empty();
                                    });
                                  }
                                }),
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
                                controller: state.txtExRef3,
                                autofocus: false,
                                showCursor: true,
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
                      const SizedBox(
                        height: 7,
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
                            suffixIcon: InkWell(
                                child: Icon(
                                    (state.txtBreakByEmp3.text
                                        .isNotEmpty)
                                        ? Icons.close
                                        : Icons
                                        .search_rounded,
                                    color: colour
                                        .commonColorred,
                                    size: 30.0),
                                onTap: () async {
                                  await OnlineApi
                                      .SelectEmployee(
                                      context,
                                      '',
                                      'Operation');
                                  if (state.txtBreakByEmp3
                                      .text ==
                                      "") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                          const Employee(
                                              Searchby:
                                              1,
                                              SearchId:
                                              0)),
                                    ).then((dynamic
                                    value) async {
                                      state.setState(() {
                                        state.txtBreakByEmp3
                                            .text =
                                            objfun
                                                .SelectEmployeeList
                                                .AccountName;
                                        state.BreakEmpId3 = objfun
                                            .SelectEmployeeList
                                            .Id;
                                        objfun.SelectEmployeeList =
                                            EmployeeModel
                                                .Empty();
                                      });
                                    });
                                  } else {
                                    state.setState(() {
                                      state.txtBreakByEmp3
                                          .text = "";
                                      state.BreakEmpId3 = 0;
                                      objfun.SelectEmployeeList =
                                          EmployeeModel
                                              .Empty();
                                    });
                                  }
                                }),
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

                    ],
                  ),
              )) ),
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