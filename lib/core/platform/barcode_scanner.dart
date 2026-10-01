import '../utils/app_globals.dart';
import '../utils/system_helpers.dart';

abstract interface class BarcodeScanner {
  Future<String?> scan();
}

class ExistingBarcodeScanner implements BarcodeScanner {
  const ExistingBarcodeScanner();
  @override
  Future<String?> scan() async {
    await SystemHelpers.barcodeScanning();
    if (AppGlobals.barcodeerror == true) return null;
    return AppGlobals.barcodestring;
  }
}
