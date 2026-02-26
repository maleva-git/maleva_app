part of 'package:maleva/PreAlertReport/PreAlertReport.dart';


mobiledesign(PreAlertreportState state, BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;
  Future<bool> onBackPressed() async {
    if(objfun.storagenew.getString('RulesType') == "ADMIN")
    {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
    }
    else if(objfun.storagenew.getString('RulesType') == "SALES")
    {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const CustDashboard()));
    }
    else if(objfun.storagenew.getString('RulesType') == "TRANSPORTATION")
    {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const TransportDashboard()));
    }
    else if(objfun.storagenew.getString('RulesType') == "OPERATIONADMIN")
    {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const OperationAdminDashboard()));
    }
    else if(objfun.storagenew.getString('RulesType') == "AIR FRIEGHT")
    {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const AirFrieghtDashboard()));
    }
    else if(objfun.storagenew.getString('RulesType') == "BOARDING"  || objfun.storagenew.getString('RulesType') == "OPERATION")
    {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const BoardingDashboard()));
    }
    else if( objfun.storagenew.getString('RulesType') == "FORWARDING" )
    {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ForwardingDashboard()));
    }
    else
    {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const Homemobile()));
    }
    return true;
  }



  return WillPopScope(
      onWillPop: onBackPressed,
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
                  Text('PreAlert Report',
                      style: GoogleFonts.lato(
                          textStyle:TextStyle(
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



            ]),
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
          Container(
              height: 700,
              /*padding:
              EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 10),*/
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
                      ],
                    ),
                    Container(
                      width: objfun.SizeConfig.safeBlockHorizontal * 99,
                      height: objfun.SizeConfig.safeBlockVertical * 5,
                      alignment: Alignment.topCenter,
                      margin: const EdgeInsets.only(right: 5.0, left: 5.0),
                      padding: const EdgeInsets.only(bottom: 5),
                      child: TextField(
                        textCapitalization: TextCapitalization.characters,
                        controller: state.txtCustomer,
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
                          hintText: "Customer Name",
                          hintStyle:GoogleFonts.lato(
                              textStyle: TextStyle(
                                  fontSize: objfun.FontLow,
                                  fontWeight: FontWeight.bold,
                                  color: colour.commonColorLight)),
                          suffixIcon: InkWell(
                              child: Icon(
                                  (state.txtCustomer.text.isNotEmpty)
                                      ? Icons.close
                                      : Icons.search_rounded,
                                  color: colour.commonColorred,
                                  size: 30.0),
                              onTap: () {
                                if (state.txtCustomer.text == "") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Customer(
                                            Searchby: 1, SearchId: 0)),
                                  ).then((dynamic value) async {
                                    state.setState(() {
                                      state.txtCustomer.text =
                                          objfun.SelectCustomerList.AccountName;
                                      state.CustId = objfun.SelectCustomerList.Id;
                                      objfun.SelectCustomerList =
                                          CustomerModel.Empty();
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
                      width: objfun.SizeConfig.safeBlockHorizontal * 99,
                      height: objfun.SizeConfig.safeBlockVertical * 5,
                      alignment: Alignment.topCenter,
                      margin: const EdgeInsets.only(right: 5.0, left: 5.0),
                      padding: const EdgeInsets.only(bottom: 5),
                      child: TextField(
                        textCapitalization: TextCapitalization.characters,
                        controller: state.txtVessel,
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
                          hintText: "Select JobType",
                          hintStyle:GoogleFonts.lato(
                              textStyle: TextStyle(
                                  fontSize: objfun.FontLow,
                                  fontWeight: FontWeight.bold,
                                  color: colour.commonColorLight)),
                          suffixIcon: InkWell(
                              child: Icon(
                                  (state.txtVessel.text.isNotEmpty)
                                      ? Icons.close
                                      : Icons.search_rounded,
                                  color: state.checkBoxValueLEmp
                                      ? colour.commonColorDisabled
                                      : colour.commonColorred,
                                  size: 30.0),
                              onTap: () async {
                                await OnlineApi.SelectJobType(context);
                                if (state.txtVessel.text == "" &&
                                    state.checkBoxValueLEmp != true) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const JobType(
                                            Searchby: 1, SearchId: 0)),
                                  ).then((dynamic value) async {
                                    state.setState(() {
                                      state.txtVessel.text =
                                          objfun.SelectJobTypeList.Name;
                                      state.Jobid = objfun.SelectEmployeeList.Id;
                                      objfun.SelectJobTypeList =
                                          JobTypeModel.Empty();
                                    });
                                  });
                                } else {
                                  state.setState(() {
                                    state.txtVessel.text = "";
                                    state.Jobid = 0;
                                    objfun.SelectEmployeeList =
                                        EmployeeModel.Empty();
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
                      width: objfun.SizeConfig.safeBlockHorizontal * 99,
                      height: objfun.SizeConfig.safeBlockVertical * 5,
                      alignment: Alignment.topCenter,
                      margin: const EdgeInsets.only(right: 5.0, left: 5.0),
                      padding: const EdgeInsets.only(bottom: 5),
                      child: TextField(
                        textCapitalization: TextCapitalization.characters,
                        controller: state.txtPort,
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
                          hintText: "Select Port",
                          hintStyle:GoogleFonts.lato(
                              textStyle: TextStyle(
                                  fontSize: objfun.FontLow,
                                  fontWeight: FontWeight.bold,
                                  color: colour.commonColorLight)),
                          suffixIcon: InkWell(
                              child: Icon(
                                  (state.txtPort.text.isNotEmpty)
                                      ? Icons.close
                                      : Icons.search_rounded,
                                  color: colour.commonColorred,
                                  size: 30.0),
                              onTap: () {
                                if (state.txtPort.text == "") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Port(
                                            Searchby: 1, SearchId: 0)),
                                  ).then((dynamic value) async {
                                    state.setState(() {
                                      state.txtPort.text =
                                          objfun.SelectedPortName;
                                      state.PortId = objfun.SelectJobStatusList.Id;
                                      objfun.SelectJobStatusList =
                                          JobStatusModel.Empty();
                                    });
                                  });
                                } else {
                                  state.setState(() {
                                    state.txtPort.text = "";
                                    state.PortId = 0;
                                    objfun.SelectJobStatusList =
                                        JobStatusModel.Empty();
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
                      width: objfun.SizeConfig.safeBlockHorizontal * 99,
                      height: objfun.SizeConfig.safeBlockVertical * 5,
                      alignment: Alignment.topCenter,
                      margin: const EdgeInsets.only(right: 5.0, left: 5.0),
                      padding: const EdgeInsets.only(bottom: 5),
                      child: TextField(
                        cursorColor: colour.commonColor,
                        controller: state.txtVessel,
                        autofocus: false,
                        showCursor: true,
                        decoration: InputDecoration(
                          hintText: ('Vessel'),
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
                    /*       Container(
                      width: objfun.SizeConfig.safeBlockHorizontal * 99,
                      height: objfun.SizeConfig.safeBlockVertical * 5,
                      alignment: Alignment.topCenter,
                      margin: const EdgeInsets.only(right: 5.0, left: 5.0),
                      padding: const EdgeInsets.only(bottom: 5),
                      child: TextField(
                        cursorColor: colour.commonColor,
                        controller: state.txtLoadingVessel,
                        autofocus: false,
                        showCursor: true,
                        decoration: InputDecoration(
                          hintText: ('Loading Vessel'),
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
                    Container(
                      width: objfun.SizeConfig.safeBlockHorizontal * 99,
                      height: objfun.SizeConfig.safeBlockVertical * 5,
                      alignment: Alignment.topCenter,
                      margin: const EdgeInsets.only(right: 5.0, left: 5.0),
                      padding: const EdgeInsets.only(bottom: 5),
                      child: TextField(
                        cursorColor: colour.commonColor,
                        controller: state.txtOffVessal,
                        autofocus: false,
                        showCursor: true,
                        decoration: InputDecoration(
                          hintText: ('Off Vessel'),
                          hintStyle: GoogleFonts.lato(
                              textStyle:TextStyle(
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
                    ),*/
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Checkbox(
                            value: state.checkBoxValuePickUp,
                            activeColor: colour.commonColorred,
                            onChanged: (bool? value) {
                              state.setState(() {
                                state.checkBoxValuePickUp = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                              width: 120,
                              // flex: 1,
                              child: Text(
                                'PickUp',
                                style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                      color: colour.commonColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: objfun.FontMedium,
                                      letterSpacing: 0.3),
                                ),
                              )),
                        ),
                        Expanded(
                          flex: 1,
                          child: Checkbox(
                            value: state.checkBoxValuePort,
                            activeColor: colour.commonColorred,
                            onChanged: (bool? value) {
                              state.setState(() {
                                state.checkBoxValuePort = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                              width: 120,
                              // flex: 1,
                              child: Text(
                                'Port',
                                style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                      color: colour.commonColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: objfun.FontMedium,
                                      letterSpacing: 0.3),
                                ),
                              )),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Checkbox(
                            value: state.checkBoxValueVesselName,
                            activeColor: colour.commonColorred,
                            onChanged: (bool? value) {
                              state.setState(() {
                                state.checkBoxValueVesselName = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                              width: 120,
                              // flex: 1,
                              child: Text(
                                'Vessel Name',
                                style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                      color: colour.commonColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: objfun.FontMedium,
                                      letterSpacing: 0.3),
                                ),
                              )),
                        ),
                        Expanded(
                          flex: 1,
                          child: Checkbox(
                            value: state.checkBoxValueConsolidated,
                            activeColor: colour.commonColorred,
                            onChanged: (bool? value) {
                              state.setState(() {
                                state.checkBoxValueConsolidated = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                              width: 120,
                              // flex: 1,
                              child: Text(
                                'Consolidated',
                                style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                      color: colour.commonColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: objfun.FontMedium,
                                      letterSpacing: 0.3),
                                ),
                              )),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Checkbox(
                            value: state.checkBoxValueDelivery,
                            activeColor: colour.commonColorred,
                            onChanged: (bool? value) {
                              state.setState(() {
                                state.checkBoxValueDelivery = value!;
                              });
                            },
                          ),
                        ),
                        Expanded  (
                          flex: 2,
                          child: SizedBox(
                              width: 120,
                              // flex: 1,
                              child: Text(
                                'Delivery Done',
                                style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                      color: colour.commonColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: objfun.FontMedium,
                                      letterSpacing: 0.3),
                                ),
                              )),
                        ),
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                              width: 120,
                              // flex: 1,
                              child: Text(
                                '',
                                style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                      color: colour.commonColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: objfun.FontMedium,
                                      letterSpacing: 0.3),
                                ),
                              )),
                        ),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                              width: 120,
                              // flex: 1,
                              child: Text(
                                '',
                                style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                      color: colour.commonColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: objfun.FontMedium,
                                      letterSpacing: 0.3),
                                ),
                              )),
                        ),
                      ],
                    ),
                    Row(children: [
                      Expanded(
                        // width: 250,
                        flex: 1,
                        child: Radio(
                          value: "1",
                          groupValue: state.ETAVal,
                          onChanged: (value) {
                            state.setState(() {
                              state.checkBoxValueETA = true;
                              state.ETARadioVal = "1";
                              state.ETAVal = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        // width: 250,
                        flex: 1,
                        child: Text(
                          "OETA",
                          style:GoogleFonts.lato(
                              textStyle: TextStyle(
                                  color: colour.commonColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: objfun.FontLow,
                                  letterSpacing: 0.3)),
                        ),
                      ),
                      Expanded(
                        // width: 250,
                        flex: 1,
                        child: Radio(
                          value: "2",
                          groupValue: state.ETAVal,
                          onChanged: (value) {
                            state.setState(() {
                              state.checkBoxValueETA = true;
                              state.ETARadioVal = "1";
                              state.ETAVal = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        // width: 250,
                        flex: 1,
                        child: Text(
                          "LETA",
                          style: GoogleFonts.lato(
                              textStyle:TextStyle(
                                  color: colour.commonColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: objfun.FontLow,
                                  letterSpacing: 0.3)),
                        ),
                      ),
                      Expanded(
                        // width: 250,
                        flex: 1,
                        child: Radio(
                          value: "3",
                          groupValue: state.ETAVal,
                          onChanged: (value) {
                            state.setState(() {
                              state.checkBoxValueETA = true;
                              state.ETARadioVal = "2";
                              state.ETAVal = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        // width: 250,
                        flex: 1,
                        child: Text(
                          "All",
                          style:GoogleFonts.lato(
                              textStyle: TextStyle(
                                  color: colour.commonColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: objfun.FontLow,
                                  letterSpacing: 0.3)),
                        ),
                      ),
                      Expanded(
                        // width: 250,
                        flex: 1,
                        child: Radio(
                          value: "0",
                          groupValue: state.ETAVal,
                          onChanged: (value) {
                            state.setState(() {
                              state.checkBoxValueETA = false;
                              state.ETARadioVal = "O";
                              state.ETAVal = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        // width: 250,
                        flex: 1,
                        child: Text(
                          "None",
                          style: GoogleFonts.lato(
                              textStyle:TextStyle(
                                  color: colour.commonColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: objfun.FontMedium,
                                  letterSpacing: 0.3)),
                        ),
                      ),
                    ]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            state._sharePreAlertReport(
                            );
                          },
                          child: Text(
                            'View',
                            style:GoogleFonts.lato(
                                textStyle: TextStyle(fontSize: objfun.FontMedium)),
                          ),
                        ),
                        const SizedBox(width: 7),

                      ],
                    ),
                  ],
                ),
              )),
            ],
          ),
        )),

      ));
}