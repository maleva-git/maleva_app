part of 'package:maleva/Transaction/SaleOrder/SalesOrderView.dart';


mobiledesign(SaleOrderViewState state, BuildContext context) {
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
                                        setState(() {
                                          state.txtCustomer.text =
                                              objfun.SelectCustomerList.AccountName;
                                          state.CustId = objfun.SelectCustomerList.Id;
                                          objfun.SelectCustomerList =
                                              CustomerModel.Empty();
                                        });
                                      });
                                    } else {
                                      setState(() {
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
                            controller: state.txtEmployee,
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
                              hintText: "Select Employee",
                              hintStyle:GoogleFonts.lato(
                                  textStyle: TextStyle(
                                      fontSize: objfun.FontLow,
                                      fontWeight: FontWeight.bold,
                                      color: colour.commonColorLight)),
                              suffixIcon: InkWell(
                                  child: Icon(
                                      (state.txtEmployee.text.isNotEmpty)
                                          ? Icons.close
                                          : Icons.search_rounded,
                                      color: state.checkBoxValueLEmp
                                          ? colour.commonColorDisabled
                                          : colour.commonColorred,
                                      size: 30.0),
                                  onTap: () async {
                                    await OnlineApi.SelectEmployee(
                                        context, 'sales', 'admin');
                                    if (state.txtEmployee.text == "" &&
                                        state.checkBoxValueLEmp != true) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const Employee(
                                                Searchby: 1, SearchId: 0)),
                                      ).then((dynamic value) async {
                                        setState(() {
                                          state.txtEmployee.text =
                                              objfun.SelectEmployeeList.AccountName;
                                          state.EmpId = objfun.SelectEmployeeList.Id;
                                          objfun.SelectEmployeeList =
                                              EmployeeModel.Empty();
                                        });
                                      });
                                    } else {
                                      setState(() {
                                        state.txtEmployee.text = "";
                                        state.EmpId = 0;
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
                            controller: state.txtStatus,
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
                              hintText: "Select Status",
                              hintStyle:GoogleFonts.lato(
                                  textStyle: TextStyle(
                                      fontSize: objfun.FontLow,
                                      fontWeight: FontWeight.bold,
                                      color: colour.commonColorLight)),
                              suffixIcon: InkWell(
                                  child: Icon(
                                      (state.txtStatus.text.isNotEmpty)
                                          ? Icons.close
                                          : Icons.search_rounded,
                                      color: colour.commonColorred,
                                      size: 30.0),
                                  onTap: () {
                                    if (state.txtStatus.text == "") {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const JobStatus(
                                                Searchby: 1, SearchId: 0)),
                                      ).then((dynamic value) async {
                                        setState(() {
                                          state.txtStatus.text =
                                              objfun.SelectJobStatusList.Name;
                                          state.StatusId = objfun.SelectJobStatusList.Id;
                                          objfun.SelectJobStatusList =
                                              JobStatusModel.Empty();
                                        });
                                      });
                                    } else {
                                      setState(() {
                                        state.txtStatus.text = "";
                                        state.StatusId = 0;
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
                            controller: state.txtJobNo,
                            autofocus: false,
                            showCursor: true,
                            decoration: InputDecoration(
                              hintText: ('Job No'),
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
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Checkbox(
                                value: state.checkBoxValuePickUp,
                                activeColor: colour.commonColorred,
                                onChanged: (bool? value) {
                                  setState(() {
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
                                value: state.checkBoxValueLEmp,
                                activeColor: colour.commonColorred,
                                onChanged: (bool? value) {
                                  setState(() {
                                    state.checkBoxValueLEmp = value!;
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
                                    'L.Emp',
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
                              value: "3",
                              groupValue: state.cls,
                              onChanged: (value) {
                                setState(() {
                                  state.cls = value.toString();
                                });
                              },
                            ),
                          ),
                          Expanded(
                            // width: 250,
                            flex: 1,
                            child: Text(
                              "All",
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
                              value: "2",
                              groupValue: state.cls,
                              onChanged: (value) {
                                setState(() {
                                  state.cls = value.toString();
                                });
                              },
                            ),
                          ),
                          Expanded(
                            // width: 250,
                            flex: 2,
                            child: Text(
                              "WithOut",
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
                              groupValue: state.cls,
                              onChanged: (value) {
                                setState(() {
                                  state.cls = value.toString();
                                });
                              },
                            ),
                          ),
                          Expanded(
                            // width: 250,
                            flex: 1,
                            child: Text(
                              "With",
                              style: GoogleFonts.lato(
                                  textStyle:TextStyle(
                                      color: colour.commonColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: objfun.FontMedium,
                                      letterSpacing: 0.3)),
                            ),
                          ),
                        ]),
                        Row(children: [
                          Expanded(
                            // width: 250,
                            flex: 1,
                            child: Radio(
                              value: "1",
                              groupValue: state.ETAVal,
                              onChanged: (value) {
                                setState(() {
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
                                setState(() {
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
                                setState(() {
                                  state.checkBoxValueETA = true;
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
                                setState(() {
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
                      ],
                    ),
                  ));
            });
      },
    );
  }

  Column loadgridheader() {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Text(
                  "SNo",
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
                  "Status",
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
                  "Employee Name",
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
                flex: 2,
                child: Text(
                  "L.V.Name",
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
                  "ETA",
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
                  "ETB",
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
                flex: 2,
                child: Text(
                  "O.V.Name",
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
                  "OETA",
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
                  "OETB",
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
                flex: 5,
                child: Text(
                  "Port",
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
                  "Order No",
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
                flex: 5,
                child: Text(
                  "Customer Name",
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
                  flex: 4,
                  child: Text(
                    "Flight Time",
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
            )),
        Expanded(
            flex: 1,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: Text(
                    "",
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
                    "DO",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(
                          color: colour.ButtonForeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: objfun.FontLow,
                          letterSpacing: 0.3),
                    ),
                  ),
                ),
                // Expanded(
                //   flex: 2,
                //   child: Text(
                //     "INVOICE",
                //     textAlign: TextAlign.center,
                //     style: GoogleFonts.lato(
                //       textStyle: TextStyle(
                //           color: colour.ButtonForeColor,
                //           fontWeight: FontWeight.bold,
                //           fontSize: objfun.FontLow,
                //           letterSpacing: 0.3),
                //     ),
                //   ),
                // ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "",
                    textAlign: TextAlign.center,
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
            )),
      ],
    );
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
                  Text('Sales Order',
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

              IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  size: 30.0,
                  color: colour.topAppBarColor,
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SalesOrderAdd()));
                },
              ),
              /* IconButton(
                  icon: const Icon(
                    Icons.exit_to_app_sharp,
                    size: 30.0,
                    color: colour.topAppBarColor,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),*/
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
              SizedBox(
                height: height * 0.21,
                child: Container(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  // margin: const EdgeInsets.only(left: 10.0, right: 30),

                  color: colour.commonColor,
                  child: loadgridheader(),
                ),
              ),
              SizedBox(
                height: height * 0.66,
                child: (objfun.SaleOrderMasterList.isNotEmpty
                    ? Container(
                    height: height / 1.4,
                    margin: const EdgeInsets.all(0),
                    padding:
                    const EdgeInsets.only(left: 1, right: 1),
                    child: ListView.builder(
                        itemCount:
                        objfun.SaleOrderMasterList.length,
                        itemBuilder:
                            (BuildContext context, int index) {
                          return SizedBox(
                              height:
                              state._currentlyVisibleIndex == index
                                  ? height * 0.55
                                  : height * 0.25,
                              child: InkWell(
                                onLongPress: () {
                                  state.setState(() {
                                    state.EditId = objfun
                                        .SaleOrderMasterList[index]
                                        .Id;
                                    state._showDialogPassword(
                                        1,
                                        objfun
                                            .SaleOrderMasterList[
                                        index]
                                            .Id,
                                        0);
                                  });
                                },
                                child: Card(
                                  // margin: EdgeInsets.all(10.0),

                                    color: state._CardColor(index),
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
                                                      objfun
                                                          .SaleOrderMasterList[
                                                      index]
                                                          .JobStatus
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
                                                          .SaleOrderMasterList[
                                                      index]
                                                          .EmployeeName
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
                                                    padding:
                                                    const EdgeInsets
                                                        .all(5),
                                                    child: Text(
                                                      objfun
                                                          .SaleOrderMasterList[
                                                      index]
                                                          .Loadingvesselname
                                                          .toString(),
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
                                                  flex: 4,
                                                  child: Container(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(1),
                                                    child: Text(
                                                      objfun
                                                          .SaleOrderMasterList[
                                                      index]
                                                          .SETA
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
                                                  flex: 4,
                                                  child: Container(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(5),
                                                    child: Text(
                                                      objfun
                                                          .SaleOrderMasterList[
                                                      index]
                                                          .SETB
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
                                                    padding:
                                                    const EdgeInsets
                                                        .all(5),
                                                    child: Text(
                                                      objfun
                                                          .SaleOrderMasterList[
                                                      index]
                                                          .Offvesselname
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
                                                  flex: 4,
                                                  child: Container(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(1),
                                                    child: Text(
                                                      objfun
                                                          .SaleOrderMasterList[
                                                      index]
                                                          .SOETA
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
                                                  flex: 4,
                                                  child: Container(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(5),
                                                    child: Text(
                                                      objfun
                                                          .SaleOrderMasterList[
                                                      index]
                                                          .SOETB
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
                                                  flex: 5,
                                                  child: Container(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(5),
                                                    child: Text(
                                                      objfun
                                                          .SaleOrderMasterList[
                                                      index]
                                                          .SPort
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
                                                          .SaleOrderMasterList[
                                                      index]
                                                          .BillNoDisplay
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
                                                  flex: 5,
                                                  child: Container(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(1),
                                                    child: Text(
                                                      objfun
                                                          .SaleOrderMasterList[
                                                      index]
                                                          .CustomerName
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
                                                  flex: 5,
                                                  child: Container(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(1),
                                                    child: Text(
                                                      objfun
                                                          .SaleOrderMasterList[
                                                      index]
                                                          .FlighTime
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
                                                                  state.SaleDetailsList = objfun.SaleOrderDetailList.where((item) => item.SaleRefId == objfun.SaleOrderMasterList[index].Id).toList();

                                                                  state.VisibleSaleDetails[index] = !state.VisibleSaleDetails[index];
                                                              if (state._currentlyVisibleIndex == index) {
                                                                state._currentlyVisibleIndex = -1;
                                                              } else {
                                                                state._currentlyVisibleIndex = index;
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
                                                      child: IconButton(
                                                          onPressed: () {
                                                            state._shareDOConvert(objfun
                                                                .SaleOrderMasterList[
                                                            index]
                                                                .Id,objfun
                                                                .SaleOrderMasterList[
                                                            index]
                                                                .BillNo);
                                                          },
                                                          icon: const Icon(
                                                            Icons
                                                                .picture_as_pdf_sharp,
                                                            color: colour
                                                                .commonColor,
                                                          ))),
                                                ),
                                             /*   Expanded(
                                                  flex: 2,
                                                  child: Container(
                                                    child:
                                                    IconButton(
                                                        onPressed:
                                                            () {
                                                              state._shareInvoice(objfun
                                                              .SaleOrderMasterList[
                                                          index]
                                                              .Id,objfun
                                                              .SaleOrderMasterList[
                                                          index]
                                                              .BillNo);
                                                        },
                                                        icon:
                                                        Icon(
                                                          Icons
                                                              .picture_as_pdf_sharp,
                                                          color:
                                                          colour.commonColor,
                                                        )),
                                                  ),
                                                ),*/
                                                /* Expanded(
                                                              flex: 2,
                                                              child: Container(
                                                                  child: IconButton(
                                                                      onPressed: () async {
                                                                        bool result = await objfun.ConfirmationMsgYesNo(
                                                                            context,
                                                                            "Are you sure to delete ?");
                                                                        if (result ==
                                                                            true) {
                                                                          await OnlineApi.DeleteSalesOrder(
                                                                              context,
                                                                              objfun.SaleOrderMasterList[index].Id);
                                                                          loaddata();
                                                                        }
                                                                      },
                                                                      icon: Icon(
                                                                        Icons
                                                                            .delete_forever,
                                                                        color: colour
                                                                            .commonColor,
                                                                      ))),
                                                            ),*/
                                              ],
                                            )),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Visibility(
                                            visible:
                                            state._currentlyVisibleIndex ==
                                                index,
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
                                                                  flex: 1,
                                                                  child: Text(
                                                                    "SNo",
                                                                    textAlign: TextAlign.left,
                                                                    style: GoogleFonts.lato(
                                                                      textStyle: TextStyle(color: colour.ButtonForeColor, fontWeight: FontWeight.bold, fontSize: objfun.FontCardText, letterSpacing: 0.3),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 2,
                                                                  child: Text(
                                                                    "Code",
                                                                    textAlign: TextAlign.left,
                                                                    style: GoogleFonts.lato(
                                                                      textStyle: TextStyle(color: colour.ButtonForeColor, fontWeight: FontWeight.bold, fontSize: objfun.FontCardText, letterSpacing: 0.3),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 4,
                                                                  child: Text(
                                                                    "Description",
                                                                    textAlign: TextAlign.left,
                                                                    style: GoogleFonts.lato(
                                                                      textStyle: TextStyle(color: colour.ButtonForeColor, fontWeight: FontWeight.bold, fontSize: objfun.FontCardText, letterSpacing: 0.3),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 1,
                                                                  child: Text(
                                                                    "Qty",
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
                                                                  flex: 3,
                                                                  child: Text(
                                                                    "SaleRate",
                                                                    textAlign: TextAlign.left,
                                                                    style: GoogleFonts.lato(
                                                                      textStyle: TextStyle(color: colour.ButtonForeColor, fontWeight: FontWeight.bold, fontSize: objfun.FontCardText, letterSpacing: 0.3),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 2,
                                                                  child: Text(
                                                                    "GST",
                                                                    textAlign: TextAlign.left,
                                                                    style: GoogleFonts.lato(
                                                                      textStyle: TextStyle(color: colour.ButtonForeColor, fontWeight: FontWeight.bold, fontSize: objfun.FontCardText, letterSpacing: 0.3),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 5,
                                                                  child: Text(
                                                                    "Amount",
                                                                    textAlign: TextAlign.right,
                                                                    style: GoogleFonts.lato(
                                                                      textStyle: TextStyle(color: colour.ButtonForeColor, fontWeight: FontWeight.bold, fontSize: objfun.FontCardText, letterSpacing: 0.3),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: height *
                                                        0.55,
                                                    child: (objfun
                                                        .SaleOrderDetailList
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
                                                            itemCount: state.SaleDetailsList.length,
                                                            itemBuilder: (BuildContext context, int index) {
                                                              return SizedBox(
                                                                height: 75,
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
                                                                                flex: 1,
                                                                                child: Text(
                                                                                  "   ${index + 1}",
                                                                                  textAlign: TextAlign.left,
                                                                                  style: GoogleFonts.lato(
                                                                                    textStyle: TextStyle(color: colour.commonColor, fontWeight: FontWeight.bold, fontSize: objfun.FontCardText, letterSpacing: 0.3),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                flex: 2,
                                                                                child: Text(
                                                                                  state.SaleDetailsList[index].ProductCode.toString(),
                                                                                  textAlign: TextAlign.left,
                                                                                  style: GoogleFonts.lato(
                                                                                    textStyle: TextStyle(color: colour.commonColor, fontWeight: FontWeight.bold, fontSize: objfun.FontCardText, letterSpacing: 0.3),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                flex: 4,
                                                                                child: Text(
                                                                                  state.SaleDetailsList[index].ProductName.toString(),
                                                                                  textAlign: TextAlign.left,
                                                                                  style: GoogleFonts.lato(
                                                                                    textStyle: TextStyle(color: colour.commonColor, fontWeight: FontWeight.bold, fontSize: objfun.FontCardText, letterSpacing: 0.3),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                flex: 1,
                                                                                child: Text(
                                                                                  "   ${state.SaleDetailsList[index].ItemQty}",
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
                                                                                flex: 3,
                                                                                child: Text(
                                                                                  "  ${state.SaleDetailsList[index].SaleRate}",
                                                                                  textAlign: TextAlign.left,
                                                                                  style: GoogleFonts.lato(
                                                                                    textStyle: TextStyle(color: colour.commonColor, fontWeight: FontWeight.bold, fontSize: objfun.FontCardText, letterSpacing: 0.3),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                flex: 2,
                                                                                child: Text(
                                                                                  state.SaleDetailsList[index].TaxPercent.toString(),
                                                                                  textAlign: TextAlign.left,
                                                                                  style: GoogleFonts.lato(
                                                                                    textStyle: TextStyle(color: colour.commonColor, fontWeight: FontWeight.bold, fontSize: objfun.FontCardText, letterSpacing: 0.3),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                flex: 5,
                                                                                child: Text(
                                                                                  "${state.SaleDetailsList[index].SAmount}   ",
                                                                                  textAlign: TextAlign.right,
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
                        style:
                        GoogleFonts.lato(
                            textStyle: TextStyle(
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