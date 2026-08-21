
import 'package:flutter/material.dart';
import 'package:maleva/core/utils/dialog_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../models/fuelentry_model.dart';
import '../bloc/fuelentry_bloc.dart';
import '../bloc/fuelentry_event.dart';
import '../../../../../core/network/api_services/master_api.dart';
import '../../../../../core/models/shared/get_truck_model.dart';
import '../../../../../core/colors/colors.dart';
import '../../../../../core/network/api_constants.dart';
import '../../../../../core/network/legacy_api_repository.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/utils/app_globals.dart';
import '../../../../../core/utils/app_preferences.dart';
import '../../../../../core/widgets/custom_app_bar.dart';

class FuelEntryAddEdit extends StatefulWidget {
  final FuelEntryModel? entry;
  const FuelEntryAddEdit({Key? key, this.entry}) : super(key: key);

  @override
  State<FuelEntryAddEdit> createState() => _FuelEntryAddEditState();
}

class _FuelEntryAddEditState extends State<FuelEntryAddEdit> {
  final _formKey = GlobalKey<FormState>();
  late FuelEntryModel _model;
  
  List<GetTruckModel> truckList = [];
  List<GetTruckModel> driverList = [];
  bool isLoadingMasters = true;

  final TextEditingController entryNoController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  
  final TextEditingController aLiterController = TextEditingController();
  final TextEditingController aAmountController = TextEditingController();
  
  final TextEditingController pLiterController = TextEditingController();
  final TextEditingController pRateController = TextEditingController();
  final TextEditingController pAmountController = TextEditingController();

  final TextEditingController gLiterController = TextEditingController();
  final TextEditingController gAmountController = TextEditingController();

  final TextEditingController dpLiterController = TextEditingController();
  final TextEditingController dpAmountController = TextEditingController();
  final TextEditingController dgLiterController = TextEditingController();
  final TextEditingController dgAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _model = widget.entry ?? FuelEntryModel();
    if (_model.entryDate.isNotEmpty) {
      dateController.text = _model.entryDate;
      entryNoController.text = _model.entryNo;
    } else {
      dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
      _fetchMaxFuelNo();
    }
    remarksController.text = _model.remarks;
    
    aLiterController.text = _model.aLiter == 0 ? "" : _model.aLiter.toString();
    aAmountController.text = _model.aAmount == 0 ? "" : _model.aAmount.toString();

    pLiterController.text = _model.pLiter == 0 ? "" : _model.pLiter.toString();
    pRateController.text = _model.pRate == 0 ? "" : _model.pRate.toString();
    pAmountController.text = _model.pAmount == 0 ? "" : _model.pAmount.toString();

    gLiterController.text = _model.gLiter == 0 ? "" : _model.gLiter.toString();
    gAmountController.text = _model.gAmount == 0 ? "" : _model.gAmount.toString();

    dpLiterController.text = _model.dpLiter == 0 ? "" : _model.dpLiter.toString();
    dpAmountController.text = _model.dpAmount == 0 ? "" : _model.dpAmount.toString();
    dgLiterController.text = _model.dgLiter == 0 ? "" : _model.dgLiter.toString();
    dgAmountController.text = _model.dgAmount == 0 ? "" : _model.dgAmount.toString();
    
