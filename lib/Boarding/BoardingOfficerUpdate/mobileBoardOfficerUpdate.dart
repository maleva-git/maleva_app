
 part of 'package:maleva/Boarding/BoardingOfficerUpdate/BoardOfficerUpdate.dart';

mobiledesign(BoardofficerupdateState state, BuildContext context) {
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
            icon: const Icon(Icons.arrow_back),
            onPressed: () {

              Navigator.pop(context);
            },
          ),
          key: state.appBarKey,
          title:  SizedBox(
            height: height * 0.05,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    flex: 1,
                    child: Text('Boarding Officer Update',
                        style:GoogleFonts.lato(textStyle: TextStyle(
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
                          style: GoogleFonts.lato(textStyle:TextStyle(
                            color: colour.commonColorLight,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Alatsi',
                            fontSize: objfun.FontLow - 2,
                          )),)
                      ]),
                ),
              ],
            ),
          ),

          iconTheme: const IconThemeData(color: colour.topAppBarColor),
          actions: [
            Padding(
              padding: const EdgeInsets.all(7.0),
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
                   state.SaveSalesOrder();
                  },
                  child: Text(
                    'UPDATE',
                    style: GoogleFonts.lato(
                        fontSize: objfun.FontMedium,
                        // height: 1.45,
                        fontWeight: FontWeight.bold,
                        color: colour.commonColor),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15,),
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
            :   Padding(
          padding: const EdgeInsets.only(
              top: 15.0, left: 15.0, right: 15.0),child: ListView(
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
                    style:GoogleFonts.lato(
                        textStyle: TextStyle(
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

              ],
            ),
            const SizedBox(
              height: 3,
            ),
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
                  hintText: "L Boarding Officer 1",
                  hintStyle: GoogleFonts.lato(
                      textStyle:TextStyle(
                          fontSize: objfun.FontMedium,
                          fontWeight: FontWeight.bold,
                          color: colour.commonColorLight)),
                  suffixIcon: InkWell(
                      child: Icon(
                          (state.txtBoardingOfficer1
                              .text.isNotEmpty)
                              ? Icons.close
                              : Icons.search_rounded,
                          color: colour.commonColorred,
                          size: 30.0),
                      onTap: () async {
                        await OnlineApi.SelectEmployee(
                            context, '', 'Operation');
                        if (state.txtBoardingOfficer1.text == "") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                const Employee(
                                    Searchby: 1,
                                    SearchId: 0)),
                          ).then((dynamic value) async {
                            state.setState(() {
                              state.txtBoardingOfficer1.text =
                                  objfun.SelectEmployeeList
                                      .AccountName;
                              state.BoardOfficerId1 = objfun
                                  .SelectEmployeeList.Id;
                              objfun.SelectEmployeeList =
                                  EmployeeModel.Empty();
                              state.Calc();
                            });
                          });
                        } else {
                          state.setState(() {
                            state.txtBoardingOfficer1.text = "";
                            state.BoardOfficerId1 = 0;
                            objfun.SelectEmployeeList =
                                EmployeeModel.Empty();
                            state.Calc();
                          });
                        }
                      }),
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
                        showCursor: false ,
                        readOnly:true ,
                        decoration: InputDecoration(
                          hintText: ('L Amount 1'),
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
            const SizedBox(
              height: 3,
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
                  hintText: "L Boarding Officer 2",
                  hintStyle: GoogleFonts.lato(
                      textStyle:TextStyle(
                          fontSize: objfun.FontMedium,
                          fontWeight: FontWeight.bold,
                          color: colour.commonColorLight)),
                  suffixIcon: InkWell(
                      child: Icon(
                          (state.txtBoardingOfficer2
                              .text.isNotEmpty)
                              ? Icons.close
                              : Icons.search_rounded,
                          color: colour.commonColorred,
                          size: 30.0),
                      onTap: () async {
                        await OnlineApi.SelectEmployee(
                            context, '', 'Operation');
                        if (state.txtBoardingOfficer2.text == "") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                const Employee(
                                    Searchby: 1,
                                    SearchId: 0)),
                          ).then((dynamic value) async {
                            state.setState(() {
                              state.txtBoardingOfficer2.text =
                                  objfun.SelectEmployeeList
                                      .AccountName;
                              state.BoardOfficerId2 = objfun
                                  .SelectEmployeeList.Id;
                              objfun.SelectEmployeeList =
                                  EmployeeModel.Empty();
                              state.Calc();
                            });
                          });
                        } else {
                          state.setState(() {
                            state.txtBoardingOfficer2.text = "";
                            state.BoardOfficerId2 = 0;
                            objfun.SelectEmployeeList =
                                EmployeeModel.Empty();
                            state.Calc();
                          });
                        }
                      }),
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
                        showCursor:false ,
                        readOnly: true ,
                        decoration: InputDecoration(
                          hintText: ('L Amount 2'),
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
            const SizedBox(
              height: 3,
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
              //padding: const EdgeInsets.only(bottom: 5),
              child: TextField(
                textCapitalization:
                TextCapitalization.characters,
                controller: state.txtOBoardingOfficer1,
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
                  hintText: "O Boarding Officer 1",
                  hintStyle: GoogleFonts.lato(
                      textStyle:TextStyle(
                          fontSize: objfun.FontMedium,
                          fontWeight: FontWeight.bold,
                          color: colour.commonColorLight)),
                  suffixIcon: InkWell(
                      child: Icon(
                          (state.txtOBoardingOfficer1
                              .text.isNotEmpty)
                              ? Icons.close
                              : Icons.search_rounded,
                          color: colour.commonColorred,
                          size: 30.0),
                      onTap: () async {
                        await OnlineApi.SelectEmployee(
                            context, '', 'Operation');
                        if (state.txtOBoardingOfficer1.text == "") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                const Employee(
                                    Searchby: 1,
                                    SearchId: 0)),
                          ).then((dynamic value) async {
                            state.setState(() {
                              state.txtOBoardingOfficer1.text =
                                  objfun.SelectEmployeeList
                                      .AccountName;
                              state.OBoardOfficerId1 = objfun
                                  .SelectEmployeeList.Id;
                              objfun.SelectEmployeeList =
                                  EmployeeModel.Empty();
                              state.Calc();
                            });
                          });
                        } else {
                          state.setState(() {
                            state.txtOBoardingOfficer1.text = "";
                            state.OBoardOfficerId1 = 0;
                            objfun.SelectEmployeeList =
                                EmployeeModel.Empty();
                            state.Calc();
                          });
                        }
                      }),
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
                        controller: state.txtOAmount1,
                        autofocus: false,
                        showCursor: false ,
                        readOnly:true ,
                        decoration: InputDecoration(
                          hintText: ('O Amount 1'),
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
            const SizedBox(
              height: 3,
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
                controller: state.txtOBoardingOfficer2,
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
                  hintText: "O Boarding Officer 2",
                  hintStyle: GoogleFonts.lato(
                      textStyle:TextStyle(
                          fontSize: objfun.FontMedium,
                          fontWeight: FontWeight.bold,
                          color: colour.commonColorLight)),
                  suffixIcon: InkWell(
                      child: Icon(
                          (state.txtOBoardingOfficer2
                              .text.isNotEmpty)
                              ? Icons.close
                              : Icons.search_rounded,
                          color: colour.commonColorred,
                          size: 30.0),
                      onTap: () async {
                        await OnlineApi.SelectEmployee(
                            context, '', 'Operation');
                        if (state.txtOBoardingOfficer2.text == "") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                const Employee(
                                    Searchby: 1,
                                    SearchId: 0)),
                          ).then((dynamic value) async {
                            state.setState(() {
                              state.txtOBoardingOfficer2.text =
                                  objfun.SelectEmployeeList
                                      .AccountName;
                              state.OBoardOfficerId2 = objfun
                                  .SelectEmployeeList.Id;
                              objfun.SelectEmployeeList =
                                  EmployeeModel.Empty();
                              state.Calc();
                            });
                          });
                        } else {
                          state.setState(() {
                            state.txtOBoardingOfficer2.text = "";
                            state.OBoardOfficerId2 = 0;
                            objfun.SelectEmployeeList =
                                EmployeeModel.Empty();
                            state.Calc();
                          });
                        }
                      }),
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
                        controller: state.txtOAmount2,
                        autofocus: false,
                        showCursor:false ,
                        readOnly: true ,
                        decoration: InputDecoration(
                          hintText: ('O Amount 2'),
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
            const SizedBox(
              height: 3,
            ),
            Row(children: [
              Expanded(

                child:Container(
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
                      value:  state.dropdownValue,
                      onChanged: (String? value) {
                        state.setState(() {
                          state.dropdownValue = value!;
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
                      items: BoardofficerupdateState.StatusUpdate.map<
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

            ],),

          ],
        ),
        ), ));
}