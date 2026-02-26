part of 'package:maleva/Transport/LicenseUpdate.dart';


mobiledesign(LicenseUpdateState state, BuildContext context) {
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
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title:  SizedBox(
            height: height * 0.05,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    flex: 1,
                    child: Text('License Update',
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
          actions: [
            ( state.admin? Padding(
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
                    state.UpdateLicenseDate();
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
            ):Container()),

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
            const SizedBox(height: 7,),
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
                          hintStyle:GoogleFonts.lato(
                              textStyle: TextStyle(
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
                                        state.loaddata();
                                      });
                                } else {

                                  state.Clear();

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
            ),
            const SizedBox(height: 5,),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                    flex: 3,
                    child: Text(
                      "RotexMyExp",
                      style:GoogleFonts.lato(
                          textStyle: TextStyle(
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
                        color: state.checkBoxValueRotexMyExp == true
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
                            DateFormat("dd-MM-yyyy")
                                .format(DateTime.parse(
                                state.dtpRotexMyExp
                                    .toString())),
                            style: GoogleFonts.lato(
                                textStyle:TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: objfun.FontLow,
                                  color: state.checkBoxValueRotexMyExp ==
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
                              if(! state.admin){
                                return;
                              }
                                  if (state.checkBoxValueRotexMyExp) {
                                final date =
                                await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(2020),
                                  initialDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  state.setState(() {
                                    var datenew =
                                    DateTime.parse(
                                        date.toString());
                                    state.dtpRotexMyExp =
                                        DateFormat("yyyy-MM-dd")
                                            .format(datenew);
                                  });
                                } else {
                                  state.dtpRotexMyExp =
                                      DateTime.now()
                                          .toString();
                                }
                              }
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
                        value: state.checkBoxValueRotexMyExp,
                        side: const BorderSide(
                            color: colour.commonColor),
                        activeColor: colour.commonColorred,
                        onChanged: (bool? value) {
                          if(! state.admin){
                            return;
                          }
                          state.setState(() {
                            state.checkBoxValueRotexMyExp = value!;
                            if (state.checkBoxValueRotexMyExp ==
                                false) {
                              state.dtpRotexMyExp = DateFormat(
                                  "yyyy-MM-dd")
                                  .format(DateTime.now());
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
            const SizedBox(height: 7),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                    flex: 3,
                    child: Text(
                      "RotexSGExp",
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
                        color: state.checkBoxValueRotexSGExp == true
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
                            DateFormat("dd-MM-yyyy")
                                .format(DateTime.parse(
                                state.dtpRotexSGExp
                                    .toString())),
                            style:GoogleFonts.lato(
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: objfun.FontLow,
                                  color: state.checkBoxValueRotexSGExp ==
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
                              if(! state.admin){
                                return;
                              }
                              if (state.checkBoxValueRotexSGExp) {
                                final date =
                                await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(2020),
                                  initialDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  state.setState(() {
                                    var datenew =
                                    DateTime.parse(
                                        date.toString());
                                    state.dtpRotexSGExp =
                                        DateFormat("yyyy-MM-dd")
                                            .format(datenew);
                                  });
                                } else {
                                  state.dtpRotexSGExp =
                                      DateTime.now()
                                          .toString();
                                }
                              }
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
                        value: state.checkBoxValueRotexSGExp,
                        side: const BorderSide(
                            color: colour.commonColor),
                        activeColor: colour.commonColorred,
                        onChanged: (bool? value) {
                          if(! state.admin){
                            return;
                          }
                          state.setState(() {
                            state.checkBoxValueRotexSGExp = value!;
                            if (state.checkBoxValueRotexSGExp ==
                                false) {
                              state.dtpRotexSGExp = DateFormat(
                                  "yyyy-MM-dd")
                                  .format(DateTime.now());
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
            const SizedBox(height: 7),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                    flex: 3,
                    child: Text(
                      "PuspacomExp",
                      style:GoogleFonts.lato(
                          textStyle: TextStyle(
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
                        color: state.checkBoxValuePuspacomExp == true
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
                            DateFormat("dd-MM-yyyy")
                                .format(DateTime.parse(
                                state.dtpPuspacomExp
                                    .toString())),
                            style: GoogleFonts.lato(
                                textStyle:TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: objfun.FontLow,
                                  color: state.checkBoxValuePuspacomExp ==
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
                              if(! state.admin){
                                return;
                              }
                              if (state.checkBoxValuePuspacomExp) {
                                final date =
                                await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(2020),
                                  initialDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  state.setState(() {
                                    var datenew =
                                    DateTime.parse(
                                        date.toString());
                                    state.dtpPuspacomExp =
                                        DateFormat("yyyy-MM-dd")
                                            .format(datenew);
                                  });
                                } else {
                                  state.dtpPuspacomExp =
                                      DateTime.now()
                                          .toString();
                                }
                              }
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
                        value: state.checkBoxValuePuspacomExp,
                        side: const BorderSide(
                            color: colour.commonColor),
                        activeColor: colour.commonColorred,
                        onChanged: (bool? value) {
                          if(! state.admin){
                            return;
                          }
                          state.setState(() {
                            state.checkBoxValuePuspacomExp = value!;
                            if (state.checkBoxValuePuspacomExp ==
                                false) {
                              state.dtpPuspacomExp = DateFormat(
                                  "yyyy-MM-dd")
                                  .format(DateTime.now());
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
            const SizedBox(height: 7),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                    flex: 3,
                    child: Text(
                      "RotexMyExp1",
                      style:GoogleFonts.lato(
                          textStyle: TextStyle(
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
                        color: state.checkBoxValueRotexMyExp1 == true
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
                            DateFormat("dd-MM-yyyy")
                                .format(DateTime.parse(
                                state.dtpRotexMyExp1
                                    .toString())),
                            style:GoogleFonts.lato(
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: objfun.FontLow,
                                  color: state.checkBoxValueRotexMyExp1 ==
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
                              if(! state.admin){
                                return;
                              }
                              if (state.checkBoxValueRotexMyExp1) {
                                final date =
                                await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(2020),
                                  initialDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  state.setState(() {
                                    var datenew =
                                    DateTime.parse(
                                        date.toString());
                                    state.dtpRotexMyExp1 =
                                        DateFormat("yyyy-MM-dd")
                                            .format(datenew);
                                  });
                                } else {
                                  state.dtpRotexMyExp1 =
                                      DateTime.now()
                                          .toString();
                                }
                              }
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
                        value: state.checkBoxValueRotexMyExp1,
                        side: const BorderSide(
                            color: colour.commonColor),
                        activeColor: colour.commonColorred,
                        onChanged: (bool? value) {
                          if(! state.admin){
                            return;
                          }
                          state.setState(() {
                            state.checkBoxValueRotexMyExp1 = value!;
                            if (state.checkBoxValueRotexMyExp1 ==
                                false) {
                              state.dtpRotexMyExp1 = DateFormat(
                                  "yyyy-MM-dd")
                                  .format(DateTime.now());
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
            const SizedBox(height: 7),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                    flex: 3,
                    child: Text(
                      "RotexSGExp1",
                      style:GoogleFonts.lato(
                          textStyle: TextStyle(
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
                        color: state.checkBoxValueRotexSGExp1 == true
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
                              DateFormat("dd-MM-yyyy")
                                  .format(DateTime.parse(
                                  state.dtpRotexSGExp1
                                      .toString())),
                              style:GoogleFonts.lato(
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: objfun.FontLow,
                                  color: state.checkBoxValueRotexSGExp1 ==
                                      true
                                      ? colour.commonColor
                                      : colour
                                      .commonColorDisabled,
                                ),
                              )),
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
                              if(! state.admin){
                                return;
                              }
                              if (state.checkBoxValueRotexSGExp1) {
                                final date =
                                await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(2020),
                                  initialDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  state.setState(() {
                                    var datenew =
                                    DateTime.parse(
                                        date.toString());
                                    state.dtpRotexSGExp1 =
                                        DateFormat("yyyy-MM-dd")
                                            .format(datenew);
                                  });
                                } else {
                                  state.dtpRotexSGExp1 =
                                      DateTime.now()
                                          .toString();
                                }
                              }
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
                        value: state.checkBoxValueRotexSGExp1,
                        side: const BorderSide(
                            color: colour.commonColor),
                        activeColor: colour.commonColorred,
                        onChanged: (bool? value) {
                          if(! state.admin){
                            return;
                          }
                          state.setState(() {
                            state.checkBoxValueRotexSGExp1 = value!;
                            if (state.checkBoxValueRotexSGExp1 ==
                                false) {
                              state.dtpRotexSGExp1 = DateFormat(
                                  "yyyy-MM-dd")
                                  .format(DateTime.now());
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
            const SizedBox(height: 7),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                    flex: 3,
                    child: Text(
                      "PuspacomExp1",
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
                        color: state.checkBoxValuePuspacomExp1 == true
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
                            DateFormat("dd-MM-yyyy")
                                .format(DateTime.parse(
                                state.dtpPuspacomExp1
                                    .toString())),
                            style: GoogleFonts.lato(
                                textStyle:TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: objfun.FontLow,
                                  color: state.checkBoxValuePuspacomExp1 ==
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
                              if(! state.admin){
                                return;
                              }
                              if (state.checkBoxValuePuspacomExp1) {
                                final date =
                                await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(2020),
                                  initialDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  state.setState(() {
                                    var datenew =
                                    DateTime.parse(
                                        date.toString());
                                    state.dtpPuspacomExp1 =
                                        DateFormat("yyyy-MM-dd")
                                            .format(datenew);
                                  });
                                } else {
                                  state.dtpPuspacomExp1 =
                                      DateTime.now()
                                          .toString();
                                }
                              }
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
                        value: state.checkBoxValuePuspacomExp1,
                        side: const BorderSide(
                            color: colour.commonColor),
                        activeColor: colour.commonColorred,
                        onChanged: (bool? value) {
                          if(! state.admin){
                            return;
                          }
                          state.setState(() {
                            state.checkBoxValuePuspacomExp1 = value!;
                            if (state.checkBoxValuePuspacomExp1 ==
                                false) {
                              state.dtpPuspacomExp1 = DateFormat(
                                  "yyyy-MM-dd")
                                  .format(DateTime.now());
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
            const SizedBox(height: 7),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                    flex: 3,
                    child: Text(
                      "InsuratnceExp",
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
                        color: state.checkBoxValueInsuratnceExp == true
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
                            DateFormat("dd-MM-yyyy")
                                .format(DateTime.parse(
                                state.dtpInsuratnceExp
                                    .toString())),
                            style: GoogleFonts.lato(
                                textStyle:TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: objfun.FontLow,
                                  color: state.checkBoxValueInsuratnceExp ==
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
                              if(! state.admin){
                                return;
                              }
                              if (state.checkBoxValueInsuratnceExp) {
                                final date =
                                await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(2020),
                                  initialDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  state.setState(() {
                                    var datenew =
                                    DateTime.parse(
                                        date.toString());
                                    state.dtpInsuratnceExp =
                                        DateFormat("yyyy-MM-dd")
                                            .format(datenew);
                                  });
                                } else {
                                  state.dtpInsuratnceExp =
                                      DateTime.now()
                                          .toString();
                                }
                              }
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
                        value: state.checkBoxValueInsuratnceExp,
                        side: const BorderSide(
                            color: colour.commonColor),
                        activeColor: colour.commonColorred,
                        onChanged: (bool? value) {
                          if(! state.admin){
                            return;
                          }
                          state.setState(() {
                            state.checkBoxValueInsuratnceExp = value!;
                            if (state.checkBoxValueInsuratnceExp ==
                                false) {
                              state.dtpInsuratnceExp = DateFormat(
                                  "yyyy-MM-dd")
                                  .format(DateTime.now());
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
            const SizedBox(height: 7),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                    flex: 3,
                    child: Text(
                      "BonamExp",
                      style:GoogleFonts.lato(
                          textStyle: TextStyle(
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
                        color: state.checkBoxValueBonamExp == true
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
                            DateFormat("dd-MM-yyyy")
                                .format(DateTime.parse(
                                state.dtpBonamExp
                                    .toString())),
                            style: GoogleFonts.lato(
                                textStyle:TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: objfun.FontLow,
                                  color: state.checkBoxValueBonamExp ==
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
                              if(! state.admin){
                                return;
                              }
                              if (state.checkBoxValueBonamExp) {
                                final date =
                                await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(2020),
                                  initialDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  state.setState(() {
                                    var datenew =
                                    DateTime.parse(
                                        date.toString());
                                    state.dtpBonamExp =
                                        DateFormat("yyyy-MM-dd")
                                            .format(datenew);
                                  });
                                } else {
                                  state.dtpBonamExp =
                                      DateTime.now()
                                          .toString();
                                }
                              }
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
                        value: state.checkBoxValueBonamExp,
                        side: const BorderSide(
                            color: colour.commonColor),
                        activeColor: colour.commonColorred,
                        onChanged: (bool? value) {
                          if(! state.admin){
                            return;
                          }
                          state.setState(() {
                            state.checkBoxValueBonamExp = value!;
                            if (state.checkBoxValueBonamExp ==
                                false) {
                              state.dtpBonamExp = DateFormat(
                                  "yyyy-MM-dd")
                                  .format(DateTime.now());
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
            const SizedBox(height: 7),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                    flex: 3,
                    child: Text(
                      "ApadExp",
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
                        color: state.checkBoxValueApadExp == true
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
                            DateFormat("dd-MM-yyyy")
                                .format(DateTime.parse(
                                state.dtpApadExp
                                    .toString())),
                            style:GoogleFonts.lato(
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: objfun.FontLow,
                                  color: state.checkBoxValueApadExp ==
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
                              if(! state.admin){
                                return;
                              }
                              if (state.checkBoxValueApadExp) {
                                final date =
                                await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(2020),
                                  initialDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  state.setState(() {
                                    var datenew =
                                    DateTime.parse(
                                        date.toString());
                                    state.dtpApadExp =
                                        DateFormat("yyyy-MM-dd")
                                            .format(datenew);
                                  });
                                } else {
                                  state.dtpApadExp =
                                      DateTime.now()
                                          .toString();
                                }
                              }
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
                        value: state.checkBoxValueApadExp,
                        side: const BorderSide(
                            color: colour.commonColor),
                        activeColor: colour.commonColorred,
                        onChanged: (bool? value) {
                          if(! state.admin){
                            return;
                          }
                          state.setState(() {
                            state.checkBoxValueApadExp = value!;
                            if (state.checkBoxValueApadExp ==
                                false) {
                              state.dtpApadExp = DateFormat(
                                  "yyyy-MM-dd")
                                  .format(DateTime.now());
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
            const SizedBox(height: 7),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                    flex: 3,
                    child: Text(
                      "ServiceExp",
                      style:GoogleFonts.lato(
                          textStyle: TextStyle(
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
                        color: state.checkBoxValueServiceExp == true
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
                            DateFormat("dd-MM-yyyy")
                                .format(DateTime.parse(
                                state.dtpServiceExp
                                    .toString())),
                            style:GoogleFonts.lato(
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: objfun.FontLow,
                                  color: state.checkBoxValueServiceExp ==
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
                              if(! state.admin){
                                return;
                              }
                              if (state.checkBoxValueServiceExp) {
                                final date =
                                await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(2020),
                                  initialDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  state.setState(() {
                                    var datenew =
                                    DateTime.parse(
                                        date.toString());
                                    state.dtpServiceExp =
                                        DateFormat("yyyy-MM-dd")
                                            .format(datenew);
                                  });
                                } else {
                                  state.dtpServiceExp =
                                      DateTime.now()
                                          .toString();
                                }
                              }
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
                        value: state.checkBoxValueServiceExp,
                        side: const BorderSide(
                            color: colour.commonColor),
                        activeColor: colour.commonColorred,
                        onChanged: (bool? value) {
                          if(! state.admin){
                            return;
                          }
                          state.setState(() {
                            state.checkBoxValueServiceExp = value!;
                            if (state.checkBoxValueServiceExp ==
                                false) {
                              state.dtpServiceExp = DateFormat(
                                  "yyyy-MM-dd")
                                  .format(DateTime.now());
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
            const SizedBox(height: 7),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                    flex: 3,
                    child: Text(
                      "AlignmentExp",
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
                        color: state.checkBoxValueAlignmentExp == true
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
                            DateFormat("dd-MM-yyyy")
                                .format(DateTime.parse(
                                state.dtpAlignmentExp
                                    .toString())),
                            style: GoogleFonts.lato(
                                textStyle:TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: objfun.FontLow,
                                  color: state.checkBoxValueAlignmentExp ==
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
                              if(! state.admin){
                                return;
                              }
                              if (state.checkBoxValueAlignmentExp) {
                                final date =
                                await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(2020),
                                  initialDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  state.setState(() {
                                    var datenew =
                                    DateTime.parse(
                                        date.toString());
                                    state.dtpAlignmentExp =
                                        DateFormat("yyyy-MM-dd")
                                            .format(datenew);
                                  });
                                } else {
                                  state.dtpAlignmentExp =
                                      DateTime.now()
                                          .toString();
                                }
                              }
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
                        value: state.checkBoxValueAlignmentExp,
                        side: const BorderSide(
                            color: colour.commonColor),
                        activeColor: colour.commonColorred,
                        onChanged: (bool? value) {
                          if(! state.admin){
                            return;
                          }
                          state.setState(() {
                            state.checkBoxValueAlignmentExp = value!;
                            if (state.checkBoxValueAlignmentExp ==
                                false) {
                              state.dtpAlignmentExp = DateFormat(
                                  "yyyy-MM-dd")
                                  .format(DateTime.now());
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
            const SizedBox(height: 7),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                    flex: 3,
                    child: Text(
                      "GreeceExp",
                      style:GoogleFonts.lato(
                          textStyle: TextStyle(
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
                        color: state.checkBoxValueGreeceExp == true
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
                            DateFormat("dd-MM-yyyy")
                                .format(DateTime.parse(
                                state.dtpGreeceExp
                                    .toString())),
                            style:GoogleFonts.lato(
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: objfun.FontLow,
                                  color: state.checkBoxValueGreeceExp ==
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
                              if(! state.admin){
                                return;
                              }
                              if (state.checkBoxValueGreeceExp) {
                                final date =
                                await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(2020),
                                  initialDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  state.setState(() {
                                    var datenew =
                                    DateTime.parse(
                                        date.toString());
                                    state.dtpGreeceExp =
                                        DateFormat("yyyy-MM-dd")
                                            .format(datenew);
                                  });
                                } else {
                                  state.dtpGreeceExp =
                                      DateTime.now()
                                          .toString();
                                }
                              }
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
                        value: state.checkBoxValueGreeceExp,
                        side: const BorderSide(
                            color: colour.commonColor),
                        activeColor: colour.commonColorred,
                        onChanged: (bool? value) {
                          if(! state.admin){
                            return;
                          }
                          state.setState(() {
                            state.checkBoxValueGreeceExp = value!;
                            if (state.checkBoxValueGreeceExp ==
                                false) {
                              state.dtpGreeceExp = DateFormat(
                                  "yyyy-MM-dd")
                                  .format(DateTime.now());
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
            const SizedBox(height: 7),
          ],
        ),
        ), ));
}