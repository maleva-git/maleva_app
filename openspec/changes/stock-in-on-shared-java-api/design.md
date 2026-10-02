# Design

| Screen call | Was (bridge, .NET shape) | Now |
|---|---|---|
| next stock number | StockApp/MaxStockInNo → `[{MaxNo}]` | GET /api/stock-ins/next-number → `"STI..."` |
| jobs with a stock-in | StockApp/SelectStockJob → `[{Id}]` | GET /api/stock-ins/jobs → `[40, 41]` |
| job details | StockApp/SelectSaleStock | GET /api/stock-ins/sale-orders?id= |
| stock by label | StockApp/EditStockIn (barcodeLabel) → `Data1[0]` | GET /api/stock-ins/entries/by-label → one object |
| save | StockApp/InsertStockIn → `Data2` id | POST /api/stock-ins/entries → `Data1` id |
| arrival | StockApp/UpdateStockIn (query + URL list body) | PUT /entries/{id}/arrival `{statusId, portId, imageUrls}` |
| transfer | StockApp/UpdateStockTransfer | PUT /entries/{id}/transfer `{portId}` |
| label print | StockApp/SelectStockPrint | GET /entries/{id}/label |
| warehouses | StockApp/SelectPortList | GET /api/stock-ins/warehouses |

Unchanged on these screens (other features): GetJobNo, job steps (shared lookups), the sale order
edit read, image delete, the boarding officer save.
