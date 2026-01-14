import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../models/customer.dart';
import '../../models/window.dart';
import '../../utils/window_types.dart';

/// InvoicePdf - Strict Replica of PrintInvoicePage.tsx
class InvoicePdf {
  static const PdfColor black = PdfColors.black;
  static const PdfColor white = PdfColors.white;
  static const PdfColor bgGrayF8 = PdfColor.fromInt(0xFFF8FAFC);
  static const PdfColor borderGrayE2 = PdfColor.fromInt(0xFFE2E8F0);
  static const PdfColor textGray64 = PdfColor.fromInt(0xFF64748B);
  static const PdfColor textGray94 = PdfColor.fromInt(0xFF94A3B8);

  static Future<pw.Document> generate({
    required Customer customer,
    required List<Window> windows,
  }) async {
    final pdf = pw.Document();

    // Use built-in fonts instead of Google Fonts (no printing package needed)
    final fontRegular = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();
    final fontMono = pw.Font.courier();

    final activeWindows = windows.where((w) => !w.isOnHold).toList();
    final totalSqFt = activeWindows.fold(0.0, (sum, w) => sum + w.sqFt);
    final rate = customer.ratePerSqft ?? 0;
    final totalAmount = totalSqFt * rate;

    final now = DateTime.now();
    final invoiceNo =
        '#DDUPVC/${DateFormat('yy').format(now)}/${customer.id?.substring(0, 4).toUpperCase() ?? "0001"}';
    final dateStr = DateFormat('dd MMM yyyy').format(now);
    final reference =
        'REF-${customer.id?.substring(0, 8).toUpperCase() ?? "MK70NSSC"}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(10 * PdfPageFormat.mm),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
          fontFallback: [fontRegular],
        ),
        build: (context) {
          return [
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: black, width: 1),
                color: white,
              ),
              padding: const pw.EdgeInsets.all(10),
              constraints: const pw.BoxConstraints(
                minHeight: 270 * PdfPageFormat.mm,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildHeader(
                    invoiceNo,
                    dateStr,
                    reference,
                    fontRegular,
                    fontBold,
                  ),

                  pw.SizedBox(height: 10),
                  _buildInfoGrid(
                    customer,
                    activeWindows.length,
                    totalSqFt,
                    rate,
                    fontRegular,
                    fontBold,
                  ),

                  pw.SizedBox(height: 15),

                  pw.Align(
                    alignment: pw.Alignment.center,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 3,
                      ),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromInt(0xFFE8E8E8),
                        border: pw.Border.all(color: black, width: 1),
                      ),
                      child: pw.Text(
                        "BLOCK A",
                        style: pw.TextStyle(font: fontBold, fontSize: 12),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 5),

                  _buildTable(
                    activeWindows,
                    totalSqFt,
                    totalAmount,
                    rate,
                    fontRegular,
                    fontBold,
                    fontMono,
                  ),

                  pw.SizedBox(height: 10),
                  _buildSummary(
                    totalAmount,
                    activeWindows.isEmpty ? 0 : 0,
                    totalAmount,
                    fontRegular,
                    fontBold,
                    fontMono,
                  ),

                  pw.Spacer(),

                  _buildFooterGrid(fontRegular, fontBold),

                  pw.SizedBox(height: 30),

                  _buildSignatures(fontRegular, fontBold),

