import 'package:flutter/material.dart';
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class VesselType extends StatefulWidget {
  final int Searchby;
  final int SearchId;

  const VesselType({super.key, required this.Searchby, required this.SearchId});

  @override
  _VesselTypestate createState() {
    return _VesselTypestate();
  }
}

class _VesselTypestate extends State<VesselType> {
  bool progress = false;
  final txtSearch = TextEditingController();
  List<String> VesselList = <String>[
    "CONTAINER VESSEL",
    "BULK CARRIER",
    "TANKER VESSEL",
    "CRUISE VESSEL",
    "RORO VESSEL",
    "NAVY VESSEL",
    "TUG BOARD",
    "BOAT SUPPLY",
  ];
  List<String> filtersearchlist = <String>[];

  @override
  void initState() {
    startup();
    super.initState();
  }
  @override
  void dispose() {
    txtSearch.dispose();
    super.dispose();
  }
  Future startup() async {
    filtersearchlist = VesselList;
    setState(() {
      progress = true;
    });
  }

  void search(value) {
    setState(() {
      if (value.isEmpty) {
        filtersearchlist = VesselList;
      } else {
        filtersearchlist = VesselList.where(
                (item) => item.toLowerCase().contains(value.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isTablet = objfun.MalevaScreen != 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colour.commonColor,
        centerTitle: true,
        title: Text(
          'Vessel Type',
          style: GoogleFonts.lato(
            textStyle: TextStyle(
                color: colour.topAppBarColor,
                fontWeight: FontWeight.w700,
                fontSize: objfun.FontLarge,
                letterSpacing: 0.5),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: colour.topAppBarColor, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: !progress
          ? const Center(
              child: SpinKitFoldingCube(color: colour.spinKitColor, size: 35.0),
            )
          : SafeArea(
              child: Center(
                child: Container(
                  width: isTablet ? 600 : width,
                  padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 20 : 16, vertical: 16),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: txtSearch,
                          textInputAction: TextInputAction.search,
                          textCapitalization: TextCapitalization.characters,
                          style: GoogleFonts.lato(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A2E5A),
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search Vessel Type...',
                            hintStyle: GoogleFonts.lato(
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w500,
                            ),
                            prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                          onChanged: search,
                          onSubmitted: search,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: filtersearchlist.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No Vessel Type Found',
                                      style: GoogleFonts.lato(
                                        color: Colors.grey.shade500,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: filtersearchlist.length,
                                itemBuilder: (context, index) {
                                  final item = filtersearchlist[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.03),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                      border: Border.all(color: Colors.grey.shade100),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () {
                                        setState(() {
                                          if (widget.Searchby == 1) {
                                            objfun.SelectedVesselTypeName = item.toString();
                                            Navigator.of(context, rootNavigator: true).pop(context);
                                          }
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: colour.commonColor.withValues(alpha: 0.08),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(Icons.list_alt_rounded, color: colour.commonColor, size: 20),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Text(
                                                item.toString(),
                                                style: GoogleFonts.lato(
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(0xFF1A2E5A),
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 24),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
