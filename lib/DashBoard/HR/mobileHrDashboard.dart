part of 'HrDashboard.dart';

Widget mobiledesign(HrDashboardState state, BuildContext context) {
  return WillPopScope(
    onWillPop: state._onBackPressed,
    child: DefaultTabController(
      length: 9,
      child: Scaffold(
        backgroundColor: Color(0xFFF1F5F9),
        appBar: AppBar(

          backgroundColor: Color(0xff0e387a),
          title: Text('HR Dashboard',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 20, color: Colors.white)),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: Container(
              color: Color(0xff0e387a),
              child: TabBar(
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
                unselectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w400),
                tabs: [
                  Tab(icon: Icon(Icons.local_gas_station, size: 20), text: 'Fuel'),
                  Tab(icon: Icon(Icons.speed, size: 20), text: 'Speed'),
                  Tab(icon: Icon(Icons.access_time, size: 20), text: 'Engine'),
                  Tab(icon: Icon(Icons.compare_arrows, size: 20), text: 'Difference'),
                  Tab(icon: Icon(Icons.compare_arrows, size: 20), text: 'Driver View'),
                  Tab(icon: Icon(Icons.compare_arrows, size: 20), text: 'License View'),
                  Tab(icon: Icon(Icons.compare_arrows, size: 20), text: 'Employee View'),
                  Tab(icon: Icon(Icons.compare_arrows, size: 20), text: 'Truck View'),
                  Tab(icon: Icon(Icons.compare_arrows, size: 20), text: 'Spare Parts Entry View'),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.exit_to_app,
                size: 30.0,
                color: Colors.white,
              ),
              onPressed: () {
                objfun.logout(context);
              },
            ),
          ]

        ),
        drawer: const Menulist(),
        body: TabBarView(
          children: [
            _buildFuelFillingTab(state),
            _buildSpeedReportTab(state),
            _buildEngineHoursTab(state),
            _buildFuelDiffeentTab(state),
            _buildDriverViewTab(state),
            _buildLicenseViewTab(state),
            _buildEmployeeViewTab(state),
            _buildTruckViewTab(state),
            _buildTruckSparePartsView(state),
          ],
        ),
      ),
    ),
  );
}

Widget _buildTruckSparePartsView(HrDashboardState state){

  return Scaffold(
    appBar: AppBar(
      title: Text("Saved Spare Entries"),
      centerTitle: true,
      elevation: 3,
    ),

    body: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // ---------------- Date Filter ---------------- //
          // ---------------- Date Filter ---------------- //
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: state.fromCtrl,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "From Date",
                          prefixIcon: Icon(Icons.date_range),
                          border: OutlineInputBorder(),
                        ),
                        onTap: state.pickFromDate,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: state.toCtrl,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "To Date",
                          prefixIcon: Icon(Icons.date_range),
                          border: OutlineInputBorder(),
                        ),
                        onTap: state.pickToDate,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Search Button Full Width
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.fetchData,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.blue,
                    ),
                    child: Text(
                      "Search",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),


          SizedBox(height: 20),

          // ---------------- Loading Indicator ---------------- //
          if (state.progress) Center(child: CircularProgressIndicator()),

          // ---------------- Result List ---------------- //
          if (!state.progress)
            Expanded(
              child: state.spareList.isEmpty
                  ? Center(
                child: Text(
                  "No Records Found",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: state.spareList.length,
                itemBuilder: (context, index) {
                  var item = state.spareList[index];

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.local_shipping, color: Colors.blue),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Truck: ${item['TruckName']}",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 6),

                          Text(
                            "Spare Parts: ${item['SpareParts']}",
                            style: TextStyle(fontSize: 16),
                          ),

                          SizedBox(height: 6),

                          Text(
                            "Amount: ₹ ${item['Amount']}",
                            style: TextStyle(fontSize: 16),
                          ),

                          SizedBox(height: 6),

                          Text(
                            "Date: ${item['EntryDate']}",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),

                          SizedBox(height: 12),

                          if (item['DocumentPath'] != "" && item['DocumentPath'] != null)

                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => ImagePreviewDialog(
                                    imageUrl: objfun.port + item['DocumentPath'],
                                  ),
                                );
                              },
                              child: Image.network(
                                objfun.port + item['DocumentPath'],
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            )

                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    ),
  );


}


