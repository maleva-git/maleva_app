import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/features/transaction/salesorder/add/bloc/salesorderadd_event.dart';
import 'package:maleva/features/transaction/salesorder/add/bloc/salesorderadd_state.dart';
import 'package:maleva/features/transaction/salesorder/add/bloc/sale_order_save_body.dart';
import 'package:maleva/features/transaction/salesorder/add/data/salesorderadd_repository.dart';
import 'package:maleva/core/models/shared/sale_edit_detail_model.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/sale_order/sale_order_api.dart';
import 'package:maleva/core/enquiry/enquiry_api.dart';
import 'package:maleva/core/logging/app_logger.dart';
import 'package:maleva/core/utils/json_read.dart';
import 'package:maleva/core/vessel_master/vessel_master_api.dart';
import 'package:maleva/core/vessel_master/vessel_master_models.dart';
import 'package:maleva/features/transaction/salesorder/add/bloc/save_date_checks.dart';
import 'package:maleva/features/transaction/salesorder/add/bloc/vessel_pick.dart';

class SalesOrderAddBloc extends Bloc<SalesOrderAddEvent, SalesOrderAddState> {
  final BuildContext context;
  final SalesOrderAddRepository _repository;
  final SaleOrderApi _saleOrders;
  final VesselMasterApi? _vesselMastersGiven;

  /// Read on first use, so the form opens even where the vessel API is not registered.
  VesselMasterApi get _vesselMasters => _vesselMastersGiven ?? sl<VesselMasterApi>();

  static const List<String> _billType = ['MY', 'TR'];

  static const List<String> _forwardingNo = ['K1', 'K2', 'K3', 'K8'];
  static const List<String> _truckSizeList = ['1 Tonner', '3 Tonner', '5 Tonner', '10 Tonner', '40 FT Truck'];
  static const List<String> _zbNo = ['ZB1', 'ZB2'];

  static List<String> get billType => _billType;
  static List<String> get forwardingNo => _forwardingNo;
  static List<String> get truckSizeList => _truckSizeList;
  static List<String> get zbNo => _zbNo;

