import 'package:flutter/material.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/fleet/outside_carrier_api.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/widgets/ui/ui.dart';

/// What the outside carrier sheet answers: the truck number (optional) and the driver of one trip.
class OutsideCarrierChoice {
  const OutsideCarrierChoice({this.vehicleId = 0, this.plateNo = '', required this.driverId, required this.driverName});

  final int vehicleId;
  final String plateNo;
  final int driverId;
  final String driverName;
}

/// Fleet D2 (the web's `OutsideCarrierModal`): the truck number and the outside driver of a trip on a
/// SUBCONTRACTOR / HIRED_TRUCK row. The billing company is fixed on the truck master (owner 2026-10-23),
/// so it is not asked. Only the truck numbers of this subcontractor row are listed. The driver's mobile is
/// shown here only; nothing is logged. The server checks every id again on save.
Future<OutsideCarrierChoice?> showOutsideCarrierSheet(
  BuildContext context, {
  required int truckRefId,
  required String unitName,
  required bool needsPlate,
  int currentVehicleId = 0,
  String currentPlateNo = '',
  int currentDriverId = 0,
  String currentDriverName = '',
  OutsideCarrierApi? api,
}) =>
    showModalBottomSheet<OutsideCarrierChoice>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: MalevaThemeScope(
          child: OutsideCarrierBody(
            api: api ?? sl<OutsideCarrierApi>(),
            truckRefId: truckRefId,
            unitName: unitName,
            needsPlate: needsPlate,
            vehicleId: currentVehicleId,
            plateNo: currentPlateNo,
            driverId: currentDriverId,
            driverName: currentDriverName,
          ),
        ),
      ),
    );

class OutsideCarrierBody extends StatefulWidget {
  const OutsideCarrierBody({
    super.key,
    required this.api,
    required this.truckRefId,
    required this.unitName,
    required this.needsPlate,
    this.vehicleId = 0,
    this.plateNo = '',
    this.driverId = 0,
    this.driverName = '',
  });

  final OutsideCarrierApi api;
  final int truckRefId;
  final String unitName;
  final bool needsPlate;
  final int vehicleId;
  final String plateNo;
  final int driverId;
  final String driverName;

  @override
  State<OutsideCarrierBody> createState() => _OutsideCarrierBodyState();
}

class _OutsideCarrierBodyState extends State<OutsideCarrierBody> {
  late int _vehicleId = widget.vehicleId;
  late String _plateNo = widget.plateNo;
  late int _driverId = widget.driverId;
  late String _driverName = widget.driverName;
  List<OutsideVehicle>? _vehicles;
  List<OutsideDriver>? _drivers;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final vehicles = widget.needsPlate ? await widget.api.vehicles(widget.truckRefId) : const <OutsideVehicle>[];
      final drivers = await widget.api.drivers();
      if (!mounted) return;
      setState(() {
        _vehicles = vehicles;
        _drivers = drivers;
        _error = null;
      });
    } on ApiFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not load the outside trucks and drivers.');
    }
  }

  Future<void> _pickPlate() async {
    final vehicles = _vehicles ?? const [];
    final result = await showPickerSheet<int>(
      context,
      title: 'Truck number',
      options: [for (final v in vehicles) PickOption(value: v.id, label: v.plateNo, subtitle: v.sizeClass)],
      current: _vehicleId > 0 ? _vehicleId : null,
      allowClear: true,
      searchHint: 'Search truck number...',
    );
    if (result == null || !mounted) return;
    setState(() {
      if (result.cleared) {
        _vehicleId = 0;
        _plateNo = '';
      } else if (result.value != null) {
        _vehicleId = result.value!;
        _plateNo = vehicles.firstWhere((v) => v.id == result.value).plateNo;
      }
    });
  }

  Future<void> _pickDriver() async {
    final drivers = _drivers ?? const [];
    final result = await showPickerSheet<int>(
      context,
      title: 'Outside driver',
      options: [for (final d in drivers) PickOption(value: d.id, label: d.name, subtitle: d.mobileNo)],
      current: _driverId > 0 ? _driverId : null,
      searchHint: 'Search driver...',
    );
    if (result == null || result.value == null || !mounted) return;
    setState(() {
      _driverId = result.value!;
      _driverName = drivers.firstWhere((d) => d.id == result.value).name;
    });
  }

  Future<void> _addPlate() async {
    final added = await showDialog<OutsideVehicle>(
      context: context,
      useRootNavigator: true,
      builder: (_) => _AddPlateDialog(api: widget.api, truckRefId: widget.truckRefId),
    );
    if (added == null || !mounted) return;
    setState(() {
      if (!(_vehicles ?? const []).any((v) => v.id == added.id)) _vehicles = [...?_vehicles, added];
      _vehicleId = added.id;
      _plateNo = added.plateNo;
    });
    showSnack(context, added.existing ? '${added.plateNo} is already in the list' : '${added.plateNo} added');
  }

  Future<void> _addDriver() async {
    final added = await showDialog<OutsideDriver>(
      context: context,
      useRootNavigator: true,
      builder: (_) => _AddDriverDialog(api: widget.api),
    );
    if (added == null || !mounted) return;
    setState(() {
      if (!(_drivers ?? const []).any((d) => d.id == added.id)) _drivers = [...?_drivers, added];
      _driverId = added.id;
      _driverName = added.name;
    });
    showSnack(context, added.existing ? '${added.name} is already in the list' : '${added.name} added');
  }

  @override
  Widget build(BuildContext context) {
    final loading = _vehicles == null || _drivers == null;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Outside trip — ${widget.unitName}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (_error != null) ...[
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              TextButton(onPressed: () {
                setState(() => _error = null);
                _load();
              }, child: const Text('Try again')),
            ] else if (loading)
              const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
            else ...[
              if (widget.needsPlate) ...[
                _Field(
                  key: const ValueKey('outside-plate'),
                  label: 'Truck number (optional)',
                  value: _plateNo,
                  onTap: _pickPlate,
                ),
                Align(alignment: Alignment.centerLeft, child: TextButton(onPressed: _addPlate, child: const Text('+ Add truck number'))),
              ],
              _Field(key: const ValueKey('outside-driver'), label: 'Driver *', value: _driverName, onTap: _pickDriver),
              Align(alignment: Alignment.centerLeft, child: TextButton(onPressed: _addDriver, child: const Text('+ Add driver'))),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _driverId <= 0 || _busy
                      ? null
                      : () {
                          _busy = true;
                          Navigator.of(context).pop(OutsideCarrierChoice(
                              vehicleId: _vehicleId, plateNo: _plateNo, driverId: _driverId, driverName: _driverName));
                        },
                  child: const Text('Use for this trip'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({super.key, required this.label, required this.value, required this.onTap});

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(labelText: label, suffixIcon: const Icon(Icons.arrow_drop_down)),
          child: Text(value.isEmpty ? 'Choose…' : value),
        ),
      );
}

