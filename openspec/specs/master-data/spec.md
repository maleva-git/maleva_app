# Master data and selection

## Purpose

Describe the company-scoped lookup requests used to select customers, employees, vehicles, jobs, locations, and related data.

## Evidence and scope

Baseline established on 2026-10-01 by static inspection of the Flutter client. These requirements describe observed client behavior; scenarios have not been exercised against a live backend or device during this setup. Known inconsistencies are observations, not newly approved behavior.

Source evidence:

- [lib/core/network/api_services/master_api.dart](../../../lib/core/network/api_services/master_api.dart)
- [lib/features/mastersearch/Customer.dart](../../../lib/features/mastersearch/Customer.dart)
- [lib/features/mastersearch/Employee.dart](../../../lib/features/mastersearch/Employee.dart)
- [lib/features/mastersearch/Truck.dart](../../../lib/features/mastersearch/Truck.dart)
- [lib/features/ir_report/data/repositories/ir_repository_impl.dart](../../../lib/features/ir_report/data/repositories/ir_repository_impl.dart)

## Requirements

### Requirement: Load company lookup data

Lookup requests SHALL include the company context and endpoint-specific filters used by the caller.

#### Scenario: Employee lookup
- **WHEN** a caller requests employees with type and user-type filters
- **THEN** the client includes company ID and the requested filters in the employee lookup URL.

#### Scenario: Agent lookup
- **WHEN** a caller requests agents for an agent company
- **THEN** the client includes that company reference in the agent request.

### Requirement: Prepare incident form lookup choices

The incident form SHALL load statuses, departments, trucks, drivers, and employees, excluding zero-ID party choices and sorting party names without regard to case.

#### Scenario: Party lookup list
- **WHEN** master rows are returned for the incident form
- **THEN** zero-ID rows are removed from truck, driver, and employee choices and the remaining names are sorted.

## Clarifications

Q06 covers master-data semantics and deployment-specific values. The lookup inventory does not assert that every picker has identical filtering behavior. See [the clarification register](../../baseline/clarifications.md).
