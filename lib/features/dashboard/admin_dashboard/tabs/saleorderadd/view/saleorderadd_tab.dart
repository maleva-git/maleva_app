import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import 'package:maleva/features/mastersearch/JobAllStatus.dart';
import 'package:maleva/menu/menulist.dart';
import '../../../../../../core/di/injection.dart';
import '../../../../../mastersearch/AddressList.dart';
import '../../../../../mastersearch/Agent.dart';
import '../../../../../mastersearch/AgentCompany.dart';
import '../../../../../mastersearch/Customer.dart';
import '../../../../../mastersearch/Employee.dart';
import '../../../../../mastersearch/JobType.dart';
import '../../../../../mastersearch/Location.dart';
import '../../saleorderview/view/saleorderview_tab.dart';
import '../bloc/saleorderadd_bloc.dart';
import '../bloc/saleorderadd_event.dart';
import '../bloc/saleorderadd_state.dart';



class SalesOrderAdd extends StatelessWidget {
  final List<SaleEditDetailModel>? saleDetails;
  final List<dynamic>? saleMaster;

  const SalesOrderAdd({super.key, this.saleDetails, this.saleMaster});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SalesOrderBloc>()
        ..add(SalesOrderInitialized(
          saleDetails: saleDetails,
          saleMaster: saleMaster,
        )),
      child: const _SalesOrderView(),
    );
  }
}


class _SalesOrderView extends StatefulWidget {
  const _SalesOrderView();

  @override
  State<_SalesOrderView> createState() => _SalesOrderViewState();
}

