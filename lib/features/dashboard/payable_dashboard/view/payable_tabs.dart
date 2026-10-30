/// The Payable dashboard's tabs in their order (change `payable-desk-today`): payable work first, the
/// fleet tabs unchanged at the end. The tab bar, the pages and the Today tab's Open buttons all read
/// this one list, so no tab number is written twice.
enum PayableTab {
  today('Today'),
  reminders('Reminders'),
  spend('PO & Vouchers'),
  records('Records'),
  completed('Completed'),
  payments('Payments'),
  pettyCash('Petty Cash'),
  expenses('Expenses'),
  driverSalary('Driver Salary'),
  irReport('IR Report'),
  empLeave('Emp Leave'),
  fuelFilling('Fuel Filling'),
  speeding('Speeding'),
  engineHours('Engine Hours'),
  fuel('Fuel'),
  driver('Driver'),
  truck('Truck');

  const PayableTab(this.label);

  final String label;
}