Widget _buildTruckViewTab(HrDashboardState state) {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  return StatefulBuilder(
    builder: (context, setState) {
      final filteredList = state.TruckViewRecords.where((truck) {
        final name = (truck.TruckName ?? '').toLowerCase();
        final number = (truck.TruckNumber ?? '').toLowerCase();
        return name.contains(searchQuery.toLowerCase()) ||
            number.contains(searchQuery.toLowerCase());
      }).toList();

      return Container(
        color: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🧭 Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple.shade400, Colors.purple.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.shade200.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.local_shipping_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Truck Overview',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'View all trucks and expiry details at a glance',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🔍 Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search Truck Name or Number...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),

            // 🚚 Truck List
            Expanded(
              child: filteredList.isEmpty
                  ? const Center(
                child: Text(
                  'No trucks found 🚛',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final record = filteredList[index];
                  final isActive = record.Active != 0;
                  final borderColor = isActive
                      ? Colors.green
                      : Colors.redAccent.shade100;

                  return _buildTruckCard(record, borderColor, isActive);
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
Widget _buildTruckCard(record, Color borderColor, bool isActive) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOut,
    margin: const EdgeInsets.only(bottom: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: borderColor, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🚛 Truck Header
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.purple.shade100,
                child: const Icon(Icons.local_shipping,
                    color: Colors.purple, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded( // ✅ Fix overflow
                child: Text(
                  record.TruckName ?? 'Unnamed Truck',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: isActive
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Divider(color: Colors.grey.shade300),

          // 🧾 Truck Basic Info
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _buildStatusChip('TruckNumber', record.TruckNumber),
              _buildStatusChip('TruckNumber1', record.TruckNumber1),
              _buildStatusChip('Type', record.TruckType),
              _buildStatusChip('RotexMyExp', record.RotexMyExp),
              _buildStatusChip('RotexSGExp', record.RotexSGExp),
              _buildStatusChip('RotexSGExp1', record.RotexSGExp1),
            ],
          ),

          const SizedBox(height: 10),
          Divider(color: Colors.grey.shade300),

          // ⚙️ Maintenance
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _buildStatusChip('RotexMyExp1', record.RotexMyExp1),
              _buildStatusChip('PuspacomExp1', record.PuspacomExp1),
              _buildStatusChip('ServiceExp', record.ServiceExp),
              _buildStatusChip('ServiceLast', record.ServiceLast),
              _buildStatusChip('AlignmentExp', record.AlignmentExp),
            ],
          ),

          const SizedBox(height: 10),
          Divider(color: Colors.grey.shade300),

          // 🛠️ Service Details
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _buildStatusChip('Align Last', record.AlignmentLast),
              _buildStatusChip('GearOil Exp', record.GearOilExp),
              _buildStatusChip('GearOil Last', record.GearOilLast),
              _buildStatusChip('Grease Exp', record.GreeceExp),
              _buildStatusChip('Grease Last', record.GreeceLast),
              _buildStatusChip('PTPStickerExp', record.PTPStickerExp),
            ],
          ),

          const SizedBox(height: 10),
          Divider(color: Colors.grey.shade300),

          // 🧾 Misc Expiries
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _buildStatusChip('Puspacom Exp', record.PuspacomExp),
              _buildStatusChip('Insurance', record.InsuratnceExp),
              _buildStatusChip('Bonam Exp', record.BonamExp),
              _buildStatusChip('Apad Exp', record.ApadExp),
              _buildStatusChip('Rotex SG Exp', record.RotexSGExp),
            ],
          ),
        ],
      ),
    ),
  );
}
Widget _buildFuelFillingTab(HrDashboardState state) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    child: Column(
      children: [
        Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6366F1).withOpacity(0.1), Color(0xFF8B5CF6).withOpacity(0.1)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.local_gas_station,
                        color: Color(0xFF6366F1), size: 26),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fuel Reports',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Track fuel consumption and usage',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              _buildDateSelector(state),
            ],
          ),
        ),
        Expanded(
          child: state.fuelFillingRecords.isEmpty
              ? _buildEmptyState('No Fuel Records', 'No fuel filling data available for the selected period', Icons.local_gas_station_outlined)
              : _buildFuelList(state),
        ),
      ],
    ),
  );
}
Widget _buildEmptyState(String title, String subtitle, IconData icon) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Color(0xFFF1F5F9),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 80,
            color: Color(0xFF94A3B8),
          ),
        ),
        SizedBox(height: 32),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
        SizedBox(height: 12),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Color(0xFF94A3B8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
  );
}
Widget _buildFuelList(HrDashboardState state) {
  return ListView.builder(
    padding: EdgeInsets.symmetric(horizontal: 16),
    itemCount: state.fuelFillingRecords.length,
    itemBuilder: (context, index) {
      final record = state.fuelFillingRecords[index];
      return Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showFuelFillingDetails(context, record),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF6366F1).withOpacity(0.1), Color(0xFF8B5CF6).withOpacity(0.1)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.local_shipping,
                            color: Color(0xFF6366F1), size: 22),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.vehicle ?? 'Unknown Vehicle',
                              style: GoogleFonts.inter(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              record.driver?.isNotEmpty == true
                                  ? record.driver!
                                  : 'No driver assigned',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.chevron_right,
                            color: Color(0xFF64748B), size: 20),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      if (record.filled?.isNotEmpty == true)
                        _buildInfoChip(Icons.local_gas_station, record.filled!,
                            Color(0xFF6366F1)),
                      if (record.location?.isNotEmpty == true)
                        _buildInfoChip(Icons.location_on, record.location!,
                            Color(0xFF10B981)),
                      if (record.time?.isNotEmpty == true)
                        _buildInfoChip(Icons.access_time, record.time!,
                            Color(0xFFF59E0B)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
Widget _buildInfoChip(IconData icon, String text, Color color) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}
void _showFuelFillingDetails(BuildContext context, FuelFilling record) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 16,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.92,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: colour.topAppBarColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.local_gas_station,
                        color: Colors.white, size: 26),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Fuel Report Details',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: Colors.white, size: 24),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildCleanDetailRow(Icons.directions_car, 'Vehicle',
                        record.vehicle ?? 'Not Available', Color(0xFF6366F1)),
                    _buildCleanDetailRow(Icons.person_outline, 'Driver',
                        record.driver ?? 'Not Available', Color(0xFF10B981)),
                    _buildCleanDetailRow(
                        Icons.local_gas_station_outlined,
                        'Fuel Quantity',
                        record.filled ?? 'Not Available',
                        Color(0xFFF59E0B)),
                    _buildCleanDetailRow(Icons.location_on_outlined, 'Location',
                        record.location ?? 'Not Available', Color(0xFF8B5CF6)),
                    _buildCleanDetailRow(
                        Icons.confirmation_number_outlined,
                        'Count',
                        record.count ?? 'Not Available',
                        Color(0xFFEF4444)),
                    _buildCleanDetailRow(Icons.schedule, 'Timestamp',
                        record.time ?? 'Not Available', Color(0xFF06B6D4)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
Widget _buildCleanDetailRow(
    IconData icon, String label, String value, Color color) {
  return Container(
    margin: EdgeInsets.only(bottom: 16),
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: color.withOpacity(0.06),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.15), width: 1),
    ),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.25),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(height: 6),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
