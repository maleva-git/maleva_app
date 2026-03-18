import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/features/transaction/salesorder/add/bloc/salesorderadd_event.dart';
import 'package:maleva/features/transaction/salesorder/add/bloc/salesorderadd_state.dart';





class SalesOrderAddBloc extends Bloc<SalesOrderAddEvent, SalesOrderAddState> {
  final BuildContext context;

  static const List<String> _billType = ['MY', 'TR'];
  static const List<String> _forwardingNo = ['K1', 'K2', 'K3', 'K8'];
  static const List<String> _truckSizeList = ['1 Tonner', '3 Tonner', '5 Tonner', '10 Tonner', '40 FT Truck'];
  static const List<String> _zbNo = ['ZB1', 'ZB2'];

  static List<String> get billType => _billType;
  static List<String> get forwardingNo => _forwardingNo;
  static List<String> get truckSizeList => _truckSizeList;
  static List<String> get zbNo => _zbNo;

  SalesOrderAddBloc(this.context) : super(SalesOrderAddInitial()) {

    // ────────────────────────────────────────────────────
    // STARTUP
    // ────────────────────────────────────────────────────
    on<StartupSalesOrderAdd>((event, emit) async {
      emit(SalesOrderAddLoading());
      try {
        final now = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
        final today = DateFormat("yyyy-MM-dd").format(DateTime.now());

        await OnlineApi.MaxSaleOrderNo(context, 'MY');
        await OnlineApi.SelectAddressList(context);
        await OnlineApi.SelectAgentCompany(context);
        await OnlineApi.SelectEmployee(context, '', 'Operation');

        final permission = _buildPermissions();

        var base = SalesOrderAddLoaded(
          progress: true,
          dtpSaleOrderdate: today,
          dtpOETAdate: now,
          dtpOETBdate: now,
          dtpOETDdate: now,
          dtpLETAdate: now,
          dtpLETBdate: now,
          dtpLETDdate: now,
          dtpFlightTimedate: now,
          dtpPickUpdate: now,
          dtpDeliverydate: now,
          dtpWHEntrydate: now,
          dtpWHExitdate: now,
          dtpFW1date: now,
          dtpFW2date: now,
          dtpFW3date: now,
          txtJobNo: objfun.MaxSaleOrderNum,
          fieldPermission: permission,
        );

        // Enquiry or edit mode
        if (event.saleMaster != null && event.saleMaster!.isNotEmpty) {
          base = await _loadMasterData(base, event.saleMaster!, event.saleDetails, event.isEnquiry);
        }

        emit(base);
      } catch (e) {
        emit(SalesOrderAddError(e.toString()));
      }
    });

    // ────────────────────────────────────────────────────
    // FIELD UPDATES
    // ────────────────────────────────────────────────────
    on<UpdateTextField>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      emit(_updateField(s, event.field, event.value));
    });

    on<UpdateDropdown>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      emit(_updateDropdown(s, event.field, event.value));
    });

    on<UpdateCheckbox>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      emit(_updateCheckbox(s, event.field, event.value));
    });

    on<UpdateDate>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      emit(_updateDateField(s, event.field, event.value));
    });

    // ────────────────────────────────────────────────────
    // MASTER SEARCH SELECTIONS
    // ────────────────────────────────────────────────────
    on<CustomerSelected>((event, emit) async {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      await OnlineApi.loadCustomerCurrency(context, event.id);
      emit(s.copyWith(
        txtCustomer: event.name,
        custId: event.id,
        currencyValue: objfun.CustomerCurrencyValue,
      ));
    });

    on<JobTypeSelected>((event, emit) async {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      await OnlineApi.SelectAllJobStatus(context, event.id);
      final newState = s.copyWith(
        txtJobType: event.name,
        jobTypeId: event.id,
      );
      emit(_applyVisibility(newState));
    });

    on<JobStatusSelected>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      emit(s.copyWith(txtJobStatus: event.name, statusId: event.id));
    });

    on<LAgentCompanySelected>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      emit(s.copyWith(txtLAgentCompany: event.name, lAgentCompanyId: event.id));
    });

    on<LAgentSelected>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      emit(s.copyWith(txtLAgentName: event.name, lAgentId: event.id));
    });

    on<OAgentCompanySelected>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      emit(s.copyWith(txtOAgentCompany: event.name, oAgentCompanyId: event.id));
    });

    on<OAgentSelected>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      emit(s.copyWith(txtOAgentName: event.name, oAgentId: event.id));
    });

    on<SealEmp1Selected>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      emit(event.isBreak
          ? s.copyWith(txtBreakByEmp1: event.name, breakEmpId1: event.id)
          : s.copyWith(txtSealByEmp1: event.name, sealEmpId1: event.id));
    });

    on<SealEmp2Selected>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      emit(event.isBreak
          ? s.copyWith(txtBreakByEmp2: event.name, breakEmpId2: event.id)
          : s.copyWith(txtSealByEmp2: event.name, sealEmpId2: event.id));
    });

    on<SealEmp3Selected>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      emit(event.isBreak
          ? s.copyWith(txtBreakByEmp3: event.name, breakEmpId3: event.id)
          : s.copyWith(txtSealByEmp3: event.name, sealEmpId3: event.id));
    });

    on<BoardingOfficer1Selected>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      emit(s.copyWith(txtBoardingOfficer1: event.name, boardOfficerId1: event.id));
    });

    on<BoardingOfficer2Selected>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      emit(s.copyWith(txtBoardingOfficer2: event.name, boardOfficerId2: event.id));
    });

    on<CommoditySelected>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      emit((state as SalesOrderAddLoaded).copyWith(txtCommodityType: event.name));
    });

    on<CargoSelected>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      emit((state as SalesOrderAddLoaded).copyWith(txtCargo: event.name));
    });

    on<LPortSelected>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      emit((state as SalesOrderAddLoaded).copyWith(txtLPort: event.name));
    });

    on<OPortSelected>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      emit((state as SalesOrderAddLoaded).copyWith(txtOPort: event.name));
    });

    on<LVesselTypeSelected>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      emit((state as SalesOrderAddLoaded).copyWith(txtLVesselType: event.name));
    });

    on<OVesselTypeSelected>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      emit((state as SalesOrderAddLoaded).copyWith(txtOVesselType: event.name));
    });

    on<OriginSelected>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      emit((state as SalesOrderAddLoaded).copyWith(
        txtOrigin: event.name,
        originId: event.id,
      ));
    });

    on<DestinationSelected>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      emit((state as SalesOrderAddLoaded).copyWith(
        txtDestination: event.name,
        destinationId: event.id,
      ));
    });

    on<PickUpAddressSelected>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      emit((state as SalesOrderAddLoaded).copyWith(txtPickUpAddress: event.address));
    });

    on<DeliveryAddressSelected>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      emit((state as SalesOrderAddLoaded).copyWith(txtDeliveryAddress: event.address));
    });

    on<WarehouseAddressSelected>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      emit((state as SalesOrderAddLoaded).copyWith(txtWarehouseAddress: event.address));
    });

    // ────────────────────────────────────────────────────
    // PRODUCT OPERATIONS
    // ────────────────────────────────────────────────────
    on<ProductSelected>((event, emit) async {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      final updated = s.copyWith(
        txtProductDescription: event.name,
        txtProductCode: event.code,
      );
      emit(_recalculate(updated));
    });

    on<ClearProduct>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      emit(s.copyWith(
        txtProductCode: '',
        txtProductDescription: '',
        txtProductQty: '',
        txtProductSaleRate: '',
        txtProductGst: '',
        txtProductAmount: '',
        productUpdateIndex: null,
      ));
    });

    on<AddProduct>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      if (s.txtProductDescription.isEmpty) return;

      final product = _buildProduct(s);
      final list = List<SaleEditDetailModel>.from(s.productViewList);

      if (s.productUpdateIndex != null) {
        list[s.productUpdateIndex!] = product;
      } else {
        list.add(product);
      }

      final updated = s.copyWith(
        productViewList: list,
        productUpdateIndex: null,
        txtProductCode: '',
        txtProductDescription: '',
        txtProductQty: '',
        txtProductSaleRate: '',
        txtProductGst: '',
        txtProductAmount: '',
      );
      emit(_recalculate(updated));
    });

    on<PrepareProductEdit>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      final p = s.productViewList[event.index];
      emit(s.copyWith(
        productUpdateIndex: event.index,
        txtProductCode: p.ProductCode,
        txtProductDescription: p.ProductName,
        txtProductQty: p.ItemQty.toString(),
        txtProductSaleRate: p.SalesRate.toString(),
        txtProductGst: p.TaxPercent.toString(),
        txtProductAmount: p.Amount.toString(),
      ));
    });

    on<RemoveProduct>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      final list = List<SaleEditDetailModel>.from(s.productViewList)
        ..removeAt(event.index);
      emit(_recalculate(s.copyWith(productViewList: list)));
    });

    on<KeyPress>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;

      String current = '';
      switch (event.activeField) {
        case 'qty': current = s.txtProductQty; break;
        case 'saleRate': current = s.txtProductSaleRate; break;
        case 'gst': current = s.txtProductGst; break;
      }

      String newVal = current;
      switch (event.key) {
        case 'CLEAR': newVal = ''; break;
        case 'C':
          if (current.isNotEmpty) newVal = current.substring(0, current.length - 1);
          break;
        default: newVal = current + event.key;
      }

      SalesOrderAddLoaded updated;
      switch (event.activeField) {
        case 'qty': updated = s.copyWith(txtProductQty: newVal); break;
        case 'saleRate': updated = s.copyWith(txtProductSaleRate: newVal); break;
        case 'gst': updated = s.copyWith(txtProductGst: newVal); break;
        default: return;
      }
      emit(_recalculate(updated));
    });

    // ────────────────────────────────────────────────────
    // ADDRESS LIST OPERATIONS
    // ────────────────────────────────────────────────────
    on<AddPickUpAddress>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      if (s.txtPickUpAddress.isEmpty) return;
      final addrList = List<dynamic>.from(s.pickUpAddressList)..add(s.txtPickUpAddress);
      final qtyList = List<dynamic>.from(s.pickUpQuantityList)..add(s.txtPickUpQuantity);
      emit(s.copyWith(
        pickUpAddressList: addrList,
        pickUpQuantityList: qtyList,
        txtPickUpAddress: '',
        txtPickUpQuantity: '',
      ));
    });

    on<AddDeliveryAddress>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      if (s.txtDeliveryAddress.isEmpty) return;
      final addrList = List<dynamic>.from(s.deliveryAddressList)..add(s.txtDeliveryAddress);
      final qtyList = List<dynamic>.from(s.deliveryQuantityList)..add(s.txtDeliveryQuantity);
      emit(s.copyWith(
        deliveryAddressList: addrList,
        deliveryQuantityList: qtyList,
        txtDeliveryAddress: '',
        txtDeliveryQuantity: '',
      ));
    });

    on<RemovePickUpAddress>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      final addrList = List<dynamic>.from(s.pickUpAddressList)..removeAt(event.index);
      final qtyList = List<dynamic>.from(s.pickUpQuantityList)..removeAt(event.index);
      emit(s.copyWith(pickUpAddressList: addrList, pickUpQuantityList: qtyList));
    });

    on<RemoveDeliveryAddress>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      final addrList = List<dynamic>.from(s.deliveryAddressList)..removeAt(event.index);
      final qtyList = List<dynamic>.from(s.deliveryQuantityList)..removeAt(event.index);
      emit(s.copyWith(deliveryAddressList: addrList, deliveryQuantityList: qtyList));
    });

    on<SelectPickUpFromList>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      emit(s.copyWith(
        txtPickUpAddress: s.pickUpAddressList[event.index].toString(),
        txtPickUpQuantity: s.pickUpQuantityList[event.index].toString(),
      ));
    });

    on<SelectDeliveryFromList>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      emit(s.copyWith(
        txtDeliveryAddress: s.deliveryAddressList[event.index].toString(),
        txtDeliveryQuantity: s.deliveryQuantityList[event.index].toString(),
      ));
    });

    // ────────────────────────────────────────────────────
    // TOGGLE
    // ────────────────────────────────────────────────────
    on<ToggleProductView>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      emit(s.copyWith(visibleProductview: !s.visibleProductview));
    });

    on<ToggleFW1>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      emit(s.copyWith(visibleFW1: !s.visibleFW1));
    });

    on<ToggleFW2>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      emit(s.copyWith(visibleFW2: !s.visibleFW2));
    });

    on<ToggleFW3>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      emit(s.copyWith(visibleFW3: !s.visibleFW3));
    });

    on<BillTypeChanged>((event, emit) async {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      await OnlineApi.MaxSaleOrderNo(context, event.value);
      emit(s.copyWith(
        dropdownValue: event.value,
        txtJobNo: objfun.MaxSaleOrderNum,
      ));
    });

    // ────────────────────────────────────────────────────
    // SAVE
    // ────────────────────────────────────────────────────
    on<SaveSalesOrderEvent>((event, emit) async {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;

      if (s.txtCustomer.isEmpty) { emit(s.copyWith(savedMessage: 'Enter Customer Name')); return; }
      if (s.txtJobType.isEmpty) { emit(s.copyWith(savedMessage: 'Enter Job Type')); return; }
      if (s.productViewList.isEmpty) { emit(s.copyWith(savedMessage: 'Add Product Details')); return; }

      emit(s.copyWith(progress: false));

      try {
        final master = [_buildMasterPayload(s)];
        final header = {'Content-Type': 'application/json; charset=UTF-8'};

        final resultData = await objfun.apiAllinoneSelectArray(
          "${objfun.apiInsertSalesOrder}?Comid=${objfun.Comid}",
          master, header, context,
        );

        if (resultData != "") {
          final value = ResponseViewModel.fromJson(resultData);
          if (value.IsSuccess == true) {
            if (s.enquiryId != 0) {
              await _confirmEnquiry(s.enquiryId);
            }
            emit(s.copyWith(progress: true, isSaved: true, savedMessage: 'Created Successfully'));
          } else {
            emit(s.copyWith(progress: true, savedMessage: value.Message));
          }
        }
      } catch (e) {
        emit(s.copyWith(progress: true, savedMessage: e.toString()));
      }
    });
  }

  // ════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════

  Map<String, bool> _buildPermissions() {
    const allFields = [
      "txtCustomer", "txtJobType", "txtJobStatus", "txtRemarks", "txtDoDescription",
      "ProductViewList", "txtCommodityType", "txtOrigin", "txtWeight", "txtQuantity",
      "txtTruckSize", "txtAWBNo", "txtBLCopy", "txtCargo", "txtPTWNo",
      "dtpLETAdate", "dtpLETBdate", "dtpLETDdate", "txtLAgentCompany", "txtLAgentName",
      "txtLSCN", "dtpFlightTimedate", "txtLoadingVessel", "txtLPort", "txtLVesselType",
      "cmbBillType", "dtpOETAdate", "dtpOETDdate", "txtOAgentCompany", "txtOAgentName",
      "txtOSCN", "txtOffVessel", "txtOPort", "txtOVesselType", "dtpPickUpdate",
      "dtpDeliverydate", "dtpWHEntrydate", "dtpWHExitdate", "txtOrigin", "txtDestination",
      "txtPickUpAddress", "txtPickUpQuantity", "txtDeliveryAddress", "txtDeliveryQuantity",
      "txtWarehouseAddress", "dtpFW1date", "txtSmk1", "txtENRef1", "txtSealByEmp1",
      "txtBreakByEmp1", "txtForwarding1S1", "txtForwarding1S2", "dropdownValueFW2",
      "dtpFW2date", "txtENRef2", "txtExRef2", "txtSealByEmp2", "txtBreakByEmp2",
      "txtForwarding2S1", "txtForwarding2S2", "dropdownValueFW3", "dtpFW3date",
      "txtSmk3", "txtENRef3", "txtSealByEmp3", "txtBreakByEmp3", "txtForwarding3S2",
      "dropdownValueZB1", "txtZBRef1", "dropdownValueZB2", "txtZBRef2",
      "txtBoardingOfficer1", "txtBoardingOfficer2", "txtAmount1", "txtAmount2",
      "txtPortCharges", "chkLETA", "chkOETA", "chkLETB", "chkOETB", "chkLETD",
      "chkOETD", "chkPickup", "chkDelivery", "chkWareHouseEntry", "chkWareHouseExit",
      "chkFlightTime", "SAVE", "VIEW", "addProduct", "dropdownValueFW1",
      "dropdownValueFW2", "checkBoxValueFW2", "txtSmk2", "dropdownValueFW3",
      "dropdownValueZB1", "dropdownValueZB2", "checkBoxValueFW1", "checkBoxValueFW3",
    ];

    const restrictedIds = [138, 50, 127, 35, 75, 38, 68, 128, 100, 117, 121];

    if (!restrictedIds.contains(objfun.EmpRefId)) {
      return {for (var f in allFields) f: true};
    }

    final map = {for (var f in allFields) f: false};
    for (var f in ["txtBoardingOfficer1", "txtBoardingOfficer2", "txtAmount1", "txtAmount2", "SAVE", "VIEW"]) {
      map[f] = true;
    }
    return map;
  }

  SalesOrderAddLoaded _applyVisibility(SalesOrderAddLoaded s) {
    bool offVessel = false, loadingVessel = false, lETA = false, flightTime = false;
    bool lETB = false, lETD = false, awbNo = false, blCopy = false;
    bool forwarding = false, origin = false, destination = false, zb = false;
    bool oETA = false, oETB = false, oETD = false, oShippingAgent = false;
    bool oAgentName = false, oScn = false, lScn = false, lShipping = false;
    bool lAgentName = false, lVesselType = false, oVesselType = false;
    bool oPort = false, lPort = false;

    for (var item in objfun.JobTypeDetailsList) {
      switch (item.Description) {
        case "OFF VESSEL NAME": offVessel = true; break;
        case "LOAD VESSEL NAME": loadingVessel = true; break;
        case "L ETA": lETA = true; break;
        case "L ETB": lETB = true; break;
        case "L ETD": lETD = true; break;
        case "AWB NO": awbNo = true; break;
        case "BL COPY": blCopy = true; break;
        case "FORWARDING": forwarding = true; break;
        case "ORIGIN": origin = true; break;
        case "DESTINATION": destination = true; break;
        case "ZB": zb = true; break;
        case "O ETA": oETA = true; break;
        case "O ETB": oETB = true; break;
        case "O ETD": oETD = true; break;
        case "O AGENT": oAgentName = true; break;
        case "O AGENT COMPANY": oShippingAgent = true; break;
        case "O SCN": oScn = true; break;
        case "L SCN": lScn = true; break;
        case "L AGENT COMPANY": lShipping = true; break;
        case "L AGENT": lAgentName = true; break;
        case "L VESSEL TYPE": lVesselType = true; break;
        case "O VESSEL TYPE": oVesselType = true; break;
        case "O PORT": oPort = true; break;
        case "L PORT": lPort = true; break;
      }
    }

    final isGC = s.txtJobType == "GENARAL CARGO";

    return s.copyWith(
      visibleOffVessel: offVessel,
      visibleLoadingVessel: loadingVessel,
      visibleLETA: lETA,
      visibleFlightTime: flightTime,
      visibleLETB: lETB,
      visibleLETD: lETD,
      visibleAWBNo: awbNo,
      visibleBLCopy: blCopy,
      visibleFORWARDING: forwarding,
      visibleOrigin: isGC ? false : origin,
      visibleDestination: isGC ? false : destination,
      visibleZB: zb,
      visibleOETA: oETA,
      visibleOETB: oETB,
      visibleOETD: oETD,
      visibleOShippingAgent: oShippingAgent,
      visibleOAgentName: oAgentName,
      visibleOScn: oScn,
      visibleLScn: lScn,
      visibleLShippingAgent: lShipping,
      visibleLAgentName: lAgentName,
      visibleLVesselType: lVesselType,
      visibleOVesselType: oVesselType,
      visibleOPort: oPort,
      visibleLPort: lPort,
      visibleGC: isGC,
    );
  }

  SalesOrderAddLoaded _recalculate(SalesOrderAddLoaded s) {
    final gst = double.tryParse(s.txtProductGst) ?? 0.0;
    final qty = double.tryParse(s.txtProductQty) ?? 0.0;
    final rate = double.tryParse(s.txtProductSaleRate) ?? 0.0;
    final netAmount = qty * rate;
    final gstAmt = gst != 0 ? (netAmount * gst) / 100 : 0.0;
    final amt = gst != 0 ? netAmount + gstAmt : netAmount;

    var producttotal = 0.0;
    var taxTotal = 0.0;
    for (var p in s.productViewList) {
      producttotal += p.Amount;
      taxTotal += p.TaxAmount;
    }

    final grossAmt = producttotal + taxTotal;
    final rounded = grossAmt.roundToDouble();
    final coinage = double.parse((rounded - grossAmt).abs().toStringAsFixed(2));

    return s.copyWith(
      txtProductAmount: amt.toStringAsFixed(2),
      totalAmount: double.parse(producttotal.toStringAsFixed(2)),
      taxAmount: taxTotal,
      coinage: coinage,
      actualAmount: double.parse((producttotal * s.currencyValue).toStringAsFixed(2)),
    );
  }

  SaleEditDetailModel _buildProduct(SalesOrderAddLoaded s) {
    return SaleEditDetailModel(
      s.txtProductDescription.isNotEmpty ? 0 : 0,
      0, 0,
      s.txtProductDescription.isNotEmpty ? 0 : 0,
      0.0, 0.0,
      double.tryParse(s.txtProductQty) ?? 0.0,
      0.0, 0.0, 0.0,
      double.tryParse(s.txtProductGst) ?? 0.0,
      0.0,
      double.tryParse(s.txtProductSaleRate) ?? 0.0,
      0.0,
      double.tryParse(s.txtProductAmount) ?? 0.0,
      s.txtProductCode,
      s.txtProductDescription,
      '',
      double.tryParse(s.txtProductAmount) ?? 0.0,
      s.currencyValue,
    );
  }

  SalesOrderAddLoaded _updateField(SalesOrderAddLoaded s, String field, String value) {
    switch (field) {
      case 'txtRemarks': return s.copyWith(txtRemarks: value);
      case 'txtDoDescription': return s.copyWith(txtDoDescription: value);
      case 'txtWeight': return s.copyWith(txtWeight: value);
      case 'txtQuantity': return s.copyWith(txtQuantity: value);
      case 'txtTruckSize': return s.copyWith(txtTruckSize: value);
      case 'txtAWBNo': return s.copyWith(txtAWBNo: value);
      case 'txtBLCopy': return s.copyWith(txtBLCopy: value);
      case 'txtPTWNo': return s.copyWith(txtPTWNo: value);
      case 'txtSmk1': return s.copyWith(txtSmk1: value);
      case 'txtSmk2': return s.copyWith(txtSmk2: value);
      case 'txtSmk3': return s.copyWith(txtSmk3: value);
      case 'txtENRef1': return s.copyWith(txtENRef1: value);
      case 'txtENRef2': return s.copyWith(txtENRef2: value);
      case 'txtENRef3': return s.copyWith(txtENRef3: value);
      case 'txtExRef1': return s.copyWith(txtExRef1: value);
      case 'txtExRef2': return s.copyWith(txtExRef2: value);
      case 'txtExRef3': return s.copyWith(txtExRef3: value);
      case 'txtZBRef1': return s.copyWith(txtZBRef1: value);
      case 'txtZBRef2': return s.copyWith(txtZBRef2: value);
      case 'txtAmount1': return s.copyWith(txtAmount1: value);
      case 'txtAmount2': return s.copyWith(txtAmount2: value);
      case 'txtPortChargeRef1': return s.copyWith(txtPortChargeRef1: value);
      case 'txtPortCharges': return s.copyWith(txtPortCharges: value);
      case 'txtForwarding1S1': return s.copyWith(txtForwarding1S1: value);
      case 'txtForwarding1S2': return s.copyWith(txtForwarding1S2: value);
      case 'txtForwarding2S1': return s.copyWith(txtForwarding2S1: value);
      case 'txtForwarding2S2': return s.copyWith(txtForwarding2S2: value);
      case 'txtForwarding3S1': return s.copyWith(txtForwarding3S1: value);
      case 'txtForwarding3S2': return s.copyWith(txtForwarding3S2: value);
      case 'txtLoadingVessel': return s.copyWith(txtLoadingVessel: value);
      case 'txtOffVessel': return s.copyWith(txtOffVessel: value);
      case 'txtOSCN': return s.copyWith(txtOSCN: value);
      case 'txtLSCN': return s.copyWith(txtLSCN: value);
      case 'txtProductQty': return _recalculate(s.copyWith(txtProductQty: value));
      case 'txtProductSaleRate': return _recalculate(s.copyWith(txtProductSaleRate: value));
      case 'txtProductGst': return _recalculate(s.copyWith(txtProductGst: value));
      case 'txtPickUpAddress': return s.copyWith(txtPickUpAddress: value);
      case 'txtPickUpQuantity': return s.copyWith(txtPickUpQuantity: value);
      case 'txtDeliveryAddress': return s.copyWith(txtDeliveryAddress: value);
      case 'txtDeliveryQuantity': return s.copyWith(txtDeliveryQuantity: value);
      case 'txtOrigin': return s.copyWith(txtOrigin: value);
      case 'txtDestination': return s.copyWith(txtDestination: value);
      default: return s;
    }
  }

  SalesOrderAddLoaded _updateDropdown(SalesOrderAddLoaded s, String field, String? value) {
    switch (field) {
      case 'dropdownValueFW1': return s.copyWith(dropdownValueFW1: value);
      case 'dropdownValueFW2': return s.copyWith(dropdownValueFW2: value);
      case 'dropdownValueFW3': return s.copyWith(dropdownValueFW3: value);
      case 'dropdownValueZB1': return s.copyWith(dropdownValueZB1: value);
      case 'dropdownValueZB2': return s.copyWith(dropdownValueZB2: value);
      case 'dropdownValueTruckSize':
        return s.copyWith(dropdownValueTruckSize: value, txtTruckSize: value ?? '');
      default: return s;
    }
  }

  SalesOrderAddLoaded _updateCheckbox(SalesOrderAddLoaded s, String field, bool value) {
    final now = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
    switch (field) {
      case 'checkBoxValueLETA': return s.copyWith(checkBoxValueLETA: value, dtpLETAdate: value ? s.dtpLETAdate : now);
      case 'checkBoxValueLETB': return s.copyWith(checkBoxValueLETB: value, dtpLETBdate: value ? s.dtpLETBdate : now);
      case 'checkBoxValueLETD': return s.copyWith(checkBoxValueLETD: value, dtpLETDdate: value ? s.dtpLETDdate : now);
      case 'checkBoxValueFlightTime': return s.copyWith(checkBoxValueFlightTime: value, dtpFlightTimedate: value ? s.dtpFlightTimedate : now);
      case 'checkBoxValueOETA': return s.copyWith(checkBoxValueOETA: value, dtpOETAdate: value ? s.dtpOETAdate : now);
      case 'checkBoxValueOETB': return s.copyWith(checkBoxValueOETB: value, dtpOETBdate: value ? s.dtpOETBdate : now);
      case 'checkBoxValueOETD': return s.copyWith(checkBoxValueOETD: value, dtpOETDdate: value ? s.dtpOETDdate : now);
      case 'checkBoxValuePickUp': return s.copyWith(checkBoxValuePickUp: value, dtpPickUpdate: value ? s.dtpPickUpdate : now);
      case 'checkBoxValueDelivery': return s.copyWith(checkBoxValueDelivery: value, dtpDeliverydate: value ? s.dtpDeliverydate : now);
      case 'checkBoxValueWHEntry': return s.copyWith(checkBoxValueWHEntry: value, dtpWHEntrydate: value ? s.dtpWHEntrydate : now);
      case 'checkBoxValueWHExit': return s.copyWith(checkBoxValueWHExit: value, dtpWHExitdate: value ? s.dtpWHExitdate : now);
      case 'checkBoxValueFW1': return s.copyWith(checkBoxValueFW1: value);
      case 'checkBoxValueFW2': return s.copyWith(checkBoxValueFW2: value);
      case 'checkBoxValueFW3': return s.copyWith(checkBoxValueFW3: value);
      default: return s;
    }
  }

  SalesOrderAddLoaded _updateDateField(SalesOrderAddLoaded s, String field, String value) {
    switch (field) {
      case 'dtpSaleOrderdate': return s.copyWith(dtpSaleOrderdate: value);
      case 'dtpLETAdate': return s.copyWith(dtpLETAdate: value);
      case 'dtpLETBdate': return s.copyWith(dtpLETBdate: value);
      case 'dtpLETDdate': return s.copyWith(dtpLETDdate: value);
      case 'dtpFlightTimedate': return s.copyWith(dtpFlightTimedate: value);
      case 'dtpOETAdate': return s.copyWith(dtpOETAdate: value);
      case 'dtpOETBdate': return s.copyWith(dtpOETBdate: value);
      case 'dtpOETDdate': return s.copyWith(dtpOETDdate: value);
      case 'dtpPickUpdate': return s.copyWith(dtpPickUpdate: value);
      case 'dtpDeliverydate': return s.copyWith(dtpDeliverydate: value);
      case 'dtpWHEntrydate': return s.copyWith(dtpWHEntrydate: value);
      case 'dtpWHExitdate': return s.copyWith(dtpWHExitdate: value);
      case 'dtpFW1date': return s.copyWith(dtpFW1date: value);
      case 'dtpFW2date': return s.copyWith(dtpFW2date: value);
      case 'dtpFW3date': return s.copyWith(dtpFW3date: value);
      default: return s;
    }
  }

  Future<SalesOrderAddLoaded> _loadMasterData(
      SalesOrderAddLoaded base,
      List<dynamic> master,
      List<SaleEditDetailModel>? details,
      bool isEnquiry,
      ) async {
    final m = master[0];
    final now = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());

    await OnlineApi.SelectCustomer(context);
    await OnlineApi.SelectJobType(context);
    if (m["JobMasterRefId"] != null) {
      await OnlineApi.SelectAllJobStatus(context, m["JobMasterRefId"]);
    }
    if (m["AgentCompanyRefId"] != null) {
      await OnlineApi.SelectAgentAll(context, m["AgentCompanyRefId"]);
    }
    await OnlineApi.loadCustomerCurrency(context, m["CustomerRefId"]);

    String _safeStr(String? v) => v ?? '';
    String _safeNum(dynamic v) => v != null ? v.toString() : '';
    String _parseDate(dynamic v, String fmt) {
      if (v == null) return now;
      return DateFormat(fmt).format(DateTime.parse(v.toString()));
    }

    var result = base.copyWith(
      editId: isEnquiry ? 0 : (m["Id"] ?? 0),
      enquiryId: isEnquiry ? (m["Id"] ?? 0) : 0,
      productViewList: details ?? [],
      currencyValue: objfun.CustomerCurrencyValue,
      custId: m["CustomerRefId"] ?? 0,
      jobTypeId: m["JobMasterRefId"] ?? 0,
      lAgentCompanyId: m["AgentCompanyRefId"] ?? 0,
      lAgentId: m["AgentMasterRefId"] ?? 0,
      oAgentCompanyId: m["OAgentCompanyRefId"] ?? 0,
      oAgentId: m["OAgentMasterRefId"] ?? 0,
      originId: m["OriginRefId"] ?? 0,
      destinationId: m["DestinationRefId"] ?? 0,
      sealEmpId1: m["SealbyRefid"] ?? 0,
      sealEmpId2: m["SealbyRefid2"] ?? 0,
      sealEmpId3: m["SealbyRefid3"] ?? 0,
      breakEmpId1: m["SealbreakbyRefid"] ?? 0,
      breakEmpId2: m["SealbreakbyRefid2"] ?? 0,
      breakEmpId3: m["SealbreakbyRefid3"] ?? 0,
      boardOfficerId1: m["BoardingOfficerRefid"] ?? 0,
      boardOfficerId2: m["BoardingOfficer1Refid"] ?? 0,
      statusId: m["JStatus"] ?? 0,
      disabledBillType: true,
      disabledAmount1: true,
      disabledAmount2: true,
      dropdownValue: m["BillType"] ?? 'MY',
      dropdownValueFW1: m["Forwarding"] != "" ? m["Forwarding"] : null,
      dropdownValueFW2: m["Forwarding2"] != "" ? m["Forwarding2"] : null,
      dropdownValueFW3: m["Forwarding3"] != "" ? m["Forwarding3"] : null,
      dropdownValueZB1: m["Zb"] != "" ? m["Zb"] : null,
      dropdownValueZB2: m["Zb2"] != "" ? m["Zb2"] : null,
      dropdownValueTruckSize: m["TruckSize"] != null && m["TruckSize"] != "" ? m["TruckSize"].toString() : null,
      dtpSaleOrderdate: _parseDate(m["SaleDate"], "yyyy-MM-dd"),
      dtpLETAdate: m["ETA"] != null ? _parseDate(m["ETA"], "yyyy-MM-dd HH:mm:ss") : now,
      dtpLETBdate: m["ETB"] != null ? _parseDate(m["ETB"], "yyyy-MM-dd HH:mm:ss") : now,
      dtpLETDdate: m["ETD"] != null ? _parseDate(m["ETD"], "yyyy-MM-dd HH:mm:ss") : now,
      dtpFlightTimedate: m["FlighTime"] != null ? _parseDate(m["FlighTime"], "yyyy-MM-dd HH:mm:ss") : now,
      dtpOETAdate: m["OETA"] != null ? _parseDate(m["OETA"], "yyyy-MM-dd HH:mm:ss") : now,
      dtpOETBdate: m["OETB"] != null ? _parseDate(m["OETB"], "yyyy-MM-dd HH:mm:ss") : now,
      dtpOETDdate: m["OETD"] != null ? _parseDate(m["OETD"], "yyyy-MM-dd HH:mm:ss") : now,
      dtpPickUpdate: m["PickupDate"] != null ? _parseDate(m["PickupDate"], "yyyy-MM-dd HH:mm:ss") : now,
      dtpDeliverydate: m["DeliveryDate"] != null ? _parseDate(m["DeliveryDate"], "yyyy-MM-dd HH:mm:ss") : now,
      dtpWHEntrydate: m["WareHouseEnterDate"] != null ? _parseDate(m["WareHouseEnterDate"], "yyyy-MM-dd HH:mm:ss") : now,
      dtpWHExitdate: m["WareHouseExitDate"] != null ? _parseDate(m["WareHouseExitDate"], "yyyy-MM-dd HH:mm:ss") : now,
      dtpFW1date: m["ForwardingDate"] != null ? _parseDate(m["ForwardingDate"], "yyyy-MM-dd HH:mm:ss") : now,
      dtpFW2date: m["Forwarding2Date"] != null ? _parseDate(m["Forwarding2Date"], "yyyy-MM-dd HH:mm:ss") : now,
      dtpFW3date: m["Forwarding3Date"] != null ? _parseDate(m["Forwarding3Date"], "yyyy-MM-dd HH:mm:ss") : now,
      checkBoxValueLETA: m["ETA"] != null,
      checkBoxValueLETB: m["ETB"] != null,
      checkBoxValueLETD: m["ETD"] != null,
      checkBoxValueFlightTime: m["FlighTime"] != null,
      checkBoxValueOETA: m["OETA"] != null,
      checkBoxValueOETB: m["OETB"] != null,
      checkBoxValueOETD: m["OETD"] != null,
      checkBoxValuePickUp: m["PickupDate"] != null,
      checkBoxValueDelivery: m["DeliveryDate"] != null,
      checkBoxValueWHEntry: m["WareHouseEnterDate"] != null,
      checkBoxValueWHExit: m["WareHouseExitDate"] != null,
      checkBoxValueFW1: m["ForwardingDate"] != null,
      checkBoxValueFW2: m["Forwarding2Date"] != null,
      checkBoxValueFW3: m["Forwarding3Date"] != null,
      txtJobNo: isEnquiry ? objfun.MaxSaleOrderNum : _safeNum(m["CNumber"]),
      txtCustomer: _getFromList(objfun.CustomerList, m["CustomerRefId"], (e) => e.AccountName),
      txtJobType: _getFromList(objfun.JobTypeList, m["JobMasterRefId"], (e) => e.Name),
      txtJobStatus: _getFromStatusList(m["JStatus"]),
      txtSealByEmp1: _getEmpName(m["SealbyRefid"]),
      txtSealByEmp2: _getEmpName(m["SealbyRefid2"]),
      txtSealByEmp3: _getEmpName(m["SealbyRefid3"]),
      txtBreakByEmp1: _getEmpName(m["SealbreakbyRefid"]),
      txtBreakByEmp2: _getEmpName(m["SealbreakbyRefid2"]),
      txtBreakByEmp3: _getEmpName(m["SealbreakbyRefid3"]),
      txtBoardingOfficer1: _getEmpName(m["BoardingOfficerRefid"]),
      txtBoardingOfficer2: _getEmpName(m["BoardingOfficer1Refid"]),
      txtLAgentCompany: _getFromAgentCompany(m["AgentCompanyRefId"]),
      txtLAgentName: _getFromAgentAll(m["AgentMasterRefId"]),
      txtOAgentCompany: _getFromAgentCompany(m["OAgentCompanyRefId"]),
      txtOAgentName: _getFromAgentAll(m["OAgentMasterRefId"]),
      txtDoDescription: _safeStr(m["DODescription"]),
      txtTruckSize: _safeNum(m["TruckSize"]),
      txtRemarks: _safeStr(m["Remarks"]),
      txtOffVessel: _safeStr(m["Offvesselname"]),
      txtLoadingVessel: _safeStr(m["Loadingvesselname"]),
      txtLPort: _safeStr(m["SPort"]),
      txtOPort: _safeStr(m["OPort"]),
      txtSmk1: _safeStr(m["ForwardingSMKNo"]),
      txtSmk2: _safeStr(m["ForwardingSMKNo2"]),
      txtSmk3: _safeStr(m["ForwardingSMKNo3"]),
      txtAWBNo: _safeStr(m["AWBNo"]),
      txtBLCopy: _safeStr(m["BLCopy"]),
      txtOSCN: _safeStr(m["SCN"]),
      txtLSCN: _safeStr(m["LSCN"]),
      txtLVesselType: _safeStr(m["Vessel"]),
      txtOVesselType: _safeStr(m["OVessel"]),
      txtCommodityType: _safeStr(m["Commodity"]),
      txtCargo: _safeStr(m["Cargo"]),
      txtWeight: _safeNum(m["TotalWeight"]),
      txtQuantity: _safeNum(m["Quantity"]),
      txtOrigin: _safeStr(m["Origin"]),
      txtDestination: _safeStr(m["Destination"]),
      txtPTWNo: _safeStr(m["PTW"]),
      txtENRef1: _safeStr(m["ForwardingEnterRef"]),
      txtENRef2: _safeStr(m["ForwardingEnterRef2"]),
      txtENRef3: _safeStr(m["ForwardingEnterRef3"]),
      txtExRef1: _safeStr(m["ForwardingExitRef"]),
      txtExRef2: _safeStr(m["ForwardingExitRef2"]),
      txtExRef3: _safeStr(m["ForwardingExitRef3"]),
      txtPortChargeRef1: _safeStr(m["PortChargesRef"]),
      txtPortCharges: _safeNum(m["PortCharges"]),
      txtAmount1: _safeNum(m["BoardingAmount"]),
      txtAmount2: _safeNum(m["BoardingAmount1"]),
      txtZBRef1: _safeStr(m["ZbRef"]),
      txtZBRef2: _safeStr(m["ZbRef2"]),
      txtWarehouseAddress: _safeStr(m["WareHouseAddress"]),
      txtForwarding1S1: _safeStr(m["Forwarding1S1"]),
      txtForwarding1S2: _safeStr(m["Forwarding1S2"]),
      txtForwarding2S1: _safeStr(m["Forwarding2S1"]),
      txtForwarding2S2: _safeStr(m["Forwarding2S2"]),
      txtForwarding3S1: _safeStr(m["Forwarding3S1"]),
      txtForwarding3S2: _safeStr(m["Forwarding3S2"]),
      pickUpAddressList: _splitAddress(m["PickupAddress"]),
      pickUpQuantityList: _splitAddress(m["pickupQuantityList"]),
      deliveryAddressList: _splitAddress(m["DeliveryAddress"]),
      deliveryQuantityList: _splitAddress(m["DeliveryQuantityList"]),
      txtPickUpAddress: _firstAddress(m["PickupAddress"]),
      txtDeliveryAddress: _firstAddress(m["DeliveryAddress"]),
    );

    return _applyVisibility(result);
  }

  String _getFromList<T>(List<T> list, dynamic id, String Function(T) getName) {
    if (id == null || id == 0) return '';
    try {
      final item = (list as List).firstWhere((e) => (e as dynamic).Id == id);
      return getName(item as T);
    } catch (_) { return ''; }
  }

  String _getFromStatusList(dynamic id) {
    if (id == null || id == 0) return '';
    try {
      return objfun.JobAllStatusList.firstWhere((e) => e.Status == id).StatusName;
    } catch (_) { return ''; }
  }

  String _getEmpName(dynamic id) {
    if (id == null || id == 0) return '';
    try {
      return objfun.EmployeeList.firstWhere((e) => e.Id == id).AccountName;
    } catch (_) { return ''; }
  }

  String _getFromAgentCompany(dynamic id) {
    if (id == null || id == 0) return '';
    try {
      return objfun.AgentCompanyList.firstWhere((e) => e.Id == id).Name;
    } catch (_) { return ''; }
  }

  String _getFromAgentAll(dynamic id) {
    if (id == null || id == 0) return '';
    try {
      return objfun.AgentAllList.firstWhere((e) => e.Id == id).AgentName;
    } catch (_) { return ''; }
  }

  List<dynamic> _splitAddress(dynamic val) {
    if (val == null || val.toString().isEmpty) return [];
    final str = val.toString();
    return str.contains('{@}') ? str.split('{@}') : [str];
  }

  String _firstAddress(dynamic val) {
    if (val == null || val.toString().isEmpty) return '';
    final str = val.toString();
    return str.contains('{@}') ? str.split('{@}').first : str;
  }

  Map<String, dynamic> _buildMasterPayload(SalesOrderAddLoaded s) {
    return {
      'Id': s.editId,
      'CompanyRefId': objfun.Comid,
      'EmployeeRefId': objfun.EmpRefId == 0 ? null : objfun.EmpRefId,
      'AgentCompanyRefId': s.lAgentCompanyId == 0 ? null : s.lAgentCompanyId,
      'AgentMasterRefId': s.lAgentId == 0 ? null : s.lAgentId,
      'OAgentCompanyRefId': s.oAgentCompanyId == 0 ? null : s.oAgentCompanyId,
      'OAgentMasterRefId': s.oAgentId == 0 ? null : s.oAgentId,
      'CustomerRefId': s.custId,
      'JobMasterRefId': s.jobTypeId,
      'SaleDate': DateTime.parse(s.dtpSaleOrderdate).toIso8601String(),
      'BillType': s.dropdownValue,
      'Remarks': s.txtRemarks,
      'DODescription': s.txtDoDescription,
      'Amount': s.totalAmount,
      'GrossAmount': s.totalAmount,
      'TaxAmount': s.taxAmount,
      'Coinage': s.coinage,
      'Offvesselname': s.txtOffVessel,
      'Loadingvesselname': s.txtLoadingVessel,
      'SPort': s.txtLPort,
      'OPort': s.txtOPort,
      'Vessel': s.txtLVesselType,
      'OVessel': s.txtOVesselType,
      'Commodity': s.txtCommodityType,
      'Cargo': s.txtCargo,
      'ETA': s.checkBoxValueLETA ? DateTime.parse(s.dtpLETAdate).toIso8601String() : null,
      'FlighTime': s.checkBoxValueFlightTime ? DateTime.parse(s.dtpFlightTimedate).toIso8601String() : null,
      'ETB': s.checkBoxValueLETB ? DateTime.parse(s.dtpLETBdate).toIso8601String() : null,
      'ETD': s.checkBoxValueLETD ? DateTime.parse(s.dtpLETDdate).toIso8601String() : null,
      'OETA': s.checkBoxValueOETA ? DateTime.parse(s.dtpOETAdate).toIso8601String() : null,
      'OETB': s.checkBoxValueOETB ? DateTime.parse(s.dtpOETBdate).toIso8601String() : null,
      'OETD': s.checkBoxValueOETD ? DateTime.parse(s.dtpOETDdate).toIso8601String() : null,
      'AWBNo': s.txtAWBNo,
      'BLCopy': s.txtBLCopy,
      'Quantity': s.txtQuantity,
      'TotalWeight': s.txtWeight,
      'TruckSize': s.txtTruckSize,
      'JStatus': s.statusId == 0 ? null : s.statusId,
      'SealbyRefid': s.sealEmpId1,
      'SealbreakbyRefid': s.breakEmpId1,
      'SealbyRefid2': s.sealEmpId2,
      'SealbreakbyRefid2': s.breakEmpId2,
      'SealbyRefid3': s.sealEmpId3,
      'SealbreakbyRefid3': s.breakEmpId3,
      'BoardingOfficerRefid': s.boardOfficerId1,
      'BoardingOfficer1Refid': s.boardOfficerId2,
      'BoardingAmount': s.txtAmount1,
      'BoardingAmount1': s.txtAmount2,
      'ForwardingEnterRef': s.txtENRef1,
      'ForwardingExitRef': s.txtExRef1,
      'ForwardingEnterRef2': s.txtENRef2,
      'ForwardingExitRef2': s.txtExRef2,
      'ForwardingEnterRef3': s.txtENRef3,
      'ForwardingExitRef3': s.txtExRef3,
      'ForwardingSMKNo': s.txtSmk1,
      'ForwardingSMKNo2': s.txtSmk2,
      'ForwardingSMKNo3': s.txtSmk3,
      'PortChargesRef': s.txtPortChargeRef1,
      'PortCharges': s.txtPortCharges,
      'OriginRefId': s.originId,
      'DestinationRefId': s.destinationId,
      'PickupDate': s.checkBoxValuePickUp ? DateTime.parse(s.dtpPickUpdate).toIso8601String() : null,
      'DeliveryDate': s.checkBoxValueDelivery ? DateTime.parse(s.dtpDeliverydate).toIso8601String() : null,
      'WareHouseEnterDate': s.checkBoxValueWHEntry ? DateTime.parse(s.dtpWHEntrydate).toIso8601String() : null,
      'WareHouseExitDate': s.checkBoxValueWHExit ? DateTime.parse(s.dtpWHExitdate).toIso8601String() : null,
      'WareHouseAddress': s.txtWarehouseAddress,
      'PickupAddress': s.pickUpAddressList.length <= 1 ? s.txtPickUpAddress : s.pickUpAddressList.join('{@}'),
      'pickupQuantitylist': s.pickUpQuantityList.length <= 1 ? s.txtPickUpQuantity : s.pickUpQuantityList.join('{@}'),
      'DeliveryAddress': s.deliveryAddressList.length <= 1 ? s.txtDeliveryAddress : s.deliveryAddressList.join('{@}'),
      'DeliveryQuantitylist': s.deliveryQuantityList.length <= 1 ? s.txtDeliveryQuantity : s.deliveryQuantityList.join('{@}'),
      'Forwarding': s.dropdownValueFW1,
      'Forwarding2': s.dropdownValueFW2,
      'Forwarding3': s.dropdownValueFW3,
      'Origin': s.txtOrigin,
      'Destination': s.txtDestination,
      'SCN': s.txtOSCN,
      'LSCN': s.txtLSCN,
      'Zb': s.dropdownValueZB1,
      'PTW': s.txtPTWNo,
      'Zb2': s.dropdownValueZB2,
      'ZbRef': s.txtZBRef1,
      'ZbRef2': s.txtZBRef2,
      'Forwarding1S1': s.txtForwarding1S1,
      'Forwarding1S2': s.txtForwarding1S2,
      'Forwarding2S1': s.txtForwarding2S1,
      'Forwarding2S2': s.txtForwarding2S2,
      'Forwarding3S1': s.txtForwarding3S1,
      'Forwarding3S2': s.txtForwarding3S2,
      'CurrencyValue': s.currencyValue,
      'ActualNetAmount': s.actualAmount,
      'ForwardingDate': s.checkBoxValueFW1 ? DateTime.parse(s.dtpFW1date).toIso8601String() : null,
      'Forwarding2Date': s.checkBoxValueFW2 ? DateTime.parse(s.dtpFW2date).toIso8601String() : null,
      'Forwarding3Date': s.checkBoxValueFW3 ? DateTime.parse(s.dtpFW3date).toIso8601String() : null,
      'SaleDetails': s.productViewList,
    };
  }

  Future<void> _confirmEnquiry(int id) async {
    final header = {'Content-Type': 'application/json; charset=UTF-8'};
    await objfun.apiAllinoneSelectArray(
      "${objfun.apiUpdateEnquiryMaster}$id&Comid=${objfun.Comid}&StatusName=CONFIRMED",
      null, header, context,
    );
  }
}