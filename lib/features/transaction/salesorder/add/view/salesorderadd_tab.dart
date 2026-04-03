import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/menu/menulist.dart';
import 'package:maleva/MasterSearch/Customer.dart';
import 'package:maleva/MasterSearch/Employee.dart';
import 'package:maleva/MasterSearch/Product.dart';
import 'package:maleva/MasterSearch/JobType.dart';
import 'package:maleva/MasterSearch/JobAllStatus.dart';
import 'package:maleva/MasterSearch/CommodityType.dart';
import 'package:maleva/MasterSearch/CargoStatus.dart';
import 'package:maleva/MasterSearch/Port.dart';
import 'package:maleva/MasterSearch/VesselType.dart';
import 'package:maleva/MasterSearch/AgentCompany.dart';
import 'package:maleva/MasterSearch/Agent.dart';
import 'package:maleva/MasterSearch/AddressList.dart';
import 'package:maleva/MasterSearch/Location.dart';
import '../../view/view/salesorderview_tab.dart';
import '../bloc/salesorderadd_bloc.dart';
import '../bloc/salesorderadd_event.dart';
import '../bloc/salesorderadd_state.dart';
import 'package:maleva/core/colors/colors.dart' as colour;


class SalesOrdersAdd extends StatelessWidget {
  final List<SaleEditDetailModel>? SaleDetails;
  final List<dynamic>? SaleMaster;

  const SalesOrdersAdd({super.key, this.SaleDetails, this.SaleMaster});

  @override
  Widget build(BuildContext context) {
    final isEnquiry =
        objfun.storagenew.getString('EnquiryOpen') == "true";
    if (isEnquiry) objfun.storagenew.setString('EnquiryOpen', "false");

    return BlocProvider(
      create: (ctx) => SalesOrderAddBloc(ctx)
        ..add(StartupSalesOrderAdd(
          saleDetails: SaleDetails,
          saleMaster: SaleMaster,
          isEnquiry: isEnquiry,
        )),
      child: const _SalesOrderAddBody(),
    );
  }
}

// ════════════════════════════════════════════════════════
// Main body
// ════════════════════════════════════════════════════════
class _SalesOrderAddBody extends StatefulWidget {
  const _SalesOrderAddBody();

  @override
  State<_SalesOrderAddBody> createState() =>
      _SalesOrderAddBodyState();
}

