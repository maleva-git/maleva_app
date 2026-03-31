part of 'package:maleva/Transaction/EnquiryTR/EnquiryTRView.dart';


mobiledesign(OldEnquiryTRViewState state, BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;
  Column loadgridheader() {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 2,
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
              Expanded(
                flex: 2,
                child: Text(
                  "Notify Date",
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

      ],
    );
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
                // height: 700,
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
                            controller: state.txtJobType,
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
                              hintText: "Job Type",
                              hintStyle:GoogleFonts.lato(
                                  textStyle: TextStyle(
                                      fontSize: objfun.FontLow,
                                      fontWeight: FontWeight.bold,
                                      color: colour.commonColorLight)),
                              suffixIcon: InkWell(
                                  child: Icon(
                                      (state.txtJobType.text.isNotEmpty)
                                          ? Icons.close
                                          : Icons.search_rounded,
                                      color: colour.commonColorred,
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
                                              state.JobId = objfun
                                                  .SelectJobTypeList
                                                  .Id;
                                              objfun.SelectJobTypeList =
                                                  JobTypeModel
                                                      .Empty();

                                            });
                                          });
                                    } else {
                                      state.setState(() {

                                        state.txtJobType.text = "";
                                        state.JobId = 0;
                                        objfun.SelectJobTypeList =
                                            JobTypeModel.Empty();
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
                              hintStyle:GoogleFonts
                                  .lato(
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

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            const Expanded(
                              flex: 2,
                              child: Text(""),
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
                                    textAlign: TextAlign.left,
                                  )),
                            ),
                            Expanded(
                              flex: 1,
                              child: Checkbox(
                                value: state.checkBoxValueEnq,
                                activeColor: colour.commonColorred,
                                onChanged: (bool? value) {
                                  setState(() {
                                    state.checkBoxValueEnq = value!;
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
                                    'ENQ',
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                          color: colour.commonColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: objfun.FontMedium,
                                          letterSpacing: 0.3),
                                    ),
                                    textAlign: TextAlign.left,
                                  )),
                            ),
                            const Expanded(
                              flex: 2,
                              child: Text(""),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  state.loaddata(true);
                                });
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'View',
                                style:GoogleFonts
                                    .lato(
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
                                style: GoogleFonts
                                    .lato(
                                    textStyle:TextStyle(fontSize: objfun.FontMedium)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        )
                      ],
                    ),
                  ));
            });
      },
    );
  }
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
                  Text('Enquiry TR View',
                      style: GoogleFonts
                          .lato(
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
                              style: GoogleFonts
                                  .lato(
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AddEnquiryTR()));

                    },
                    child: Text(
                      'Add',
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
                height: height * 0.05,
                child: Container(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  // margin: const EdgeInsets.only(left: 10.0, right: 30),

                  color: colour.commonColor,
                  child: loadgridheader(),
                ),
              ),
              SizedBox(
                height: height * 0.80,
                child: (objfun.EnquiryMasterList.isNotEmpty
                    ? Container(
                    height: height / 1.4,
                    margin: const EdgeInsets.all(0),
                    padding:
                    const EdgeInsets.only(left: 1, right: 1),
                    child: ListView.builder(
                        itemCount:
                        objfun.EnquiryMasterList.length,
                        itemBuilder:
                            (BuildContext context, int index) {
                          return SizedBox(
                              height:  height * 0.08,
                              child: InkWell(
                                onDoubleTap: () {
                                  state._showDialogEnqDetails(objfun
                                      .EnquiryMasterList[index]);
                                },
                                onLongPress: () {
                                  state.setState(() {

                                    Navigator.push(
                                            context, MaterialPageRoute(builder: (context) => AddEnquiryTR(SaleMaster:objfun.EnquiryMasterList[index])));
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
                                                  flex: 2,
                                                  child: Container(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(1),
                                                    child: Text("   ${objfun.EnquiryMasterList[index]["CustomerName"]}",
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
                                                        .all(1),
                                                    child: Text("   ${objfun.EnquiryMasterList[index]["SForwardingDate"]}",
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
                                              children: [
                                                Expanded(
                                                  flex: 2,
                                                  child: InkWell(
                                                    onTap: () async {
                                                      bool result = await objfun
                                                          .ConfirmationMsgYesNo(
                                                          context,
                                                          "Do You Want to Push to SalesOrder ?");
                                                      if (result ==
                                                          true) {
                                                        objfun.storagenew.setString('EnquiryOpen', "true");
                                                        List<dynamic> Enquirylist = [];
                                                        Enquirylist.add(objfun.EnquiryMasterList[index]);
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    SalesOrderAdd(
                                                                        SaleDetails: null,
                                                                        SaleMaster: Enquirylist
                                                                    )));
                                                      }

                                                    },
                                                    child: const Icon(
                                                      Icons
                                                          .fast_forward_sharp,
                                                      color: colour
                                                          .commonColor,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: InkWell(
                                                    onTap: () async {
                                                      bool result = await objfun
                                                          .ConfirmationMsgYesNo(
                                                          context,
                                                          "Do You Want to Cancel the Enquiry ?");
                                                      if (result ==
                                                          true) {
                                                        state.CancelEnquiry(objfun.EnquiryMasterList[index]["Id"]);
                                                      }
                                                    },
                                                    child: const Icon(
                                                      Icons.cancel,
                                                      color: colour
                                                          .commonColor,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                              ],
                                            ),),

                                        const SizedBox(
                                          height: 10,
                                        ),

                                      ],
                                    )),
                              ));
                        }))
                    : Container(
                    width: width - 40.0,
                    height: height / 1.4,
                    padding: const EdgeInsets.all(20),
                    child: const Center(
                      child: Text('No Record'),
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