part of 'package:maleva/DashBoard/User/UserDashboard.dart';


mobiledesign(HomemobileState state, BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;
  if (width <= 370) {
    objfun.FontLarge = 22;
    objfun.FontMedium = 18;
    objfun.FontLow = 16;
    objfun.FontCardText = 12;
  }
  else{
    objfun.FontLarge = 24;
    objfun.FontMedium = 20;
    objfun.FontLow = 18;
    objfun.FontCardText = 14;
  }
  return WillPopScope(
      onWillPop: state._onBackPressed,
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          appBar: AppBar(
              title: SizedBox(
                height: height * 0.05,
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
              actions: <Widget>[
                IconButton(
                  icon: const Icon(
                    Icons.exit_to_app,
                    size: 30.0,
                    color: colour.topAppBarColor,
                  ),
                  onPressed: () {
                    objfun.logout(context);
                  },
                ),
              ]),
          drawer: const Menulist(),
          body: state.progress == true
              ? Center(
            child: Container(
              width: 300.0,
              height: 250.0,
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