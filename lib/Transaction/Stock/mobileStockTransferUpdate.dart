part of 'package:maleva/Transaction/Stock/StockTransferUpdate.dart';


mobiledesign(StockTransferUpdateState state, BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;
  return  WillPopScope(
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
                    child: Text('Stock Transfer Update',
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


            ],),
            Row(
              children: [
              Expanded(
                flex:1,
                child:Text("  " + state.TotalPkg.toString(),
                  style: GoogleFonts.lato(
                      fontSize: objfun.FontMedium,
                      // height: 1.45,
                      fontWeight: FontWeight.bold,
                      color: colour.commonColor),)
              ),
               SizedBox(width: 3,height: height *0.055,),
              Expanded(
                  flex:1,
                  child:Text(state.ScnPkg.toString(),
                    style: GoogleFonts.lato(
                        fontSize: objfun.FontMedium,
                        // height: 1.45,
                        fontWeight: FontWeight.bold,
                        color: colour.commonColorred),)
              ),



              const SizedBox(width: 3,),
              Expanded(
                  flex:3,
                  child:Text(state.PortName.toString(),
                    style: GoogleFonts.lato(
                        fontSize: objfun.FontMedium,
                        // height: 1.45,
                        fontWeight: FontWeight.bold,
                        color: colour.commonColor),)
              ),
                const SizedBox(width: 3,),
                Expanded(
                    flex:1,
                    child:Text("SCAN",
                      style: GoogleFonts.lato(
                          fontSize: objfun.FontMedium,
                          // height: 1.45,
                          fontWeight: FontWeight.bold,
                          color: colour.commonColorred),)
                ),
                const SizedBox(width: 3,),
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
              const SizedBox(width: 4,),

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
                        hintText: "WareHouse",
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
                  if(state.WareHouseId == 0){
                    await objfun.ConfirmationOK('Select WareHouse', context);
                    return;
                  }
                  if(state.TotalPkg != 0 && state.TotalPkg == state.ScnPkg ) {
                    if (state.StockId != 0 ) {
                      bool result = await objfun.ConfirmationMsgYesNo(
                          context, "Do you want to Transfer the Stock ?");
                      if (result == true) {
                        state.UpdateStockStatus(state.StockId, state.WareHouseId);
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
                height: height * 0.66,
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
                                                          state.clear();

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
             
           

          ],
        ),
        ), ));
}