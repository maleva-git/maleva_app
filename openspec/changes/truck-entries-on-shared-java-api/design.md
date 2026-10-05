# Design

`TruckEntriesApi(Dio, {companyId})` follows the same pattern as the other shared APIs:
- `spareParts`, `summons` and `spotSales` call the `/entries` lists with `companyId`, `fromDate`
  and `toDate`, each cut to `yyyy-MM-dd`.
- `saveSpareParts` posts a Dio `FormData` with two parts:
  - `entry`: a JSON part, `{id, truckId, driverName, spareParts, amount, entryDate}`;
  - `files`: one per document (the image and the PDF).

The repositories return the Java rows (`List<Map>`) to the blocs, which already kept raw rows. The
views read the camelCase keys. The spare parts bloc turns the picked truck (its id as text) and the
amount text into numbers.