class _SalesOrderAddBodyState extends State<_SalesOrderAddBody>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _activeNumpadField = 'qty';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 6);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width  = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return BlocConsumer<SalesOrderAddBloc, SalesOrderAddState>(
      listenWhen: (prev, curr) {
        if (curr is SalesOrderAddLoaded) {
          return curr.isSaved || curr.savedMessage != null;
        }
        return false;
      },
      listener: (context, state) {
        if (state is SalesOrderAddLoaded) {
          if (state.savedMessage != null) {
            objfun.toastMsg(state.savedMessage!, '', context);
          }
          if (state.isSaved) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => const SalesOrdersAdd()));
          }
        }
      },
      builder: (context, state) {
        if (state is SalesOrderAddLoading ||
            state is SalesOrderAddInitial) {
          return const Scaffold(
            backgroundColor: colour.surface,
            body: Center(
              child: SpinKitFoldingCube(color: colour.brand, size: 35),
            ),
          );
        }

        if (state is SalesOrderAddError) {
          return Scaffold(
            backgroundColor: colour.surface,
            body: Center(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: colour.red, size: 48),
                    const SizedBox(height: 12),
                    Text(state.message,
                        style: GoogleFonts.poppins(
                            color: colour.textSub, fontSize: 14)),
                  ]),
            ),
          );
        }

        if (state is! SalesOrderAddLoaded) return const SizedBox();

        return WillPopScope(
          onWillPop: () async {
            if (state.showSearch) return false;
            final result = await objfun.ConfirmationMsgYesNo(
                context, "Are you Sure you want to Exit?");
            if (result == true) Navigator.of(context).pop();
            return false;
          },
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: colour.surface,
            appBar: _buildAppBar(context, state),
            drawer: const Menulist(),
            body: state.progress == false
                ? const Center(
                child: SpinKitFoldingCube(
                    color: colour.brand, size: 35))
                : _buildTabBody(
                context, state, width, height),
            bottomNavigationBar:
            _buildBottomNav(context, state),
          ),
        );
      },
    );
  }

  // ── AppBar ──────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(
      BuildContext context, SalesOrderAddLoaded state) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [colour.brand, colour.brandMid],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
                color: Color(0x551555F3),
                blurRadius: 12,
                offset: Offset(0, 4))
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Sales Order',
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3)),
          Text(objfun.storagenew.getString('Username') ?? '',
              style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
        ],
      ),
      actions: [
        _appBarBtn(
          label: 'VIEW',
          enabled: state.fieldPermission["VIEW"] == true,
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const SaleOrderView())),
        ),
        _appBarBtn(
          label: 'SAVE',
          enabled: state.fieldPermission["SAVE"] == true,
          onPressed: () async {
            final confirm = await objfun.ConfirmationMsgYesNo(
                context, "Do You Want to Save ?");
            if (confirm == true) {
              context
                  .read<SalesOrderAddBloc>()
                  .add(SaveSalesOrderEvent());
            }
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _appBarBtn({
    required String label,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: TextButton(
        onPressed: enabled ? onPressed : null,
        style: TextButton.styleFrom(
          backgroundColor: enabled
              ? Colors.white.withOpacity(0.2)
              : Colors.white.withOpacity(0.07),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                  color: enabled
                      ? Colors.white54
                      : Colors.white24)),
          padding:
          const EdgeInsets.symmetric(horizontal: 12),
        ),
        child: Text(label,
            style: GoogleFonts.poppins(
                color: enabled
                    ? Colors.white
                    : Colors.white38,
                fontSize: 12,
                fontWeight: FontWeight.w700)),
      ),
    );
  }

  // ── Tab body ────────────────────────────────────────
  Widget _buildTabBody(BuildContext context,
      SalesOrderAddLoaded state, double width, double height) {
    return DefaultTabController(
      length: 6,
      child: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildTab1(context, state, width, height),
          _buildTab2(context, state, width, height),
          _buildTab3(context, state, height),
          _buildTab4(context, state, height),
          _buildTab5(context, state, height),
          _buildTab6(context, state, width, height),
        ],
      ),
    );
  }

  // ── Bottom Nav ──────────────────────────────────────
  Widget _buildBottomNav(
      BuildContext context, SalesOrderAddLoaded state) {
    final List<IconData> navIcons = [
      Icons.info_outline_rounded,
      Icons.comment_outlined,
      Icons.directions_boat_filled,
      Icons.directions_boat_filled_outlined,
      Icons.local_shipping_rounded,
      Icons.format_list_bulleted_rounded,
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: colour.brand.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, -3),
          )
        ],
        border: Border(
            top: BorderSide(color: colour.border, width: 1)),
      ),
      child: SalomonBottomBar(
        duration: const Duration(milliseconds: 300),
        currentIndex: _tabController.index,
        onTap: (i) => setState(() => _tabController.index = i),
        selectedItemColor: colour.brand,
        unselectedItemColor: colour.textSub,
        items: navIcons
            .map((icon) => SalomonBottomBarItem(
          icon: Icon(icon, size: 22),
          title: const SizedBox.shrink(),
          selectedColor: colour.brand,
        ))
            .toList(),
      ),
    );
  }

  // ════════════════════════════════════════════════════
  // TAB 1 — Basic Info
  // ════════════════════════════════════════════════════
  Widget _buildTab1(BuildContext context,
      SalesOrderAddLoaded state, double width, double height) {
    final bloc = context.read<SalesOrderAddBloc>();
    final fp   = state.fieldPermission;

    return _tabScroll(children: [
      _sectionCard(children: [
        Row(children: [
          Expanded(flex: 2, child: _labelText('Job No')),
          Expanded(flex: 3, child: _readonlyBox(state.txtJobNo)),
          const SizedBox(width: 10),
          Expanded(
            flex: 4,
            child: _dateTapBox(
              date: width <= 370
                  ? DateFormat("dd-MM-yy").format(DateTime.parse(state.dtpSaleOrderdate))
                  : DateFormat("dd-MM-yyyy").format(DateTime.parse(state.dtpSaleOrderdate)),
              onTap: null,
            ),
          ),
        ]),
      ]),

      const SizedBox(height: 10),

      _sectionCard(children: [
        Row(children: [
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                state.totalAmount.toString(),
                style: GoogleFonts.poppins(
                    color: colour.red, fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: _styledDropdown<String>(
              value: state.dropdownValue,
              items: SalesOrderAddBloc.billType,
              enabled: fp["cmbBillType"] == true && !state.disabledBillType,
              onChanged: (v) => bloc.add(BillTypeChanged(v!)),
            ),
          ),
        ]),
      ]),

      const SizedBox(height: 10),

      _sectionCard(children: [
        _searchField(
          hint: "Customer Name",
          value: state.txtCustomer,
          enabled: fp["txtCustomer"] == true,
          onSearch: () async {
            final r = await Navigator.push(context,
                MaterialPageRoute(builder: (_) => const Customer(Searchby: 1, SearchId: 0)));
            if (r != null) {
              bloc.add(CustomerSelected(
                  objfun.SelectCustomerList.AccountName,
                  objfun.SelectCustomerList.Id));
              objfun.SelectCustomerList = CustomerModel.Empty();
            }
          },
          onClear: () => bloc.add(CustomerSelected('', 0)),
        ),
        _gap(),
        _searchField(
          hint: "Job Type",
          value: state.txtJobType,
          enabled: fp["txtJobType"] == true,
          onSearch: () async {
            final r = await Navigator.push(context,
                MaterialPageRoute(builder: (_) => const JobType(Searchby: 1, SearchId: 0)));
            if (r != null) {
              bloc.add(JobTypeSelected(
                  objfun.SelectJobTypeList.Name,
                  objfun.SelectJobTypeList.Id));
              objfun.SelectJobTypeList = JobTypeModel.Empty();
            }
          },
          onClear: () => bloc.add(JobTypeSelected('', 0)),
        ),
        _gap(),
        _searchField(
          hint: "Job Status",
          value: state.txtJobStatus,
          enabled: fp["txtJobStatus"] == true && state.txtJobType.isNotEmpty,
          onSearch: () async {
            final r = await Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => JobAllStatus(
                        Searchby: 1, SearchId: 0, JobTypeId: state.jobTypeId)));
            if (r != null) {
              bloc.add(JobStatusSelected(
                  objfun.SelectAllStatusList.StatusName,
                  objfun.SelectAllStatusList.Status));
              objfun.SelectAllStatusList = JobAllStatusModel.Empty();
            }
          },
          onClear: () => bloc.add(JobStatusSelected('', 0)),
        ),
        _gap(),
        _editField(
          hint: 'Remarks',
          value: state.txtRemarks,
          enabled: fp["txtRemarks"] == true,
          onChanged: (v) => bloc.add(UpdateTextField('txtRemarks', v)),
          minLines: 2,
          maxLines: 4,
        ),
        _gap(),
        _editField(
          hint: 'DO Description',
          value: state.txtDoDescription,
          enabled: fp["txtDoDescription"] == true,
          onChanged: (v) => bloc.add(UpdateTextField('txtDoDescription', v)),
          minLines: 3,
          maxLines: 5,
          keyboardType: TextInputType.multiline,
        ),
      ]),

      const SizedBox(height: 10),

      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _iconBtn(
            icon: Icons.library_add_sharp,
            enabled: fp["addProduct"] == true,
            onTap: () => _showProductDialog(context, state, -1),
          ),
          const SizedBox(width: 8),
          _iconBtn(
            icon: Icons.library_books_rounded,
            enabled: true,
            onTap: () => bloc.add(ToggleProductView()),
          ),
        ],
      ),

      if (state.visibleProductview) ...[
        const SizedBox(height: 6),
        _productHeader(),
        const SizedBox(height: 4),
        if (state.productViewList.isEmpty)
          _emptyProducts()
        else
          ...state.productViewList
              .asMap()
              .entries
              .map((e) => _productRow(context, state, e.key, e.value, bloc))
              .toList(),
      ],
    ]);
  }

  // ════════════════════════════════════════════════════
  // TAB 2 — Commodity
  // ════════════════════════════════════════════════════
  Widget _buildTab2(BuildContext context,
      SalesOrderAddLoaded state, double width, double height) {
    final bloc = context.read<SalesOrderAddBloc>();
    final fp   = state.fieldPermission;

    return _tabScroll(children: [
      _sectionCard(children: [
        _searchField(
          hint: "Commodity Type",
          value: state.txtCommodityType,
          enabled: fp["txtCommodityType"] == true,
          onSearch: () async {
            // ✅ FIX: await + isNotEmpty check (no r != null)
            await Navigator.push(context, MaterialPageRoute(
                builder: (_) => const CommodityType(Searchby: 1, SearchId: 0)));
            print("DEBUG: returned - '${objfun.SelectedCommodityName}'");
            if (objfun.SelectedCommodityName.isNotEmpty) {
              bloc.add(CommoditySelected(objfun.SelectedCommodityName));
              objfun.SelectedCommodityName = "";
            }
          },
          onClear: () => bloc.add(CommoditySelected('')),
        ),
        _gap(),
        _editField(
          hint: 'Weight',
          value: state.txtWeight,
          enabled: fp["txtWeight"] == true,
          onChanged: (v) => bloc.add(UpdateTextField('txtWeight', v)),
        ),
        _gap(),
        _editField(
          hint: 'Quantity',
          value: state.txtQuantity,
          enabled: fp["txtQuantity"] == true,
          onChanged: (v) => bloc.add(UpdateTextField('txtQuantity', v)),
        ),
        _gap(),
        if (!state.visibleGC)
          _editField(
            hint: 'Truck Size',
            value: state.txtTruckSize,
            enabled: fp["txtTruckSize"] == true,
            onChanged: (v) => bloc.add(UpdateTextField('txtTruckSize', v)),
          )
        else
          Row(children: [
            Expanded(flex: 2, child: _labelText('Truck Size')),
            const SizedBox(width: 10),
            Expanded(
              flex: 5,
              child: _styledDropdown<String>(
                value: state.dropdownValueTruckSize,
                items: SalesOrderAddBloc.truckSizeList,
                enabled: true,
                onChanged: (v) => bloc.add(UpdateDropdown('dropdownValueTruckSize', v)),
              ),
            ),
          ]),
        if (state.visibleAWBNo) ...[
          _gap(),
          _editField(
            hint: 'AWB NO',
            value: state.txtAWBNo,
            enabled: fp["txtAWBNo"] == true,
            onChanged: (v) => bloc.add(UpdateTextField('txtAWBNo', v)),
          ),
        ],
        if (state.visibleBLCopy) ...[
          _gap(),
          _editField(
            hint: 'BL Copy',
            value: state.txtBLCopy,
            enabled: fp["txtBLCopy"] == true,
            onChanged: (v) => bloc.add(UpdateTextField('txtBLCopy', v)),
          ),
        ],
        _gap(),
        _searchField(
          hint: "Cargo",
          value: state.txtCargo,
          enabled: fp["txtCargo"] == true,
          onSearch: () async {
            // ✅ FIX: await + isNotEmpty check
            await Navigator.push(context, MaterialPageRoute(
                builder: (_) => const CargoStatus(Searchby: 1, SearchId: 0)));
            if (objfun.SelectedCargoName.isNotEmpty) {
              bloc.add(CargoSelected(objfun.SelectedCargoName));
              objfun.SelectedCargoName = "";
            }
          },
          onClear: () => bloc.add(CargoSelected('')),
        ),
        _gap(),
        _editField(
          hint: 'PTW No',
          value: state.txtPTWNo,
          enabled: fp["txtPTWNo"] == true,
          onChanged: (v) => bloc.add(UpdateTextField('txtPTWNo', v)),
        ),
      ]),
    ]);
  }

  // ════════════════════════════════════════════════════
  // TAB 3 — Loading
  // ════════════════════════════════════════════════════
  Widget _buildTab3(BuildContext context,
      SalesOrderAddLoaded state, double height) {
    final bloc = context.read<SalesOrderAddBloc>();
    final fp   = state.fieldPermission;

    return _tabScroll(children: [
      _sectionCard(children: [
        if (state.visibleLETA) ...[
          _dateCheckRow(
            context: context,
            label: "ETA",
            dateStr: state.dtpLETAdate,
            checkValue: state.checkBoxValueLETA,
            checkKey: 'checkBoxValueLETA',
            dateKey: 'dtpLETAdate',
            enabled: fp["chkLETA"] == true,
            bloc: bloc,
          ),
          _gap(),
        ],
        if (state.visibleLETB) ...[
          _dateCheckRow(
            context: context,
            label: "ETB",
            dateStr: state.dtpLETBdate,
            checkValue: state.checkBoxValueLETB,
            checkKey: 'checkBoxValueLETB',
            dateKey: 'dtpLETBdate',
            enabled: fp["chkLETB"] == true,
            bloc: bloc,
          ),
          _gap(),
        ],
        if (state.visibleLETD) ...[
          _dateCheckRow(
            context: context,
            label: "ETD",
            dateStr: state.dtpLETDdate,
            checkValue: state.checkBoxValueLETD,
            checkKey: 'checkBoxValueLETD',
            dateKey: 'dtpLETDdate',
            enabled: fp["chkLETD"] == true,
            bloc: bloc,
          ),
          _gap(),
        ],
        if (state.visibleFlightTime) ...[
          _dateCheckRow(
            context: context,
            label: "Flight Time",
            dateStr: state.dtpFlightTimedate,
            checkValue: state.checkBoxValueFlightTime,
            checkKey: 'checkBoxValueFlightTime',
            dateKey: 'dtpFlightTimedate',
            enabled: fp["chkFlightTime"] == true,
            bloc: bloc,
            showTime: true,
          ),
          _gap(),
        ],
        if (state.visibleLShippingAgent) ...[
          _searchField(
            hint: "Shipping Agent",
            value: state.txtLAgentCompany,
            enabled: fp["txtLAgentCompany"] == true,
            onSearch: () async {
              final r = await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AgentCompany(Searchby: 1, SearchId: 0)));
              if (r != null) {
                bloc.add(LAgentCompanySelected(
                    objfun.SelectAgentCompanyList.Name,
                    objfun.SelectAgentCompanyList.Id));
                objfun.SelectAgentCompanyList = AgentCompanyModel.Empty();
              }
            },
            onClear: () => bloc.add(LAgentCompanySelected('', 0)),
          ),
          _gap(),
        ],
        if (state.visibleLAgentName) ...[
          _searchField(
            hint: "Agent Name",
            value: state.txtLAgentName,
            enabled: fp["txtLAgentName"] == true && state.txtLAgentCompany.isNotEmpty,
            onSearch: () async {
              final r = await Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => Agent(
                          Searchby: 1, SearchId: 0, AgentCompanyId: state.lAgentCompanyId)));
              if (r != null) {
                bloc.add(LAgentSelected(
                    objfun.SelectAgentAllList.AgentName,
                    objfun.SelectAgentAllList.Id));
                objfun.SelectAgentAllList = AgentModel.Empty();
              }
            },
            onClear: () => bloc.add(LAgentSelected('', 0)),
          ),
          _gap(),
        ],
        if (state.visibleLScn) ...[
          _editField(
            hint: 'SCN',
            value: state.txtLSCN,
            enabled: fp["txtLSCN"] == true,
            onChanged: (v) => bloc.add(UpdateTextField('txtLSCN', v)),
          ),
          _gap(),
        ],
        if (state.visibleLoadingVessel) ...[
          _editField(
            hint: 'Loading Vessel Name',
            value: state.txtLoadingVessel,
            enabled: fp["txtLoadingVessel"] == true,
            onChanged: (v) => bloc.add(UpdateTextField('txtLoadingVessel', v)),
          ),
          _gap(),
        ],
        if (state.visibleLPort) ...[
          _searchField(
            hint: "Port",
            value: state.txtLPort,
            enabled: fp["txtLPort"] == true,
            onSearch: () async {
              // ✅ FIX: await + isNotEmpty check
              await Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const Port(Searchby: 1, SearchId: 0)));
              if (objfun.SelectedPortName.isNotEmpty) {
                bloc.add(LPortSelected(objfun.SelectedPortName));
                objfun.SelectedPortName = "";
              }
            },
            onClear: () => bloc.add(LPortSelected('')),
          ),
          _gap(),
        ],
        if (state.visibleLVesselType)
          _searchField(
            hint: "Vessel Type",
            value: state.txtLVesselType,
            enabled: fp["txtLVesselType"] == true,
            onSearch: () async {
              // ✅ FIX: await + isNotEmpty check
              await Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const VesselType(Searchby: 1, SearchId: 0)));
              if (objfun.SelectedVesselTypeName.isNotEmpty) {
                bloc.add(LVesselTypeSelected(objfun.SelectedVesselTypeName));
                objfun.SelectedVesselTypeName = "";
              }
            },
            onClear: () => bloc.add(LVesselTypeSelected('')),
          ),
      ]),
    ]);
  }

  // ════════════════════════════════════════════════════
  // TAB 4 — Origin
  // ════════════════════════════════════════════════════
  Widget _buildTab4(BuildContext context,
      SalesOrderAddLoaded state, double height) {
    final bloc = context.read<SalesOrderAddBloc>();
    final fp   = state.fieldPermission;

    return _tabScroll(children: [
      _sectionCard(children: [
        if (state.visibleOETA) ...[
          _dateCheckRow(
            context: context,
            label: "ETA",
            dateStr: state.dtpOETAdate,
            checkValue: state.checkBoxValueOETA,
            checkKey: 'checkBoxValueOETA',
            dateKey: 'dtpOETAdate',
            enabled: fp["chkOETA"] == true,
            bloc: bloc,
            showTime: true,
          ),
          _gap(),
        ],
        if (state.visibleOETB) ...[
          _dateCheckRow(
            context: context,
            label: "ETB",
            dateStr: state.dtpOETBdate,
            checkValue: state.checkBoxValueOETB,
            checkKey: 'checkBoxValueOETB',
            dateKey: 'dtpOETBdate',
            enabled: fp["chkLETB"] == true,
            bloc: bloc,
            showTime: true,
          ),
          _gap(),
        ],
        if (state.visibleOETD) ...[
          _dateCheckRow(
            context: context,
            label: "ETD",
            dateStr: state.dtpOETDdate,
            checkValue: state.checkBoxValueOETD,
            checkKey: 'checkBoxValueOETD',
            dateKey: 'dtpOETDdate',
            enabled: fp["chkLETD"] == true,
            bloc: bloc,
            showTime: true,
          ),
          _gap(),
        ],
        if (state.visibleOShippingAgent) ...[
          _searchField(
            hint: "Shipping Agent",
            value: state.txtOAgentCompany,
            enabled: fp["txtOAgentCompany"] == true,
            onSearch: () async {
              final r = await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AgentCompany(Searchby: 1, SearchId: 0)));
              if (r != null) {
                bloc.add(OAgentCompanySelected(
                    objfun.SelectAgentCompanyList.Name,
                    objfun.SelectAgentCompanyList.Id));
                objfun.SelectAgentCompanyList = AgentCompanyModel.Empty();
              }
            },
            onClear: () => bloc.add(OAgentCompanySelected('', 0)),
          ),
          _gap(),
        ],
        if (state.visibleOAgentName) ...[
          _searchField(
            hint: "Agent Name",
            value: state.txtOAgentName,
            enabled: fp["txtOAgentName"] == true && state.txtOAgentCompany.isNotEmpty,
            onSearch: () async {
              final r = await Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => Agent(
                          Searchby: 1, SearchId: 0, AgentCompanyId: state.oAgentCompanyId)));
              if (r != null) {
                bloc.add(OAgentSelected(
                    objfun.SelectAgentAllList.AgentName,
                    objfun.SelectAgentAllList.Id));
                objfun.SelectAgentAllList = AgentModel.Empty();
              }
            },
            onClear: () => bloc.add(OAgentSelected('', 0)),
          ),
          _gap(),
        ],
        if (state.visibleOScn) ...[
          _editField(
            hint: 'SCN',
            value: state.txtOSCN,
            enabled: fp["txtOSCN"] == true,
            onChanged: (v) => bloc.add(UpdateTextField('txtOSCN', v)),
          ),
          _gap(),
        ],
        if (state.visibleOffVessel) ...[
          _editField(
            hint: 'Off Vessel Name',
            value: state.txtOffVessel,
            enabled: fp["txtOffVessel"] == true,
            onChanged: (v) => bloc.add(UpdateTextField('txtOffVessel', v)),
          ),
          _gap(),
        ],
        if (state.visibleOPort) ...[
          _searchField(
            hint: "Port",
            value: state.txtOPort,
            enabled: fp["txtOPort"] == true,
            onSearch: () async {
              // ✅ FIX: await + isNotEmpty check
              await Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const Port(Searchby: 1, SearchId: 0)));
              if (objfun.SelectedPortName.isNotEmpty) {
                bloc.add(OPortSelected(objfun.SelectedPortName));
                objfun.SelectedPortName = "";
              }
            },
            onClear: () => bloc.add(OPortSelected('')),
          ),
          _gap(),
        ],
        if (state.visibleOVesselType)
          _searchField(
            hint: "Vessel Type",
            value: state.txtOVesselType,
            enabled: fp["txtOVesselType"] == true,
            onSearch: () async {
              // ✅ FIX: await + isNotEmpty check
              await Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const VesselType(Searchby: 1, SearchId: 0)));
              if (objfun.SelectedVesselTypeName.isNotEmpty) {
                bloc.add(OVesselTypeSelected(objfun.SelectedVesselTypeName));
                objfun.SelectedVesselTypeName = "";
              }
            },
            onClear: () => bloc.add(OVesselTypeSelected('')),
          ),
      ]),
    ]);
  }

  // ════════════════════════════════════════════════════
  // TAB 5 — Pickup / Delivery
  // ════════════════════════════════════════════════════
  Widget _buildTab5(BuildContext context,
      SalesOrderAddLoaded state, double height) {
    final bloc = context.read<SalesOrderAddBloc>();
    final fp   = state.fieldPermission;

    return _tabScroll(children: [
      _sectionCard(children: [
        _dateCheckRow(
          context: context,
          label: "PickUp Date",
          dateStr: state.dtpPickUpdate,
          checkValue: state.checkBoxValuePickUp,
          checkKey: 'checkBoxValuePickUp',
          dateKey: 'dtpPickUpdate',
          enabled: fp["chkPickup"] == true,
          bloc: bloc,
          showTime: true,
        ),
        _gap(),
        _dateCheckRow(
          context: context,
          label: "Delivery Date",
          dateStr: state.dtpDeliverydate,
          checkValue: state.checkBoxValueDelivery,
          checkKey: 'checkBoxValueDelivery',
          dateKey: 'dtpDeliverydate',
          enabled: fp["chkDelivery"] == true,
          bloc: bloc,
          showTime: true,
        ),
        _gap(),
        _dateCheckRow(
          context: context,
          label: "WH Entry",
          dateStr: state.dtpWHEntrydate,
          checkValue: state.checkBoxValueWHEntry,
          checkKey: 'checkBoxValueWHEntry',
          dateKey: 'dtpWHEntrydate',
          enabled: fp["chkWareHouseEntry"] == true,
          bloc: bloc,
          showTime: true,
        ),
        _gap(),
        _dateCheckRow(
          context: context,
          label: "WH Exit",
          dateStr: state.dtpWHExitdate,
          checkValue: state.checkBoxValueWHExit,
          checkKey: 'checkBoxValueWHExit',
          dateKey: 'dtpWHExitdate',
          enabled: fp["chkWareHouseExit"] == true,
          bloc: bloc,
          showTime: true,
        ),
      ]),

      const SizedBox(height: 10),

      if (state.visibleOrigin || state.visibleDestination)
        _sectionCard(children: [
          if (state.visibleOrigin && !state.visibleGC) ...[
            _editField(
              hint: 'Origin',
              value: state.txtOrigin,
              enabled: fp["txtOrigin"] == true,
              onChanged: (v) => bloc.add(UpdateTextField('txtOrigin', v)),
            ),
            _gap(),
          ],
          if (state.visibleDestination && !state.visibleGC) ...[
            _editField(
              hint: 'Destination',
              value: state.txtDestination,
              enabled: fp["txtDestination"] == true,
              onChanged: (v) => bloc.add(UpdateTextField('txtDestination', v)),
            ),
            _gap(),
          ],
          if (state.visibleGC) ...[
            _searchField(
              hint: "Origin",
              value: state.txtOrigin,
              enabled: fp["txtOrigin"] == true,
              onSearch: () async {
                final r = await Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const Location(Searchby: 1, SearchId: 0)));
                if (r != null) {
                  bloc.add(OriginSelected(
                      objfun.SelectLocationList.Location,
                      objfun.SelectLocationList.Id));
                  objfun.SelectLocationList = LocationModel.Empty();
                }
              },
              onClear: () => bloc.add(OriginSelected('', 0)),
            ),
            _gap(),
            _searchField(
              hint: "Destination",
              value: state.txtDestination,
              enabled: fp["txtDestination"] == true,
              onSearch: () async {
                final r = await Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const Location(Searchby: 1, SearchId: 0)));
                if (r != null) {
                  bloc.add(DestinationSelected(
                      objfun.SelectLocationList.Location,
                      objfun.SelectLocationList.Id));
                  objfun.SelectLocationList = LocationModel.Empty();
                }
              },
              onClear: () => bloc.add(DestinationSelected('', 0)),
            ),
          ],
        ]),

      const SizedBox(height: 10),

      _addressCard(
        title: 'PickUp Address',
        addressValue: state.txtPickUpAddress,
        qtyValue: state.txtPickUpQuantity,
        addressEnabled: fp["txtPickUpAddress"] == true,
        qtyEnabled: fp["txtPickUpQuantity"] == true,
        onAddressChanged: (v) => bloc.add(UpdateTextField('txtPickUpAddress', v)),
        onQtyChanged: (v) => bloc.add(UpdateTextField('txtPickUpQuantity', v)),
        onSearch: () async {
          final r = await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddressList(Searchby: 1, SearchId: 0)));
          if (r != null && objfun.SelectAddressList.isNotEmpty) {
            final enc = Uri.encodeComponent(objfun.SelectAddressList);
            await OnlineApi.SelectAddressDetails(context, enc);
            if (objfun.AddressDetailedList.isNotEmpty) {
              bloc.add(PickUpAddressSelected(
                  objfun.AddressDetailedList[0].Address +
                      (objfun.AddressDetailedList[0].Phone != null
                          ? " ${objfun.AddressDetailedList[0].Phone}"
                          : "")));
            }
            objfun.SelectAddressList = "";
            objfun.AddressDetailedList = [];
          }
        },
        onClear: () => bloc.add(PickUpAddressSelected('')),
        onList: () => _showPickUpList(context, state),
        onAdd: () => bloc.add(AddPickUpAddress()),
      ),

      const SizedBox(height: 10),

      _addressCard(
        title: 'Delivery Address',
        addressValue: state.txtDeliveryAddress,
        qtyValue: state.txtDeliveryQuantity,
        addressEnabled: fp["txtDeliveryAddress"] == true,
        qtyEnabled: fp["txtDeliveryQuantity"] == true,
        onAddressChanged: (v) => bloc.add(UpdateTextField('txtDeliveryAddress', v)),
        onQtyChanged: (v) => bloc.add(UpdateTextField('txtDeliveryQuantity', v)),
        onSearch: () async {
          final r = await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddressList(Searchby: 1, SearchId: 0)));
          if (r != null && objfun.SelectAddressList.isNotEmpty) {
            final enc = Uri.encodeComponent(objfun.SelectAddressList);
            await OnlineApi.SelectAddressDetails(context, enc);
            if (objfun.AddressDetailedList.isNotEmpty) {
              bloc.add(DeliveryAddressSelected(
                  objfun.AddressDetailedList[0].Address +
                      (objfun.AddressDetailedList[0].Phone != null
                          ? " ${objfun.AddressDetailedList[0].Phone}"
                          : "")));
            }
            objfun.SelectAddressList = "";
            objfun.AddressDetailedList = [];
          }
        },
        onClear: () => bloc.add(DeliveryAddressSelected('')),
        onList: () => _showDeliveryList(context, state),
        onAdd: () => bloc.add(AddDeliveryAddress()),
      ),

      const SizedBox(height: 10),

      _sectionCard(children: [
        _sectionLabel('Warehouse Address'),
        _gap(),
        _addressMultiField(
          hint: 'Warehouse Address',
          value: state.txtWarehouseAddress,
          enabled: fp["txtWarehouseAddress"] == true,
          onChanged: (v) => bloc.add(UpdateTextField('txtWarehouseAddress', v)),
          onSearch: () async {
            final r = await Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AddressList(Searchby: 1, SearchId: 0)));
            if (r != null && objfun.SelectAddressList.isNotEmpty) {
              final enc = Uri.encodeComponent(objfun.SelectAddressList);
              await OnlineApi.SelectAddressDetails(context, enc);
              if (objfun.AddressDetailedList.isNotEmpty) {
                bloc.add(WarehouseAddressSelected(
                    objfun.AddressDetailedList[0].Address +
                        (objfun.AddressDetailedList[0].Phone != null
                            ? " ${objfun.AddressDetailedList[0].Phone}"
                            : "")));
              }
              objfun.SelectAddressList = "";
              objfun.AddressDetailedList = [];
            }
          },
          onClear: () => bloc.add(WarehouseAddressSelected('')),
        ),
      ]),
    ]);
  }

  // ════════════════════════════════════════════════════
  // TAB 6 — Forwarding / ZB / Boarding
  // ════════════════════════════════════════════════════
  Widget _buildTab6(BuildContext context,
      SalesOrderAddLoaded state, double width, double height) {
    final bloc = context.read<SalesOrderAddBloc>();
    final fp   = state.fieldPermission;

    return _tabScroll(children: [
      if (state.visibleFORWARDING) ...[
        _fwCard(context, bloc, state, fp,
            fwNum: 1,
            visible: state.visibleFW1,
            dropValue: state.dropdownValueFW1,
            dropKey: 'dropdownValueFW1',
            dateStr: state.dtpFW1date,
            checkValue: state.checkBoxValueFW1,
            checkKey: 'checkBoxValueFW1',
            dateKey: 'dtpFW1date',
            smkValue: state.txtSmk1,
            smkKey: 'txtSmk1',
            enRef: state.txtENRef1,
            enKey: 'txtENRef1',
            exRef: state.txtExRef1,
            exKey: 'txtExRef1',
            sealEmpValue: state.txtSealByEmp1,
            breakEmpValue: state.txtBreakByEmp1,
            s1Value: state.txtForwarding1S1,
            s1Key: 'txtForwarding1S1',
            s2Value: state.txtForwarding1S2,
            s2Key: 'txtForwarding1S2',
            toggleEvent: ToggleFW1(),
            sealEvent: (n, id) => SealEmp1Selected(n, id),
            breakEvent: (n, id) => SealEmp1Selected(n, id, isBreak: true),
            width: width),
        const SizedBox(height: 10),
        _fwCard(context, bloc, state, fp,
            fwNum: 2,
            visible: state.visibleFW2,
            dropValue: state.dropdownValueFW2,
            dropKey: 'dropdownValueFW2',
            dateStr: state.dtpFW2date,
            checkValue: state.checkBoxValueFW2,
            checkKey: 'checkBoxValueFW2',
            dateKey: 'dtpFW2date',
            smkValue: state.txtSmk2,
            smkKey: 'txtSmk2',
            enRef: state.txtENRef2,
            enKey: 'txtENRef2',
            exRef: state.txtExRef2,
            exKey: 'txtExRef2',
            sealEmpValue: state.txtSealByEmp2,
            breakEmpValue: state.txtBreakByEmp2,
            s1Value: state.txtForwarding2S1,
            s1Key: 'txtForwarding2S1',
            s2Value: state.txtForwarding2S2,
            s2Key: 'txtForwarding2S2',
            toggleEvent: ToggleFW2(),
            sealEvent: (n, id) => SealEmp2Selected(n, id),
            breakEvent: (n, id) => SealEmp2Selected(n, id, isBreak: true),
            width: width),
        const SizedBox(height: 10),
        _fwCard(context, bloc, state, fp,
            fwNum: 3,
            visible: state.visibleFW3,
            dropValue: state.dropdownValueFW3,
            dropKey: 'dropdownValueFW3',
            dateStr: state.dtpFW3date,
            checkValue: state.checkBoxValueFW3,
            checkKey: 'checkBoxValueFW3',
            dateKey: 'dtpFW3date',
            smkValue: state.txtSmk3,
            smkKey: 'txtSmk3',
            enRef: state.txtENRef3,
            enKey: 'txtENRef3',
            exRef: state.txtExRef3,
            exKey: 'txtExRef3',
            sealEmpValue: state.txtSealByEmp3,
            breakEmpValue: state.txtBreakByEmp3,
            s1Value: state.txtForwarding3S1,
            s1Key: 'txtForwarding3S1',
            s2Value: state.txtForwarding3S2,
            s2Key: 'txtForwarding3S2',
            toggleEvent: ToggleFW3(),
            sealEvent: (n, id) => SealEmp3Selected(n, id),
            breakEvent: (n, id) => SealEmp3Selected(n, id, isBreak: true),
            width: width),
        const SizedBox(height: 10),
      ],

      if (state.visibleZB) ...[
        _zbCard(context, bloc, state, fp, 1),
        const SizedBox(height: 10),
        _zbCard(context, bloc, state, fp, 2),
        const SizedBox(height: 10),
      ],

      _sectionCard(children: [
        _sectionLabel('Boarding Officer 1'),
        _gap(),
        _searchField(
          hint: "Boarding Officer 1",
          value: state.txtBoardingOfficer1,
          enabled: fp["txtBoardingOfficer1"] == true,
          onSearch: () async {
            await OnlineApi.SelectEmployee(context, '', 'Operation');
            // ✅ FIX: await + isNotEmpty check
            await Navigator.push(context,
                MaterialPageRoute(builder: (_) => const Employee(Searchby: 1, SearchId: 0)));
            if (objfun.SelectEmployeeList.AccountName.isNotEmpty) {
              bloc.add(BoardingOfficer1Selected(
                  objfun.SelectEmployeeList.AccountName,
                  objfun.SelectEmployeeList.Id));
              objfun.SelectEmployeeList = EmployeeModel.Empty();
            }
          },
          onClear: () => bloc.add(BoardingOfficer1Selected('', 0)),
        ),
        _gap(),
        _editField(
          hint: 'Amount 1',
          value: state.txtAmount1,
          enabled: !state.disabledAmount1,
          onChanged: (v) => bloc.add(UpdateTextField('txtAmount1', v)),
        ),
        _gap(),
        _editField(
          hint: 'Port Charges Ref',
          value: state.txtPortChargeRef1,
          enabled: fp["txtPortChargeRef1"] == true,
          onChanged: (v) => bloc.add(UpdateTextField('txtPortChargeRef1', v)),
        ),
        _gap(),
        _divider(),
        _gap(),
        _sectionLabel('Boarding Officer 2'),
        _gap(),
        _searchField(
          hint: "Boarding Officer 2",
          value: state.txtBoardingOfficer2,
          enabled: fp["txtBoardingOfficer2"] == true,
          onSearch: () async {
            await OnlineApi.SelectEmployee(context, '', 'Operation');
            // ✅ FIX: await + isNotEmpty check
            await Navigator.push(context,
                MaterialPageRoute(builder: (_) => const Employee(Searchby: 1, SearchId: 0)));
            if (objfun.SelectEmployeeList.AccountName.isNotEmpty) {
              bloc.add(BoardingOfficer2Selected(
                  objfun.SelectEmployeeList.AccountName,
                  objfun.SelectEmployeeList.Id));
              objfun.SelectEmployeeList = EmployeeModel.Empty();
            }
          },
          onClear: () => bloc.add(BoardingOfficer2Selected('', 0)),
        ),
        _gap(),
        _editField(
          hint: 'Amount 2',
          value: state.txtAmount2,
          enabled: !state.disabledAmount2,
          onChanged: (v) => bloc.add(UpdateTextField('txtAmount2', v)),
        ),
        _gap(),
        _editField(
          hint: 'Port Charges',
          value: state.txtPortCharges,
          enabled: fp["txtPortCharges"] == true,
          onChanged: (v) => bloc.add(UpdateTextField('txtPortCharges', v)),
        ),
      ]),
    ]);
  }

  // ════════════════════════════════════════════════════
  // FW Card
  // ════════════════════════════════════════════════════
  Widget _fwCard(
      BuildContext context,
      SalesOrderAddBloc bloc,
      SalesOrderAddLoaded state,
      Map<String, bool> fp, {
        required int fwNum,
        required bool visible,
        required String? dropValue,
        required String dropKey,
        required String dateStr,
        required bool checkValue,
        required String checkKey,
        required String dateKey,
        required String smkValue,
        required String smkKey,
        required String enRef,
        required String enKey,
        required String exRef,
        required String exKey,
        required String sealEmpValue,
        required String breakEmpValue,
        required String s1Value,
        required String s1Key,
        required String s2Value,
        required String s2Key,
        required SalesOrderAddEvent toggleEvent,
        required SalesOrderAddEvent Function(String, int) sealEvent,
        required SalesOrderAddEvent Function(String, int) breakEvent,
        required double width,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colour.border),
        boxShadow: const [
          BoxShadow(color: Color(0x0A1555F3), blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: Column(children: [
        InkWell(
          onTap: () => bloc.add(toggleEvent),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: visible ? colour.brandLight : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(children: [
              AnimatedRotation(
                turns: visible ? 0.25 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(Icons.arrow_right_rounded, color: colour.brand, size: 28),
              ),
              const SizedBox(width: 8),
              Text("FW $fwNum",
                  style: GoogleFonts.poppins(
                      color: colour.brandDark, fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(width: 12),
              Expanded(
                child: _styledDropdown<String>(
                  value: dropValue,
                  items: SalesOrderAddBloc.forwardingNo,
                  enabled: fp[dropKey] == true,
                  onChanged: (v) => bloc.add(UpdateDropdown(dropKey, v)),
                ),
              ),
            ]),
          ),
        ),

        if (visible)
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              _dateCheckRow(
                context: context,
                label: "Date",
                dateStr: dateStr,
                checkValue: checkValue,
                checkKey: checkKey,
                dateKey: dateKey,
                enabled: fp[checkKey] == true,
                bloc: bloc,
              ),
              _gap(),
              _editField(
                hint: 'SMK NO $fwNum',
                value: smkValue,
                enabled: fp[smkKey] == true,
                onChanged: (v) => bloc.add(UpdateTextField(smkKey, v)),
              ),
              _gap(),
              Row(children: [
                Expanded(
                  child: _editField(
                    hint: 'R.No $fwNum',
                    value: enRef,
                    enabled: fp[enKey] == true,
                    onChanged: (v) => bloc.add(UpdateTextField(enKey, v)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _editField(
                    hint: 'EX.Ref $fwNum',
                    value: exRef,
                    enabled: fp[exKey] == true,
                    onChanged: (v) => bloc.add(UpdateTextField(exKey, v)),
                  ),
                ),
              ]),
              _gap(),
              _searchField(
                hint: "Seal By",
                value: sealEmpValue,
                enabled: fp["txtSealByEmp$fwNum"] == true,
                onSearch: () async {
                  await OnlineApi.SelectEmployee(context, '', 'Operation');
                  // ✅ FIX: await + isNotEmpty check
                  await Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const Employee(Searchby: 1, SearchId: 0)));
                  if (objfun.SelectEmployeeList.AccountName.isNotEmpty) {
                    bloc.add(sealEvent(
                        objfun.SelectEmployeeList.AccountName,
                        objfun.SelectEmployeeList.Id));
                    objfun.SelectEmployeeList = EmployeeModel.Empty();
                  }
                },
                onClear: () => bloc.add(sealEvent('', 0)),
              ),
              _gap(),
              _searchField(
                hint: "B.Seal By",
                value: breakEmpValue,
                enabled: fp["txtBreakByEmp$fwNum"] == true,
                onSearch: () async {
                  await OnlineApi.SelectEmployee(context, '', 'Operation');
                  // ✅ FIX: await + isNotEmpty check
                  await Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const Employee(Searchby: 1, SearchId: 0)));
                  if (objfun.SelectEmployeeList.AccountName.isNotEmpty) {
                    bloc.add(breakEvent(
                        objfun.SelectEmployeeList.AccountName,
                        objfun.SelectEmployeeList.Id));
                    objfun.SelectEmployeeList = EmployeeModel.Empty();
                  }
                },
                onClear: () => bloc.add(breakEvent('', 0)),
              ),
              _gap(),
              Row(children: [
                Expanded(
                  child: _editField(
                    hint: 'S1',
                    value: s1Value,
                    enabled: fp[s1Key] == true,
                    onChanged: (v) => bloc.add(UpdateTextField(s1Key, v)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _editField(
                    hint: 'S2',
                    value: s2Value,
                    enabled: fp[s2Key] == true,
                    onChanged: (v) => bloc.add(UpdateTextField(s2Key, v)),
                  ),
                ),
              ]),
            ]),
          ),
      ]),
    );
  }

  // ════════════════════════════════════════════════════
  // ZB Card
  // ════════════════════════════════════════════════════
  Widget _zbCard(BuildContext context, SalesOrderAddBloc bloc,
      SalesOrderAddLoaded state, Map<String, bool> fp, int zbNum) {
    final dropKey = zbNum == 1 ? 'dropdownValueZB1' : 'dropdownValueZB2';
    final refKey  = zbNum == 1 ? 'txtZBRef1' : 'txtZBRef2';
    final dropVal = zbNum == 1 ? state.dropdownValueZB1 : state.dropdownValueZB2;
    final refVal  = zbNum == 1 ? state.txtZBRef1 : state.txtZBRef2;

    return _sectionCard(children: [
      Row(children: [
        Text("ZB $zbNum",
            style: GoogleFonts.poppins(
                color: colour.brandDark, fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(width: 12),
        Expanded(
          child: _styledDropdown<String>(
            value: dropVal,
            items: SalesOrderAddBloc.zbNo,
            enabled: fp[dropKey] == true,
            onChanged: (v) => bloc.add(UpdateDropdown(dropKey, v)),
          ),
        ),
      ]),
      _gap(),
      _editField(
        hint: 'ZB Ref $zbNum',
        value: refVal,
        enabled: fp[refKey] == true,
        onChanged: (v) => bloc.add(UpdateTextField(refKey, v)),
      ),
    ]);
  }

  // ── Address Card ──────────────────────────────────
  Widget _addressCard({
    required String title,
    required String addressValue,
    required String qtyValue,
    required bool addressEnabled,
    required bool qtyEnabled,
    required ValueChanged<String> onAddressChanged,
    required ValueChanged<String> onQtyChanged,
    required VoidCallback onSearch,
    required VoidCallback onClear,
    required VoidCallback onList,
    required VoidCallback onAdd,
  }) {
    return _sectionCard(children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel(title),
                  _gap(),
                  _addressMultiField(
                    hint: title,
                    value: addressValue,
                    enabled: addressEnabled,
                    onChanged: onAddressChanged,
                    onSearch: onSearch,
                    onClear: onClear,
                  ),
                ]),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Column(children: [
              _sectionLabel('Qty'),
              _gap(),
              _editField(
                hint: 'Qty',
                value: qtyValue,
                enabled: qtyEnabled,
                onChanged: onQtyChanged,
              ),
            ]),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _iconBtn(icon: Icons.list_rounded, enabled: true, onTap: onList),
              const SizedBox(height: 4),
              _iconBtn(icon: Icons.add_box_rounded, enabled: true, onTap: onAdd),
            ],
          ),
        ],
      ),
    ]);
  }

  // ── Dialogs ───────────────────────────────────────
  void _showProductDialog(BuildContext context,
      SalesOrderAddLoaded state, int editIndex) {
    final bloc = context.read<SalesOrderAddBloc>();
    if (editIndex >= 0) {
      bloc.add(PrepareProductEdit(editIndex));
    } else {
      bloc.add(ClearProduct());
    }
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: _ProductDialog(activeField: _activeNumpadField),
      ),
    );
  }

  void _showPickUpList(BuildContext context, SalesOrderAddLoaded state) {
    final bloc = context.read<SalesOrderAddBloc>();
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: _AddressListDialog(
          title: "PickUp Address & Qty List",
          addresses: state.pickUpAddressList,
          quantities: state.pickUpQuantityList,
          onSelect: (i) => bloc.add(SelectPickUpFromList(i)),
          onDelete: (i) => bloc.add(RemovePickUpAddress(i)),
          onClear: () => bloc.add(ClearProduct()),
        ),
      ),
    );
  }

  void _showDeliveryList(BuildContext context, SalesOrderAddLoaded state) {
    final bloc = context.read<SalesOrderAddBloc>();
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: _AddressListDialog(
          title: "Delivery Address & Qty List",
          addresses: state.deliveryAddressList,
          quantities: state.deliveryQuantityList,
          onSelect: (i) => bloc.add(SelectDeliveryFromList(i)),
          onDelete: (i) => bloc.add(RemoveDeliveryAddress(i)),
          onClear: () {},
        ),
      ),
    );
  }

  // ── Product table ─────────────────────────────────
  Widget _productHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [colour.brand, colour.brandMid]),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        _ph('S',           flex: 1),
        _ph('Code',        flex: 2),
        _ph('Description', flex: 4),
        _ph('Qty',         flex: 1),
        _ph('Rate',        flex: 2),
        _ph('GST',         flex: 2),
        _ph('Amount',      flex: 2, align: TextAlign.right),
        _ph('',            flex: 2),
      ]),
    );
  }

  Widget _ph(String t, {int flex = 1, TextAlign align = TextAlign.left}) =>
      Expanded(
        flex: flex,
        child: Text(t,
            textAlign: align,
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5)),
      );

  Widget _emptyProducts() => Container(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Center(
      child: Text('No products added',
          style: GoogleFonts.poppins(color: colour.textSub, fontSize: 13)),
    ),
  );

  Widget _productRow(BuildContext context, SalesOrderAddLoaded state,
      int index, dynamic p, SalesOrderAddBloc bloc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colour.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(children: [
        Expanded(flex: 1,
            child: Text('${index + 1}',
                style: GoogleFonts.poppins(color: colour.brand, fontSize: 11, fontWeight: FontWeight.w800))),
        Expanded(flex: 2,
            child: Text(p.ProductCode.toString(),
                style: GoogleFonts.poppins(color: colour.brand, fontSize: 11, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis)),
        Expanded(flex: 4,
            child: Text(p.ProductName.toString(),
                style: GoogleFonts.poppins(color: colour.textMain, fontSize: 11, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis)),
        Expanded(flex: 1,
            child: Text('${p.ItemQty}',
                style: GoogleFonts.poppins(color: colour.textSub, fontSize: 11, fontWeight: FontWeight.w600))),
        Expanded(flex: 2,
            child: Text('${p.SalesRate}',
                style: GoogleFonts.poppins(color: colour.textSub, fontSize: 11),
                overflow: TextOverflow.ellipsis)),
        Expanded(flex: 2,
            child: Text('${p.TaxPercent}%',
                style: GoogleFonts.poppins(color: colour.textSub, fontSize: 11))),
        Expanded(
          flex: 2,
          child: Text('${p.Amount}',
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(color: colour.brand, fontSize: 11, fontWeight: FontWeight.w800)),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _showProductDialog(context, state, index),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: const Icon(Icons.edit_rounded, color: colour.brand, size: 18),
              ),
            ),
            GestureDetector(
              onTap: () => bloc.add(RemoveProduct(index)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(Icons.delete_rounded, color: colour.red, size: 18),
              ),
            ),
          ],
        ),
      ]),
    );
  }

  // ════════════════════════════════════════════════════
  // Shared layout helpers
  // ════════════════════════════════════════════════════

  Widget _tabScroll({required List<Widget> children}) =>
      ListView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
        children: children,
      );

  Widget _sectionCard({required List<Widget> children}) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colour.border),
          boxShadow: const [
            BoxShadow(color: Color(0x0A1555F3), blurRadius: 8, offset: Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      );

  Widget _sectionLabel(String t) => Text(t,
      style: GoogleFonts.poppins(
          color: colour.textSub, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.6));

  Widget _labelText(String t) => Text(t,
      style: GoogleFonts.poppins(color: colour.textMain, fontSize: 13, fontWeight: FontWeight.w600));

  Widget _gap() => const SizedBox(height: 10);
  Widget _divider() => Divider(color: colour.border, thickness: 1);

  Widget _readonlyBox(String val) => Container(
    key: ValueKey('readonly_$val'),
    height: 44,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: colour.brandLight,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: colour.border),
    ),
    alignment: Alignment.centerLeft,
    child: Text(val,
        style: GoogleFonts.poppins(
            color: colour.brandDark, fontSize: 13, fontWeight: FontWeight.w700)),
  );

  Widget _dateTapBox({required String date, required VoidCallback? onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: colour.brandLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colour.border),
          ),
          child: Row(children: [
            const Icon(Icons.calendar_today_rounded, color: colour.brand, size: 15),
            const SizedBox(width: 8),
            Flexible(
              child: Text(date,
                  style: GoogleFonts.poppins(
                      color: colour.brandDark, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
      );

  Widget _searchField({
    required String hint,
    required String value,
    required bool enabled,
    required VoidCallback onSearch,
    required VoidCallback onClear,
  }) {
    final action = enabled ? (value.isEmpty ? onSearch : onClear) : null;
    return GestureDetector(
      key: ValueKey('search_${hint}_$value'),
      onTap: action,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: enabled ? Colors.white : colour.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: enabled ? colour.border : colour.border.withOpacity(0.3)),
        ),
        child: Row(children: [
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value.isEmpty ? hint : value,
              style: GoogleFonts.poppins(
                  color: value.isEmpty ? colour.textSub.withOpacity(0.45) : colour.textMain,
                  fontSize: 13,
                  fontWeight: value.isEmpty ? FontWeight.w400 : FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(
              value.isEmpty ? Icons.search_rounded : Icons.close_rounded,
              color: enabled ? colour.brand : colour.textSub.withOpacity(0.25),
              size: 20,
            ),
          ),
        ]),
      ),
    );
  }

  Widget _editField({
    required String hint,
    required String value,
    required bool enabled,
    required ValueChanged<String> onChanged,
    int minLines = 1,
    int? maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) =>
      TextField(
        key: ValueKey('edit_${hint}_$value'),
        controller: TextEditingController(text: value),
        enabled: enabled,
        onChanged: onChanged,
        minLines: minLines,
        maxLines: maxLines,
        keyboardType: keyboardType,
        textCapitalization: TextCapitalization.characters,
        style: GoogleFonts.poppins(
            color: colour.textMain, fontSize: 13, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
              color: colour.textSub.withOpacity(0.45), fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          filled: true,
          fillColor: enabled ? Colors.white : colour.surface,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: colour.border),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: colour.border.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: colour.brand, width: 1.5),
          ),
        ),
      );

  Widget _addressMultiField({
    required String hint,
    required String value,
    required bool enabled,
    required ValueChanged<String> onChanged,
    VoidCallback? onSearch,
    VoidCallback? onClear,
  }) =>
      Container(
        constraints: const BoxConstraints(minHeight: 80),
        decoration: BoxDecoration(
          color: enabled ? Colors.white : colour.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colour.border),
        ),
        child: TextField(
          controller: TextEditingController(text: value),
          enabled: enabled,
          onChanged: onChanged,
          maxLines: null,
          minLines: 3,
          textCapitalization: TextCapitalization.characters,
          style: GoogleFonts.poppins(
              color: colour.textMain, fontSize: 13, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
                color: colour.textSub.withOpacity(0.45), fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: InputBorder.none,
            suffixIcon: onSearch != null
                ? GestureDetector(
              onTap: value.isEmpty ? onSearch : onClear,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  value.isEmpty ? Icons.search_rounded : Icons.close_rounded,
                  color: colour.brand,
                  size: 20,
                ),
              ),
            )
                : null,
          ),
        ),
      );

  Widget _styledDropdown<T>({
    required T? value,
    required List<T> items,
    required bool enabled,
    required ValueChanged<T?> onChanged,
  }) =>
      Container(
        key: ValueKey('dropdown_${T}_$value'),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: enabled ? Colors.white : colour.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: enabled ? colour.border : colour.border.withOpacity(0.3)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            isExpanded: true,
            value: value,
            onChanged: enabled ? onChanged : null,
            style: GoogleFonts.poppins(
                color: colour.textMain, fontSize: 13, fontWeight: FontWeight.w600),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: colour.brand, size: 20),
            items: items
                .map((v) => DropdownMenuItem<T>(
                value: v,
                child: Text(v.toString(),
                    style: GoogleFonts.poppins(
                        color: colour.textMain, fontSize: 13, fontWeight: FontWeight.w600))))
                .toList(),
          ),
        ),
      );

  Widget _dateCheckRow({
    required BuildContext context,
    required String label,
    required String dateStr,
    required bool checkValue,
    required String checkKey,
    required String dateKey,
    required bool enabled,
    required SalesOrderAddBloc bloc,
    bool showTime = false,
  }) {
    final fmt = showTime ? "dd-MM-yyyy HH:mm" : "dd-MM-yyyy";

    return Row(children: [
      SizedBox(
        width: 90,
        child: Text(label,
            style: GoogleFonts.poppins(
                color: colour.textMain, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
      Expanded(
        child: GestureDetector(
          onTap: () async {
            if (!checkValue || !enabled) return;
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: colour.brand,
                    onPrimary: Colors.white,
                    onSurface: colour.textMain,
                  ),
                ),
                child: child!,
              ),
            );
            if (date != null) {
              if (showTime) {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                  builder: (ctx, child) => MediaQuery(
                    data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
                    child: child!,
                  ),
                );
                final combined = DateTime(date.year, date.month, date.day,
                    time?.hour ?? 0, time?.minute ?? 0);
                bloc.add(UpdateDate(dateKey,
                    DateFormat("yyyy-MM-dd HH:mm:ss").format(combined)));
              } else {
                bloc.add(UpdateDate(dateKey, DateFormat("yyyy-MM-dd").format(date)));
              }
            }
          },
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: checkValue ? colour.brandLight : colour.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: checkValue ? colour.border : colour.border.withOpacity(0.3)),
            ),
            child: Row(children: [
              const Icon(Icons.calendar_today_rounded, size: 14, color: colour.brand),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  DateFormat(fmt).format(DateTime.parse(dateStr)),
                  style: GoogleFonts.poppins(
                      color: checkValue ? colour.brandDark : colour.textSub,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ]),
          ),
        ),
      ),
      const SizedBox(width: 8),
      Transform.scale(
        scale: 1.1,
        child: Checkbox(
          value: checkValue,
          activeColor: colour.brand,
          side: BorderSide(color: colour.border, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: enabled
              ? (v) => bloc.add(UpdateCheckbox(checkKey, v!))
              : null,
        ),
      ),
    ]);
  }

  Widget _iconBtn({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: enabled ? colour.brandLight : colour.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: enabled ? colour.border : colour.border.withOpacity(0.3)),
          ),
          child: Icon(icon,
              color: enabled ? colour.brand : colour.textSub.withOpacity(0.3), size: 22),
        ),
      );
}