Widget _buildSpeedReportTab(HrDashboardState state) {
  return Container(
    color: Colors.grey.shade50,
    child: Column(
      children: [
        Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.speed, color: Colors.orange.shade600, size: 24),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Speed Reports',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          'Monitor vehicle speeds',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildDateSelector(state),
            ],
          ),
        ),
        Expanded(
          child: state.speedingRecords.isEmpty
              ? _buildSpeedEmptyState()
              : _buildSpeedList(state),
        ),
      ],
    ),
  );
}
Widget _buildEngineHoursTab(HrDashboardState state) {
  return Container(
    color: Colors.grey.shade50,
    child: Column(
      children: [
        Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.access_time, color: Colors.green.shade600, size: 24),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Engine Hours Reports',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          'Track engine usage hours',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildEngineHoursDateSelector(state),
            ],
          ),
        ),
        Expanded(
          child: state.engineHoursRecords.isEmpty
              ? _buildEngineHoursEmptyState()
              : _buildEngineHoursList(state),
        ),
      ],
    ),
  );
}
//WORKING
Widget _buildEmployeeViewTab(HrDashboardState state) {
  List<EmployeeDetailsModel> allLicenses = state.EmployeeViewRecords;
  List<EmployeeDetailsModel> filteredLicenses = List.from(allLicenses);

  return StatefulBuilder(
    builder: (context, setState) {
      return Container(
        color: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 Search Bar
            Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon:
                    Icon(Icons.search, color: Colors.purple.shade400),
                    hintText: 'Search Employee...',
                    border: InputBorder.none,
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  ),
                  onChanged: (query) {
                    setState(() {
                      if (query.isEmpty) {
                        filteredLicenses = List.from(allLicenses);
                      } else {
                        filteredLicenses = allLicenses
                            .where((license) =>
                        (license.EmployeeName ?? '')
                            .toLowerCase()
                            .contains(query.toLowerCase()) ||
                            (license.MobileNo ?? '')
                                .toLowerCase()
                                .contains(query.toLowerCase()))
                            .toList();
                      }
                    });
                  },
                ),
              ),
            ),

            // 🧾 Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Employee’s List",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.purple,
                      size: 28,
                    ),
                    tooltip: 'Add Employee',
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Addemployee()),
                      );

                   //

                        state.LoadEmployeeViewRecords();


                    },

                  ),

                ],
              ),
            ),

            // 🚗 Filtered List
            Expanded(
              child: filteredLicenses.isEmpty
                  ? Center(
                child: Text(
                  'No Employees found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              )
                  : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: filteredLicenses.length,
                itemBuilder: (context, index) {
                  final record = filteredLicenses[index];
                  final isActive = record.Active != 0;

                  final statusColor =
                  isActive ? Colors.green.shade600 : Colors.red.shade600;
                  final cardGradient = LinearGradient(
                    colors: isActive
                        ? [Colors.green.shade50, Colors.white]
                        : [Colors.red.shade50, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  );

                  return InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: Text(
                            record.EmployeeName ?? 'Employee Details',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _detailRow("Email", record.Email),
                                _detailRow("Employee Type", record.EmployeeType),
                                _detailRow("Currency", record.Employeecurrency),
                                _detailRow("Address 1", record.Address1),
                                _detailRow("Address 2", record.Address2),
                                _detailRow("City", record.City),
                                _detailRow("State", record.State),
                                _detailRow("Country", record.Country),
                                _detailRow("GST No", record.GSTNO),
                                _detailRow("User Name", record.UserName),
                                _detailRow(
                                    "Joining Date", formatDate(record.JoiningDate)),
                                _detailRow(
                                    "Leaving Date", formatDate(record.LeavingDate)),
                                _detailRow("Rules Type", record.RulesType),
                                _detailRow("Bank Name", record.BankName),
                                _detailRow("Account No", record.AccountNo),
                                _detailRow("Account Code", record.AccountCode),
                                _detailRow("Latitude", record.Latitude),
                                _detailRow("Longitude", record.longitude),
                                SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text("Close"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        gradient: cardGradient,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 👤 Header
                            Row(
                              children: [
                                Container(
                                  height: 45,
                                  width: 45,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.purple.shade100,
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.purple.shade700,
                                  ),
                                ),
                                SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        record.EmployeeName ?? 'Unknown Driver',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                      SizedBox(height: 3),
                                      Text(
                                        record.MobileNo ?? 'No phone info',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isActive ? Icons.check_circle : Icons.cancel,
                                        color: statusColor,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        isActive ? 'Active' : 'Inactive',
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 10),
                            Divider(),

                            // 📅 Info
                            // 📅 Info
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _infoChip(
                                  icon: Icons.calendar_today,
                                  label: "Joining Date",
                                  value: formatDate(record.JoiningDate) ?? '—',
                                ),
                                _infoChip(
                                  icon: Icons.event,
                                  label: "Leaving Date",
                                  value: formatDate(record.LeavingDate) ?? '—',
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

// ✏️ Edit & 🗑️ Delete Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // 🟣 Edit Button
                                TextButton.icon(
                                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                  label: const Text(
                                    "Edit",
                                    style: TextStyle(color: Colors.blueAccent),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Addemployee(
                                          existingEmployee: record, // 👈 pass selected employee
                                        ),
                                      ),
                                    );
                                      state.LoadEmployeeViewRecords();

                                  },
                                ),

                                const SizedBox(width: 8),

                                // 🔴 Delete Button
                                TextButton.icon(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  label: const Text(
                                    "Delete",
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text("Confirm Delete"),
                                        content: Text(
                                            "Are you sure you want to delete ${record.EmployeeName}?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context, true);
                                              // 🔥 Call your delete function here
                                              deleteEmployee(context, record.Id);
                                            },
                                            child: const Text(
                                              "Delete",
                                              style: TextStyle(color: Colors.redAccent),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),

                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            )

          ],
        ),
      );
    },
  );
}

Future<void> deleteEmployee(BuildContext context, int Id) async {
  var comid = objfun.storagenew.getInt('Comid') ?? 0;

  Map<String, String> header = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  try {
    final apiUrl = "${objfun.apiDeleteEmployeeType}$Id&Comid=$comid";

    final resultData = await objfun.apiAllinoneSelectArray(
      apiUrl,
      '',
      header,
      context,
    );
    if (resultData != null && resultData is String) {
      if (resultData.contains('Deleted')) {
        objfun.ConfirmationOK(resultData, context);
      } else {
        objfun.ConfirmationOK('Employee deleted successfully', context);
      }
    }



  } catch (e, st) {
    objfun.msgshow(
      e.toString(),
      st.toString(),
      Colors.white,
      Colors.red,
      null,
      18.00 - objfun.reducesize,
      objfun.tll,
      objfun.tgc,
      context,
      2,
    );

  }
}


Widget _detailRow(String label, String? value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            "$label:",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text(
            value?.isNotEmpty == true ? value! : '—',
            style: TextStyle(color: Colors.grey.shade800),
          ),
        ),
      ],
    ),
  );
}


