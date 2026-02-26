part of 'package:maleva/Transaction/EnquiryTR/AddEnquiryTR.dart';


mobiledesign(AddEnquiryTRState state, BuildContext context) {
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
                    child: Text('Enquiry TR Add',
                        style: GoogleFonts.lato(
                            textStyle:TextStyle(
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
                    state.SaveEnquiry();
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
            :
                Padding(
                  padding: const EdgeInsets.only(
                      top: 15.0, left: 15.0, right: 15.0),
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
                                    hintStyle:GoogleFonts.lato(
                                        textStyle: TextStyle(
                                            fontSize: objfun.FontMedium,
                                            fontWeight: FontWeight.bold,
                                            color: colour.commonColorLight)),
                                    suffixIcon: InkWell(
                                        child: Icon(
                                            (state.txtCustomer
                                                .text.isNotEmpty)
                                                ? Icons.close
                                                : Icons.search_rounded,
                                            color:
                                            colour.commonColorred,
                                            size: 30.0),
                                        onTap: () {
                                          if (state.txtCustomer.text == "") {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                  const Customer(
                                                      Searchby: 1,
                                                      SearchId: 0)),
                                            ).then(
                                                    (dynamic value) async {
                                                  state.setState(()   {
                                                    state.txtCustomer.text = objfun
                                                        .SelectCustomerList
                                                        .AccountName;
                                                    state.CustId = objfun
                                                        .SelectCustomerList
                                                        .Id;
                                                    objfun.SelectCustomerList =
                                                        CustomerModel
                                                            .Empty();
                                                  });
                                                  await OnlineApi.loadCustomerCurrency(
                                                      context, state.CustId);
                                                  state.setState(()   {
                                                    //state.CurrencyValue = objfun.CustomerCurrencyValue;
                                                  });
                                                });
                                          } else {
                                            state.setState(() {
                                              state.txtCustomer.text = "";
                                              state.CustId = 0;
                                              objfun.SelectCustomerList =
                                                  CustomerModel.Empty();
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
                                    suffixIcon: InkWell(
                                        child: Icon(
                                            (state.txtJobType.text.isNotEmpty)
                                                ? Icons.close
                                                : Icons.search_rounded,
                                            color:
                                            colour.commonColorred,
                                            size: 30.0),
                                        onTap: () {
                                          if (state.txtJobType.text == "") {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                  const JobType(
                                                      Searchby: 1,
                                                      SearchId: 0)),
                                            ).then(
                                                    (dynamic value) async {
                                                  await OnlineApi
                                                      .SelectAllJobStatus(
                                                      context,
                                                      objfun
                                                          .SelectJobTypeList
                                                          .Id);
                                                  state.setState(() {

                                                    state.txtJobType.text = objfun
                                                        .SelectJobTypeList
                                                        .Name;
                                                    state.JobTypeId = objfun
                                                        .SelectJobTypeList
                                                        .Id;
                                                    objfun.SelectJobTypeList =
                                                        JobTypeModel
                                                            .Empty();

                                                  });
                                                });
                                          }
                                          else {
                                            state.setState(() {

                                              state.txtJobType.text = "";

                                              state.JobTypeId = 0;
                                              objfun.SelectJobTypeList =
                                                  JobTypeModel.Empty();
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
                      ),
                      Row(
  mainAxisAlignment:
  MainAxisAlignment.start,
  children: [
    Expanded(
        flex: 2,
        child:  Text("Notify Date",
          style: GoogleFonts.lato(
              textStyle:TextStyle(
                  fontSize: objfun.FontMedium,
                  fontWeight: FontWeight.bold,
                  color: colour.commonColor)),
          textAlign: TextAlign.center,)),
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
  child:
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Text(
                              width <= 370
                                  ? DateFormat("dd-MM-yy")
                                  .format(DateTime.parse(
                                  state.dtpNotfiydate
                                      .toString()))
                                  : DateFormat("dd-MM-yyyy")
                                  .format(DateTime.parse(
                                  state.dtpNotfiydate
                                      .toString())),
                              style: GoogleFonts.lato(
                                  textStyle:TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: objfun.FontLow,
                                    color:  colour.commonColor
                                        )),
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
                                      state.dtpNotfiydate =
                                          DateFormat("yyyy-MM-dd")
                                              .format(datenew);
                                    });
                                  });

                              },
                            ),
                          ),
                        ],
                      ),))

  ]),
                      const SizedBox(height: 5,),
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
                                  controller: state.txtOrigin,
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
                                    hintText: "Origin",
                                    hintStyle:GoogleFonts.lato(
                                        textStyle: TextStyle(
                                            fontSize: objfun.FontMedium,
                                            fontWeight: FontWeight.bold,
                                            color: colour.commonColorLight)),
                                    suffixIcon: InkWell(
                                        child: Icon(
                                            (state.txtOrigin
                                                .text.isNotEmpty)
                                                ? Icons.close
                                                : Icons.search_rounded,
                                            color:
                                            colour.commonColorred,
                                            size: 30.0),
                                        onTap: () {
                                          if (state.txtOrigin.text == "") {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                  const Location(
                                                      Searchby: 1,
                                                      SearchId: 0)),
                                            ).then(
                                                    (dynamic value) async {
                                                  state.setState(()   {
                                                    state.txtOrigin.text = objfun
                                                        .SelectLocationList
                                                        .Location;
                                                    state.OriginId = objfun
                                                        .SelectLocationList
                                                        .Id;
                                                    objfun.SelectLocationList =
                                                        LocationModel
                                                            .Empty();
                                                  });

                                                  state.setState(()   {
                                                    //state.CurrencyValue = objfun.CustomerCurrencyValue;
                                                  });
                                                });
                                          } else {
                                            state.setState(() {
                                              state.txtOrigin.text = "";
                                              state.OriginId = 0;
                                              objfun.SelectLocationList =
                                                  LocationModel
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
                                  controller: state.txtDestination,
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
                                    hintText: "Destination",
                                    hintStyle:GoogleFonts.lato(
                                        textStyle: TextStyle(
                                            fontSize: objfun.FontMedium,
                                            fontWeight: FontWeight.bold,
                                            color: colour.commonColorLight)),
                                    suffixIcon: InkWell(
                                        child: Icon(
                                            (state.txtDestination
                                                .text.isNotEmpty)
                                                ? Icons.close
                                                : Icons.search_rounded,
                                            color:
                                            colour.commonColorred,
                                            size: 30.0),
                                        onTap: () {
                                          if (state.txtDestination.text == "") {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                  const Location(
                                                      Searchby: 1,
                                                      SearchId: 0)),
                                            ).then(
                                                    (dynamic value) async {
                                                  state.setState(()   {
                                                    state.txtDestination.text = objfun
                                                        .SelectLocationList
                                                        .Location;
                                                    state.DestinationId = objfun
                                                        .SelectLocationList
                                                        .Id;
                                                    objfun.SelectLocationList =
                                                        LocationModel
                                                            .Empty();
                                                  });

                                                  state.setState(()   {
                                                    //state.CurrencyValue = objfun.CustomerCurrencyValue;
                                                  });
                                                });
                                          } else {
                                            state.setState(() {
                                              state.txtDestination.text = "";
                                              state.DestinationId = 0;
                                              objfun.SelectLocationList =
                                                  LocationModel
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
                      ),


                      Row(
                          mainAxisAlignment:
                          MainAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 2,
                                child:  Text("Collection Date",
                                  style: GoogleFonts.lato(
                                      textStyle:TextStyle(
                                          fontSize: objfun.FontMedium,
                                          fontWeight: FontWeight.bold,
                                          color: colour.commonColor)),
                                  textAlign: TextAlign.center,)),
                            Expanded(
                                flex: 4,
                                child:  Container(
                                  height: 50,
                                  padding: const EdgeInsets.only(
                                      left: 10.0, right: 5.0),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: colour.commonColorLight,
                                      border: Border.all()),
                                  child:Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          DateFormat("dd-MM-yyyy HH:mm:ss")
                                              .format(DateTime.parse(
                                              state.dtpCollectiondate
                                                  .toString())),
                                          style:GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: objfun.FontLow,
                                                color: state.checkBoxValueCollection ==
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
                                              if (state.checkBoxValueCollection) {
                                                final date =
                                                await showDatePicker(
                                                  context: context,
                                                  firstDate: DateTime(2020),
                                                  initialDate: DateTime.now(),
                                                  lastDate: DateTime(2100),
                                                );
                                                if (date != null) {
                                                  var time =
                                                  await showTimePicker(
                                                      context: context,
                                                      builder: (
                                                          BuildContext context,
                                                          Widget? child) {
                                                        return MediaQuery(
                                                          data: MediaQuery.of(
                                                              context).copyWith(
                                                              alwaysUse24HourFormat: true),
                                                          child: child!,
                                                        );
                                                      },
                                                      initialTime:
                                                      TimeOfDay
                                                          .now());
                                                  state.setState(() {
                                                    time ??= TimeOfDay.now();
                                                    state.dtpCollectiondate =
                                                    '${state.combineDateAndTime(
                                                        date, time!)}';
                                                  });
                                                } else {
                                                  state.dtpCollectiondate =
                                                      DateTime.now()
                                                          .toString();
                                                }
                                              }
                                            }
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                            Expanded(
                                flex: 1,
                                child: Transform.scale(
                                  scale: 1.3,
                                  child: Checkbox(
                                    value: state.checkBoxValueCollection,
                                    side: const BorderSide(
                                        color: colour.commonColor),
                                    activeColor: colour.commonColorred,
                                    onChanged: (bool? value) {
                                      state.setState(() {
                                        state.checkBoxValueCollection = value!;
                                        if (state.checkBoxValueCollection ==
                                            false) {
                                          state.dtpCollectiondate = DateFormat(
                                              "yyyy-MM-dd HH:mm:ss")
                                              .format(DateTime.now());
                                        }
                                      });

                                      // else{
                                      //   buildDropDownMenuItemsCash();
                                      // }
                                    },
                                  ),
                                )),

                          ]),
                      const SizedBox(height: 5,),
                      Row(
                          mainAxisAlignment:
                          MainAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 2,
                                child:  Text("Delivery Date",
                                  style: GoogleFonts.lato(
                                      textStyle:TextStyle(
                                          fontSize: objfun.FontMedium,
                                          fontWeight: FontWeight.bold,
                                          color: colour.commonColor)),
                                  textAlign: TextAlign.center,)),
                            Expanded(
                                flex: 4,
                                child:  Container(
                                  height: 50,
                                  padding: const EdgeInsets.only(
                                      left: 10.0, right: 5.0),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: colour.commonColorLight,
                                      border: Border.all()),
                                  child:Row(
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
                                          style:GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: objfun.FontLow,
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
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: objfun.calendar,
                                                  //fit: BoxFit.fill,
                                                ),
                                              ),
                                            ),
                                            onTap: () async {
                                              if (state.checkBoxValueLETA) {
                                                final date =
                                                await showDatePicker(
                                                  context: context,
                                                  firstDate: DateTime(2020),
                                                  initialDate: DateTime.now(),
                                                  lastDate: DateTime(2100),
                                                );
                                                if (date != null) {
                                                  var time =
                                                  await showTimePicker(
                                                      context: context,
                                                      builder: (
                                                          BuildContext context,
                                                          Widget? child) {
                                                        return MediaQuery(
                                                          data: MediaQuery.of(
                                                              context).copyWith(
                                                              alwaysUse24HourFormat: true),
                                                          child: child!,
                                                        );
                                                      },
                                                      initialTime:
                                                      TimeOfDay
                                                          .now());
                                                  state.setState(() {
                                                    time ??= TimeOfDay.now();
                                                    state.dtpDeliverydate =
                                                    '${state.combineDateAndTime(
                                                        date, time!)}';
                                                  });
                                                } else {
                                                  state.dtpDeliverydate =
                                                      DateTime.now()
                                                          .toString();
                                                }
                                              }
                                            }
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                            Expanded(
                                flex: 1,
                                child: Transform.scale(
                                  scale: 1.3,
                                  child: Checkbox(
                                    value: state.checkBoxValueLETA,
                                    side: const BorderSide(
                                        color: colour.commonColor),
                                    activeColor: colour.commonColorred,
                                    onChanged: (bool? value) {
                                      state.setState(() {
                                        state.checkBoxValueLETA = value!;
                                        if (state.checkBoxValueLETA ==
                                            false) {
                                          state.dtpDeliverydate = DateFormat(
                                              "yyyy-MM-dd HH:mm:ss")
                                              .format(DateTime.now());
                                        }
                                      });

                                      // else{
                                      //   buildDropDownMenuItemsCash();
                                      // }
                                    },
                                  ),
                                )),

                          ]),
                      const SizedBox(height: 5,),

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
                                controller: state.txtQuantity,
                                autofocus: false,
                                showCursor: true,
                                decoration:
                                InputDecoration(
                                  hintText:
                                  ('Quantity'),
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
                                controller: state.txtWeight,
                                autofocus: false,
                                showCursor: true,
                                decoration:
                                InputDecoration(
                                  hintText:
                                  ('Weight'),
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


                      const SizedBox(height: 7,),


                    ],
                  ),
                ),




      ));
}