// ════════════════════════════════════════════════════
// Product Dialog
// ════════════════════════════════════════════════════
class _ProductDialog extends StatefulWidget {
  final String activeField;
  const _ProductDialog({required this.activeField});

  @override
  State<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<_ProductDialog> {
  late String _activeField;

  @override
  void initState() {
    super.initState();
    _activeField = widget.activeField;
  }

  @override
  Widget build(BuildContext context) {
    final double width  = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return BlocBuilder<SalesOrderAddBloc, SalesOrderAddState>(
      builder: (context, state) {
        if (state is! SalesOrderAddLoaded) return const SizedBox();
        final bloc = context.read<SalesOrderAddBloc>();

        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: width * 0.95,
            height: height * 0.92,
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Row(children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colour.brandLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add_shopping_cart_rounded, color: colour.brand, size: 20),
                ),
                const SizedBox(width: 10),
                Text("Add Product",
                    style: GoogleFonts.poppins(
                        color: colour.textMain, fontSize: 15, fontWeight: FontWeight.w700)),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    bloc.add(ClearProduct());
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colour.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colour.border),
                    ),
                    child: const Icon(Icons.close_rounded, color: colour.textSub, size: 18),
                  ),
                ),
              ]),

              const SizedBox(height: 12),
              Divider(color: colour.border),
              const SizedBox(height: 8),

              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _roField("Product Code", state.txtProductCode),
                      const SizedBox(height: 8),
                      _searchableField(
                        hint: "Product Description",
                        value: state.txtProductDescription,
                        onSearch: () async {
                          final r = await Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (_) => const Product(Searchby: 1, SearchId: 0)));
                          if (r != null) {
                            bloc.add(ProductSelected(
                                objfun.SelectProductList.ProductName,
                                objfun.SelectProductList.Productcode,
                                objfun.SelectProductList.Id));
                            objfun.SelectProductList = ProductModel.Empty();
                            Navigator.of(context, rootNavigator: true).pop();
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (ctx) => BlocProvider.value(
                                value: bloc,
                                child: _ProductDialog(activeField: _activeField),
                              ),
                            );
                          }
                        },
                        onClear: () => bloc.add(ClearProduct()),
                      ),
                      const SizedBox(height: 8),
                      _numField("Qty", state.txtProductQty, 'qty'),
                      const SizedBox(height: 6),
                      _numField("Sale Rate", state.txtProductSaleRate, 'saleRate'),
                      const SizedBox(height: 6),
                      _numField("GST", state.txtProductGst, 'gst'),
                      const SizedBox(height: 6),
                      Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: colour.brandLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: colour.brand.withOpacity(0.3)),
                        ),
                        child: Row(children: [
                          Text('Amount : ',
                              style: GoogleFonts.poppins(
                                  color: colour.textSub, fontSize: 12, fontWeight: FontWeight.w600)),
                          Text(state.txtProductAmount,
                              style: GoogleFonts.poppins(
                                  color: colour.brand, fontSize: 15, fontWeight: FontWeight.w800)),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                flex: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: colour.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colour.border),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(children: [
                    _numRow(['1', '2', '3'], bloc),
                    _numRow(['4', '5', '6'], bloc),
                    _numRow(['7', '8', '9'], bloc),
                    _numRow(['CLR', '0', 'C'], bloc),
                    Row(children: [
                      _numBtn('Add', () {
                        bloc.add(AddProduct());
                        Navigator.of(context, rootNavigator: true).pop();
                      }, isAction: true),
                      _numBtn('Reset', () => bloc.add(ClearProduct()), isAction: true),
                    ]),
                  ]),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget _roField(String hint, String value) =>
      Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: colour.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colour.border),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          value.isEmpty ? hint : value,
          style: GoogleFonts.poppins(
              color: value.isEmpty ? colour.textSub : colour.textMain,
              fontSize: 13,
              fontWeight: value.isEmpty ? FontWeight.w400 : FontWeight.w600),
        ),
      );

  Widget _searchableField({
    required String hint,
    required String value,
    required VoidCallback onSearch,
    required VoidCallback onClear,
  }) =>
      Container(
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colour.border),
        ),
        child: Row(children: [
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value.isEmpty ? hint : value,
              style: GoogleFonts.poppins(
                  color: value.isEmpty ? colour.textSub.withOpacity(0.45) : colour.textMain,
                  fontSize: 13,
                  fontWeight: value.isEmpty ? FontWeight.w400 : FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: value.isEmpty ? onSearch : onClear,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(
                value.isEmpty ? Icons.search_rounded : Icons.close_rounded,
                color: colour.brand,
                size: 20,
              ),
            ),
          ),
        ]),
      );

  Widget _numField(String hint, String value, String fieldKey) {
    final active = _activeField == fieldKey;
    return GestureDetector(
      onTap: () => setState(() => _activeField = fieldKey),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: active ? colour.brandLight : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? colour.brand : colour.border, width: active ? 1.5 : 1),
        ),
        child: Row(children: [
          Expanded(
            child: Text(
              value.isEmpty ? hint : value,
              style: GoogleFonts.poppins(
                  color: value.isEmpty ? colour.textSub.withOpacity(0.45) : colour.textMain,
                  fontSize: 13,
                  fontWeight: value.isEmpty ? FontWeight.w400 : FontWeight.w700),
            ),
          ),
          if (active) Container(width: 2, height: 18, color: colour.brand),
        ]),
      ),
    );
  }

  Widget _numRow(List<String> keys, SalesOrderAddBloc bloc) =>
      Expanded(
        child: Row(
          children: keys
              .map((k) => _numBtn(k, () => bloc.add(KeyPress(k, _activeField))))
              .toList(),
        ),
      );

  Widget _numBtn(String label, VoidCallback onPressed, {bool isAction = false}) =>
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: GestureDetector(
            onTap: onPressed,
            child: Container(
              decoration: BoxDecoration(
                color: isAction ? colour.brand : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isAction ? colour.brand : colour.border),
                boxShadow: [
                  BoxShadow(
                    color: isAction ? colour.brand.withOpacity(0.2) : Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              alignment: Alignment.center,
              child: Text(label,
                  style: GoogleFonts.poppins(
                      color: isAction ? Colors.white : colour.textMain,
                      fontSize: isAction ? 13 : 16,
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      );
}

// ════════════════════════════════════════════════════
// Address List Dialog
// ════════════════════════════════════════════════════
class _AddressListDialog extends StatelessWidget {
  final String title;
  final List<dynamic> addresses;
  final List<dynamic> quantities;
  final ValueChanged<int> onSelect;
  final ValueChanged<int> onDelete;
  final VoidCallback onClear;

  const _AddressListDialog({
    required this.title,
    required this.addresses,
    required this.quantities,
    required this.onSelect,
    required this.onDelete,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final double width  = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: width * 0.9,
        height: height * 0.65,
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colour.brandLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.list_rounded, color: colour.brand, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(title,
                  style: GoogleFonts.poppins(
                      color: colour.textMain, fontSize: 14, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis),
            ),
            GestureDetector(
              onTap: () {
                onClear();
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colour.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colour.border),
                ),
                child: const Icon(Icons.close_rounded, color: colour.textSub, size: 18),
              ),
            ),
          ]),

          const SizedBox(height: 10),
          Divider(color: colour.border),
          const SizedBox(height: 6),

          Expanded(
            child: addresses.isEmpty
                ? Center(
                child: Text('No records',
                    style: GoogleFonts.poppins(color: colour.textSub, fontSize: 13)))
                : ListView.builder(
              itemCount: addresses.length,
              itemBuilder: (ctx, index) => InkWell(
                onLongPress: () async {
                  final del = await objfun.ConfirmationMsgYesNo(
                      context, "Are you sure to delete?");
                  if (del == true) onDelete(index);
                },
                onTap: () {
                  onSelect(index);
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colour.border),
                    boxShadow: const [
                      BoxShadow(color: Color(0x0A1555F3), blurRadius: 6, offset: Offset(0, 2))
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(children: [
                    Expanded(
                      flex: 3,
                      child: Text(addresses[index].toString(),
                          style: GoogleFonts.poppins(
                              color: colour.textMain, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colour.brandLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          index < quantities.length ? quantities[index].toString() : '',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              color: colour.brand, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}