Widget _buildLicenseViewTab(HrDashboardState state) {
  List<LicenseViewModel> allLicenses = state.LicenseViewRecords;
  List<LicenseViewModel> filteredLicenses = List.from(allLicenses);

  return StatefulBuilder(
    builder: (context, setState) {
      return Container(
        color: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 Search Bar
            Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon:
                    Icon(Icons.search, color: Colors.purple.shade400),
                    hintText: 'Search License...',
                    border: InputBorder.none,
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  ),
                  onChanged: (query) {
                    setState(() {
                      if (query.isEmpty) {
                        filteredLicenses = List.from(allLicenses);
                      } else {
                        filteredLicenses = allLicenses
                            .where((license) =>
                        (license.LicenseName ?? '')
                            .toLowerCase()
                            .contains(query.toLowerCase()) ||
                            (license.Category ?? '')
                                .toLowerCase()
                                .contains(query.toLowerCase()))
                            .toList();
                      }
                    });
                  },
                ),
              ),
            ),

            // 🧾 Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: Text(
                "Driver’s License List",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),

            // 🚗 Filtered List
            Expanded(
              child: filteredLicenses.isEmpty
                  ? Center(
                child: Text(
                  'No License found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              )
                  : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: filteredLicenses.length,
                itemBuilder: (context, index) {
                  final record = filteredLicenses[index];
                  final isActive = record.Active != 0;

                  final statusColor = isActive
                      ? Colors.green.shade600
                      : Colors.red.shade600;
                  final cardGradient = LinearGradient(
                    colors: isActive
                        ? [Colors.green.shade50, Colors.white]
                        : [Colors.red.shade50, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  );

                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      gradient: cardGradient,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 👤 Header
                          Row(
                            children: [
                              Container(
                                height: 45,
                                width: 45,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.purple.shade100,
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.purple.shade700,
                                ),
                              ),
                              SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      record.LicenseName ??
                                          'Unknown Driver',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      record.Category ??
                                          'No category info',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isActive
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      color: statusColor,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      isActive ? 'Active' : 'Inactive',
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 10),
                          Divider(),

                          // 📅 Info
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _infoChip(
                                icon: Icons.calendar_today,
                                label: "Expiry",
                                value:
                                formatDate(record.ExpiryDate) ?? '—',
                              ),
                              _infoChip(
                                icon: Icons.event,
                                label: "Issued",
                                value: formatDate(record.LDate) ?? '—',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _infoChip(
    {required IconData icon, required String label, required String value}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.purple.shade50,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.purple.shade600, size: 16),
        SizedBox(width: 5),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.purple.shade800,
          ),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),
      ],
    ),
  );
}