    _loadMasters();
  }

  void _calculateDifferences() {
    double aLiter = double.tryParse(aLiterController.text) ?? 0;
    double pLiter = double.tryParse(pLiterController.text) ?? 0;
    double gLiter = double.tryParse(gLiterController.text) ?? 0;
    
    double aAmount = double.tryParse(aAmountController.text) ?? 0;
    double pAmount = double.tryParse(pAmountController.text) ?? 0;
    double gAmount = double.tryParse(gAmountController.text) ?? 0;
    
    dpLiterController.text = (aLiter - pLiter).toStringAsFixed(2);
    dpAmountController.text = (aAmount - pAmount).toStringAsFixed(2);
    dgLiterController.text = (aLiter - gLiter).toStringAsFixed(2);
    dgAmountController.text = (aAmount - gAmount).toStringAsFixed(2);
    
    _model.dpLiter = aLiter - pLiter;
    _model.dpAmount = aAmount - pAmount;
    _model.dgLiter = aLiter - gLiter;
    _model.dgAmount = aAmount - gAmount;
  }

  Future<void> _fetchMaxFuelNo() async {
    try {
      final comId = AppPreferences.getComid();
      var result = await sl<LegacyApiRepository>().apiGetString('${ApiConstants.apiMaxFuelEntryNo}$comId');
      if (result.isNotEmpty) {
        result = result.replaceAll('"', ''); // Remove any double quotes
        if (mounted) {
          setState(() {
            entryNoController.text = result;
            _model.entryNo = result;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _loadMasters() async {
    try {
      final trucks = await MasterApi.getTrucks();
      final drivers = await MasterApi.getDrivers();
      setState(() {
        truckList = trucks;
        driverList = drivers;
        isLoadingMasters = false;
      });
    } catch (e) {
      setState(() { isLoadingMasters = false; });
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, Function(String) onChanged, {IconData? prefixIcon}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: Colors.grey.shade50,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.appBarColor, size: 20) : null,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.appBarColor, width: 1.5),
            ),
          ),
          keyboardType: TextInputType.number,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 4.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.appBarColor, size: 22),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.appBarColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: const CustomGradientAppBar(title: 'Fuel Entry Details', isTablet: false, showBackButton: true),
      body: isLoadingMasters 
        ? const Center(child: CircularProgressIndicator()) 
        : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('General Info', Icons.info_outline),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: entryNoController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Entry No',
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              prefixIcon: const Icon(Icons.numbers, color: Colors.grey, size: 20),
                              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: dateController,
                            decoration: InputDecoration(
                              labelText: 'Fuel Date',
                              prefixIcon: const Icon(Icons.calendar_today, color: AppColors.appBarColor),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            readOnly: true,
                            onTap: () async {
                              DateTime? picked = await showDatePicker(
                                context: context, 
                                initialDate: DateTime.now(), 
                                firstDate: DateTime(2000), 
                                lastDate: DateTime(2100)
                              );
                              if (picked != null) {
                                setState(() {
                                  dateController.text = DateFormat('dd/MM/yyyy').format(picked);
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      isExpanded: true,
                      value: _model.truckId == 0 ? null : _model.truckId,
                      decoration: InputDecoration(
                        labelText: 'Select Truck',
                        prefixIcon: const Icon(Icons.local_shipping, color: AppColors.appBarColor),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: truckList.map((t) => DropdownMenuItem(value: t.Id, child: Text(t.AccountName, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (val) {
                        setState(() { _model.truckId = val ?? 0; });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      isExpanded: true,
                      value: _model.driverId == 0 ? null : _model.driverId,
                      decoration: InputDecoration(
                        labelText: 'Select Driver',
                        prefixIcon: const Icon(Icons.person, color: AppColors.appBarColor),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: driverList.map((d) => DropdownMenuItem(value: d.Id, child: Text(d.AccountName, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (val) {
                        setState(() { _model.driverId = val ?? 0; });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: remarksController,
                      decoration: InputDecoration(
                        labelText: 'Remarks',
                        prefixIcon: const Icon(Icons.comment, color: AppColors.appBarColor),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onChanged: (v) => _model.remarks = v,
                    ),
                  ],
                ),
              ),

              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('App Entry', Icons.phone_android),
                    Row(
                      children: [
                        _buildTextField('App Liter', aLiterController, (v) { _model.aLiter = double.tryParse(v) ?? 0; _calculateDifferences(); }, prefixIcon: Icons.water_drop),
                        _buildTextField('App Amount', aAmountController, (v) { _model.aAmount = double.tryParse(v) ?? 0; _calculateDifferences(); }, prefixIcon: Icons.attach_money),
                      ],
                    ),
                  ],
                ),
              ),

              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Patron Entry', Icons.account_balance_wallet),
                    Row(
                      children: [
                        _buildTextField('Patron Liter', pLiterController, (v) { _model.pLiter = double.tryParse(v) ?? 0; _calculateDifferences(); }),
                        _buildTextField('Patron Rate', pRateController, (v) => _model.pRate = double.tryParse(v) ?? 0),
                        _buildTextField('Patron Amount', pAmountController, (v) { _model.pAmount = double.tryParse(v) ?? 0; _calculateDifferences(); }),
                      ],
                    ),
                  ],
                ),
              ),

              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('GPS Entry', Icons.gps_fixed),
                    Row(
                      children: [
                        _buildTextField('GPS Liter', gLiterController, (v) { _model.gLiter = double.tryParse(v) ?? 0; _calculateDifferences(); }),
                        _buildTextField('GPS Amount', gAmountController, (v) { _model.gAmount = double.tryParse(v) ?? 0; _calculateDifferences(); }),
                      ],
                    ),
                  ],
                ),
              ),

              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Difference', Icons.compare_arrows),
                    Row(
                      children: [
                        _buildTextField('D Pat Liter', dpLiterController, (v) => _model.dpLiter = double.tryParse(v) ?? 0),
                        _buildTextField('D Pat Amount', dpAmountController, (v) => _model.dpAmount = double.tryParse(v) ?? 0),
                      ],
                    ),
                    Row(
                      children: [
                        _buildTextField('D GPS Liter', dgLiterController, (v) => _model.dgLiter = double.tryParse(v) ?? 0),
                        _buildTextField('D GPS Amount', dgAmountController, (v) => _model.dgAmount = double.tryParse(v) ?? 0),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: 55,
                margin: const EdgeInsets.only(bottom: 24),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appBarColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text('SAVE FUEL ENTRY', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    if (_model.truckId == 0 || _model.driverId == 0) {
                       toastMsg('Please select Truck and Driver', '', context);
                       return;
                    }
                    _model.entryDate = dateController.text;
                    context.read<FuelEntryBloc>().add(SaveFuelEntry(_model));
                    Navigator.pop(context);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
