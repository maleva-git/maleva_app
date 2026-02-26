import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maleva/GoogleReview/ReviewEntryScreen.dart';
import 'package:maleva/Transport/Fuel/FuelEntry.dart';

import 'package:maleva/core/colors/colors.dart' as colour;

import 'package:maleva/core/utils/clsfunction.dart' as objfun;

import 'package:maleva/core/models/model.dart';
import 'package:maleva/Transaction/SaleOrder/SalesOrderView.dart';

import '../Boarding/BoardingStatusUpdate.dart';
import '../MailInbox/MailInboxView.dart';
import '../Operation/FWBreakSealUpdate.dart';
import '../Operation/FWSmkUpdate.dart';
import '../Operation/FWUpdate.dart';
import '../Operation/ForwardingSalary/ForwardingSalaryUpdate.dart';
import '../PreAlertReport/PreAlertReport.dart';
import '../SaleOrderView/SaleOrderView.dart';
import '../Transaction/AirFrieght/AirFrieght.dart';
import '../Transaction/Enquiry/EnquiryView.dart';
import '../Transaction/EnquiryTR/EnquiryTRView.dart';
import '../Transaction/GetJobNoPage.dart';
import '../Transaction/JobStatus/JobStatusUpdate.dart';
import '../Transaction/Planning/PlanningView.dart';
import '../Transaction/SpotSaleOrder/SpotSaleOrder.dart';
import '../Transaction/Stock/StockInEntry.dart';
import '../Transaction/Stock/StockTransferUpdate.dart';
import '../Transaction/Stock/StockUpdate.dart';
import '../Transaction/VesselPlanning/VesselPlanningView.dart';
import '../Transport/LicenseUpdate.dart';
import '../Transport/Maintenance.dart';
import '../Transport/RTI/UpdateRTIDetails.dart';
import '../DashBoard/User/UserDashboard.dart';

import '../DashBoard/OperationAdmin/OperationAdminDashboard.dart';

class Menulist extends StatefulWidget {
  const Menulist({super.key});

  @override
  _MenulistState createState() => _MenulistState();
}

class _MenulistState extends State<Menulist> {
  // List<objfun.MenuMaster> childclass = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenheight = MediaQuery.of(context).size.height;
    return Drawer(

      child: SafeArea(
        child: ListView(
          children: <Widget>[
            Container(
              width:objfun.MalevaScreen == 1
                  ?  225.0 :200,
              height: objfun.MalevaScreen == 1
                  ? 175.0 : 190,
              decoration: BoxDecoration(
                color: Colors.white24,
                image: DecorationImage(
                  image: objfun.logo,
                    fit: BoxFit.fitHeight,
                ),
              ),
            ),
            const SizedBox(
              height: 7.0,
            ),
            SizedBox(
              width: 150,
              height: 25,
              child: Text(
               objfun.appversion,
                textAlign: TextAlign.center,
                style: GoogleFonts.karla(
                    fontSize: 20.0,
                    // height: 1.45,
                    fontWeight: FontWeight.bold,
                    color: colour.commonColorred),
              ),
            ),

            // Container(
            //     alignment: Alignment.topLeft,
            //     color: Colors.white,
            //     child:ListTile(
            //     title: Text('LOGOUT'),
            //      onTap: () {
            //       objfun.logOut();
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(builder: (context) => Login()),
            //       );
            //     },)),
            const Divider(
              height: 1,
            ),
            Container(
                height:  objfun.MalevaScreen == 1
                    ? screenheight * 0.75 : screenheight * 0.55,
                color: Colors.white24,
                child: ListView.builder(
                  itemCount: (objfun.parentclass.length),
                  itemBuilder: (BuildContext context, int index) {
                    return Menulistnew(objfun.parentclass[index], context);
                  },
                )),
          ],
        ),
      ),
    );
  }
}

class Menulistnew extends StatelessWidget {
  const Menulistnew(this.entry, this.context, {super.key});
  final MenuMasterModel entry;
  final BuildContext context;
// Suppose objfun.objMenuMaster is your menu list