//
// Widget _buildLicenseViewTab(HrDashboardState state) {
//   String selectedFilter = 'All';
//
//   return Container(
//     color: Colors.grey.shade100,
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // 🔍 Search + Filter Bar (Responsive)
//         Padding(
//           padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
//           child: LayoutBuilder(
//             builder: (context, constraints) {
//               if (constraints.maxWidth < 400) {
//                 // small screen → stack vertically
//                 return Column(
//                   children: [
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.05),
//                             blurRadius: 6,
//                             offset: Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: TextField(
//                         decoration: InputDecoration(
//                           prefixIcon:
//                           Icon(Icons.search, color: Colors.purple.shade400),
//                           hintText: 'Search License...',
//                           border: InputBorder.none,
//                           contentPadding: EdgeInsets.symmetric(
//                               vertical: 14, horizontal: 12),
//                         ),
//                         onChanged: (query) {
//
//                         },
//                       ),
//                     ),
//
//                   ],
//                 );
//               } else {
//                 // large screen → Row
//                 return Row(
//                   children: [
//                     Expanded(
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(12),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.05),
//                               blurRadius: 6,
//                               offset: Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: TextField(
//                           decoration: InputDecoration(
//                             prefixIcon: Icon(Icons.search,
//                                 color: Colors.purple.shade400),
//                             hintText: 'Search License...',
//                             border: InputBorder.none,
//                             contentPadding: EdgeInsets.symmetric(
//                                 vertical: 14, horizontal: 12),
//                           ),
//                           onChanged: (query) {
//                             // TODO: implement filtering logic if needed
//                           },
//                         ),
//                       ),
//                     ),
//
//                   ],
//                 );
//               }
//             },
//           ),
//         ),
//
//         // 🧾 Title Bar
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 18, vertical: 4),
//           child: Text(
//             "Driver’s License List",
//             style: GoogleFonts.inter(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey.shade800,
//             ),
//           ),
//         ),
//
//         // 🚗 License List Section
//         Expanded(
//           child: state.LicenseViewRecords.isEmpty
//               ? Center(
//             child: Text(
//               'No License found',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey.shade600,
//               ),
//             ),
//           )
//               : ListView.builder(
//             padding: EdgeInsets.all(16),
//             itemCount: state.LicenseViewRecords.length,
//             itemBuilder: (context, index) {
//               final record = state.LicenseViewRecords[index];
//               final isActive = record.Active != 0;
//
//               final statusColor =
//               isActive ? Colors.green.shade600 : Colors.red.shade600;
//               final cardGradient = LinearGradient(
//                 colors: isActive
//                     ? [Colors.green.shade50, Colors.white]
//                     : [Colors.red.shade50, Colors.white],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               );
//
//               return AnimatedContainer(
//                 duration: Duration(milliseconds: 300),
//                 margin: EdgeInsets.only(bottom: 14),
//                 decoration: BoxDecoration(
//                   gradient: cardGradient,
//                   borderRadius: BorderRadius.circular(18),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 8,
//                       offset: Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: Padding(
//                   padding: EdgeInsets.all(18),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // 👤 Header Row
//                       Row(
//                         children: [
//                           Container(
//                             height: 45,
//                             width: 45,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Colors.purple.shade100,
//                             ),
//                             child: Icon(
//                               Icons.person,
//                               color: Colors.purple.shade700,
//                             ),
//                           ),
//                           SizedBox(width: 14),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment:
//                               CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   record.LicenseName ??
//                                       'Unknown Driver',
//                                   style: GoogleFonts.inter(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.grey.shade800,
//                                   ),
//                                 ),
//                                 SizedBox(height: 3),
//                                 Text(
//                                   record.Category ?? 'No category info',
//                                   style: GoogleFonts.inter(
//                                     fontSize: 13,
//                                     color: Colors.grey.shade600,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Container(
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: 12, vertical: 5),
//                             decoration: BoxDecoration(
//                               color: statusColor.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   isActive
//                                       ? Icons.check_circle
//                                       : Icons.cancel,
//                                   color: statusColor,
//                                   size: 16,
//                                 ),
//                                 SizedBox(width: 4),
//                                 Text(
//                                   isActive ? 'Active' : 'Inactive',
//                                   style: TextStyle(
//                                     color: statusColor,
//                                     fontWeight: FontWeight.w600,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//
//                       SizedBox(height: 10),
//                       Divider(),
//
//                       // 📅 License Info Inline Chips (fixed for overflow)
//                       Wrap(
//                         spacing: 8,
//                         runSpacing: 8,
//                         children: [
//                           Container(
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: 10, vertical: 6),
//                             decoration: BoxDecoration(
//                               color: Colors.purple.shade50,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(Icons.calendar_today,
//                                     color: Colors.purple.shade600,
//                                     size: 16),
//                                 SizedBox(width: 5),
//                                 Text(
//                                   'Expiry: ',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.w600,
//                                     fontSize: 13,
//                                     color: Colors.purple.shade800,
//                                   ),
//                                 ),
//                                 Text(
//                                   formatDate(record.ExpiryDate) ??'—',
//                                   style: TextStyle(
//                                     fontSize: 13,
//                                     color: Colors.grey.shade700,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Container(
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: 10, vertical: 6),
//                             decoration: BoxDecoration(
//                               color: Colors.purple.shade50,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(Icons.event,
//                                     color: Colors.purple.shade600,
//                                     size: 16),
//                                 SizedBox(width: 5),
//                                 Text(
//                                   'Issued: ',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.w600,
//                                     fontSize: 13,
//                                     color: Colors.purple.shade800,
//                                   ),
//                                 ),
//                                 Text(
//                                   formatDate(record.LDate) ??'—',
//                                   style: TextStyle(
//                                     fontSize: 13,
//                                     color: Colors.grey.shade700,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//
//                       SizedBox(height: 12),
//
//                       // 📊 Expiry Progress (Optional)
//                       if (record.ExpiryDate != null)
//
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             LinearProgressIndicator(
//                               value: 0.7, // example
//                               color: statusColor,
//                               backgroundColor: Colors.grey.shade200,
//                             ),
//                             SizedBox(height: 4),
//                             Text(
//                               "License valid until ${formatDate(record.ExpiryDate)}",
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey.shade600,
//                               ),
//                             ),
//                           ],
//                         ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     ),
//   );
// }



String formatDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) return '—';
  try {
    DateTime parsedDate = DateTime.parse(dateString);
    return DateFormat('dd/MM/yyyy').format(parsedDate);
  } catch (e) {
    return dateString;
  }
}