                  pw.SizedBox(height: 20),
                  pw.Container(
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        top: pw.BorderSide(
                          color: PdfColor.fromInt(0xFFCCCCCC),
                          style: pw.BorderStyle.dotted,
                        ),
                      ),
                    ),
                    padding: const pw.EdgeInsets.only(top: 5),
                    width: double.infinity,
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      'This is a Computer Generated Invoice',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColor.fromInt(0xFF666666),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _buildHeader(
    String invNo,
    String date,
    String ref,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: black, width: 2)),
      ),
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'DD UPVC WINDOWS SYSTEM',
                style: pw.TextStyle(font: fontBold, fontSize: 20),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Kudri (Medical College Road), Shahdol, Madhya Pradesh',
                style: const pw.TextStyle(fontSize: 11),
              ),
              pw.Text(
                'Contact: +91 9826414729',
                style: pw.TextStyle(font: fontBold, fontSize: 11),
              ),
              pw.Text(
                'Email: ddupvcwindowsystem@gmail.com',
                style: pw.TextStyle(font: fontBold, fontSize: 11),
              ),
              pw.Text(
                'GSTIN: 23EVFPG6600A1ZB',
                style: pw.TextStyle(font: fontBold, fontSize: 11),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: black, width: 2),
                ),
                margin: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Text(
                  'PROFORMA INVOICE',
                  style: pw.TextStyle(font: fontBold, fontSize: 16),
                ),
              ),
              _invRow('Invoice No:', invNo, fontBold),
              _invRow('Date:', date, fontBold),
              _invRow('Reference:', ref, fontBold),
              _invRow('Page:', '1 of 1', fontBold),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _invRow(String label, String value, pw.Font fontBold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(label, style: pw.TextStyle(font: fontBold, fontSize: 12)),
          pw.SizedBox(width: 5),
          pw.Text(value, style: const pw.TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoGrid(
    Customer customer,
    int count,
    double sqft,
    double rate,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: black, width: 1)),
      ),
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 6,
            child: pw.Container(
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  right: pw.BorderSide(
                    color: PdfColor.fromInt(0xFFCCCCCC),
                    width: 1,
                  ),
                ),
              ),
              padding: const pw.EdgeInsets.only(right: 10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'BILL TO',
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 10,
                      color: PdfColor.fromInt(0xFF555555),
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    customer.name,
                    style: pw.TextStyle(font: fontBold, fontSize: 14),
                  ),
                  pw.Text(
                    customer.location,
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                  if (customer.phone != null)
                    pw.Text(
                      'Phone: ${customer.phone}',
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                ],
              ),
            ),
          ),
          pw.Expanded(
            flex: 4,
            child: pw.Padding(
              padding: const pw.EdgeInsets.only(left: 10),
              child: pw.Column(
                children: [
                  _metaRow('Total Items', '$count', fontBold),
                  _metaRow('Total Sqft', sqft.toStringAsFixed(2), fontBold),
                  _metaRow(
                    'Rate / Sqft',
                    'Rs. ${rate.toStringAsFixed(2)}',
                    fontBold,
                  ),
                  _metaRow('Status', 'FINALIZED', fontBold),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _metaRow(String label, String value, pw.Font fontBold) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColor.fromInt(0xFFEEEEEE), width: 1),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(
              fontSize: 11,
              color: PdfColor.fromInt(0xFF555555),
            ),
          ),
          pw.Text(value, style: pw.TextStyle(font: fontBold, fontSize: 11)),
        ],
      ),
    );
  }

  static pw.Widget _buildTable(
    List<Window> windows,
    double totalSqFt,
    double totalAmount,
    double rate,
    pw.Font font,
    pw.Font fontBold,
    pw.Font fontMono,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: black, width: 1),
      columnWidths: {
        0: const pw.FixedColumnWidth(30),
        1: const pw.FlexColumnWidth(4),
        2: const pw.FixedColumnWidth(60),
        3: const pw.FixedColumnWidth(60),
        4: const pw.FixedColumnWidth(40),
        5: const pw.FixedColumnWidth(60),
        6: const pw.FixedColumnWidth(80),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColor.fromInt(0xFFF0F0F0),
          ),
          children: [
            _th('#', fontBold),
            _th('DESCRIPTION', fontBold, align: pw.TextAlign.left),
            _th('WIDTH', fontBold),
            _th('HEIGHT', fontBold),
            _th('QTY', fontBold),
            _th('SQFT', fontBold),
            _th('AMOUNT', fontBold),
          ],
        ),
        ...windows.asMap().entries.map((entry) {
          final i = entry.key + 1;
          final w = entry.value;
          final amount = w.sqFt * rate;

          String widthStr = w.width.toStringAsFixed(0);
          if (w.width2 != null && w.width2! > 0) {
            widthStr =
                '(${w.width.toStringAsFixed(0)}+${w.width2!.toStringAsFixed(0)})';
          }

          String desc = WindowType.getName(w.type);
          if (w.customName != null && w.customName!.isNotEmpty) {
            desc = w.customName!;
          }

          final isEven = (i % 2) == 0;

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: isEven ? PdfColor.fromInt(0xFFFAFAFA) : white,
            ),
            children: [
              _td('$i', font),
              _td(desc, fontBold, align: pw.TextAlign.left),
              _td(widthStr, fontMono),
              _td(w.height.toStringAsFixed(0), fontMono),
              _td('1', fontMono),
              _td(w.sqFt.toStringAsFixed(2), fontMono),
              _td(
                amount.toStringAsFixed(2),
                fontMono,
                fontBold: true,
                align: pw.TextAlign.right,
              ),
            ],
          );
        }),
        if (windows.length < 12)
          ...List.generate(12 - windows.length, (idx) {
            final n = windows.length + idx + 1;
            return pw.TableRow(
              children: [
                _td('$n', font, color: PdfColor.fromInt(0xFFCCCCCC)),
                _td('', font),
                _td('', font),
                _td('', font),
                _td('', font),
                _td('', font),
                _td('', font),
              ],
            );
          }),
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColor.fromInt(0xFFEEEEEE),
          ),
          children: [
            pw.Container(),
            pw.Container(),
            pw.Container(),
            pw.Container(),
            pw.Container(
              padding: const pw.EdgeInsets.all(5),
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'TOTAL',
                style: pw.TextStyle(font: fontBold, fontSize: 11),
              ),
            ),
            _td(totalSqFt.toStringAsFixed(2), fontMono, fontBold: true),
            _td(
              totalAmount.toStringAsFixed(2),
              fontMono,
              fontBold: true,
              align: pw.TextAlign.right,
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _th(
    String text,
    pw.Font font, {
    pw.TextAlign align = pw.TextAlign.center,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          font: font,
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.Widget _td(
    String text,
    pw.Font font, {
    pw.TextAlign align = pw.TextAlign.center,
    bool fontBold = false,
    PdfColor color = black,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 4),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          font: font,
          fontSize: 11,
          fontWeight: fontBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color,
        ),
      ),
    );
  }

  static pw.Widget _buildSummary(
    double amount,
    double paid,
    double balance,
    pw.Font font,
    pw.Font fontBold,
    pw.Font fontMono,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: black, width: 1),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 6,
            child: pw.Container(
              decoration: const pw.BoxDecoration(
                border: pw.Border(right: pw.BorderSide(color: black, width: 1)),
              ),
              padding: const pw.EdgeInsets.all(10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Amount in Words',
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 10,
                      color: PdfColor.fromInt(0xFF555555),
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    '${_toWords(amount.round())} Rupees Only',
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 12,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
          pw.Expanded(
            flex: 4,
            child: pw.Column(
              children: [
                _sumLine('Subtotal', amount, fontMono),
                if (paid > 0) ...[
                  _sumLine('Paid', paid, fontMono),
                  _sumLine('Balance Due', balance, fontMono, isFinal: true),
                ] else ...[
                  _sumLine('Net Amount', amount, fontMono),
                  pw.Container(
                    color: black,
                    padding: const pw.EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 10,
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'TOTAL PAYABLE',
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 13,
                            color: white,
                          ),
                        ),
                        pw.Text(
                          'Rs.${amount.toStringAsFixed(2)}',
                          style: pw.TextStyle(
                            font: fontMono,
                            fontSize: 13,
                            color: white,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _sumLine(
    String label,
    double val,
    pw.Font fontMono, {
    bool isFinal = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      color: isFinal ? black : null,
      decoration: isFinal
          ? null
          : const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(
                  color: PdfColor.fromInt(0xFFCCCCCC),
                  width: 1,
                ),
              ),
            ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 11,
              color: isFinal ? white : black,
              fontWeight: isFinal ? pw.FontWeight.bold : null,
            ),
          ),
          pw.Text(
            val.toStringAsFixed(2),
            style: pw.TextStyle(
              font: fontMono,
              fontSize: 11,
              color: isFinal ? white : black,
              fontWeight: isFinal ? pw.FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooterGrid(pw.Font font, pw.Font fontBold) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: black, width: 1),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Container(
              decoration: const pw.BoxDecoration(
                border: pw.Border(right: pw.BorderSide(color: black, width: 1)),
              ),
              padding: const pw.EdgeInsets.all(10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'BANK DETAILS',
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 10,
                      decoration: pw.TextDecoration.underline,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Bank: State Bank of India (SBI)',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                  pw.Text(
                    'A/c No: 44250720832',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                  pw.Text(
                    'Name: DD UPVC Windows System',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                  pw.Text(
                    'IFSC: SBIN0061553',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'TERMS & CONDITIONS',
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 10,
                      decoration: pw.TextDecoration.underline,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    '1. Installation on FOR basis',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    '2. Timeline: 25-35 working days post advance',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    '3. Payment Schedule: 50% Advance, 30% Post-Dispatch, 20% Post-Installation',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    '4. Compliance: Payments must follow schedule',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSignatures(pw.Font font, pw.Font fontBold) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Container(width: 150, height: 1, color: black),
            pw.SizedBox(height: 5),
            pw.Text(
              'Customer Signature',
              style: pw.TextStyle(font: fontBold, fontSize: 10),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              'For DD UPVC Windows System',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 40),
            pw.Container(width: 150, height: 1, color: black),
            pw.SizedBox(height: 5),
            pw.Text(
              'Authorised Signatory',
              style: pw.TextStyle(font: fontBold, fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }

  static String _toWords(int n) {
    if (n == 0) return 'Zero';
    final o = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine',
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen',
    ];
    final t = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety',
    ];
    String c(int x) {
      if (x < 20) {
        return o[x];
      }
      if (x < 100) {
        return '${t[x ~/ 10]}${x % 10 != 0 ? ' ${o[x % 10]}' : ''}';
      }
      if (x < 1000) {
        return '${o[x ~/ 100]} Hundred${x % 100 != 0 ? ' ${c(x % 100)}' : ''}';
      }
      if (x < 100000) {
        return '${c(x ~/ 1000)} Thousand${x % 1000 != 0 ? ' ${c(x % 1000)}' : ''}';
      }
      if (x < 10000000) {
        return '${c(x ~/ 100000)} Lakh${x % 100000 != 0 ? ' ${c(x % 100000)}' : ''}';
      }
      // For Crores
      return '${c(x ~/ 10000000)} Crore${x % 10000000 != 0 ? ' ${c(x % 10000000)}' : ''}';
    }

    return c(n);
  }
}