class _SalesOrderViewState extends State<_SalesOrderView>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // ─── Text controllers ──────────────────────────────────────────────────────
  final txtRemarks = TextEditingController();
  final txtDoDescription = TextEditingController();
  final txtJobNo = TextEditingController();
  final txtOffVessel = TextEditingController();
  final txtLoadingVessel = TextEditingController();
  final txtLPort = TextEditingController();
  final txtOPort = TextEditingController();
  final txtLVesselType = TextEditingController();
  final txtOVesselType = TextEditingController();
  final txtCommodityType = TextEditingController();
  final txtCargo = TextEditingController();
  final txtAWBNo = TextEditingController();
  final txtBLCopy = TextEditingController();
  final txtOSCN = TextEditingController();
  final txtLSCN = TextEditingController();
  final txtWeight = TextEditingController();
  final txtQuantity = TextEditingController();
  final txtTruckSize = TextEditingController();
  final txtPTWNo = TextEditingController();
  final txtSmk1 = TextEditingController();
  final txtSmk2 = TextEditingController();
  final txtSmk3 = TextEditingController();
  final txtENRef1 = TextEditingController();
  final txtENRef2 = TextEditingController();
  final txtENRef3 = TextEditingController();
  final txtExRef1 = TextEditingController();
  final txtExRef2 = TextEditingController();
  final txtExRef3 = TextEditingController();
  final txtZBRef1 = TextEditingController();
  final txtZBRef2 = TextEditingController();
  final txtAmount1 = TextEditingController();
  final txtAmount2 = TextEditingController();
  final txtPortChargeRef1 = TextEditingController();
  final txtPortCharges = TextEditingController();
  final txtForwarding1S1 = TextEditingController();
  final txtForwarding1S2 = TextEditingController();
  final txtForwarding2S1 = TextEditingController();
  final txtForwarding2S2 = TextEditingController();
  final txtForwarding3S1 = TextEditingController();
  final txtForwarding3S2 = TextEditingController();
  final txtWarehouseAddress = TextEditingController();
  final txtPickUpAddress = TextEditingController();
  final txtPickUpQuantity = TextEditingController();
  final txtDeliveryAddress = TextEditingController();
  final txtDeliveryQuantity = TextEditingController();
  final txtOrigin = TextEditingController();
  final txtDestination = TextEditingController();
  final txtPickUpWeight = TextEditingController();
  final txtDeliveryWeight = TextEditingController();
  // Product fields
  final txtProductCode = TextEditingController();
  final txtProductDescription = TextEditingController();
  final txtProductQty = TextEditingController();
  final txtProductSaleRate = TextEditingController();
  final txtProductGst = TextEditingController();
  final txtProductAmount = TextEditingController();
  final txtProductGSTAmount = TextEditingController();
  final txtProductActualAmount = TextEditingController();
  final txtProductCurrencyValue = TextEditingController();
  final txtProductUOM = TextEditingController();
  final txtProductId = TextEditingController();
  final txtProductSDId = TextEditingController();
  final txtItemMasterRefId = TextEditingController();
  final txtSaleOrderMasterRefId = TextEditingController();
  final txtProductMRP = TextEditingController();
  final txtProductPurchaseRate = TextEditingController();
  final txtProductNetSalesRate = TextEditingController();
  final txtProductDiscPer = TextEditingController();
  final txtProductDiscAmount = TextEditingController();
  final txtProductLandingCost = TextEditingController();

  List<TextEditingController> get _allControllers => [
    txtRemarks, txtDoDescription, txtJobNo, txtOffVessel, txtLoadingVessel,
    txtLPort, txtOPort, txtLVesselType, txtOVesselType, txtCommodityType,
    txtCargo, txtAWBNo, txtBLCopy, txtOSCN, txtLSCN, txtWeight, txtQuantity,
    txtTruckSize, txtPTWNo, txtSmk1, txtSmk2, txtSmk3,
    txtENRef1, txtENRef2, txtENRef3, txtExRef1, txtExRef2, txtExRef3,
    txtZBRef1, txtZBRef2, txtAmount1, txtAmount2, txtPortChargeRef1,
    txtPortCharges, txtForwarding1S1, txtForwarding1S2, txtForwarding2S1,
    txtForwarding2S2, txtForwarding3S1, txtForwarding3S2, txtWarehouseAddress,
    txtPickUpAddress, txtPickUpQuantity, txtDeliveryAddress, txtDeliveryQuantity,
    txtOrigin, txtDestination,
    txtProductCode, txtProductDescription, txtProductQty, txtProductSaleRate,
    txtProductGst, txtProductAmount, txtProductGSTAmount, txtProductActualAmount,
    txtProductCurrencyValue, txtProductUOM, txtProductId, txtProductSDId,
    txtItemMasterRefId, txtSaleOrderMasterRefId, txtProductMRP,
    txtProductPurchaseRate, txtProductNetSalesRate, txtProductDiscPer,
    txtProductDiscAmount, txtProductLandingCost,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in _allControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ─── Sync state → controllers ─────────────────────────────────────────────

  void _syncControllersFromState(SalesOrderState state) {
    txtJobNo.text = state.jobNo;
    txtRemarks.text = state.remarks;
    txtDoDescription.text = state.doDescription;
    txtOffVessel.text = state.offVessel;
    txtLoadingVessel.text = state.loadingVessel;
    txtLPort.text = state.lPort;
    txtOPort.text = state.oPort;
    txtLVesselType.text = state.lVesselType;
    txtOVesselType.text = state.oVesselType;
    txtCommodityType.text = state.commodityType;
    txtCargo.text = state.cargo;
    txtAWBNo.text = state.awbNo;
    txtBLCopy.text = state.blCopy;
    txtOSCN.text = state.oScn;
    txtLSCN.text = state.lScn;
    txtWeight.text = state.weight;
    txtQuantity.text = state.quantity;
    txtTruckSize.text = state.truckSize;
    txtPTWNo.text = state.ptwNo;
    txtSmk1.text = state.smk1;
    txtSmk2.text = state.smk2;
    txtSmk3.text = state.smk3;
    txtENRef1.text = state.enRef1;
    txtENRef2.text = state.enRef2;
    txtENRef3.text = state.enRef3;
    txtExRef1.text = state.exRef1;
    txtExRef2.text = state.exRef2;
    txtExRef3.text = state.exRef3;
    txtZBRef1.text = state.zbRef1;
    txtZBRef2.text = state.zbRef2;
    txtAmount1.text = state.amount1;
    txtAmount2.text = state.amount2;
    txtPortChargeRef1.text = state.portChargeRef1;
    txtPortCharges.text = state.portCharges;
    txtForwarding1S1.text = state.forwarding1S1;
    txtForwarding1S2.text = state.forwarding1S2;
    txtForwarding2S1.text = state.forwarding2S1;
    txtForwarding2S2.text = state.forwarding2S2;
    txtForwarding3S1.text = state.forwarding3S1;
    txtForwarding3S2.text = state.forwarding3S2;
    txtWarehouseAddress.text = state.warehouseAddress;
    txtPickUpAddress.text = state.pickupAddress;
    txtPickUpQuantity.text = state.pickupQuantity;
    txtDeliveryAddress.text = state.deliveryAddress;
    txtDeliveryQuantity.text = state.deliveryQuantity;
    txtOrigin.text = state.originName;
    txtDestination.text = state.destinationName;
    txtProductCurrencyValue.text = state.currencyValue.toString();
    txtProductGSTAmount.text = state.productCalc.gstAmount.toStringAsFixed(2);
    txtProductAmount.text = state.productCalc.amount.toStringAsFixed(2);
    txtProductActualAmount.text = state.productCalc.actualAmount.toStringAsFixed(2);
  }

  Map<String, String> _collectFields() => {
    'remarks': txtRemarks.text,
    'doDescription': txtDoDescription.text,
    'offVessel': txtOffVessel.text,
    'loadingVessel': txtLoadingVessel.text,
    'lPort': txtLPort.text,
    'oPort': txtOPort.text,
    'lVesselType': txtLVesselType.text,
    'oVesselType': txtOVesselType.text,
    'commodityType': txtCommodityType.text,
    'cargo': txtCargo.text,
    'awbNo': txtAWBNo.text,
    'blCopy': txtBLCopy.text,
    'oScn': txtOSCN.text,
    'lScn': txtLSCN.text,
    'weight': txtWeight.text,
    'quantity': txtQuantity.text,
    'truckSize': txtTruckSize.text,
    'ptwNo': txtPTWNo.text,
    'smk1': txtSmk1.text,
    'smk2': txtSmk2.text,
    'smk3': txtSmk3.text,
    'enRef1': txtENRef1.text,
    'enRef2': txtENRef2.text,
    'enRef3': txtENRef3.text,
    'exRef1': txtExRef1.text,
    'exRef2': txtExRef2.text,
    'exRef3': txtExRef3.text,
    'zbRef1': txtZBRef1.text,
    'zbRef2': txtZBRef2.text,
    'amount1': txtAmount1.text,
    'amount2': txtAmount2.text,
    'portChargeRef1': txtPortChargeRef1.text,
    'portCharges': txtPortCharges.text,
    'forwarding1S1': txtForwarding1S1.text,
    'forwarding1S2': txtForwarding1S2.text,
    'forwarding2S1': txtForwarding2S1.text,
    'forwarding2S2': txtForwarding2S2.text,
    'forwarding3S1': txtForwarding3S1.text,
    'forwarding3S2': txtForwarding3S2.text,
    'warehouseAddress': txtWarehouseAddress.text,
    'pickupAddress': txtPickUpAddress.text,
    'pickupWeight': txtPickUpWeight.text,
    'pickupQuantity': txtPickUpQuantity.text,
    'deliveryAddress': txtDeliveryAddress.text,
    'deliveryQuantity': txtDeliveryQuantity.text,
    'deliveryWeight': txtDeliveryWeight.text,
    'originName': txtOrigin.text,
    'destinationName': txtDestination.text,
  };

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isTablet = objfun.MalevaScreen != 1;

    return BlocConsumer<SalesOrderBloc, SalesOrderState>(
      listenWhen: (prev, curr) =>
      curr.status != prev.status ||
          curr.successMessage != prev.successMessage ||
          curr.errorMessage != prev.errorMessage ||
          curr.jobNo != prev.jobNo,
      listener: (context, state) async {
        if (state.status == SalesOrderStatus.success) {
          _syncControllersFromState(state);
        }
        if (state.successMessage != null) {
          await objfun.ConfirmationOK(state.successMessage!, context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SalesOrderAdd()),
          );
        }
        if (state.errorMessage != null) {
          objfun.msgshow(
            state.errorMessage!, '', Colors.white, Colors.red, null,
            18.0 - objfun.reducesize, objfun.tll, objfun.tgc, context, 2,
          );
        }
      },
      builder: (context, state) {
        final bloc = context.read<SalesOrderBloc>();

        return WillPopScope(
          onWillPop: () async {
            Navigator.of(context).pop();
            return true;
          },
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Colors.white,
            drawer: const Menulist(),
            appBar: _buildAppBar(context, state, bloc, isTablet),
            body: state.status == SalesOrderStatus.loading
                ? const Center(
                child: SpinKitFoldingCube(
                    color: colour.spinKitColor, size: 35))
                : _buildTabBody(context, state, bloc, isTablet),
            bottomNavigationBar:
            _buildBottomNav(context, state, bloc, isTablet),
          ),
        );
      },
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────

  AppBar _buildAppBar(
      BuildContext context,
      SalesOrderState state,
      SalesOrderBloc bloc,
      bool isTablet,
      ) {
    final h = MediaQuery.of(context).size.height;
    final userName = objfun.storagenew.getString('Username') ?? '';
    final titleSize =
    isTablet ? objfun.FontLarge + 2.0 : objfun.FontMedium.toDouble();
    final subSize =
    isTablet ? objfun.FontLow.toDouble() : (objfun.FontLow - 2).toDouble();

    return AppBar(
      automaticallyImplyLeading: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: SizedBox(
        height: h * 0.05,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text('Sales Order',
                  style: GoogleFonts.lato(
                      color: colour.topAppBarColor,
                      fontWeight: FontWeight.bold,
                      fontSize: titleSize)),
            ),
            Expanded(
              child: Text(userName,
                  style: GoogleFonts.lato(
                      color: colour.commonColorLight,
                      fontWeight: FontWeight.bold,
                      fontSize: subSize)),
            ),
          ],
        ),
      ),
      iconTheme: const IconThemeData(color: colour.topAppBarColor),
      actions: [
        if (state.isAllowed('VIEW'))
          Padding(
            padding: const EdgeInsets.only(top: 7, bottom: 7, left: 7),
            child: _appBarBtn(
              label: 'View',
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const Saleorderview())),
              isTablet: isTablet,
            ),
          ),
        if (state.isAllowed('SAVE'))
          Padding(
            padding: const EdgeInsets.only(top: 7, bottom: 7, left: 7),
            child: _appBarBtn(
              label: 'Save',
              onPressed: () async {
                final confirm = await objfun.ConfirmationMsgYesNo(
                    context, 'Do You Want to Save ?');
                if (confirm) {
                  bloc.add(SalesOrderSaveRequested(fields: _collectFields()));
                }
              },
              isTablet: isTablet,
            ),
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _appBarBtn({
    required String label,
    required VoidCallback onPressed,
    required bool isTablet,
  }) {
    return SizedBox(
      width: isTablet ? 90 : 70,
      height: 25,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: colour.commonColorLight,
          side: const BorderSide(color: colour.commonColor, width: 1),
          elevation: 20,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.all(4),
        ),
        onPressed: onPressed,
        child: Text(label,
            style: GoogleFonts.lato(
                fontSize: objfun.FontMedium.toDouble(),
                fontWeight: FontWeight.bold,
                color: colour.commonColor)),
      ),
    );
  }

  // ─── Bottom Navigation ────────────────────────────────────────────────────

  Widget _buildBottomNav(
      BuildContext context,
      SalesOrderState state,
      SalesOrderBloc bloc,
      bool isTablet,
      ) {
    final labels = [
      'Job Info', 'L. Vessel', 'O. Vessel',
      'Forwarding', 'Boarding', 'Products',
    ];
    final icons = [
      Icons.info_outline, Icons.directions_boat_outlined,
      Icons.anchor_outlined, Icons.local_shipping_outlined,
      Icons.person_outline, Icons.inventory_2_outlined,
    ];

    return BottomNavigationBar(
      backgroundColor: colour.commonColorLight,
      currentIndex: state.currentTabIndex,
      unselectedItemColor: colour.commonHeadingColor.withOpacity(0.5),
      selectedFontSize:
      isTablet ? objfun.FontLow.toDouble() : objfun.FontCardText.toDouble(),
      unselectedFontSize: isTablet ? objfun.FontCardText.toDouble() : 10,
      type: BottomNavigationBarType.fixed,
      onTap: (i) {
        _tabController.animateTo(i);
        bloc.add(SalesOrderTabChanged(index: i));
      },
      items: List.generate(
        labels.length,
            (i) => BottomNavigationBarItem(
          icon: Icon(icons[i]),
          label: labels[i],
        ),
      ),
    );
  }

  // ─── Tab body ─────────────────────────────────────────────────────────────

  Widget _buildTabBody(
      BuildContext context,
      SalesOrderState state,
      SalesOrderBloc bloc,
      bool isTablet,
      ) {
    return TabBarView(
      controller: _tabController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
          _buildTab0_JobInfo(context, state, bloc, isTablet),
        _buildTab1_LoadingVessel(context, state, bloc, isTablet),
        _buildTab2_OffVessel(context, state, bloc, isTablet),
        _buildTab3_Forwarding(context, state, bloc, isTablet),
        _buildTab4_Boarding(context, state, bloc, isTablet),
        _buildTab5_Products(context, state, bloc, isTablet),
      ],
    );
  }

  // ─── TAB 0: Job Info ──────────────────────────────────────────────────────

  Widget _buildTab0_JobInfo(
      BuildContext context,
      SalesOrderState state,
      SalesOrderBloc bloc,
      bool isTablet,
      ) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? 20 : 15),
      child: ListView(
        children: [
          _styledField(
              controller: txtJobNo,
              hint: 'Job No',
              readOnly: true,
              isTablet: isTablet),
          const SizedBox(height: 8),
          _styledDropdown<String>(
            value: state.billType,
            items: ['MY', 'TR'],
            label: 'Bill Type',
            enabled:
            !state.disabledBillType && state.isAllowed('cmbBillType'),
            onChanged: (v) {
              if (v != null) bloc.add(SalesOrderBillTypeChanged(value: v));
            },
            isTablet: isTablet,
          ),
          const SizedBox(height: 8),

          // Customer
          _searchField(
            controller: TextEditingController(text: state.custName),
            hint: 'Customer Name',
            hasValue: state.custName.isNotEmpty,
            enabled: state.isAllowed('txtCustomer'),
            onSearch: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const Customer(Searchby: 1, SearchId: 0)),
              ).then((_navRes) { if (_navRes != null) { objfun.SelectCustomerList = _navRes; }
                if (objfun.SelectCustomerList.Id != 0) {
                  bloc.add(SalesOrderCustomerSelected(
                    custId: objfun.SelectCustomerList.Id,
                    custName: objfun.SelectCustomerList.AccountName,
                  ));
                  objfun.SelectCustomerList = CustomerModel.Empty();
                }
              });
            },
            onClear: () => bloc.add(const SalesOrderCustomerCleared()),
            isTablet: isTablet,
          ),
          const SizedBox(height: 8),

          // Job Type
          _searchField(
            controller: TextEditingController(text: state.jobTypeName),
            hint: 'Job Type',
            hasValue: state.jobTypeName.isNotEmpty,
            enabled: state.isAllowed('txtJobType'),
            onSearch: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const JobType(Searchby: 1, SearchId: 0)),
              ).then((_navRes) { if (_navRes != null) { objfun.SelectJobTypeList = _navRes; }
                if (objfun.SelectJobTypeList.Id != 0) {
                  bloc.add(SalesOrderJobTypeSelected(
                    jobTypeId: objfun.SelectJobTypeList.Id,
                    jobTypeName: objfun.SelectJobTypeList.Name,
                  ));
                  objfun.SelectJobTypeList = JobTypeModel.Empty();
                }
              });
            },
            onClear: () => bloc.add(const SalesOrderJobTypeCleared()),
            isTablet: isTablet,
          ),
          const SizedBox(height: 8),

          // Job Status
          _searchField(
            controller: TextEditingController(text: state.jobStatusName),
            hint: 'Job Status',
            hasValue: state.jobStatusName.isNotEmpty,
            enabled: state.isAllowed('txtJobStatus'),
            onSearch: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const JobAllStatus(
                        Searchby: 1, SearchId: 0, JobTypeId: 0)),
              ).then((_navRes) { if (_navRes != null) { objfun.SelectAllStatusList = _navRes; }
                if (objfun.SelectAllStatusList.Status != 0) {
                  bloc.add(SalesOrderJobStatusSelected(
                    statusId: objfun.SelectAllStatusList.Status,
                    statusName: objfun.SelectAllStatusList.StatusName,
                  ));
                  objfun.SelectAllStatusList = JobAllStatusModel.Empty();
                }
              });
            },
            isTablet: isTablet,
          ),
          const SizedBox(height: 8),

          // Sale Date
          _datePicker(
            context: context,
            label: 'Sale Date',
            dateStr: state.dtpSaleOrderDate,
            onPicked: (d) => bloc.add(SalesOrderDateChanged(
                date: DateFormat('yyyy-MM-dd').format(d))),
            isTablet: isTablet,
          ),
          const SizedBox(height: 8),

          // Truck Size
          _styledDropdown<String>(
            value: state.truckSizeDropdown,
            items: [
              '1 Tonner', '3 Tonner', '5 Tonner',
              '10 Tonner', '40 FT Truck'
            ],
            label: 'Truck Size',
            enabled: state.isAllowed('txtTruckSize'),
            onChanged: (v) =>
                bloc.add(SalesOrderTruckSizeChanged(value: v)),
            isTablet: isTablet,
          ),
          const SizedBox(height: 8),

          _styledField(
              controller: txtWeight,
              hint: 'Total Weight',
              isTablet: isTablet),
          const SizedBox(height: 8),

          _styledField(
              controller: txtQuantity,
              hint: 'Quantity',
              isTablet: isTablet),
          const SizedBox(height: 8),

          _styledField(
              controller: txtRemarks, hint: 'Remarks', isTablet: isTablet),
          const SizedBox(height: 8),

          _styledField(
              controller: txtDoDescription,
              hint: 'DO Description',
              isTablet: isTablet),
          const SizedBox(height: 8),

          _styledField(
              controller: txtCommodityType,
              hint: 'Commodity Type',
              isTablet: isTablet),
          const SizedBox(height: 8),

          if (state.visibility.awbNo)
            _styledField(
                controller: txtAWBNo, hint: 'AWB No', isTablet: isTablet),

          if (state.visibility.blCopy)
            _styledField(
                controller: txtBLCopy, hint: 'BL Copy', isTablet: isTablet),

          // Origin
          if (state.visibility.origin)
            _searchField(
              controller: txtOrigin,
              hint: 'Origin',
              hasValue: txtOrigin.text.isNotEmpty,
              enabled: state.isAllowed('txtOrigin'),
              onSearch: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                    const Location(Searchby: 1, SearchId: 0)),
              ).then((_navRes) { if (_navRes != null) { objfun.SelectLocationList = _navRes; }
                if (objfun.SelectLocationList.Id != 0) {
                  bloc.add(SalesOrderOriginSelected(
                    id: objfun.SelectLocationList.Id,
                    name: objfun.SelectLocationList.Location,
                  ));
                  txtOrigin.text = objfun.SelectLocationList.Location;
                  objfun.SelectLocationList = LocationModel.Empty();
                }
              }),
              isTablet: isTablet,
            ),

          // Destination
          if (state.visibility.destination)
            _searchField(
              controller: txtDestination,
              hint: 'Destination',
              hasValue: txtDestination.text.isNotEmpty,
              enabled: state.isAllowed('txtDestination'),
              onSearch: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                    const Location(Searchby: 1, SearchId: 0)),
              ).then((_navRes) { if (_navRes != null) { objfun.SelectLocationList = _navRes; }
                if (objfun.SelectLocationList.Id != 0) {
                  bloc.add(SalesOrderDestinationSelected(
                    id: objfun.SelectLocationList.Id,
                    name: objfun.SelectLocationList.Location,
                  ));
                  txtDestination.text = objfun.SelectLocationList.Location;
                  objfun.SelectLocationList = LocationModel.Empty();
                }
              }),
              isTablet: isTablet,
            ),

          // Pickup date
          if (state.isAllowed('chkPickup'))
            _checkboxDateRow(
              context: context,
              label: 'Pickup Date',
              checked: state.chkPickUp,
              dateStr: state.dtpPickUpDate,
              onToggle: (v) => bloc.add(SalesOrderDateTimeToggled(
                  field: 'PickUp', value: v ?? false)),
              onDatePicked: (d) => bloc.add(SalesOrderDateTimeChanged(
                  field: 'PickUp',
                  dateTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(d))),
              isTablet: isTablet,
            ),

          // Delivery date
          if (state.isAllowed('chkDelivery'))
            _checkboxDateRow(
              context: context,
              label: 'Delivery Date',
              checked: state.chkDelivery,
              dateStr: state.dtpDeliveryDate,
              onToggle: (v) => bloc.add(SalesOrderDateTimeToggled(
                  field: 'Delivery', value: v ?? false)),
              onDatePicked: (d) => bloc.add(SalesOrderDateTimeChanged(
                  field: 'Delivery',
                  dateTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(d))),
              isTablet: isTablet,
            ),
          const SizedBox(height: 8),

          // ── Pickup Address ── FIX: removed pre-fetch; AddressList fetches itself
          _searchField(
            controller: txtPickUpAddress,
            hint: 'Pickup Address',
            hasValue: txtPickUpAddress.text.isNotEmpty,
            enabled: state.isAllowed('txtPickUpAddress'),
            isTablet: isTablet,
            onSearch: () {
              // Do NOT call OnlineApi.selectAddressList() here.
              // AddressList widget handles its own fetch in initState.
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                    const AddressList(Searchby: 1, SearchId: 0)),
              ).then((_navRes) { if (_navRes != null) { objfun.SelectAddressList = _navRes; }
                if (objfun.SelectAddressList.isNotEmpty) {
                  txtPickUpAddress.text = objfun.SelectAddressList;
                  bloc.add(SalesOrderPickupAddressListUpdated(
                    list: state.pickupAddressList,
                    displayText: objfun.SelectAddressList,
                  ));
                  objfun.SelectAddressList = '';
                }
              });
            },
            onClear: () {
              txtPickUpAddress.clear();
              bloc.add(const SalesOrderPickupAddressListUpdated(
                  list: [], displayText: ''));
            },
          ),
          const SizedBox(height: 8),

          _styledField(
              controller: txtPickUpQuantity,
              hint: 'Pickup Quantity',
              isTablet: isTablet),
          const SizedBox(height: 8),

          _styledField(
              controller: txtPickUpWeight, // Pudhu controller create pannunga
              hint: 'Pickup Weight',
              keyboardType: TextInputType.number,
              isTablet: isTablet),
          const SizedBox(height: 8),
          // ── Delivery Address ── FIX: removed pre-fetch
          _searchField(
            controller: txtDeliveryAddress,
            hint: 'Delivery Address',
            hasValue: txtDeliveryAddress.text.isNotEmpty,
            enabled: state.isAllowed('txtDeliveryAddress'),
            isTablet: isTablet,
            onSearch: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                    const AddressList(Searchby: 1, SearchId: 0)),
              ).then((_navRes) { if (_navRes != null) { objfun.SelectAddressList = _navRes; }
                if (objfun.SelectAddressList.isNotEmpty) {
                  txtDeliveryAddress.text = objfun.SelectAddressList;
                  bloc.add(SalesOrderDeliveryAddressListUpdated(
                    list: state.deliveryAddressList,
                    displayText: objfun.SelectAddressList,
                  ));
                  objfun.SelectAddressList = '';
                }
              });
            },
            onClear: () {
              txtDeliveryAddress.clear();
              bloc.add(const SalesOrderDeliveryAddressListUpdated(
                  list: [], displayText: ''));
            },
          ),
          const SizedBox(height: 8),

          _styledField(
              controller: txtDeliveryQuantity,
              hint: 'Delivery Quantity',
              isTablet: isTablet),
          const SizedBox(height: 8),

          _styledField(
              controller: txtDeliveryWeight, // Pudhu controller create pannunga
              hint: 'Delivery Weight',
              keyboardType: TextInputType.number,
              isTablet: isTablet),
          // ── Warehouse Address ── FIX: removed pre-fetch
          _searchField(
            controller: txtWarehouseAddress,
            hint: 'Warehouse Address',
            hasValue: txtWarehouseAddress.text.isNotEmpty,
            enabled: state.isAllowed('txtWarehouseAddress'),
            isTablet: isTablet,
            onSearch: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                    const AddressList(Searchby: 1, SearchId: 0)),
              ).then((_navRes) { if (_navRes != null) { objfun.SelectAddressList = _navRes; }
                if (objfun.SelectAddressList.isNotEmpty) {
                  txtWarehouseAddress.text = objfun.SelectAddressList;
                  objfun.SelectAddressList = '';
                }
              });
            },
            onClear: () => txtWarehouseAddress.clear(),
          ),

          // WH Entry
          if (state.isAllowed('chkWareHouseEntry'))
            _checkboxDateRow(
              context: context,
              label: 'WH Entry',
              checked: state.chkWHEntry,
              dateStr: state.dtpWHEntryDate,
              onToggle: (v) => bloc.add(SalesOrderDateTimeToggled(
                  field: 'WHEntry', value: v ?? false)),
              onDatePicked: (d) => bloc.add(SalesOrderDateTimeChanged(
                  field: 'WHEntry',
                  dateTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(d))),
              isTablet: isTablet,
            ),

          // WH Exit
          if (state.isAllowed('chkWareHouseExit'))
            _checkboxDateRow(
              context: context,
              label: 'WH Exit',
              checked: state.chkWHExit,
              dateStr: state.dtpWHExitDate,
              onToggle: (v) => bloc.add(SalesOrderDateTimeToggled(
                  field: 'WHExit', value: v ?? false)),
              onDatePicked: (d) => bloc.add(SalesOrderDateTimeChanged(
                  field: 'WHExit',
                  dateTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(d))),
              isTablet: isTablet,
            ),
        ],
      ),
    );
  }

  // ─── TAB 1: Loading Vessel ────────────────────────────────────────────────

  Widget _buildTab1_LoadingVessel(
      BuildContext context,
      SalesOrderState state,
      SalesOrderBloc bloc,
      bool isTablet,
      ) {
    final v = state.visibility;
    return Padding(
      padding: EdgeInsets.all(isTablet ? 20 : 15),
      child: ListView(
        children: [
          if (v.loadingVessel)
            _styledField(
                controller: txtLoadingVessel,
                hint: 'Loading Vessel Name',
                isTablet: isTablet),
          if (v.lShippingAgent)
            _searchField(
              controller:
              TextEditingController(text: state.lAgentCompanyName),
              hint: 'L Agent Company',
              hasValue: state.lAgentCompanyName.isNotEmpty,
              enabled: state.isAllowed('txtLAgentCompany'),
              onSearch: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                    const AgentCompany(Searchby: 1, SearchId: 0)),
              ).then((_navRes) { if (_navRes != null) { objfun.SelectAgentCompanyList = _navRes; }
                if (objfun.SelectAgentCompanyList.Id != 0) {
                  bloc.add(SalesOrderLAgentCompanySelected(
                      id: objfun.SelectAgentCompanyList.Id,
                      name: objfun.SelectAgentCompanyList.Name));
                  objfun.SelectAgentCompanyList = AgentCompanyModel.Empty();
                }
              }),
              isTablet: isTablet,
            ),
          if (v.lAgentName)
            _searchField(
              controller: TextEditingController(text: state.lAgentName),
              hint: 'L Agent Name',
              hasValue: state.lAgentName.isNotEmpty,
              enabled: state.isAllowed('txtLAgentName'),
              onSearch: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                    const Agent(Searchby: 1, SearchId: 0, AgentCompanyId: 0)),
              ).then((_navRes) { if (_navRes != null) { objfun.SelectAgentAllList = _navRes; }
                if (objfun.SelectAgentAllList.Id != 0) {
                  bloc.add(SalesOrderLAgentSelected(
                      id: objfun.SelectAgentAllList.Id,
                      name: objfun.SelectAgentAllList.AgentName));
                  objfun.SelectAgentAllList = AgentModel.Empty();
                }
              }),
              isTablet: isTablet,
            ),
          if (v.lVesselType)
            _styledField(
                controller: txtLVesselType,
                hint: 'L Vessel Type',
                isTablet: isTablet),
          if (v.lPort)
            _styledField(
                controller: txtLPort, hint: 'L Port', isTablet: isTablet),
          if (v.lScn)
            _styledField(
                controller: txtLSCN, hint: 'L SCN', isTablet: isTablet),
          if (v.lETA)
            _checkboxDateRow(
              context: context,
              label: 'L ETA',
              checked: state.chkLETA,
              dateStr: state.dtpLETAdate,
              onToggle: (v) => bloc.add(SalesOrderDateTimeToggled(
                  field: 'LETA', value: v ?? false)),
              onDatePicked: (d) => bloc.add(SalesOrderDateTimeChanged(
                  field: 'LETA',
                  dateTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(d))),
              isTablet: isTablet,
            ),
          if (v.flightTime)
            _checkboxDateRow(
              context: context,
              label: 'Flight Time',
              checked: state.chkFlightTime,
              dateStr: state.dtpFlightTimeDate,
              onToggle: (v) => bloc.add(SalesOrderDateTimeToggled(
                  field: 'FlightTime', value: v ?? false)),
              onDatePicked: (d) => bloc.add(SalesOrderDateTimeChanged(
                  field: 'FlightTime',
                  dateTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(d))),
              isTablet: isTablet,
            ),
          if (v.lETB)
            _checkboxDateRow(
              context: context,
              label: 'L ETB',
              checked: state.chkLETB,
              dateStr: state.dtpLETBdate,
              onToggle: (v) => bloc.add(SalesOrderDateTimeToggled(
                  field: 'LETB', value: v ?? false)),
              onDatePicked: (d) => bloc.add(SalesOrderDateTimeChanged(
                  field: 'LETB',
                  dateTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(d))),
              isTablet: isTablet,
            ),
          if (v.lETD)
            _checkboxDateRow(
              context: context,
              label: 'L ETD',
              checked: state.chkLETD,
              dateStr: state.dtpLETDdate,
              onToggle: (v) => bloc.add(SalesOrderDateTimeToggled(
                  field: 'LETD', value: v ?? false)),
              onDatePicked: (d) => bloc.add(SalesOrderDateTimeChanged(
                  field: 'LETD',
                  dateTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(d))),
              isTablet: isTablet,
            ),
        ],
      ),
    );
  }

  // ─── TAB 2: Off Vessel ────────────────────────────────────────────────────

  Widget _buildTab2_OffVessel(
      BuildContext context,
      SalesOrderState state,
      SalesOrderBloc bloc,
      bool isTablet,
      ) {
    final v = state.visibility;
    return Padding(
      padding: EdgeInsets.all(isTablet ? 20 : 15),
      child: ListView(
        children: [
          if (v.offVessel)
            _styledField(
                controller: txtOffVessel,
                hint: 'Off Vessel Name',
                isTablet: isTablet),
          if (v.oShippingAgent)
            _searchField(
              controller:
              TextEditingController(text: state.oAgentCompanyName),
              hint: 'O Agent Company',
              hasValue: state.oAgentCompanyName.isNotEmpty,
              enabled: state.isAllowed('txtOAgentCompany'),
              onSearch: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                    const AgentCompany(Searchby: 1, SearchId: 0)),
              ).then((_navRes) { if (_navRes != null) { objfun.SelectAgentCompanyList = _navRes; }
                if (objfun.SelectAgentCompanyList.Id != 0) {
                  bloc.add(SalesOrderOAgentCompanySelected(
                      id: objfun.SelectAgentCompanyList.Id,
                      name: objfun.SelectAgentCompanyList.Name));
                  objfun.SelectAgentCompanyList = AgentCompanyModel.Empty();
                }
              }),
              isTablet: isTablet,
            ),
          if (v.oAgentName)
            _searchField(
              controller: TextEditingController(text: state.oAgentName),
              hint: 'O Agent Name',
              hasValue: state.oAgentName.isNotEmpty,
              enabled: state.isAllowed('txtOAgentName'),
              onSearch: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                    const Agent(Searchby: 1, SearchId: 0, AgentCompanyId: 0)),
              ).then((_navRes) { if (_navRes != null) { objfun.SelectAgentAllList = _navRes; }
                if (objfun.SelectAgentAllList.Id != 0) {
                  bloc.add(SalesOrderOAgentSelected(
                      id: objfun.SelectAgentAllList.Id,
                      name: objfun.SelectAgentAllList.AgentName));
                  objfun.SelectAgentAllList = AgentModel.Empty();
                }
              }),
              isTablet: isTablet,
            ),
          if (v.oVesselType)
            _styledField(
                controller: txtOVesselType,
                hint: 'O Vessel Type',
                isTablet: isTablet),
          if (v.oPort)
            _styledField(
                controller: txtOPort, hint: 'O Port', isTablet: isTablet),
          if (v.oScn)
            _styledField(
                controller: txtOSCN, hint: 'O SCN', isTablet: isTablet),
          if (v.oETA)
            _checkboxDateRow(
              context: context,
              label: 'O ETA',
              checked: state.chkOETA,
              dateStr: state.dtpOETAdate,
              onToggle: (v) => bloc.add(SalesOrderDateTimeToggled(
                  field: 'OETA', value: v ?? false)),
              onDatePicked: (d) => bloc.add(SalesOrderDateTimeChanged(
                  field: 'OETA',
                  dateTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(d))),
              isTablet: isTablet,
            ),
          if (v.oETB)
            _checkboxDateRow(
              context: context,
              label: 'O ETB',
              checked: state.chkOETB,
              dateStr: state.dtpOETBdate,
              onToggle: (v) => bloc.add(SalesOrderDateTimeToggled(
                  field: 'OETB', value: v ?? false)),
              onDatePicked: (d) => bloc.add(SalesOrderDateTimeChanged(
                  field: 'OETB',
                  dateTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(d))),
              isTablet: isTablet,
            ),
          if (v.oETD)
            _checkboxDateRow(
              context: context,
              label: 'O ETD',
              checked: state.chkOETD,
              dateStr: state.dtpOETDdate,
              onToggle: (v) => bloc.add(SalesOrderDateTimeToggled(
                  field: 'OETD', value: v ?? false)),
              onDatePicked: (d) => bloc.add(SalesOrderDateTimeChanged(
                  field: 'OETD',
                  dateTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(d))),
              isTablet: isTablet,
            ),
        ],
      ),
    );
  }

  // ─── TAB 3: Forwarding ────────────────────────────────────────────────────

  Widget _buildTab3_Forwarding(
      BuildContext context,
      SalesOrderState state,
      SalesOrderBloc bloc,
      bool isTablet,
      ) {
    if (!state.visibility.forwarding) {
      return const Center(child: Text('Not applicable for this job type'));
    }
    return Padding(
      padding: EdgeInsets.all(isTablet ? 20 : 15),
      child: ListView(
        children: [
          // FW 1
          if (state.isAllowed('dropdownValueFW1'))
            _styledDropdown<String>(
              value: state.fw1Dropdown,
              items: const ['K1', 'K2', 'K3', 'K8'],
              label: 'Forwarding 1',
              onChanged: (v) => bloc.add(SalesOrderFW1Changed(value: v)),
              isTablet: isTablet,
            ),
          if (state.isAllowed('checkBoxValueFW1'))
            _checkboxDateRow(
              context: context,
              label: 'FW1 Date',
              checked: state.chkFW1,
              dateStr: state.dtpFW1date,
              onToggle: (v) => bloc.add(SalesOrderDateTimeToggled(
                  field: 'FW1', value: v ?? false)),
              onDatePicked: (d) => bloc.add(SalesOrderDateTimeChanged(
                  field: 'FW1',
                  dateTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(d))),
              isTablet: isTablet,
            ),
          _styledField(
              controller: txtSmk1, hint: 'SMK No 1', isTablet: isTablet),
          _styledField(
              controller: txtENRef1, hint: 'EN Ref 1', isTablet: isTablet),
          _styledField(
              controller: txtExRef1, hint: 'EX Ref 1', isTablet: isTablet),
          if (state.visibility.sealBy)
            _searchField(
              controller: TextEditingController(text: state.sealEmpName1),
              hint: 'Seal By 1',
              hasValue: state.sealEmpName1.isNotEmpty,
              enabled: state.isAllowed('txtSealByEmp1'),
              onSearch: () => _pickEmployee(context, bloc, 'seal', 1),
              onClear: () =>
                  bloc.add(const SalesOrderSealEmpCleared(slot: 1)),
              isTablet: isTablet,
            ),
          if (state.visibility.breakSealBy)
            _searchField(
              controller: TextEditingController(text: state.breakEmpName1),
              hint: 'Break Seal By 1',
              hasValue: state.breakEmpName1.isNotEmpty,
              enabled: state.isAllowed('txtBreakByEmp1'),
              onSearch: () => _pickEmployee(context, bloc, 'break', 1),
              onClear: () =>
                  bloc.add(const SalesOrderBreakSealEmpCleared(slot: 1)),
              isTablet: isTablet,
            ),
          _autocompleteField(
              context: context, controller: txtForwarding1S1,
              hint: 'Forwarding 1 S1', type: 1, bloc: bloc,
              state: state, isTablet: isTablet),
          _autocompleteField(
              context: context, controller: txtForwarding1S2,
              hint: 'Forwarding 1 S2', type: 2, bloc: bloc,
              state: state, isTablet: isTablet),
          const Divider(),

          // FW 2
          if (state.isAllowed('dropdownValueFW2'))
            _styledDropdown<String>(
              value: state.fw2Dropdown,
              items: const ['K1', 'K2', 'K3', 'K8'],
              label: 'Forwarding 2',
              onChanged: (v) => bloc.add(SalesOrderFW2Changed(value: v)),
              isTablet: isTablet,
            ),
          if (state.isAllowed('checkBoxValueFW2'))
            _checkboxDateRow(
              context: context,
              label: 'FW2 Date',
              checked: state.chkFW2,
              dateStr: state.dtpFW2date,
              onToggle: (v) => bloc.add(SalesOrderDateTimeToggled(
                  field: 'FW2', value: v ?? false)),
              onDatePicked: (d) => bloc.add(SalesOrderDateTimeChanged(
                  field: 'FW2',
                  dateTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(d))),
              isTablet: isTablet,
            ),
          if (state.isAllowed('txtSmk2'))
            _styledField(
                controller: txtSmk2, hint: 'SMK No 2', isTablet: isTablet),
          _styledField(
              controller: txtENRef2, hint: 'EN Ref 2', isTablet: isTablet),
          _styledField(
              controller: txtExRef2, hint: 'EX Ref 2', isTablet: isTablet),
          if (state.visibility.sealBy)
            _searchField(
              controller: TextEditingController(text: state.sealEmpName2),
              hint: 'Seal By 2',
              hasValue: state.sealEmpName2.isNotEmpty,
              enabled: state.isAllowed('txtSealByEmp2'),
              onSearch: () => _pickEmployee(context, bloc, 'seal', 2),
              onClear: () =>
                  bloc.add(const SalesOrderSealEmpCleared(slot: 2)),
              isTablet: isTablet,
            ),
          if (state.visibility.breakSealBy)
            _searchField(
              controller: TextEditingController(text: state.breakEmpName2),
              hint: 'Break Seal By 2',
              hasValue: state.breakEmpName2.isNotEmpty,
              enabled: state.isAllowed('txtBreakByEmp2'),
              onSearch: () => _pickEmployee(context, bloc, 'break', 2),
              onClear: () =>
                  bloc.add(const SalesOrderBreakSealEmpCleared(slot: 2)),
              isTablet: isTablet,
            ),
          _autocompleteField(
              context: context, controller: txtForwarding2S1,
              hint: 'Forwarding 2 S1', type: 3, bloc: bloc,
              state: state, isTablet: isTablet),
          _autocompleteField(
              context: context, controller: txtForwarding2S2,
              hint: 'Forwarding 2 S2', type: 4, bloc: bloc,
              state: state, isTablet: isTablet),
          const Divider(),

          // FW 3
          if (state.isAllowed('dropdownValueFW3'))
            _styledDropdown<String>(
              value: state.fw3Dropdown,
              items: const ['K1', 'K2', 'K3', 'K8'],
              label: 'Forwarding 3',
              onChanged: (v) => bloc.add(SalesOrderFW3Changed(value: v)),
              isTablet: isTablet,
            ),
          if (state.isAllowed('checkBoxValueFW3'))
            _checkboxDateRow(
              context: context,
              label: 'FW3 Date',
              checked: state.chkFW3,
              dateStr: state.dtpFW3date,
              onToggle: (v) => bloc.add(SalesOrderDateTimeToggled(
                  field: 'FW3', value: v ?? false)),
              onDatePicked: (d) => bloc.add(SalesOrderDateTimeChanged(
                  field: 'FW3',
                  dateTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(d))),
              isTablet: isTablet,
            ),
          _styledField(
              controller: txtSmk3, hint: 'SMK No 3', isTablet: isTablet),
          _styledField(
              controller: txtENRef3, hint: 'EN Ref 3', isTablet: isTablet),
          _styledField(
              controller: txtExRef3, hint: 'EX Ref 3', isTablet: isTablet),
          if (state.visibility.sealBy)
            _searchField(
              controller: TextEditingController(text: state.sealEmpName3),
              hint: 'Seal By 3',
              hasValue: state.sealEmpName3.isNotEmpty,
              enabled: state.isAllowed('txtSealByEmp3'),
              onSearch: () => _pickEmployee(context, bloc, 'seal', 3),
              onClear: () =>
                  bloc.add(const SalesOrderSealEmpCleared(slot: 3)),
              isTablet: isTablet,
            ),
          if (state.visibility.breakSealBy)
            _searchField(
              controller: TextEditingController(text: state.breakEmpName3),
              hint: 'Break Seal By 3',
              hasValue: state.breakEmpName3.isNotEmpty,
              enabled: state.isAllowed('txtBreakByEmp3'),
              onSearch: () => _pickEmployee(context, bloc, 'break', 3),
              onClear: () =>
                  bloc.add(const SalesOrderBreakSealEmpCleared(slot: 3)),
              isTablet: isTablet,
            ),
          _autocompleteField(
              context: context, controller: txtForwarding3S1,
              hint: 'Forwarding 3 S1', type: 5, bloc: bloc,
              state: state, isTablet: isTablet),
          _autocompleteField(
              context: context, controller: txtForwarding3S2,
              hint: 'Forwarding 3 S2', type: 6, bloc: bloc,
              state: state, isTablet: isTablet),

          // ZB
          if (state.visibility.zb) ...[
            const Divider(),
            _styledDropdown<String>(
              value: state.zb1Dropdown,
              items: const ['ZB1', 'ZB2'],
              label: 'ZB 1',
              onChanged: (v) => bloc.add(SalesOrderZB1Changed(value: v)),
              isTablet: isTablet,
            ),
            _styledField(
                controller: txtZBRef1,
                hint: 'ZB Ref 1',
                isTablet: isTablet),
            _styledDropdown<String>(
              value: state.zb2Dropdown,
              items: const ['ZB1', 'ZB2'],
              label: 'ZB 2',
              onChanged: (v) => bloc.add(SalesOrderZB2Changed(value: v)),
              isTablet: isTablet,
            ),
            _styledField(
                controller: txtZBRef2,
                hint: 'ZB Ref 2',
                isTablet: isTablet),
          ],

          _styledField(
              controller: txtPortChargeRef1,
              hint: 'Port Charge Ref',
              isTablet: isTablet),
          _styledField(
              controller: txtPortCharges,
              hint: 'Port Charges',
              isTablet: isTablet),
          _styledField(
              controller: txtPTWNo, hint: 'PTW No', isTablet: isTablet),
        ],
      ),
    );
  }

  // ─── TAB 4: Boarding ──────────────────────────────────────────────────────

  Widget _buildTab4_Boarding(
      BuildContext context,
      SalesOrderState state,
      SalesOrderBloc bloc,
      bool isTablet,
      ) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? 20 : 15),
      child: ListView(
        children: [
          _searchField(
            controller:
            TextEditingController(text: state.boardingOfficerName1),
            hint: 'Boarding Officer 1',
            hasValue: state.boardingOfficerName1.isNotEmpty,
            enabled: state.isAllowed('txtBoardingOfficer1'),
            onSearch: () => _pickEmployee(context, bloc, 'boarding', 1),
            onClear: () =>
                bloc.add(const SalesOrderBoardingOfficerCleared(slot: 1)),
            isTablet: isTablet,
          ),
          const SizedBox(height: 8),
          _styledField(
            controller: txtAmount1,
            hint: 'Amount 1',
            enabled:
            state.isAllowed('txtAmount1') && !state.disabledAmount1,
            isTablet: isTablet,
          ),
          const SizedBox(height: 8),
          _searchField(
            controller:
            TextEditingController(text: state.boardingOfficerName2),
            hint: 'Boarding Officer 2',
            hasValue: state.boardingOfficerName2.isNotEmpty,
            enabled: state.isAllowed('txtBoardingOfficer2'),
            onSearch: () => _pickEmployee(context, bloc, 'boarding', 2),
            onClear: () =>
                bloc.add(const SalesOrderBoardingOfficerCleared(slot: 2)),
            isTablet: isTablet,
          ),
          const SizedBox(height: 8),
          _styledField(
            controller: txtAmount2,
            hint: 'Amount 2',
            enabled:
            state.isAllowed('txtAmount2') && !state.disabledAmount2,
            isTablet: isTablet,
          ),
        ],
      ),
    );
  }

  // ─── TAB 5: Products ──────────────────────────────────────────────────────

  Widget _buildTab5_Products(
      BuildContext context,
      SalesOrderState state,
      SalesOrderBloc bloc,
      bool isTablet,
      ) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? 20 : 15),
      child: Column(
        children: [
          if (state.isAllowed('addProduct'))
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colour.commonColorLight,
                  side: const BorderSide(color: colour.commonColor),
                ),
                onPressed: () => _showAddProductDialog(
                    context, state, bloc, isTablet),
              ),
            ),
          const SizedBox(height: 8),

          // Totals row
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colour.commonColorLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ${state.totalAmount.toStringAsFixed(2)}',
                  style: GoogleFonts.lato(
                    color: colour.commonColor,
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet
                        ? objfun.FontMedium.toDouble()
                        : objfun.FontLow.toDouble(),
                  ),
                ),
                Text(
                  'Actual: ${state.actualAmount.toStringAsFixed(2)}',
                  style: GoogleFonts.lato(
                    color: colour.commonColor,
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet
                        ? objfun.FontMedium.toDouble()
                        : objfun.FontLow.toDouble(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Product list
          Expanded(
            child: ListView.builder(
              itemCount: state.productList.length,
              itemBuilder: (context, index) {
                final p = state.productList[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(p.ProductName,
                        style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold,
                            color: colour.commonColor,
                            fontSize: isTablet
                                ? objfun.FontMedium.toDouble()
                                : objfun.FontCardText.toDouble())),
                    subtitle: Text(
                        'Qty: ${p.ItemQty}  Rate: ${p.SalesRate}  Amt: ${p.Amount.toStringAsFixed(2)}',
                        style: GoogleFonts.lato(
                            color: colour.commonColor,
                            fontSize: isTablet ? 14.0 : 12.0)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit,
                              color: colour.commonColor),
                          onPressed: () => _showAddProductDialog(
                              context, state, bloc, isTablet,
                              editIndex: index, existing: p),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: colour.commonColorred),
                          onPressed: () => bloc
                              .add(SalesOrderProductRemoved(index: index)),
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

  // ─── Add/Edit Product Dialog ──────────────────────────────────────────────

  void _showAddProductDialog(
      BuildContext context,
      SalesOrderState state,
      SalesOrderBloc bloc,
      bool isTablet, {
        int? editIndex,
        SaleEditDetailModel? existing,
      }) {
    if (existing != null) {
      txtProductDescription.text = existing.ProductName;
      txtProductCode.text = existing.ProductCode;
      txtProductQty.text = existing.ItemQty.toString();
      txtProductSaleRate.text = existing.SalesRate.toString();
      txtProductGst.text = existing.TaxPercent.toString();
      txtProductAmount.text = existing.Amount.toString();
      txtProductUOM.text = existing.UOM;
      txtProductId.text = existing.Id.toString();
      txtProductSDId.text = existing.SDId.toString();
      txtItemMasterRefId.text = existing.ItemMasterRefId.toString();
    } else {
      for (final c in [
        txtProductDescription, txtProductCode, txtProductQty,
        txtProductSaleRate, txtProductGst, txtProductAmount,
        txtProductGSTAmount, txtProductActualAmount, txtProductUOM,
        txtProductId, txtProductSDId, txtItemMasterRefId,
        txtSaleOrderMasterRefId, txtProductMRP, txtProductPurchaseRate,
        txtProductNetSalesRate, txtProductDiscPer, txtProductDiscAmount,
        txtProductLandingCost,
      ]) {
        c.clear();
      }
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(editIndex != null ? 'Edit Product' : 'Add Product',
            style: GoogleFonts.lato(
                color: colour.commonColor,
                fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: isTablet ? 500 : double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _styledField(
                  controller: txtProductDescription,
                  hint: 'Description',
                  isTablet: isTablet),
              const SizedBox(height: 8),
              _styledField(
                  controller: txtProductQty,
                  hint: 'Quantity',
                  keyboardType: TextInputType.number,
                  isTablet: isTablet),
              const SizedBox(height: 8),
              _styledField(
                  controller: txtProductSaleRate,
                  hint: 'Sale Rate',
                  keyboardType: TextInputType.number,
                  isTablet: isTablet),
              const SizedBox(height: 8),
              _styledField(
                  controller: txtProductGst,
                  hint: 'GST %',
                  keyboardType: TextInputType.number,
                  isTablet: isTablet),
              const SizedBox(height: 8),
              _styledField(
                  controller: txtProductUOM,
                  hint: 'UOM',
                  isTablet: isTablet),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: colour.commonColor),
            onPressed: () {
              Navigator.pop(context);
              final product = SaleEditDetailModel(
                txtProductId.text.isNotEmpty
                    ? int.parse(txtProductId.text)
                    : 0,
                txtProductSDId.text.isNotEmpty
                    ? int.parse(txtProductSDId.text)
                    : 0,
                txtSaleOrderMasterRefId.text.isNotEmpty
                    ? int.parse(txtSaleOrderMasterRefId.text)
                    : 0,
                txtItemMasterRefId.text.isNotEmpty
                    ? int.parse(txtItemMasterRefId.text)
                    : 0,
                txtProductMRP.text.isNotEmpty
                    ? double.parse(txtProductMRP.text)
                    : 0,
                txtProductPurchaseRate.text.isNotEmpty
                    ? double.parse(txtProductPurchaseRate.text)
                    : 0,
                txtProductQty.text.isNotEmpty
                    ? double.parse(txtProductQty.text)
                    : 0,
                txtProductDiscPer.text.isNotEmpty
                    ? double.parse(txtProductDiscPer.text)
                    : 0,
                txtProductDiscAmount.text.isNotEmpty
                    ? double.parse(txtProductDiscAmount.text)
                    : 0,
                txtProductLandingCost.text.isNotEmpty
                    ? double.parse(txtProductLandingCost.text)
                    : 0,
                txtProductGst.text.isNotEmpty
                    ? double.parse(txtProductGst.text)
                    : 0,
                txtProductGSTAmount.text.isNotEmpty
                    ? double.parse(txtProductGSTAmount.text)
                    : 0,
                txtProductSaleRate.text.isNotEmpty
                    ? double.parse(txtProductSaleRate.text)
                    : 0,
                txtProductNetSalesRate.text.isNotEmpty
                    ? double.parse(txtProductNetSalesRate.text)
                    : 0,
                txtProductAmount.text.isNotEmpty
                    ? double.parse(txtProductAmount.text)
                    : 0,
                txtProductCode.text,
                txtProductDescription.text,
                txtProductUOM.text,
                txtProductActualAmount.text.isNotEmpty
                    ? double.parse(txtProductActualAmount.text)
                    : 0,
                state.currencyValue,
              );
              bloc.add(SalesOrderProductAdded(
                  product: product, updateIndex: editIndex));
            },
            child: Text('Save',
                style: GoogleFonts.lato(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─── Employee picker ──────────────────────────────────────────────────────

  Future<void> _pickEmployee(
      BuildContext context,
      SalesOrderBloc bloc,
      String type,
      int slot,
      ) async {
    await objfun.apiAllinoneSelect(
        '${objfun.apiSelectEmployee}${objfun.Comid}&type=&type1=Operation',
        null, null, context);

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => const Employee(Searchby: 1, SearchId: 0)),
    ).then((_navRes) { if (_navRes != null) { objfun.SelectEmployeeList = _navRes; }
      final emp = objfun.SelectEmployeeList;
      if (emp.Id != 0) {
        if (type == 'seal') {
          bloc.add(SalesOrderSealEmpSelected(
              slot: slot, id: emp.Id, name: emp.AccountName));
        } else if (type == 'break') {
          bloc.add(SalesOrderBreakSealEmpSelected(
              slot: slot, id: emp.Id, name: emp.AccountName));
        } else {
          bloc.add(SalesOrderBoardingOfficerSelected(
              slot: slot, id: emp.Id, name: emp.AccountName));
        }
        objfun.SelectEmployeeList = EmployeeModel.Empty();
      }
    });
  }

  // ─── Reusable widgets ─────────────────────────────────────────────────────

  Widget _styledField({
    required TextEditingController controller,
    required String hint,
    bool readOnly = false,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    required bool isTablet,
  }) {
    return SizedBox(
      height: isTablet
          ? objfun.SizeConfig.safeBlockVertical * 7
          : objfun.SizeConfig.safeBlockVertical * 6,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        enabled: enabled,
        keyboardType: keyboardType,
        textCapitalization: TextCapitalization.characters,
        style: GoogleFonts.lato(
            color: colour.commonColor,
            fontWeight: FontWeight.bold,
            fontSize: isTablet
                ? objfun.FontLow + 2.0
                : objfun.FontLow.toDouble(),
            letterSpacing: 0.3),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.lato(
              color: colour.commonColorLight,
              fontWeight: FontWeight.bold,
              fontSize: isTablet
                  ? objfun.FontMedium + 2.0
                  : objfun.FontMedium.toDouble()),
          contentPadding:
          const EdgeInsets.only(left: 10, right: 20, top: 10),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: colour.commonColor),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: colour.commonColorred),
          ),
          disabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _searchField({
    required TextEditingController controller,
    required String hint,
    bool hasValue = false,
    bool enabled = true,
    required VoidCallback onSearch,
    VoidCallback? onClear,
    required bool isTablet,
  }) {
    return SizedBox(
      height: isTablet
          ? objfun.SizeConfig.safeBlockVertical * 7
          : objfun.SizeConfig.safeBlockVertical * 6,
      child: TextField(
        controller: controller,
        readOnly: true,
        enabled: enabled,
        style: GoogleFonts.lato(
            color: colour.commonColor,
            fontWeight: FontWeight.bold,
            fontSize: isTablet
                ? objfun.FontLow + 2.0
                : objfun.FontLow.toDouble()),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.lato(
              color: colour.commonColorLight,
              fontWeight: FontWeight.bold,
              fontSize: isTablet
                  ? objfun.FontMedium + 2.0
                  : objfun.FontMedium.toDouble()),
          contentPadding:
          const EdgeInsets.only(left: 10, right: 20, top: 10),
          suffixIcon: InkWell(
            onTap: enabled
                ? (hasValue && onClear != null ? onClear : onSearch)
                : null,
            child: Icon(
              hasValue ? Icons.close : Icons.search_rounded,
              color: colour.commonColorred,
              size: 30,
            ),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: colour.commonColor),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: colour.commonColorred),
          ),
        ),
      ),
    );
  }

  Widget _styledDropdown<T>({
    required T? value,
    required List<T> items,
    required String label,
    required ValueChanged<T?> onChanged,
    bool enabled = true,
    required bool isTablet,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: colour.commonColorLight,
        border: Border.all(color: colour.commonColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          hint: Text(label,
              style: GoogleFonts.lato(
                  color: colour.commonColorLight,
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet
                      ? objfun.FontMedium + 2.0
                      : objfun.FontMedium.toDouble())),
          onChanged: enabled ? onChanged : null,
          style: GoogleFonts.lato(
              color: colour.commonColor,
              fontWeight: FontWeight.bold,
              fontSize: isTablet
                  ? objfun.FontMedium + 2.0
                  : objfun.FontMedium.toDouble()),
          items: items
              .map((item) => DropdownMenuItem<T>(
            value: item,
            child: Text(item.toString()),
          ))
              .toList(),
        ),
      ),
    );
  }

  Widget _checkboxDateRow({
    required BuildContext context,
    required String label,
    required bool checked,
    required String dateStr,
    required ValueChanged<bool?> onToggle,
    required ValueChanged<DateTime> onDatePicked,
    required bool isTablet,
  }) {
    return Row(
      children: [
        Checkbox(
          value: checked,
          activeColor: colour.commonColorred,
          side: const BorderSide(color: colour.commonColor),
          onChanged: onToggle,
        ),
        Text(label,
            style: GoogleFonts.lato(
                color: colour.commonColor,
                fontWeight: FontWeight.bold,
                fontSize: isTablet
                    ? objfun.FontMedium.toDouble()
                    : objfun.FontCardText.toDouble())),
        if (checked) ...[
          const Spacer(),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate:
                DateTime.tryParse(dateStr) ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) onDatePicked(picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: colour.commonColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                dateStr.length >= 10
                    ? dateStr.substring(0, 16)
                    : dateStr,
                style: GoogleFonts.lato(
                    color: colour.commonColor,
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet
                        ? objfun.FontCardText + 2.0
                        : objfun.FontCardText.toDouble()),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _datePicker({
    required BuildContext context,
    required String label,
    required String dateStr,
    required ValueChanged<DateTime> onPicked,
    required bool isTablet,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text('$label: $dateStr',
              style: GoogleFonts.lato(
                  color: colour.commonColor,
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet
                      ? objfun.FontLow.toDouble()
                      : objfun.FontCardText.toDouble())),
        ),
        IconButton(
          icon: const Icon(Icons.date_range, color: colour.commonColor),
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate:
              DateTime.tryParse(dateStr) ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );
            if (picked != null) onPicked(picked);
          },
        ),
      ],
    );
  }

  Widget _autocompleteField({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    required int type,
    required SalesOrderBloc bloc,
    required SalesOrderState state,
    required bool isTablet,
  }) {
    return Column(
      children: [
        _styledField(
          controller: controller,
          hint: hint,
          isTablet: isTablet,
        ),
        if (state.showOverlay && state.overlayType == type)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: colour.commonColorLight,
              border: Border.all(color: colour.commonColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: state.overlaySuggestions.length,
              itemBuilder: (_, i) {
                final keyMap = {
                  1: 'Forwarding1S1', 2: 'Forwarding1S2',
                  3: 'Forwarding2S1', 4: 'Forwarding2S2',
                  5: 'Forwarding3S1', 6: 'Forwarding3S2',
                };
                final key = keyMap[type]!;
                final val =
                    state.overlaySuggestions[i][key]?.toString() ?? '';
                return InkWell(
                  onTap: () {
                    controller.text = val;
                    bloc.add(SalesOrderAutoCompleteS1Selected(
                        type: type, value: val));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    child: Text(val,
                        style: GoogleFonts.lato(
                            color: colour.commonColor,
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet
                                ? objfun.FontLow.toDouble()
                                : objfun.FontCardText.toDouble())),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}