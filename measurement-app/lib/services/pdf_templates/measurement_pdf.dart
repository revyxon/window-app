import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../models/customer.dart';
import '../../models/window.dart';
import '../../utils/window_types.dart';

class MeasurementPdf {
  static Future<pw.Document> generate({
    required Customer customer,
    required List<Window> windows,
  }) async {
    final pdf = pw.Document();

    // Filter active windows
    final activeWindows = windows.where((w) => !w.isOnHold).toList();
    final totalSqFt = activeWindows.fold(0.0, (sum, w) => sum + w.sqFt);

    // Exact Colors from Document.html
    final colorDark = PdfColor.fromHex('#374151');
    final colorLight = PdfColor.fromHex('#6B7280');

    // Use built-in fonts instead of Google Fonts (no printing package needed)
    final fontRegular = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
        build: (context) {
          return [
            _buildHeader(colorDark, colorLight),
            pw.SizedBox(height: 30),
            _buildCustomerSection(customer, colorDark, colorLight),
            pw.SizedBox(height: 20),
            _buildTableRows(activeWindows, colorDark),
            pw.SizedBox(height: 20),
            _buildFooter(activeWindows.length, totalSqFt, colorDark),
          ];
        },
        footer: (context) => _buildPageFooter(context, colorLight),
      ),
    );

    return pdf;
  }

  static pw.Widget _buildHeader(PdfColor colorDark, PdfColor colorLight) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'DD UPVC WINDOWS SYSTEM',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 13,
                color: colorDark,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Kudri (Medical College Road), Shahdol, Madhya Pradesh',
              style: pw.TextStyle(fontSize: 9, color: colorLight),
            ),
            pw.Text(
              '+91 9826414729 | ddupvcwindowsystem@gmail.com',
              style: pw.TextStyle(fontSize: 9, color: colorLight),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'MEASUREMENT SHEET',
              style: pw.TextStyle(fontSize: 11, color: colorDark),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              DateFormat('dd MMM yyyy').format(DateTime.now()),
              style: pw.TextStyle(fontSize: 9, color: colorLight),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildCustomerSection(
    Customer customer,
    PdfColor colorDark,
    PdfColor colorLight,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'CUSTOMER',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 8,
                color: colorLight,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              customer.name,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 11,
                color: colorDark,
              ),
            ),
            pw.Text(
              customer.location,
              style: pw.TextStyle(fontSize: 10, color: colorLight),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Safe null checks: if customer.framework is null, use '-'
            _buildInfoRow(
              'Framework',
              customer.framework,
              colorDark,
              colorLight,
            ),
            _buildInfoRow(
              'Glass',
              customer.glassType ?? '-',
              colorDark,
              colorLight,
            ),
            if (customer.isFinalMeasurement)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 4),
                child: pw.Text(
                  'FINAL',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                    color: colorDark,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildInfoRow(
    String label,
    String value,
    PdfColor colorDark,
    PdfColor colorLight,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 60,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontSize: 9, color: colorLight),
            ),
          ),
          pw.Text(': ', style: pw.TextStyle(fontSize: 9, color: colorLight)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
              color: colorDark,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTableRows(List<Window> windows, PdfColor colorDark) {
    return pw.Column(
      children: [
        // Custom Header with BG
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          color: colorDark,
          child: pw.Row(
            children: [
              pw.SizedBox(
                width: 30,
                child: pw.Text(
                  '#',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 9,
                    color: PdfColors.white,
                  ),
                ),
              ),
              pw.Expanded(
                flex: 3,
                child: pw.Text(
                  'SIZE (mm)',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 9,
                    color: PdfColors.white,
                  ),
                ),
              ),
              pw.Expanded(
                flex: 4,
                child: pw.Text(
                  'TYPE',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 9,
                    color: PdfColors.white,
                  ),
                ),
              ),
              pw.Expanded(
                flex: 2,
                child: pw.Text(
                  'SQ.FT',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 9,
                    color: PdfColors.white,
                  ),
                  textAlign: pw.TextAlign.right,
                ),
              ),
            ],
          ),
        ),

        // Data Rows
        ...windows.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final w = entry.value;

          String sizeStr;
          if (w.width2 != null && w.width2! > 0) {
            // L-Corner fix: (W1+W2)xH
            sizeStr =
                '(${w.width.toStringAsFixed(0)} + ${w.width2!.toStringAsFixed(0)}) x ${w.height.toStringAsFixed(0)}';
          } else {
            sizeStr =
                '${w.width.toStringAsFixed(0)} x ${w.height.toStringAsFixed(0)}';
          }

          String typeStr = WindowType.getName(w.type);
          if (w.customName != null && w.customName!.isNotEmpty) {
            typeStr = w.customName!;
          }

          return pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                  width: 30,
                  child: pw.Text(
                    index.toString(),
                    style: pw.TextStyle(fontSize: 10, color: colorDark),
                  ),
                ),
                pw.Expanded(
                  flex: 3,
                  child: pw.Text(
                    sizeStr,
                    style: pw.TextStyle(fontSize: 10, color: colorDark),
                  ),
                ),
                pw.Expanded(
                  flex: 4,
                  child: pw.Text(
                    typeStr,
                    style: pw.TextStyle(fontSize: 10, color: colorDark),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    w.sqFt.toStringAsFixed(2),
                    style: pw.TextStyle(fontSize: 10, color: colorDark),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  static pw.Widget _buildFooter(
    int count,
    double totalSqFt,
    PdfColor colorDark,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Total: $count Windows',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 11,
              color: colorDark,
            ),
          ),
          pw.Text(
            '${totalSqFt.toStringAsFixed(2)} Sq.Ft',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 11,
              color: colorDark,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPageFooter(pw.Context context, PdfColor colorLight) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'DD UPVC WINDOWS SYSTEM | +91 9826414729',
          style: pw.TextStyle(fontSize: 7, color: colorLight),
        ),
        pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: pw.TextStyle(fontSize: 7, color: colorLight),
        ),
      ],
    );
  }
}