  List<Widget> _childlsit(List<MenuMasterModel> parent) {
    List<Widget> child = [];

    for (int i = 0; i < parent.length; i++) {
      List<MenuMasterModel> subchild = [];
      subchild.addAll(objfun.objMenuMaster
          .where((element) => element.ParentId == parent[i].Id)
          .toList());
      if (subchild.isEmpty) {
        String menu = parent[i].FormText;
        child.add(ListTile(
          onTap: () {
            //Master

            if (parent[i].FormText == "Sales Order") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SaleOrderView()),
              ).then((dynamic value) {});
            }
            else if (parent[i].FormText == "Planning") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PlanningView()),
              ).then((dynamic value) {

              });
            }
            else if (parent[i].FormText == "SpotSaleOrder") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Spotsaleorder()),
              ).then((dynamic value) {

              });
            }
            else if (parent[i].FormText == "PreAlertReport") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PreAlertreport()),
              ).then((dynamic value) {

              });
            }
            else if (parent[i].FormText == "Email InBox") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EmailScreen()),
              ).then((dynamic value) {

              });
            }
            else if (parent[i].FormText == "Google Review") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReviewEntryScreen()),
              ).then((dynamic value) {

              });
            }
            else if (parent[i].FormText == "Update Air Frieght") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AirFrieghtUpdate()),
              ).then((dynamic value) {

              });

            }
            else if (parent[i].FormText == "JobStatus Update") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const JobStatusUpdate()),
              ).then((dynamic value) {

              });

            }
            else if (parent[i].FormText == "RTI") {

            }
            else if (parent[i].FormText == "Forwarding Update") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FWUpdate()),
              ).then((dynamic value) {});
            }
            else if (parent[i].FormText == "Forwarding Exit Update") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FWUpdateBreakSeal()),
              ).then((dynamic value) {

              });
            }
            else if (parent[i].FormText == "View Sale Order") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GetJobNoPage()),
              ).then((dynamic value) {

              });
            }
            else if (parent[i].FormText == "Forwarding Salary") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ForwardingSalaryUpdate()),
              ).then((dynamic value) {

              });
            }
            else if (parent[i].FormText == "Stock In Entry") {

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Stockinentry()),
              ).then((dynamic value) {

              });

            }
            else if (parent[i].FormText == "Stock Update") {

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StockUpdate()),
              ).then((dynamic value) {

              });

            }
            else if (parent[i].FormText == "Stock Transfer") {

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StockTransferUpdate()),
              ).then((dynamic value) {

              });

            }
            else if (parent[i].FormText == "Enquiry Master") {

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EnquiryView()),
              ).then((dynamic value) {

              });
            }
            else if (parent[i].FormText == "EnquiryTR Master") {

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EnquiryTRView()),
              ).then((dynamic value) {

              });
            }
            else if (parent[i].FormText == "Update Boarding Details") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BoardingStatusUpdate()),
              ).then((dynamic value) {

              });
            }
            else if (parent[i].FormText == "Maintenance") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Maintenance()),
              ).then((dynamic value) {

              });
            }
            else if (parent[i].FormText == "View") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SaleOrderView()),
              ).then((dynamic value) {

              });
            }
            else if (parent[i].FormText == "License Update") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LicenseUpdate()),
              ).then((dynamic value) {

              });
            }
            else if (parent[i].FormText == "Update RTI Details") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UpdateRTI()),
              ).then((dynamic value) {

              });
            }
            else if (parent[i].FormText == "Forwarding SMK Update") {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FWSmkUpdate()),
              ).then((dynamic value) {

              });
            }
            else if (parent[i].FormText == "Fuel Entry") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FuelEntry()),
              ).then((dynamic value) {

              });
            } else if (parent[i].FormText == "Vessel Planning") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VesselPlanningView()),
              //  MaterialPageRoute(builder: (context) => const OperationAdminDashboard()),
              ).then((dynamic value) {

              });
            }
            else if (parent[i].FormText == "Logout") {
              objfun.logout(context);
            }
            //Transaction
          },
          title: Text(
            menu,
            style: GoogleFonts.lato(
              textStyle:  TextStyle(
                color: colour.commonColor,
                fontWeight: FontWeight.bold,
                fontSize: objfun.FontCardText + 2
              ),
            ),
          ),
        ));
      } else {
        String menu = parent[i].FormText;

        child.add(
          ExpansionTile(
            key: PageStorageKey<MenuMasterModel>(parent[i]),
            title: Text(
              menu,
              style: GoogleFonts.lato(
                textStyle:  TextStyle(
                  color: colour.commonColor,
                  fontWeight: FontWeight.bold,
                  fontSize: objfun.FontLow
                ),
              ),
            ),
            children: _childlsit(subchild),
          ),
        );
//      return child;
      }
    }
    return child;
  }

  // This function recursively creates the multi-level list rows.
  Widget _buildTiles(MenuMasterModel parent) {
    List<MenuMasterModel> subchild = [];
    subchild.addAll(objfun.objMenuMaster
        .where((element) => element.ParentId == parent.Id)
        .toList());
    if (subchild.isEmpty) {
      String menu = parent.FormText;

      return ListTile(
        title: Text(
          menu,
          style: GoogleFonts.lato(
            textStyle:  TextStyle(
                color: colour.commonColor,
                fontWeight: FontWeight.bold,
                fontSize: objfun.FontLow),
          ),
        ),
        onTap: () {
          //Master
          if (parent.FormText == "Payment Entry") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Homemobile()),
            ).then((dynamic value) {});
          } else if (parent.FormText == "RTI") {

          } else if (parent.FormText == "Planning") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PlanningView()),
            ).then((dynamic value) {

            });
          }
          else if (parent.FormText == "Email InBox") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EmailScreen()),
            ).then((dynamic value) {

            });
          }
          else if (parent.FormText == "Google Review") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReviewEntryScreen()),
            ).then((dynamic value) {

            });
          }
            else if (parent.FormText == "Forwarding Update") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FWUpdate()),
            ).then((dynamic value) {});
          }
            else if (parent.FormText == "Forwarding Exit Update") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FWUpdateBreakSeal()),
            ).then((dynamic value) {

            });
          }
          else if (parent.FormText == "View Sale Order") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GetJobNoPage()),
            ).then((dynamic value) {

            });

          }
          else if (parent.FormText == "Update Air Frieght") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AirFrieghtUpdate()),
            ).then((dynamic value) {

            });

          }
          else if (parent.FormText == "JobStatus Update") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const JobStatusUpdate()),
            ).then((dynamic value) {

            });

          }
          else if (parent.FormText == "Update Boarding Details") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BoardingStatusUpdate()),
            ).then((dynamic value) {

            });
          }
          else if (parent.FormText == "Maintenance") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Maintenance()),
            ).then((dynamic value) {

            });
          }
          else if (parent.FormText == "License Update") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LicenseUpdate()),
            ).then((dynamic value) {

            });
          } else if (parent.FormText == "Update RTI Details") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UpdateRTI()),
            ).then((dynamic value) {

            });
          }
          else if (parent.FormText == "Forwarding SMK Update") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FWSmkUpdate()),
            ).then((dynamic value) {

            });
          }
          else if (parent.FormText == "Fuel Entry") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FuelEntry()),
            ).then((dynamic value) {

            });
          }
          else if (parent.FormText == "Vessel Planning") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const VesselPlanningView()),
            ).then((dynamic value) {

            });
          }

       else if (parent.FormText == "Logout") {
            objfun.logout(context);
          }
          //Transaction
        },
      );
    } else {
      String menu = parent.FormText;

      return ExpansionTile(
        key: PageStorageKey<MenuMasterModel>(parent),
        title: Text(
          menu,
          style: GoogleFonts.lato(
            textStyle:  TextStyle(
                color: colour.commonColor,
                fontWeight: FontWeight.bold,
                fontSize: objfun.FontLow),
          ),
        ),
        children: _childlsit(subchild),
      );
//    );
//      return child;
    }
//
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(entry);
  }
}
