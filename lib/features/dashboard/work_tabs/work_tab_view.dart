import 'package:flutter/material.dart';
import 'package:maleva/features/dashboard/common_tabs/driverleave/view/employee_leave_request_tab.dart';
import 'package:maleva/features/dashboard/common_tabs/inventoryreport/view/inventoryview_tab.dart';
import 'package:maleva/features/dashboard/common_tabs/salary/view/salary_tab.dart';
import 'package:maleva/features/dashboard/common_tabs/spotsaleorder/view/spotsaleorder_add.dart';
import 'package:maleva/features/dashboard/common_tabs/vesselreport/view/vesselreportview_tab.dart';
import 'package:maleva/features/dashboard/forwarding_agent_dashboard/view/rti_route_activities_tab.dart';
import 'package:maleva/features/forwarding_requests/view/forwarding_requests_page.dart';
import 'package:maleva/features/ir_report/presentation/pages/ir_report_tab.dart';
import 'package:maleva/features/transaction/prealertview/view/prealertview_tab.dart';

import 'seal_break_seal_tab.dart';
import 'work_tabs.dart';

/// The body of a work dashboard tab: the same widgets the dashboards showed before.
Widget workTabView(WorkTab tab) {
  switch (tab) {
    case WorkTab.vsl:
      return const VesselReportPage();
    case WorkTab.salary:
      return const SalaryTab();
    case WorkTab.spotSaleOrder:
      return const SpotSaleEntryPage();
    case WorkTab.irReport:
      return const IrReportTab();
    case WorkTab.inventoryReport:
      return const InventoryPage();
    case WorkTab.empLeave:
      return const EmployeeLeaveRequestTab();
    case WorkTab.rtiActivities:
      return const RtiRouteActivitiesTab();
    case WorkTab.fwRequests:
      // The planning list of Customer Service's forwarding requests (forwarding-requests-on-shared-java-api)
      return const ForwardingRequestsBody();
    case WorkTab.sealBreakSeal:
      return const SealBreakSealTab();
    case WorkTab.preAlert:
      // ETA All, Delivery Done, own ports (boarding-pre-alert-tab)
      return const PreAlertReportBody(workMode: true);
  }
}
