part of 'PayableDashbord.dart';

Widget mobiledesign(PayableDashbordState state, BuildContext context) {
  return WillPopScope(
    onWillPop: state._onBackPressed,
    child: DefaultTabController(
      length: 8,
      child: Scaffold(
        backgroundColor: Color(0xFFF1F5F9),
        appBar: AppBar(

            backgroundColor: Color(0xff0e387a),
            title: Text(' PAYABLE Dashboard',
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
                    Tab(icon: Icon(Icons.local_shipping, size: 20), text: 'Driver View'),
                    Tab(icon: Icon(Icons.local_taxi, size: 20), text: 'Truck View'),
                    Tab(icon: Icon(Icons.receipt_long, size: 20), text: 'BillOrderView'),
                    Tab(icon: Icon(Icons.account_balance_wallet, size: 20), text: 'Petty cash Entry'),
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
            _buildTruckViewTab(state),
            _buildBillOrderViewTab(state),
            _buildPettyCashViewTab(state),
          ],
        ),
      ),
    ),
  );
}

Widget _buildDriverViewTab(PayableDashbordState state) {
  TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  
  return StatefulBuilder(
    builder: (context, setState) {
      final filteredDrivers = state.DriverViewRecords.where((record) {
        final name = record.DriverName?.toLowerCase() ?? '';
        final mobile = record.MobileNo?.toLowerCase() ?? '';
        return name.contains(searchQuery) || mobile.contains(searchQuery);
      }).toList();
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search driver name or mobile...',
                  prefixIcon: Icon(Icons.search, color: Colors.purple),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.purple.shade100),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
            // Driver list
            Expanded(
              child: filteredDrivers.isEmpty
                  ? const Center(
                child: Text(
                  'No drivers found',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
                  : ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: filteredDrivers.length,
                itemBuilder: (context, index) {
                  final record = filteredDrivers[index];

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
  );
}
Widget _buildTruckViewTab(PayableDashbordState state) {
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
// ✅ STATUS CHIP WITH EXPIRY LOGIC CORRECT
Widget _buildStatusChip(String title, String? value, {bool isStatus = false}) {
  // 🔹 Date Parsing Function
  DateTime? parseDate(String? date) {
    if (date == null || date.trim().isEmpty) return null;

    if (!(date.contains('-') || date.contains('/') || date.contains(':'))) {
      return null;
    }

    try {
      return DateFormat('MM/dd/yyyy HH:mm:ss').parse(date);
    } catch (_) {
      try {
        return DateFormat('dd/MM/yyyy HH:mm:ss').parse(date);
      } catch (_) {
        try {
          if (date.contains('T')) {
            return DateTime.parse(date);
          }
          return DateFormat('yyyy-MM-dd').parse(date);
        } catch (_) {
          try {
            return DateFormat('dd/MM/yyyy').parse(date);
          } catch (_) {
            return DateTime.tryParse(date);
          }
        }
      }
    }
  }

  Color bg = Colors.grey.shade200;
  Color text = Colors.black;
  String label = value ?? "N/A";

  if (isStatus) {
    bg = Colors.red.shade100;
    text = Colors.red.shade900;
  } else {
    final expiry = parseDate(value);
    if (expiry != null) {
      final now = DateTime.now();
      final days = expiry.difference(now).inDays;

      // ✅ Format date properly before color logic
      label = DateFormat('dd/MM/yyyy').format(expiry);

      if (days < 0) {
        bg = Colors.red.shade100;
        text = Colors.red.shade900;
      } else if (days <= 5) {
        bg = Colors.yellow.shade100;
        text = Colors.orange.shade900;
      } else {
        bg = Colors.green.shade100;
        text = Colors.green.shade900;
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
Widget _buildFuelFillingTab(PayableDashbordState state) {
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
Widget _buildFuelList(PayableDashbordState state) {
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

Widget _buildBillOrderViewTab(PayableDashbordState state) {
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
        // ==== HEADER CARD ====
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
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF10B981).withOpacity(0.1),
                      Color(0xFF34D399).withOpacity(0.1)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.receipt_long,
                    color: Color(0xFF10B981), size: 26),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bill Order Reports',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'View all bill and order transactions',
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
        ),

        // ==== DATE SELECTOR ====
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildDateSelector(state),
        ),

        // ==== MAIN CONTENT ====
        Expanded(
          child: state.BillorderViewRecords.isEmpty
              ? _buildEmptyState(
              'No Bill Records',
              'No bill orders found for the selected period',
              Icons.receipt_long_outlined)
              : _buildBillList(state),
        ),
      ],
    ),
  );
}
Widget _buildBillList(PayableDashbordState state) {
  return ListView.builder(
    padding: EdgeInsets.all(16),
    itemCount: state.BillorderViewRecords.length,
    itemBuilder: (context, index) {
      final bill = state.BillorderViewRecords[index];

      return GestureDetector(
        onLongPress: () {
          _showBillDetailsDialog(context, bill);
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 14),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    bill.BillNoDisplay,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    bill.BillNoDisplay1,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),

              // Supplier
              Text(
                bill.SupplierName,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Color(0xFF334155),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),

              // Employee & Invoice
              Row(
                children: [
                  Icon(Icons.person, size: 14, color: Color(0xFF94A3B8)),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      bill.EmployeeName,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                  if (bill.InvoiceNo.isNotEmpty) ...[
                    Icon(Icons.description_outlined, size: 14, color: Color(0xFF94A3B8)),
                    SizedBox(width: 4),
                    Text(
                      bill.InvoiceNo,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 8),

              // Pending Status
              if (bill.PStatus == 0) ...[
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFFFDE68A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Pending',
                        style: GoogleFonts.inter(
                          color: Color(0xFF92400E),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
              ],

              // Net Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'RM ${bill.NetAmt.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        color: Color(0xFF047857),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}


// petty cash  view createt  that





void _showBillDetailsDialog(BuildContext context, dynamic bill) {
  showDialog(
    context: context,
    barrierDismissible: true, // Tap outside to close
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 6,
        backgroundColor: Colors.white,
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bill Details',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey[600]),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Divider(height: 10, color: Colors.grey.shade300),

                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _detailRow(Icons.receipt_long, 'Bill No', bill.BillNoDisplay ?? 'N/A'),
                      _detailRow(Icons.local_shipping_outlined, 'Supplier', bill.SupplierName ?? 'N/A'),
                      _detailRow(Icons.badge_outlined, 'Employee', bill.EmployeeName ?? 'N/A'),
                      _detailRow(Icons.fire_truck_outlined, 'Truck Name', bill.TruckName ?? 'N/A'),
                      _detailRow(Icons.account_circle_outlined, 'Driver Name', bill.DriverName ?? 'N/A'),
                      _detailRow(Icons.numbers_outlined, 'Job No', bill.BillNoDisplay1 ?? 'N/A'),
                      _detailRow(Icons.description_outlined, 'Invoice', bill.InvoiceNo ?? 'N/A'),
                      _detailRow(Icons.currency_exchange_outlined, 'Net Amount', 'RM ${(bill.NetAmt ?? 0.0).toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Status:',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Color(0xFF475569),
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: bill.PStatus == 0
                                ? Color(0xFFFDE68A)
                                : Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            bill.PStatus == 0 ? 'Pending' : 'Completed',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: bill.PStatus == 0
                                  ? Color(0xFF92400E)
                                  : Color(0xFF047857),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.check, size: 18),
                        label: Text('Close'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
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
      );
    },
  );
}


Widget _detailRow(IconData icon, String label, String value) {
  return Container(
    margin: EdgeInsets.only(bottom: 12),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade800,
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
Widget _buildSpeedReportTab(PayableDashbordState state) {
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

Widget _buildEngineHoursTab(PayableDashbordState state) {
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

Widget _buildFuelDiffeentTab(PayableDashbordState state) {
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

Widget _buildSpeedList(PayableDashbordState state) {
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
                        _buildInfoChip(Icons.speed, '${record.filled} ', Colors.red.shade600),
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
                  _buildSpeedDetailRow(Icons.speed, 'Speed', record.filled.isNotEmpty ? '${record.filled} ' : 'Not Available', Color(0xFFf56565)),
                  _buildSpeedDetailRow(Icons.policy, 'Speed Limit', record.count.isNotEmpty ? '${record.count} ' : 'Not Available', Color(0xFFed8936)),
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

Widget _buildDateSelector(PayableDashbordState state) {
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
            onPressed: () => state.LoadBillorderview(),
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

Widget _buildEngineHoursList(PayableDashbordState state) {
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

Widget _buildEngineHoursDateSelector(PayableDashbordState state) {
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

Widget _buildFuelDifferenceList(PayableDashbordState state) {
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
                    _buildFuelDifferenceDetailRow(Icons.attach_money, 'Rate', '₹${(record.pRate ?? 0.0).toStringAsFixed(2)}', Color(0xFFed8936)),
                    _buildFuelDifferenceDetailRow(Icons.attach_money, 'A Amount', '₹${(record.aAmount ?? 0.0).toStringAsFixed(2)}', Color(0xFFed8936)),
                    _buildFuelDifferenceDetailRow(Icons.monetization_on, 'G Amount', '₹${(record.gAmount ?? 0.0).toStringAsFixed(2)}', Color(0xFF38b2ac)),
                    _buildFuelDifferenceDetailRow(Icons.monetization_on, 'P Amount', '₹${(record.pAmount ?? 0.0).toStringAsFixed(2)}', Color(0xFF38b2ac)),
                    _buildFuelDifferenceDetailRow(Icons.local_gas_station, 'A Liter', '${(record.aliter ?? 0.0).toStringAsFixed(2)} L', Color(0xFF9f7aea)),
                    _buildFuelDifferenceDetailRow(Icons.local_gas_station_outlined, 'G Liter', '${(record.gliter ?? 0.0).toStringAsFixed(2)} L', Color(0xFFf56565)),
                    _buildFuelDifferenceDetailRow(Icons.local_gas_station_outlined, 'P Liter', '${(record.pliter ?? 0.0).toStringAsFixed(2)} L', Color(0xFFf56565)),
                    _buildFuelDifferenceDetailRow(Icons.local_gas_station_outlined, 'Remarks', '${(record.remarks )}', Color(0xFFf56565)),
                    _buildFuelDifferenceDetailRow(Icons.calendar_today, 'Sale Date', record.sSaleDate ?? 'Not Available', Color(0xFF667eea)),
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

Widget _buildFuelDifferenceSelector(PayableDashbordState state) {
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

Widget _buildPettyCashViewTab(PayableDashbordState state) {
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
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFE91E63).withOpacity(0.1),
                      Color(0xFFAD1457).withOpacity(0.1)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.account_balance_wallet,
                    color: Color(0xFFE91E63), size: 26),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Petty Cash Reports',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Track petty cash expenses and approvals',
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
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildPettyCashDateSelector(state),
        ),
        Expanded(
          child: state.PettyCashRecords.isEmpty
              ? _buildEmptyState(
              'No Petty Cash Records',
              'No petty cash entries found for the selected period',
              Icons.account_balance_wallet_outlined)
              : _buildPettyCashList(state),
        ),
      ],
    ),
  );
}

Widget _buildPettyCashList(PayableDashbordState state) {
  return ListView.builder(
    padding: EdgeInsets.all(16),
    itemCount: state.PettyCashRecords.length,
    itemBuilder: (context, index) {
      final record = state.PettyCashRecords[index];
      final amount = double.tryParse(record.Amount) ?? 0.0;
      final isPending = record.PaymentStatus.toLowerCase().contains('approval');
      
      return Container(
        margin: EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPending ? Colors.orange.shade200 : Colors.green.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onLongPress: () => _showPettyCashDetails(context, record),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFFE91E63).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.person, color: Color(0xFFE91E63), size: 22),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.EmployeeName,
                              style: GoogleFonts.inter(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              record.CNumberDisplay,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isPending ? Colors.orange.shade100 : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isPending ? 'Pending' : 'Approved',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isPending ? Colors.orange.shade800 : Colors.green.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Divider(color: Colors.grey.shade200),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _formatDate(record.PettyCashDate),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Color(0xFF1E293B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Amount',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'RM ${amount.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Color(0xFFE91E63),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      record.PaymentStatus,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w600,
                      ),
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

void _showPettyCashDetails(BuildContext context, PettyCashMasterModel record) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Color(0xFFE91E63),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: Colors.white, size: 26),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Petty Cash Details',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildCleanDetailRow(Icons.person, 'Employee', record.EmployeeName, Color(0xFFE91E63)),
                    _buildCleanDetailRow(Icons.confirmation_number, 'Reference No', record.CNumberDisplay, Color(0xFF3B82F6)),
                    _buildCleanDetailRow(Icons.calendar_today, 'Date', _formatDate(record.PettyCashDate), Color(0xFF10B981)),
                    _buildCleanDetailRow(Icons.attach_money, 'Amount', 'RM ${double.tryParse(record.Amount)?.toStringAsFixed(2) ?? '0.00'}', Color(0xFFF59E0B)),
                    _buildCleanDetailRow(Icons.info_outline, 'Status', record.PaymentStatus, Color(0xFF8B5CF6)),
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

String _formatDate(String dateStr) {
  try {
    final date = DateTime.parse(dateStr);
    return DateFormat('dd MMM yyyy').format(date);
  } catch (e) {
    return dateStr;
  }
}

Widget _buildPettyCashDateSelector(PayableDashbordState state) {
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
                    colors: [Color(0xFFE91E63).withOpacity(0.1), Color(0xFFAD1457).withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "to",
                  style: GoogleFonts.inter(
                    color: Color(0xFFE91E63),
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
            onPressed: () => state.LoadPettycashview(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFE91E63),
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