part of 'package:maleva/Transaction/Stock/StockInEntry.dart';


tabletdesign(StockinentryState state, BuildContext context) {
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
              if(state.overlayEntry != null){
                state.clearOverlay();

              }
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
                    child: Text('Stock Entry',
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
                    if(objfun.storagenew.getString('RulesType') == "AIR FRIEGHT"){
                      Navigator.push(context, MaterialPageRoute(builder: (
                          context) => OldAirFrieghtUpdate(JobNo:state.widget.JobNo ,JobId: state.widget.JobId,)));
                    }
                    // else if(objfun.storagenew.getString('RulesType') == "BOARDING" || objfun.storagenew.getString('RulesType') == "FORWARDING" || objfun.storagenew.getString('RulesType') == "OPERATION")
                    // {
                    //   Navigator.push(context, MaterialPageRoute(builder: (
                    //       context) => BoardingStatusUpdate()));
                    // }
                  },
                  child: Text(
                    'UPLOAD',
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
                    state.UpdateStockData();
                  },
                  child: Text(
                    'SAVE',
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
                        style: GoogleFonts.lato(textStyle:TextStyle(
                            color: colour.commonColor,
                            fontWeight: FontWeight.bold,
                            fontSize: objfun.FontMedium,
                            letterSpacing: 0.3),)
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
                        style:GoogleFonts.lato(textStyle: TextStyle(
                            color: colour.commonColor,
                            fontWeight: FontWeight.bold,
                            fontSize: objfun.FontMedium,
                            letterSpacing: 0.3),)
                    ),
                  ),


                ]),
            Row(children: [
              Expanded(flex:3,child:Container(
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
                    hintStyle: GoogleFonts.lato(textStyle:TextStyle(
                        fontSize: objfun.FontMedium,
                        fontWeight: FontWeight.bold,
                        color: colour.commonColorLight),),
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
              ),
              const SizedBox(width: 7,),
              Expanded(flex:2,child:ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colour.commonColor,
                  side: const BorderSide(
                      color: colour.commonColor,
                      width: 1,
                      style: BorderStyle.solid),
                  textStyle: const TextStyle(color: Colors.black),
                  elevation: 20.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 9),
                ),
                onPressed: () async {
                  if(state.txtJobNo.text.isEmpty){
                    objfun.toastMsg('Enter Job No', '', context);
                    return;
                  }
                  await OnlineApi.EditSalesOrder(
                      context, state.SaleOrderId, int.parse(state.txtJobNo.text));
                  Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) =>
                              SaleOrderDetails(
                                SaleDetails: null,
                                SaleMaster: objfun
                                    .SaleEditMasterList,
                              )));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'VIEW',
                      style: GoogleFonts.lato(
                          fontSize: objfun.FontMedium,
                          // height: 1.45,
                          fontWeight: FontWeight.bold,
                          color: colour.commonColorLight),
                    ),
                    const SizedBox(width: 5,),
                    const Icon(Icons.arrow_circle_right,
                      color: colour.commonColorLight,
                    )],
                ),
              ), ),
            ],),
            const SizedBox(height: 7,),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: <Widget>[

                Expanded(
                  flex: 1,
                  child: Text(
                    "Stock No :",
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

                      decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(10.0),
                          color: colour.commonColorLight,
                          border: Border.all()),
                      child: TextField(
                        cursorColor: colour.commonColor,
                        controller: state.txtStockNo,
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
            const SizedBox(height: 7,),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: <Widget>[

                Expanded(
                  flex: 1,
                  child: Text(
                    "Stock Date :",
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
                                state.dtpStockdate
                                    .toString()))
                                : DateFormat("dd-MM-yyyy")
                                .format(DateTime.parse(
                                state.dtpStockdate
                                    .toString())),
                            style: GoogleFonts.lato(
                                textStyle:TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: objfun.FontLow,
                                    color: colour.commonColor)),
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
                                  state.dtpStockdate =
                                      DateFormat("yyyy-MM-dd")
                                          .format(datenew);
                                });
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              ],
            ),
            const SizedBox(height: 15,),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: <Widget>[

                Expanded(
                  flex: 1,
                  child: Text(
                    "Ship Name :",
                    style:GoogleFonts.lato(
                        textStyle: TextStyle(
                            fontSize: objfun.FontLow,
                            fontWeight: FontWeight.bold,
                            color: colour.commonColor)),
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: Text(
                    state.ShipName,
                    style:GoogleFonts.lato(
                        textStyle: TextStyle(
                            fontSize: objfun.FontMedium,
                            fontWeight: FontWeight.bold,
                            color: colour.commonColorhighlight)),
                  ),
                ),

              ],
            ),
            const SizedBox(height: 15,),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: <Widget>[

                Expanded(
                  flex: 1,
                  child: Text(
                    "Customer :",
                    style:GoogleFonts.lato(
                        textStyle: TextStyle(
                            fontSize: objfun.FontLow,
                            fontWeight: FontWeight.bold,
                            color: colour.commonColor)),
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: Text(
                    state.CustomerName,
                    style:GoogleFonts.lato(
                        textStyle: TextStyle(
                            fontSize: objfun.FontMedium,
                            fontWeight: FontWeight.bold,
                            color: colour.commonColorhighlight)),
                  ),
                ),

              ],
            ),
            const SizedBox(height: 15,),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: <Widget>[

                Expanded(
                  flex: 1,
                  child: Text(
                    "Job Date :",
                    style:GoogleFonts.lato(
                        textStyle: TextStyle(
                            fontSize: objfun.FontLow,
                            fontWeight: FontWeight.bold,
                            color: colour.commonColor)),
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: Text(
                    state.JobDate,
                    style:GoogleFonts.lato(
                        textStyle: TextStyle(
                            fontSize: objfun.FontMedium,
                            fontWeight: FontWeight.bold,
                            color: colour.commonColorhighlight)),
                  ),
                ),

              ],
            ),
            const SizedBox(height: 15,),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: TextField(
                    cursorColor: colour.commonColor,
                    controller: state.txtPackages,
                    autofocus: false,
                    showCursor: true,
                    decoration: InputDecoration(
                      hintText: ('Packages'),
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
                    keyboardType: TextInputType.number,
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
              ],
            ),
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
                        controller: state.txtJobStatus,
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
                          hintText: "Job Status",
                          hintStyle: GoogleFonts.lato(
                              textStyle:TextStyle(
                                  fontSize: objfun.FontMedium,
                                  fontWeight: FontWeight.bold,
                                  color: colour.commonColorLight)),
                          suffixIcon: InkWell(
                              child: Icon(
                                  (state.txtJobStatus
                                      .text.isNotEmpty)
                                      ? Icons.close
                                      : Icons.search_rounded,
                                  color:
                                  colour.commonColorred,
                                  size: 30.0),
                              onTap: () {
                                if (state.txtJobStatus.text == "" ) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            JobAllStatus(
                                                Searchby: 1,
                                                SearchId: 0,
                                                JobTypeId:
                                                state.JobId)),
                                  ).then(
                                          (dynamic value) async {
                                        state.setState(() {
                                          state.txtJobStatus.text = objfun
                                              .SelectAllStatusList
                                              .StatusName;
                                          state.StatusId = objfun
                                              .SelectAllStatusList
                                              .Status;
                                          objfun.SelectAllStatusList =
                                              JobAllStatusModel
                                                  .Empty();
                                        });
                                      });
                                } else {
                                  state.setState(() {
                                    state.txtJobStatus.text = "";
                                    state.StatusId = 0;
                                    objfun.SelectAllStatusList =
                                        JobAllStatusModel
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
            const SizedBox(height: 7,),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Transform.scale(
                  scale: 1.3,
                  child: Checkbox(
                    value: state.checkBoxImageUpload,
                    side: const BorderSide(
                        color:
                        colour.commonColor),
                    activeColor:
                    colour.commonColorred,
                    onChanged: (bool? value) {
                      state.setState(() {
                        state.checkBoxImageUpload =
                        value!;

                      });
                    },
                  ),
                ),
                Text(
                  "Upload Image",
                  style: GoogleFonts.lato(
                      textStyle:TextStyle(
                          fontSize: objfun.FontMedium,
                          color: colour.commonColor,
                          fontWeight:
                          FontWeight.bold)),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                IconButton(
                    onPressed: state.checkBoxImageUpload ?() {
                      if(state.txtJobStatus.text.isEmpty){
                        objfun.toastMsg("Select Status!!", "", context);
                        return;
                      }
                      state._pickImage(ImageSource.gallery);
                    } : null,
                    icon: Icon(
                      Icons.photo,
                      size: 35,
                      color: state.checkBoxImageUpload ? colour.commonColor : colour.commonColorDisabled,
                    )),
                IconButton(
                    onPressed: state.checkBoxImageUpload ? () {
                      if(state.txtJobStatus.text.isEmpty){
                        objfun.toastMsg("Select Status!!", "", context);
                        return;
                      }
                      /* captureImage(
                        ImageSource.gallery, 0);*/
                      state._pickImage(ImageSource.camera);
                    } : null,
                    icon: Icon(
                      Icons.camera_alt,
                      size: 35,
                      color:state.checkBoxImageUpload ? colour.commonColor : colour.commonColorDisabled,
                    )),
              ],
            ),

            const SizedBox(height: 7,),

            Container(
              height: height *0.50,
              width: width * 0.40,
              decoration: BoxDecoration(
                  border: Border.all(color: colour.commonColorLight)
              ),
              child:
              state.imagenetwork.isEmpty ? Center(
                  child: Text(
                    'No Image Selected.',
                    style:
                    GoogleFonts.lato(
                        textStyle:TextStyle(
                            color: colour.commonColorLight,
                            fontWeight: FontWeight.bold,
                            fontSize: objfun.FontLow,
                            letterSpacing: 0.3)),
                  )):
              state.imagenetwork == null
                  ?  Center(
                  child: Text(
                      'No Image Selected.',
                      style:
                      GoogleFonts.lato(
                        textStyle: TextStyle(
                            color: colour.commonColorLight,
                            fontWeight: FontWeight.bold,
                            fontSize: objfun.FontLow,
                            letterSpacing: 0.3),)))
                  : Container(

                child: GridView.builder(

                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                  ),
                  itemCount: state.imagenetwork.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                        onLongPress: (){
                          state.DeleteImages(index);
                          state.setState(() {
                            state.progress = true;
                          });

                        },
                        onTap: (){
                          state._showDialogPreviewImage(index);
                        },
                        child: CachedNetworkImage(
                          placeholder: (context,
                              url) =>
                          const CircularProgressIndicator(),
                          imageUrl: "${objfun.imagepath}SalesOrder/${state.SaleOrderId}/${state.txtJobStatus.text}/${state.imagenetwork[index]}",
                          fit: BoxFit.fill,
                        )
                      // Image.file(
                      //   _images[index]!,
                      //   fit: BoxFit.cover,
                      // ) ,
                    );
                  },
                ),
              ),
            )

          ],
        ),
        ), ));
}