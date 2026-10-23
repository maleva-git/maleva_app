import 'package:maleva/core/session/work_jobs.dart';

/// A tab on the boarding or forwarding agent dashboard.
enum WorkTab {
  vsl,
  salary,
  spotSaleOrder,
  irReport,
  inventoryReport,
  empLeave,
  rtiActivities,
  fwRequests,
  sealBreakSeal,
  preAlert,
}

/// Which work dashboard is showing; the main role picks it (dashboard_routes.dart).
enum WorkDashboard { boarding, forwardingAgent }

/// The tabs of a work dashboard: today's tabs for the main role, then the tabs
/// of the extra jobs, each tab once (openspec change employee-extra-jobs-and-driver-mode).
///
/// With no extra jobs the list is exactly the one before this change:
/// - boarding, role 500: VSL, Salary, EmpLeave, IR Report
/// - boarding, role 600: VSL, Salary, SpotsSaleOrder, IR Report, InventoryReport, EmpLeave
/// - forwarding agent: Emp Leave, RTI Activities, IR Report
/// FW Requests is not shown on either dashboard (owner, 2026-10-20: boarding officers
/// and forwarding agents do not need it; Sales / Air Freight keep their own tab).
/// with Pre Alert as the second tab, one tap from the first (boarding-pre-alert-tab:
/// ETA All, Delivery Done, the user's own ports).
List<WorkTab> workTabsFor(WorkDashboard dashboard, WorkJobs jobs) {
  final tabs = <WorkTab>[];
  void add(WorkTab tab) {
    if (!tabs.contains(tab)) tabs.add(tab);
  }

  if (dashboard == WorkDashboard.boarding) {
    add(WorkTab.vsl);
    add(WorkTab.preAlert);
    add(WorkTab.salary);
    if (jobs.isBoardingOfficerOnly) {
      add(WorkTab.empLeave);
      add(WorkTab.irReport);
    } else {
      add(WorkTab.spotSaleOrder);
      add(WorkTab.irReport);
      add(WorkTab.inventoryReport);
      add(WorkTab.empLeave);
    }
    // Forwarding work for a boarding person (seal and break seal).
    if (jobs.isForwardingAgent) {
      add(WorkTab.rtiActivities);
      add(WorkTab.sealBreakSeal);
    }
    return tabs;
  }

  add(WorkTab.empLeave);
  add(WorkTab.preAlert);
  add(WorkTab.rtiActivities);
  add(WorkTab.irReport);
  // Boarding work for a forwarding agent.
  if (jobs.isBoarding) {
    add(WorkTab.vsl);
    if (jobs.isBoardingAdmin) {
      add(WorkTab.spotSaleOrder);
      add(WorkTab.inventoryReport);
    }
  }
  return tabs;
}

/// The tab label, as each dashboard wrote it before.
String workTabLabel(WorkTab tab, WorkDashboard dashboard) {
  switch (tab) {
    case WorkTab.vsl:
      return 'VSL';
    case WorkTab.salary:
      return 'Salary';
    case WorkTab.spotSaleOrder:
      return 'SpotsSaleOrder';
    case WorkTab.irReport:
      return 'IR Report';
    case WorkTab.inventoryReport:
      return 'InventoryReport';
    case WorkTab.empLeave:
      return dashboard == WorkDashboard.boarding ? 'EmpLeave' : 'Emp Leave';
    case WorkTab.rtiActivities:
      return 'RTI Activities';
    case WorkTab.fwRequests:
      return 'FW Requests';
    case WorkTab.sealBreakSeal:
      return 'Seal / Break Seal';
    case WorkTab.preAlert:
      return 'Pre Alert';
  }
}
