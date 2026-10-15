import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'truck_driver_details_models.dart';

/// The blue of the Maleva emblem.
const _brand = PdfColor.fromInt(0xFF233F94);
const _brandSoft = PdfColor.fromInt(0xFFE8EDFA);
const _ink = PdfColor.fromInt(0xFF0F172A);
const _muted = PdfColor.fromInt(0xFF64748B);
const _rule = PdfColor.fromInt(0xFFCBD5E1);

/// Which halves of the sheet to print.
enum SheetPart { both, truck, driver }

/// The sheet as a PDF, the same design as the web download (A4 portrait):
/// Maleva letterhead, Vehicle Details and/or Driver Details as blue-titled
/// cards and a footer. [emblem] is the logo PNG; without it
/// the letterhead is text only. [part] picks the halves; `both` prints
/// whichever of the two is given.
Future<Uint8List> buildTruckDriverDetailsPdf(
  SheetVehicle? vehicle,
  SheetDriver? driver, {
  SheetPart part = SheetPart.both,
  Uint8List? emblem,
  DateTime? now,
}) {
  final truck = part == SheetPart.driver ? null : vehicle;
  final person = part == SheetPart.truck ? null : driver;
  final made = now ?? DateTime.now();
  final title = truck != null && person != null
      ? 'TRUCK & DRIVER DETAILS'
      : truck != null
          ? 'VEHICLE DETAILS'
          : 'DRIVER DETAILS';

  final doc = pw.Document(title: title, author: 'Maleva (M) Sdn. Bhd.');
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(45, 40, 45, 30),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _header(title, emblem, made),
          pw.SizedBox(height: 28),
          if (truck != null) _section('VEHICLE DETAILS', truck.truckNo, truck.rows),
          if (truck != null && person != null) pw.SizedBox(height: 24),
          if (person != null)
            _section('DRIVER DETAILS', person.nricNo.isEmpty ? '' : 'NRIC ${person.nricNo}', person.rows),
          pw.Spacer(),
          _footer(made),
        ],
      ),
    ),
  );
  return doc.save();
}

pw.Widget _header(String title, Uint8List? emblem, DateTime made) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            if (emblem != null) ...[
              pw.Image(pw.MemoryImage(emblem), width: 62, height: 62),
              pw.SizedBox(width: 14),
            ],
            pw.Expanded(
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('MALEVA (M) SDN. BHD.',
                    style: pw.TextStyle(fontSize: 17, fontWeight: pw.FontWeight.bold, color: _brand)),
                pw.SizedBox(height: 4),
                pw.Text('Ship Spare In Transit', style: const pw.TextStyle(fontSize: 9, color: _muted)),
              ]),
            ),
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
              pw.Text(title, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: _ink)),
              pw.SizedBox(height: 4),
              pw.Text('Date: ${DateFormat('dd-MM-yyyy').format(made)}',
                  style: const pw.TextStyle(fontSize: 8.5, color: _muted)),
            ]),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Container(height: 3.4, color: _brand),
        pw.SizedBox(height: 1.8),
        pw.Container(height: 1.7, color: _brandSoft),
      ],
    );

pw.Widget _section(String title, String reference, List<SheetRow> rows) {
  final label = pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: _brand);
  final value = pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: _ink);
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: const pw.BoxDecoration(
          color: _brand,
          borderRadius: pw.BorderRadius.only(topLeft: pw.Radius.circular(4.5), topRight: pw.Radius.circular(4.5)),
        ),
        child: pw.Row(children: [
          pw.Expanded(
            child: pw.Text(title,
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
          ),
          if (reference.isNotEmpty)
            pw.Text(reference, style: const pw.TextStyle(fontSize: 9, color: PdfColors.white)),
        ]),
      ),
      pw.Container(
        // A brand edge down the left of the card.
        decoration: const pw.BoxDecoration(border: pw.Border(left: pw.BorderSide(color: _brand, width: 2.6))),
        child: pw.Table(
          border: pw.TableBorder.all(color: _rule, width: 0.7),
          columnWidths: const {0: pw.FlexColumnWidth(34), 1: pw.FlexColumnWidth(66)},
          children: [
            for (final row in rows)
              pw.TableRow(
                verticalAlignment: pw.TableCellVerticalAlignment.middle,
                children: [
                  pw.Container(
                    color: _brandSoft,
                    padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: pw.Text(row.label, style: label),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: pw.Text(row.value.isEmpty ? '-' : row.value, style: value),
                  ),
                ],
              ),
          ],
        ),
      ),
    ],
  );
}

pw.Widget _footer(DateTime made) => pw.Column(children: [
      pw.Container(height: 0.8, color: _rule),
      pw.SizedBox(height: 6),
      pw.Row(children: [
        pw.Expanded(
          child: pw.Text('Maleva (M) Sdn. Bhd.  |  Truck & Driver Details',
              style: const pw.TextStyle(fontSize: 8, color: _muted)),
        ),
        pw.Text('Generated ${DateFormat('dd-MM-yyyy HH:mm').format(made)}',
            style: const pw.TextStyle(fontSize: 8, color: _muted)),
      ]),
    ]);
