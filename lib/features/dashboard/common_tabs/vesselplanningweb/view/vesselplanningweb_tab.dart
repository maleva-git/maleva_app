import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../../../core/colors/colors.dart' as colour;
import '../../../../../core/theme/tokens.dart';
import '../bloc/vesselplanningweb_bloc.dart';
import '../bloc/vesselplanningweb_event.dart';
import '../bloc/vesselplanningweb_state.dart';
import '../data/vesselplanningweb_repository.dart';
import '../models/vesselplanningweb_model.dart';
import 'vesselplanning_filter_sheet.dart';
import 'vesselplanning_update_sheet.dart';

const kGradient = LinearGradient(
  colors: [AppTokens.invoiceHeaderStart, colour.kHeaderGradEnd],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
class VesselPlanningWebTab extends StatelessWidget {
  const VesselPlanningWebTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VesselPlanningWebBloc(
        repository: VesselPlanningWebRepository(),
      )..add(const FetchVesselPlanningSearch(
          fromDate: '2000-01-01', // Fetch all initially or last month
          toDate: '2100-01-01',
          etaType: 3,
          searchPorts: '',
          deliveryDone: true,
          employeeId: 0,
        )),
      child: const VesselPlanningWebView(),
    );
  }
}

class VesselPlanningWebView extends StatefulWidget {
  const VesselPlanningWebView({super.key});

  @override
  _VesselPlanningWebViewState createState() => _VesselPlanningWebViewState();
}

