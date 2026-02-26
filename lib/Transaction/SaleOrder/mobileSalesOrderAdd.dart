part of 'package:maleva/Transaction/SaleOrder/SalesOrderAdd.dart';


mobiledesign(SalesOrderAddState state, BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;
  bool enabled =
      !state.DisabledBillType &&
          state.isAllowed("cmbBillType");

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
                  "Code",
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
                  "Description",
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
                flex: 1,
                child: Text(
                  "Qty",
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
                  "SaleRate",
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
                  "GST",
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
                    "Amount",
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
                const Expanded(flex: 2, child: Text(""))
              ],
            )),
      ],
    );
  }
  Future<void> showDialogPickUpAddress() async {
    // flutter defined function
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Dialog(
                    elevation: 40.0,
                    child: Container(
                        width: width * 0.65,
                        height: height * 0.65,
                        alignment: Alignment.center,
                        margin:
                        const EdgeInsets.only(right: 15.0, left: 15.0, top: 7),
                        child: Column(children: [
                          ListView(shrinkWrap: true, children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 8,
                                  child: Container(),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: FloatingActionButton(
                                    backgroundColor: colour.commonColor,
                                    onPressed: () => setState(() {
                                      state.Productclear();
                                      Navigator.of(context, rootNavigator: true)
                                          .pop(context);
                                    }),
                                    heroTag: "btn5",
                                    tooltip: 'Close',
                                    child: const Icon(
                                      Icons.close,
                                      color: colour.ButtonForeColor,
                                      size: 25.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Center(
                                child: Container(
                                  color: colour.commonColor,
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  child: Text(
                                    "PickUp Address & Qty List",
                                    maxLines: 1,
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                          color: colour.ButtonForeColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: objfun.FontMedium,
                                          overflow: TextOverflow.ellipsis,
                                          letterSpacing: 1.3),
                                    ),
                                  ),
                                )),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: height * 0.50,
                              child: (state.PickUpAddressList.isNotEmpty
                                  ? Container(
                                  height: 70,
                                  margin: const EdgeInsets.all(0),
                                  padding:
                                  const EdgeInsets.only(left: 0, right: 0),
                                  child: ListView.builder(
                                      itemCount: state.PickUpAddressList.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return InkWell(
                                            onLongPress: () async {
                                              bool result = await objfun
                                                  .ConfirmationMsgYesNo(context,
                                                  "Are you sure to delete ?");
                                              if (result == true) {
                                                setState(() {
                                                  state.PickUpAddressList.removeAt(
                                                      index);
                                                });
                                              }
                                            },
                                            onTap: () {
                                              state.txtPickUpAddress.text =
                                              state.PickUpAddressList[index];
                                              state.txtPickUpQuantity.text =
                                              state.PickUpQuantityList[index];
                                              Navigator.of(context,
                                                  rootNavigator: true)
                                                  .pop(context);
                                            },
                                            child: SizedBox(
                                              height: 85,
                                              child: Card(
                                                //margin: EdgeInsets.all(10.0),
                                                  elevation: 10.0,
                                                  borderOnForeground: true,
                                                  semanticContainer: true,
                                                  shape: RoundedRectangleBorder(
                                                    side: const BorderSide(
                                                        color:
                                                        colour.commonColor,
                                                        width: 1),
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        10),
                                                  ),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .center,
                                                    children: [
                                                      Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                          padding:
                                                          const EdgeInsets.all(5),
                                                          child: Text(
                                                            state.PickUpAddressList[
                                                            index]
                                                                .toString(),
                                                            textAlign: TextAlign
                                                                .justify,
                                                            /*overflow:
                                                          TextOverflow.ellipsis,*/
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
                                                      ),
                                                      Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                          padding:
                                                          const EdgeInsets.all(5),
                                                          child: Text(
                                                            state.PickUpQuantityList[
                                                            index]
                                                                .toString(),
                                                            textAlign: TextAlign
                                                                .justify,
                                                            /*overflow:
                                                          TextOverflow.ellipsis,*/
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
                                                      ),
                                                    ],
                                                  )),
                                            ));
                                      }))
                                  : Container(
                                  width: 40.0,
                                  height: 60,
                                  padding: const EdgeInsets.all(20),
                                  child: const Center(
                                    child: Text('No Record'),
                                  ))),
                            ),
                          ]),
                        ])));
              });
        });
  }
  Future<void> showDialogDeliveryAddress() async {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    // flutter defined function
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Dialog(
                    elevation: 40.0,
                    child: Container(
                        width: width * 0.65,
                        height: height * 0.65,
                        alignment: Alignment.center,
                        margin:
                        const EdgeInsets.only(right: 15.0, left: 15.0, top: 7),
                        child: Column(children: [
                          ListView(shrinkWrap: true, children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 8,
                                  child: Container(),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: FloatingActionButton(
                                    backgroundColor: colour.commonColor,
                                    onPressed: () => setState(() {
                                      state.Productclear();
                                      Navigator.of(context, rootNavigator: true)
                                          .pop(context);
                                    }),
                                    heroTag: "btn5",
                                    tooltip: 'Close',
                                    child: const Icon(
                                      Icons.close,
                                      color: colour.ButtonForeColor,
                                      size: 25.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Center(
                                child: Container(
                                  color: colour.commonColor,
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                  child: Text(
                                    "Delivery Address & Qty List",
                                    maxLines: 1,
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                          color: colour.ButtonForeColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: objfun.FontMedium,
                                          overflow: TextOverflow.ellipsis,
                                          letterSpacing: 1.3),
                                    ),
                                  ),
                                )),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: height * 0.50,
                              child: (state.DeliveryAddressList.isNotEmpty
                                  ? Container(
                                  height: 70,
                                  margin: const EdgeInsets.all(0),
                                  padding:
                                  const EdgeInsets.only(left: 0, right: 0),
                                  child: ListView.builder(
                                      itemCount: state.DeliveryAddressList.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return InkWell(
                                            onLongPress: () async {
                                              bool result = await objfun
                                                  .ConfirmationMsgYesNo(context,
                                                  "Are you sure to delete ?");
                                              if (result == true) {
                                                setState(() {
                                                  state.DeliveryAddressList.removeAt(
                                                      index);
                                                });
                                              }
                                            },
                                            onTap: () {
                                              state.txtDeliveryAddress.text =
                                              state.DeliveryAddressList[index];
                                              state.txtDeliveryQuantity.text =
                                              state.DeliveryQuantityList[index];
                                              Navigator.of(context,
                                                  rootNavigator: true)
                                                  .pop(context);
                                            },
                                            child: SizedBox(
                                              height: 85,
                                              child: Card(
                                                //margin: EdgeInsets.all(10.0),
                                                  elevation: 10.0,
                                                  borderOnForeground: true,
                                                  semanticContainer: true,
                                                  shape: RoundedRectangleBorder(
                                                    side: const BorderSide(
                                                        color:
                                                        colour.commonColor,
                                                        width: 1),
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        10),
                                                  ),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .center,
                                                    children: [
                                                      Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                          padding:
                                                          const EdgeInsets.all(5),
                                                          child: Text(
                                                            state.DeliveryAddressList[
                                                            index]
                                                                .toString(),
                                                            textAlign: TextAlign
                                                                .justify,
                                                            /*overflow:
                                                          TextOverflow.ellipsis,*/
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
                                                      ),
                                                      Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                          padding:
                                                          const EdgeInsets.all(5),
                                                          child: Text(
                                                            state.DeliveryQuantityList[
                                                            index]
                                                                .toString(),
                                                            textAlign: TextAlign
                                                                .justify,
                                                            /*overflow:
                                                          TextOverflow.ellipsis,*/
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
                                                      ),
                                                    ],

                                                  )),
                                            ));
                                      }))
                                  : Container(
                                  width: 40.0,
                                  height: 60,
                                  padding: const EdgeInsets.all(20),
                                  child: const Center(
                                    child: Text('No Record'),
                                  ))),
                            ),
                          ]),
                        ])));
              });
        });
  }
  Future<void> showDialogProductAdd(int index, int EditId) async {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    if (objfun.SelectProductList.ProductName != "") {
      state.txtProductDescription.text = objfun.SelectProductList.ProductName;
      state.txtProductCode.text = objfun.SelectProductList.Productcode;
/*      txtProductSaleRate.text = objfun.SelectProductList.SaleRate.toString();
      txtProductGst.text = objfun.SelectProductList.GST.toString();
      txtProductMRP.text = objfun.SelectProductList.MRP.toString();
      txtProductPurchaseRate.text = objfun.SelectProductList.PurRate.toString();*/
      state.txtProductId.text = objfun.SelectProductList.Id.toString();
      state.txtItemMasterRefId.text = objfun.SelectProductList.Id.toString();

      await state.Calculation();
    }
    if (EditId == 1) {
      state.txtProductDescription.text = state.ProductViewList[index].ProductName;
      state.txtProductCode.text = state.ProductViewList[index].ProductCode;
      state.txtProductSaleRate.text = state.ProductViewList[index].SalesRate.toString();
      state.txtProductGst.text = state.ProductViewList[index].TaxPercent.toString();
      state.txtProductQty.text = state.ProductViewList[index].ItemQty.toString();
      state.txtProductMRP.text = state.ProductViewList[index].MRP.toString();
      state.txtProductPurchaseRate.text =
          state.ProductViewList[index].PurchaseRate.toString();
      state.txtProductId.text = state.ProductViewList[index].Id.toString();
      state.txtProductSDId.text = state.ProductViewList[index].SDId.toString();
      state.txtSaleOrderMasterRefId.text =
          state.ProductViewList[index].SaleOrderMasterRefId.toString();
      state.txtProductLandingCost.text =
          state.ProductViewList[index].LandingCost.toString();
      state.txtProductNetSalesRate.text =
          state.ProductViewList[index].NetSalesRate.toString();
      state.txtSaleOrderMasterRefId.text =
          state.ProductViewList[index].SaleOrderMasterRefId.toString();
      state.txtProductLandingCost.text =
          state.ProductViewList[index].LandingCost.toString();
      state.txtItemMasterRefId.text =
          state.ProductViewList[index].ItemMasterRefId.toString();

      await state.Calculation();
      state.setState(() {
        state.ProductUpdateIndex = index;
      });
    } else {
      state.setState(() {
        state.ProductUpdateIndex = null;
      });
    }
    // flutter defined function
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              elevation: 40.0,
              child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                    width: width * 0.95,
                    height: height * 0.95,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(
                        right: 15.0, left: 15.0, bottom: 15, top: 7),
                    child: Column(children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 8,
                            child: Container(),
                          ),
                          Expanded(
                            flex: 1,
                            child: FloatingActionButton(
                              backgroundColor: colour.commonColor,
                              onPressed: () => state.setState(() {
                                state.Productclear();
                                Navigator.of(context, rootNavigator: true)
                                    .pop(context);
                              }),
                              heroTag: "btn5",
                              tooltip: 'Close',
                              child: const Icon(
                                Icons.close,
                                color: colour.ButtonForeColor,
                                size: 25.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Center(
                        child: Text(
                          "Product Add",
                          maxLines: 1,
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                                color: colour.commonColor,
                                fontWeight: FontWeight.bold,
                                fontSize: objfun.FontLarge,
                                letterSpacing: 1.3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            Expanded(
                              flex: 1,
                              //height: height * 0.06,
                              child: Container(
                                width:
                                objfun.SizeConfig.safeBlockHorizontal * 99,
                                height: objfun.SizeConfig.safeBlockVertical * 5,
                                alignment: Alignment.topCenter,
                                padding: const EdgeInsets.only(bottom: 5),
                                child: TextField(
                                  cursorColor: colour.commonColor,
                                  controller: state.txtProductCode,
                                  autofocus: false,
                                  showCursor: false,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    hintText: ('Product Code'),
                                    hintStyle:GoogleFonts.lato(
                                        textStyle: TextStyle(
                                            fontSize: objfun.FontMedium,
                                            fontWeight: FontWeight.bold,
                                            color: colour.commonColorLight)),
                                    fillColor: colour.commonColor,
                                    enabledBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide:
                                      BorderSide(color: colour.commonColor),
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
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                width:
                                objfun.SizeConfig.safeBlockHorizontal * 99,
                                height: objfun.SizeConfig.safeBlockVertical * 5,
                                alignment: Alignment.topCenter,
                                padding: const EdgeInsets.only(bottom: 5),
                                child: TextField(
                                  textCapitalization:
                                  TextCapitalization.characters,
                                  controller: state.txtProductDescription,
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
                                    hintText: "Product Description",
                                    hintStyle:GoogleFonts.lato(
                                        textStyle: TextStyle(
                                            fontSize: objfun.FontMedium,
                                            fontWeight: FontWeight.bold,
                                            color: colour.commonColorLight)),
                                    suffixIcon: InkWell(
                                        child: Icon(
                                            (state.txtProductDescription
                                                .text.isNotEmpty)
                                                ? Icons.close
                                                : Icons.search_rounded,
                                            color: colour.commonColorred,
                                            size: 30.0),
                                        onTap: () {
                                          if (state.txtProductDescription.text ==
                                              "") {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                  const Product(
                                                      Searchby: 1,
                                                      SearchId: 0)),
                                            ).then((dynamic value) async {
                                              Navigator.of(context,
                                                  rootNavigator: true)
                                                  .pop(context);

                                              showDialogProductAdd(0, 0);
                                            });
                                          } else {
                                            state.Productclear();
                                          }
                                        }),
                                    fillColor: Colors.black,
                                    enabledBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide:
                                      BorderSide(color: colour.commonColor),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide: BorderSide(
                                          color: colour.commonColorred),
                                    ),
                                    contentPadding: const EdgeInsets.only(
                                        left: 10, right: 10, top: 10.0),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Expanded(
                              flex: 1,
                              //height: height * 0.06,
                              child: Container(
                                width:
                                objfun.SizeConfig.safeBlockHorizontal * 99,
                                height: objfun.SizeConfig.safeBlockVertical * 5,
                                alignment: Alignment.topCenter,
                                padding: const EdgeInsets.only(bottom: 5),
                                child: TextField(
                                  cursorColor: colour.commonColor,
                                  controller: state.txtProductQty,
                                  autofocus: false,
                                  focusNode: state._focusQty,
                                  readOnly: true,
                                  showCursor: false,
                                  onChanged: (value) {
                                    state.Calculation();
                                  },
                                  decoration: InputDecoration(
                                    hintText: ('Qty'),
                                    hintStyle: GoogleFonts.lato(
                                        textStyle:TextStyle(
                                            fontSize: objfun.FontMedium,
                                            fontWeight: FontWeight.bold,
                                            color: colour.commonColorLight)),
                                    fillColor: colour.commonColor,
                                    enabledBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide:
                                      BorderSide(color: colour.commonColor),
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
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                width:
                                objfun.SizeConfig.safeBlockHorizontal * 99,
                                height: objfun.SizeConfig.safeBlockVertical * 5,
                                alignment: Alignment.topCenter,
                                padding: const EdgeInsets.only(bottom: 5),
                                child: TextField(
                                  cursorColor: colour.commonColor,
                                  controller: state.txtProductSaleRate,
                                  autofocus: false,
                                  showCursor: false,
                                  readOnly: true,
                                  focusNode: state._focusSaleRate,
                                  decoration: InputDecoration(
                                    hintText: ('Sale Rate'),
                                    hintStyle:GoogleFonts.lato(
                                        textStyle: TextStyle(
                                            fontSize: objfun.FontMedium,
                                            fontWeight: FontWeight.bold,
                                            color: colour.commonColorLight)),
                                    fillColor: colour.commonColor,
                                    enabledBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide:
                                      BorderSide(color: colour.commonColor),
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
                                  onChanged: (value) {
                                    state.Calculation();
                                  },
                                  keyboardType: TextInputType.text,
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
                            ),
                            Expanded(
                              flex: 1,
                              //height: height * 0.06,
                              child: Container(
                                width:
                                objfun.SizeConfig.safeBlockHorizontal * 99,
                                height: objfun.SizeConfig.safeBlockVertical * 5,
                                alignment: Alignment.topCenter,
                                padding: const EdgeInsets.only(bottom: 5),
                                child: TextField(
                                  cursorColor: colour.commonColor,
                                  controller: state.txtProductGst,
                                  autofocus: false,
                                  showCursor: false,
                                  readOnly: true,
                                  focusNode: state._focusGst,
                                  decoration: InputDecoration(
                                    hintText: ('GST'),
                                    hintStyle: GoogleFonts.lato(
                                        textStyle:TextStyle(
                                            fontSize: objfun.FontMedium,
                                            fontWeight: FontWeight.bold,
                                            color: colour.commonColorLight)),
                                    fillColor: colour.commonColor,
                                    enabledBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      borderSide:
                                      BorderSide(color: colour.commonColor),
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
                                  onChanged: (value) {
                                    state.Calculation();
                                  },
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
                            ),
                            Expanded(
                              flex: 1,
                              //height: height * 0.06,
                              child: Container(
                                width:
                                objfun.SizeConfig.safeBlockHorizontal * 99,
                                height: objfun.SizeConfig.safeBlockVertical * 6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color: colour.commonColor,
                                  ),
                                ),
                                child: TextField(
                                  cursorColor: colour.commonColor,
                                  controller: state.txtProductAmount,
                                  autofocus: false,
                                  showCursor: true,
                                  enabled: false,
                                  decoration: InputDecoration(
                                    hintText: ('Amount'),
                                    hintStyle:GoogleFonts.lato(
                                        textStyle: TextStyle(
                                            fontSize: objfun.FontMedium,
                                            fontWeight: FontWeight.bold,
                                            color: colour.commonColorLight)),
                                    fillColor: colour.commonColor,
                                    contentPadding: const EdgeInsets.only(
                                        left: 10, right: 20, bottom: 5),
                                  ),
                                  keyboardType: TextInputType.text,
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
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Expanded(
                        flex: 4,
                        child: Container(
                          // height: height * 0.20,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1.0, color: colour.commonColorLight),
                              color: colour.commonColorLight,
                              shape: BoxShape.rectangle,
                            ),
                            padding: const EdgeInsets.all(2),
                            child: Column(
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: Padding(
                                                padding:
                                                const EdgeInsets.all(1),
                                                child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                        fixedSize: Size(
                                                            height * 0.20,
                                                            width * 0.20), backgroundColor: colour
                                                            .commonColor),
                                                    child: Center(
                                                      child: Text(
                                                        '1',
                                                        style: GoogleFonts
                                                            .lato(
                                                          textStyle: TextStyle(
                                                              color: colour
                                                                  .ButtonForeColor,
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold,
                                                              fontSize: objfun
                                                                  .FontLarge,
                                                              letterSpacing:
                                                              1.3),
                                                        ),
                                                      ),
                                                    ),
                                                    onPressed: () =>
                                                    {state.keypress('1')}))),
                                        Expanded(
                                            flex: 1,
                                            child: Padding(
                                                padding:
                                                const EdgeInsets.all(1),
                                                child: ElevatedButton(
                                                  style:
                                                  ElevatedButton.styleFrom(
                                                      fixedSize: Size(
                                                          height * 0.20,
                                                          width * 0.20), backgroundColor: colour
                                                          .commonColor),
                                                  child: Text(
                                                    '2',
                                                    style: GoogleFonts
                                                        .lato(
                                                      textStyle: TextStyle(
                                                          color: colour
                                                              .ButtonForeColor,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          fontSize:
                                                          objfun.FontLarge,
                                                          letterSpacing: 1.3),
                                                    ),
                                                  ),
                                                  onPressed: () =>
                                                  {state.keypress('2')},
                                                ))),
                                        Expanded(
                                            flex: 1,
                                            child: Padding(
                                                padding:
                                                const EdgeInsets.all(1),
                                                child: ElevatedButton(
                                                  style:
                                                  ElevatedButton.styleFrom(
                                                      fixedSize: Size(
                                                          height * 0.20,
                                                          width * 0.20), backgroundColor: colour
                                                          .commonColor),
                                                  child: Text(
                                                    '3',
                                                    style: GoogleFonts
                                                        .lato(
                                                      textStyle: TextStyle(
                                                          color: colour
                                                              .ButtonForeColor,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          fontSize:
                                                          objfun.FontLarge,
                                                          letterSpacing: 1.3),
                                                    ),
                                                  ),
                                                  onPressed: () =>
                                                  {state.keypress('3')},
                                                )))
                                      ],
                                    )),
                                Expanded(
                                    flex: 1,
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 8,
                                            child: Padding(
                                                padding:
                                                const EdgeInsets.all(1),
                                                child: ElevatedButton(
                                                  style:
                                                  ElevatedButton.styleFrom(
                                                      fixedSize: Size(
                                                          height * 0.20,
                                                          width * 0.20), backgroundColor: colour
                                                          .commonColor),
                                                  child: Text(
                                                    '4',
                                                    style: GoogleFonts
                                                        .lato(
                                                      textStyle: TextStyle(
                                                          color: colour
                                                              .ButtonForeColor,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          fontSize:
                                                          objfun.FontLarge,
                                                          letterSpacing: 1.3),
                                                    ),
                                                  ),
                                                  onPressed: () =>
                                                  {state.keypress('4')},
                                                ))),
                                        Expanded(
                                            flex: 8,
                                            child: Padding(
                                                padding:
                                                const EdgeInsets.all(1),
                                                child: ElevatedButton(
                                                  style:
                                                  ElevatedButton.styleFrom(
                                                      fixedSize: Size(
                                                          height * 0.20,
                                                          width * 0.20), backgroundColor: colour
                                                          .commonColor),
                                                  child: Text(
                                                    '5',
                                                    style: GoogleFonts
                                                        .lato(
                                                      textStyle: TextStyle(
                                                          color: colour
                                                              .ButtonForeColor,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          fontSize:
                                                          objfun.FontLarge,
                                                          letterSpacing: 1.3),
                                                    ),
                                                  ),
                                                  onPressed: () =>
                                                  {state.keypress('5')},
                                                ))),
                                        Expanded(
                                            flex: 8,
                                            child: Padding(
                                                padding:
                                                const EdgeInsets.all(1),
                                                child: ElevatedButton(
                                                  style:
                                                  ElevatedButton.styleFrom(
                                                      fixedSize: Size(
                                                          height * 0.20,
                                                          width * 0.20), backgroundColor: colour
                                                          .commonColor),
                                                  child: Text(
                                                    '6',
                                                    style: GoogleFonts
                                                        .lato(
                                                      textStyle: TextStyle(
                                                          color: colour
                                                              .ButtonForeColor,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          fontSize:
                                                          objfun.FontLarge,
                                                          letterSpacing: 1.3),
                                                    ),
                                                  ),
                                                  onPressed: () =>
                                                  {state.keypress('6')},
                                                )))
                                      ],
                                    )),
                                Expanded(
                                    flex: 1,
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 8,
                                            child: Padding(
                                                padding:
                                                const EdgeInsets.all(1),
                                                child: ElevatedButton(
                                                  style:
                                                  ElevatedButton.styleFrom(
                                                      fixedSize: Size(
                                                          height * 0.20,
                                                          width * 0.20), backgroundColor: colour
                                                          .commonColor),
                                                  child: Text(
                                                    '7',
                                                    style: GoogleFonts
                                                        .lato(
                                                      textStyle: TextStyle(
                                                          color: colour
                                                              .ButtonForeColor,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          fontSize:
                                                          objfun.FontLarge,
                                                          letterSpacing: 1.3),
                                                    ),
                                                  ),
                                                  onPressed: () =>
                                                  {state.keypress('7')},
                                                ))),
                                        Expanded(
                                            flex: 8,
                                            child: Padding(
                                                padding:
                                                const EdgeInsets.all(1),
                                                child: ElevatedButton(
                                                  style:
                                                  ElevatedButton.styleFrom(
                                                      fixedSize: Size(
                                                          height * 0.20,
                                                          width * 0.20), backgroundColor: colour
                                                          .commonColor),
                                                  child: Text(
                                                    '8',
                                                    style: GoogleFonts
                                                        .lato(
                                                      textStyle: TextStyle(
                                                          color: colour
                                                              .ButtonForeColor,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          fontSize:
                                                          objfun.FontLarge,
                                                          letterSpacing: 1.3),
                                                    ),
                                                  ),
                                                  onPressed: () =>
                                                  {state.keypress('8')},
                                                ))),
                                        Expanded(
                                            flex: 8,
                                            child: Padding(
                                                padding:
                                                const EdgeInsets.all(1),
                                                child: ElevatedButton(
                                                  style:
                                                  ElevatedButton.styleFrom(
                                                      fixedSize: Size(
                                                          height * 0.20,
                                                          width * 0.20), backgroundColor: colour
                                                          .commonColor),
                                                  child: Text(
                                                    '9',
                                                    style: GoogleFonts
                                                        .lato(
                                                      textStyle: TextStyle(
                                                          color: colour
                                                              .ButtonForeColor,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          fontSize:
                                                          objfun.FontLarge,
                                                          letterSpacing: 1.3),
                                                    ),
                                                  ),
                                                  onPressed: () =>
                                                  {state.keypress('9')},
                                                )))
                                      ],
                                    )),
                                Expanded(
                                    flex: 1,
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 8,
                                            child: Padding(
                                                padding:
                                                const EdgeInsets.all(1),
                                                child: ElevatedButton(
                                                  style:
                                                  ElevatedButton.styleFrom(
                                                      fixedSize: Size(
                                                          height * 0.20,
                                                          width * 0.20), backgroundColor: colour
                                                          .commonColor),
                                                  child: Text(
                                                    'CLR',
                                                    style: GoogleFonts
                                                        .lato(
                                                      textStyle: TextStyle(
                                                          color: colour
                                                              .ButtonForeColor,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          fontSize:
                                                          objfun.FontMedium,
                                                          letterSpacing: 1.3),
                                                    ),
                                                  ),
                                                  onPressed: () => {
                                                    state.keypress('CLEAR'),
                                                  },
                                                ))),
                                        Expanded(
                                            flex: 8,
                                            child: Padding(
                                                padding:
                                                const EdgeInsets.all(1),
                                                child: ElevatedButton(
                                                  style:
                                                  ElevatedButton.styleFrom(
                                                      fixedSize: Size(
                                                          height * 0.20,
                                                          width * 0.20), backgroundColor: colour
                                                          .commonColor),
                                                  child: Text(
                                                    '0',
                                                    style: GoogleFonts
                                                        .lato(
                                                      textStyle: TextStyle(
                                                          color: colour
                                                              .ButtonForeColor,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          fontSize:
                                                          objfun.FontLarge,
                                                          letterSpacing: 1.3),
                                                    ),
                                                  ),
                                                  onPressed: () =>
                                                  {state.keypress('0')},
                                                ))),
                                        Expanded(
                                            flex: 8,
                                            child: Padding(
                                                padding:
                                                const EdgeInsets.all(1),
                                                child: ElevatedButton(
                                                  style:
                                                  ElevatedButton.styleFrom(
                                                      fixedSize: Size(
                                                          height * 0.20,
                                                          width * 0.20), backgroundColor: colour
                                                          .commonColor),
                                                  child: Text(
                                                    'C',
                                                    style: GoogleFonts
                                                        .lato(
                                                      textStyle: TextStyle(
                                                          color: colour
                                                              .ButtonForeColor,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          fontSize:
                                                          objfun.FontLarge,
                                                          letterSpacing: 1.3),
                                                    ),
                                                  ),
                                                  onPressed: () =>
                                                  {state.keypress('C')},
                                                )))
                                      ],
                                    )),
                                Expanded(
                                    flex: 1,
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 8,
                                            child: Padding(
                                                padding:
                                                const EdgeInsets.all(1),
                                                child: ElevatedButton(
                                                  style:
                                                  ElevatedButton.styleFrom(
                                                      fixedSize: Size(
                                                          height * 0.20,
                                                          width * 0.20), backgroundColor: colour
                                                          .commonColor),
                                                  child: Text(
                                                    'Add',
                                                    style: GoogleFonts
                                                        .lato(
                                                      textStyle: TextStyle(
                                                          color: colour
                                                              .ButtonForeColor,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          fontSize:
                                                          objfun.FontMedium,
                                                          letterSpacing: 1.3),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    if (state.txtProductDescription
                                                        .text.isEmpty) {
                                                      objfun.ConfirmationOK(
                                                          "Add Product !!!",
                                                          context);
                                                      return;
                                                    }
                                                    state.ProductAdd();
                                                    state.Productclear();
                                                    Navigator.of(context,
                                                        rootNavigator: true)
                                                        .pop(context);
                                                  },
                                                ))),
                                        Expanded(
                                            flex: 8,
                                            child: Padding(
                                                padding:
                                                const EdgeInsets.all(1),
                                                child: ElevatedButton(
                                                  style:
                                                  ElevatedButton.styleFrom(
                                                      fixedSize: Size(
                                                          height * 0.20,
                                                          width * 0.20), backgroundColor: colour
                                                          .commonColor),
                                                  child: Text(
                                                    'Refresh',
                                                    style: GoogleFonts
                                                        .lato(
                                                      textStyle: TextStyle(
                                                          color: colour
                                                              .ButtonForeColor,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          fontSize:
                                                          objfun.FontMedium,
                                                          letterSpacing: 1.3),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    state.Productclear();
                                                  },
                                                ))),
                                      ],
                                    )),
                              ],
                            )),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                    ]),
                  )));
        });
  }
  Future<bool> onBackPressed() async {
    bool result = false;
    if(state.overlayEntry != null){
      state.clearOverlay();
      return false;
    }else{
     result = await objfun.ConfirmationMsgYesNo(
        context, "Are you Sure you want to Exit?");
    if (result == true) {
      Navigator.of(context).pop();
    }
    else {
      return false;
    }}

    return result;
  }
  return WillPopScope(
      onWillPop: onBackPressed,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          key: state.appBarKey,
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
                Row(
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SaleOrderView()));
                  },
                  child: Text(
                    'VIEW',
                    style: GoogleFonts.lato(
                        fontSize: objfun.FontMedium,
                        // height: 1.45,
                        fontWeight: FontWeight.bold,
                        color: colour.commonColor),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(7.0),
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
                    state.SaveSalesOrder();
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
            /*IconButton(
                icon: const Icon(
                  Icons.exit_to_app_sharp,
                  size: 30.0,
                  color: colour.topAppBarColor,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),*/
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
            : DefaultTabController(
          length: 5,
          child: TabBarView(
              controller: state._tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 15.0, left: 15.0, right: 15.0),
                  child: ListView(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const SizedBox(
                            width: 7,
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              "Job No :",
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
                                margin: const EdgeInsets.only(
                                    left: 5, right: 5.0),
                                decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(10.0),
                                    color: colour.commonColorLight,
                                    border: Border.all()),
                                child: TextField(
                                  cursorColor: colour.commonColor,
                                  controller: state.txtJobNo,
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
                                          state.dtpSaleOrderdate
                                              .toString()))
                                          : DateFormat("dd-MM-yyyy")
                                          .format(DateTime.parse(
                                          state.dtpSaleOrderdate
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
                                        /*      showDatePicker(
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
                                                    state.dtpSaleOrderdate =
                                                        DateFormat("yyyy-MM-dd")
                                                            .format(datenew);
                                                  });
                                                });*/
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 7,
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          Expanded(
                              flex: 2,
                              child: Text(
                                state.TotalAmount.toString(),
                                style: GoogleFonts.lato(
                                    textStyle:TextStyle(
                                        fontSize: objfun.FontMedium,
                                        fontWeight: FontWeight.bold,
                                        color: colour.commonColorred)),
                                textAlign: TextAlign.center,
                              )),
                          Expanded(
                            flex: 3,
                            child: Container(
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
                                  value: state.dropdownValue,
                                  onChanged: enabled
                                      ? (String? value) async {
                                    await OnlineApi.MaxSaleOrderNo(context, value!);
                                    state.setState(() {
                                      state.dropdownValue = value;
                                      state.txtJobNo.text = objfun.MaxSaleOrderNum;
                                    });
                                  }
                                      : null,
                                  style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                        color: colour.commonColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: objfun.FontMedium,
                                        letterSpacing: 0.3),
                                  ),
                                  items: SalesOrderAddState.BillType.map<
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
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 7,
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
                                  controller: state.txtCustomer,
                                  enabled: state.isAllowed("txtCustomer"),
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
                                                  state.CurrencyValue = objfun.CustomerCurrencyValue;
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
                      const SizedBox(
                        height: 4,
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
                                  enabled: state.isAllowed("txtJobType"),
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
                                                    state._isTextFieldEnabled =
                                                    true;
                                                    state.txtJobType.text = objfun
                                                        .SelectJobTypeList
                                                        .Name;
                                                    state.JobTypeId = objfun
                                                        .SelectJobTypeList
                                                        .Id;
                                                    objfun.SelectJobTypeList =
                                                        JobTypeModel
                                                            .Empty();
                                                    if (state.txtJobType.text !=
                                                        "") {
                                                      state.EnableVisibility();
                                                    }

                                                    if(state.txtJobType.text ==
                                                        "GENARAL CARGO"){
                                                      state.VisibleOrigin = false;
                                                      state.VisibleDestination = false;
                                                      state.VisibleGC = true;
                                                    }
                                                    else{
                                                      state.VisibleGC = false;
                                                    }
                                                  });
                                                });
                                          } else {
                                            state.setState(() {
                                              state._isTextFieldEnabled =
                                              false;
                                              state.txtJobType.text = "";
                                              state.txtJobStatus.text = "";
                                              state.StatusId = 0;
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
                      const SizedBox(
                        height: 3,
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
                                  controller: state.txtJobStatus,
                                  enabled: state.isAllowed("txtJobStatus"),
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
                                          if (state.txtJobStatus.text == "" &&
                                              state.txtJobType.text != "") {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      JobAllStatus(
                                                          Searchby: 1,
                                                          SearchId: 0,
                                                          JobTypeId:
                                                          state.JobTypeId)),
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
                      const SizedBox(
                        height: 3,
                      ),
                      SizedBox(
                        height: height * 0.08,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: TextField(
                                cursorColor: colour.commonColor,
                                controller: state.txtRemarks,
                                enabled: state.isAllowed("txtRemarks"),
                                maxLines: null, // Set this
                                expands: true, // and this
                                keyboardType: TextInputType.text,
                                autofocus: false,
                                showCursor: true,
                                decoration: InputDecoration(
                                  hintText: ('Remarks'),
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
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      SizedBox(
                        height: height * 0.10,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: TextField(
                                cursorColor: colour.commonColor,
                                controller: state.txtDoDescription,
                                enabled: state.isAllowed("txtDoDescription"),
                                maxLines: null, // Set this
                                expands: true, // and this
                                keyboardType: TextInputType.multiline,
                                autofocus: false,
                                showCursor: true,
                                decoration: InputDecoration(
                                  hintText: ('Do Description'),
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
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: state.isAllowed("addProduct")
                                ? () {
                              showDialogProductAdd(0, 0);
                            }
                                : null, // 👈 disable
                            icon: Icon(
                              Icons.library_add_sharp,
                              size: 35,
                              color: state.isAllowed("addProduct")
                                  ? colour.commonColor
                                  : colour.commonColorDisabled,
                            ),
                          ),

                          IconButton(
                              onPressed: () {
                                state.setState(() {
                                  state.VisibleProductview =
                                  state.VisibleProductview == true
                                      ? false
                                      : true;
                                });
                              },
                              icon: const Icon(
                                Icons.library_books_rounded,
                                size: 35,
                                color: colour.commonColor,
                              )),
                        ],
                      ),
                      Visibility(
                          visible: state.VisibleProductview,
                          child: Column(
                            children: [
                              SizedBox(
                                height: height * 0.09,
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      left: 5, right: 5),
                                  // margin: const EdgeInsets.only(left: 10.0, right: 30),

                                  color: colour.commonColor,
                                  child: loadgridheader(),
                                ),
                              ),
                              SizedBox(
                                height: height * 0.65,
                                child: (state.ProductViewList.isNotEmpty
                                    ? Container(
                                    height: height / 1.4,
                                    margin: const EdgeInsets.all(0),
                                    padding: const EdgeInsets.only(
                                        left: 0, right: 0),
                                    child: ListView.builder(
                                        itemCount:
                                        state.ProductViewList.length,
                                        itemBuilder:
                                            (BuildContext context,
                                            int index) {
                                          return SizedBox(
                                            height: height <= 800
                                                ? height * 0.15
                                                : height * 0.12,
                                            child: Card(
                                              //margin: EdgeInsets.all(10.0),
                                                elevation: 10.0,
                                                borderOnForeground:
                                                true,
                                                semanticContainer:
                                                true,
                                                shape:
                                                RoundedRectangleBorder(
                                                  side: const BorderSide(
                                                      color: colour
                                                          .commonColor,
                                                      width: 1),
                                                  borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                      10),
                                                ),
                                                child: Column(
                                                  children: [
                                                    Expanded(
                                                      flex: 1,
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            flex: 1,
                                                            child:
                                                            Text(
                                                              "   ${index + 1}",
                                                              textAlign:
                                                              TextAlign.left,
                                                              style:
                                                              GoogleFonts.lato(
                                                                textStyle: TextStyle(
                                                                    color: colour.commonColor,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: objfun.FontLow,
                                                                    letterSpacing: 0.3),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 2,
                                                            child:
                                                            Text(
                                                              state.ProductViewList[index]
                                                                  .ProductCode
                                                                  .toString(),
                                                              textAlign:
                                                              TextAlign.left,
                                                              style:
                                                              GoogleFonts.lato(
                                                                textStyle: TextStyle(
                                                                    color: colour.commonColor,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: objfun.FontLow,
                                                                    letterSpacing: 0.3),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 3,
                                                            child:
                                                            Text(
                                                              state.ProductViewList[index]
                                                                  .ProductName
                                                                  .toString(),
                                                              textAlign:
                                                              TextAlign.left,
                                                              style:
                                                              GoogleFonts.lato(
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
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            flex: 1,
                                                            child:
                                                            Text(
                                                              "   ${state.ProductViewList[index].ItemQty}",
                                                              textAlign:
                                                              TextAlign.left,
                                                              style:
                                                              GoogleFonts.lato(
                                                                textStyle: TextStyle(
                                                                    color: colour.commonColor,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: objfun.FontLow,
                                                                    letterSpacing: 0.3),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 2,
                                                            child:
                                                            Text(
                                                              state.ProductViewList[index]
                                                                  .SalesRate
                                                                  .toString(),
                                                              textAlign:
                                                              TextAlign.left,
                                                              style:
                                                              GoogleFonts.lato(
                                                                textStyle: TextStyle(
                                                                    color: colour.commonColor,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: objfun.FontLow,
                                                                    letterSpacing: 0.3),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 3,
                                                            child:
                                                            Text(
                                                              state.ProductViewList[index]
                                                                  .TaxPercent
                                                                  .toString(),
                                                              textAlign:
                                                              TextAlign.left,
                                                              style:
                                                              GoogleFonts.lato(
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
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            flex: 4,
                                                            child:
                                                            Text(
                                                              "   ${state.ProductViewList[index].Amount}",
                                                              textAlign:
                                                              TextAlign.left,
                                                              style:
                                                              GoogleFonts.lato(
                                                                textStyle: TextStyle(
                                                                    color: colour.commonColor,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: objfun.FontLow,
                                                                    letterSpacing: 0.3),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child:
                                                            IconButton(
                                                              onPressed:
                                                                  () {
                                                                state.setState(() {
                                                                  showDialogProductAdd(index, 1);
                                                                });
                                                              },
                                                              icon:
                                                              const Icon(Icons.mode_edit_outline_outlined),
                                                              color:
                                                              colour.commonColor,
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child:
                                                            IconButton(
                                                              onPressed:
                                                                  () {
                                                                state.setState(() {
                                                                  state.ProductViewList.removeAt(index);
                                                                  state.Calculation();
                                                                });
                                                              },
                                                              icon:
                                                              const Icon(Icons.delete_outline_rounded),
                                                              color:
                                                              colour.commonColor,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 15,
                                                    )
                                                  ],
                                                )),
                                          );
                                        }))
                                    : Container(
                                    width: width - 40.0,
                                    height: height / 1.4,
                                    padding:
                                    const EdgeInsets.all(20),
                                    child: const Center(
                                      child: Text('No Record'),
                                    ))),
                              ),
                            ],
                          ))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 20.0, left: 15.0, right: 15.0),
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
                                  controller: state.txtCommodityType,
                                  enabled: state.isAllowed("txtCommodityType"),
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
                                    hintText: "Commodity Type",
                                    hintStyle:GoogleFonts.lato(
                                        textStyle: TextStyle(
                                            fontSize: objfun.FontMedium,
                                            fontWeight: FontWeight.bold,
                                            color: colour.commonColorLight)),
                                    suffixIcon: InkWell(
                                        child: Icon(
                                            (state.txtCommodityType
                                                .text.isNotEmpty)
                                                ? Icons.close
                                                : Icons.search_rounded,
                                            color:
                                            colour.commonColorred,
                                            size: 30.0),
                                        onTap: () {
                                          if (state.txtCommodityType.text ==
                                              "") {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const CommodityType(
                                                          Searchby: 1,
                                                          SearchId: 0)),
                                            ).then(
                                                    (dynamic value) async {
                                                  state.setState(() {
                                                    state.txtCommodityType.text =
                                                        objfun
                                                            .SelectedCommodityName;
                                                    objfun.SelectedCommodityName =
                                                    "";
                                                  });
                                                });
                                          } else {
                                            state.setState(() {
                                              state.txtCommodityType.text =
                                              "";
                                              objfun.SelectedCommodityName =
                                              "";
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
                      const SizedBox(
                        height: 3,
                      ),
                      SizedBox(
                        height: height * 0.06,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: TextField(
                                cursorColor: colour.commonColor,
                                controller: state.txtWeight,
                                enabled: state.isAllowed("txtWeight"),
                                autofocus: false,
                                showCursor: true,
                                decoration: InputDecoration(
                                  hintText: ('Weight'),
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
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      SizedBox(
                        height: height * 0.06,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: TextField(
                                cursorColor: colour.commonColor,
                                controller: state.txtQuantity,
                                enabled: state.isAllowed("txtQuantity"),
                                autofocus: false,
                                showCursor: true,
                                decoration: InputDecoration(
                                  hintText: ('Quantity'),
                                  hintStyle:GoogleFonts.lato(
                                      textStyle: TextStyle(
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
                                keyboardType: TextInputType.text,
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
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                     
                      Visibility(
                        visible: state.VisibleGC != true ,
                        child:  Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: TextField(
                                cursorColor: colour.commonColor,
                                controller: state.txtTruckSize,
                                enabled: state.isAllowed("txtTruckSize"),
                                autofocus: false,
                                showCursor: true,
                                decoration: InputDecoration(
                                  hintText: ('Truck Size'),
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
                                keyboardType: TextInputType.text,
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
                        ),),
                      const SizedBox(
                        height: 3,
                      ),
                      Visibility(
                          visible: state.VisibleGC ,
                          child:     Row(
                            children: [

                              Expanded(
                                  flex: 3,
                                  child: Text(
                                    "Truck Size ",
                                    style: GoogleFonts.lato(
                                        textStyle:TextStyle(
                                            fontSize: objfun.FontMedium,
                                            fontWeight: FontWeight.bold,
                                            color: colour.commonColor)),
                                    textAlign: TextAlign.center,
                                  )),
                              Expanded(
                                flex: 5,
                                child: Container(
                                  padding: const EdgeInsets.only(
                                    left: 10.0,
                                    right: 10.0,
                                  ),
                                  decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(
                                          10.0),
                                      color:
                                      colour.commonColorLight,
                                      border: Border.all()),
                                  child:
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                      isExpanded: true,
                                      value: state.dropdownValueTruckSize,
                                      onChanged: (String? value) {
                                        state.setState(() {
                                          state.dropdownValueTruckSize = value!;
                                          state.txtTruckSize.text = value?? "";
                                        });
                                      },
                                      style: GoogleFonts
                                          .lato(
                                        textStyle: TextStyle(
                                            color:
                                            colour.commonColor,
                                            fontWeight:
                                            FontWeight.bold,
                                            fontSize:
                                            objfun.FontMedium,
                                            letterSpacing: 0.3),
                                      ),
                                      items: SalesOrderAddState.TruckSizeList.map<
                                          DropdownMenuItem<
                                              String>>(
                                              (String value) {
                                            return DropdownMenuItem<
                                                String>(
                                              value: value,
                                              child: Text(
                                                value,
                                                style: GoogleFonts
                                                    .lato(
                                                  textStyle: TextStyle(
                                                      color: colour
                                                          .commonColor,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                      fontSize: objfun
                                                          .FontMedium,
                                                      letterSpacing:
                                                      0.3),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),),
                      const SizedBox(
                        height: 3,
                      ),
                      Visibility(
                          visible: state.VisibleAWBNo,
                          child: Column(
                            children: [
                              SizedBox(
                                height: height * 0.06,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: TextField(
                                        cursorColor: colour.commonColor,
                                        controller: state.txtAWBNo,
                                        enabled: state.isAllowed("txtAWBNo"),
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
                              const SizedBox(
                                height: 3,
                              ),
                            ],
                          )),
                      Visibility(
                          visible: state.VisibleBLCopy,
                          child: Column(
                            children: [
                              SizedBox(
                                height: height * 0.06,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: TextField(
                                        cursorColor: colour.commonColor,
                                        controller: state.txtBLCopy,
                                        enabled: state.isAllowed("txtBLCopy"),
                                        autofocus: false,
                                        showCursor: true,
                                        decoration: InputDecoration(
                                          hintText: ('BL Copy'),
                                          hintStyle:GoogleFonts.lato(
                                              textStyle: TextStyle(
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
                                        keyboardType:
                                        TextInputType.text,
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
                              const SizedBox(
                                height: 3,
                              ),
                            ],
                          )),

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
                                  controller: state.txtCargo,
                                  enabled: state.isAllowed("txtCargo"),
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
                                    hintText: "Cargo",
                                    hintStyle:GoogleFonts.lato(
                                        textStyle: TextStyle(
                                            fontSize: objfun.FontMedium,
                                            fontWeight: FontWeight.bold,
                                            color: colour.commonColorLight)),
                                    suffixIcon: InkWell(
                                        child: Icon(
                                            (state.txtCargo.text.isNotEmpty)
                                                ? Icons.close
                                                : Icons.search_rounded,
                                            color:
                                            colour.commonColorred,
                                            size: 30.0),
                                        onTap: () {
                                          if (state.txtCargo.text == "") {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const CargoStatus(
                                                          Searchby: 1,
                                                          SearchId: 0)),
                                            ).then(
                                                    (dynamic value) async {
                                                  state.setState(() {
                                                    state.txtCargo.text = objfun
                                                        .SelectedCargoName;
                                                    objfun.SelectedCargoName =
                                                    "";
                                                  });
                                                });
                                          } else {
                                            state.setState(() {
                                              state.txtCargo.text = "";
                                              objfun.SelectedCargoName =
                                              "";
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
                      const SizedBox(
                        height: 3,
                      ),
                      SizedBox(
                        height: height * 0.06,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: TextField(
                                cursorColor: colour.commonColor,
                                controller: state.txtPTWNo,
                                enabled: state.isAllowed("txtPTWNo"),
                                autofocus: false,
                                showCursor: true,
                                decoration: InputDecoration(
                                  hintText: ('PTW No'),
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
                                keyboardType: TextInputType.text,
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
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 20.0, left: 15.0, right: 15.0),
                  child: ListView(
                    children: <Widget>[
                      Visibility(
                          visible: state.VisibleLETA,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  const SizedBox(
                                    width: 7,
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: Text(
                                        "ETA ",
                                        style:GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                fontSize: objfun.FontMedium,
                                                color: colour.commonColor,
                                                fontWeight:
                                                FontWeight.bold)),
                                        textAlign: TextAlign.center,
                                      )),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Container(
                                      height: 50,
                                      padding: const EdgeInsets.only(
                                          left: 10.0, right: 5.0),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(
                                              10.0),
                                          color: state.checkBoxValueLETA ==
                                              true
                                              ? colour.commonColorLight
                                              : colour
                                              .commonColorDisabled,
                                          border: Border.all()),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            child: Text(
                                              DateFormat(
                                                  "dd-MM-yyyy HH:mm:ss")
                                                  .format(DateTime
                                                  .parse(state.dtpLETAdate
                                                  .toString())),
                                              style: GoogleFonts.lato(
                                                  textStyle:TextStyle(
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    fontSize:
                                                    objfun.FontMedium,
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
                                                decoration:
                                                BoxDecoration(
                                                  image:
                                                  DecorationImage(
                                                    image:
                                                    objfun.calendar,
                                                    //fit: BoxFit.fill,
                                                  ),
                                                ),
                                              ),
                                              onTap: () async {
                                                if (state.checkBoxValueLETA && state.isAllowed("chkLETA")) {
                                                  final date =
                                                  await showDatePicker(
                                                    context: context,
                                                    firstDate:
                                                    DateTime(2020),
                                                    initialDate:
                                                    DateTime.now(),
                                                    lastDate:
                                                    DateTime(2100),
                                                  );
                                                  if (date != null) {
                                                    var time =
                                                    await showTimePicker(
                                                        context:
                                                        context,
                                                        builder: (BuildContext context, Widget? child) {
                                                          return MediaQuery(
                                                            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                                            child: child!,
                                                          );
                                                        },
                                                        initialTime:
                                                        TimeOfDay
                                                            .now());
                                                    state.setState(() {
                                                      time ??= TimeOfDay.now();
                                                      state.dtpLETAdate =
                                                      '${state.combineDateAndTime(date, time!)}';
                                                    });
                                                  } else {
                                                    state.dtpLETAdate =
                                                        DateTime.now()
                                                            .toString();
                                                  }
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: Transform.scale(
                                        scale: 1.3,
                                        child:
                                        Checkbox(
                                          value: state.checkBoxValueLETA,
                                          side: const BorderSide(color: colour.commonColor),
                                          activeColor: colour.commonColorred,
                                          onChanged: state.isAllowed("chkLETA")
                                              ? (bool? value) {
                                            state.setState(() {
                                              state.checkBoxValueLETA = value!;
                                              if (!state.checkBoxValueLETA) {
                                                state.dtpLETAdate = DateFormat(
                                                  "yyyy-MM-dd HH:mm:ss",
                                                ).format(DateTime.now());
                                              }
                                            });
                                          }
                                              : null, // 👈 disable
                                        ),
                                      )),
                                ],
                              ),
                              const SizedBox(height: 5),
                            ],
                          )),
                      Visibility(
                          visible: state.VisibleLETB,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  const SizedBox(
                                    width: 7,
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: Text(
                                        "ETB ",
                                        style: GoogleFonts.lato(
                                            textStyle:TextStyle(
                                                fontSize: objfun.FontMedium,
                                                color: colour.commonColor,
                                                fontWeight:
                                                FontWeight.bold)),
                                        textAlign: TextAlign.center,
                                      )),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Container(
                                      height: 50,
                                      padding: const EdgeInsets.only(
                                          left: 10.0, right: 5.0),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(
                                              10.0),
                                          color: state.checkBoxValueLETB ==
                                              true
                                              ? colour.commonColorLight
                                              : colour
                                              .commonColorDisabled,
                                          border: Border.all()),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            child: Text(
                                              DateFormat(
                                                  "dd-MM-yyyy HH:mm:ss")
                                                  .format(DateTime
                                                  .parse(state.dtpLETBdate
                                                  .toString())),
                                              style: GoogleFonts.lato(
                                                  textStyle:TextStyle(
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    fontSize:
                                                    objfun.FontMedium,
                                                    color: state.checkBoxValueLETB ==
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
                                                decoration:
                                                BoxDecoration(
                                                  image:
                                                  DecorationImage(
                                                    image:
                                                    objfun.calendar,
                                                    //fit: BoxFit.fill,
                                                  ),
                                                ),
                                              ),
                                              onTap: () async {
                                                if (state.checkBoxValueLETB && state.isAllowed("chkLETB")) {
                                                  final date =
                                                  await showDatePicker(
                                                    context: context,
                                                    firstDate:
                                                    DateTime(2020),
                                                    initialDate:
                                                    DateTime.now(),
                                                    lastDate:
                                                    DateTime(2100),
                                                  );
                                                  if (date != null) {
                                                    var time =
                                                    await showTimePicker(
                                                        context:
                                                        context,
                                                        builder: (BuildContext context, Widget? child) {
                                                          return MediaQuery(
                                                            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                                            child: child!,
                                                          );
                                                        },
                                                        initialTime:
                                                        TimeOfDay
                                                            .now());
                                                    state.setState(() {
                                                      time ??= TimeOfDay.now();
                                                      state.dtpLETBdate =
                                                      '${state.combineDateAndTime(date, time!)}';
                                                    });
                                                  } else {
                                                    state.dtpLETBdate =
                                                        DateTime.now()
                                                            .toString();
                                                  }
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: Transform.scale(
                                        scale: 1.3,
                                        child:
                                        Checkbox(
                                          value: state.checkBoxValueLETB,
                                          side: const BorderSide(
                                              color:
                                              colour.commonColor),
                                          activeColor:
                                          colour.commonColorred,
                                          onChanged: state.isAllowed("chkLETB") ? (bool? value) {
                                            state.setState(() {
                                              state.checkBoxValueLETB =
                                              value!;
                                              if (state.checkBoxValueLETB ==
                                                  false) {
                                                state.dtpLETBdate = DateFormat(
                                                    "yyyy-MM-dd HH:mm:ss")
                                                    .format(
                                                    DateTime.now());
                                              }
                                            });

                                            // else{
                                            //   buildDropDownMenuItemsCash();
                                            // }
                                          } : null
                                        ),
                                      )),
                                ],
                              ),
                              const SizedBox(height: 5),
                            ],
                          )),
                      Visibility(
                        visible: state.VisibleLETD,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const SizedBox(
                                  width: 7,
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                      "ETD ",
                                      style:GoogleFonts.lato(
                                          textStyle: TextStyle(
                                              fontSize: objfun.FontMedium,
                                              color: colour.commonColor,
                                              fontWeight: FontWeight.bold)),
                                      textAlign: TextAlign.center,
                                    )),
                                const SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    height: 50,
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 5.0),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(10.0),
                                        color: state.checkBoxValueLETD == true
                                            ? colour.commonColorLight
                                            : colour
                                            .commonColorDisabled,
                                        border: Border.all()),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: Text(
                                            DateFormat(
                                                "dd-MM-yyyy HH:mm:ss")
                                                .format(DateTime.parse(
                                                state.dtpLETDdate
                                                    .toString())),
                                            style:GoogleFonts.lato(
                                                textStyle: TextStyle(
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  fontSize:
                                                  objfun.FontMedium,
                                                  color: state.checkBoxValueLETD ==
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
                                                  image:
                                                  objfun.calendar,
                                                  //fit: BoxFit.fill,
                                                ),
                                              ),
                                            ),
                                            onTap: () async {
                                              if (state.checkBoxValueLETD && state.isAllowed("chkLETD")) {
                                                final date =
                                                await showDatePicker(
                                                  context: context,
                                                  firstDate:
                                                  DateTime(2020),
                                                  initialDate:
                                                  DateTime.now(),
                                                  lastDate:
                                                  DateTime(2100),
                                                );
                                                if (date != null) {
                                                  var time =
                                                  await showTimePicker(
                                                      context:
                                                      context,
                                                      builder: (BuildContext context, Widget? child) {
                                                        return MediaQuery(
                                                          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                                          child: child!,
                                                        );
                                                      },
                                                      initialTime:
                                                      TimeOfDay
                                                          .now());
                                                  state.setState(() {
                                                    time ??= TimeOfDay.now();
                                                    state.dtpLETDdate =
                                                    '${state.combineDateAndTime(date, time!)}';
                                                  });
                                                } else {
                                                  state.dtpLETDdate =
                                                      DateTime.now()
                                                          .toString();
                                                }
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Transform.scale(
                                      scale: 1.3,
                                      child: Checkbox(
                                        value: state.checkBoxValueLETD,
                                        side: const BorderSide(
                                            color: colour.commonColor),
                                        activeColor:
                                        colour.commonColorred,
                                        onChanged: state.isAllowed("chkLETD") ? (bool? value) {
                                          state.setState(() {
                                            state.checkBoxValueLETD = value!;
                                            if (state.checkBoxValueLETD ==
                                                false) {
                                              state.dtpLETDdate = DateFormat(
                                                  "yyyy-MM-dd HH:mm:ss")
                                                  .format(
                                                  DateTime.now());
                                            }
                                          });

                                          // else{
                                          //   buildDropDownMenuItemsCash();
                                          // }
                                        } : null
                                      ),
                                    )),
                              ],
                            ),
                            const SizedBox(
                              height: 7,
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                          visible: state.VisibleLShippingAgent,
                          child: Column(
                            children: [
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
                                          controller: state.txtLAgentCompany,
                                          enabled: state.isAllowed("txtLAgentCompany"),
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
                                            hintText: "Shipping Agent",
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
                                                    (state.txtLAgentCompany
                                                        .text
                                                        .isNotEmpty)
                                                        ? Icons.close
                                                        : Icons
                                                        .search_rounded,
                                                    color: colour
                                                        .commonColorred,
                                                    size: 30.0),
                                                onTap: () {
                                                  if (state.txtLAgentCompany
                                                      .text ==
                                                      "") {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                          const AgentCompany(
                                                              Searchby:
                                                              1,
                                                              SearchId:
                                                              0)),
                                                    ).then((dynamic
                                                    value) async {
                                                      state.setState(() {
                                                        state.txtLAgentCompany
                                                            .text =
                                                            objfun
                                                                .SelectAgentCompanyList
                                                                .Name;
                                                        state.LAgentCompanyId =
                                                            objfun
                                                                .SelectAgentCompanyList
                                                                .Id;
                                                        objfun.SelectAgentCompanyList =
                                                            AgentCompanyModel
                                                                .Empty();
                                                      });
                                                    });
                                                  } else {
                                                    state.setState(() {
                                                      state.txtLAgentCompany
                                                          .text = "";
                                                      state.LAgentCompanyId =
                                                      0;
                                                      objfun.SelectAgentCompanyList =
                                                          AgentCompanyModel
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
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                            ],
                          )),
                      Visibility(
                          visible: state.VisibleLAgentName,
                          child: Column(
                            children: [
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
                                          controller: state.txtLAgentName,
                                          enabled: state.isAllowed("txtLAgentName"),
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
                                            hintText: "Agent Name",
                                            hintStyle: GoogleFonts.lato(
                                                textStyle:TextStyle(
                                                    fontSize:
                                                    objfun.FontMedium,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color: colour
                                                        .commonColorLight)),
                                            suffixIcon: InkWell(
                                                child: Icon(
                                                    (state.txtLAgentName.text
                                                        .isNotEmpty)
                                                        ? Icons.close
                                                        : Icons
                                                        .search_rounded,
                                                    color: colour
                                                        .commonColorred,
                                                    size: 30.0),
                                                onTap: () {
                                                  if (state.txtLAgentName
                                                      .text ==
                                                      "" &&
                                                      state.txtLAgentCompany
                                                          .text !=
                                                          "" && state.LAgentCompanyId != 0) {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) => Agent(
                                                              Searchby:
                                                              1,
                                                              SearchId:
                                                              0,
                                                              AgentCompanyId:
                                                              state.LAgentCompanyId)),
                                                    ).then((dynamic
                                                    value) async {
                                                      state.setState(() {
                                                        state.txtLAgentName
                                                            .text =
                                                            objfun
                                                                .SelectAgentAllList
                                                                .AgentName;
                                                        state.LAgentId = objfun
                                                            .SelectAgentAllList
                                                            .Id;
                                                        objfun.SelectAgentAllList =
                                                            AgentModel
                                                                .Empty();
                                                      });
                                                    });
                                                  } else {
                                                    state.setState(() {
                                                      state.txtLAgentName
                                                          .text = "";
                                                      state.LAgentId = 0;
                                                      objfun.SelectAgentAllList =
                                                          AgentModel
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
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                            ],
                          )),
                      Visibility(
                          visible: state.VisibleLScn,
                          child: SizedBox(
                            height: height * 0.06,
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: TextField(
                                    cursorColor: colour.commonColor,
                                    controller: state.txtLSCN,
                                    enabled: state.isAllowed("txtLSCN"),
                                    autofocus: false,
                                    showCursor: true,
                                    decoration: InputDecoration(
                                      hintText: ('SCN'),
                                      hintStyle: GoogleFonts.lato(
                                          textStyle:TextStyle(
                                              fontSize: objfun.FontMedium,
                                              fontWeight: FontWeight.bold,
                                              color:
                                              colour.commonColorLight)),
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
                                            color:
                                            colour.commonColorred),
                                      ),
                                      contentPadding: const EdgeInsets.only(
                                          left: 10,
                                          right: 20,
                                          top: 10.0),
                                    ),
                                    textInputAction:
                                    TextInputAction.done,
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
                          )),
                      Visibility(
                          visible: state.VisibleFlightTime,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  const SizedBox(
                                    width: 7,
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: Text(
                                        "Flight Time ",
                                        style:GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                fontSize: objfun.FontMedium,
                                                color: colour.commonColor,
                                                fontWeight:
                                                FontWeight.bold)),
                                        textAlign: TextAlign.center,
                                      )),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Container(
                                      height: 50,
                                      padding: const EdgeInsets.only(
                                          left: 10.0, right: 5.0),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(
                                              10.0),
                                          color: state.checkBoxValueFlightTime ==
                                              true
                                              ? colour.commonColorLight
                                              : colour
                                              .commonColorDisabled,
                                          border: Border.all()),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            child: Text(
                                              DateFormat(
                                                  "dd-MM-yyyy HH:mm:ss")
                                                  .format(DateTime
                                                  .parse(state.dtpFlightTimedate
                                                  .toString())),
                                              style: GoogleFonts.lato(
                                                  textStyle:TextStyle(
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    fontSize:
                                                    objfun.FontMedium,
                                                    color: state.checkBoxValueFlightTime ==
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
                                                decoration:
                                                BoxDecoration(
                                                  image:
                                                  DecorationImage(
                                                    image:
                                                    objfun.calendar,
                                                    //fit: BoxFit.fill,
                                                  ),
                                                ),
                                              ),
                                              onTap: () async {
                                                if (state.checkBoxValueFlightTime && state.isAllowed("chkFlightTime")) {
                                                  final date =
                                                  await showDatePicker(
                                                    context: context,
                                                    firstDate:
                                                    DateTime(2020),
                                                    initialDate:
                                                    DateTime.now(),
                                                    lastDate:
                                                    DateTime(2100),
                                                  );
                                                  if (date != null) {
                                                    var time =
                                                    await showTimePicker(
                                                        context:
                                                        context,
                                                        builder: (BuildContext context, Widget? child) {
                                                          return MediaQuery(
                                                            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                                            child: child!,
                                                          );
                                                        },
                                                        initialTime:
                                                        TimeOfDay
                                                            .now());
                                                    state.setState(() {
                                                      time ??= TimeOfDay.now();
                                                      state.dtpFlightTimedate =
                                                      '${state.combineDateAndTime(date, time!)}';
                                                    });
                                                  } else {
                                                    state.dtpFlightTimedate =
                                                        DateTime.now()
                                                            .toString();
                                                  }
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: Transform.scale(
                                        scale: 1.3,
                                        child: Checkbox(
                                          value: state.checkBoxValueFlightTime,
                                          side: const BorderSide(
                                              color:
                                              colour.commonColor),
                                          activeColor:
                                          colour.commonColorred,
                                          onChanged: state.isAllowed("chkFlightTime") ? (bool? value) {
                                            state.setState(() {
                                              state.checkBoxValueFlightTime =
                                              value!;
                                              if (state.checkBoxValueFlightTime ==
                                                  false) {
                                                state.dtpFlightTimedate = DateFormat(
                                                    "yyyy-MM-dd HH:mm:ss")
                                                    .format(
                                                    DateTime.now());
                                              }
                                            });

                                            // else{
                                            //   buildDropDownMenuItemsCash();
                                            // }
                                          } : null
                                        ),
                                      )),
                                ],
                              ),
                              const SizedBox(height: 5),
                            ],
                          )),
                      Visibility(
                          visible: state.VisibleLoadingVessel,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 3,
                              ),
                              SizedBox(
                                height: height * 0.06,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: TextField(
                                        cursorColor: colour.commonColor,
                                        controller: state.txtLoadingVessel,
                                        enabled: state.isAllowed("txtLoadingVessel"),
                                        autofocus: false,
                                        showCursor: true,
                                        decoration: InputDecoration(
                                          hintText:
                                          ('Loading Vessel Name'),
                                          hintStyle:GoogleFonts.lato(
                                              textStyle: TextStyle(
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
                                        keyboardType:
                                        TextInputType.text,
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
                            ],
                          )),
                      const SizedBox(height: 5),
                      Visibility(
                          visible: state.VisibleLPort,
                          child: Column(
                            children: [
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
                                          controller: state.txtLPort,
                                          enabled: state.isAllowed("txtLPort"),
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
                                            hintText: "Port",
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
                                                    (state.txtLPort.text
                                                        .isNotEmpty)
                                                        ? Icons.close
                                                        : Icons
                                                        .search_rounded,
                                                    color: colour
                                                        .commonColorred,
                                                    size: 30.0),
                                                onTap: () {
                                                  state.setState(() {
                                                    if (state.txtLPort.text ==
                                                        "") {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => const Port(
                                                                Searchby:
                                                                1,
                                                                SearchId:
                                                                0)),
                                                      ).then((dynamic
                                                      value) async {
                                                        state.setState(() {
                                                          state.txtLPort.text =
                                                              objfun
                                                                  .SelectedPortName;
                                                          objfun.SelectedPortName =
                                                          "";
                                                        });
                                                      });
                                                    } else {
                                                      state.setState(() {
                                                        state.txtLPort.text =
                                                        "";
                                                        objfun.SelectedPortName =
                                                        "";
                                                      });
                                                    }
                                                  });
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
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                            ],
                          )),
                      Visibility(
                          visible: state.VisibleLVesselType,
                          child: SizedBox(
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
                                    height: objfun.SizeConfig
                                        .safeBlockVertical *
                                        7,
                                    alignment: Alignment.topCenter,
                                    padding: const EdgeInsets.only(
                                        bottom: 5),
                                    child: TextField(
                                      textCapitalization:
                                      TextCapitalization.characters,
                                      controller: state.txtLVesselType,
                                      enabled: state.isAllowed("txtLVesselType"),
                                      textInputAction:
                                      TextInputAction.done,
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
                                        hintText: "Vessel Type",
                                        hintStyle:GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                fontSize: objfun.FontMedium,
                                                fontWeight: FontWeight.bold,
                                                color: colour
                                                    .commonColorLight)),
                                        suffixIcon: InkWell(
                                            child: Icon(
                                                (state.txtLVesselType.text
                                                    .isNotEmpty)
                                                    ? Icons.close
                                                    : Icons
                                                    .search_rounded,
                                                color: colour
                                                    .commonColorred,
                                                size: 30.0),
                                            onTap: () {
                                              if (state.txtLVesselType.text ==
                                                  "") {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                      const VesselType(
                                                          Searchby:
                                                          1,
                                                          SearchId:
                                                          0)),
                                                ).then((dynamic
                                                value) async {
                                                  state.setState(() {
                                                    state.txtLVesselType
                                                        .text =
                                                        objfun
                                                            .SelectedVesselTypeName;
                                                    objfun.SelectedVesselTypeName =
                                                    "";
                                                  });
                                                });
                                              } else {
                                                state.setState(() {
                                                  state.txtLVesselType.text =
                                                  "";
                                                  objfun.SelectedVesselTypeName =
                                                  "";
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
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 20.0, left: 15.0, right: 15.0),
                  child: ListView(
                    children: <Widget>[
                      Visibility(
                          visible: state.VisibleOETA,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  const SizedBox(
                                    width: 7,
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: Text(
                                        "ETA ",
                                        style: GoogleFonts.lato(
                                            textStyle:TextStyle(
                                                fontSize: objfun.FontMedium,
                                                color: colour.commonColor,
                                                fontWeight:
                                                FontWeight.bold)),
                                        textAlign: TextAlign.center,
                                      )),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Container(
                                      height: 50,
                                      padding: const EdgeInsets.only(
                                          left: 10.0, right: 5.0),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(
                                              10.0),
                                          color: state.checkBoxValueOETA ==
                                              true
                                              ? colour.commonColorLight
                                              : colour
                                              .commonColorDisabled,
                                          border: Border.all()),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            child: Text(
                                              DateFormat(
                                                  "dd-MM-yyyy HH:mm:ss")
                                                  .format(DateTime
                                                  .parse(state.dtpOETAdate
                                                  .toString())),
                                              style: GoogleFonts.lato(
                                                  textStyle:TextStyle(
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    fontSize:
                                                    objfun.FontMedium,
                                                    color: state.checkBoxValueOETA ==
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
                                                decoration:
                                                BoxDecoration(
                                                  image:
                                                  DecorationImage(
                                                    image:
                                                    objfun.calendar,
                                                    //fit: BoxFit.fill,
                                                  ),
                                                ),
                                              ),
                                              onTap: () async {
                                                if (state.checkBoxValueOETA && state.isAllowed("chkOETA")) {
                                                  final date =
                                                  await showDatePicker(
                                                    context: context,
                                                    firstDate:
                                                    DateTime(2020),
                                                    initialDate:
                                                    DateTime.now(),
                                                    lastDate:
                                                    DateTime(2100),
                                                  );
                                                  if (date != null) {
                                                    var time =
                                                    await showTimePicker(
                                                        context:
                                                        context,
                                                        builder: (BuildContext context, Widget? child) {
                                                          return MediaQuery(
                                                            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                                            child: child!,
                                                          );
                                                        },
                                                        initialTime:
                                                        TimeOfDay
                                                            .now());
                                                    state.setState(() {
                                                      time ??= TimeOfDay.now();
                                                      state.dtpOETAdate =
                                                      '${state.combineDateAndTime(date, time!)}';
                                                    });
                                                  } else {
                                                    state.dtpOETAdate =
                                                        DateTime.now()
                                                            .toString();
                                                  }
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: Transform.scale(
                                        scale: 1.3,
                                        child: Checkbox(
                                          value: state.checkBoxValueOETA,
                                          side: const BorderSide(
                                              color:
                                              colour.commonColor),
                                          activeColor:
                                          colour.commonColorred,
                                          onChanged:state.isAllowed("chkOETA") ? (bool? value) {
                                            state.setState(() {
                                              state.checkBoxValueOETA =
                                              value!;
                                              if (state.checkBoxValueOETA ==
                                                  false) {
                                                state.dtpOETAdate = DateFormat(
                                                    "yyyy-MM-dd HH:mm:ss")
                                                    .format(
                                                    DateTime.now());
                                              }
                                            });

                                            // else{
                                            //   buildDropDownMenuItemsCash();
                                            // }
                                          } : null
                                        ),
                                      )),
                                ],
                              ),
                              const SizedBox(height: 5),
                            ],
                          )),
                      Visibility(
                          visible: state.VisibleOETB,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  const SizedBox(
                                    width: 7,
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: Text(
                                        "ETB ",
                                        style: GoogleFonts.lato(
                                            textStyle:TextStyle(
                                                fontSize: objfun.FontMedium,
                                                color: colour.commonColor,
                                                fontWeight:
                                                FontWeight.bold)),
                                        textAlign: TextAlign.center,
                                      )),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Container(
                                      height: 50,
                                      padding: const EdgeInsets.only(
                                          left: 10.0, right: 5.0),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(
                                              10.0),
                                          color: state.checkBoxValueOETB ==
                                              true
                                              ? colour.commonColorLight
                                              : colour
                                              .commonColorDisabled,
                                          border: Border.all()),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            child: Text(
                                              DateFormat(
                                                  "dd-MM-yyyy HH:mm:ss")
                                                  .format(DateTime
                                                  .parse(state.dtpOETBdate
                                                  .toString())),
                                              style: GoogleFonts.lato(
                                                  textStyle:TextStyle(
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    fontSize:
                                                    objfun.FontMedium,
                                                    color: state.checkBoxValueOETB ==
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
                                                decoration:
                                                BoxDecoration(
                                                  image:
                                                  DecorationImage(
                                                    image:
                                                    objfun.calendar,
                                                    //fit: BoxFit.fill,
                                                  ),
                                                ),
                                              ),
                                              onTap: () async {
                                                if (state.checkBoxValueOETB  && state.isAllowed("chkLETB")) {
                                                  final date =
                                                  await showDatePicker(
                                                    context: context,

                                                    firstDate:
                                                    DateTime(2020),
                                                    initialDate:
                                                    DateTime.now(),
                                                    lastDate:
                                                    DateTime(2100),
                                                  );
                                                  if (date != null) {
                                                    var time =
                                                    await showTimePicker(
                                                        context:
                                                        context,
                                                        builder: (BuildContext context, Widget? child) {
                                                          return MediaQuery(
                                                            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                                            child: child!,
                                                          );
                                                        },
                                                        initialTime:
                                                        TimeOfDay
                                                            .now());
                                                    state.setState(() {
                                                      time ??= TimeOfDay.now();
                                                      state.dtpOETBdate =
                                                      '${state.combineDateAndTime(date, time!)}';
                                                    });
                                                  } else {
                                                    state.dtpOETBdate =
                                                        DateTime.now()
                                                            .toString();
                                                  }
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: Transform.scale(
                                        scale: 1.3,
                                        child: Checkbox(
                                          value: state.checkBoxValueOETB,
                                          side: const BorderSide(
                                              color:
                                              colour.commonColor),
                                          activeColor:
                                          colour.commonColorred,
                                          onChanged: state.isAllowed("chkLETB") ? (bool? value) {
                                            state.setState(() {
                                              state.checkBoxValueOETB =
                                              value!;
                                              if (state.checkBoxValueOETB ==
                                                  false) {
                                                state.dtpOETBdate = DateFormat(
                                                    "yyyy-MM-dd HH:mm:ss")
                                                    .format(
                                                    DateTime.now());
                                              }
                                            });

                                            // else{
                                            //   buildDropDownMenuItemsCash();
                                            // }
                                          } : null
                                        ),
                                      )),
                                ],
                              ),
                              const SizedBox(height: 5),
                            ],
                          )),
                      Visibility(
                        visible: state.VisibleOETD,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const SizedBox(
                                  width: 7,
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                      "ETD ",
                                      style: GoogleFonts.lato(
                                          textStyle:TextStyle(
                                              fontSize: objfun.FontMedium,
                                              color: colour.commonColor,
                                              fontWeight: FontWeight.bold)),
                                      textAlign: TextAlign.center,
                                    )),
                                const SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    height: 50,
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 5.0),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(10.0),
                                        color: state.checkBoxValueOETD == true
                                            ? colour.commonColorLight
                                            : colour
                                            .commonColorDisabled,
                                        border: Border.all()),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: Text(
                                            DateFormat(
                                                "dd-MM-yyyy HH:mm:ss")
                                                .format(DateTime.parse(
                                                state.dtpOETDdate
                                                    .toString())),
                                            style: GoogleFonts.lato(
                                                textStyle:TextStyle(
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  fontSize:
                                                  objfun.FontMedium,
                                                  color: state.checkBoxValueOETD ==
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
                                                  image:
                                                  objfun.calendar,
                                                  //fit: BoxFit.fill,
                                                ),
                                              ),
                                            ),
                                            onTap: () async {
                                              if (state.checkBoxValueOETD  && state.isAllowed("chkLETD")) {
                                                final date =
                                                await showDatePicker(
                                                  context: context,
                                                  firstDate:
                                                  DateTime(2020),
                                                  initialDate:
                                                  DateTime.now(),
                                                  lastDate:
                                                  DateTime(2100),
                                                );
                                                if (date != null) {
                                                  var time =
                                                  await showTimePicker(
                                                      context:
                                                      context,
                                                      builder: (BuildContext context, Widget? child) {
                                                        return MediaQuery(
                                                          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                                          child: child!,
                                                        );
                                                      },
                                                      initialTime:
                                                      TimeOfDay
                                                          .now());
                                                  state.setState(() {
                                                    time ??= TimeOfDay.now();
                                                    state.dtpOETDdate =
                                                    '${state.combineDateAndTime(date, time!)}';
                                                  });
                                                } else {
                                                  state.dtpOETDdate =
                                                      DateTime.now()
                                                          .toString();
                                                }
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Transform.scale(
                                      scale: 1.3,
                                      child: Checkbox(
                                        value: state.checkBoxValueOETD,
                                        side: const BorderSide(
                                            color: colour.commonColor),
                                        activeColor:
                                        colour.commonColorred,
                                        onChanged: state.isAllowed("chkLETD") ? (bool? value) {
                                          state.setState(() {
                                            state.checkBoxValueOETD = value!;
                                            if (state.checkBoxValueOETD ==
                                                false) {
                                              state.dtpOETDdate = DateFormat(
                                                  "yyyy-MM-dd HH:mm:ss")
                                                  .format(
                                                  DateTime.now());
                                            }
                                          });

                                          // else{
                                          //   buildDropDownMenuItemsCash();
                                          // }
                                        } : null
                                      ),
                                    )),
                              ],
                            ),
                            const SizedBox(
                              height: 7,
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                          visible: state.VisibleOShippingAgent,
                          child: Column(
                            children: [
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
                                          controller: state.txtOAgentCompany,
                                          enabled: state.isAllowed("txtOAgentCompany"),
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
                                            hintText: "Shipping Agent",
                                            hintStyle: GoogleFonts.lato(
                                                textStyle:TextStyle(
                                                    fontSize:
                                                    objfun.FontMedium,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color: colour
                                                        .commonColorLight)),
                                            suffixIcon: InkWell(
                                                child: Icon(
                                                    (state.txtOAgentCompany
                                                        .text
                                                        .isNotEmpty)
                                                        ? Icons.close
                                                        : Icons
                                                        .search_rounded,
                                                    color: colour
                                                        .commonColorred,
                                                    size: 30.0),
                                                onTap: () {
                                                  if (state.txtOAgentCompany
                                                      .text ==
                                                      "") {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                          const AgentCompany(
                                                              Searchby:
                                                              1,
                                                              SearchId:
                                                              0)),
                                                    ).then((dynamic
                                                    value) async {
                                                      state.setState(() {
                                                        state.txtOAgentCompany
                                                            .text =
                                                            objfun
                                                                .SelectAgentCompanyList
                                                                .Name;
                                                        state.OAgentCompanyId =
                                                            objfun
                                                                .SelectAgentCompanyList
                                                                .Id;
                                                        objfun.SelectAgentCompanyList =
                                                            AgentCompanyModel
                                                                .Empty();
                                                      });
                                                    });
                                                  } else {
                                                    state.setState(() {
                                                      state.txtOAgentCompany
                                                          .text = "";
                                                      state.OAgentCompanyId =
                                                      0;
                                                      objfun.SelectAgentCompanyList =
                                                          AgentCompanyModel
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
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                            ],
                          )),
                      Visibility(
                          visible: state.VisibleOAgentName,
                          child: Column(
                            children: [
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
                                          controller: state.txtOAgentName,
                                          enabled: state.isAllowed("txtOAgentName"),
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
                                            hintText: "Agent Name",
                                            hintStyle: GoogleFonts.lato(
                                                textStyle:TextStyle(
                                                    fontSize:
                                                    objfun.FontMedium,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color: colour
                                                        .commonColorLight)),
                                            suffixIcon: InkWell(
                                                child: Icon(
                                                    (state.txtOAgentName.text
                                                        .isNotEmpty)
                                                        ? Icons.close
                                                        : Icons
                                                        .search_rounded,
                                                    color: colour
                                                        .commonColorred,
                                                    size: 30.0),
                                                onTap: () {
                                                  if (state.txtOAgentName
                                                      .text ==
                                                      "" &&
                                                      state.txtOAgentCompany
                                                          .text !=
                                                          "" && state.OAgentCompanyId != 0) {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) => Agent(
                                                              Searchby:
                                                              1,
                                                              SearchId:
                                                              0,
                                                              AgentCompanyId:
                                                              state.OAgentCompanyId)),
                                                    ).then((dynamic
                                                    value) async {
                                                      state.setState(() {
                                                        state.txtOAgentName
                                                            .text =
                                                            objfun
                                                                .SelectAgentAllList
                                                                .AgentName;
                                                        state.OAgentId = objfun
                                                            .SelectAgentAllList
                                                            .Id;
                                                        objfun.SelectAgentAllList =
                                                            AgentModel
                                                                .Empty();
                                                      });
                                                    });
                                                  } else {
                                                    state.setState(() {
                                                      state.txtOAgentName
                                                          .text = "";
                                                      state.OAgentId = 0;
                                                      objfun.SelectAgentAllList =
                                                          AgentModel
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
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                            ],
                          )),
                      Visibility(
                          visible: state.VisibleOScn,
                          child: SizedBox(
                            height: height * 0.06,
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: TextField(
                                    cursorColor: colour.commonColor,
                                    controller: state.txtOSCN,
                                    enabled: state.isAllowed("txtOSCN"),
                                    autofocus: false,
                                    showCursor: true,
                                    decoration: InputDecoration(
                                      hintText: ('SCN'),
                                      hintStyle: GoogleFonts.lato(
                                          textStyle:TextStyle(
                                              fontSize: objfun.FontMedium,
                                              fontWeight: FontWeight.bold,
                                              color:
                                              colour.commonColorLight)),
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
                                            color:
                                            colour.commonColorred),
                                      ),
                                      contentPadding: const EdgeInsets.only(
                                          left: 10,
                                          right: 20,
                                          top: 10.0),
                                    ),
                                    textInputAction:
                                    TextInputAction.done,
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
                          )),
                      Visibility(
                          visible: state.VisibleOffVessel,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 3,
                              ),
                              SizedBox(
                                height: height * 0.06,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: TextField(
                                        cursorColor: colour.commonColor,
                                        controller: state.txtOffVessel,
                                        enabled: state.isAllowed("txtOffVessel"),
                                        autofocus: false,
                                        showCursor: true,
                                        decoration: InputDecoration(
                                          hintText: ('Off Vessel Name'),
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
                            ],
                          )),
                      const SizedBox(height: 5),
                      Visibility(
                          visible: state.VisibleOPort,
                          child: Column(
                            children: [
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
                                          controller: state.txtOPort,
                                          enabled: state.isAllowed("txtOPort"),
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
                                            hintText: "Port",
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
                                                    (state.txtOPort.text
                                                        .isNotEmpty)
                                                        ? Icons.close
                                                        : Icons
                                                        .search_rounded,
                                                    color: colour
                                                        .commonColorred,
                                                    size: 30.0),
                                                onTap: () {
                                                  state.setState(() {
                                                    if (state.txtOPort.text ==
                                                        "") {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => const Port(
                                                                Searchby:
                                                                1,
                                                                SearchId:
                                                                0)),
                                                      ).then((dynamic
                                                      value) async {
                                                        state.setState(() {
                                                          state.txtOPort.text =
                                                              objfun
                                                                  .SelectedPortName;
                                                          objfun.SelectedPortName =
                                                          "";
                                                        });
                                                      });
                                                    } else {
                                                      state.setState(() {
                                                        state.txtOPort.text =
                                                        "";
                                                        objfun.SelectedPortName =
                                                        "";
                                                      });
                                                    }
                                                  });
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
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                            ],
                          )),
                      Visibility(
                          visible: state.VisibleOVesselType,
                          child: SizedBox(
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
                                    height: objfun.SizeConfig
                                        .safeBlockVertical *
                                        7,
                                    alignment: Alignment.topCenter,
                                    padding: const EdgeInsets.only(
                                        bottom: 5),
                                    child: TextField(
                                      textCapitalization:
                                      TextCapitalization.characters,
                                      controller: state.txtOVesselType,
                                      enabled: state.isAllowed("txtOVesselType"),
                                      textInputAction:
                                      TextInputAction.done,
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
                                        hintText: "Vessel Type",
                                        hintStyle:GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                fontSize: objfun.FontMedium,
                                                fontWeight: FontWeight.bold,
                                                color: colour
                                                    .commonColorLight)),
                                        suffixIcon: InkWell(
                                            child: Icon(
                                                (state.txtOVesselType.text
                                                    .isNotEmpty)
                                                    ? Icons.close
                                                    : Icons
                                                    .search_rounded,
                                                color: colour
                                                    .commonColorred,
                                                size: 30.0),
                                            onTap: () {
                                              if (state.txtOVesselType.text ==
                                                  "") {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                      const VesselType(
                                                          Searchby:
                                                          1,
                                                          SearchId:
                                                          0)),
                                                ).then((dynamic
                                                value) async {
                                                  state.setState(() {
                                                    state.txtOVesselType
                                                        .text =
                                                        objfun
                                                            .SelectedVesselTypeName;
                                                    objfun.SelectedVesselTypeName =
                                                    "";
                                                  });
                                                });
                                              } else {
                                                state.setState(() {
                                                  state.txtOVesselType.text =
                                                  "";
                                                  objfun.SelectedVesselTypeName =
                                                  "";
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
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 20.0, left: 15.0, right: 15.0),
                  child: ListView(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                              flex: 2,
                              child: Text(
                                "PickUp Date",
                                style: GoogleFonts.lato(
                                    textStyle:TextStyle(
                                        fontSize: objfun.FontMedium,
                                        color: colour.commonColor,
                                        fontWeight: FontWeight.bold)),
                                textAlign: TextAlign.left,
                              )),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            flex: 4,
                            child: Container(
                              height: 50,
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 5.0),
                              decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(10.0),
                                  color: state.checkBoxValuePickUp == true
                                      ? colour.commonColorLight
                                      : colour.commonColorDisabled,
                                  border: Border.all()),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      DateFormat("dd-MM-yyyy HH:mm:ss")
                                          .format(DateTime.parse(
                                          state.dtpPickUpdate
                                              .toString())),
                                      style:GoogleFonts.lato(
                                          textStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: objfun.FontLow,
                                            color: state.checkBoxValuePickUp ==
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
                                        if (state.checkBoxValuePickUp  && state.isAllowed("chkPickup")) {
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
                                                builder: (BuildContext context, Widget? child) {
                                                  return MediaQuery(
                                                    data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                                    child: child!,
                                                  );
                                                },
                                                initialTime:
                                                TimeOfDay
                                                    .now());
                                            state.setState(() {
                                              time ??= TimeOfDay.now();
                                              state.dtpPickUpdate =
                                              '${state.combineDateAndTime(date, time!)}';
                                            });
                                          } else {
                                            state.dtpPickUpdate =
                                                DateTime.now()
                                                    .toString();
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                              flex: 1,
                              child: Transform.scale(
                                scale: 1.3,
                                child: Checkbox(
                                  value: state.checkBoxValuePickUp,
                                  side: const BorderSide(
                                      color: colour.commonColor),
                                  activeColor: colour.commonColorred,
                                  onChanged: state.isAllowed("chkPickup") ? (bool? value) {
                                    state.setState(() {
                                      state.checkBoxValuePickUp = value!;
                                      if (state.checkBoxValuePickUp ==
                                          false) {
                                        state.dtpPickUpdate = DateFormat(
                                            "yyyy-MM-dd HH:mm:ss")
                                            .format(DateTime.now());
                                      }
                                    });

                                    // else{
                                    //   buildDropDownMenuItemsCash();
                                    // }
                                  } : null,
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                              flex: 2,
                              child: Text(
                                "Delivery Date",
                                style:GoogleFonts.lato(
                                    textStyle: TextStyle(
                                        fontSize: objfun.FontMedium,
                                        color: colour.commonColor,
                                        fontWeight: FontWeight.bold)),
                                textAlign: TextAlign.left,
                              )),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            flex: 4,
                            child: Container(
                              height: 50,
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 5.0),
                              decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(10.0),
                                  color: state.checkBoxValueDelivery == true
                                      ? colour.commonColorLight
                                      : colour.commonColorDisabled,
                                  border: Border.all()),
                              child: Row(
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
                                      style: GoogleFonts.lato(
                                          textStyle:TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: objfun.FontLow,
                                            color: state.checkBoxValueDelivery ==
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
                                        if (state.checkBoxValueDelivery  && state.isAllowed("chkDelivery")) {
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
                                                builder: (BuildContext context, Widget? child) {
                                                  return MediaQuery(
                                                    data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                                    child: child!,
                                                  );
                                                },
                                                initialTime:
                                                TimeOfDay
                                                    .now());
                                            state.setState(() {
                                              time ??= TimeOfDay.now();
                                              state.dtpDeliverydate =
                                              '${state.combineDateAndTime(date, time!)}';
                                            });
                                          } else {
                                            state.dtpDeliverydate =
                                                DateTime.now()
                                                    .toString();
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                              flex: 1,
                              child: Transform.scale(
                                scale: 1.3,
                                child: Checkbox(
                                  value: state.checkBoxValueDelivery,
                                  side: const BorderSide(
                                      color: colour.commonColor),
                                  activeColor: colour.commonColorred,
                                  onChanged: state.isAllowed("chkDelivery") ? (bool? value) {
                                    state.setState(() {
                                      state.checkBoxValueDelivery = value!;
                                      if (state.checkBoxValueDelivery ==
                                          false) {
                                        state.dtpDeliverydate = DateFormat(
                                            "yyyy-MM-dd HH:mm:ss")
                                            .format(DateTime.now());
                                      }
                                    });

                                    // else{
                                    //   buildDropDownMenuItemsCash();
                                    // }
                                  } : null,
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                              flex: 2,
                              child: Text(
                                "WareHouse Entry Date",
                                style: GoogleFonts.lato(
                                    textStyle:TextStyle(
                                        fontSize: objfun.FontMedium,
                                        color: colour.commonColor,
                                        fontWeight: FontWeight.bold)),
                                textAlign: TextAlign.left,
                              )),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            flex: 4,
                            child: Container(
                              height: 50,
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 5.0),
                              decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(10.0),
                                  color: state.checkBoxValueWHEntry == true
                                      ? colour.commonColorLight
                                      : colour.commonColorDisabled,
                                  border: Border.all()),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      DateFormat("dd-MM-yyyy HH:mm:ss")
                                          .format(DateTime.parse(
                                          state.dtpWHEntrydate
                                              .toString())),
                                      style: GoogleFonts.lato(
                                          textStyle:TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: objfun.FontLow,
                                            color: state.checkBoxValueWHEntry ==
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
                                        if (state.checkBoxValueWHEntry  && state.isAllowed("chkWareHouseEntry")) {
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
                                                builder: (BuildContext context, Widget? child) {
                                                  return MediaQuery(
                                                    data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                                    child: child!,
                                                  );
                                                },
                                                initialTime:
                                                TimeOfDay
                                                    .now());
                                            state.setState(() {
                                              time ??= TimeOfDay.now();
                                              state.dtpWHEntrydate =
                                              '${state.combineDateAndTime(date, time!)}';
                                            });
                                          } else {
                                            state.dtpWHEntrydate =
                                                DateTime.now()
                                                    .toString();
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                              flex: 1,
                              child: Transform.scale(
                                scale: 1.3,
                                child: Checkbox(
                                  value: state.checkBoxValueWHEntry,
                                  side: const BorderSide(
                                      color: colour.commonColor),
                                  activeColor: colour.commonColorred,
                                  onChanged: state.isAllowed("chkWareHouseEntry") ? (bool? value) {
                                    state.setState(() {
                                      state.checkBoxValueWHEntry = value!;
                                      if (state.checkBoxValueWHEntry ==
                                          false) {
                                        state.dtpWHEntrydate = DateFormat(
                                            "yyyy-MM-dd HH:mm:ss")
                                            .format(DateTime.now());
                                      }
                                    });

                                    // else{
                                    //   buildDropDownMenuItemsCash();
                                    // }
                                  } : null,
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                              flex: 2,
                              child: Text(
                                "Warehouse Exit Date",
                                style: GoogleFonts.lato(
                                    textStyle:TextStyle(
                                        fontSize: objfun.FontMedium,
                                        color: colour.commonColor,
                                        fontWeight: FontWeight.bold)),
                                textAlign: TextAlign.left,
                              )),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            flex: 4,
                            child: Container(
                              height: 50,
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 5.0),
                              decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(10.0),
                                  color: state.checkBoxValueWHExit == true
                                      ? colour.commonColorLight
                                      : colour.commonColorDisabled,
                                  border: Border.all()),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      DateFormat("dd-MM-yyyy HH:mm:ss")
                                          .format(DateTime.parse(
                                          state.dtpWHExitdate
                                              .toString())),
                                      style:GoogleFonts.lato(
                                          textStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: objfun.FontLow,
                                            color: state.checkBoxValueWHExit ==
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
                                        if (state.checkBoxValueWHExit && state.isAllowed("chkWareHouseExit")) {
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
                                                builder: (BuildContext context, Widget? child) {
                                                  return MediaQuery(
                                                    data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                                    child: child!,
                                                  );
                                                },
                                                initialTime:
                                                TimeOfDay
                                                    .now());
                                            state.setState(() {
                                              time ??= TimeOfDay.now();
                                              state.dtpWHExitdate =
                                              '${state.combineDateAndTime(date, time!)}';
                                            });
                                          } else {
                                            state.dtpWHExitdate =
                                                DateTime.now()
                                                    .toString();
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                              flex: 1,
                              child: Transform.scale(
                                scale: 1.3,
                                child: Checkbox(
                                  value: state.checkBoxValueWHExit,
                                  side: const BorderSide(
                                      color: colour.commonColor),
                                  activeColor: colour.commonColorred,
                                  onChanged: state.isAllowed("chkWareHouseExit") ? (bool? value) {
                                    state.setState(() {
                                      state.checkBoxValueWHExit = value!;
                                      if (state.checkBoxValueWHExit ==
                                          false) {
                                        state.dtpWHExitdate = DateFormat(
                                            "yyyy-MM-dd HH:mm:ss")
                                            .format(DateTime.now());
                                      }
                                    });

                                    // else{
                                    //   buildDropDownMenuItemsCash();
                                    // }
                                  } : null ,
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(
                        height: 7,
                      ),
                      Visibility(
                          visible: state.VisibleOrigin,
                          child: Column(
                            children: [
                              SizedBox(
                                height: height * 0.06,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: TextField(
                                        cursorColor: colour.commonColor,
                                        controller: state.txtOrigin,
                                        enabled: state.isAllowed("txtOrigin"),
                                        autofocus: false,
                                        showCursor: true,
                                        decoration: InputDecoration(
                                          hintText: ('Origin'),
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
                              const SizedBox(
                                height: 3,
                              ),
                            ],
                          )),
                      Visibility(
                          visible: state.VisibleDestination,
                          child: Column(children: [
                            SizedBox(
                              height: height * 0.06,
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                    flex: 1,
                                    child: TextField(
                                      cursorColor: colour.commonColor,
                                      controller: state.txtDestination,
                                      enabled: state.isAllowed("txtDestination"),
                                      autofocus: false,
                                      showCursor: true,
                                      decoration: InputDecoration(
                                        hintText: ('Destination'),
                                        hintStyle: GoogleFonts.lato(
                                            textStyle:TextStyle(
                                                fontSize: objfun.FontMedium,
                                                fontWeight: FontWeight.bold,
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
                                        contentPadding: const EdgeInsets.only(
                                            left: 10,
                                            right: 20,
                                            top: 10.0),
                                      ),
                                      keyboardType: TextInputType.text,
                                      textInputAction:
                                      TextInputAction.done,
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
                            ),
                            const SizedBox(
                              height: 5,
                            )
                          ])),
                      Visibility(
                          visible: state.VisibleGC,
                          child: Column(children: [
                            SizedBox(
                              height: height * 0.06,
                              child:  Row(
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
                                        enabled: state.isAllowed("txtOrigin"),
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
                                                          state.Originid = objfun
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
                                                    state.Originid = 0;
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
                            const SizedBox(
                              height: 5,
                            )
                          ])
                      ),
                      Visibility(
                          visible: state.VisibleGC,
                          child: Column(children: [
                            SizedBox(
                              height: height * 0.06,
                              child:  Row(
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
                                                          state.Destinationid = objfun
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
                                                    state.Destinationid = 0;
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
                            const SizedBox(
                              height: 5,
                            )
                          ])
                      ),
                      SizedBox(
                          height: height * 0.15,
                          child: Column(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                        flex: 6,
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                textCapitalization:
                                                TextCapitalization
                                                    .characters,
                                                controller:
                                                state.txtPickUpAddress,
                                                enabled: state.isAllowed("txtPickUpAddress"),
                                                textInputAction:
                                                TextInputAction
                                                    .done,
                                                keyboardType:
                                                TextInputType.name,
                                                maxLines: null,
                                                expands: true,
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
                                                decoration:
                                                InputDecoration(
                                                  hintText:
                                                  "PickUp Address",
                                                  hintStyle:GoogleFonts.lato(
                                                      textStyle: TextStyle(
                                                          fontSize: objfun
                                                              .FontMedium,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          color: colour
                                                              .commonColorLight)),
                                                  suffixIcon: InkWell(
                                                      child: Icon(
                                                          (state.txtPickUpAddress
                                                              .text
                                                              .isNotEmpty)
                                                              ? Icons
                                                              .close
                                                              : Icons
                                                              .search_rounded,
                                                          color: colour
                                                              .commonColorred,
                                                          size: 30.0),
                                                      onTap: () {
                                                        state.setState(() {
                                                          if (state.txtPickUpAddress
                                                              .text ==
                                                              "") {
                                                            Navigator
                                                                .push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => const AddressList(
                                                                      Searchby: 1,
                                                                      SearchId: 0)),
                                                            ).then((dynamic
                                                            value) async {
                                                              String
                                                              encodedAddress =
                                                              Uri.encodeComponent(
                                                                  objfun.SelectAddressList);
                                                              if(encodedAddress == "")
                                                              {
                                                                return;
                                                              }
                                                              await OnlineApi.SelectAddressDetails(
                                                                  context,
                                                                  encodedAddress);
                                                              state.setState(
                                                                      () {
                                                                    state.txtPickUpAddress
                                                                        .text = (objfun
                                                                        .AddressDetailedList[0].Address +
                                                                        (objfun.AddressDetailedList[0].Phone != null ? " ${objfun.AddressDetailedList[0].Phone}" : ""));
                                                                    objfun.SelectAddressList =
                                                                    "";
                                                                    objfun.AddressDetailedList =
                                                                    [];
                                                                  });
                                                            });
                                                          } else {
                                                            state.setState(
                                                                    () {
                                                                  state.txtPickUpAddress
                                                                      .text = "";
                                                                  objfun.SelectAddressList =
                                                                  "";
                                                                  objfun.AddressDetailedList =
                                                                  [];
                                                                });
                                                          }
                                                        });
                                                      }),
                                                  fillColor:
                                                  Colors.black,
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
                                                  const EdgeInsets
                                                      .only(
                                                      left: 20,
                                                      right: 20,
                                                      top: 10.0),
                                                ),
                                              ),
                                            )
                                          ],
                                        )),
                                    Expanded(
                                        flex: 2,
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                textCapitalization:
                                                TextCapitalization
                                                    .characters,
                                                controller:
                                                state.txtPickUpQuantity,
                                                enabled: state.isAllowed("txtPickUpQuantity"),
                                                textInputAction:
                                                TextInputAction
                                                    .done,
                                                keyboardType:
                                                TextInputType.name,
                                                maxLines: null,
                                                expands: true,
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
                                                decoration:
                                                InputDecoration(
                                                  hintText:
                                                  "PickUp Quantity",
                                                  hintStyle:GoogleFonts.lato(
                                                      textStyle: TextStyle(
                                                          fontSize: objfun
                                                              .FontMedium,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          color: colour
                                                              .commonColorLight)),
                                               
                                                  fillColor:
                                                  Colors.black,
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
                                                  const EdgeInsets
                                                      .only(
                                                      left: 20,
                                                      right: 20,
                                                      top: 10.0),
                                                ),
                                              ),
                                            )
                                          ],
                                        )),
                                    Expanded(
                                        flex: 1,
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                                onPressed: () {
                                                  showDialogPickUpAddress();
                                                },
                                                icon: const Icon(
                                                  Icons.list,
                                                  size: 35,
                                                  color: colour
                                                      .commonColor,
                                                )),
                                            IconButton(
                                                onPressed: () {
                                                  if (state.txtPickUpAddress
                                                      .text !=
                                                      "") {
                                                    state.setState(() {
                                                      state.PickUpAddressList.add(
                                                          state.txtPickUpAddress
                                                              .text);
                                                      state.PickUpQuantityList.add(
                                                          state.txtPickUpQuantity
                                                              .text);
                                                      state.txtPickUpAddress
                                                          .text = "";
                                                      state.txtPickUpQuantity
                                                          .text = "";
                                                    });
                                                  }
                                                },
                                                icon: const Icon(
                                                  Icons.add_box,
                                                  size: 35,
                                                  color: colour
                                                      .commonColor,
                                                )),
                                          ],
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          )),
                      const SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        height: height * 0.15,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 6,
                              child: TextField(
                                textCapitalization:
                                TextCapitalization.characters,
                                controller: state.txtDeliveryAddress,
                                enabled: state.isAllowed("txtDeliveryAddress"),
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.name,
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
                                  hintText: "Delivery Address",
                                  hintStyle:GoogleFonts.lato(
                                      textStyle: TextStyle(
                                          fontSize: objfun.FontMedium,
                                          fontWeight: FontWeight.bold,
                                          color: colour.commonColorLight)),
                                  suffixIcon: InkWell(
                                      child: Icon(
                                          (state.txtDeliveryAddress
                                              .text.isNotEmpty)
                                              ? Icons.close
                                              : Icons.search_rounded,
                                          color: colour.commonColorred,
                                          size: 30.0),
                                      onTap: () {
                                        state.setState(() {
                                          if (state.txtDeliveryAddress.text ==
                                              "") {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                  const AddressList(
                                                      Searchby: 1,
                                                      SearchId: 0)),
                                            ).then(
                                                    (dynamic value) async {
                                                  String encodedAddress = Uri
                                                      .encodeComponent(objfun
                                                      .SelectAddressList);
                                                  if(encodedAddress == "")
                                                  {
                                                    return;
                                                  }
                                                  await OnlineApi
                                                      .SelectAddressDetails(
                                                      context,
                                                      encodedAddress);
                                                  state.setState(() {
                                                    state.txtDeliveryAddress
                                                        .text = (objfun
                                                        .AddressDetailedList[
                                                    0]
                                                        .Address +
                                                        (objfun
                                                            .AddressDetailedList[
                                                        0]
                                                            .Phone !=
                                                            null
                                                            ? " ${objfun
                                                                .AddressDetailedList[
                                                            0]
                                                                .Phone}"
                                                            : ""));
                                                    objfun.SelectAddressList =
                                                    "";
                                                    objfun.AddressDetailedList =
                                                    [];
                                                  });
                                                });
                                          } else {
                                            state.setState(() {
                                              state.txtDeliveryAddress.text =
                                              "";
                                              objfun.SelectAddressList =
                                              "";
                                              objfun.AddressDetailedList =
                                              [];
                                            });
                                          }
                                        });
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
                                  contentPadding: const EdgeInsets.only(
                                      left: 20, right: 20, top: 10.0),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                textCapitalization:
                                TextCapitalization.characters,
                                controller: state.txtDeliveryQuantity,
                                enabled: state.isAllowed("txtDeliveryQuantity"),
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.name,
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
                                  hintText: "Delivery Quantity",
                                  hintStyle:GoogleFonts.lato(
                                      textStyle: TextStyle(
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
                                  contentPadding: const EdgeInsets.only(
                                      left: 20, right: 20, top: 10.0),
                                ),
                              ),
                            ),
                            Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          showDialogDeliveryAddress();
                                        },
                                        icon: const Icon(
                                          Icons.list,
                                          size: 35,
                                          color: colour.commonColor,
                                        )),
                                    IconButton(
                                        onPressed: () {
                                          if (state.txtDeliveryAddress.text !=
                                              "") {
                                            state.setState(() {
                                              state.DeliveryAddressList.add(
                                                  state.txtDeliveryAddress
                                                      .text);
                                              state.txtDeliveryAddress.text =
                                              "";

                                              state.DeliveryQuantityList.add(
                                                  state.txtDeliveryQuantity
                                                      .text);
                                              state.txtDeliveryQuantity.text =
                                              "";
                                            });
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.add_box,
                                          size: 35,
                                          color: colour.commonColor,
                                        )),
                                  ],
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      SizedBox(
                        height: height * 0.15,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: TextField(
                                textCapitalization:
                                TextCapitalization.characters,
                                controller: state.txtWarehouseAddress,
                                enabled: state.isAllowed("txtWarehouseAddress"),
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.name,
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
                                  hintText: "Warehouse Address",
                                  hintStyle:GoogleFonts.lato(
                                      textStyle: TextStyle(
                                          fontSize: objfun.FontMedium,
                                          fontWeight: FontWeight.bold,
                                          color: colour.commonColorLight)),
                                  suffixIcon: InkWell(
                                      child: Icon(
                                          (state.txtWarehouseAddress
                                              .text.isNotEmpty)
                                              ? Icons.close
                                              : Icons.search_rounded,
                                          color: colour.commonColorred,
                                          size: 30.0),
                                      onTap: () {
                                        state.setState(() {
                                          if (state.txtWarehouseAddress
                                              .text ==
                                              "") {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                  const AddressList(
                                                      Searchby: 1,
                                                      SearchId: 0)),
                                            ).then(
                                                    (dynamic value) async {
                                                  String encodedAddress = Uri
                                                      .encodeComponent(objfun
                                                      .SelectAddressList);
                                                  if(encodedAddress == "")
                                                  {
                                                    return;
                                                  }
                                                  await OnlineApi
                                                      .SelectAddressDetails(
                                                      context,
                                                      encodedAddress);
                                                  state.setState(() {
                                                    state.txtWarehouseAddress
                                                        .text = (objfun
                                                        .AddressDetailedList[
                                                    0]
                                                        .Address +
                                                        (objfun
                                                            .AddressDetailedList[
                                                        0]
                                                            .Phone !=
                                                            null
                                                            ? " ${objfun
                                                                .AddressDetailedList[
                                                            0]
                                                                .Phone}"
                                                            : ""));
                                                    objfun.SelectAddressList =
                                                    "";
                                                    objfun.AddressDetailedList =
                                                    [];
                                                  });
                                                });
                                          } else {
                                            state.setState(() {
                                              state.txtWarehouseAddress.text =
                                              "";
                                              objfun.SelectAddressList =
                                              "";
                                              objfun.AddressDetailedList =
                                              [];
                                            });
                                          }
                                        });
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
                                  contentPadding: const EdgeInsets.only(
                                      left: 20, right: 20, top: 10.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 15.0, left: 15.0, right: 15.0),
                  child: ListView(
                    children: <Widget>[
                      Visibility(
                          visible: state.VisibleFORWARDING,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      flex: 1,
                                      child: IconButton(
                                          onPressed: () {
                                            state.setState(() {
                                              state.VisibleFW1 =
                                              state.VisibleFW1 == false
                                                  ? true
                                                  : false;
                                            });
                                          },
                                          icon: Icon(
                                            state.VisibleFW1 == false
                                                ? Icons
                                                .arrow_right_sharp
                                                : Icons.arrow_drop_down,
                                            size: 35,
                                            color: colour.commonColor,
                                          ))),
                                  Expanded(
                                      flex: 3,
                                      child: Text(
                                        "FW 1 ",
                                        style: GoogleFonts.lato(
                                            textStyle:TextStyle(
                                                fontSize: objfun.FontMedium,
                                                fontWeight: FontWeight.bold,
                                                color: colour.commonColor)),
                                        textAlign: TextAlign.center,
                                      )),
                                  Expanded(
                                    flex: 5,
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                        left: 10.0,
                                        right: 10.0,
                                      ),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(
                                              10.0),
                                          color:
                                          colour.commonColorLight,
                                          border: Border.all()),
                                      child:
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton(
                                          isExpanded: true,
                                          value: state.dropdownValueFW1,
                                          onChanged: state.isAllowed("dropdownValueFW1") ?(String? value) {
                                            state.setState(() {
                                              state.dropdownValueFW1 = value!;
                                            });
                                          } : null,
                                          style: GoogleFonts
                                              .lato(
                                            textStyle: TextStyle(
                                                color:
                                                colour.commonColor,
                                                fontWeight:
                                                FontWeight.bold,
                                                fontSize:
                                                objfun.FontMedium,
                                                letterSpacing: 0.3),
                                          ),
                                          items: SalesOrderAddState.ForwardingNo.map<
                                              DropdownMenuItem<
                                                  String>>(
                                                  (String value) {
                                                return DropdownMenuItem<
                                                    String>(
                                                  value: value,
                                                  child: Text(
                                                    value,
                                                    style: GoogleFonts
                                                        .lato(
                                                      textStyle: TextStyle(
                                                          color: colour
                                                              .commonColor,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          fontSize: objfun
                                                              .FontMedium,
                                                          letterSpacing:
                                                          0.3),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              Visibility(
                                  visible: state.VisibleFW1,
                                  child: Column(children: [
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [
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
                                                        state.dtpFW1date
                                                            .toString()))
                                                        : DateFormat("dd-MM-yyyy")
                                                        .format(DateTime.parse(
                                                        state.dtpFW1date
                                                            .toString())),
                                                    style: GoogleFonts.lato(
                                                        textStyle:TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: objfun.FontLow,
                                                          color: state.checkBoxValueFW1 ==
                                                              true
                                                              ? colour.commonColor
                                                              : colour
                                                              .commonColorDisabled,)),
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
                                                      if (state.checkBoxValueFW1 && state.isAllowed("checkBoxValueFW1")) {
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
                                                            state.dtpFW1date =
                                                                DateFormat("yyyy-MM-dd")
                                                                    .format(datenew);
                                                          });
                                                        });
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const Expanded(
                                            flex: 1,
                                            child: Text("")

                                        ),
                                        Expanded(
                                            flex: 1,
                                            child: Transform.scale(
                                              scale: 1.3,
                                              child: Checkbox(
                                                value: state.checkBoxValueFW1,
                                                side: const BorderSide(
                                                    color:
                                                    colour.commonColor),
                                                activeColor:
                                                colour.commonColorred,
                                                onChanged: state.isAllowed("checkBoxValueFW1") ? (bool? value) {
                                                  state.setState(() {
                                                    state.checkBoxValueFW1 =
                                                    value!;
                                                    if (state.checkBoxValueFW1 ==
                                                        false) {
                                                      // state.dtpFW1date = DateFormat(
                                                      //     "yyyy-MM-dd HH:mm:ss ")
                                                      //     .format(
                                                      //     DateTime.now());
                                                    }
                                                  });

                                                  // else{
                                                  //   buildDropDownMenuItemsCash();
                                                  // }
                                                } : null,
                                              ),
                                            )),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 7,
                                    ),
                                    Container(
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
                                        controller: state.txtSmk1,
                                        enabled: state.isAllowed("txtSmk1"),
                                        autofocus: false,
                                        showCursor: true,
                                        decoration:
                                        InputDecoration(
                                          hintText:
                                          ('SMK NO 1'),
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
                                    SizedBox(
                                      height: height * 0.06,
                                      child: Row(
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
                                                controller: state.txtENRef1,
                                                enabled: state.isAllowed("txtENRef1"),
                                                autofocus: false,
                                                showCursor: true,
                                                decoration:
                                                InputDecoration(
                                                  hintText:
                                                  ('R.No 1'),
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
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
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
                                                controller: state.txtExRef1,
                                                enabled:state.isAllowed("txtExRef1"),
                                                autofocus: false,
                                                showCursor: true,
                                                decoration:
                                                InputDecoration(
                                                  hintText:
                                                  ('EX.Ref 1'),
                                                  hintStyle:GoogleFonts.lato(
                                                      textStyle: TextStyle(
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
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Container(
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
                                        controller: state.txtSealByEmp1,
                                        enabled: state.isAllowed("txtSealByEmp1"),
                                        textInputAction:
                                        TextInputAction.done,
                                        keyboardType:
                                        TextInputType.name,
                                        readOnly: true,
                                        style:
                                        GoogleFonts.lato(
                                          textStyle: TextStyle(
                                              color: colour.commonColor,
                                              fontWeight:
                                              FontWeight.bold,
                                              fontSize: objfun.FontLow,
                                              letterSpacing: 0.3),
                                        ),
                                        decoration: InputDecoration(
                                          hintText: "Seal By",
                                          hintStyle: GoogleFonts.lato(
                                              textStyle:TextStyle(
                                                  fontSize:
                                                  objfun.FontMedium,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  color: colour
                                                      .commonColorLight)),
                                          suffixIcon: InkWell(
                                              child: Icon(
                                                  (state.txtSealByEmp1.text
                                                      .isNotEmpty)
                                                      ? Icons.close
                                                      : Icons
                                                      .search_rounded,
                                                  color: colour
                                                      .commonColorred,
                                                  size: 30.0),
                                              onTap: () async {
                                                if (state.txtSealByEmp1
                                                    .text ==
                                                    "") {
                                                  await OnlineApi
                                                      .SelectEmployee(
                                                      context,
                                                      '',
                                                      'Operation');
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                        const Employee(
                                                            Searchby:
                                                            1,
                                                            SearchId:
                                                            0)),
                                                  ).then((dynamic
                                                  value) async {
                                                    state.setState(() {
                                                      state.txtSealByEmp1
                                                          .text =
                                                          objfun
                                                              .SelectEmployeeList
                                                              .AccountName;
                                                      state.SealEmpId1 = objfun
                                                          .SelectEmployeeList
                                                          .Id;
                                                      objfun.SelectEmployeeList =
                                                          EmployeeModel
                                                              .Empty();
                                                    });
                                                  });
                                                } else {
                                                  state.setState(() {
                                                    state.txtSealByEmp1.text =
                                                    "";
                                                    state.SealEmpId1 = 0;
                                                    objfun.SelectEmployeeList =
                                                        EmployeeModel
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
                                      ),
                                    ),
                                    Container(
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
                                        controller: state.txtBreakByEmp1,
                                        enabled: state.isAllowed("txtBreakByEmp1"),
                                        textInputAction:
                                        TextInputAction.done,
                                        keyboardType:
                                        TextInputType.name,
                                        readOnly: true,
                                        style:
                                        GoogleFonts.lato(
                                          textStyle: TextStyle(
                                              color: colour.commonColor,
                                              fontWeight:
                                              FontWeight.bold,
                                              fontSize: objfun.FontLow,
                                              letterSpacing: 0.3),
                                        ),
                                        decoration: InputDecoration(
                                          hintText: "B.Seal By",
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
                                                  (state.txtBreakByEmp1.text
                                                      .isNotEmpty)
                                                      ? Icons.close
                                                      : Icons
                                                      .search_rounded,
                                                  color: colour
                                                      .commonColorred,
                                                  size: 30.0),
                                              onTap: () async {
                                                await OnlineApi
                                                    .SelectEmployee(
                                                    context,
                                                    '',
                                                    'Operation');
                                                if (state.txtBreakByEmp1
                                                    .text ==
                                                    "") {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                        const Employee(
                                                            Searchby:
                                                            1,
                                                            SearchId:
                                                            0)),
                                                  ).then((dynamic
                                                  value) async {
                                                    state.setState(() {
                                                      state.txtBreakByEmp1
                                                          .text =
                                                          objfun
                                                              .SelectEmployeeList
                                                              .AccountName;
                                                      state.BreakEmpId1 = objfun
                                                          .SelectEmployeeList
                                                          .Id;
                                                      objfun.SelectEmployeeList =
                                                          EmployeeModel
                                                              .Empty();
                                                    });
                                                  });
                                                } else {
                                                  state.setState(() {
                                                    state.txtBreakByEmp1
                                                        .text = "";
                                                    state.BreakEmpId1 = 0;
                                                    objfun.SelectEmployeeList =
                                                        EmployeeModel
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
                                      ),
                                    ),
                                    Container(
                                      width: objfun.SizeConfig.safeBlockHorizontal * 99,
                                      height: objfun.SizeConfig.safeBlockVertical * 6,
                                      alignment: Alignment.topCenter,
                                      padding: const EdgeInsets.only(bottom: 5),
                                      child: TextField(
                                        cursorColor: colour.commonColor,
                                        controller: state.txtForwarding1S1,
                                        enabled: state.isAllowed("txtForwarding1S1"),
                                        autofocus: false,
                                        showCursor: true,
                                        decoration: InputDecoration(
                                          hintText: ('S1'),
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
                                        keyboardType: TextInputType.text,
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
                                            state.autoCompleteSearchS1(value, false,1);
                                          });
                                        },
                                      ),
                                    ),
                                    Container(
                                      width: objfun.SizeConfig.safeBlockHorizontal * 99,
                                      height: objfun.SizeConfig.safeBlockVertical * 6,
                                      alignment: Alignment.topCenter,
                                      padding: const EdgeInsets.only(bottom: 5),
                                      child: TextField(
                                        cursorColor: colour.commonColor,
                                        controller: state.txtForwarding1S2,
                                        enabled: state.isAllowed("txtForwarding1S2"),
                                        autofocus: false,
                                        showCursor: true,
                                        decoration: InputDecoration(
                                          hintText: ('S2'),
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
                                        keyboardType: TextInputType.text,
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
                                            state.autoCompleteSearchS1(value, false,2);
                                          });
                                        },
                                      ),
                                    ),
                                  ])),
                              const Divider(
                                color: colour.commonColorLight,
                                thickness: 1,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                      flex: 1,
                                      child: IconButton(
                                          onPressed: () {
                                            state.setState(() {
                                              state.VisibleFW2 =
                                              state.VisibleFW2 == false
                                                  ? true
                                                  : false;
                                            });
                                          },
                                          icon: Icon(
                                            state.VisibleFW2 == false
                                                ? Icons
                                                .arrow_right_sharp
                                                : Icons.arrow_drop_down,
                                            size: 35,
                                            color: colour.commonColor,
                                          ))),
                                  Expanded(
                                      flex: 3,
                                      child: Text(
                                        "FW 2 ",
                                        style:GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                fontSize: objfun.FontMedium,
                                                fontWeight: FontWeight.bold,
                                                color: colour.commonColor)),
                                        textAlign: TextAlign.center,
                                      )),
                                  Expanded(
                                    flex: 5,
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                        left: 10.0,
                                        right: 10.0,
                                      ),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(
                                              10.0),
                                          color:
                                          colour.commonColorLight,
                                          border: Border.all()),
                                      child:
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton(
                                          isExpanded: true,
                                          value: state.dropdownValueFW2,
                                          onChanged: state.isAllowed("dropdownValueFW2") ? (String? value) {
                                            state.setState(() {
                                              state.dropdownValueFW2 = value!;
                                            });
                                          } : null,
                                          style: GoogleFonts
                                              .lato(
                                            textStyle: TextStyle(
                                                color:
                                                colour.commonColor,
                                                fontWeight:
                                                FontWeight.bold,
                                                fontSize:
                                                objfun.FontMedium,
                                                letterSpacing: 0.3),
                                          ),
                                          items: SalesOrderAddState.ForwardingNo.map<
                                              DropdownMenuItem<
                                                  String>>(
                                                  (String value) {
                                                return DropdownMenuItem<
                                                    String>(
                                                  value: value,
                                                  child: Text(
                                                    value,
                                                    style: GoogleFonts
                                                        .lato(
                                                      textStyle: TextStyle(
                                                          color: colour
                                                              .commonColor,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          fontSize: objfun
                                                              .FontMedium,
                                                          letterSpacing:
                                                          0.3),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              Visibility(
                                  visible: state.VisibleFW2,
                                  child: Column(children: [
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [
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
                                                        state.dtpFW2date
                                                            .toString()))
                                                        : DateFormat("dd-MM-yyyy")
                                                        .format(DateTime.parse(
                                                        state.dtpFW2date
                                                            .toString())),
                                                    style: GoogleFonts.lato(
                                                        textStyle:TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: objfun.FontLow,
                                                          color: state.checkBoxValueFW2 ==
                                                              true
                                                              ? colour.commonColor
                                                              : colour
                                                              .commonColorDisabled,)),
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
                                                      if (state.checkBoxValueFW2 && state.isAllowed("checkBoxValueFW2")) {
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
                                                            state.dtpFW2date =
                                                                DateFormat("yyyy-MM-dd")
                                                                    .format(datenew);
                                                          });
                                                        });
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const Expanded(
                                            flex: 1,
                                            child: Text("")

                                        ),
                                        Expanded(
                                            flex: 1,
                                            child: Transform.scale(
                                              scale: 1.3,
                                              child: Checkbox(
                                                value: state.checkBoxValueFW2,
                                                side: const BorderSide(
                                                    color:
                                                    colour.commonColor),
                                                activeColor:
                                                colour.commonColorred,
                                                onChanged: state.isAllowed("checkBoxValueFW2") ? (bool? value) {
                                                  state.setState(() {
                                                    state.checkBoxValueFW2 =
                                                    value!;
                                                    if (state.checkBoxValueFW2 ==
                                                        false) {
                                                      // state.dtpFW1date = DateFormat(
                                                      //     "yyyy-MM-dd HH:mm:ss ")
                                                      //     .format(
                                                      //     DateTime.now());
                                                    }
                                                  });

                                                  // else{
                                                  //   buildDropDownMenuItemsCash();
                                                  // }
                                                } : null,
                                              ),
                                            )),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 7,
                                    ),
                                    Container(
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
                                        controller: state.txtSmk2,
                                        enabled: state.isAllowed("txtSmk2"),
                                        autofocus: false,
                                        showCursor: true,
                                        decoration:
                                        InputDecoration(
                                          hintText:
                                          ('SMK NO 2'),
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
                                    SizedBox(
                                      height: height * 0.06,
                                      child: Row(
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
                                                controller: state.txtENRef2,
                                                enabled: state.isAllowed("txtENRef2"),
                                                autofocus: false,
                                                showCursor: true,
                                                decoration:
                                                InputDecoration(
                                                  hintText:
                                                  ('R.No 2'),
                                                  hintStyle:GoogleFonts.lato(
                                                      textStyle: TextStyle(
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
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
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
                                                controller: state.txtExRef2,
                                                enabled: state.isAllowed("txtExRef2"),
                                                autofocus: false,
                                                showCursor: true,
                                                decoration:
                                                InputDecoration(
                                                  hintText:
                                                  ('EX.Ref 2'),
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
                                          ),

                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Container(
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
                                        controller: state.txtSealByEmp2,
                                        enabled: state.isAllowed("txtSealByEmp2"),
                                        textInputAction:
                                        TextInputAction.done,
                                        keyboardType:
                                        TextInputType.name,
                                        readOnly: true,
                                        style:
                                        GoogleFonts.lato(
                                          textStyle: TextStyle(
                                              color: colour.commonColor,
                                              fontWeight:
                                              FontWeight.bold,
                                              fontSize: objfun.FontLow,
                                              letterSpacing: 0.3),
                                        ),
                                        decoration: InputDecoration(
                                          hintText: "Seal By",
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
                                                  (state.txtSealByEmp2.text
                                                      .isNotEmpty)
                                                      ? Icons.close
                                                      : Icons
                                                      .search_rounded,
                                                  color: colour
                                                      .commonColorred,
                                                  size: 30.0),
                                              onTap: () async {
                                                await OnlineApi
                                                    .SelectEmployee(
                                                    context,
                                                    '',
                                                    'Operation');
                                                if (state.txtSealByEmp2
                                                    .text ==
                                                    "") {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                        const Employee(
                                                            Searchby:
                                                            1,
                                                            SearchId:
                                                            0)),
                                                  ).then((dynamic
                                                  value) async {
                                                    state.setState(() {
                                                      state.txtSealByEmp2
                                                          .text =
                                                          objfun
                                                              .SelectEmployeeList
                                                              .AccountName;
                                                      state.SealEmpId2 = objfun
                                                          .SelectEmployeeList
                                                          .Id;
                                                      objfun.SelectEmployeeList =
                                                          EmployeeModel
                                                              .Empty();
                                                    });
                                                  });
                                                } else {
                                                  state.setState(() {
                                                    state.txtSealByEmp2.text =
                                                    "";
                                                    state.SealEmpId2 = 0;
                                                    objfun.SelectEmployeeList =
                                                        EmployeeModel
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
                                      ),
                                    ),
                                    Container(
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
                                        controller: state.txtBreakByEmp2,
                                        enabled: state.isAllowed("txtBreakByEmp2"),
                                        textInputAction:
                                        TextInputAction.done,
                                        keyboardType:
                                        TextInputType.name,
                                        readOnly: true,
                                        style:
                                        GoogleFonts.lato(
                                          textStyle: TextStyle(
                                              color: colour.commonColor,
                                              fontWeight:
                                              FontWeight.bold,
                                              fontSize: objfun.FontLow,
                                              letterSpacing: 0.3),
                                        ),
                                        decoration: InputDecoration(
                                          hintText: "B.Seal By",
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
                                                  (state.txtBreakByEmp2.text
                                                      .isNotEmpty)
                                                      ? Icons.close
                                                      : Icons
                                                      .search_rounded,
                                                  color: colour
                                                      .commonColorred,
                                                  size: 30.0),
                                              onTap: () async {
                                                await OnlineApi
                                                    .SelectEmployee(
                                                    context,
                                                    '',
                                                    'Operation');
                                                if (state.txtBreakByEmp2
                                                    .text ==
                                                    "") {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                        const Employee(
                                                            Searchby:
                                                            1,
                                                            SearchId:
                                                            0)),
                                                  ).then((dynamic
                                                  value) async {
                                                    state.setState(() {
                                                      state.txtBreakByEmp2
                                                          .text =
                                                          objfun
                                                              .SelectEmployeeList
                                                              .AccountName;
                                                      state.BreakEmpId2 = objfun
                                                          .SelectEmployeeList
                                                          .Id;
                                                      objfun.SelectEmployeeList =
                                                          EmployeeModel
                                                              .Empty();
                                                    });
                                                  });
                                                } else {
                                                  state.setState(() {
                                                    state.txtBreakByEmp2
                                                        .text = "";
                                                    state.BreakEmpId2 = 0;
                                                    objfun.SelectEmployeeList =
                                                        EmployeeModel
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
                                      ),
                                    ),
                                    Container(
                                      width: objfun.SizeConfig.safeBlockHorizontal * 99,
                                      height: objfun.SizeConfig.safeBlockVertical * 6,
                                      alignment: Alignment.topCenter,
                                      padding: const EdgeInsets.only(bottom: 5),
                                      child: TextField(
                                        cursorColor: colour.commonColor,
                                        controller: state.txtForwarding2S1,
                                        enabled: state.isAllowed("txtForwarding2S1"),
                                        autofocus: false,
                                        showCursor: true,
                                        decoration: InputDecoration(
                                          hintText: ('S1'),
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
                                        keyboardType: TextInputType.text,
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
                                            state.autoCompleteSearchS1(value, false,3);
                                          });
                                        },
                                      ),
                                    ),
                                    Container(
                                      width: objfun.SizeConfig.safeBlockHorizontal * 99,
                                      height: objfun.SizeConfig.safeBlockVertical * 6,
                                      alignment: Alignment.topCenter,
                                      padding: const EdgeInsets.only(bottom: 5),
                                      child: TextField(
                                        cursorColor: colour.commonColor,
                                        controller: state.txtForwarding2S2,
                                        enabled: state.isAllowed("txtForwarding2S2"),
                                        autofocus: false,
                                        showCursor: true,
                                        decoration: InputDecoration(
                                          hintText: ('S2'),
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
                                        keyboardType: TextInputType.text,
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
                                            state.autoCompleteSearchS1(value, false,4);
                                          });
                                        },
                                      ),
                                    ),
                                  ])),
                              const Divider(
                                color: colour.commonColorLight,
                                thickness: 1,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                      flex: 1,
                                      child: IconButton(
                                          onPressed: () {
                                            state.setState(() {
                                              state.VisibleFW3 =
                                              state.VisibleFW3 == false
                                                  ? true
                                                  : false;
                                            });
                                          },
                                          icon: Icon(
                                            state.VisibleFW3 == false
                                                ? Icons
                                                .arrow_right_sharp
                                                : Icons.arrow_drop_down,
                                            size: 35,
                                            color: colour.commonColor,
                                          ))),
                                  Expanded(
                                      flex: 3,
                                      child: Text(
                                        "FW 3 ",
                                        style:GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                fontSize: objfun.FontMedium,
                                                fontWeight: FontWeight.bold,
                                                color: colour.commonColor)),
                                        textAlign: TextAlign.center,
                                      )),
                                  Expanded(
                                    flex: 5,
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                        left: 10.0,
                                        right: 10.0,
                                      ),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(
                                              10.0),
                                          color:
                                          colour.commonColorLight,
                                          border: Border.all()),
                                      child:
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton(
                                          isExpanded: true,
                                          value: state.dropdownValueFW3,
                                          onChanged: state.isAllowed("dropdownValueFW3") ? (String? value) {
                                            state.setState(() {
                                              state.dropdownValueFW3 = value!;
                                            });
                                          } : null,
                                          style: GoogleFonts
                                              .lato(
                                            textStyle: TextStyle(
                                                color:
                                                colour.commonColor,
                                                fontWeight:
                                                FontWeight.bold,
                                                fontSize:
                                                objfun.FontMedium,
                                                letterSpacing: 0.3),
                                          ),
                                          items: SalesOrderAddState.ForwardingNo.map<
                                              DropdownMenuItem<
                                                  String>>(
                                                  (String value) {
                                                return DropdownMenuItem<
                                                    String>(
                                                  value: value,
                                                  child: Text(
                                                    value,
                                                    style: GoogleFonts
                                                        .lato(
                                                      textStyle: TextStyle(
                                                          color: colour
                                                              .commonColor,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          fontSize: objfun
                                                              .FontMedium,
                                                          letterSpacing:
                                                          0.3),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              Visibility(
                                  visible: state.VisibleFW3,
                                  child: Column(children: [
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [
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
                                                        state.dtpFW3date
                                                            .toString()))
                                                        : DateFormat("dd-MM-yyyy")
                                                        .format(DateTime.parse(
                                                        state.dtpFW3date
                                                            .toString())),
                                                    style: GoogleFonts.lato(
                                                        textStyle:TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: objfun.FontLow,
                                                          color: state.checkBoxValueFW3 ==
                                                              true
                                                              ? colour.commonColor
                                                              : colour
                                                              .commonColorDisabled,)),
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
                                                      if (state.checkBoxValueFW3 && state.isAllowed("checkBoxValueFW3")) {
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
                                                            state.dtpFW3date =
                                                                DateFormat("yyyy-MM-dd")
                                                                    .format(datenew);
                                                          });
                                                        });
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const Expanded(
                                            flex: 1,
                                            child: Text("")

                                        ),
                                        Expanded(
                                            flex: 1,
                                            child: Transform.scale(
                                              scale: 1.3,
                                              child: Checkbox(
                                                value: state.checkBoxValueFW3,
                                                side: const BorderSide(
                                                    color:
                                                    colour.commonColor),
                                                activeColor:
                                                colour.commonColorred,
                                                onChanged: state.isAllowed("checkBoxValueFW3")  ? (bool? value) {
                                                  state.setState(() {
                                                    state.checkBoxValueFW3 =
                                                    value!;
                                                    if (state.checkBoxValueFW3 ==
                                                        false) {
                                                      // state.dtpFW1date = DateFormat(
                                                      //     "yyyy-MM-dd HH:mm:ss ")
                                                      //     .format(
                                                      //     DateTime.now());
                                                    }
                                                  });

                                                  // else{
                                                  //   buildDropDownMenuItemsCash();
                                                  // }
                                                } : null,
                                              ),
                                            )),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 7,
                                    ),
                                    Container(
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
                                        controller: state.txtSmk3,
                                        enabled: state.isAllowed("txtSmk3"),
                                        autofocus: false,
                                        showCursor: true,
                                        decoration:
                                        InputDecoration(
                                          hintText:
                                          ('SMK NO 3'),
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
                                    SizedBox(
                                      height: height * 0.06,
                                      child: Row(
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
                                                controller: state.txtENRef3,
                                                autofocus: false,
                                                enabled:state.isAllowed("txtENRef3"),
                                                showCursor: true,
                                                decoration:
                                                InputDecoration(
                                                  hintText:
                                                  ('R.No 3'),
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
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
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
                                                controller: state.txtExRef3,
                                                enabled: state.isAllowed("txtExRef3"),
                                                autofocus: false,
                                                showCursor: true,
                                                decoration:
                                                InputDecoration(
                                                  hintText:
                                                  ('EX.Ref 3'),
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
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Container(
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
                                        controller: state.txtSealByEmp3,
                                        enabled: state.isAllowed("txtSealByEmp3"),
                                        textInputAction:
                                        TextInputAction.done,
                                        keyboardType:
                                        TextInputType.name,
                                        readOnly: true,
                                        style:
                                        GoogleFonts.lato(
                                          textStyle: TextStyle(
                                              color: colour.commonColor,
                                              fontWeight:
                                              FontWeight.bold,
                                              fontSize: objfun.FontLow,
                                              letterSpacing: 0.3),
                                        ),
                                        decoration: InputDecoration(
                                          hintText: "Seal By",
                                          hintStyle: GoogleFonts.lato(
                                              textStyle:TextStyle(
                                                  fontSize:
                                                  objfun.FontMedium,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  color: colour
                                                      .commonColorLight)),
                                          suffixIcon: InkWell(
                                              child: Icon(
                                                  (state.txtSealByEmp3.text
                                                      .isNotEmpty)
                                                      ? Icons.close
                                                      : Icons
                                                      .search_rounded,
                                                  color: colour
                                                      .commonColorred,
                                                  size: 30.0),
                                              onTap: () async {
                                                await OnlineApi
                                                    .SelectEmployee(
                                                    context,
                                                    '',
                                                    'Operation');
                                                if (state.txtSealByEmp3
                                                    .text ==
                                                    "") {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                        const Employee(
                                                            Searchby:
                                                            1,
                                                            SearchId:
                                                            0)),
                                                  ).then((dynamic
                                                  value) async {
                                                    state.setState(() {
                                                      state.txtSealByEmp3
                                                          .text =
                                                          objfun
                                                              .SelectEmployeeList
                                                              .AccountName;
                                                      state.SealEmpId3 = objfun
                                                          .SelectEmployeeList
                                                          .Id;
                                                      objfun.SelectEmployeeList =
                                                          EmployeeModel
                                                              .Empty();
                                                    });
                                                  });
                                                } else {
                                                  state.setState(() {
                                                    state.txtSealByEmp3.text =
                                                    "";
                                                    state.SealEmpId3 = 0;
                                                    objfun.SelectEmployeeList =
                                                        EmployeeModel
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
                                      ),
                                    ),
                                    Container(
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
                                        controller: state.txtBreakByEmp3,
                                        enabled: state.isAllowed("txtBreakByEmp3"),
                                        textInputAction:
                                        TextInputAction.done,
                                        keyboardType:
                                        TextInputType.name,
                                        readOnly: true,
                                        style:
                                        GoogleFonts.lato(
                                          textStyle: TextStyle(
                                              color: colour.commonColor,
                                              fontWeight:
                                              FontWeight.bold,
                                              fontSize: objfun.FontLow,
                                              letterSpacing: 0.3),
                                        ),
                                        decoration: InputDecoration(
                                          hintText: "B.Seal By",
                                          hintStyle: GoogleFonts.lato(
                                              textStyle:TextStyle(
                                                  fontSize:
                                                  objfun.FontMedium,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  color: colour
                                                      .commonColorLight)),
                                          suffixIcon: InkWell(
                                              child: Icon(
                                                  (state.txtBreakByEmp3.text
                                                      .isNotEmpty)
                                                      ? Icons.close
                                                      : Icons
                                                      .search_rounded,
                                                  color: colour
                                                      .commonColorred,
                                                  size: 30.0),
                                              onTap: () async {
                                                await OnlineApi
                                                    .SelectEmployee(
                                                    context,
                                                    '',
                                                    'Operation');
                                                if (state.txtBreakByEmp3
                                                    .text ==
                                                    "") {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                        const Employee(
                                                            Searchby:
                                                            1,
                                                            SearchId:
                                                            0)),
                                                  ).then((dynamic
                                                  value) async {
                                                    state.setState(() {
                                                      state.txtBreakByEmp3
                                                          .text =
                                                          objfun
                                                              .SelectEmployeeList
                                                              .AccountName;
                                                      state.BreakEmpId3 = objfun
                                                          .SelectEmployeeList
                                                          .Id;
                                                      objfun.SelectEmployeeList =
                                                          EmployeeModel
                                                              .Empty();
                                                    });
                                                  });
                                                } else {
                                                  state.setState(() {
                                                    state.txtBreakByEmp3
                                                        .text = "";
                                                    state.BreakEmpId3 = 0;
                                                    objfun.SelectEmployeeList =
                                                        EmployeeModel
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
                                      ),
                                    ),
                                    Container(
                                      width: objfun.SizeConfig.safeBlockHorizontal * 99,
                                      height: objfun.SizeConfig.safeBlockVertical * 6,
                                      alignment: Alignment.topCenter,
                                      padding: const EdgeInsets.only(bottom: 5),
                                      child: TextField(
                                        cursorColor: colour.commonColor,
                                        controller: state.txtForwarding3S1,
                                        enabled: state.isAllowed("txtForwarding3S1"),
                                        autofocus: false,
                                        showCursor: true,
                                        decoration: InputDecoration(
                                          hintText: ('S1'),
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
                                        keyboardType: TextInputType.text,
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
                                            state.autoCompleteSearchS1(value, false,5);
                                          });
                                        },
                                      ),
                                    ),
                                    Container(
                                      width: objfun.SizeConfig.safeBlockHorizontal * 99,
                                      height: objfun.SizeConfig.safeBlockVertical * 6,
                                      alignment: Alignment.topCenter,
                                      padding: const EdgeInsets.only(bottom: 5),
                                      child: TextField(
                                        cursorColor: colour.commonColor,
                                        controller: state.txtForwarding3S2,
                                        enabled: state.isAllowed("txtForwarding3S2"),
                                        autofocus: false,
                                        showCursor: true,
                                        decoration: InputDecoration(
                                          hintText: ('S2'),
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
                                        keyboardType: TextInputType.text,
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
                                            state.autoCompleteSearchS1(value, false,6);
                                          });
                                        },
                                      ),
                                    ),
                                  ])),
                              const Divider(
                                color: colour.commonColorLight,
                                thickness: 1,
                              ),
                            ],
                          )),
                      Visibility(
                          visible: state.VisibleZB,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      flex: 2,
                                      child: Text(
                                        "ZB 1",
                                        style:GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                fontSize: objfun.FontMedium,
                                                fontWeight: FontWeight.bold,
                                                color: colour.commonColor)),
                                        textAlign: TextAlign.center,
                                      )),
                                  Expanded(
                                    flex: 5,
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                        left: 10.0,
                                        right: 10.0,
                                      ),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(
                                              10.0),
                                          color:
                                          colour.commonColorLight,
                                          border: Border.all()),
                                      child:
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton(
                                          isExpanded: true,
                                          value: state.dropdownValueZB1,
                                          onChanged: state.isAllowed("dropdownValueZB1") ? (String? value) {
                                            state.setState(() {
                                              state.dropdownValueZB1 = value!;
                                            });
                                          } : null,
                                          style: GoogleFonts
                                              .lato(
                                            textStyle: TextStyle(
                                                color:
                                                colour.commonColor,
                                                fontWeight:
                                                FontWeight.bold,
                                                fontSize:
                                                objfun.FontMedium,
                                                letterSpacing: 0.3),
                                          ),
                                          items: SalesOrderAddState.ZBNo.map<
                                              DropdownMenuItem<
                                                  String>>(
                                                  (String value) {
                                                return DropdownMenuItem<
                                                    String>(
                                                  value: value,
                                                  child: Text(
                                                    value,
                                                    style: GoogleFonts
                                                        .lato(
                                                      textStyle: TextStyle(
                                                          color: colour
                                                              .commonColor,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          fontSize: objfun
                                                              .FontMedium,
                                                          letterSpacing:
                                                          0.3),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              SizedBox(
                                height: height * 0.06,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
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
                                        alignment: Alignment.topCenter,
                                        padding: const EdgeInsets.only(
                                            bottom: 5),
                                        child: TextField(
                                          cursorColor:
                                          colour.commonColor,
                                          controller: state.txtZBRef1,
                                          enabled: state.isAllowed("txtZBRef1"),
                                          autofocus: false,
                                          showCursor: true,
                                          decoration: InputDecoration(
                                            hintText: ('ZB Ref 1'),
                                            hintStyle: GoogleFonts.lato(
                                                textStyle:TextStyle(
                                                    fontSize:
                                                    objfun.FontMedium,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color: colour
                                                        .commonColorLight)),
                                            fillColor:
                                            colour.commonColor,
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
                                          TextInputAction.done,
                                          textCapitalization:
                                          TextCapitalization
                                              .characters,
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
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                      Visibility(
                          visible: state.VisibleZB,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      flex: 2,
                                      child: Text(
                                        "ZB 2",
                                        style:GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                fontSize: objfun.FontMedium,
                                                fontWeight: FontWeight.bold,
                                                color: colour.commonColor)),
                                        textAlign: TextAlign.center,
                                      )),
                                  Expanded(
                                    flex: 5,
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                        left: 10.0,
                                        right: 10.0,
                                      ),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(
                                              10.0),
                                          color:
                                          colour.commonColorLight,
                                          border: Border.all()),
                                      child:
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton(
                                          isExpanded: true,
                                          value: state.dropdownValueZB2,
                                          onChanged: state.isAllowed("dropdownValueZB2") ?(String? value) {
                                            state.setState(() {
                                              state.dropdownValueZB2 = value!;
                                            });
                                          } : null,
                                          style: GoogleFonts
                                              .lato(
                                            textStyle: TextStyle(
                                                color:
                                                colour.commonColor,
                                                fontWeight:
                                                FontWeight.bold,
                                                fontSize:
                                                objfun.FontMedium,
                                                letterSpacing: 0.3),
                                          ),
                                          items: SalesOrderAddState.ZBNo.map<
                                              DropdownMenuItem<
                                                  String>>(
                                                  (String value) {
                                                return DropdownMenuItem<
                                                    String>(
                                                  value: value,
                                                  child: Text(
                                                    value,
                                                    style: GoogleFonts
                                                        .lato(
                                                      textStyle: TextStyle(
                                                          color: colour
                                                              .commonColor,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          fontSize: objfun
                                                              .FontMedium,
                                                          letterSpacing:
                                                          0.3),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              SizedBox(
                                height: height * 0.06,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
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
                                        alignment: Alignment.topCenter,
                                        padding: const EdgeInsets.only(
                                            bottom: 5),
                                        child: TextField(
                                          cursorColor:
                                          colour.commonColor,
                                          controller: state.txtZBRef2,
                                          autofocus: false,
                                          enabled: state.isAllowed("txtZBRef2"),
                                          showCursor: true,
                                          decoration: InputDecoration(
                                            hintText: ('ZB Ref 2'),
                                            hintStyle: GoogleFonts.lato(
                                                textStyle:TextStyle(
                                                    fontSize:
                                                    objfun.FontMedium,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color: colour
                                                        .commonColorLight)),
                                            fillColor:
                                            colour.commonColor,
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
                                          TextInputAction.done,
                                          textCapitalization:
                                          TextCapitalization
                                              .characters,
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
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                color: colour.commonColorLight,
                                thickness: 1,
                              ),
                            ],
                          )),
                      Container(
                        width:
                        objfun.SizeConfig.safeBlockHorizontal * 99,
                        height: objfun.SizeConfig.safeBlockVertical * 7,
                        alignment: Alignment.topCenter,
                        //padding: const EdgeInsets.only(bottom: 5),
                        child: TextField(
                          textCapitalization:
                          TextCapitalization.characters,
                          controller: state.txtBoardingOfficer1,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.name,
                          readOnly: !state.isAllowed("txtBoardingOfficer1"),
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                                color: colour.commonColor,
                                fontWeight: FontWeight.bold,
                                fontSize: objfun.FontLow,
                                letterSpacing: 0.3),
                          ),
                          decoration: InputDecoration(
                            hintText: "Boarding Officer 1",
                            hintStyle: GoogleFonts.lato(
                                textStyle:TextStyle(
                                    fontSize: objfun.FontMedium,
                                    fontWeight: FontWeight.bold,
                                    color: colour.commonColorLight)),
                            suffixIcon: InkWell(
                                child: Icon(
                                    (state.txtBoardingOfficer1
                                        .text.isNotEmpty)
                                        ? Icons.close
                                        : Icons.search_rounded,
                                    color: colour.commonColorred,
                                    size: 30.0),
                                onTap: () async {
                                  await OnlineApi.SelectEmployee(
                                      context, '', 'Operation');
                                  if (state.txtBoardingOfficer1.text == "") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                          const Employee(
                                              Searchby: 1,
                                              SearchId: 0)),
                                    ).then((dynamic value) async {
                                      state.setState(() {
                                        state.txtBoardingOfficer1.text =
                                            objfun.SelectEmployeeList
                                                .AccountName;
                                        state.BoardOfficerId1 = objfun
                                            .SelectEmployeeList.Id;
                                        objfun.SelectEmployeeList =
                                            EmployeeModel.Empty();
                                      });
                                    });
                                  } else {
                                    state.setState(() {
                                      state.txtBoardingOfficer1.text = "";
                                      state.BoardOfficerId1 = 0;
                                      objfun.SelectEmployeeList =
                                          EmployeeModel.Empty();
                                    });
                                  }
                                }),
                            fillColor: Colors.black,
                            enabledBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10.0)),
                              borderSide:
                              BorderSide(color: colour.commonColor),
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
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      SizedBox(
                        height: height * 0.06,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
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
                                  cursorColor: colour.commonColor,
                                  controller: state.txtAmount1,
                                  autofocus: false,
                                  showCursor:
                                  state.DisabledAmount1 ? false : true,
                                  readOnly:
                                  state.DisabledAmount1 ? true : false,
                                  decoration: InputDecoration(
                                    hintText: ('Amount 1'),
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
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      SizedBox(
                        height: height * 0.06,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
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
                                  cursorColor: colour.commonColor,
                                  controller: state.txtPortChargeRef1,
                                  enabled: state.isAllowed("txtPortChargeRef1"),
                                  autofocus: false,
                                  showCursor: true,
                                  decoration: InputDecoration(
                                    hintText: ('Port Charges Ref'),
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
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        color: colour.commonColorLight,
                        thickness: 1,
                      ),
                      Container(
                        width:
                        objfun.SizeConfig.safeBlockHorizontal * 99,
                        height: objfun.SizeConfig.safeBlockVertical * 7,
                        alignment: Alignment.topCenter,
                        // padding: const EdgeInsets.only(bottom: 5),
                        child: TextField(
                          textCapitalization:
                          TextCapitalization.characters,
                          controller: state.txtBoardingOfficer2,
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
                            hintText: "Boarding Officer 2",
                            hintStyle: GoogleFonts.lato(
                                textStyle:TextStyle(
                                    fontSize: objfun.FontMedium,
                                    fontWeight: FontWeight.bold,
                                    color: colour.commonColorLight)),
                            suffixIcon: InkWell(
                                child: Icon(
                                    (state.txtBoardingOfficer2
                                        .text.isNotEmpty)
                                        ? Icons.close
                                        : Icons.search_rounded,
                                    color: colour.commonColorred,
                                    size: 30.0),
                                onTap: () async {
                                  await OnlineApi.SelectEmployee(
                                      context, '', 'Operation');
                                  if (state.txtBoardingOfficer2.text == "") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                          const Employee(
                                              Searchby: 1,
                                              SearchId: 0)),
                                    ).then((dynamic value) async {
                                      state.setState(() {
                                        state.txtBoardingOfficer2.text =
                                            objfun.SelectEmployeeList
                                                .AccountName;
                                        state.BoardOfficerId2 = objfun
                                            .SelectEmployeeList.Id;
                                        objfun.SelectEmployeeList =
                                            EmployeeModel.Empty();
                                      });
                                    });
                                  } else {
                                    state.setState(() {
                                      state.txtBoardingOfficer2.text = "";
                                      state.BoardOfficerId2 = 0;
                                      objfun.SelectEmployeeList =
                                          EmployeeModel.Empty();
                                    });
                                  }
                                }),
                            fillColor: Colors.black,
                            enabledBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10.0)),
                              borderSide:
                              BorderSide(color: colour.commonColor),
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
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      SizedBox(
                        height: height * 0.06,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
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
                                  cursorColor: colour.commonColor,
                                  controller: state.txtAmount2,
                                  autofocus: false,
                                  showCursor:
                                  state.DisabledAmount2 ? false : true,
                                  readOnly:
                                  state.DisabledAmount2 ? true : false,
                                  decoration: InputDecoration(
                                    hintText: ('Amount 2'),
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
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      SizedBox(
                        height: height * 0.06,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
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
                                  cursorColor: colour.commonColor,
                                  controller: state.txtPortCharges,
                                  autofocus: false,
                                  enabled: state.isAllowed("txtPortCharges"),
                                  showCursor: true,
                                  decoration: InputDecoration(
                                    hintText: ('Port Charges'),
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
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
        ),
        bottomNavigationBar: Card(
          elevation: 6,
          color: colour.commonColorLight,
          //  margin: EdgeInsets.all(15),
          child: SalomonBottomBar(
            duration: const Duration(seconds: 1),
            items: [
              SalomonBottomBarItem(
                icon: const Icon(
                  Icons.info_outline,
                  color: colour.commonColor,
                ),
                title: Text(
                  "",
                  style: TextStyle(
                      color: colour.commonColor,
                      fontSize: width <= 370
                          ? objfun.FontCardText + 2
                          : objfun.FontLow),
                ),
              ),
              SalomonBottomBarItem(
                icon: const Icon(
                  Icons.comment_outlined,
                  color: colour.commonColor,
                ),
                title: Text(
                  "",
                  style: TextStyle(
                      color: colour.commonColor,
                      fontSize: width <= 370
                          ? objfun.FontCardText + 2
                          : objfun.FontLow),
                ),
              ),
              SalomonBottomBarItem(
                icon: const Icon(
                  Icons.directions_boat_filled,
                  color: colour.commonColor,
                ),
                title: Text(
                  "",
                  style: TextStyle(
                      color: colour.commonColor,
                      fontSize: width <= 370
                          ? objfun.FontCardText + 2
                          : objfun.FontLow),
                ),

              ),
              SalomonBottomBarItem(
                icon: const Icon(
                  Icons.directions_boat_filled_outlined,
                  color: colour.commonColor,
                ),
                title: Text(
                  "",
                  style: TextStyle(
                      color: colour.commonColor,
                      fontSize: width <= 370
                          ? objfun.FontCardText + 2
                          : objfun.FontLow),
                ),

              ),
              SalomonBottomBarItem(
                icon: const Icon(
                  Icons.rate_review_outlined,
                  color: colour.commonColor,
                ),
                title: Text(
                  "",
                  style: TextStyle(
                      color: colour.commonColor,
                      fontSize: width <= 370
                          ? objfun.FontCardText + 2
                          : objfun.FontLow),
                ),
              ),
              SalomonBottomBarItem(
                icon: const Icon(
                  Icons.local_shipping_sharp,
                  color: colour.commonColor,
                ),
                title: Text(
                  "",
                  style: TextStyle(
                      color: colour.commonColor,
                      fontSize: width <= 370
                          ? objfun.FontCardText + 2
                          : objfun.FontLow),
                ),
              ),
            ],
            currentIndex: state._tabController.index,
            onTap: (index) => state.setState(() {
              state._tabController.index = index;
            }),
          ),
        ),
      ));
}