part of 'package:maleva/Transaction/Planning/PlanningDetails.dart';


mobiledesign(PlanningDetailsState state, BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;
  Widget loadgridheader() {
    return Card(
      color: colour.commonColor, // Header background
      elevation: 6,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: colour.commonColor.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ===== ROW 1 =====
            Row(
              children: [
                _headerText("S.No", flex: 1),
                _headerText("Remarks", flex: 3),
                _headerText("Truck", flex: 2),
              ],
            ),

            const SizedBox(height: 6),
            const Divider(color: Colors.white54, height: 1),

            /// ===== ROW 2 =====
            const SizedBox(height: 6),
            Row(
              children: [
                _headerText("Pickup Date", flex: 3),
                _headerText("Delivery Date", flex: 3),
              ],
            ),

            const SizedBox(height: 6),

            /// ===== ROW 3 =====
            Row(
              children: [
                _headerText("Origin", flex: 3),
                _headerText("Destination", flex: 3),
                _headerText("Package", flex: 4),
              ],
            ),

            const SizedBox(height: 6),

            /// ===== ROW 4 =====
            Row(
              children: [
                _headerText("Customer", flex: 4),
                _headerText("Job No", flex: 2),
              ],
            ),

            const SizedBox(height: 6),

            /// ===== ROW 5 =====
            Row(
              children: [
                _headerText("Vessel", flex: 3),
                _headerText("Status", flex: 2),
                _headerText("PIC", flex: 3),
              ],
            ),

            const SizedBox(height: 6),

            /// ===== ROW 6 =====
            Row(
              children: [
                _headerText("LETA", flex: 3),
                _headerText("OETA", flex: 2),
              ],
            ),
          ],
        ),
      ),
    );
  }



  return WillPopScope(
    onWillPop: state._onBackPressed,
    child: Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,

      appBar: AppBar(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Planning Details',
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    color: colour.topAppBarColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Alatsi',
                    fontSize: objfun.FontMedium,
                  ),
                ),
              ),
              Text(
                state.UserName,
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    color: colour.commonColorLight,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Alatsi',
                    fontSize: objfun.FontLow - 2,
                  ),
                ),
              ),
            ],
          ),
        ),
        iconTheme: const IconThemeData(color: colour.topAppBarColor),
      ),

      drawer: const Menulist(),

      body: state.progress == false
          ? const Center(
        child: SpinKitFoldingCube(
          color: colour.spinKitColor,
          size: 35.0,
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [

            /// ===== HEADER =====
            loadgridheader(),

            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: state.searchController,
                onChanged: state.searchPlanning,
                decoration: InputDecoration(
                  hintText: "Search by Planning No / PIC / Date / Port",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: state.searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      state.searchController.clear();
                      state.searchPlanning('');
                    },
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            /// ===== LIST =====
            Expanded(
              child: ListView.builder(
                itemCount: state.filteredPlanningList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: buildPlanningCard(index, height,  state),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Updated _headerText function
Widget _headerText(String text, {int flex = 1, Color color = Colors.white}) {
  return Expanded(
    flex: flex,
    child: Text(
      text,
      style: GoogleFonts.lato(
        textStyle: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: objfun.FontLow,
          letterSpacing: 0.3,
        ),
      ),
    ),
  );
}
Widget buildPlanningCard(int index, double height, state  ) {
  return SizedBox(
    height: height * 0.25,
    child: Card(
      elevation: 6,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: colour.commonColor.withOpacity(0.4),
          width: 1,

        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ===== TOP ROW =====
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: colour.commonColor,
                  child: Text(
                    "${index + 1}",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    state.filteredPlanningList[index]["Remarks"] ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lato(
                      fontSize: objfun.FontCardText + 1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colour.commonColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    state.filteredPlanningList[index]["JobNo"] ?? "",
                    style: GoogleFonts.lato(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: colour.commonColor,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(),

            Row(
              children: [
                Expanded(
                  child: _infoText(
                    "Pickup",
                    state.filteredPlanningList[index]["SPickupDate"],
                  ),
                ),
                Expanded(
                  child: _infoText(
                    "Delivery",
                    state.filteredPlanningList[index]["SDeliveryDate"],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                Expanded(
                  child: _infoText(
                    "Origin",
                    state.filteredPlanningList[index]["Origin"],
                  ),
                ),
                Expanded(
                  child: _infoText(
                    "Destination",
                    state.filteredPlanningList[index]["Destination"],
                  ),
                ),

                Expanded(
                  child: _infoText(
                    "Package",
                    state.filteredPlanningList[index]["pkg"],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),



            Row(
              children: [
                Expanded(
                  child: _infoText(
                    "CustomerName",
                    state.filteredPlanningList[index]["CustomerName"],
                  ),
                ),
                Expanded(
                  child: _infoText(
                    "TruckName",
                    state.filteredPlanningList[index]["TruckName"],
                  ),
                ),


              ],
            ),

      /*      Row (
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    objfun.PlanningEditList[index]["CustomerName"] ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
                Text(
                  "Job #${objfun.PlanningEditList[index]["JobNo"]}",
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colour.commonColor,
                  ),
                ),
              ],
            ),*/

            const SizedBox(height: 6),

            Row(
              children: [
                Expanded(
                  child: _infoText(
                    "Vessel",
                    state.filteredPlanningList[index]["VesselName"],
                  ),
                ),

                Expanded(
                  child: _infoText(
                    "JobStatus",
                    state.filteredPlanningList[index]["JobStatus"],
                  ),
                ),

                Expanded(
                  child: _infoText(
                    "PIC",
                    state.filteredPlanningList[index]["EmployeeName"],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                Expanded(
                  child: _infoText(
                    "LETA",
                    state.filteredPlanningList[index]["LETA"],
                  ),
                ),
                Expanded(
                  child: _infoText(
                    "OETA",
                    state.filteredPlanningList[index]["OETA"],
                  ),
                ),
              ],
            ),




          ],
        ),
      ),
    ),
  );
}
Widget _infoText(String title, String? value) {
  return
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.lato(
            fontSize: 9, // smaller
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2), // small spacing
        Text(
          value ?? "-",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.lato(
            fontSize: 11, // slightly smaller
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );

}