  SalesOrderAddBloc(this.context, this._repository, {SaleOrderApi? saleOrders, VesselMasterApi? vesselMasters})
      : _saleOrders = saleOrders ?? sl<SaleOrderApi>(),
        _vesselMastersGiven = vesselMasters,
        super(SalesOrderAddInitial()) {

    on<StartupSalesOrderAdd>((event, emit) async {
      emit(SalesOrderAddLoading());
      try {
        final now = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
        final today = DateFormat("yyyy-MM-dd").format(DateTime.now());
        AppGlobals.MaxSaleOrderNum = await _saleOrders.nextJobNo('MY'); AppGlobals.AddressList = await _repository.selectAddressList();
        AppGlobals.AgentCompanyList = await _repository.selectAgentCompany();AppGlobals.EmployeeList = await _repository.selectEmployee('', 'Operation');final permission = _buildPermissions();
        var base = SalesOrderAddLoaded(
          progress: true, dtpSaleOrderdate: today, dtpOETAdate: now, dtpOETBdate: now, dtpOETDdate: now,
          dtpLETAdate: now, dtpLETBdate: now, dtpLETDdate: now, dtpFlightTimedate: now, dtpPickUpdate: now,
          dtpDeliverydate: now, dtpWHEntrydate: now, dtpWHExitdate: now, dtpFW1date: now, dtpFW2date: now,
          dtpFW3date: now, txtJobNo: AppGlobals.MaxSaleOrderNum, fieldPermission: permission,
        );

        if (event.saleOrderId > 0 || event.saleOrderNo > 0) {
          final order = await _saleOrders.edit(id: event.saleOrderId, saleOrderNo: event.saleOrderNo);
          base = await _loadMasterData(base, order.master,
              details: [for (final d in order.details) SaleEditDetailModel.fromJava(d)],
              pickups: order.pickups, deliveries: order.deliveries, isEnquiry: false);
          base = base.copyWith(
            invoiceNo: await _invoiceNo(base.editId),
            savedLegCalls: await _savedLegCalls(base.editId),
            // the order as loaded counts as answered: an unrelated edit asks nothing
            ptpSettledKey: ptpTimeKey(base),
          );
        } else if (event.enquiry != null) {
          base = await _loadMasterData(base, EnquiryApi.asSaleOrder(event.enquiry!), isEnquiry: true);
        }
        emit(base);
      } catch (e) {
        emit(SalesOrderAddError(e.toString()));
      }
    });

    on<UpdateTextField>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      emit(_updateField(state as SalesOrderAddLoaded, event.field, event.value));
    });

    on<UpdateDropdown>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      emit(_updateDropdown(state as SalesOrderAddLoaded, event.field, event.value));
    });

    on<UpdateCheckbox>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      emit(_updateCheckbox(state as SalesOrderAddLoaded, event.field, event.value));
    });

    on<UpdateDate>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      emit(_updateDateField(state as SalesOrderAddLoaded, event.field, event.value));
    });


    on<CustomerSelected>((event, emit) async {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;

      if (event.id == 0) {
        // If user clears the customer, just update state and exit early.
        // DO NOT call the API.
        emit(s.copyWith(txtCustomer: '', custId: 0));
        return;
      }

      AppGlobals.CustomerCurrencyValue = await _saleOrders.currencyValue(event.id);emit(s.copyWith(txtCustomer: event.name, custId: event.id, currencyValue: AppGlobals.CustomerCurrencyValue));
    });


    on<JobTypeSelected>((event, emit) async {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;

      if (event.id == 0) {
        // Clear Job Type AND Job Status since status depends on type
        emit(_applyVisibility(s.copyWith(txtJobType: '', jobTypeId: 0, txtJobStatus: '', statusId: 0)));
        return;
      }

      final jobData = await _repository.selectAllJobStatus(event.id);
      AppGlobals.JobAllStatusList = jobData.statuses;
      AppGlobals.JobTypeDetailsList = jobData.details;
      emit(_applyVisibility(s.copyWith(txtJobType: event.name, jobTypeId: event.id)));
    });


    on<JobStatusSelected>((event, emit) { if (state is SalesOrderAddLoaded) emit((state as SalesOrderAddLoaded).copyWith(txtJobStatus: event.name, statusId: event.id)); });
    on<LAgentCompanySelected>((event, emit) { if (state is SalesOrderAddLoaded) emit((state as SalesOrderAddLoaded).copyWith(txtLAgentCompany: event.name, lAgentCompanyId: event.id)); });
    on<LAgentSelected>((event, emit) { if (state is SalesOrderAddLoaded) emit((state as SalesOrderAddLoaded).copyWith(txtLAgentName: event.name, lAgentId: event.id)); });
    on<OAgentCompanySelected>((event, emit) { if (state is SalesOrderAddLoaded) emit((state as SalesOrderAddLoaded).copyWith(txtOAgentCompany: event.name, oAgentCompanyId: event.id)); });
    on<OAgentSelected>((event, emit) { if (state is SalesOrderAddLoaded) emit((state as SalesOrderAddLoaded).copyWith(txtOAgentName: event.name, oAgentId: event.id)); });

    on<SealEmp1Selected>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      emit(event.isBreak ? s.copyWith(txtBreakByEmp1: event.name, breakEmpId1: event.id) : s.copyWith(txtSealByEmp1: event.name, sealEmpId1: event.id));
    });
    on<SealEmp2Selected>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      emit(event.isBreak ? s.copyWith(txtBreakByEmp2: event.name, breakEmpId2: event.id) : s.copyWith(txtSealByEmp2: event.name, sealEmpId2: event.id));
    });
    on<SealEmp3Selected>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      emit(event.isBreak ? s.copyWith(txtBreakByEmp3: event.name, breakEmpId3: event.id) : s.copyWith(txtSealByEmp3: event.name, sealEmpId3: event.id));
    });

    on<BoardingOfficer1Selected>((event, emit) { if (state is SalesOrderAddLoaded) emit((state as SalesOrderAddLoaded).copyWith(txtBoardingOfficer1: event.name, boardOfficerId1: event.id)); });
    on<BoardingOfficer2Selected>((event, emit) { if (state is SalesOrderAddLoaded) emit((state as SalesOrderAddLoaded).copyWith(txtBoardingOfficer2: event.name, boardOfficerId2: event.id)); });
    on<CommoditySelected>((event, emit) { if (state is SalesOrderAddLoaded) emit((state as SalesOrderAddLoaded).copyWith(txtCommodityType: event.name)); });
    on<CargoSelected>((event, emit) { if (state is SalesOrderAddLoaded) emit((state as SalesOrderAddLoaded).copyWith(txtCargo: event.name)); });
    on<LPortSelected>((event, emit) { if (state is SalesOrderAddLoaded) emit((state as SalesOrderAddLoaded).copyWith(txtLPort: event.name)); });
    on<OPortSelected>((event, emit) { if (state is SalesOrderAddLoaded) emit((state as SalesOrderAddLoaded).copyWith(txtOPort: event.name)); });
    on<LVesselTypeSelected>((event, emit) { if (state is SalesOrderAddLoaded) emit((state as SalesOrderAddLoaded).copyWith(txtLVesselType: event.name)); });
    on<OVesselTypeSelected>((event, emit) { if (state is SalesOrderAddLoaded) emit((state as SalesOrderAddLoaded).copyWith(txtOVesselType: event.name)); });
    on<OriginSelected>((event, emit) { if (state is SalesOrderAddLoaded) emit((state as SalesOrderAddLoaded).copyWith(txtOrigin: event.name, originId: event.id)); });
    on<DestinationSelected>((event, emit) { if (state is SalesOrderAddLoaded) emit((state as SalesOrderAddLoaded).copyWith(txtDestination: event.name, destinationId: event.id)); });
    on<PickUpAddressSelected>((event, emit) { if (state is SalesOrderAddLoaded) emit((state as SalesOrderAddLoaded).copyWith(txtPickUpAddress: event.address)); });
    on<DeliveryAddressSelected>((event, emit) { if (state is SalesOrderAddLoaded) emit((state as SalesOrderAddLoaded).copyWith(txtDeliveryAddress: event.address)); });
    on<WarehouseAddressSelected>((event, emit) { if (state is SalesOrderAddLoaded) emit((state as SalesOrderAddLoaded).copyWith(txtWarehouseAddress: event.address)); });

    on<ProductSelected>((event, emit) async {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      final updated = s.copyWith(
        txtProductDescription: event.name,
        txtProductCode: event.code,
        productId: event.id,
      );
      emit(_recalculate(updated));
    });

    on<ClearProduct>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      emit((state as SalesOrderAddLoaded).copyWith(
        txtProductCode: '', txtProductDescription: '', txtProductQty: '',
        txtProductSaleRate: '', txtProductGst: '', txtProductAmount: '',
        productId: 0, productUpdateIndex: null,
      ));
    });

    on<AddProduct>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      if (s.txtProductDescription.isEmpty) return;

      final product = _buildProduct(s);
      final list = List<SaleEditDetailModel>.from(s.productViewList);
      final idList = List<int>.from(s.productIds);

      if (s.productUpdateIndex != null) {
        list[s.productUpdateIndex!] = product;
        idList[s.productUpdateIndex!] = s.productId;
      } else {
        list.add(product);
        idList.add(s.productId);
      }

      final updated = s.copyWith(
        productViewList: list, productIds: idList, productUpdateIndex: null, productId: 0,
        txtProductCode: '', txtProductDescription: '', txtProductQty: '',
        txtProductSaleRate: '', txtProductGst: '', txtProductAmount: '',
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
        productId: s.productIds.length > event.index ? s.productIds[event.index] : 0,
      ));
    });

    on<RemoveProduct>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      final list = List<SaleEditDetailModel>.from(s.productViewList)..removeAt(event.index);
      final idList = List<int>.from(s.productIds)..removeAt(event.index);
      emit(_recalculate(s.copyWith(productViewList: list, productIds: idList)));
    });

    on<KeyPress>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      String current = '';
      switch (event.activeField) { case 'qty': current = s.txtProductQty; break; case 'saleRate': current = s.txtProductSaleRate; break; case 'gst': current = s.txtProductGst; break; }
      String newVal = current;
      switch (event.key) {
        case 'CLEAR': newVal = ''; break;
        case 'C': if (current.isNotEmpty) newVal = current.substring(0, current.length - 1); break;
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

    on<AddPickUpAddress>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      if (s.txtPickUpAddress.isEmpty) return;
      
      final addrList = List<dynamic>.from(s.pickUpAddressList);
      final qtyList = List<dynamic>.from(s.pickUpQuantityList);
      final wtList = List<dynamic>.from(s.pickUpWeightList);
      
      if (s.pickUpUpdateIndex != null && s.pickUpUpdateIndex! < addrList.length) {
        addrList[s.pickUpUpdateIndex!] = s.txtPickUpAddress;
        qtyList[s.pickUpUpdateIndex!] = s.txtPickUpQuantity;
        if (s.pickUpUpdateIndex! < wtList.length) {
          wtList[s.pickUpUpdateIndex!] = s.txtPickUpWeight;
        } else {
          wtList.add(s.txtPickUpWeight);
        }
      } else {
        addrList.add(s.txtPickUpAddress);
        qtyList.add(s.txtPickUpQuantity);
        wtList.add(s.txtPickUpWeight);
      }
      
      emit(s.copyWith(pickUpAddressList: addrList, pickUpQuantityList: qtyList, pickUpWeightList: wtList, txtPickUpAddress: '', txtPickUpQuantity: '', txtPickUpWeight: '', clearPickUpUpdateIndex: true));
    });

    on<AddDeliveryAddress>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      if (s.txtDeliveryAddress.isEmpty) return;
      
      final addrList = List<dynamic>.from(s.deliveryAddressList);
      final qtyList = List<dynamic>.from(s.deliveryQuantityList);
      final wtList = List<dynamic>.from(s.deliveryWeightList);
      
      if (s.deliveryUpdateIndex != null && s.deliveryUpdateIndex! < addrList.length) {
        addrList[s.deliveryUpdateIndex!] = s.txtDeliveryAddress;
        qtyList[s.deliveryUpdateIndex!] = s.txtDeliveryQuantity;
        if (s.deliveryUpdateIndex! < wtList.length) {
          wtList[s.deliveryUpdateIndex!] = s.txtDeliveryWeight;
        } else {
          wtList.add(s.txtDeliveryWeight);
        }
      } else {
        addrList.add(s.txtDeliveryAddress);
        qtyList.add(s.txtDeliveryQuantity);
        wtList.add(s.txtDeliveryWeight);
      }
      
      emit(s.copyWith(deliveryAddressList: addrList, deliveryQuantityList: qtyList, deliveryWeightList: wtList, txtDeliveryAddress: '', txtDeliveryQuantity: '', txtDeliveryWeight: '', clearDeliveryUpdateIndex: true));
    });

    on<RemovePickUpAddress>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      final addrList = List<dynamic>.from(s.pickUpAddressList);
      final qtyList = List<dynamic>.from(s.pickUpQuantityList);
      final wtList = List<dynamic>.from(s.pickUpWeightList);
      
      if (event.index < addrList.length) addrList.removeAt(event.index);
      if (event.index < qtyList.length) qtyList.removeAt(event.index);
      if (event.index < wtList.length) wtList.removeAt(event.index);
      
      emit(s.copyWith(pickUpAddressList: addrList, pickUpQuantityList: qtyList, pickUpWeightList: wtList, clearPickUpUpdateIndex: true));
    });

    on<RemoveDeliveryAddress>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      final addrList = List<dynamic>.from(s.deliveryAddressList);
      final qtyList = List<dynamic>.from(s.deliveryQuantityList);
      final wtList = List<dynamic>.from(s.deliveryWeightList);
      
      if (event.index < addrList.length) addrList.removeAt(event.index);
      if (event.index < qtyList.length) qtyList.removeAt(event.index);
      if (event.index < wtList.length) wtList.removeAt(event.index);
      
      emit(s.copyWith(deliveryAddressList: addrList, deliveryQuantityList: qtyList, deliveryWeightList: wtList, clearDeliveryUpdateIndex: true));
    });

    on<SelectPickUpFromList>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      emit(s.copyWith(
          txtPickUpAddress: s.pickUpAddressList[event.index].toString(),
          txtPickUpQuantity: s.pickUpQuantityList[event.index].toString(),
          txtPickUpWeight: s.pickUpWeightList.length > event.index ? s.pickUpWeightList[event.index].toString() : '',
          pickUpUpdateIndex: event.index,
      ));
    });

    on<SelectDeliveryFromList>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      emit(s.copyWith(
          txtDeliveryAddress: s.deliveryAddressList[event.index].toString(),
          txtDeliveryQuantity: s.deliveryQuantityList[event.index].toString(),
          txtDeliveryWeight: s.deliveryWeightList.length > event.index ? s.deliveryWeightList[event.index].toString() : '',
          deliveryUpdateIndex: event.index,
      ));
    });
    on<ToggleProductView>((event, emit) { if (state is SalesOrderAddLoaded) emit((state as SalesOrderAddLoaded).copyWith(visibleProductview: !(state as SalesOrderAddLoaded).visibleProductview)); });
    on<ToggleFW1>((event, emit) { if (state is SalesOrderAddLoaded) emit((state as SalesOrderAddLoaded).copyWith(visibleFW1: !(state as SalesOrderAddLoaded).visibleFW1)); });
    on<ToggleFW2>((event, emit) { if (state is SalesOrderAddLoaded) emit((state as SalesOrderAddLoaded).copyWith(visibleFW2: !(state as SalesOrderAddLoaded).visibleFW2)); });
    on<ToggleFW3>((event, emit) { if (state is SalesOrderAddLoaded) emit((state as SalesOrderAddLoaded).copyWith(visibleFW3: !(state as SalesOrderAddLoaded).visibleFW3)); });

    on<BillTypeChanged>((event, emit) async {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      AppGlobals.MaxSaleOrderNum = await _saleOrders.nextJobNo(event.value);emit(s.copyWith(dropdownValue: event.value, txtJobNo: AppGlobals.MaxSaleOrderNum));
    });

    // ── Vessel suggestions (change vessel-master-and-ptp-schedule). The save body is not touched:
    // picks live in the state and go out as vessel links after the save.

    on<VesselPicked>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      final pick = VesselPick(
          name: event.vessel.vesselName,
          vesselMasterId: event.vessel.vesselMasterId,
          ptpVesselCallId: event.call?.id,
          call: event.call);
      final named = event.leg == VesselLeg.loading
          ? s.copyWith(txtLoadingVessel: pick.name, pickedLoading: pick, vesselFillQuestion: null)
          : s.copyWith(txtOffVessel: pick.name, pickedOff: pick, vesselFillQuestion: null);
      final call = event.call;
      if (call == null) {
        emit(named);
        return;
      }
      final differing = _fillDifferences(named, event.leg, call);
      emit(differing.isEmpty
          ? _applyFill(named, event.leg, call, replace: true)
          : named.copyWith(vesselFillQuestion: VesselFillQuestion(leg: event.leg, call: call, differing: differing)));
    });

    on<VesselFillAnswered>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      final q = s.vesselFillQuestion;
      if (q == null) return;
      // "no" keeps the typed values and fills only what the leg did not have yet
      emit(_applyFill(s.copyWith(vesselFillQuestion: null), q.leg, q.call, replace: event.replace));
    });

    on<VesselFieldLeft>((event, emit) async {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      final text = _vesselText(s, event.leg).trim();
      if (text.length < 2) return;
      final pick = event.leg == VesselLeg.loading ? s.pickedLoading : s.pickedOff;
      if (pick != null && pick.name == text) return;
      final key = '${event.leg}|${text.toUpperCase()}';
      if (s.keptSpellings.contains(key)) return;

      final SimilarVessel similar;
      try {
        similar = await _vesselMasters.similar(text);
      } catch (e, st) {
        AppLogger.instance.logError(e, st, 'Sale order vessel similar');
        return;
      }
      if (state is! SalesOrderAddLoaded) return;
      final now = state as SalesOrderAddLoaded;
      if (_vesselText(now, event.leg).trim() != text) return; // changed (or picked) meanwhile
      final name = similar.vesselName;
      if (name == null || name.isEmpty) return;
      final asked = {...now.keptSpellings, key};
      if (similar.match == SimilarVessel.same) {
        emit(_setVessel(now, event.leg, VesselPick(name: name, vesselMasterId: similar.vesselMasterId))
            .copyWith(keptSpellings: asked));
      } else if (similar.match == SimilarVessel.close && name.toUpperCase() != text.toUpperCase()) {
        emit(now.copyWith(
            keptSpellings: asked,
            didYouMean: DidYouMean(leg: event.leg, typed: text, name: name, vesselMasterId: similar.vesselMasterId)));
      }
    });

    on<DidYouMeanAnswered>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      final q = s.didYouMean;
      if (q == null) return;
      final cleared = s.copyWith(didYouMean: null);
      if (!event.useSuggestion || _vesselText(cleared, q.leg).trim() != q.typed) {
        emit(cleared);
        return;
      }
      emit(_setVessel(cleared, q.leg, VesselPick(name: q.name, vesselMasterId: q.vesselMasterId)));
    });

    on<SaveDateQuestionAnswered>((event, emit) {
      if (state is! SalesOrderAddLoaded) return;
      final s = state as SalesOrderAddLoaded;
      final q = s.saveQuestion;
      if (q == null) return;
      final answered = event.change ? applyPtpTimes(s, q) : s;
      emit(answered.copyWith(saveQuestion: null, ptpSettledKey: ptpTimeKey(answered)));
      add(SaveSalesOrderEvent());
    });

    on<SaveSalesOrderEvent>((event, emit) async {
      if (state is! SalesOrderAddLoaded) return;
      var s = state as SalesOrderAddLoaded;

      if (s.txtCustomer.isEmpty) { emit(s.copyWith(savedMessage: 'Enter Customer Name')); return; }
      if (s.txtJobType.isEmpty) { emit(s.copyWith(savedMessage: 'Enter Job Type')); return; }
      if (s.productViewList.isEmpty) { emit(s.copyWith(savedMessage: 'Add Product Details')); return; }

      // The question before saving (save_date_checks.dart): either answer continues the save.
      if (s.saveQuestion != null) return;
      if (ptpTimeKey(s) != s.ptpSettledKey) {
        final ptp = planPtpTimes(s, _legCalls(s));
        if (ptp != null) { emit(s.copyWith(saveQuestion: ptp, savedMessage: null)); return; }
      }

      // SYNC PICKUP
      List<dynamic> addrList = List.from(s.pickUpAddressList);
      List<dynamic> qtyList = List.from(s.pickUpQuantityList);
      List<dynamic> wtList = List.from(s.pickUpWeightList);
      if (s.txtPickUpAddress.isNotEmpty) {
        if (s.pickUpUpdateIndex != null && s.pickUpUpdateIndex! < addrList.length) {
          addrList[s.pickUpUpdateIndex!] = s.txtPickUpAddress;
          qtyList[s.pickUpUpdateIndex!] = s.txtPickUpQuantity;
          if (s.pickUpUpdateIndex! < wtList.length) {
            wtList[s.pickUpUpdateIndex!] = s.txtPickUpWeight;
          } else {
            wtList.add(s.txtPickUpWeight);
          }
        } else {
          addrList.add(s.txtPickUpAddress);
          qtyList.add(s.txtPickUpQuantity);
          wtList.add(s.txtPickUpWeight);
        }
      }
      
      // SYNC DELIVERY
      List<dynamic> dAddrList = List.from(s.deliveryAddressList);
      List<dynamic> dQtyList = List.from(s.deliveryQuantityList);
      List<dynamic> dWtList = List.from(s.deliveryWeightList);
      if (s.txtDeliveryAddress.isNotEmpty) {
        if (s.deliveryUpdateIndex != null && s.deliveryUpdateIndex! < dAddrList.length) {
          dAddrList[s.deliveryUpdateIndex!] = s.txtDeliveryAddress;
          dQtyList[s.deliveryUpdateIndex!] = s.txtDeliveryQuantity;
          if (s.deliveryUpdateIndex! < dWtList.length) {
            dWtList[s.deliveryUpdateIndex!] = s.txtDeliveryWeight;
          } else {
            dWtList.add(s.txtDeliveryWeight);
          }
        } else {
          dAddrList.add(s.txtDeliveryAddress);
          dQtyList.add(s.txtDeliveryQuantity);
          dWtList.add(s.txtDeliveryWeight);
        }
      }

      s = s.copyWith(
        pickUpAddressList: addrList, pickUpQuantityList: qtyList, pickUpWeightList: wtList,
        deliveryAddressList: dAddrList, deliveryQuantityList: dQtyList, deliveryWeightList: dWtList,
        txtPickUpAddress: '', txtDeliveryAddress: ''
      );

      emit(s.copyWith(progress: false));

      try {
        // the shared Java save (POST /api/sale-orders/save, PUT /api/sale-orders/{id})
        final saved = await _saleOrders.save(saleOrderSaveBody(s, companyId: AppGlobals.Comid, employeeId: AppGlobals.EmpRefId));
        await _sendVesselLinks(s, JsonRead.integer(saved['id'], fallback: s.editId));
        if (s.enquiryId != 0) await _confirmEnquiry(s.enquiryId);
        emit(s.copyWith(progress: true, isSaved: true,
            savedMessage: s.editId > 0 ? 'Updated Successfully' : 'Created Successfully'));
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
      "txtCustomer", "txtJobType", "txtJobStatus", "txtRemarks", "txtDoDescription", "ProductViewList", "txtCommodityType", "txtOrigin", "txtWeight", "txtQuantity",
      "txtTruckSize", "txtAWBNo", "txtBLCopy", "txtCargo", "txtPTWNo", "dtpLETAdate", "dtpLETBdate", "dtpLETDdate", "txtLAgentCompany", "txtLAgentName",
      "txtLSCN", "dtpFlightTimedate", "txtLoadingVessel", "txtLPort", "txtLVesselType", "cmbBillType", "dtpOETAdate", "dtpOETDdate", "txtOAgentCompany", "txtOAgentName",
      "txtOSCN", "txtOffVessel", "txtOPort", "txtOVesselType", "dtpPickUpdate", "dtpDeliverydate", "dtpWHEntrydate", "dtpWHExitdate", "txtDestination",
      "txtPickUpAddress", "txtPickUpQuantity", "txtDeliveryAddress", "txtDeliveryQuantity", "txtWarehouseAddress", "dtpFW1date", "txtSmk1", "txtENRef1", "txtSealByEmp1",
      "txtBreakByEmp1", "txtForwarding1S1", "txtForwarding1S2", "dropdownValueFW2", "dtpFW2date", "txtENRef2", "txtExRef2", "txtSealByEmp2", "txtBreakByEmp2",
      "txtForwarding2S1", "txtForwarding2S2", "dropdownValueFW3", "dtpFW3date", "txtSmk3", "txtENRef3", "txtSealByEmp3", "txtBreakByEmp3", "txtForwarding3S2",
      "dropdownValueZB1", "txtZBRef1", "dropdownValueZB2", "txtZBRef2", "txtBoardingOfficer1", "txtBoardingOfficer2", "txtAmount1", "txtAmount2",
      // ✅ FIX 2: Added missing permission allowing user to type in PortCharges Ref
      "txtPortCharges", "txtPortChargeRef1", "chkLETA", "chkOETA", "chkLETB", "chkOETB", "chkLETD", "chkOETD", "chkPickup", "chkDelivery", "chkWareHouseEntry", "chkWareHouseExit",
      "chkFlightTime", "SAVE", "VIEW", "addProduct", "dropdownValueFW1", "checkBoxValueFW2", "txtSmk2", "checkBoxValueFW1", "checkBoxValueFW3",
    ];
    const restrictedIds = [138, 50, 127, 35, 75, 38, 68, 128, 100, 117, 121];

    if (!restrictedIds.contains(AppGlobals.EmpRefId)) return {for (var f in allFields) f: true};
    final map = {for (var f in allFields) f: false};
    for (var f in ["txtBoardingOfficer1", "txtBoardingOfficer2", "txtAmount1", "txtAmount2", "SAVE", "VIEW"]) {
      map[f] = true;
    }
    return map;
  }

  SalesOrderAddLoaded _applyVisibility(SalesOrderAddLoaded s) {
    bool offVessel = false, loadingVessel = false, lETA = false, flightTime = false, lETB = false, lETD = false, awbNo = false, blCopy = false;
    bool forwarding = false, origin = false, destination = false, zb = false, oETA = false, oETB = false, oETD = false, oShippingAgent = false;
    bool oAgentName = false, oScn = false, lScn = false, lShipping = false, lAgentName = false, lVesselType = false, oVesselType = false, oPort = false, lPort = false;

    for (var item in AppGlobals.JobTypeDetailsList) {
      switch (item.Description) {
        case "OFF VESSEL NAME": offVessel = true; break; case "LOAD VESSEL NAME": loadingVessel = true; break;
        case "L ETA": lETA = true; break; case "L ETB": lETB = true; break; case "L ETD": lETD = true; break;
        case "AWB NO": awbNo = true; break; case "BL COPY": blCopy = true; break; case "FORWARDING": forwarding = true; break;
        case "ORIGIN": origin = true; break; case "DESTINATION": destination = true; break; case "ZB": zb = true; break;
        case "O ETA": oETA = true; break; case "O ETB": oETB = true; break; case "O ETD": oETD = true; break;
        case "O AGENT": oAgentName = true; break; case "O AGENT COMPANY": oShippingAgent = true; break;
        case "O SCN": oScn = true; break; case "L SCN": lScn = true; break; case "L AGENT COMPANY": lShipping = true; break;
        case "L AGENT": lAgentName = true; break; case "L VESSEL TYPE": lVesselType = true; break; case "O VESSEL TYPE": oVesselType = true; break;
        case "O PORT": oPort = true; break; case "L PORT": lPort = true; break;
      }
    }
    final isGC = s.txtJobType == "GENARAL CARGO";
    return s.copyWith(
      visibleOffVessel: offVessel, visibleLoadingVessel: loadingVessel, visibleLETA: lETA, visibleFlightTime: flightTime, visibleLETB: lETB, visibleLETD: lETD,
      visibleAWBNo: awbNo, visibleBLCopy: blCopy, visibleFORWARDING: forwarding, visibleOrigin: isGC ? false : origin, visibleDestination: isGC ? false : destination,
      visibleZB: zb, visibleOETA: oETA, visibleOETB: oETB, visibleOETD: oETD, visibleOShippingAgent: oShippingAgent, visibleOAgentName: oAgentName, visibleOScn: oScn,
      visibleLScn: lScn, visibleLShippingAgent: lShipping, visibleLAgentName: lAgentName, visibleLVesselType: lVesselType, visibleOVesselType: oVesselType,
      visibleOPort: oPort, visibleLPort: lPort, visibleGC: isGC,
    );
  }

  SalesOrderAddLoaded _recalculate(SalesOrderAddLoaded s) {
    final gst = double.tryParse(s.txtProductGst) ?? 0.0;
    final qty = double.tryParse(s.txtProductQty) ?? 0.0;
    final rate = double.tryParse(s.txtProductSaleRate) ?? 0.0;
    final netAmount = qty * rate;
    final gstAmt = gst != 0 ? (netAmount * gst) / 100 : 0.0;
    final amt = gst != 0 ? netAmount + gstAmt : netAmount;

    var producttotal = 0.0; var taxTotal = 0.0;
    for (var p in s.productViewList) { producttotal += p.Amount; taxTotal += p.TaxAmount; }

    final grossAmt = producttotal + taxTotal;
    final coinage = double.parse((grossAmt.roundToDouble() - grossAmt).abs().toStringAsFixed(2));

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
      s.productUpdateIndex != null ? s.productViewList[s.productUpdateIndex!].Id : 0,
      0,
      s.productId,
      0, 0.0, 0.0,
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
      // a pick is dropped as soon as the text changes after it
      case 'txtLoadingVessel': return s.copyWith(txtLoadingVessel: value, pickedLoading: value == s.txtLoadingVessel ? s.pickedLoading : null);
      case 'txtOffVessel': return s.copyWith(txtOffVessel: value, pickedOff: value == s.txtOffVessel ? s.pickedOff : null);
      case 'txtOSCN': return s.copyWith(txtOSCN: value);
      case 'txtLSCN': return s.copyWith(txtLSCN: value);
      case 'txtProductQty': return _recalculate(s.copyWith(txtProductQty: value));
      case 'txtProductSaleRate': return _recalculate(s.copyWith(txtProductSaleRate: value));
      case 'txtProductGst': return _recalculate(s.copyWith(txtProductGst: value));

    // ==========================================================
    // PICKUP FIELDS
    // ==========================================================
      case 'txtPickUpAddress': return s.copyWith(txtPickUpAddress: value);
      case 'txtPickUpQuantity': return s.copyWith(txtPickUpQuantity: value);
      case 'txtPickUpWeight': return s.copyWith(txtPickUpWeight: value);

    // ==========================================================
    // DELIVERY FIELDS
    // ==========================================================
      case 'txtDeliveryAddress': return s.copyWith(txtDeliveryAddress: value);
      case 'txtDeliveryQuantity': return s.copyWith(txtDeliveryQuantity: value);
      case 'txtDeliveryWeight': return s.copyWith(txtDeliveryWeight: value);

      case 'txtWarehouseAddress': return s.copyWith(txtWarehouseAddress: value);
      case 'txtOrigin': return s.copyWith(txtOrigin: value);
      case 'txtDestination': return s.copyWith(txtDestination: value);
      default: return s;
    }
  }
  // ── Vessel helpers (change vessel-master-and-ptp-schedule)

  static String _vesselText(SalesOrderAddLoaded s, String leg) =>
      leg == VesselLeg.loading ? s.txtLoadingVessel : s.txtOffVessel;

  static SalesOrderAddLoaded _setVessel(SalesOrderAddLoaded s, String leg, VesselPick pick) => leg == VesselLeg.loading
      ? s.copyWith(txtLoadingVessel: pick.name, pickedLoading: pick)
      : s.copyWith(txtOffVessel: pick.name, pickedOff: pick);

  static bool _sameTime(String formValue, DateTime ptp) => DateTime.tryParse(formValue) == ptp;

  static String _shown(DateTime d) => DateFormat('dd MMM HH:mm').format(d);

  /// What the leg already has (a ticked date, a typed SCN) that PTP's call would change. ETB is never part of it.
  static List<VesselFillChange> _fillDifferences(SalesOrderAddLoaded s, String leg, PtpCall call) {
    final loading = leg == VesselLeg.loading;
    final etaTicked = loading ? s.checkBoxValueLETA : s.checkBoxValueOETA;
    final eta = loading ? s.dtpLETAdate : s.dtpOETAdate;
    final etdTicked = loading ? s.checkBoxValueLETD : s.checkBoxValueOETD;
    final etd = loading ? s.dtpLETDdate : s.dtpOETDdate;
    final scn = (loading ? s.txtLSCN : s.txtOSCN).trim();
    final arrive = call.arrive;
    final depart = call.depart;
    final ptpScn = call.scn;
    return [
      if (arrive != null && etaTicked && !_sameTime(eta, arrive))
        VesselFillChange('ETA', DateTime.tryParse(eta) == null ? eta : _shown(DateTime.parse(eta)), _shown(arrive)),
      if (depart != null && etdTicked && !_sameTime(etd, depart))
        VesselFillChange('ETD', DateTime.tryParse(etd) == null ? etd : _shown(DateTime.parse(etd)), _shown(depart)),
      if (ptpScn != null && scn.isNotEmpty && scn.toUpperCase() != ptpScn.toUpperCase()) VesselFillChange('SCN', scn, ptpScn),
    ];
  }

  /// Fills the leg's ETA and ETD (ticking their boxes) and SCN from PTP's call. Without [replace], only
  /// what the leg did not have yet (an unticked date, an empty SCN) is filled. ETB, the other leg and
  /// every other field stay as they are; a time PTP does not give is left alone.
  static SalesOrderAddLoaded _applyFill(SalesOrderAddLoaded s, String leg, PtpCall call, {required bool replace}) {
    final arrive = call.arrive;
    final depart = call.depart;
    final scn = call.scn;
    if (leg == VesselLeg.loading) {
      final eta = arrive != null && (replace || !s.checkBoxValueLETA);
      final etd = depart != null && (replace || !s.checkBoxValueLETD);
      final setScn = scn != null && (replace || s.txtLSCN.trim().isEmpty);
      return s.copyWith(
        dtpLETAdate: eta ? formDateOf(arrive) : null,
        checkBoxValueLETA: eta ? true : null,
        dtpLETDdate: etd ? formDateOf(depart) : null,
        checkBoxValueLETD: etd ? true : null,
        txtLSCN: setScn ? scn : null,
      );
    }
    final eta = arrive != null && (replace || !s.checkBoxValueOETA);
    final etd = depart != null && (replace || !s.checkBoxValueOETD);
    final setScn = scn != null && (replace || s.txtOSCN.trim().isEmpty);
    return s.copyWith(
      dtpOETAdate: eta ? formDateOf(arrive) : null,
      checkBoxValueOETA: eta ? true : null,
      dtpOETDdate: etd ? formDateOf(depart) : null,
      checkBoxValueOETD: etd ? true : null,
      txtOSCN: setScn ? scn : null,
    );
  }

  /// After a successful save: both legs' names and any picked ids go to
  /// `PUT /api/sale-orders/{id}/vessel-links`. A failure is logged only; the save stays a success.
  Future<void> _sendVesselLinks(SalesOrderAddLoaded s, int saleOrderId) async {
    if (saleOrderId <= 0) {
      AppLogger.instance.logError('the save answer has no id', null, 'Sale order vessel links skipped');
      return;
    }
    VesselLinkRequest leg(String leg, String text, VesselPick? pick) {
      final name = text.trim();
      final picked = pick != null && pick.name == name ? pick : null;
      return VesselLinkRequest(
          leg: leg, vesselName: name, vesselMasterId: picked?.vesselMasterId, ptpVesselCallId: picked?.ptpVesselCallId);
    }

    try {
      await _vesselMasters.saveLinks(saleOrderId, [
        leg(VesselLeg.loading, s.txtLoadingVessel, s.pickedLoading),
        leg(VesselLeg.off, s.txtOffVessel, s.pickedOff),
      ]);
    } catch (e, st) {
      AppLogger.instance.logError(e, st, 'Sale order vessel links');
    }
  }

  SalesOrderAddLoaded _updateDropdown(SalesOrderAddLoaded s, String field, String? value) {
    switch (field) {
      case 'dropdownValueFW1': return s.copyWith(dropdownValueFW1: value);
      case 'dropdownValueFW2': return s.copyWith(dropdownValueFW2: value);
      case 'dropdownValueFW3': return s.copyWith(dropdownValueFW3: value);
      case 'dropdownValueZB1': return s.copyWith(dropdownValueZB1: value);
      case 'dropdownValueZB2': return s.copyWith(dropdownValueZB2: value);
      case 'dropdownValueTruckSize': return s.copyWith(dropdownValueTruckSize: value, txtTruckSize: value ?? '');
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

  Future<SalesOrderAddLoaded> _loadMasterData(SalesOrderAddLoaded base, Map<String, dynamic> m,
      {List<SaleEditDetailModel> details = const [], List<Map<String, dynamic>> pickups = const [],
      List<Map<String, dynamic>> deliveries = const [], required bool isEnquiry}) async {
    final now = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());




    AppGlobals.CustomerList = await _repository.selectCustomer();
    AppGlobals.JobTypeList = await _repository.selectJobType();
    if (m["jobMasterRefId"] != null) {
      final jobData = await _repository.selectAllJobStatus(m["jobMasterRefId"] as int? ?? 0);
      AppGlobals.JobAllStatusList = jobData.statuses;
      AppGlobals.JobTypeDetailsList = jobData.details;
    }
    String lAgentName = '';
    if (m["agentCompanyRefId"] != null && m["agentCompanyRefId"] > 0) {
      AppGlobals.AgentAllList = await _repository.selectAgentAll(m["agentCompanyRefId"] as int? ?? 0);lAgentName = _getFromAgentAll(m["agentMasterRefId"]);
    }
    String oAgentName = '';
    if (m["oAgentCompanyRefId"] != null && m["oAgentCompanyRefId"] > 0) {
      AppGlobals.AgentAllList = await _repository.selectAgentAll(m["oAgentCompanyRefId"] as int? ?? 0);oAgentName = _getFromAgentAll(m["oAgentMasterRefId"]);
    }

    AppGlobals.CustomerCurrencyValue = await _saleOrders.currencyValue(m["customerRefId"] as int? ?? 0);String safeStr(String? v) => v ?? ''; String safeNum(dynamic v) => v != null ? v.toString() : '';
    String parseDate(dynamic v, String fmt) { if (v == null) return now; return DateFormat(fmt).format(DateTime.parse(v.toString())); }

    final loadedIds = [for (final d in details) d.ItemMasterRefId];

    // pickups and deliveries: the Java rows, else the legacy "{@}"-joined columns
    final parsedPickupAddresses = <dynamic>[];
    final parsedPickupQuantities = <dynamic>[];
    final parsedPickupWeights = <dynamic>[];
    if (pickups.isNotEmpty) {
      for (final item in pickups) {
        parsedPickupAddresses.add(item['pickupAddress'] ?? '');
        parsedPickupQuantities.add(item['pickupQuantity'] ?? '');
        parsedPickupWeights.add(item['pickupWeight'] ?? '');
      }
    } else {
      parsedPickupAddresses.addAll(_splitAddress(m["pickupAddress"]));
      parsedPickupQuantities.addAll(_splitAddress(m["pickupQuantitylist"]));
      parsedPickupWeights.addAll(List.filled(parsedPickupAddresses.length, ""));
    }

    final parsedDeliveryAddresses = <dynamic>[];
    final parsedDeliveryQuantities = <dynamic>[];
    final parsedDeliveryWeights = <dynamic>[];
    if (deliveries.isNotEmpty) {
      for (final item in deliveries) {
        parsedDeliveryAddresses.add(item['deliveryAddress'] ?? '');
        parsedDeliveryQuantities.add(item['deliveryQuantity'] ?? '');
        parsedDeliveryWeights.add(item['deliveryWeight'] ?? '');
      }
    } else {
      parsedDeliveryAddresses.addAll(_splitAddress(m["deliveryAddress"]));
      parsedDeliveryQuantities.addAll(_splitAddress(m["deliveryQuantitylist"]));
      parsedDeliveryWeights.addAll(List.filled(parsedDeliveryAddresses.length, ""));
    }

    
      List<String> poRemarks = [];
      int notPort = int.tryParse(m["notportchagre"]?.toString() ?? "0") ?? 0;
      int portCPop = int.tryParse(m["portCPop"]?.toString() ?? "0") ?? 0;
      if (portCPop == 1 && notPort == 0) poRemarks.add("Port Charges (PO Pending)");

      int liveCPop = int.tryParse(m["livecpop"]?.toString() ?? "0") ?? 0;
      int notLevy = int.tryParse(m["notLevyChares"]?.toString() ?? "0") ?? 0;
      if (liveCPop == 1 && notLevy == 0) poRemarks.add("Port Charges (LEVY CHARGES PO PENDING)");

      int mmheCPop = int.tryParse(m["mmheCPop"]?.toString() ?? "0") ?? 0;
      int notMmhe = int.tryParse(m["notMMHECPop"]?.toString() ?? "0") ?? 0;
      if (mmheCPop == 1 && notMmhe == 0) poRemarks.add("MMHE AGENT PO PENDING");

      int afPoCPop = int.tryParse(m["afpoCPop"]?.toString() ?? "0") ?? 0;
      int notAfPo = int.tryParse(m["notAFpoCPop"]?.toString() ?? "0") ?? 0;
      if (afPoCPop == 1 && notAfPo == 0) poRemarks.add("AF PO PENDING");

      int sfWpoCPop = int.tryParse(m["sfWpoCPop"]?.toString() ?? "0") ?? 0;
      int notSfWpo = int.tryParse(m["notSFWpoCPop"]?.toString() ?? "0") ?? 0;
      if (sfWpoCPop == 1 && notSfWpo == 0) poRemarks.add("DO CHARGES PO PENDING,SEAFRIEGHT IMPORT");

      int sfeWpoCPop = int.tryParse(m["sfewpoCPop"]?.toString() ?? "0") ?? 0;
      int notSfeWpo = int.tryParse(m["notSFEWpoCPop"]?.toString() ?? "0") ?? 0;
      if (sfeWpoCPop == 1 && notSfeWpo == 0) poRemarks.add("DO CHARGES PO PENDING,SEAFRIEGHT EXPORT");

      int boatCPop = int.tryParse(m["boatCPop"]?.toString() ?? "0") ?? 0;
      int notBoat = int.tryParse(m["notBoatCPop"]?.toString() ?? "0") ?? 0;
      if (boatCPop == 1 && notBoat == 0) poRemarks.add("PO PENDING FOR PORT EQUIPMENT CARGO BOAT");

      int boatCPop1 = int.tryParse(m["boatCPop1"]?.toString() ?? "0") ?? 0;
      int notBoat1 = int.tryParse(m["notBoatCPop1"]?.toString() ?? "0") ?? 0;
      if (boatCPop1 == 1 && notBoat1 == 0) poRemarks.add("PO PENDING FOR PORT EQUIPMENT WHARFMARK CRANE FORKLIFT");

      int permitCPop = int.tryParse(m["permitCPop"]?.toString() ?? "0") ?? 0;
      int notPermit = int.tryParse(m["notPermitCPop"]?.toString() ?? "0") ?? 0;
      if (permitCPop == 1 && notPermit == 0) poRemarks.add("PO PENDING FOR PERMIT OUTWARD PERMIT OR iNWARD");

      int pfppCPop1 = int.tryParse(m["pfppCPop1"]?.toString() ?? "0") ?? 0;
      int notPfpp1 = int.tryParse(m["notPFPPCPop1"]?.toString() ?? "0") ?? 0;
      if (pfppCPop1 == 1 && notPfpp1 == 0) poRemarks.add("(PO FOR PERMIT PENDING ORIGIN OR DESTINATION IS SINGAPORE)");

      var result = base.copyWith(

      editId: isEnquiry ? 0 : (m["id"] ?? 0), enquiryId: isEnquiry ? (m["id"] ?? 0) : 0, totalAmount: double.tryParse(m["amount"]?.toString() ?? "0") ?? 0.0,
        poPendingRemarks: poRemarks, productViewList: List<SaleEditDetailModel>.from(details),
      loadedMaster: isEnquiry ? const {} : m,
      productIds: loadedIds,
      currencyValue: AppGlobals.CustomerCurrencyValue, custId: m["customerRefId"] ?? 0, jobTypeId: m["jobMasterRefId"] ?? 0,
      lAgentCompanyId: m["agentCompanyRefId"] ?? 0, lAgentId: m["agentMasterRefId"] ?? 0, oAgentCompanyId: m["oAgentCompanyRefId"] ?? 0,
      oAgentId: m["oAgentMasterRefId"] ?? 0, originId: m["originRefId"] ?? 0, destinationId: m["destinationRefId"] ?? 0,
      sealEmpId1: m["sealbyRefid"] ?? 0, sealEmpId2: m["sealbyRefid2"] ?? 0, sealEmpId3: m["sealbyRefid3"] ?? 0,
      breakEmpId1: m["sealbreakbyRefid"] ?? 0, breakEmpId2: m["sealbreakbyRefid2"] ?? 0, breakEmpId3: m["sealbreakbyRefid3"] ?? 0,
      boardOfficerId1: m["boardingOfficerRefid"] ?? 0, boardOfficerId2: m["boardingOfficer1Refid"] ?? 0, statusId: m["jStatus"] ?? 0,
      disabledBillType: true, disabledAmount1: true, disabledAmount2: true, dropdownValue: m["billType"] ?? 'MY',
      dropdownValueFW1: m["forwarding"] != "" ? m["forwarding"] : null, dropdownValueFW2: m["forwarding2"] != "" ? m["forwarding2"] : null,
      dropdownValueFW3: m["forwarding3"] != "" ? m["forwarding3"] : null, dropdownValueZB1: m["zb"] != "" ? m["zb"] : null,
      dropdownValueZB2: m["zb2"] != "" ? m["zb2"] : null, dropdownValueTruckSize: m["truckSize"] != null && m["truckSize"] != "" ? m["truckSize"].toString() : null,
      dtpSaleOrderdate: parseDate(m["saleDate"], "yyyy-MM-dd"), dtpLETAdate: m["eta"] != null ? parseDate(m["eta"], "yyyy-MM-dd HH:mm:ss") : now,
      dtpLETBdate: m["etb"] != null ? parseDate(m["etb"], "yyyy-MM-dd HH:mm:ss") : now, dtpLETDdate: m["etd"] != null ? parseDate(m["etd"], "yyyy-MM-dd HH:mm:ss") : now,
      dtpFlightTimedate: m["flighTime"] != null ? parseDate(m["flighTime"], "yyyy-MM-dd HH:mm:ss") : now, dtpOETAdate: m["oeta"] != null ? parseDate(m["oeta"], "yyyy-MM-dd HH:mm:ss") : now,
      dtpOETBdate: m["oetb"] != null ? parseDate(m["oetb"], "yyyy-MM-dd HH:mm:ss") : now, dtpOETDdate: m["oetd"] != null ? parseDate(m["oetd"], "yyyy-MM-dd HH:mm:ss") : now,
      dtpPickUpdate: m["pickupDate"] != null ? parseDate(m["pickupDate"], "yyyy-MM-dd HH:mm:ss") : now, dtpDeliverydate: m["deliveryDate"] != null ? parseDate(m["deliveryDate"], "yyyy-MM-dd HH:mm:ss") : now,
      dtpWHEntrydate: m["wareHouseEnterDate"] != null ? parseDate(m["wareHouseEnterDate"], "yyyy-MM-dd HH:mm:ss") : now, dtpWHExitdate: m["wareHouseExitDate"] != null ? parseDate(m["wareHouseExitDate"], "yyyy-MM-dd HH:mm:ss") : now,
      dtpFW1date: m["forwardingDate"] != null ? parseDate(m["forwardingDate"], "yyyy-MM-dd HH:mm:ss") : now, dtpFW2date: m["forwarding2Date"] != null ? parseDate(m["forwarding2Date"], "yyyy-MM-dd HH:mm:ss") : now,
      dtpFW3date: m["forwarding3Date"] != null ? parseDate(m["forwarding3Date"], "yyyy-MM-dd HH:mm:ss") : now, checkBoxValueLETA: m["eta"] != null,
      checkBoxValueLETB: m["etb"] != null, checkBoxValueLETD: m["etd"] != null, checkBoxValueFlightTime: m["flighTime"] != null,
      checkBoxValueOETA: m["oeta"] != null, checkBoxValueOETB: m["oetb"] != null, checkBoxValueOETD: m["oetd"] != null,
      checkBoxValuePickUp: m["pickupDate"] != null, checkBoxValueDelivery: m["deliveryDate"] != null, checkBoxValueWHEntry: m["wareHouseEnterDate"] != null,
      checkBoxValueWHExit: m["wareHouseExitDate"] != null, checkBoxValueFW1: m["forwardingDate"] != null, checkBoxValueFW2: m["forwarding2Date"] != null,
      checkBoxValueFW3: m["forwarding3Date"] != null, txtJobNo: isEnquiry ? AppGlobals.MaxSaleOrderNum : safeNum(m["cNumber"]),
      txtCustomer: _getFromList(AppGlobals.CustomerList, m["customerRefId"], (e) => e.AccountName), txtJobType: _getFromList(AppGlobals.JobTypeList, m["jobMasterRefId"], (e) => e.Name),
      txtJobStatus: _getFromStatusList(m["jStatus"]), txtSealByEmp1: _getEmpName(m["sealbyRefid"]), txtSealByEmp2: _getEmpName(m["sealbyRefid2"]),
      txtSealByEmp3: _getEmpName(m["sealbyRefid3"]), txtBreakByEmp1: _getEmpName(m["sealbreakbyRefid"]), txtBreakByEmp2: _getEmpName(m["sealbreakbyRefid2"]),
      txtBreakByEmp3: _getEmpName(m["sealbreakbyRefid3"]), txtBoardingOfficer1: _getEmpName(m["boardingOfficerRefid"]), txtBoardingOfficer2: _getEmpName(m["boardingOfficer1Refid"]),

      txtLAgentCompany: _getFromAgentCompany(m["agentCompanyRefId"]), txtLAgentName: lAgentName, txtOAgentCompany: _getFromAgentCompany(m["oAgentCompanyRefId"]), txtOAgentName: oAgentName,

      txtDoDescription: safeStr(m["doDescription"]), txtTruckSize: safeNum(m["truckSize"]),
      txtRemarks: safeStr(m["remarks"]), txtOffVessel: safeStr(m["offvesselname"]), txtLoadingVessel: safeStr(m["loadingvesselname"]), txtLPort: safeStr(m["sPort"]),
      txtOPort: safeStr(m["oPort"]), txtSmk1: safeStr(m["forwardingSMKNo"]), txtSmk2: safeStr(m["forwardingSMKNo2"]), txtSmk3: safeStr(m["forwardingSMKNo3"]),
      txtAWBNo: safeStr(m["awbNo"]), txtBLCopy: safeStr(m["blCopy"]), txtOSCN: safeStr(m["scn"]), txtLSCN: safeStr(m["lscn"]), txtLVesselType: safeStr(m["vessel"]),
      txtOVesselType: safeStr(m["oVessel"]), txtCommodityType: safeStr(m["commodity"]), txtCargo: safeStr(m["cargo"]), txtWeight: safeNum(m["totalWeight"]),
      txtQuantity: safeNum(m["quantity"]), txtOrigin: safeStr(m["origin"]), txtDestination: safeStr(m["destination"]), txtPTWNo: safeStr(m["ptw"]),
      txtENRef1: safeStr(m["forwardingEnterRef"]), txtENRef2: safeStr(m["forwardingEnterRef2"]), txtENRef3: safeStr(m["forwardingEnterRef3"]),
      txtExRef1: safeStr(m["forwardingExitRef"]), txtExRef2: safeStr(m["forwardingExitRef2"]), txtExRef3: safeStr(m["forwardingExitRef3"]),
      txtPortChargeRef1: safeStr(m["portChargesRef"]), txtPortCharges: safeNum(m["portCharges"]), txtAmount1: safeNum(m["boardingAmount"]),
      txtAmount2: safeNum(m["boardingAmount1"]), txtZBRef1: safeStr(m["zbRef"]), txtZBRef2: safeStr(m["zbRef2"]), txtWarehouseAddress: safeStr(m["wareHouseAddress"]),
      txtForwarding1S1: safeStr(m["forwarding1S1"]), txtForwarding1S2: safeStr(m["forwarding1S2"]), txtForwarding2S1: safeStr(m["forwarding2S1"]),
      txtForwarding2S2: safeStr(m["forwarding2S2"]), txtForwarding3S1: safeStr(m["forwarding3S1"]), txtForwarding3S2: safeStr(m["forwarding3S2"]),

      // MAP NEW ARRAYS TO STATE
      pickUpAddressList: parsedPickupAddresses,
      pickUpQuantityList: parsedPickupQuantities,
      pickUpWeightList: parsedPickupWeights,
      deliveryAddressList: parsedDeliveryAddresses,
      deliveryQuantityList: parsedDeliveryQuantities,
      deliveryWeightList: parsedDeliveryWeights,
      txtPickUpAddress: parsedPickupAddresses.isNotEmpty ? parsedPickupAddresses[0] : '',
      txtPickUpQuantity: parsedPickupQuantities.isNotEmpty ? parsedPickupQuantities[0] : '',
      txtPickUpWeight: parsedPickupWeights.isNotEmpty ? parsedPickupWeights[0] : '',
      txtDeliveryAddress: parsedDeliveryAddresses.isNotEmpty ? parsedDeliveryAddresses[0] : '',
      txtDeliveryQuantity: parsedDeliveryQuantities.isNotEmpty ? parsedDeliveryQuantities[0] : '',
      txtDeliveryWeight: parsedDeliveryWeights.isNotEmpty ? parsedDeliveryWeights[0] : '',
      pickUpUpdateIndex: parsedPickupAddresses.isNotEmpty ? 0 : null,
      deliveryUpdateIndex: parsedDeliveryAddresses.isNotEmpty ? 0 : null,
    );
    return _applyVisibility(result);
  }
  /// Each leg's PTP call: the one picked on this visit, else the one it was saved with.
  Map<String, LegCall> _legCalls(SalesOrderAddLoaded s) {
    final calls = Map<String, LegCall>.of(s.savedLegCalls);
    for (final (leg, pick) in [(VesselLeg.loading, s.pickedLoading), (VesselLeg.off, s.pickedOff)]) {
      final call = pick?.call;
      if (pick != null && call != null) calls[leg] = LegCall(pick.name, call);
    }
    return calls;
  }

  /// The saved legs' PTP calls with PTP's current times; a failed read only means no PTP warning.
  Future<Map<String, LegCall>> _savedLegCalls(int saleOrderId) async {
    if (saleOrderId <= 0) return const {};
    try {
      return {
        for (final link in await _vesselMasters.links(saleOrderId))
          if (link.call != null) link.leg: LegCall(link.vesselName ?? '', link.call!),
      };
    } catch (e, st) {
      AppLogger.instance.logError(e, st, 'Sale order vessel links');
      return const {};
    }
  }

  String _getFromList<T>(List<T> list, dynamic id, String Function(T) getName) { if (id == null || id == 0) return ''; try { return getName((list as List).firstWhere((e) => (e as dynamic).Id == id) as T); } catch (_) { return ''; } }
  String _getFromStatusList(dynamic id) { if (id == null || id == 0) return ''; try { return AppGlobals.JobAllStatusList.firstWhere((e) => e.Status == id).StatusName; } catch (_) { return ''; } }
  String _getEmpName(dynamic id) { if (id == null || id == 0) return ''; try { return AppGlobals.EmployeeList.firstWhere((e) => e.Id == id).AccountName; } catch (_) { return ''; } }
  String _getFromAgentCompany(dynamic id) { if (id == null || id == 0) return ''; try { return AppGlobals.AgentCompanyList.firstWhere((e) => e.Id == id).Name; } catch (_) { return ''; } }
  String _getFromAgentAll(dynamic id) { if (id == null || id == 0) return ''; try { return AppGlobals.AgentAllList.firstWhere((e) => e.Id == id).AgentName; } catch (_) { return ''; } }
  List<dynamic> _splitAddress(dynamic val) { if (val == null || val.toString().isEmpty) return []; final str = val.toString(); return str.contains('{@}') ? str.split('{@}') : [str]; }

  /// The invoice number of an invoiced job; the form opens without it when the lookup fails.
  Future<String> _invoiceNo(int saleOrderId) async {
    try {
      final link = await _saleOrders.invoiceLink(saleOrderId);
      return link['invoiced'] == true ? '${link['invoiceNo'] ?? ''}' : '';
    } catch (_) {
      return '';
    }
  }

  /// The enquiry this order came from is CONFIRMED (shared Java enquiry API).
  Future<void> _confirmEnquiry(int id) => sl<EnquiryApi>().setStatus(id, 'CONFIRMED');



}