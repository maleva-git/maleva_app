part of 'package:maleva/DashBoard/User/UserDashboard.dart';


tabletdesign(HomemobileState state, BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;
  // objfun.FontMedium = 26;
  // objfun.FontLow = 22;
  // objfun.FontLarge = 30;
  // objfun.FontCardText = 20;
  objfun.FontMedium = 22;
  objfun.FontLow = 18;
  objfun.FontLarge = 24;
  objfun.FontCardText = 16;
  return WillPopScope(
      onWillPop: state._onBackPressed,
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          appBar: AppBar(
              title: SizedBox(
                height: height * 0.06,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:  [
                    Text('Dash Board',
                        style: GoogleFonts.lato(textStyle:TextStyle(
                          color: colour.topAppBarColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Alatsi',
                          fontSize:objfun.FontLarge,
                        ))),
                  ],
                ),
              ),
              iconTheme: const IconThemeData(color: colour.topAppBarColor),
              leading: IconTheme(
                data: const IconThemeData(size: 35.0), // Change size here
                child: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu,color: colour.commonHeadingColor,),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ),),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(
                    Icons.exit_to_app,
                    size: 40.0,
                    color: colour.topAppBarColor,
                  ),
                  onPressed: () {
                    objfun.logout(context);
                  },
                ),
              ]),
          drawer:SizedBox(
  width: width*0.30,
  child: const Menulist()),
          body: state.progress == true
              ? Center(
            child: Container(
              width: 400.0,
              height: 450.0,
              decoration: BoxDecoration(
                color: Colors.white24,
                image: DecorationImage(
                  image: objfun.logo,
                  colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(
                        0.5), // Set your desired opacity here
                    BlendMode.dstATop,
                  ),
                  //   fit: BoxFit.scaleDown,
                ),
              ),
            ),
          )
              : Container()));
}