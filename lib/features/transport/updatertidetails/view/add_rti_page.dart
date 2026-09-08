import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/network/legacy_api_repository.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/features/mastersearch/Driver.dart';
import 'package:maleva/features/mastersearch/Truck.dart';
import 'package:maleva/core/models/shared/get_truck_model.dart';


const kGradient = LinearGradient(
  colors: [Palette.blue700, Palette.blue400],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class AddRtiPage extends StatefulWidget {
  final List<dynamic>? initialJobs;
  final dynamic editMaster;
  final List<dynamic>? editDetails;

  const AddRtiPage({Key? key, this.initialJobs, this.editMaster, this.editDetails}) : super(key: key);

  @override
  State<AddRtiPage> createState() => _AddRtiPageState();
}

class _AddRtiPageState extends State<AddRtiPage> {
  final TextEditingController _rtiNoCtrl = TextEditingController();
  String _rtiDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
  
  int _driverId = 0;
  String _driverName = '';
  
  int _vehicleId = 0;
  String _vehicleNo = '';
  
  String _enterVal = '';
  String _exitVal = '';
  
  String _sleepingAllow = 'NO';
  String _emptyPickup = '';
  String _emptyDelivery = '';
  String _addPickup = 'NO';
  String _addDrop = 'NO';
  
  bool _punctuality = false;
  bool _docSub = false;
  bool _multiPickup = false;
  
  final TextEditingController _destinationCtrl = TextEditingController();
  final TextEditingController _sealByCtrl = TextEditingController();
  final TextEditingController _breakSealByCtrl = TextEditingController();
  final TextEditingController _remarksCtrl = TextEditingController();
  final TextEditingController _commentsCtrl = TextEditingController();
  
  String _manpower = 'NO';
  
  List<Map<String, dynamic>> _jobDetails = [];
  
  int _rtiId = 0;
  bool _isLoading = false;
  double _totalAmount = 0.0;
  
  @override
  void initState() {
    super.initState();
    if (widget.editMaster != null) {
      _loadEditData();
    } else {
      _fetchMaxRtiNo();
      if (widget.initialJobs != null && widget.initialJobs!.isNotEmpty) {
        _loadInitialJobs(widget.initialJobs!);
      }
    }
  }

  Future<void> _loadEditData() async {
    final m = widget.editMaster;
    setState(() => _isLoading = true);
    try {
      final comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
      final payload = {
        'Id': m.Id ?? 0,
        'SaleReturnNo': 0,
        'Comid': comid
      };
      
      final header = {'Content-Type': 'application/json; charset=UTF-8'};
      
      final res = await sl<LegacyApiRepository>().apiAllinone('${ApiConstants.port}/RTI/EditRTI', payload, header);
      
      if (res != null && res['ok'] == true && res['Data'] != null && (res['Data'] as List).isNotEmpty) {
        final data = res['Data'][0];
        setState(() {
          _rtiId = data['Id'] ?? 0;
          _rtiNoCtrl.text = data['CNumber']?.toString() ?? '';
          try {
            if (data['SSaleDate'] != null && data['SSaleDate'].toString().contains('/Date(')) {
              final ms = int.parse(data['SSaleDate'].toString().replaceAll(RegExp(r'[^0-9]'), ''));
              _rtiDate = DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(ms));
            } else if (data['SSaleDate'] != null) {
              _rtiDate = DateFormat('dd/MM/yyyy').format(DateTime.parse(data['SSaleDate']));
            } else {
              _rtiDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
            }
          } catch(e) {
             _rtiDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
          }
          
          _driverId = data['DriverMasterRefId'] ?? 0;
          _driverName = data['DriverName']?.toString() ?? '';
          if (_driverName.isEmpty && m.DriverName != null) _driverName = m.DriverName.toString();
          
          _vehicleId = data['TruckRefid'] ?? 0;
          _vehicleNo = data['TruckName']?.toString() ?? '';
          if (_vehicleNo.isEmpty && m.TruckName != null) _vehicleNo = m.TruckName.toString();
          
          _enterVal = data['ELink'] == null || data['ELink'] == 0 ? '' : (data['ELink'] == 1 ? 'LINK 1' : 'LINK 2');
          _exitVal = data['EXLink'] == null || data['EXLink'] == 0 ? '' : (data['EXLink'] == 1 ? 'LINK 1' : 'LINK 2');
          
          if (data['ELink'] is String) _enterVal = data['ELink'];
          if (data['EXLink'] is String) _exitVal = data['EXLink'];
          
          _sleepingAllow = data['Sleeping'] == 1 ? 'YES' : 'NO';
          _emptyPickup = data['ExitYN'] == 0 ? '' : (data['ExitYN'] == 1 ? 'EMPTY 50' : 'EMPTY 80');
          _emptyDelivery = data['EmptyDeliveryYN'] == 0 ? '' : (data['EmptyDeliveryYN'] == 1 ? 'EMPTY 50' : 'EMPTY 80');
          _addPickup = data['Pickup'] == 1 ? 'YES' : 'NO';
          _addDrop = data['AddDrop'] == 1 ? 'YES' : 'NO';
          _manpower = data['Manpw'] == 0 ? 'NO' : 'YES';
          
          _punctuality = data['Punctuality'] == 1;
          _docSub = data['DocumentSub'] == 1;
          _multiPickup = data['PckHandling'] == 1;
          
          _destinationCtrl.text = data['Destination']?.toString() ?? '';
          _sealByCtrl.text = data['SealBy']?.toString() ?? '';
          _breakSealByCtrl.text = data['BreakSealBy']?.toString() ?? '';
          _remarksCtrl.text = data['Remarks']?.toString() ?? '';
          _commentsCtrl.text = data['Comments']?.toString() ?? '';
        });
        
        if (data['SaleDetails'] != null) {
          _jobDetails.clear();
          for (var d in data['SaleDetails']) {
            _jobDetails.add({
              'id': d['SaleOrderMasterRefId'] ?? 0,
              'rtidetailsId': d['SDId'] ?? 0,
              'jobNo': d['JobNo']?.toString() ?? '',
              'customer': d['CustomerName']?.toString() ?? '',
              'date': () {
                if (d['JobDate'] == null) return '';
                try {
                  if (d['JobDate'].toString().contains('/Date(')) {
                    final ms = int.parse(d['JobDate'].toString().replaceAll(RegExp(r'[^0-9]'), ''));
                    return DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(ms));
                  }
                  return DateFormat('dd/MM/yyyy').format(DateTime.parse(d['JobDate']));
                } catch(e) {
                  return '';
                }
              }(),
              'salary': d['Salary'] ?? 0.0,
              'ppic': d['PPIC']?.toString() ?? '',
              'dpic': d['DPIC']?.toString() ?? '',
              'pwd': d['PWDType'] ?? 0,
              'origin': d['OriginD']?.toString() ?? '',
              'destination': d['DestinationD']?.toString() ?? '',
              'pickupDate': d['PickupDateD']?.toString() ?? '',
              'deliveryDate': d['DeliveryDateD']?.toString() ?? '',
            });
          }
          _calculateAmount();
        }
      }
    } catch(e, s) {
      debugPrint("Error loading EditRTI: $e\n$s");
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading RTI details: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  Future<void> _fetchMaxRtiNo() async {
    setState(() => _isLoading = true);
    try {
      final comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
      final repo = sl<LegacyApiRepository>();
      final res = await repo.apiAllinone('${ApiConstants.port}/RTI/MaxRTINo', {"Comid": comid});
      if (res != null && res.isNotEmpty) {
         if (mounted) setState(() => _rtiNoCtrl.text = res['No']?.toString() ?? '');
      }
    } catch (e) {
      debugPrint("Error fetching max RTI No: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _loadInitialJobs(List<dynamic> jobs) {
    setState(() {
      _jobDetails = jobs.map((job) => {
        'id': job['Id'] ?? 0,
        'jobNo': job['JobNo'] ?? '',
        'customer': job['CustomerName'] ?? '',
        'date': job['JobDate'] ?? '',
        'salary': job['Salary'] ?? 0,
        'ppic': '',
        'dpic': '',
        'pwd': '',
      }).toList();
    });
    _calculateAmount();
  }

  void _calculateAmount() {
    double total = 0.0;
    for (var job in _jobDetails) {
      total += double.tryParse(job['salary'].toString()) ?? 0.0;
    }
    if (_sleepingAllow == 'YES') total += 50.0;
    if (_exitVal == 'EMPTY 80') total += 80.0;
    else if (_exitVal == 'EMPTY 50') total += 50.0;
    if (_emptyDelivery == 'EMPTY 80') total += 80.0;
    else if (_emptyDelivery == 'EMPTY 50') total += 50.0; 
    
    setState(() {
      _totalAmount = total;
    });
  }

  Future<void> _addJobManually() async {
    // Controllers for the add job form
    final jobNoCtrl = TextEditingController();
    final customerCtrl = TextEditingController();
    final salaryCtrl = TextEditingController(text: '0');
    final ppicCtrl = TextEditingController();
    final dpicCtrl = TextEditingController();
    final originCtrl = TextEditingController();
    final destinationCtrl = TextEditingController();
    int pwdType = 0;
    String pickupDate = '';
    String deliveryDate = '';
    int saleOrderId = 0;
    bool isSearching = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          // Helper: search job from API and auto-fill fields
          Future<void> searchJob() async {
            if (jobNoCtrl.text.trim().isEmpty) return;
            setSheetState(() => isSearching = true);
            try {
              final comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
              final repo = sl<LegacyApiRepository>();
              final res = await repo.apiAllinone(
                '${ApiConstants.port}/RTI/SearchJobNo',
                {"JobNo": jobNoCtrl.text.trim(), "Comid": comid},
              );
              if (res != null && res['ok'] == true && res['Data'] != null) {
                final dataList = res['Data'];
                if (dataList is List && dataList.isNotEmpty) {
                  final job = dataList[0];
                  saleOrderId = job['SaleOrderMasterRefId'] ?? job['Id'] ?? 0;
                  setSheetState(() {
                    customerCtrl.text = job['CustomerName']?.toString() ?? '';
                    salaryCtrl.text = (job['Salary'] ?? 0).toString();
                    originCtrl.text = job['Origin']?.toString() ?? '';
                    destinationCtrl.text = job['Destination']?.toString() ?? '';
                  });
                } else {
                  if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Job not found')));
                }
              } else {
                if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Job not found')));
              }
            } catch (e) {
              if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
            } finally {
              setSheetState(() => isSearching = false);
            }
          }

          // Helper: date picker
          Future<void> pickDate(String current, Function(String) onPicked) async {
            DateTime initial = DateTime.now();
            if (current.isNotEmpty) {
              try { initial = DateFormat('dd/MM/yyyy').parse(current); } catch (_) {}
            }
            final picked = await showDatePicker(
              context: ctx, initialDate: initial,
              firstDate: DateTime(2020), lastDate: DateTime(2035),
            );
            if (picked != null) onPicked(DateFormat('dd/MM/yyyy').format(picked));
          }

          InputDecoration fieldDecor(String hint) => InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            isDense: true,
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Palette.blue700, width: 1.5)),
          );

          Widget label(String text) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
          );

          return DraggableScrollableSheet(
            initialChildSize: 0.92,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, scrollCtrl) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 4),
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Add Job', style: AppTypography.heading2(color: Palette.blue700)),
                        IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Form fields
                  Expanded(
                    child: ListView(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Job No + Search button
                        label('Job No *'),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: jobNoCtrl,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                textCapitalization: TextCapitalization.characters,
                                decoration: fieldDecor('Enter Job No'),
                                onSubmitted: (_) => searchJob(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: isSearching ? null : searchJob,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Palette.blue700,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: isSearching
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text('SEARCH', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Customer Name
                        label('Customer Name'),
                        TextField(controller: customerCtrl, style: const TextStyle(fontSize: 13), decoration: fieldDecor('Customer Name')),
                        const SizedBox(height: 12),

                        // Salary
                        label('Salary (RM)'),
                        TextField(
                          controller: salaryCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(fontSize: 13),
                          decoration: fieldDecor('0.00'),
                        ),
                        const SizedBox(height: 12),

                        // PPIC / DPIC
                        Row(
                          children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              label('PPIC'),
                              TextField(controller: ppicCtrl, style: const TextStyle(fontSize: 13), decoration: fieldDecor('PPIC')),
                            ])),
                            const SizedBox(width: 10),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              label('DPIC'),
                              TextField(controller: dpicCtrl, style: const TextStyle(fontSize: 13), decoration: fieldDecor('DPIC')),
                            ])),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // PWD Type
                        label('PWD Type'),
                        DropdownButtonFormField<int>(
                          value: pwdType,
                          decoration: fieldDecor('').copyWith(contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                          items: const [
                            DropdownMenuItem(value: 0, child: Text('0 - None', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 1, child: Text('1 - Type 1', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 2, child: Text('2 - Type 2', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 3, child: Text('3 - Type 3', style: TextStyle(fontSize: 13))),
                          ],
                          onChanged: (v) => setSheetState(() => pwdType = v ?? 0),
                        ),
                        const SizedBox(height: 12),

                        // Origin / Destination
                        Row(
                          children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              label('Origin'),
                              TextField(controller: originCtrl, style: const TextStyle(fontSize: 13), decoration: fieldDecor('Origin')),
                            ])),
                            const SizedBox(width: 10),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              label('Destination'),
                              TextField(controller: destinationCtrl, style: const TextStyle(fontSize: 13), decoration: fieldDecor('Destination')),
                            ])),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Pickup Date
                        label('Pickup Date'),
                        InkWell(
                          onTap: () => pickDate(pickupDate, (v) => setSheetState(() => pickupDate = v)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(pickupDate.isEmpty ? 'Select date' : pickupDate, style: TextStyle(fontSize: 13, color: pickupDate.isEmpty ? Colors.grey.shade400 : Colors.black87)),
                                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Delivery Date
                        label('Delivery Date'),
                        InkWell(
                          onTap: () => pickDate(deliveryDate, (v) => setSheetState(() => deliveryDate = v)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(deliveryDate.isEmpty ? 'Select date' : deliveryDate, style: TextStyle(fontSize: 13, color: deliveryDate.isEmpty ? Colors.grey.shade400 : Colors.black87)),
                                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  // ADD button
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (jobNoCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Please enter Job No')));
                            return;
                          }
                          final newJob = {
                            'id': saleOrderId,
                            'rtidetailsId': 0,
                            'jobNo': jobNoCtrl.text.trim(),
                            'customer': customerCtrl.text.trim(),
                            'date': '',
                            'salary': double.tryParse(salaryCtrl.text) ?? 0.0,
                            'ppic': ppicCtrl.text.trim(),
                            'dpic': dpicCtrl.text.trim(),
                            'pwd': pwdType,
                            'origin': originCtrl.text.trim(),
                            'destination': destinationCtrl.text.trim(),
                            'pickupDate': pickupDate,
                            'deliveryDate': deliveryDate,
                          };
                          Navigator.pop(ctx);
                          setState(() => _jobDetails.add(newJob));
                          _calculateAmount();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Palette.blue700,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('ADD JOB', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Future<void> _viewRTI() async {
    if (_rtiId == 0) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please load or save an RTI first.')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
      final repo = sl<LegacyApiRepository>();
      final res = await repo.apiAllinone('${ApiConstants.port}/RTI/RTIView', {'SoId': _rtiId, 'Comid': comid});
      if (res != null && res['ok'] == true) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final urlString = "${ApiConstants.port}/Reports/ReportViewer.aspx?ReportName=RTIReport&TimeStamp=$timestamp";
        final uri = Uri.parse(urlString);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open PDF viewer.')));
        }
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to generate PDF view.')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error viewing RTI: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadReviseData() async {
    if (_rtiId == 0) return;
    
    bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Load'),
        content: const Text('Do you want to revise data from Sales Orders?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('LOAD', style: TextStyle(color: Colors.blue))),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
      final payload = {
        'Id': _rtiId,
        'SaleReturnNo': 0,
        'Comid': comid
      };
      final res = await sl<LegacyApiRepository>().apiAllinone('${ApiConstants.port}/RTI/ReviseRTI', payload, {'Content-Type': 'application/json; charset=UTF-8'});
      if (res != null && res['ok'] == true && res['Data'] != null && (res['Data'] as List).isNotEmpty) {
        final data = res['Data'][0];
        if (data['SaleDetails'] != null) {
          _jobDetails.clear();
          for (var d in data['SaleDetails']) {
            _jobDetails.add({
              'id': d['SaleOrderMasterRefId'] ?? 0,
              'rtidetailsId': d['SDId'] ?? d['Id'] ?? 0,
              'jobNo': d['JobNo']?.toString() ?? '',
              'customer': d['CustomerName']?.toString() ?? '',
              'date': () {
                if (d['JobDate'] == null) return '';
                try {
                  if (d['JobDate'].toString().contains('/Date(')) {
                    final ms = int.parse(d['JobDate'].toString().replaceAll(RegExp(r'[^0-9]'), ''));
                    return DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(ms));
                  }
                  return DateFormat('dd/MM/yyyy').format(DateTime.parse(d['JobDate']));
                } catch(e) {
                  return '';
                }
              }(),
              'salary': d['Salary'] ?? 0.0,
              'ppic': d['PPIC']?.toString() ?? '',
              'dpic': d['DPIC']?.toString() ?? '',
              'pwd': d['PWDType'] ?? 0,
              'origin': d['OriginD']?.toString() ?? '',
              'destination': d['DestinationD']?.toString() ?? '',
              'pickupDate': d['PickupDateD']?.toString() ?? '',
              'deliveryDate': d['DeliveryDateD']?.toString() ?? '',
            });
          }
          _calculateAmount();
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sales Orders revised successfully')));
        }
      }
    } catch(e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteRTI() async {
    if (_rtiId == 0) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No RTI loaded to delete.')));
      return;
    }
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Confirm Delete', style: AppTypography.heading2()),
        content: const Text('Are you sure you want to delete this RTI?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('NO', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text('YES', style: TextStyle(color: Colors.white))
          ),
        ],
      )
    );
    
    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
      final repo = sl<LegacyApiRepository>();
      final res = await repo.apiAllinone('${ApiConstants.port}/RTI/DeleteRTI', {'SoId': _rtiId, 'Comid': comid});
      if (res != null && res['ok'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('RTI Deleted Successfully!')));
          Navigator.pop(context);
        }
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete RTI.')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting RTI: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveRTI() async {
    if (_driverId == 0 || _vehicleId == 0) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select Driver and Vehicle')));
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      final comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
      final repo = sl<LegacyApiRepository>();
      
      // DEBUG: print all job ids before building payload
      print('=== RTI Save Debug: _jobDetails count = ${_jobDetails.length}');
      for (var job in _jobDetails) {
        print('  job id=${job['id']}, jobNo=${job['jobNo']}, customer=${job['customer']}');
      }
      
      final saleOrderDetails = _jobDetails.map((job) => {
        "Id": job['rtidetailsId'] ?? 0,
        "SaleOrderMasterRefId": job['id'],
        "RTIMasterRefId": _rtiId,
        "JobNo": job['jobNo'],
        "JobDate": job['date'] != null && job['date'].toString().isNotEmpty ? DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(job['date'])) : null,
        "CustomerName": job['customer'],
        "Salary": job['salary'] ?? 0.0,
        "PPIC": job['ppic'] ?? '',
        "DPIC": job['dpic'] ?? '',
        "PWDType": job['pwd'] ?? 0,
        "OriginD": job['origin'] ?? '',
        "DestinationD": job['destination'] ?? '',
        "PickupDateD": (job['pickupDate'] ?? '').toString().isNotEmpty
            ? (() { try { return DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(job['pickupDate'])); } catch(_) { return null; } })()
            : null,
        "DeliveryDateD": (job['deliveryDate'] ?? '').toString().isNotEmpty
            ? (() { try { return DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(job['deliveryDate'])); } catch(_) { return null; } })()
            : null,
      }).toList();
      
      final payload = [{
        "Id": _rtiId,
        "CompanyRefId": comid,
        "UserRefId": null,
        "AgentCompanyRefId": null,
        "AgentMasterRefId": null,
        "EmployeeRefId": null,
        "SaleDate": DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(_rtiDate)),
        "CNumberDisplay": 0,
        "CNumber": 0,
        "ELink": _enterVal,
        "EXLink": _exitVal,
        "Amount": _totalAmount,
        "Sleeping": _sleepingAllow == 'YES' ? 1 : 0,
        "SleepingAmount": 0,
        "ExitYN": _emptyPickup == '' || _emptyPickup == 'NO' ? 0 : (_emptyPickup == 'EMPTY 80' ? 1 : 2),
        "ExitAmount": 0,
        "EmptyDeliveryYN": _emptyDelivery == '' || _emptyDelivery == 'NO' ? 0 : (_emptyDelivery == 'EMPTY 80' ? 1 : 2),
        "EmptyDeliveryAmount": 0,
        "Pickup": _addPickup == 'YES' ? 1 : 0,
        "PickupCount": 0,
        "PickupAmount": 0,
        "AddDrop": _addDrop == 'YES' ? 1 : 0,
        "DropCount": 0,
        "DropAmount": 0,
        "Remarks": _remarksCtrl.text,
        "Comments": _commentsCtrl.text,
        "SealBy": _sealByCtrl.text,
        "BreakSealBy": _breakSealByCtrl.text,
        "Destination": _destinationCtrl.text,
        "TruckRefid": _vehicleId,
        "DriverRefid": _driverId,
        "Manpw": _manpower == 'NO' ? 0 : (_manpower == '1' ? 1 : 2),
        "ManpwAmount": 0,
        "SaleDetails": saleOrderDetails,
        "DocumentSub": _docSub ? 1 : 0,
        "PckHandling": _multiPickup ? 1 : 0,
        "Punctuality": _punctuality ? 1 : 0,
      }];
      
      final res = await repo.apiAllinone('${ApiConstants.port}/RTI/InsertRTI', payload, {'Comid': comid.toString(), 'Content-Type': 'application/json; charset=UTF-8'});
      if (!mounted) return;
      if (res != null && res['ok'] == true) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('RTI Saved Successfully!')));
         setState(() {
           _rtiId = res['Id'] ?? _rtiId;
         });
      } else {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save RTI')));
      }
    } catch (e) {
      debugPrint("Error saving RTI: $e");
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.grey100,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: kGradient)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Update RTI', style: AppTypography.heading2(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.picture_as_pdf, color: Colors.white), onPressed: _viewRTI),
        ],
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: Palette.blue700)) 
        : Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  children: [
                    _buildSectionTitle('General Details'),
                    _buildGeneralDetailsCard(),
                    const SizedBox(height: 20),
                    
                    _buildSectionTitle('Allowances & Links'),
                    _buildAllowancesCard(),
                    const SizedBox(height: 20),
                    
                    _buildSectionTitle('Checklist'),
                    _buildChecklistCard(),
                    const SizedBox(height: 20),
                    
                    _buildSectionTitle('Additional Info'),
                    _buildAdditionalInfoCard(),
                    const SizedBox(height: 20),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle('Job Lines (${_jobDetails.length})'),
                        TextButton.icon(
                          onPressed: _addJobManually,
                          icon: const Icon(Icons.add_circle, color: Palette.blue700, size: 18),
                          label: const Text('Add Job', style: TextStyle(color: Palette.blue700, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    _buildJobsList(),
                    const SizedBox(height: 40), // Bottom padding
                  ],
                ),
              ),
              _buildBottomActionArea(),
            ],
          ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: AppTypography.heading3(color: Colors.grey.shade800)),
    );
  }

  Widget _buildGeneralDetailsCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildTextField('RTI No', _rtiNoCtrl, readOnly: true, icon: Icons.tag)),
                const SizedBox(width: 12),
                Expanded(child: _buildDatePicker('RTI Date', _rtiDate, (v) => setState(() => _rtiDate = v))),
              ],
            ),
            const SizedBox(height: 16),
            _buildMasterLookup('DRIVER NAME', _driverName, _searchDriver, Icons.person),
            const SizedBox(height: 16),
            _buildMasterLookup('VEHICLE NUMBER', _vehicleNo, _searchVehicle, Icons.local_shipping),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _getYesNoItems() => ['NO', 'YES'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: AppTypography.bodySmall()))).toList();
  List<DropdownMenuItem<String>> _getLinkItems() => ['','LINK 1', 'LINK 2'].map((e) => DropdownMenuItem(value: e, child: Text(e == '' ? 'SELECT' : e, style: AppTypography.bodySmall()))).toList();
  List<DropdownMenuItem<String>> _getExitItems() => ['','EMPTY 50', 'EMPTY 80'].map((e) => DropdownMenuItem(value: e, child: Text(e == '' ? 'SELECT' : e, style: AppTypography.bodySmall()))).toList();

  Widget _buildAllowancesCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildDropdown('ENTER', _enterVal, _getLinkItems(), (v) { setState(() => _enterVal = v!); _calculateAmount(); })),
                const SizedBox(width: 12),
                Expanded(child: _buildDropdown('EXIT', _exitVal, _getExitItems(), (v) { setState(() => _exitVal = v!); _calculateAmount(); })),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildDropdown('SLEEPING ALLOW', _sleepingAllow, _getYesNoItems(), (v) { setState(() => _sleepingAllow = v!); _calculateAmount(); })),
                const SizedBox(width: 12),
                Expanded(child: _buildDropdown('EMPTY PICKUP', _emptyPickup, _getExitItems(), (v) { setState(() => _emptyPickup = v!); _calculateAmount(); })),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildDropdown('EMPTY DELIVERY', _emptyDelivery, _getExitItems(), (v) { setState(() => _emptyDelivery = v!); _calculateAmount(); })),
                const SizedBox(width: 12),
                Expanded(child: _buildDropdown('ADD PICKUP', _addPickup, _getYesNoItems(), (v) => setState(() => _addPickup = v!))),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildDropdown('ADD DROP', _addDrop, _getYesNoItems(), (v) => setState(() => _addDrop = v!))),
                const SizedBox(width: 12),
                Expanded(child: _buildDropdown('MANPOWER', _manpower, _getYesNoItems(), (v) => setState(() => _manpower = v!))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            _buildCheckboxTile('Punctuality', _punctuality, (v) => setState(() => _punctuality = v!)),
            const Divider(height: 1),
            _buildCheckboxTile('Document Submission', _docSub, (v) => setState(() => _docSub = v!)),
            const Divider(height: 1),
            _buildCheckboxTile('Multiple Pickup Handling', _multiPickup, (v) => setState(() => _multiPickup = v!)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCheckboxTile(String title, bool value, Function(bool?) onChanged) {
    return CheckboxListTile(
      title: Text(title, style: AppTypography.bodyMedium()),
      value: value,
      onChanged: onChanged,
      activeColor: Palette.blue700,
      controlAffinity: ListTileControlAffinity.leading,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildAdditionalInfoCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField('Destination', _destinationCtrl, icon: Icons.location_on),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField('Seal By', _sealByCtrl)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField('Break Seal By', _breakSealByCtrl)),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField('Remarks', _remarksCtrl, maxLines: 2),
            const SizedBox(height: 16),
            _buildTextField('Comments', _commentsCtrl, maxLines: 2),
          ],
        ),
      ),
    );
  }

  void _openJobEditSheet(int index) {
    final d = Map<String, dynamic>.from(_jobDetails[index]);

    final salaryCtrl = TextEditingController(text: (d['salary'] ?? 0.0).toString());
    final ppicCtrl = TextEditingController(text: d['ppic']?.toString() ?? '');
    final dpicCtrl = TextEditingController(text: d['dpic']?.toString() ?? '');
    final originCtrl = TextEditingController(text: d['origin']?.toString() ?? '');
    final destinationCtrl = TextEditingController(text: d['destination']?.toString() ?? '');
    String pickupDate = d['pickupDate']?.toString() ?? '';
    String deliveryDate = d['deliveryDate']?.toString() ?? '';
    int pwdType = (d['pwd'] is int) ? d['pwd'] as int : int.tryParse(d['pwd']?.toString() ?? '0') ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.only(
              left: 16, right: 16, top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d['jobNo']?.toString() ?? '', style: AppTypography.heading3(color: Palette.blue700)),
                          Text(d['customer']?.toString() ?? '', style: AppTypography.bodySmall(color: Colors.grey)),
                        ],
                      ),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Salary
                  TextField(
                    controller: salaryCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Salary', border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.all(10)),
                  ),
                  const SizedBox(height: 12),

                  // PPIC & DPIC
                  Row(
                    children: [
                      Expanded(child: TextField(controller: ppicCtrl, decoration: const InputDecoration(labelText: 'PPIC', border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.all(10)))),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: dpicCtrl, decoration: const InputDecoration(labelText: 'DPIC', border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.all(10)))),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // PWD
                  DropdownButtonFormField<int>(
                    value: pwdType,
                    decoration: const InputDecoration(labelText: 'PWD Type', border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.all(10)),
                    items: [0, 1, 2, 3].map((e) => DropdownMenuItem(value: e, child: Text(e.toString()))).toList(),
                    onChanged: (val) => setSheetState(() => pwdType = val ?? 0),
                  ),
                  const SizedBox(height: 12),

                  // Origin & Destination
                  Row(
                    children: [
                      Expanded(child: TextField(controller: originCtrl, decoration: const InputDecoration(labelText: 'Origin', border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.all(10)))),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: destinationCtrl, decoration: const InputDecoration(labelText: 'Destination', border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.all(10)))),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Pickup Date
                  GestureDetector(
                    onTap: () async {
                      DateTime? initDate;
                      try { initDate = pickupDate.isNotEmpty ? DateFormat('dd/MM/yyyy').parse(pickupDate) : DateTime.now(); } catch(_) { initDate = DateTime.now(); }
                      final picked = await showDatePicker(context: ctx, initialDate: initDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
                      if (picked != null) setSheetState(() => pickupDate = DateFormat('dd/MM/yyyy').format(picked));
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        controller: TextEditingController(text: pickupDate),
                        decoration: InputDecoration(
                          labelText: 'Pickup Date',
                          border: const OutlineInputBorder(),
                          isDense: true,
                          contentPadding: const EdgeInsets.all(10),
                          suffixIcon: const Icon(Icons.calendar_today, size: 16),
                          hintText: pickupDate.isEmpty ? 'Select date' : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Delivery Date
                  GestureDetector(
                    onTap: () async {
                      DateTime? initDate;
                      try { initDate = deliveryDate.isNotEmpty ? DateFormat('dd/MM/yyyy').parse(deliveryDate) : DateTime.now(); } catch(_) { initDate = DateTime.now(); }
                      final picked = await showDatePicker(context: ctx, initialDate: initDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
                      if (picked != null) setSheetState(() => deliveryDate = DateFormat('dd/MM/yyyy').format(picked));
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        controller: TextEditingController(text: deliveryDate),
                        decoration: InputDecoration(
                          labelText: 'Delivery Date',
                          border: const OutlineInputBorder(),
                          isDense: true,
                          contentPadding: const EdgeInsets.all(10),
                          suffixIcon: const Icon(Icons.calendar_today, size: 16),
                          hintText: deliveryDate.isEmpty ? 'Select date' : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Palette.blue700,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        setState(() {
                          _jobDetails[index]['salary'] = double.tryParse(salaryCtrl.text) ?? 0.0;
                          _jobDetails[index]['ppic'] = ppicCtrl.text;
                          _jobDetails[index]['dpic'] = dpicCtrl.text;
                          _jobDetails[index]['pwd'] = pwdType;
                          _jobDetails[index]['origin'] = originCtrl.text;
                          _jobDetails[index]['destination'] = destinationCtrl.text;
                          _jobDetails[index]['pickupDate'] = pickupDate;
                          _jobDetails[index]['deliveryDate'] = deliveryDate;
                        });
                        _calculateAmount();
                        Navigator.pop(ctx);
                      },
                      child: const Text('UPDATE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildJobsList() {
    if (_jobDetails.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
        ),
        child: const Center(
          child: Text('No Job lines added.\nTap Add Job to add manually.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
        ),
      );
    }
    
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _jobDetails.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final d = _jobDetails[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(d['jobNo']?.toString() ?? '', style: AppTypography.heading3(color: Palette.blue700)),
                    Text(d['date']?.toString() ?? '', style: AppTypography.bodySmall(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(d['customer']?.toString() ?? '', style: AppTypography.bodyMedium(color: Colors.grey.shade800)),
                const SizedBox(height: 8),
                // Quick info row
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _jobChip('Salary: ${(d['salary'] ?? 0).toString()}', Colors.green.shade700, Colors.green.shade50),
                    if ((d['ppic']?.toString() ?? '').isNotEmpty)
                      _jobChip('PPIC: ${d['ppic']}', Palette.blue700, Colors.blue.shade50),
                    if ((d['dpic']?.toString() ?? '').isNotEmpty)
                      _jobChip('DPIC: ${d['dpic']}', Colors.orange.shade700, Colors.orange.shade50),
                    if ((d['pwd'] ?? 0) != 0)
                      _jobChip('PWD: ${d['pwd']}', Colors.purple.shade700, Colors.purple.shade50),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _openJobEditSheet(index),
                      icon: const Icon(Icons.edit_outlined, size: 16, color: Palette.blue700),
                      label: const Text('Edit', style: TextStyle(color: Palette.blue700, fontSize: 12)),
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    ),
                    const SizedBox(width: 4),
                    TextButton.icon(
                      onPressed: () {
                        setState(() => _jobDetails.removeAt(index));
                        _calculateAmount();
                      },
                      icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                      label: const Text('Delete', style: TextStyle(color: Colors.red, fontSize: 12)),
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _jobChip(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  Widget _buildBottomActionArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Total Amount', style: AppTypography.bodySmall(color: Colors.grey)),
                  Text('RM ${_totalAmount.toStringAsFixed(2)}', style: AppTypography.heading2(color: Colors.red.shade700)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_rtiId != 0)
                  OutlinedButton(
                    onPressed: _deleteRTI,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('DEL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                if (_rtiId != 0) const SizedBox(width: 6),
                if (_rtiId != 0) OutlinedButton(
                  onPressed: _loadReviseData,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Palette.blue700,
                    side: BorderSide(color: Palette.blue700),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('LOAD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                if (_rtiId != 0) const SizedBox(width: 6),
                ElevatedButton(
                  onPressed: _saveRTI,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.blue700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('SAVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool readOnly = false, int maxLines = 1, IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySmall(color: Colors.grey.shade700).copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          style: AppTypography.bodyMedium(color: Colors.grey.shade800),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
            prefixIcon: icon != null ? Icon(icon, size: 18, color: Colors.grey) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Palette.blue700, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String? value, List<DropdownMenuItem<String>> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySmall(color: Colors.grey.shade700).copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, String value, Function(String) onPicked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySmall(color: Colors.grey.shade700).copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            DateTime? initial;
            try { initial = DateFormat('dd/MM/yyyy').parse(value); } catch (_) { initial = DateTime.now(); }
            final picked = await showDatePicker(
              context: context,
              initialDate: initial,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(primary: Palette.blue700),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) onPicked(DateFormat('dd/MM/yyyy').format(picked));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: AppTypography.bodyMedium(color: Colors.grey.shade800)),
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _searchDriver() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const Driver(Searchby: 1, SearchId: 0)));
    if (result != null && mounted) {
      setState(() {
        _driverId = result.Id ?? 0;
        _driverName = result.AccountName?.toString() ?? '';
      });
    }
  }

  Future<void> _searchVehicle() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const Truck(Searchby: 1, SearchId: 0)));
    if (result != null && mounted) {
      setState(() {
        _vehicleId = result.Id ?? 0;
        _vehicleNo = result.AccountName?.toString() ?? '';
      });
    }
  }

  Widget _buildMasterLookup(String label, String value, VoidCallback onTap, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySmall(color: Colors.grey.shade700).copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(child: Text(value.isEmpty ? 'Tap to Search' : value, style: AppTypography.bodyMedium(color: value.isEmpty ? Colors.grey : Colors.grey.shade800), overflow: TextOverflow.ellipsis)),
                const Icon(Icons.search, size: 18, color: Palette.blue700),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
