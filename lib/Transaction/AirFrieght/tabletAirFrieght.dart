part of 'package:maleva/Transaction/AirFrieght/AirFrieght.dart';


tabletdesign(OldAirFrieghtUpdateState state, BuildContext context) {
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
              if(state.overlayEntry != null){
                state.clearOverlay();
              }
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
                Text('Air Frieght Update',
                        style:GoogleFonts.lato(
                            textStyle: TextStyle(
                              color: colour.topAppBarColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Alatsi',
                              fontSize: objfun.FontMedium,
                            ))),
                        Text(" - ${state.UserName}",
                            style: GoogleFonts.lato(
                                textStyle:TextStyle(
                                  color: colour.commonColorLight,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Alatsi',
                                  fontSize: objfun.FontLow ,
                                ))),

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
                    state.UpdateAirFrieghtDetails();
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
            :  Container(
            padding: const EdgeInsets.only(
                top: 15.0, left: 50.0, right: 50.0),
          child: Card(
            elevation: 12,
            child:  Padding(
              padding: const EdgeInsets.only(
                  top: 50.0, left: 25.0, right: 25.0, bottom: 25),
              child: ListView(
              children: <Widget>[
Row(
  children: [
    Expanded(
        flex :1 ,
        child: Column(
      children: [
        Row(children: [
          Expanded(flex:2,child:Container(
            width: objfun.SizeConfig.safeBlockHorizontal * 99,
            height: objfun.SizeConfig.safeBlockVertical * 9,
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(bottom: 5),
            child: TextField(
              cursorColor: colour.commonColor,
              controller: state.txtJobNo,
              autofocus: false,
              showCursor: true,
              decoration: InputDecoration(
                hintText: ('Job No'),
                hintStyle: GoogleFonts.lato(
                    textStyle:TextStyle(
                        fontSize: objfun.FontMedium,
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
                  size: 35,
                )],
            ),
          ), ),
        ],),
        const SizedBox(height: 7,),
        SizedBox(
          height: height * 0.07,
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
                      9,
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
        SizedBox(
          height: height * 0.07,
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
                      9,
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
                      hintStyle: GoogleFonts.lato(
                          textStyle:TextStyle(
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
                              size: 30.0),
                          onTap: () async {
                            if(state.txtJobNo.text == "" && state.txtStatus.text == ""){
                              objfun.toastMsg("Enter Job No", "", context);
                              return;
                            }
                            if (state.txtStatus.text == "" &&
                                state.txtJobNo.text != "") {
                              await OnlineApi.EditSalesOrder(
                                  context, state.SaleOrderId, int.parse(state.txtJobNo.text));
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
        const SizedBox(height: 7,),
        SizedBox(
          height: height * 0.07,
          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: TextField(
                  cursorColor: colour.commonColor,
                  controller: state.txtAWBNo,
                  autofocus: false,
                  showCursor: true,
                  decoration: InputDecoration(
                    hintText: ('AWB NO'),
                    hintStyle: GoogleFonts.lato(
                        textStyle:TextStyle(
                            fontSize:
                            objfun.FontMedium,
                            fontWeight:
                            FontWeight.bold,
                            color: colour
                                .commonColorLight)),
                    fillColor: colour.commonColor,
                    enabledBorder:
                    const OutlineInputBorder(
                      borderRadius:
                      BorderRadius.all(
                          Radius.circular(
                              10.0)),
                      borderSide: BorderSide(
                          color:
                          colour.commonColor),
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
                  TextInputAction.done,
                  textCapitalization:
                  TextCapitalization
                      .characters,
                  style:
                  GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: colour.commonColor,
                        fontWeight:
                        FontWeight.bold,
                        fontSize: objfun.FontLow,
                        letterSpacing: 0.3),
                  ),
                ),
              ),
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
                  if(state.txtJobNo.text.isEmpty){
                    objfun.toastMsg("Enter JobNo!!", "", context);
                    return;
                  }
                  state._pickImage(ImageSource.gallery);
                } : null,
                icon: Icon(
                  Icons.photo,
                  size: 40,
                  color: state.checkBoxImageUpload ? colour.commonColor : colour.commonColorDisabled,
                )),
            IconButton(
                onPressed: state.checkBoxImageUpload ? () {
                  if(state.txtJobNo.text.isEmpty){
                    objfun.toastMsg("Enter JobNo!!", "", context);
                    return;
                  }
                  /* captureImage(
                        ImageSource.gallery, 0);*/
                  state._pickImage(ImageSource.camera);
                } : null,
                icon: Icon(
                  Icons.camera_alt,
                  size: 40,
                  color:state.checkBoxImageUpload ? colour.commonColor : colour.commonColorDisabled,
                )),
          ],
        ),

        const SizedBox(height: 7,),
      ],
    )),
    Expanded(
      flex: 1,
      child: Column(
        children: [Container(
          height: height *0.60,
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
                      imageUrl: "${objfun.imagepath}SalesOrder/${state.SaleOrderId}/AirFrieght/${state.imagenetwork[index]}",
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
        )],
      ),
    )
  ],
),




              ],
            ),
            ),
          )
        ) ));
}