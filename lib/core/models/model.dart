// GENERATED BARREL FILE
// This file exports all models for backward compatibility.
// ignore_for_file: non_constant_identifier_names
// class LicenseViewModel {
//   String LicenseName;
//   String Category;
//   String ExpiryDate;
//   String LDate;
//   int Active;
//
//   // ✅ Constructor
//   LicenseViewModel(
//       this.LicenseName,
//       this.Category,
//       this.ExpiryDate,
//       this.LDate,
//       this.Active,
//       );
//
//   // ✅ fromJson factory constructor
//   factory LicenseViewModel.fromJson(Map<String, dynamic> json) {
//     return LicenseViewModel(
//       json['LicenseName'] ?? "",
//       json['Category'] ?? "",
//       json['ExpiryDate'] ?? "",
//       json['LDate'] ?? "",
//       json['Active'] ?? 0,
//     );
//   }
//
//   // ✅ toJson method
//   Map<String, dynamic> toJson() {
//     return {
//       'LicenseName': LicenseName,
//       'Category': Category,
//       'ExpiryDate': ExpiryDate,
//       'LDate': LDate,
//       'Active': Active,
//     };
//   }
//
//   // ✅ Empty constructor for default initialization
//   LicenseViewModel.Empty()
//       : LicenseName = "",
//         Category = "",
//         ExpiryDate = "",
//         LDate = "",
//         Active = 0;
// }
export '../../features/transaction/enquirytrmaster/models/enquiry_master_model.dart';
export 'shared/list_item.dart';
export '../../features/transport/models/maintenance_model.dart';
export 'shared/review.dart';
export 'shared/email_model.dart';
export 'shared/employee_details_model.dart';
export 'shared/employee_model.dart';
export 'shared/driver_details_model.dart';
export 'shared/bill_order_master.dart';
export 'shared/bill_order_detail.dart';
export 'shared/bo_detail_response.dart';
export '../../features/transport/models/fuel_filling.dart';
export 'shared/engine_hoursdata.dart';
export 'shared/pattycash_master_model.dart';
export 'shared/patty_cash_details_model.dart';
export 'shared/speeding_view.dart';
export 'shared/customer_model.dart';
export 'shared/location_model.dart';
export 'shared/ware_house_model.dart';
export 'shared/get_truck_model.dart';
export '../../features/operations/models/job_type_details_model.dart';
export '../../features/operations/models/job_status_model.dart';
export '../../features/operations/models/job_type_model.dart';
export '../../features/operations/models/job_all_status_model.dart';
export 'shared/agent_company_model.dart';
export 'shared/agent_model.dart';
export 'shared/product_model.dart';
export 'shared/truck_details_model.dart';
export 'shared/payment_pending_model.dart';
export 'shared/inventory_model.dart';
export 'shared/mainsetting_model.dart';
export 'shared/menu_master_model.dart';
export 'shared/bluetooth_model.dart';
export '../../features/transaction/salesorder/models/sale_order_master_model.dart';
export '../../features/transaction/salesorder/models/sale_order_detail_model.dart';
export 'shared/planning_detail_model.dart';
export 'shared/planning_master_model.dart';
export 'shared/sale_edit_detail_model.dart';
export 'shared/address_details_model.dart';
export 'shared/r_t_i_master_view_model.dart';
export 'shared/r_t_i_details_view_model.dart';
export '../../features/transport/models/fuelselect_model.dart';
export 'shared/bill_view_model.dart';
export 'shared/license_view_model.dart';
export 'shared/barcode_print_model.dart';
