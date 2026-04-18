part of 'package:maleva/Transaction/Stock/StockUpdate.dart';


mobiledesign(OldStockUpdateState state, BuildContext context) {
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
                    child: Text('Stock Update',
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
                width: 50,
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
                    onPressed: () async {
                      state.clear();
                    },
                    child:Icon(Icons.refresh,color: colour.commonColor,)

                ),
              ),
            ),
            // objfun.DriverLogin == 1 ? Text(""):  Padding(
            //   padding:
            //   const EdgeInsets.only(top: 7.0, bottom: 7.0, left: 7.0),
            //   child: SizedBox(
            //     width: 50,
            //     height: 25,
            //     child: ElevatedButton(
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: colour.commonColorLight,
            //         side: const BorderSide(
            //             color: colour.commonColor,
            //             width: 1,
            //             style: BorderStyle.solid),
            //         textStyle: const TextStyle(color: Colors.black),
            //         elevation: 20.0,
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(10.0),
            //         ),
            //         padding: const EdgeInsets.all(4.0),
            //       ),
            //       onPressed: () async {
            //         if(objfun.storagenew.getString('RulesType') == "BOARDING" || objfun.storagenew.getString('RulesType') == "FORWARDING" || objfun.storagenew.getString('RulesType') == "OPERATION"){
            //
            //           Navigator.push(context, MaterialPageRoute(builder: (
            //               context) => BoardingStatusUpdate(JobId:state.SaleOrderId,JobNo: state.Jobno,)));
            //         }
            //
            //
            //         // else if(objfun.storagenew.getString('RulesType') == "BOARDING" || objfun.storagenew.getString('RulesType') == "FORWARDING" || objfun.storagenew.getString('RulesType') == "OPERATION")
            //         // {
            //         //   Navigator.push(context, MaterialPageRoute(builder: (
            //         //       context) => BoardingStatusUpdate()));
            //         // }
            //       },
            //       child:Icon(Icons.image,color: colour.commonColor,)
            //
            //     ),
            //   ),
            // ),

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


            Row(children: [
              Expanded(
                flex:4,
                child:Text("Packages :"+ "     " + state.TotalPkg.toString(),
                  style: GoogleFonts.lato(
                      fontSize: objfun.FontMedium,
                      // height: 1.45,
                      fontWeight: FontWeight.bold,
                      color: colour.commonColor),)
              ),
              const SizedBox(width: 3,),
              Expanded(
                  flex:1,
                  child:Text(state.ScnPkg.toString(),
                    style: GoogleFonts.lato(
                        fontSize: objfun.FontMedium,
                        // height: 1.45,
                        fontWeight: FontWeight.bold,
                        color: colour.commonColorred),)
              ),
              const SizedBox(width: 4,),
              Expanded(
                  flex:1,
                  child:Text("SCAN",
                    style: GoogleFonts.lato(
                        fontSize: objfun.FontMedium,
                        // height: 1.45,
                        fontWeight: FontWeight.bold,
                        color: colour.commonColor),)
              ),
              const SizedBox(width: 4,),
              Expanded(flex:1,child:ElevatedButton(
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
                  objfun
                      .barcodeScanning()
                      .then((dynamic value) async {
                    if (objfun.barcodeerror == false) {

                      if (state.StockNoList.length == 0) {
                        var JobId = objfun.barcodestring.split('-')[0];
                        await state.loadStockData(JobId);
                      }
                      state.setState(() {
                        if (state.CheckStockNoList.contains(
                            objfun.barcodestring) &&
                            !state.StockNoList.contains(
                                objfun.barcodestring)) {
                          state.StockNoList.add(objfun.barcodestring);
                          state.ScnPkg = state.StockNoList.length;
                        }
                        else {
                          objfun.ConfirmationOK(
                              "Invalid!!!", context);
                        }
                      });

                    }
                    // state.setState(() {
                    //   if (objfun.barcodeerror ==
                    //       false) {
                    //     state.setState(() {
                    //       state.StockNoList.add( objfun.barcodestring);
                    //       state.ScnPkg = state.StockNoList.length;
                    //     });
                    //   }
                    // });
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    const Icon( Icons.center_focus_weak,
                      color: colour.commonColorLight,
                    )],
                ),
              ), ),
            ],),
            Row(children: [
              Expanded(
                flex:3,
                child: Container(
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
                    controller: state.txtWareHouse,
                    textInputAction:
                    TextInputAction.done,
                    keyboardType:
                    TextInputType.name,
                    readOnly: true,
                    style: GoogleFonts
                        .lato(
                      textStyle: TextStyle(
                          color:
                          colour.commonColor,
                          fontWeight:
                          FontWeight.bold,
                          fontSize:
                          objfun.FontLow,
                          letterSpacing: 0.3),
                    ),
                    decoration: InputDecoration(
                      hintText: "Location",
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
                              (state.txtWareHouse
                                  .text
                                  .isNotEmpty)
                                  ? Icons.close
                                  : Icons
                                  .search_rounded,
                              color: colour
                                  .commonColorred,
                              size: 30.0),
                          onTap: () {
                            if (state.txtWareHouse
                                .text ==
                                "") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                    const WareHouse(
                                        Searchby:
                                        1,
                                        SearchId:
                                        0)),
                              ).then((dynamic
                              value) async {
                                state.setState(() {
                                  state.txtWareHouse
                                      .text =
                                      objfun
                                          .SelectWareHouseList
                                          .PortName;
                                  state.WareHouseId =
                                      objfun
                                          .SelectWareHouseList
                                          .Id;
                                  objfun.SelectWareHouseList =
                                      WareHouseModel
                                          .Empty();
                                });
                              });
                            } else {
                              state.setState(() {
                                state.txtWareHouse
                                    .text = "";
                                state.WareHouseId =0;
                                objfun.SelectWareHouseList =
                                    WareHouseModel
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
                  ),
                ),
              ),

            ],),
            Row(
              children: [
              Expanded(
                  flex:3,
                  child:SizedBox(
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
              ),
              Expanded(
                  flex:2,
                  child:Text("  "+state.Jobno,
                    style: GoogleFonts.lato(
                        fontSize: objfun.FontMedium,
                        // height: 1.45,
                        fontWeight: FontWeight.bold,
                        color: colour.commonColor),)
              ),
              const SizedBox(width: 7,),
              Expanded(flex:1,child:ElevatedButton(
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
                  if(state.TotalPkg != 0 && state.TotalPkg == state.ScnPkg ) {
                    if (state.StockId != 0 ) {
                      bool result = await objfun.ConfirmationMsgYesNo(
                          context, "Do you want to update the Status ?");
                      if (result == true) {
                        state.UpdateStockStatus(state.StockId, state.StatusId,state.WareHouseId);
                      }
                    }
                    else{
                      await objfun.ConfirmationOK('Invalid Details', context);
                    }
                  }
                  else{
                    await objfun.ConfirmationOK('Stock Mismatch', context);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Text(
                    //   'UPDATE',
                    //   style: GoogleFonts.lato(
                    //       fontSize: objfun.FontMedium,
                    //       // height: 1.45,
                    //       fontWeight: FontWeight.bold,
                    //       color: colour.commonColorLight),
                    // ),
                    Icon(Icons.save_as_outlined,color:colour.commonColorLight,)
                  ],
                ),
              ), ),
            ],),
             SizedBox(height: height * 0.02,),
             SizedBox(
                height: height * 0.25,
                child: (state.StockNoList.isNotEmpty
                    ? Container(
                    height: height / 1.4,
                    margin: const EdgeInsets.all(0),
                    padding:
                    const EdgeInsets.only(left: 1, right: 1),
                    child: ListView.builder(
                        itemCount:
                        state.StockNoList.length,
                        itemBuilder:
                            (BuildContext context, int index) {
                          return SizedBox(
                              height: height * 0.07,
                              child: InkWell(
                                onLongPress: () {

                                },
                                child: Card(
                                  // margin: EdgeInsets.all(10.0),

                                    color: colour.commonColorLight,
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
                                                  flex: 3,
                                                  child: Container(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(5),
                                                    child: Text(
                                                      state.StockNoList[index].toString()  ,
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
                                                  flex: 1,
                                                  child:InkWell(
                                                    onTap: (){
                                                      state.setState(() {
                                                        state.StockNoList.removeAt(index);
                                                        state.ScnPkg = state.StockNoList.length;
                                                        if(state.StockNoList.isEmpty){
                                                          state.CheckStockNoList = [];
                                                          state.TotalPkg = 0;
                                                          state.Jobno = "";

                                                        }
                                                      });

                                                    },
                                                    child: Icon(Icons.delete,
                                                    color:  colour.commonColor,),
                                                  )
                                                ),

                                              ],
                                            )),


                                      ],
                                    )),
                              ));
                        }))
                    : Container(
                    width: width - 40.0,
                    height: height / 1.4,
                    padding: const EdgeInsets.all(20),
                    child:  Center(
                      child: Text('No Stock Scanned',
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
                          imageUrl: "${objfun.imagepath}SalesOrder/${state.SaleOrderId}/${state.txtJobStatus.text.replaceAll(' ', '')}/${state.imagenetwork[index]}",
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