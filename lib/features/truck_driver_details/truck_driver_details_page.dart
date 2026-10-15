import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/fleet/driver_api.dart';
import 'package:maleva/core/fleet/truck_api.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/utils/json_read.dart';
import 'package:maleva/core/widgets/searchable_picker_field.dart';
import 'package:maleva/core/widgets/ui/feedback.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'truck_driver_details_api.dart';
import 'truck_driver_details_models.dart';
import 'truck_driver_details_pdf.dart';

/// Truck & Driver Details: a truck and a driver on one screen, shared as the
/// same PDF sheet the web page downloads. Read only - the values are edited
/// on the web Truck Master and Driver Master forms.
class TruckDriverDetailsPage extends StatefulWidget {
  const TruckDriverDetailsPage({super.key});

  static Route<void> route() => MaterialPageRoute<void>(builder: (_) => const TruckDriverDetailsPage());

  @override
  State<TruckDriverDetailsPage> createState() => _TruckDriverDetailsPageState();
}

/// A picker entry from `/api/truck-combo` or `/api/driver-combo` (`{Id, AccountName}`).
class _Option {
  const _Option(this.id, this.label);
  final int id;
  final String label;

  static List<_Option> fromCombo(List<Map<String, dynamic>> rows) => rows
      .map((row) => _Option(JsonRead.integer(JsonRead.field(row, 'Id')),
          JsonRead.string(JsonRead.field(row, 'AccountName')).trim()))
      .where((option) => option.id > 0)
      .toList()
    ..sort((a, b) => a.label.compareTo(b.label));

  @override
  bool operator ==(Object other) => other is _Option && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class _TruckDriverDetailsPageState extends State<TruckDriverDetailsPage> {
  final _api = sl<TruckDriverDetailsApi>();

  List<_Option> _trucks = const [];
  List<_Option> _drivers = const [];
  bool _loadingLists = true;
  String? _listError;

  _Option? _truck;
  _Option? _driver;
  SheetVehicle? _vehicle;
  SheetDriver? _driverDetails;
  bool _loadingTruck = false;
  bool _loadingDriver = false;
  /// The part being made, so only that button spins.
  SheetPart? _sharing;

  @override
  void initState() {
    super.initState();
    _loadLists();
  }

  Future<void> _loadLists() async {
    setState(() {
      _loadingLists = true;
      _listError = null;
    });
    try {
      final results = await Future.wait([sl<TruckApi>().combo(), sl<DriverApi>().combo()]);
      if (!mounted) return;
      setState(() {
        _trucks = _Option.fromCombo(results[0]);
        _drivers = _Option.fromCombo(results[1]);
        _loadingLists = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingLists = false;
        _listError = '$e';
      });
    }
  }

  Future<void> _pickTruck(_Option? option) async {
    setState(() {
      _truck = option;
      _vehicle = null;
      _loadingTruck = option != null;
    });
    if (option == null) return;
    try {
      final vehicle = await _api.vehicle(option.id);
      if (!mounted || _truck != option) return;
      setState(() {
        _vehicle = vehicle;
        _loadingTruck = false;
      });
      // The truck's usual driver comes along, unless a driver is already chosen.
      final paired = vehicle?.driverRefId;
      if (_driver == null && paired != null) {
        final match = _drivers.where((d) => d.id == paired);
        await _pickDriver(match.isEmpty ? _Option(paired, '') : match.first);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingTruck = false);
      showSnack(context, 'Could not load the truck: $e', kind: SnackKind.error);
    }
  }

  Future<void> _pickDriver(_Option? option) async {
    setState(() {
      _driver = option;
      _driverDetails = null;
      _loadingDriver = option != null;
    });
    if (option == null) return;
    try {
      final driver = await _api.driver(option.id);
      if (!mounted || _driver != option) return;
      setState(() {
        _driverDetails = driver;
        _loadingDriver = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingDriver = false);
      showSnack(context, 'Could not load the driver: $e', kind: SnackKind.error);
    }
  }

  Future<void> _sharePdf(SheetPart part) async {
    setState(() => _sharing = part);
    try {
      final truck = part == SheetPart.driver ? null : _vehicle;
      final person = part == SheetPart.truck ? null : _driverDetails;
      final emblem = await _emblem();
      final bytes = await buildTruckDriverDetailsPdf(truck, person, part: part, emblem: emblem);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${sheetFileName(truck, person)}');
      await file.writeAsBytes(bytes, flush: true);
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        subject: 'Truck & Driver Details',
      ));
    } catch (e) {
      if (mounted) showSnack(context, 'Could not make the PDF: $e', kind: SnackKind.error);
    } finally {
      if (mounted) setState(() => _sharing = null);
    }
  }