Widget _buildDriverViewTab(HrDashboardState state) {
  return Container(
    color: Colors.grey.shade50,
    child: Column(
      children: [
        // Header
        Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.compare_arrows,
                    color: Colors.purple.shade600, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Driver View',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'List of drivers with port and license info',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Driver list
        Expanded(
          child: state.DriverViewRecords.isEmpty
              ? const Center(
            child: Text(
              'No drivers found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
              : ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: state.DriverViewRecords.length,
            itemBuilder: (context, index) {
              final record = state.DriverViewRecords[index];

              // ✅ Card color based on ACTIVE status
              final isActive = record.Active == 0;
              final cardColor =
              isActive ? Colors.green.shade50 : Colors.white;
              final borderColor =
              isActive ? Colors.green : Colors.purple.shade100;

              return Container(
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Row(
                        children: [
                          Icon(Icons.person,
                              color: Colors.purple.shade600, size: 28),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              record.DriverName ?? 'Unknown',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.red.shade100
                                  : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isActive ? 'Inactive' : 'Active',
                              style: TextStyle(
                                color: isActive
                                    ? Colors.red
                                    : Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Divider(),

                      // License & GDL
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _buildStatusChip('Mobile No', record.MobileNo),
                          _buildStatusChip('License', record.licenseExp),

                          _buildStatusChip('GDL', record.GDLExp),
                          _buildStatusChip(
                              'Joining', record.JoiningDate),
                          _buildStatusChip(
                              'Leaving', record.LeavingDate),
                        ],
                      ),

                      SizedBox(height: 8),
                      Divider(),

                      // Ports
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _buildStatusChip(
                              'Kuantan',
                              record.KuantanPort?.isNotEmpty == true
                                  ? record.KuantanPort
                                  : record.KuantanPortStatus,
                              isStatus: record.KuantanPort?.isNotEmpty != true),
                          _buildStatusChip(
                              'Northport',
                              record.NorthportPort?.isNotEmpty == true
                                  ? record.NorthportPort
                                  : record.NorthportPortStatus),
                          _buildStatusChip(
                              'Pkfz',
                              record.PkfzPort?.isNotEmpty == true
                                  ? record.PkfzPort
                                  : record.PkfzPortStatus),
                          _buildStatusChip(
                              'Klia',
                              record.KliaPort?.isNotEmpty == true
                                  ? record.KliaPort
                                  : record.KliaPortStatus),
                          _buildStatusChip(
                              'Pgu',
                              record.PguPort?.isNotEmpty == true
                                  ? record.PguPort
                                  : record.PguPortStatus),
                          _buildStatusChip(
                              'Penang',
                              record.PenangPort?.isNotEmpty == true
                                  ? record.PenangPort
                                  : record.PenangPortStatus),
                          _buildStatusChip(
                              'Ptp',
                              record.PtpPort?.isNotEmpty == true
                                  ? record.PtpPort
                                  : record.PtpPortStatus),
                          _buildStatusChip(
                              'Westport',
                              record.WestportPort?.isNotEmpty == true
                                  ? record.WestportPort
                                  : record.WestportPortStatus),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

// ✅ STATUS CHIP WITH EXPIRY LOGIC CORRECT
Widget _buildStatusChip(String title, String? value,{bool isStatus = false}) {
  // Parse expiry dates


  DateTime? parseDate(String? date) {
    if (date == null || date.trim().isEmpty) return null;

    // ignore non-date values like phone numbers
    if (!(date.contains('-') || date.contains('/') || date.contains(':'))) {
      return null;
    }

    try {
      // 🔹 Try your backend format first: MM/dd/yyyy HH:mm:ss
      return DateFormat('MM/dd/yyyy HH:mm:ss').parse(date);
    } catch (_) {
      try {
        // 🔹 Try yyyy-MM-dd
        return DateFormat('yyyy-MM-dd').parse(date);
      } catch (_) {
        try {
          // 🔹 Try dd/MM/yyyy
          return DateFormat('dd/MM/yyyy').parse(date);
        } catch (_) {
          return DateTime.tryParse(date);
        }
      }
    }
  }



  Color bg = Colors.grey.shade200;
  Color text = Colors.black;
  String label = value ?? "N/A";
if (isStatus){
  bg = Colors.red.shade100;
  text = Colors.red.shade900;
}else{
  final expiry = parseDate(value);
  if (expiry != null) {
    final now = DateTime.now();
    final days = expiry.difference(now).inDays;
    if (days < 0) {
      bg = Colors.red.shade100;
      text = Colors.red.shade900;
    } else if (days <= 5) {
      bg = Colors.yellow.shade100;
      text = Colors.orange.shade900;
    } else {
      bg = Colors.green.shade100;
      text = Colors.green.shade900;

      label = DateFormat('dd/MM/yyyy').format(expiry);

    }
  }
}


  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text("$title: $label",
        style: TextStyle(fontSize: 12, color: text, fontWeight: FontWeight.w500)),
  );
}





Widget _buildFuelDiffeentTab(HrDashboardState state) {
  return Container(
    color: Colors.grey.shade50,
    child: Column(
      children: [
        Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.compare_arrows, color: Colors.purple.shade600, size: 24),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fuel Difference Reports',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          'Compare actual vs given fuel',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildFuelDifferenceSelector(state),
            ],
          ),
        ),
        Expanded(
          child: state.fuelDifferenceRecords.isEmpty
              ? _buildFuelDifferenceEmptyState()
              : _buildFuelDifferenceList(state),
        ),
      ],
    ),
  );
}

Widget _buildSpeedEmptyState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.speed_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
        ),
        SizedBox(height: 24),
        Text(
          'No Speed Records',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'No speeding violations found for the selected period',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey.shade500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

Widget _buildSpeedList(HrDashboardState state) {
  return ListView.builder(
    padding: EdgeInsets.symmetric(horizontal: 16),
    itemCount: state.speedingRecords.length,
    itemBuilder: (context, index) {
      final record = state.speedingRecords[index];
      return Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showSpeedingDetails(context, record),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.warning, color: Colors.red.shade600, size: 20),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.vehicle.isNotEmpty ? record.vehicle : 'Unknown Vehicle',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              record.driver.isNotEmpty ? record.driver : 'No driver',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 18),
                    ],
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (record.filled.isNotEmpty)
                        _buildInfoChip(Icons.speed, '${record.filled} km/h', Colors.red.shade600),
                      if (record.location.isNotEmpty)
                        _buildInfoChip(Icons.location_on, record.location, Colors.orange.shade600),
                      if (record.time.isNotEmpty)
                        _buildInfoChip(Icons.access_time, record.time, Colors.blue.shade600),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

void _showSpeedingDetails(BuildContext context, SpeedingView record) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Color(0xFFFF6B6B),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.warning, color: Colors.white, size: 24),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Speeding Details',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: Colors.white, size: 22),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildSpeedDetailRow(Icons.directions_car, 'Vehicle', record.vehicle.isNotEmpty ? record.vehicle : 'Not Available', Color(0xFF4299e1)),
                  _buildSpeedDetailRow(Icons.person_outline, 'Driver', record.driver.isNotEmpty ? record.driver : 'Not Available', Color(0xFF48bb78)),
                  _buildSpeedDetailRow(Icons.speed, 'Speed', record.filled.isNotEmpty ? '${record.filled} km/h' : 'Not Available', Color(0xFFf56565)),
                  _buildSpeedDetailRow(Icons.policy, 'Speed Limit', record.count.isNotEmpty ? '${record.count} km/h' : 'Not Available', Color(0xFFed8936)),
                  _buildSpeedDetailRow(Icons.location_on_outlined, 'Location', record.location.isNotEmpty ? record.location : 'Not Available', Color(0xFF9f7aea)),
                  _buildSpeedDetailRow(Icons.schedule, 'Time', record.time.isNotEmpty ? record.time : 'Not Available', Color(0xFF38b2ac)),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildSpeedDetailRow(IconData icon, String label, String value, Color color) {
  return Container(
    margin: EdgeInsets.only(bottom: 16),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.2), width: 1),
    ),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Color(0xFF4A5568),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Color(0xFF1A202C),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildDateSelector(HrDashboardState state) {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Color(0xFFE2E8F0)),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDateButton(
                DateFormat("dd MMM yyyy").format(DateTime.parse(state.dtpFromDate)),
                () => state.selectFromDate(),
                'From Date',
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6366F1).withOpacity(0.1), Color(0xFF8B5CF6).withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "to",
                  style: GoogleFonts.inter(
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _buildDateButton(
                DateFormat("dd MMM yyyy").format(DateTime.parse(state.dtpToDate)),
                () => state.selectToDate(),
                'To Date',
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => state.loadFuelFilling(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6366F1),
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search, size: 18, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'View Reports',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildDateButton(String text, VoidCallback onTap, String label) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.inter(
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              Icon(Icons.calendar_today, size: 14, color: Color(0xFF6366F1)),
            ],
          ),
        ],
      ),
    ),
  );
}


