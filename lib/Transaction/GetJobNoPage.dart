import 'package:flutter/Material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import '../Transaction/SaleOrderDetails.dart';


class OldGetJobNoPage extends StatefulWidget {

  const OldGetJobNoPage({super.key});

  @override
  _OldGetJobNoPageState createState() => _OldGetJobNoPageState();
}

class _OldGetJobNoPageState extends State<OldGetJobNoPage> {
  bool progress = false;
  late MenuMasterModel menuControl;
  String UserName = objfun.storagenew.getString('Username') ?? "";


  String BillType = "0";
  int SealEmpId1 = 0;
  int SealEmpId2 = 0;
  int SealEmpId3 = 0;
  int BreakEmpId1 = 0;
  int BreakEmpId2 = 0;
  int BreakEmpId3 = 0;
  int SaleOrderId = 0;
  int StatusId = 0;

  final txtStatus = TextEditingController();
  final txtJobNo = TextEditingController();
  final txtENRef1 = TextEditingController();
  final txtENRef2 = TextEditingController();
  final txtENRef3 = TextEditingController();
  final txtSealByEmp1 = TextEditingController();
  final txtSealByEmp2 = TextEditingController();
  final txtSealByEmp3 = TextEditingController();
  final txtBreakByEmp1 = TextEditingController();
  final txtBreakByEmp2 = TextEditingController();
  final txtBreakByEmp3 = TextEditingController();
  final txtExRef1 = TextEditingController();
  final txtExRef2 = TextEditingController();
  final txtExRef3 = TextEditingController();

  @override
  void initState() {
    OnlineApi.GetJobNoForwarding(context,int.parse(BillType));
    startup();
    super.initState();
  }

  @override
  void dispose() {
    txtStatus.dispose();
    txtJobNo.dispose();
    txtENRef1.dispose();
    txtENRef2.dispose();
    txtENRef3.dispose();
    txtSealByEmp1.dispose();
    txtSealByEmp2.dispose();
    txtSealByEmp3.dispose();
    txtBreakByEmp1.dispose();
    txtBreakByEmp2.dispose();
    txtBreakByEmp3.dispose();
    txtExRef1.dispose();
    txtExRef2.dispose();
    txtExRef3.dispose();
    super.dispose();
  }

  Future startup() async {
    setState(() {
      progress = true;
    });
  }

  void clear() {
    BillType = "0";
    SaleOrderId = 0;

    txtJobNo.text = "";

    setState(() {
      progress =true;
    });

  }