  /// The Maleva emblem for the letterhead; null (text-only letterhead) if it cannot be read.
  static Future<Uint8List?> _emblem() async {
    try {
      return (await rootBundle.load('assets/company/maleva_emblem.png')).buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _sharing != null;
    return Scaffold(
      backgroundColor: AppTokens.surfacePage,
      appBar: AppBar(
        backgroundColor: AppTokens.appBarBg,
        iconTheme: const IconThemeData(color: AppTokens.appBarIcon),
        title: Text('Truck & Driver Details', style: AppTypography.pageTitleWhite),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Expanded(
                child: _PdfButton(
                  label: 'Truck PDF',
                  icon: Icons.local_shipping_outlined,
                  busy: _sharing == SheetPart.truck,
                  onPressed: _vehicle != null && !busy ? () => _sharePdf(SheetPart.truck) : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PdfButton(
                  label: 'Driver PDF',
                  icon: Icons.badge_outlined,
                  busy: _sharing == SheetPart.driver,
                  onPressed: _driverDetails != null && !busy ? () => _sharePdf(SheetPart.driver) : null,
                ),
              ),
            ]),
            const SizedBox(height: 8),
            _PdfButton(
              label: 'Download Both',
              icon: Icons.picture_as_pdf_outlined,
              filled: true,
              busy: _sharing == SheetPart.both,
              onPressed:
                  _vehicle != null && _driverDetails != null && !busy ? () => _sharePdf(SheetPart.both) : null,
            ),
          ],
        ),
      ),
      body: _loadingLists
          ? const Center(child: CircularProgressIndicator())
          : _listError != null
              ? _ListError(message: _listError!, onRetry: _loadLists)
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('Truck', style: AppTypography.bodyMedium(color: AppTokens.textPrimary)),
                    const SizedBox(height: 6),
                    SearchablePickerField<_Option>(
                      items: _trucks,
                      value: _truck,
                      itemLabel: (o) => o.label,
                      hint: 'Select a truck',
                      onChanged: _pickTruck,
                    ),
                    const SizedBox(height: 14),
                    Text('Driver', style: AppTypography.bodyMedium(color: AppTokens.textPrimary)),
                    const SizedBox(height: 6),
                    SearchablePickerField<_Option>(
                      items: _drivers,
                      value: _driver,
                      itemLabel: (o) => o.label,
                      hint: 'Select a driver',
                      onChanged: _pickDriver,
                    ),
                    const SizedBox(height: 22),
                    _SheetBlock(
                      title: 'VEHICLE DETAILS',
                      icon: Icons.local_shipping_outlined,
                      rows: _vehicle?.rows,
                      loading: _loadingTruck,
                      emptyText: 'Select a truck to see its details.',
                    ),
                    const SizedBox(height: 20),
                    _SheetBlock(
                      title: 'DRIVER DETAILS',
                      icon: Icons.badge_outlined,
                      rows: _driverDetails?.rows,
                      loading: _loadingDriver,
                      emptyText: 'Select a driver to see their details.',
                    ),
                  ],
                ),
    );
  }
}

/// One block of the sheet, drawn the way it prints.
class _SheetBlock extends StatelessWidget {
  const _SheetBlock({
    required this.title,
    required this.icon,
    required this.rows,
    required this.loading,
    required this.emptyText,
  });

  final String title;
  final IconData icon;
  final List<SheetRow>? rows;
  final bool loading;
  final String emptyText;

  static const _navy = Color(0xFF0F172A);
  static const _shade = Color(0xFFF1F4F9);

  @override
  Widget build(BuildContext context) {
    const bold = TextStyle(color: _navy, fontWeight: FontWeight.w700, fontSize: 13.5);
    final current = rows;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: _shade, border: Border.all(color: const Color(0xFF94A3B8))),
          child: Row(children: [
            Icon(icon, size: 18, color: _navy),
            const SizedBox(width: 8),
            Text(title, style: bold.copyWith(letterSpacing: 0.4)),
          ]),
        ),
        const SizedBox(height: 10),
        if (loading)
          const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
        else if (current == null)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Text(emptyText, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF64748B))),
          )
        else
          Table(
            border: TableBorder.all(color: _navy, width: 1.6),
            columnWidths: const {0: FlexColumnWidth(38), 1: FlexColumnWidth(62)},
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              for (final row in current)
                TableRow(children: [
                  Container(
                    color: _shade,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                    child: Text(row.label, style: bold),
                  ),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                    child: SelectableText(row.value.isEmpty ? '-' : row.value, style: bold),
                  ),
                ]),
            ],
          ),
      ],
    );
  }
}

/// One PDF button: outlined for one half, filled for both.
class _PdfButton extends StatelessWidget {
  const _PdfButton({
    required this.label,
    required this.icon,
    required this.busy,
    required this.onPressed,
    this.filled = false,
  });

  final String label;
  final IconData icon;
  final bool busy;
  final bool filled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final Widget leading = busy
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: filled ? Colors.white : AppTokens.brandPrimary))
        : Icon(icon);
    const size = Size.fromHeight(46);
    return filled
        ? FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: AppTokens.brandPrimary, minimumSize: size),
            onPressed: onPressed,
            icon: leading,
            label: Text(label),
          )
        : OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: AppTokens.brandPrimary, minimumSize: size),
            onPressed: onPressed,
            icon: leading,
            label: Text(label),
          );
  }
}

class _ListError extends StatelessWidget {
  const _ListError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Could not load the trucks and drivers.\n$message', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
          ]),
        ),
      );
}