Widget _buildEngineHoursEmptyState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.access_time_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
        ),
        SizedBox(height: 24),
        Text(
          'No Engine Hours Records',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'No engine hours data available for the selected period',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey.shade500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

Widget _buildEngineHoursList(HrDashboardState state) {
  return ListView.builder(
    padding: EdgeInsets.symmetric(horizontal: 16),
    itemCount: state.engineHoursRecords.length,
    itemBuilder: (context, index) {
      final record = state.engineHoursRecords[index];
      return Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showEngineHoursDetails(context, record),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.access_time, color: Colors.green.shade600, size: 20),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record['TruckName']?.toString() ?? 'Unknown Vehicle',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Mileage: ${record['mileage']?.toString() ?? 'Not Available'}',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 18),
                    ],
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (record['totalTime']?.toString().isNotEmpty == true)
                        _buildInfoChip(Icons.timer, '${record['totalTime']} hrs', Colors.green.shade600),
                      if (record['beginLocation']?.toString().isNotEmpty == true)
                        _buildInfoChip(Icons.location_on, record['beginLocation'].toString(), Colors.blue.shade600),
                      if (record['beginTime']?.toString().isNotEmpty == true)
                        _buildInfoChip(Icons.access_time, record['beginTime'].toString(), Colors.orange.shade600),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

void _showEngineHoursDetails(BuildContext context, dynamic record) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Color(0xFF48BB78),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.access_time, color: Colors.white, size: 24),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Engine Hours Details',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: Colors.white, size: 22),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildEngineHoursDetailRow(Icons.directions_car, 'Truck Name', record['TruckName']?.toString() ?? 'Not Available', Color(0xFF4299e1)),
                    _buildEngineHoursDetailRow(Icons.play_arrow, 'Begin Time', record['beginTime']?.toString() ?? 'Not Available', Color(0xFF48bb78)),
                    _buildEngineHoursDetailRow(Icons.stop, 'End Time', record['endTime']?.toString() ?? 'Not Available', Color(0xFFf56565)),
                    _buildEngineHoursDetailRow(Icons.timer, 'Total Time', record['totalTime']?.toString() ?? 'Not Available', Color(0xFF38b2ac)),
                    _buildEngineHoursDetailRow(Icons.place, 'Begin Location', record['beginLocation']?.toString() ?? 'Not Available', Color(0xFF9f7aea)),
                    _buildEngineHoursDetailRow(Icons.flag, 'End Location', record['endLocation']?.toString() ?? 'Not Available', Color(0xFFed8936)),
                    _buildEngineHoursDetailRow(Icons.pause_circle_filled, 'Idling', record['idling']?.toString() ?? 'Not Available', Color(0xFFa0aec0)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildEngineHoursDetailRow(IconData icon, String label, String value, Color color) {
  return Container(
    margin: EdgeInsets.only(bottom: 16),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.2), width: 1),
    ),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Color(0xFF4A5568),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Color(0xFF1A202C),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildEngineHoursDateSelector(HrDashboardState state) {
  return Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            DateFormat("dd-MM-yy").format(DateTime.parse(state.dtpFromDate)),
            style: GoogleFonts.inter(
              color: colour.commonColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          icon: Icon(Icons.calendar_month_outlined, size: 24, color: colour.commonColor),
          onPressed: () => state.selectFromDate(),
          padding: EdgeInsets.all(4),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            "to",
            style: GoogleFonts.inter(
              color: colour.commonColor,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            DateFormat("dd-MM-yy").format(DateTime.parse(state.dtpToDate)),
            style: GoogleFonts.inter(
              color: colour.commonColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          icon: Icon(Icons.calendar_month_outlined, size: 24, color: colour.commonColor),
          onPressed: () => state.selectToDate(),
          padding: EdgeInsets.all(4),
        ),
        SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () => state.loadEngineHoursDifference(),
            style: ElevatedButton.styleFrom(
              backgroundColor: colour.commonColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.symmetric(vertical: 8),
            ),
            child: Text(
              'View',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
Widget _buildFuelDifferenceEmptyState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.compare_arrows_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
        ),
        SizedBox(height: 24),
        Text(
          'No Fuel Difference Records',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'No fuel difference data available for the selected period',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey.shade500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}




Widget _buildFuelDifferenceList(HrDashboardState state) {
  return ListView.builder(
    padding: EdgeInsets.symmetric(horizontal: 16),
    itemCount: state.fuelDifferenceRecords.length,
    itemBuilder: (context, index) {
      final record = state.fuelDifferenceRecords[index];
      final double aAmount = record.aAmount ?? 0.0;
      final double gAmount = record.gAmount ?? 0.0;
      final double aliter = record.aliter ?? 0.0;
      final double gliter = record.gliter ?? 0.0;
      final double difference = gAmount - aAmount;

      Color diffColor = difference > 0 ? Colors.green : difference < 0 ? Colors.red : Colors.grey;
      IconData diffIcon = difference > 0 ? Icons.trending_up : difference < 0 ? Icons.trending_down : Icons.remove;

      return Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.purple.shade100, width: 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showFuelDifferenceDetails(context, record),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.local_shipping, color: Colors.purple.shade600, size: 20),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.driverName ?? 'Unknown Driver',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              record.truckName ?? 'No Truck',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 18),
                    ],
                  ),
                  SizedBox(height: 12),
                  Divider(color: Colors.purple.shade100, thickness: 1),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFuelInfoTile('A Amount', '₹${aAmount.toStringAsFixed(2)}', Colors.orange.shade600),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildFuelInfoTile('G Amount', '₹${gAmount.toStringAsFixed(2)}', Colors.blue.shade600),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFuelInfoTile('A Liter', '${aliter.toStringAsFixed(2)} L', Colors.orange.shade600),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildFuelInfoTile('G Liter', '${gliter.toStringAsFixed(2)} L', Colors.blue.shade600),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: diffColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: diffColor.withOpacity(0.3), width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(diffIcon, color: diffColor, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Difference: ${difference >= 0 ? '+' : ''}₹${difference.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            color: diffColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildFuelInfoTile(String label, String value, Color color) {
  return Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.3), width: 1),
    ),
    child: Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

void _showFuelDifferenceDetails(BuildContext context, FuelselectModel record) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Color(0xFF9F7AEA),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.compare_arrows, color: Colors.white, size: 24),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Fuel Difference Details',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: Colors.white, size: 22),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildFuelDifferenceDetailRow(Icons.person, 'Driver Name', record.driverName ?? 'Not Available', Color(0xFF4299e1)),
                    _buildFuelDifferenceDetailRow(Icons.local_shipping, 'Truck Name', record.truckName ?? 'Not Available', Color(0xFF48bb78)),
                    _buildFuelDifferenceDetailRow(Icons.local_gas_station, 'P Rate', '₹${(record.pRate ?? 0.0).toStringAsFixed(2)}', Color(0xFFed8936)),
                    _buildFuelDifferenceDetailRow(Icons.local_gas_station, 'P liter', '₹${(record.pliter ?? 0.0).toStringAsFixed(2)}', Color(0xFFed8936)),
                    _buildFuelDifferenceDetailRow(Icons.currency_rupee, 'P Amount', '₹${(record.pAmount ?? 0.0).toStringAsFixed(2)}', Color(0xFFed8936)),
                    _buildFuelDifferenceDetailRow(Icons.attach_money, 'A Amount', '₹${(record.aAmount ?? 0.0).toStringAsFixed(2)}', Color(0xFFed8936)),
                    _buildFuelDifferenceDetailRow(Icons.monetization_on, 'G Amount', '₹${(record.gAmount ?? 0.0).toStringAsFixed(2)}', Color(0xFF38b2ac)),
                    _buildFuelDifferenceDetailRow(Icons.local_gas_station, 'A Liter', '${(record.aliter ?? 0.0).toStringAsFixed(2)} L', Color(0xFF9f7aea)),
                    _buildFuelDifferenceDetailRow(Icons.local_gas_station_outlined, 'G Liter', '${(record.gliter ?? 0.0).toStringAsFixed(2)} L', Color(0xFFf56565)),
                    _buildFuelDifferenceDetailRow(Icons.calendar_today, 'Sale Date', record.sSaleDate ?? 'Not Available', Color(0xFF667eea)),
                    _buildFuelDifferenceDetailRow(Icons.person, 'Remarks', record.remarks ?? 'Not Available', Color(0xFF4299e1)),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildFuelDifferenceDetailRow(IconData icon, String label, String value, Color color) {
  return Container(
    margin: EdgeInsets.only(bottom: 16),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.2), width: 1),
    ),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Color(0xFF4A5568),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Color(0xFF1A202C),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildFuelDifferenceSelector(HrDashboardState state) {
  return Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            DateFormat("dd-MM-yy").format(DateTime.parse(state.dtpFromDate)),
            style: GoogleFonts.inter(
              color: colour.commonColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          icon: Icon(Icons.calendar_month_outlined, size: 24, color: colour.commonColor),
          onPressed: () => state.selectFromDate(),
          padding: EdgeInsets.all(4),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            "to",
            style: GoogleFonts.inter(
              color: colour.commonColor,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            DateFormat("dd-MM-yy").format(DateTime.parse(state.dtpToDate)),
            style: GoogleFonts.inter(
              color: colour.commonColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          icon: Icon(Icons.calendar_month_outlined, size: 24, color: colour.commonColor),
          onPressed: () => state.selectToDate(),
          padding: EdgeInsets.all(4),
        ),
        SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () => state.loadFuelDifferenceDifference(),
            style: ElevatedButton.styleFrom(
              backgroundColor: colour.commonColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.symmetric(vertical: 8),
            ),
            child: Text(
              'View',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}