/// "+ Add truck number": the number and its size; under this subcontractor row only.
class _AddPlateDialog extends StatefulWidget {
  const _AddPlateDialog({required this.api, required this.truckRefId});

  final OutsideCarrierApi api;
  final int truckRefId;

  @override
  State<_AddPlateDialog> createState() => _AddPlateDialogState();
}

class _AddPlateDialogState extends State<_AddPlateDialog> {
  final _plate = TextEditingController();
  String? _size;
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _plate.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_plate.text.trim().isEmpty || _size == null) {
      setState(() => _error = 'Type the truck number and choose the size.');
      return;
    }
    setState(() => _saving = true);
    try {
      final v = await widget.api.addVehicle(truckRefId: widget.truckRefId, plateNo: _plate.text.trim(), sizeClass: _size!);
      if (mounted) Navigator.of(context).pop(v);
    } on ApiFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Add truck number'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _plate,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(labelText: 'Truck number'),
            ),
            DropdownButtonFormField<String>(
              initialValue: _size,
              decoration: const InputDecoration(labelText: 'Size'),
              items: [for (final s in OutsideCarrierApi.sizeClasses) DropdownMenuItem(value: s, child: Text(s))],
              onChanged: (v) => setState(() => _size = v),
            ),
            if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(onPressed: _saving ? null : _save, child: const Text('Add')),
        ],
      );
}

/// "+ Add driver": name and mobile; IC or passport when known (then the same person is never added twice).
class _AddDriverDialog extends StatefulWidget {
  const _AddDriverDialog({required this.api});

  final OutsideCarrierApi api;

  @override
  State<_AddDriverDialog> createState() => _AddDriverDialogState();
}

class _AddDriverDialogState extends State<_AddDriverDialog> {
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _idNo = TextEditingController();
  String _idType = 'IC';
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _mobile.dispose();
    _idNo.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _mobile.text.trim().isEmpty) {
      setState(() => _error = 'Type the driver name and mobile number.');
      return;
    }
    setState(() => _saving = true);
    try {
      final d = await widget.api.addDriver(name: _name.text.trim(), mobileNo: _mobile.text.trim(), idType: _idType, idNo: _idNo.text.trim());
      if (mounted) Navigator.of(context).pop(d);
    } on ApiFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Add driver'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _name,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(labelText: 'Driver name'),
              ),
              TextField(controller: _mobile, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Mobile number')),
              Row(
                children: [
                  DropdownButton<String>(
                    value: _idType,
                    items: const [DropdownMenuItem(value: 'IC', child: Text('IC')), DropdownMenuItem(value: 'PASSPORT', child: Text('Passport'))],
                    onChanged: (v) => setState(() => _idType = v ?? 'IC'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: _idNo, decoration: const InputDecoration(labelText: 'Number (optional)'))),
                ],
              ),
              if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(onPressed: _saving ? null : _save, child: const Text('Add driver')),
        ],
      );
}