  void clearOverlay() {
    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry = null;
    }
    showsearch = false;
  }

  bool showsearch = false;
  OverlayEntry? overlayEntry;
  String previousSearchTerm = '';
  GlobalKey appBarKey = GlobalKey();
  /// Fetches the place autocomplete list with the query [place].
  void autoCompleteSearch(String place, bool show) async {

    if (show == false) {
      if (place == previousSearchTerm) {
        return;
      }
      previousSearchTerm = place;
      clearOverlay();

      if (place.isEmpty) {
        return;
      }
      setState(() {
        showsearch = true;
      });
    } else {
      // if (context == null) {
      //   return;
      // }
      clearOverlay();
      setState(() {
        showsearch = true;
      });
    }
    try {
      place = place.replaceAll(" ", "+");
      List<Widget> suggestions = [];

      List<dynamic> predictions = [];

      if (place == '') {
        predictions = objfun.JobNoList;
      } else {
        predictions = objfun.JobNoList
            .where((element) =>
            element['CNumber'].toString().contains(place))
            .toList();
      }
      if (predictions.isNotEmpty) {
        for (int i = 0; i < predictions.length; i++) {
          suggestions.add(InkWell(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(predictions[i]['CNumber'].toString()) ,
            ),
            onTap: () {
              txtJobNo.text = predictions[i]['CNumber'].toString();
              SaleOrderId = predictions[i]['Id'];
              FocusScope.of(context).requestFocus(FocusNode());
              clearOverlay();
            },
          ));
        }
      }
      if(suggestions.isEmpty){
        objfun.toastMsg("Enter Correct Job No", " ", context);
        return;
      }
      displayAutoCompleteSuggestions(suggestions,context);
    } finally {}
  }

  void displayAutoCompleteSuggestions(List<Widget> suggestions,context) {

    double height = MediaQuery.of(context).size.height;
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;

    final RenderBox? appBarBox =
    appBarKey.currentContext!.findRenderObject() as RenderBox?;

    clearOverlay();
    setState(() {
      showsearch = true;
    });
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: null,
        top: objfun.MalevaScreen == 1
            ? appBarBox!.size.height + height * 0.25 + 100
            : appBarBox!.size.height + height * 0.15 + 100 ,
        left:objfun.MalevaScreen == 1?10: 250,
        right:objfun.MalevaScreen == 1?10: 250,
        child: Material(
          color: colour.ButtonForeColor.withOpacity(0.85),
          elevation: 1,
          textStyle:GoogleFonts.lato(
              textStyle: TextStyle(
              color: colour.commonColor,
              fontWeight: FontWeight.bold,
              fontSize: objfun.FontLow,
              letterSpacing: 0.3)),
          child:
          SizedBox(height: 350, child: ListView(children: suggestions)),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry!);
  }
  Future<bool> _onBackPressed() async {
    if(overlayEntry != null){
      clearOverlay();
      return false;
    }
    Navigator.of(context).pop();

    return true;
  }


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return WillPopScope(
        onWillPop: _onBackPressed,
        child: objfun.MalevaScreen == 1
            ? Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if(overlayEntry != null){
                    clearOverlay();
                  }
                  Navigator.pop(context);
                },
              ),
              key: appBarKey,
            ),
            resizeToAvoidBottomInset: true,
            backgroundColor: colour.commonColorLight.withOpacity(0.9),

            body: progress == false
                ? const Center(
              child: SpinKitFoldingCube(
                color: colour.spinKitColor,
                size: 35.0,
              ),
            )
                :  Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children:[    Card(
                  elevation: 15.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0), // Optional: Add border radius
                  ),
                  margin: const EdgeInsets.all(10.0),
                  child: Container(
                    padding: const EdgeInsets.all(20),


                    child: Column(
                      children: <Widget>[
                        Row(
                            children: [
                              Expanded(
                                // width: 250,
                                flex: 1,
                                child: Radio(
                                  value: "0",
                                  groupValue: BillType,
                                  onChanged: (value) {
                                    setState(() {
                                      BillType = value.toString();
                                    });
                                    OnlineApi.GetJobNoForwarding(context,int.parse(BillType));
                                  },
                                ),
                              ),
                              Expanded(
                                // width: 250,
                                flex: 1,
                                child: Text(
                                  "MY",
                                  style:GoogleFonts.lato(
                                      textStyle: TextStyle(
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
                                  groupValue: BillType,
                                  onChanged: (value) {

                                    setState(() {
                                      BillType = value.toString();
                                    });
                                    OnlineApi.GetJobNoForwarding(context,int.parse(BillType));
                                  },
                                ),
                              ),
                              Expanded(
                                // width: 250,
                                flex: 1,
                                child: Text(
                                  "TR",
                                  style:GoogleFonts.lato(
                                      textStyle: TextStyle(
                                          color: colour.commonColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: objfun.FontMedium,
                                          letterSpacing: 0.3)),
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
                              controller: txtJobNo,
                              autofocus: false,
                              showCursor: true,
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
                              onChanged: (value) {
                                Future.delayed(const Duration(milliseconds: 500));
                                setState(() {
                                  autoCompleteSearch(value, false);
                                });
                              },
                            ),
                          ),
                          ),

                        ],),

                        const SizedBox(height: 7,),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
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
                                padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 7),
                              ),
                              onPressed: () async {
                                if(txtJobNo.text.isEmpty){
                                  objfun.toastMsg('Enter Job No', '', context);
                                  return;
                                }
                                await OnlineApi.EditSalesOrder(
                                    context, SaleOrderId, int.parse(txtJobNo.text));
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
                            ),
                            ElevatedButton(
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
                                padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 7),
                              ),
                              onPressed: () async {
                                Navigator.pop(context);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'CLOSE',
                                    style: GoogleFonts.lato(
                                        fontSize: objfun.FontMedium,
                                        // height: 1.45,
                                        fontWeight: FontWeight.bold,
                                        color: colour.commonColorLight),
                                  ),
                                  const SizedBox(width: 5,),
                                  const Icon(Icons.close,
                                    color: colour.commonColorLight,
                                  )],
                              ),
                            ),
                          ],
                        ),


                      ],
                    ),
                  ),
                )]
            )


        )
            : Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back,size: 35,),
                onPressed: () {
                  if(overlayEntry != null){
                    clearOverlay();
                  }
                  Navigator.pop(context);
                },
              ),
              key: appBarKey,
            ),
            resizeToAvoidBottomInset: true,
            backgroundColor: colour.commonColorLight.withOpacity(0.9),

            body: progress == false
                ? const Center(
              child: SpinKitFoldingCube(
                color: colour.spinKitColor,
                size: 35.0,
              ),
            )
                :  Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children:[  
                  Padding(padding:const EdgeInsets.only(left: 250,right: 250) ,
                  child: Card(
                    elevation: 15.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0), // Optional: Add border radius
                    ),
                    margin: const EdgeInsets.all(10.0),
                    child: Container(
                      padding: const EdgeInsets.all(20),


                      child: Column(
                        children: <Widget>[
                          Row(
                              children: [
                                const Expanded(
                                  flex:2,
                                  child: Text(""),
                                ),
                                Expanded(
                                  // width: 250,
                                  flex: 1,
                                  child: Transform.scale(
                                    scale:1.5,
                                    child: Radio(
                                      value: "0",
                                      groupValue: BillType,
                                      onChanged: (value) {
                                        setState(() {
                                          BillType = value.toString();
                                        });
                                        OnlineApi.GetJobNoForwarding(context,int.parse(BillType));
                                      },
                                    ),
                                  )
                                ),
                                Expanded(
                                  // width: 250,
                                  flex: 1,
                                  child: Text(
                                    "MY",
                                    style:GoogleFonts.lato(
                                        textStyle: TextStyle(
                                            color: colour.commonColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: objfun.FontMedium,
                                            letterSpacing: 0.3)),
                                  ),
                                ),
                                Expanded(
                                  // width: 250,
                                  flex: 1,
                                  child: Transform.scale(
                                    scale:1.5,
                                    child:Radio(
                                    value: "1",
                                    groupValue: BillType,
                                    onChanged: (value) {

                                      setState(() {
                                        BillType = value.toString();
                                      });
                                      OnlineApi.GetJobNoForwarding(context,int.parse(BillType));
                                    },
                                  ),)
                                ),
                                Expanded(
                                  // width: 250,
                                  flex: 1,
                                  child: Text(
                                    "TR",
                                    style:GoogleFonts.lato(
                                        textStyle: TextStyle(
                                            color: colour.commonColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: objfun.FontMedium,
                                            letterSpacing: 0.3)),
                                  ),
                                ),
                                const Expanded(
                                  flex:2,
                                  child: Text(""),
                                ),

                              ]),
                          Row(children: [
                            Expanded(flex:3,child:Container(
                              width: objfun.SizeConfig.safeBlockHorizontal * 99,
                              height: objfun.SizeConfig.safeBlockVertical * 8,
                              alignment: Alignment.topCenter,
                              padding: const EdgeInsets.only(bottom: 5,left: 15,right: 15),
                              child: TextField(
                                cursorColor: colour.commonColor,
                                controller: txtJobNo,
                                autofocus: false,
                                showCursor: true,
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
                                onChanged: (value) {
                                  Future.delayed(const Duration(milliseconds: 500));
                                  setState(() {
                                    autoCompleteSearch(value, false);
                                  });
                                },
                              ),
                            ),
                            ),

                          ],),
                          const SizedBox(height: 7,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
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
                                  padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 7),
                                ),
                                onPressed: () async {
                                  if(txtJobNo.text.isEmpty){
                                    objfun.toastMsg('Enter Job No', '', context);
                                    return;
                                  }
                                  await OnlineApi.EditSalesOrder(
                                      context, SaleOrderId, int.parse(txtJobNo.text));
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
                              ),
                              const SizedBox(width: 30,),
                              ElevatedButton(
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
                                  padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 7),
                                ),
                                onPressed: () async {
                                  Navigator.pop(context);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'CLOSE',
                                      style: GoogleFonts.lato(
                                          fontSize: objfun.FontMedium,
                                          // height: 1.45,
                                          fontWeight: FontWeight.bold,
                                          color: colour.commonColorLight),
                                    ),
                                    const SizedBox(width: 5,),
                                    const Icon(Icons.close,
                                      color: colour.commonColorLight,
                                      size: 35,
                                    )],
                                ),
                              ),
                            ],
                          ),


                        ],
                      ),
                    ),
                  ),
                  )
                ]
            )


        )
        );
  }
}