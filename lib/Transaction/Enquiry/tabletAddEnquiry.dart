part of 'package:maleva/Transaction/Enquiry/AddEnquiry.dart';

tabletdesign(AddEnquiryStates state, BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;
  return WillPopScope(
      onWillPop: state._onBackPressed,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          key: state.appBarKey,
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
          title: SizedBox(
            height: height * 0.05,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
               Text('FW Entry Update',
                        style: GoogleFonts.lato(
                            textStyle:TextStyle(
                              color: colour.topAppBarColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Alatsi',
                              fontSize: objfun.FontMedium,
                            ))),

                        Text(" - ${state.UserName}",
                            style:GoogleFonts.lato(
                                textStyle: TextStyle(
                                  color: colour.commonColorLight,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Alatsi',
                                  fontSize: objfun.FontLow - 2,
                                ))),

              ],
            ),
          ),
          iconTheme: const IconThemeData(color: colour.topAppBarColor),
          actions: <Widget>[
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
                    state.UpdateForwarding();
                  },
                  child: Text(
                    'Update',
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
          ],

        ),
        drawer: const Menulist(),
        body: const Center(
          child: SpinKitFoldingCube(
            color: colour.spinKitColor,
            size: 35.0,
          ),
        ),

        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: colour.commonColorLight,
          unselectedItemColor: colour.commonHeadingColor.withOpacity(0.5),
          currentIndex: state._tabController.index,
          selectedLabelStyle: GoogleFonts.lato(
            textStyle: TextStyle(

                fontWeight: FontWeight.bold,
                fontSize: objfun.FontLow,
                letterSpacing: 0.3),
          ),
          unselectedLabelStyle:GoogleFonts.lato(
            textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: objfun.FontCardText,
                letterSpacing: 0.3),
          ) ,
          onTap:(index) => state.setState(() {
            state._tabController.index = index;
          }),
          items: const [
            BottomNavigationBarItem(icon: Icon(
              Icons.local_shipping_sharp,
            ),
              label: "FW 1",
            ),
            BottomNavigationBarItem(icon: Icon(
              Icons.local_shipping_sharp,
            ),
              label: "FW 2",
            ),
            BottomNavigationBarItem(icon: Icon(
              Icons.local_shipping_sharp,
            ), label: "FW 3"),
          ],
        ),
      ));
}