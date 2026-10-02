/// The Java sale order field name for a .NET one (`AWBNo` -> `awbNo`, `SPort` -> `sPort`,
/// `DODescription` -> `doDescription`, `OETA` -> `oeta`), for rows that still come from
/// .NET (enquiries) and must be read as a Java sale order.
///
/// Transitional (change `sale-order-on-shared-java-api`): delete with the enquiry move.
String javaSaleOrderKey(String dotNetKey) {
  final special = _special[dotNetKey];
  if (special != null) return special;
  if (dotNetKey.isEmpty) return dotNetKey;
  if (dotNetKey == dotNetKey.toUpperCase()) return dotNetKey.toLowerCase();
  var run = 0;
  while (run < dotNetKey.length && _isUpper(dotNetKey[run])) {
    run++;
  }
  if (run <= 1) return dotNetKey[0].toLowerCase() + dotNetKey.substring(1);
  // "AWBNo": the last capital of the run starts the next word
  return dotNetKey.substring(0, run - 1).toLowerCase() + dotNetKey.substring(run - 1);
}

/// An enquiry (or any .NET sale order row) with the Java field names.
Map<String, dynamic> javaSaleOrderFromDotNet(Map<dynamic, dynamic> row) => {
      for (final e in row.entries) javaSaleOrderKey(e.key.toString()): e.value,
    };

bool _isUpper(String c) => c.toUpperCase() == c && c.toLowerCase() != c;

/// Java spells these differently from the rule.
const _special = {
  'LiveCPop': 'livecpop',
  'MMHECPop': 'mmheCPop',
  'AFpoCPop': 'afpoCPop',
  'SFEWpoCPop': 'sfewpoCPop',
  'PFPPCPop1': 'pfppCPop1',
  'pickupQuantitylist': 'pickupQuantitylist',
  'DeliveryQuantitylist': 'deliveryQuantitylist',
};
