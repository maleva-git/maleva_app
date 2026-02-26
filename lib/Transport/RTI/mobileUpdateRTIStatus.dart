part of 'package:maleva/Transport/RTI/UpdateRTIStatus.dart';


mobiledesign(RTIStatusState state, BuildContext context) {
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
                    child: Text('RTI Status',
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
                    state.UpdateStatusMail();

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
            :   Padding(
          padding: const EdgeInsets.only(
              top: 15.0, left: 15.0, right: 15.0),child: ListView(
          children: <Widget>[
            Row(children: [
              Expanded(flex:3,child:Container(
                width: objfun.SizeConfig.safeBlockHorizontal * 99,
                height: objfun.SizeConfig.safeBlockVertical * 6,
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.only(bottom: 5),
                child: TextField(
                  cursorColor: colour.commonColor,
                  controller: state.txtRTINo,
                  autofocus: false,
                  showCursor: false,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: ('RTI No'),
                    hintStyle:GoogleFonts.lato(
                        textStyle: TextStyle(
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

                ),
              ),
              ),

            ],),
            const SizedBox(height: 7,),
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
                  showCursor: false,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: ('Job No'),
                    hintStyle:GoogleFonts.lato(
                        textStyle: TextStyle(
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

                ),
              ),
              ),

            ],),
            const SizedBox(height: 7,),
            SizedBox(
              height: height * 0.06,
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child:Container(
                      padding: const EdgeInsets.only(
                        left: 10.0,
                        right: 10.0,
                      ),
                      decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(10.0),
                          color: colour.commonColorLight,
                          border: Border.all()),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          isExpanded: true,
                          value: state.dropdownValueStatus,
                          onChanged:  (String? value) async {
                            state.setState((){
                              state.dropdownValueStatus=value!;
                            });
                            if(state.dropdownValueStatus == "PickUp")
                            {
                              state.DriverFolder = "DriverPickup";
                            }
                            else
                            {
                              state.DriverFolder = "DriverDelivery";
                            }
                            state.setState((){
                              state.imagenetwork = [];
                            });
                            state.loaddata();
                          },
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                                color: colour.commonColor,
                                fontWeight: FontWeight.bold,
                                fontSize: objfun.FontMedium,
                                letterSpacing: 0.3),
                          ),
                          items: RTIStatusState.DriverStatus.map<
                              DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style:
                                    GoogleFonts.lato(
                                      textStyle: TextStyle(
                                          color: colour.commonColor,
                                          fontWeight:
                                          FontWeight.bold,
                                          fontSize:
                                          objfun.FontMedium,
                                          letterSpacing: 0.3),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 5,),

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
                  style:GoogleFonts.lato(
                      textStyle: TextStyle(
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
                      size: 35,
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
                      size: 35,
                      color:state.checkBoxImageUpload ? colour.commonColor : colour.commonColorDisabled,
                    )),
              ],
            ),

            const SizedBox(height: 7,),

            Container(
              height: height *0.57,
              width: width * 0.40,
              decoration: BoxDecoration(
                  border: Border.all(color: colour.commonColorLight)
              ),
              child:
              state.imagenetwork.isEmpty ? Center(
                  child: Text(
                    'No Image Selected.',
                    style:GoogleFonts.lato(
                        textStyle:
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
                      style:GoogleFonts.lato(
                        textStyle:
                        TextStyle(
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
                          imageUrl: "${objfun.imagepath}SalesOrder/${state.SaleOrderId}/${state.DriverFolder}/${state.imagenetwork[index]}",
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