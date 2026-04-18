part of 'package:maleva/Transaction/Stock/StockUpdate.dart';

tabletdesign(OldStockUpdateState state, BuildContext context) {
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
            icon: const Icon(Icons.arrow_back,size: 35,),
            onPressed: () {

              Navigator.pop(context);
            },
          ),
          key: state.appBarKey,
          title:  SizedBox(
            height: height * 0.05,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
               Text('Status Update',
                        style:GoogleFonts.lato(textStyle: TextStyle(
                          color: colour.topAppBarColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Alatsi',
                          fontSize: objfun.FontMedium,
                        ))),

                        Text(" - ${state.UserName}",
                          style: GoogleFonts.lato(textStyle:TextStyle(
                            color: colour.commonColorLight,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Alatsi',
                            fontSize: objfun.FontLow - 2,
                          )),)

              ],
            ),
          ),

          iconTheme: const IconThemeData(color: colour.topAppBarColor),
          actions: [
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
            :     Padding(
  padding: const EdgeInsets.only(
  top: 25.0, left: 50.0, right: 50.0,bottom: 15),
  child: Card(
  elevation: 15,
  child: Container(
  padding: const EdgeInsets.only(
  top: 50.0, left:25.0, right: 25.0,bottom: 25),
  child: ListView(
          children: <Widget>[
            Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Column(
                 children: [
                   Row(
                       children: [
                         Expanded(
                           // width: 250,
                             flex: 1,
                             child: Transform.scale(
                               scale: 1.5,
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
                             )
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
                             child: Transform.scale(
                               scale: 1.5,
                               child:Radio(
                                 value: "1",
                                 groupValue: state.BillType,
                                 onChanged: (value) {

                                   state.setState(() {
                                     state.BillType = value.toString();
                                   });
                                   OnlineApi.GetJobNoForwarding(context,int.parse(state.BillType));
                                 },
                               ),)
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
                     Expanded(flex:2,child:Container(
                       width: objfun.SizeConfig.safeBlockHorizontal * 99,
                       height: objfun.SizeConfig.safeBlockVertical * 9,
                       alignment: Alignment.topCenter,
                       padding: const EdgeInsets.only(bottom: 5),
                       child: TextField(
                         cursorColor: colour.commonColor,
                         controller: state.txtBarcodeNo,
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

                           });
                         },
                       ),
                     ),
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
                         if(state.txtBarcodeNo.text.isEmpty){
                           objfun.toastMsg('Enter Job No', '', context);
                           return;
                         }
                         await OnlineApi.EditSalesOrder(
                             context, state.SaleOrderId, int.parse(state.txtBarcodeNo.text));
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
                             size: 35,
                           )],
                       ),
                     ), ),
                   ],),
                   const SizedBox(height: 7,),
                   SizedBox(
                     height: height * 0.09,
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
                                 hintStyle: GoogleFonts.lato(textStyle:TextStyle(
                                     fontSize: objfun.FontMedium,
                                     fontWeight: FontWeight.bold,
                                     color: colour.commonColorLight)),
                                 suffixIcon: InkWell(
                                     child: Icon(
                                         (state.txtStatus
                                             .text.isNotEmpty)
                                             ? Icons.close
                                             : Icons.search_rounded,
                                         color:
                                         colour.commonColorred,
                                         size: 35.0),
                                     onTap: () async {
                                       if(state.txtBarcodeNo.text == "" && state.txtStatus.text == ""){
                                         objfun.toastMsg("Enter Job No", "", context);
                                         return;
                                       }
                                       if (state.txtStatus.text == "" &&
                                           state.txtBarcodeNo.text != "") {
                                         await OnlineApi.EditSalesOrder(
                                             context, state.SaleOrderId, int.parse(state.txtBarcodeNo.text));
                                         await OnlineApi
                                             .SelectAllJobStatus(
                                             context,objfun
                                             .SaleEditMasterList[0]["JobMasterRefId"]);
                                         Navigator.push(
                                           context,
                                           MaterialPageRoute(
                                               builder: (context) =>
                                                   const JobAllStatus(
                                                       Searchby: 1,
                                                       SearchId: 0,
                                                       JobTypeId:
                                                       0)),
                                         ).then(
                                                 (dynamic value) async {
                                               state.setState(() {
                                                 state.txtStatus.text = objfun
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
                                           state.txtStatus.text = "";
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
                   const SizedBox(height: 5,),

                   const SizedBox(height: 7,),

                   const SizedBox(height: 7,),


                   const SizedBox(height: 7,),
                 ],
                )),
                Expanded(
                    flex: 1,
                    child: Column(
                  children: [
                    Container(
                      height: height *0.60,
                      width: width * 0.40,
                      decoration: BoxDecoration(
                          border: Border.all(color: colour.commonColorLight)
                      ),
                      child:
                      state.imagenetwork.isEmpty ? Center(
                          child: Text(
                            'No Image Selected.',
                            style:GoogleFonts.lato(textStyle:
                            TextStyle(
                                color: colour.commonColorLight,
                                fontWeight: FontWeight.bold,
                                fontSize: objfun.FontLow,
                                letterSpacing: 0.3)),
                          )):
                      state.imagenetwork == null
                          ?  Center(
                          child: Text(
                            'No Image Selected.',
                            style:GoogleFonts.lato(textStyle:
                            TextStyle(
                                color: colour.commonColorLight,
                                fontWeight: FontWeight.bold,
                                fontSize: objfun.FontLow,
                                letterSpacing: 0.3)),))
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

                                  state.setState(() {
                                    state.progress = true;
                                  });

                                },
                                onTap: (){

                                },
                                child: CachedNetworkImage(
                                  placeholder: (context,
                                      url) =>
                                  const CircularProgressIndicator(),
                                  imageUrl: "${objfun.imagepath}SalesOrder/${state.SaleOrderId}/Boarding/${state.imagenetwork[index]}",
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
                ))
              ],
            ),




          ],
        ),))
        ), ));
}