class _VesselPlanningWebViewState extends State<VesselPlanningWebView> {
  List<VesselPlanningWebModel> _currentData = [];

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return VesselPlanningFilterSheet(
          onSearch: (fromDate, toDate, etaType, searchPorts, deliveryDone) {
            context.read<VesselPlanningWebBloc>().add(
              FetchVesselPlanningSearch(
                fromDate: fromDate,
                toDate: toDate,
                etaType: etaType,
                searchPorts: searchPorts,
                deliveryDone: deliveryDone,
                employeeId: 0, // 0 for all
              ),
            );
          },
        );
      },
    );
  }

  void _showUpdateSheet(BuildContext context, VesselPlanningWebModel jobData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return VesselPlanningUpdateSheet(
          jobData: jobData,
          onUpdate: (updateList) {
            context.read<VesselPlanningWebBloc>().add(
              UpdateSpecificJobEvent(
                updateList: updateList,
                onSuccess: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Job Updated Successfully')),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _savePlanning(BuildContext context) {
    final checkedItems = _currentData.where((element) => element.isChecked).toList();
    if (checkedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one job to plan.')),
      );
      return;
    }

    // Prepare data for InsertVESSELPLANING API
    List<Map<String, dynamic>> planningList = [
      {
        "Id": 0,
        "CNumberDisplay": "",
        "Remarks": "Generated from Mobile App",
        "SaleDetails": checkedItems.map((e) => {
          "SDId": 0,
          "SaleOrderMasterRefId": e.saleOrderMasterRefId,
          "Remarks": "Added via Web Style Mobile View"
        }).toList()
      }
    ];

    context.read<VesselPlanningWebBloc>().add(SaveVesselPlanningEvent(planningList: planningList));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colour.kPageBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        toolbarHeight: 62,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: kGradient),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Vessel Planning (Web Style)',
          style: GoogleFonts.lato(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 0.3,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: () => _savePlanning(context),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFilterSheet(context),
        elevation: 4,
        backgroundColor: Colors.transparent,
        child: Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: kGradient,
          ),
          child: const Icon(Icons.filter_list_rounded, color: Colors.white, size: 26),
        ),
      ),
      body: BlocConsumer<VesselPlanningWebBloc, VesselPlanningWebState>(
        listener: (context, state) {
          if (state is VesselPlanningWebError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is VesselPlanningWebActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is VesselPlanningWebLoading) {
            return const Center(child: SpinKitFoldingCube(color: colour.kHeaderGradEnd, size: 35.0));
          } else if (state is VesselPlanningWebLoaded) {
            _currentData = state.dataList;
            if (_currentData.isEmpty) {
              return const Center(child: Text("No records found"));
            }
            return _buildDataTable();
          } else if (state is VesselPlanningWebActionLoading) {
            return const Center(child: SpinKitFoldingCube(color: colour.kHeaderGradEnd, size: 35.0));
          }
          return const Center(child: Text("Use the filter to search jobs"));
        },
      ),
    );
  }

  Widget _buildDataTable() {
    final headerStyle = GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12);
    final rowStyle = GoogleFonts.lato(color: colour.kTextDark, fontWeight: FontWeight.w600, fontSize: 12);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTokens.maintCardBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(colour.kHeaderGradEnd),
              dataRowMinHeight: 40,
              dataRowMaxHeight: 40,
              columnSpacing: 20,
              horizontalMargin: 16,
              dividerThickness: 0.5,
              showCheckboxColumn: true,
              columns: [
                DataColumn(label: Text("Select", style: headerStyle)),
                DataColumn(label: Text("PORT", style: headerStyle)),
                DataColumn(label: Text("Remarks", style: headerStyle)),
                DataColumn(label: Text("Off Vessel", style: headerStyle)),
                DataColumn(label: Text("Loading Vessel", style: headerStyle)),
                DataColumn(label: Text("Job No", style: headerStyle)),
                DataColumn(label: Text("Job Type", style: headerStyle)),
                DataColumn(label: Text("Status", style: headerStyle)),
                DataColumn(label: Text("ETA", style: headerStyle)),
                DataColumn(label: Text("OETA", style: headerStyle)),
                DataColumn(label: Text("Package", style: headerStyle)),
                DataColumn(label: Text("Customer Name", style: headerStyle)),
                DataColumn(label: Text("Job Date", style: headerStyle)),
                DataColumn(label: Text("Origin", style: headerStyle)),
                DataColumn(label: Text("Destination", style: headerStyle)),
                DataColumn(label: Text("Action", style: headerStyle)),
              ],
          rows: _currentData.map((data) {
            return DataRow(
              selected: data.isChecked,
              onSelectChanged: (val) {
                setState(() {
                  data.isChecked = val ?? false;
                });
              },
              cells: [
                DataCell(
                  Checkbox(
                    value: data.isChecked,
                    onChanged: (val) {
                      setState(() => data.isChecked = val ?? false);
                    },
                  )
                ),
                DataCell(Text(data.sPort.isNotEmpty ? data.sPort : data.oPort, style: rowStyle)),
                DataCell(Text(data.remarks, style: rowStyle)),
                DataCell(Text(data.offvesselname, style: rowStyle)),
                DataCell(Text(data.loadingvesselname, style: rowStyle)),
                DataCell(Text(data.jobNo, style: rowStyle.copyWith(color: AppTokens.brandPrimary, fontWeight: FontWeight.bold))),
                DataCell(Text(data.jobName, style: rowStyle)),
                DataCell(Text(data.jobStatus, style: rowStyle.copyWith(color: AppTokens.statusSuccess))),
                DataCell(Text(data.eta, style: rowStyle)),
                DataCell(Text(data.oeta, style: rowStyle)),
                DataCell(Text(data.pkg, style: rowStyle)),
                DataCell(Text(data.customerName, style: rowStyle)),
                DataCell(Text(data.jobDate, style: rowStyle)),
                DataCell(Text(data.origin, style: rowStyle)),
                DataCell(Text(data.destination, style: rowStyle)),
                DataCell(
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTokens.invoiceHeaderStart,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(60, 30),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    onPressed: () => _showUpdateSheet(context, data),
                    child: const Text("Edit", style: TextStyle(fontSize: 11)),
                  )
                ),
              ],
            );
          }).toList(),
        ),
      ),
    ),
      ),
    );
  }
}
