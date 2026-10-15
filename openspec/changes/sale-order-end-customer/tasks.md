## 1. Data

- [x] 1.1 `lib/core/end_customer/end_customer_api.dart`: model, `forCustomer`, `quickAdd`; register in `auth_injection.dart`
- [x] 1.2 `SaleOrderMasterModel.EndCustomerName`

## 2. Sales order form

- [x] 2.1 State `endCustomerId` / `txtEndCustomer`, event `EndCustomerSelected`, cleared on customer change, loaded on edit
- [x] 2.2 Save body `endCustomerRefId`
- [x] 2.3 End Customer field and `end_customer_sheet.dart`

## 3. List

- [x] 3.1 "for <end customer>" under the customer name in the list card and rows

## 4. Verify

- [x] 4.1 `flutter analyze`: no errors, nothing new in the changed files; `sale_order_save_body_test.dart` and the end customer API test pass
- [ ] 4.2 Owner: on a device after the SQL and backend deploy, add Daikin under CIVA, save, reopen
