## ADDED Requirements

### Requirement: Product picker on the shared API

The product picker SHALL read `/api/item-masters/company/{companyId}/products` directly and its Java
fields, without the .NET-shaped adapter.

#### Scenario: Pick a product
- **WHEN** the product picker opens
- **THEN** the app lists the company's products from the shared endpoint with their codes and rates
