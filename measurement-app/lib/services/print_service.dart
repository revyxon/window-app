import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../models/customer.dart';
import '../models/window.dart';
import 'pdf_templates/measurement_pdf.dart';
import 'pdf_templates/invoice_pdf.dart';

class PrintService {
  /// Generates the PDF bytes based on the type (Invoice or Measurement Sheet)
  static Future<Uint8List> _generatePdf({
    required Customer customer,
    required List<Window> windows,
    required bool isInvoice,
  }) async {
    final pw.Document pdf;
    if (isInvoice) {
      pdf = await InvoicePdf.generate(customer: customer, windows: windows);
    } else {
      pdf = await MeasurementPdf.generate(customer: customer, windows: windows);
    }
    return pdf.save();
  }

  /// Print the document - opens share dialog to print via system
  static Future<void> printDocument({
    required Customer customer,
    required List<Window> windows,
    required bool isInvoice,
  }) async {
    // Use share functionality to allow printing via system share sheet
    await shareDocument(
      customer: customer,
      windows: windows,
      isInvoice: isInvoice,
    );
  }

  /// Share the document as a PDF file
  static Future<void> shareDocument({
    required Customer customer,
    required List<Window> windows,
    required bool isInvoice,
  }) async {
    final pdfBytes = await _generatePdf(
      customer: customer,
      windows: windows,
      isInvoice: isInvoice,
    );

    final name = isInvoice ? 'Invoice' : 'Measurement';
    final fileName = '${name}_${customer.name.replaceAll(' ', '_')}.pdf';

    // Save to temporary file
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(pdfBytes);

    // Share using CrossFile (XFile)
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: '$name - ${customer.name}',
      text: 'Please find attached the $name for ${customer.name}.',
    );
  }
}
